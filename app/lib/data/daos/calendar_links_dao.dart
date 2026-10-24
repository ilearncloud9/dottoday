import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/tables/calendar_tables.dart';
import 'package:dottoday/data/db/tables/occurrences.dart';
import 'package:drift/drift.dart';

part 'calendar_links_dao.g.dart';

/// Queries over `calendar_links` and the imported occurrences they point
/// at (docs/05, docs/09 M7.2); rows only, no mapping.
@DriftAccessor(tables: [CalendarLinks, CalendarAccounts, Occurrences])
class CalendarLinksDao extends DatabaseAccessor<AppDatabase>
    with _$CalendarLinksDaoMixin {
  CalendarLinksDao(super.attachedDatabase);

  /// Every link of [userId] whose account is one of [providers], with its
  /// occurrence when one still points at it (deleted ones included).
  Future<List<(CalendarLinkRow, OccurrenceRow?)>> linked(
    String userId,
    Set<String> providers,
  ) async {
    final query =
        select(calendarLinks).join([
          innerJoin(
            calendarAccounts,
            calendarAccounts.id.equalsExp(calendarLinks.accountId),
          ),
          leftOuterJoin(
            occurrences,
            occurrences.calendarLinkId.equalsExp(calendarLinks.id),
          ),
        ])..where(
          calendarLinks.userId.equals(userId) &
              calendarAccounts.provider.isIn(providers),
        );
    final rows = await query.get();
    return [
      for (final r in rows)
        (r.readTable(calendarLinks), r.readTableOrNull(occurrences)),
    ];
  }

  /// [userId]'s live imported occurrences that may send changes back
  /// (docs/09 M7.3): a writable link of a switched-on calendar of
  /// [providers] with write-back on. Watchable, so an edit here starts a
  /// write-back.
  Selectable<(CalendarLinkRow, OccurrenceRow, CalendarAccountRow)>
  writeBackCandidates(String userId, Set<String> providers) {
    final query =
        select(calendarLinks).join([
          innerJoin(
            calendarAccounts,
            calendarAccounts.id.equalsExp(calendarLinks.accountId),
          ),
          innerJoin(
            occurrences,
            occurrences.calendarLinkId.equalsExp(calendarLinks.id),
          ),
        ])..where(
          calendarLinks.userId.equals(userId) &
              calendarLinks.readOnly.equals(false) &
              calendarAccounts.provider.isIn(providers) &
              calendarAccounts.writeBack.equals(true) &
              calendarAccounts.enabled.equals(true) &
              occurrences.deletedAt.isNull(),
        );
    return query.map(
      (r) => (
        r.readTable(calendarLinks),
        r.readTable(occurrences),
        r.readTable(calendarAccounts),
      ),
    );
  }

  /// Link [linkId] of [userId] with its calendar row, watchable (the
  /// editor's write-back line, M7.3).
  Selectable<(CalendarLinkRow, CalendarAccountRow)> linkWithAccount(
    String userId,
    String linkId,
  ) {
    final query =
        select(calendarLinks).join([
          innerJoin(
            calendarAccounts,
            calendarAccounts.id.equalsExp(calendarLinks.accountId),
          ),
        ])..where(
          calendarLinks.userId.equals(userId) & calendarLinks.id.equals(linkId),
        );
    return query.map(
      (r) => (r.readTable(calendarLinks), r.readTable(calendarAccounts)),
    );
  }

  /// Ids of [userId]'s imported occurrences that have live subtasks.
  Future<Set<String>> withSubtasks(String userId) async {
    final rows = await customSelect(
      'SELECT DISTINCT s.occurrence_id AS id FROM subtasks s '
      'JOIN occurrences o ON o.id = s.occurrence_id '
      "WHERE s.user_id = ? AND s.deleted_at IS NULL AND o.source = 'calendar'",
      variables: [Variable<String>(userId)],
      readsFrom: {occurrences, attachedDatabase.subtasks},
    ).get();
    return {for (final r in rows) r.read<String>('id')};
  }

  /// Ids of [userId]'s live imported occurrences whose calendar won't take
  /// a change back: the link is read-only (read-only calendar, repeating or
  /// all-day event) or gone. A shift never moves them (docs/09 M7.6).
  /// Watchable, so the timeline follows imports and permission changes.
  Selectable<String> readOnlyImportIds(String userId) => customSelect(
    'SELECT o.id AS id FROM occurrences o '
    'LEFT JOIN calendar_links l ON l.id = o.calendar_link_id '
    "WHERE o.user_id = ? AND o.source = 'calendar' AND o.deleted_at IS NULL "
    'AND (l.id IS NULL OR l.read_only = 1)',
    variables: [Variable<String>(userId)],
    readsFrom: {occurrences, calendarLinks},
  ).map((r) => r.read<String>('id'));

  Future<void> upsertAll(Iterable<Insertable<CalendarLinkRow>> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(calendarLinks, rows.toList()));

  Future<void> upsertLink(Insertable<CalendarLinkRow> row) =>
      into(calendarLinks).insertOnConflictUpdate(row);

  Future<void> deleteLinks(String userId, Set<String> ids) => (delete(
    calendarLinks,
  )..where((l) => l.userId.equals(userId) & l.id.isIn(ids))).go();

  /// Removes imported occurrences outright. Only `source = 'calendar'`
  /// rows can go, so a person's own task is never hard-deleted here.
  Future<void> deleteImported(String userId, Set<String> ids) =>
      (delete(occurrences)..where(
            (o) =>
                o.userId.equals(userId) &
                o.source.equals('calendar') &
                o.id.isIn(ids),
          ))
          .go();
}
