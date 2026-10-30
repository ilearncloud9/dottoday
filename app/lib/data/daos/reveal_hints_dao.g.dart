// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reveal_hints_dao.dart';

// ignore_for_file: type=lint
mixin _$RevealHintsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $RevealHintsTableTable get revealHintsTable =>
      attachedDatabase.revealHintsTable;
  RevealHintsDaoManager get managers => RevealHintsDaoManager(this);
}

class RevealHintsDaoManager {
  final _$RevealHintsDaoMixin _db;
  RevealHintsDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$RevealHintsTableTableTableManager get revealHintsTable =>
      $$RevealHintsTableTableTableManager(
        _db.attachedDatabase,
        _db.revealHintsTable,
      );
}
