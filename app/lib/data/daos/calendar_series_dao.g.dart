// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_series_dao.dart';

// ignore_for_file: type=lint
mixin _$CalendarSeriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $CalendarAccountsTable get calendarAccounts =>
      attachedDatabase.calendarAccounts;
  $CalendarSeriesTableTable get calendarSeriesTable =>
      attachedDatabase.calendarSeriesTable;
  CalendarSeriesDaoManager get managers => CalendarSeriesDaoManager(this);
}

class CalendarSeriesDaoManager {
  final _$CalendarSeriesDaoMixin _db;
  CalendarSeriesDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$CalendarAccountsTableTableManager get calendarAccounts =>
      $$CalendarAccountsTableTableManager(
        _db.attachedDatabase,
        _db.calendarAccounts,
      );
  $$CalendarSeriesTableTableTableManager get calendarSeriesTable =>
      $$CalendarSeriesTableTableTableManager(
        _db.attachedDatabase,
        _db.calendarSeriesTable,
      );
}
