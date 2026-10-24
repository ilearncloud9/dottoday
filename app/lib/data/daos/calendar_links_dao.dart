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

  Future<void> upsertAll(Iterable<Insertable<CalendarLinkRow>> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(calendarLinks, rows.toList()));

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
