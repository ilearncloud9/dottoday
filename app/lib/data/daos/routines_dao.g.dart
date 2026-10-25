// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routines_dao.dart';

// ignore_for_file: type=lint
mixin _$RoutinesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $RoutinesTableTable get routinesTable => attachedDatabase.routinesTable;
  RoutinesDaoManager get managers => RoutinesDaoManager(this);
}

class RoutinesDaoManager {
  final _$RoutinesDaoMixin _db;
  RoutinesDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$RoutinesTableTableTableManager get routinesTable =>
      $$RoutinesTableTableTableManager(_db.attachedDatabase, _db.routinesTable);
}
