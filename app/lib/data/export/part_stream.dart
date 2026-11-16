/// One account's rows as parts (CR-160 Stage B4/B6,
/// docs/cr-160-multipart-export.md §4): what a backup stored as parts and
/// a multipart export share, so there is one way to read and one format.
/// Run both passes inside one read transaction (one consistent cut): the
/// first plans where parts end from each row's size, the second hands each
/// part to a sink, one part in memory at a time. Rows come in written
/// order (part tables, then id), a page at a time.
library;

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dottoday/data/calendar/pending_calendar_series.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_part.dart';
import 'package:dottoday/domain/export/multipart_planner.dart';
import 'package:drift/drift.dart';

/// Which rows a set holds, as `readUserData` reads them.
enum RowScope {
  /// A backup or a Settings export: imported calendar events and their
  /// steps left out; no calendar-series templates.
  standard,

  /// D1's export before an account deletion: imported calendar events
  /// kept as ordinary tasks, every calendar-series template included.
  accountDeletion,
}

/// Where the parts end, or why there are none.
sealed class Planned {
  const Planned();
}

/// No profile for the owner: nothing to write.
final class NoProfile extends Planned {
  const NoProfile();
}

/// A row no part could hold (§4: never left out, the set fails).
final class RowOverTarget extends Planned {
  const RowOverTarget(this.table);
  final String table;
}

/// Rows per part, the totals per table and part 1's profile.
final class PartPlan extends Planned {
  const PartPlan(this.profile, this.sizes, this.totals);
  final Map<String, Object?> profile;
  final List<int> sizes;
  final TableCounts totals;
}

/// Hands one finished part on: its index, text, UTF-8 bytes and SHA-256.
typedef PartSink =
    Future<void> Function(int index, String text, List<int> bytes, String hash);

const _page = 500;

/// The first pass: plans [owner]'s parts of at most [targetBytes]. Reads
/// in [reads] (the read transaction's zone).
Future<Planned> planParts(
  AppDatabase db,
  Zone reads,
  String owner,
  RowScope scope, {
  required String exportId,
  required int targetBytes,
}) async {
  final row = await reads.run(
    (db.select(db.profiles)..where((p) => p.id.equals(owner))).getSingleOrNull,
  );
  if (row == null) return const NoProfile();
  final profile = profileFromRow(row).toJson();
  final planner = PartPlanner(
    exportId: exportId,
    profile: profile,
    targetBytes: targetBytes,
  );
  final totals = {for (final t in partTables) t: 0};
  var fits = true;
  await eachPartRow(db, reads, owner, scope, (table, row) async {
    totals[table] = totals[table]! + 1;
    fits = fits && planner.add(table, row);
  });
  if (!fits) return RowOverTarget(planner.tooLarge!);
  return PartPlan(profile, planner.finish(), totals);
}

/// The second pass: writes [plan]'s parts in order to [sink] and returns
/// their manifest entries, each named by [name] (index, total).
Future<List<PartEntry>> writeParts(
  AppDatabase db,
  Zone reads,
  String owner,
  RowScope scope,
  PartPlan plan, {
  required String exportId,
  required String Function(int index, int total) name,
  required PartSink sink,
}) async {
  final sizes = plan.sizes;
  final entries = <PartEntry>[];
  var part = <String, List<Map<String, Object?>>>{
    for (final t in partTables) t: [],
  };
  var inPart = 0;
  Future<void> flush() async {
    final index = entries.length + 1;
    final text = canonicalJson(
      ExportPart(
        exportId: exportId,
        index: index,
        total: sizes.length,
        profile: index == 1 ? plan.profile : null,
        rows: part,
      ).toJson(),
    );
    // The rows are text now: let them go before the part is handed on,
    // and encode it once for both its size and its hash (peak memory, §7).
    final counts = {for (final t in partTables) t: part[t]!.length};
    part = {for (final t in partTables) t: []};
    inPart = 0;
    final bytes = utf8.encode(text);
    final hash = sha256.convert(bytes).toString();
    await sink(index, text, bytes, hash);
    entries.add(
      PartEntry(
        index: index,
        name: name(index, sizes.length),
        bytes: bytes.length,
        sha256: hash,
        counts: counts,
      ),
    );
  }

  Future<void> flushEmpty() async {
    // Part 1 may hold the profile alone (the planner said so).
    while (entries.length < sizes.length && sizes[entries.length] == 0) {
      await flush();
    }
  }

  await flushEmpty();
  await eachPartRow(db, reads, owner, scope, (table, row) async {
    part[table]!.add(row);
    inPart++;
    if (inPart == sizes[entries.length]) {
      await flush();
      await flushEmpty();
    }
  });
  return entries;
}

/// Runs [visit] on every row [scope] holds of [owner], in written order,
/// a page at a time, each page read in [reads].
Future<void> eachPartRow(
  AppDatabase db,
  Zone reads,
  String owner,
  RowScope scope,
  Future<void> Function(String table, Map<String, Object?> row) visit,
) async {
  final all = scope == RowScope.accountDeletion;
  final calendarEvents = db.selectOnly(db.occurrences)
    ..addColumns([db.occurrences.id])
    ..where(db.occurrences.source.equals('calendar'));
  for (final table in partTables) {
    if (table == 'calendarSeries') {
      if (!all) continue;
      // A few per calendar: read whole, as readUserData does.
      for (final t in await reads.run(
        () => readCalendarSeriesTemplates(db, owner),
      )) {
        await visit(table, t.toJson());
      }
      continue;
    }
    var after = '';
    while (true) {
      final page = await reads.run(
        () => _rowsPage(db, table, owner, after, all, calendarEvents),
      );
      if (page.isEmpty) break;
      for (final (_, row) in page) {
        await visit(table, row);
      }
      after = page.last.$1;
    }
  }
}

/// One page of [table] after id [after]: (id, row as JSON).
Future<List<(String, Map<String, Object?>)>> _rowsPage(
  AppDatabase db,
  String table,
  String owner,
  String after,
  bool all,
  BaseSelectStatement<Object?> calendarEvents,
) async => switch (table) {
  'series' => [
    for (final r
        in await (db.select(db.seriesTable)
              ..where(
                (t) => t.userId.equals(owner) & t.id.isBiggerThanValue(after),
              )
              ..orderBy([(t) => OrderingTerm(expression: t.id)])
              ..limit(_page))
            .get())
      (r.id, seriesFromRow(r).toJson()),
  ],
  'occurrences' => [
    for (final r
        in await (db.select(db.occurrences)
              ..where(
                (t) =>
                    t.userId.equals(owner) &
                    t.id.isBiggerThanValue(after) &
                    (all
                        ? const Constant(true)
                        : t.source.equals('calendar').not()),
              )
              ..orderBy([(t) => OrderingTerm(expression: t.id)])
              ..limit(_page))
            .get())
      (r.id, _occurrence(r, all)),
  ],
  'subtasks' => [
    for (final r
        in await (db.select(db.subtasks)
              ..where(
                (t) =>
                    t.userId.equals(owner) &
                    t.id.isBiggerThanValue(after) &
                    (all
                        ? const Constant(true)
                        : t.occurrenceId.isNotInQuery(calendarEvents)),
              )
              ..orderBy([(t) => OrderingTerm(expression: t.id)])
              ..limit(_page))
            .get())
      (r.id, subtaskFromRow(r).toJson()),
  ],
  'routines' => [
    for (final r
        in await (db.select(db.routinesTable)
              ..where(
                (t) => t.userId.equals(owner) & t.id.isBiggerThanValue(after),
              )
              ..orderBy([(t) => OrderingTerm(expression: t.id)])
              ..limit(_page))
            .get())
      (r.id, routineFromRow(r).toJson()),
  ],
  _ => const [],
};

/// An occurrence as its set holds it: D1 keeps an imported calendar event
/// as an ordinary task (`ExportBundle.withImportedAsTasks`).
Map<String, Object?> _occurrence(OccurrenceRow r, bool all) {
  final o = occurrenceFromRow(r);
  if (!all || o.source != OccurrenceSource.calendar) return o.toJson();
  return o
      .copyWith(source: OccurrenceSource.user, calendarLinkId: null)
      .toJson();
}
