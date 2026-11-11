/// Splitting an export into parts (CR-160 Stage B1,
/// docs/cr-160-multipart-export.md §4). An export that fits one part stays
/// today's JSON v1 file. Otherwise rows go into parts in table order, a new
/// part starting before a row would push the current one past the target;
/// relationship groups may span parts (the importer resolves references
/// across the whole set). A row larger than any part could hold fails the
/// split loudly: nothing is ever left out.
///
/// Two passes over the rows: the first plans where parts end from each
/// row's encoded size, the second writes them, so every part knows the
/// total. A source can be read twice in one read transaction (B4/B6 will
/// stream rows that way); here the rows come from an [ExportBundle].
library;

import 'dart:convert';

import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_part.dart';

/// The result of [splitExport].
sealed class ExportSplit {
  const ExportSplit();
}

/// It fits one part: today's JSON v1 file, unchanged.
final class SingleFileSplit extends ExportSplit {
  const SingleFileSplit(this.text);
  final String text;
}

/// The manifest first, then the parts in order.
final class MultipartSplit extends ExportSplit {
  const MultipartSplit(this.manifest, this.files);
  final ExportManifest manifest;
  final List<ExportFile> files;
}

/// One row of [table] can't fit in any part: nothing was made.
final class RowTooLarge extends ExportSplit {
  const RowTooLarge(this.table);
  final String table;
}

/// One row with its table, in written order.
typedef PartRow = ({String table, Map<String, Object?> row});

/// Splits [bundle] for [purpose]. [date] is the person's local
/// `yyyy-MM-dd` for the file names; [exportId] a fresh UUID v7.
///
/// ```dart
/// switch (splitExport(b, exportId: id, appVersion: v, schemaVersion: 21,
///     purpose: ExportPurpose.export, date: '2026-11-11')) { ... }
/// ```
ExportSplit splitExport(
  ExportBundle bundle, {
  required String exportId,
  required String appVersion,
  required int schemaVersion,
  required ExportPurpose purpose,
  required String date,
  int targetBytes = partTargetBytes,
}) {
  assert(targetBytes <= maxImportBytes, 'a part must stay readable');
  final json = bundle.toJson();
  final rows = <PartRow>[
    for (final t in partTables)
      for (final r in (json[t] as List<Object?>?) ?? const [])
        (table: t, row: r! as Map<String, Object?>),
  ];
  final single = encodeExportJson(bundle);
  if (utf8.encode(single).length <= targetBytes) return SingleFileSplit(single);
  final profile = json['profile']! as Map<String, Object?>;
  final (:table, plan: sizes) = _plan(rows, exportId, profile, targetBytes);
  if (sizes == null) return RowTooLarge(table);
  final parts = _write(rows, sizes, exportId, profile);
  // The plan is an upper bound, so this holds unless the plan is wrong.
  assert(parts.every((p) => utf8.encode(p).length <= targetBytes));
  final stem = 'dottoday-backup-$date-${exportId.substring(0, 8)}';
  final width = '${parts.length}'.length.clamp(2, 6);
  String n(int i) => '$i'.padLeft(width, '0');
  final entries = [
    for (final (i, text) in parts.indexed)
      PartEntry(
        index: i + 1,
        name: '$stem-part-${n(i + 1)}-of-${n(parts.length)}.json',
        bytes: utf8.encode(text).length,
        sha256: sha256Hex(text),
        counts: _counts(rows, sizes, i),
      ),
  ];
  final manifest = ExportManifest(
    exportId: exportId,
    exportedAtMs: bundle.exportedAt.millisecondsSinceEpoch,
    appVersion: appVersion,
    schemaVersion: schemaVersion,
    purpose: purpose,
    totals: {
      for (final t in partTables) t: rows.where((r) => r.table == t).length,
    },
    parts: entries,
  );
  return MultipartSplit(manifest, [
    ExportFile(
      name: '$stem-manifest.json',
      mimeType: 'application/json',
      content: canonicalJson(manifest.toJson()),
    ),
    for (final (i, text) in parts.indexed)
      ExportFile(
        name: entries[i].name,
        mimeType: 'application/json',
        content: text,
      ),
  ]);
}

/// Rows per part; or the table of a row too large for any part.
({String table, List<int>? plan}) _plan(
  List<PartRow> rows,
  String exportId,
  Map<String, Object?> profile,
  int target,
) {
  final firstHeader = _headerBytes(exportId, profile);
  final header = _headerBytes(exportId, null);
  final plan = <int>[];
  var used = firstHeader;
  var count = 0;
  for (final r in rows) {
    // +1: the comma before it (an upper bound for an array's first row).
    final size = utf8.encode(canonicalJson(r.row)).length + 1;
    if (header + size > target) return (table: r.table, plan: null);
    if (used + size > target) {
      plan.add(count);
      used = header;
      count = 0;
    }
    used += size;
    count++;
  }
  plan.add(count);
  return (table: '', plan: plan);
}

/// Bytes of an empty part, with the widest index and total a plan can need.
int _headerBytes(String exportId, Map<String, Object?>? profile) => utf8
    .encode(
      canonicalJson(
        ExportPart(
          exportId: exportId,
          index: 999999,
          total: 999999,
          profile: profile,
          rows: {for (final t in partTables) t: const []},
        ).toJson(),
      ),
    )
    .length;

List<String> _write(
  List<PartRow> rows,
  List<int> sizes,
  String exportId,
  Map<String, Object?> profile,
) {
  final out = <String>[];
  var next = 0;
  for (final (i, size) in sizes.indexed) {
    final slice = rows.sublist(next, next + size);
    next += size;
    out.add(
      canonicalJson(
        ExportPart(
          exportId: exportId,
          index: i + 1,
          total: sizes.length,
          profile: i == 0 ? profile : null,
          rows: {
            for (final t in partTables)
              t: [
                for (final r in slice)
                  if (r.table == t) r.row,
              ],
          },
        ).toJson(),
      ),
    );
  }
  return out;
}

TableCounts _counts(List<PartRow> rows, List<int> sizes, int part) {
  final start = sizes.take(part).fold(0, (a, b) => a + b);
  final slice = rows.sublist(start, start + sizes[part]);
  return {
    for (final t in partTables) t: slice.where((r) => r.table == t).length,
  };
}
