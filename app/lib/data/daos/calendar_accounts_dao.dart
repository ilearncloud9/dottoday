import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/tables/calendar_tables.dart';
import 'package:drift/drift.dart';

part 'calendar_accounts_dao.g.dart';

/// Single-table queries over `calendar_accounts`; rows only, no mapping.
@DriftAccessor(tables: [CalendarAccounts])
class CalendarAccountsDao extends DatabaseAccessor<AppDatabase>
    with _$CalendarAccountsDaoMixin {
  CalendarAccountsDao(super.attachedDatabase);

  /// Rows of [userId] from any of [providers], oldest first.
  Stream<List<CalendarAccountRow>> watchByProviders(
    String userId,
    Set<String> providers,
  ) =>
      (select(calendarAccounts)
            ..where((a) => a.userId.equals(userId) & a.provider.isIn(providers))
            ..orderBy([(a) => OrderingTerm(expression: a.createdAt)]))
          .watch();

  /// The row of [userId] for the external id [externalId] of [provider].
  Future<CalendarAccountRow?> findExternal(
    String userId,
    String provider,
    String externalId,
  ) =>
      (select(calendarAccounts)..where(
            (a) =>
                a.userId.equals(userId) &
                a.provider.equals(provider) &
                a.externalAccountId.equals(externalId),
          ))
          .getSingleOrNull();

  Future<void> upsert(Insertable<CalendarAccountRow> row) =>
      into(calendarAccounts).insertOnConflictUpdate(row);
}
