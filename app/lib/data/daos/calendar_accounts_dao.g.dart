// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_accounts_dao.dart';

// ignore_for_file: type=lint
mixin _$CalendarAccountsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $CalendarAccountsTable get calendarAccounts =>
      attachedDatabase.calendarAccounts;
  CalendarAccountsDaoManager get managers => CalendarAccountsDaoManager(this);
}

class CalendarAccountsDaoManager {
  final _$CalendarAccountsDaoMixin _db;
  CalendarAccountsDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$CalendarAccountsTableTableManager get calendarAccounts =>
      $$CalendarAccountsTableTableManager(
        _db.attachedDatabase,
        _db.calendarAccounts,
      );
}
