// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_links_dao.dart';

// ignore_for_file: type=lint
mixin _$CalendarLinksDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $CalendarAccountsTable get calendarAccounts =>
      attachedDatabase.calendarAccounts;
  $CalendarLinksTable get calendarLinks => attachedDatabase.calendarLinks;
  $SeriesTableTable get seriesTable => attachedDatabase.seriesTable;
  $OccurrencesTable get occurrences => attachedDatabase.occurrences;
  CalendarLinksDaoManager get managers => CalendarLinksDaoManager(this);
}

class CalendarLinksDaoManager {
  final _$CalendarLinksDaoMixin _db;
  CalendarLinksDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$CalendarAccountsTableTableManager get calendarAccounts =>
      $$CalendarAccountsTableTableManager(
        _db.attachedDatabase,
        _db.calendarAccounts,
      );
  $$CalendarLinksTableTableManager get calendarLinks =>
      $$CalendarLinksTableTableManager(_db.attachedDatabase, _db.calendarLinks);
  $$SeriesTableTableTableManager get seriesTable =>
      $$SeriesTableTableTableManager(_db.attachedDatabase, _db.seriesTable);
  $$OccurrencesTableTableManager get occurrences =>
      $$OccurrencesTableTableManager(_db.attachedDatabase, _db.occurrences);
}
