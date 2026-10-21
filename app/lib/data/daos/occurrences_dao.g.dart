// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'occurrences_dao.dart';

// ignore_for_file: type=lint
mixin _$OccurrencesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $SeriesTableTable get seriesTable => attachedDatabase.seriesTable;
  $CalendarAccountsTable get calendarAccounts =>
      attachedDatabase.calendarAccounts;
  $CalendarLinksTable get calendarLinks => attachedDatabase.calendarLinks;
  $OccurrencesTable get occurrences => attachedDatabase.occurrences;
  OccurrencesDaoManager get managers => OccurrencesDaoManager(this);
}

class OccurrencesDaoManager {
  final _$OccurrencesDaoMixin _db;
  OccurrencesDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$SeriesTableTableTableManager get seriesTable =>
      $$SeriesTableTableTableManager(_db.attachedDatabase, _db.seriesTable);
  $$CalendarAccountsTableTableManager get calendarAccounts =>
      $$CalendarAccountsTableTableManager(
        _db.attachedDatabase,
        _db.calendarAccounts,
      );
  $$CalendarLinksTableTableManager get calendarLinks =>
      $$CalendarLinksTableTableManager(_db.attachedDatabase, _db.calendarLinks);
  $$OccurrencesTableTableManager get occurrences =>
      $$OccurrencesTableTableManager(_db.attachedDatabase, _db.occurrences);
}
