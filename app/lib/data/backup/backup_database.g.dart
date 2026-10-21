// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_database.dart';

// ignore_for_file: type=lint
class $BackupsTable extends Backups with TableInfo<$BackupsTable, BackupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appSchemaVersionMeta = const VerificationMeta(
    'appSchemaVersion',
  );
  @override
  late final GeneratedColumn<int> appSchemaVersion = GeneratedColumn<int>(
    'app_schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    reason,
    appSchemaVersion,
    json,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backups';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('app_schema_version')) {
      context.handle(
        _appSchemaVersionMeta,
        appSchemaVersion.isAcceptableOrUnknown(
          data['app_schema_version']!,
          _appSchemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appSchemaVersionMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      appSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}app_schema_version'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $BackupsTable createAlias(String alias) {
    return $BackupsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class BackupRow extends DataClass implements Insertable<BackupRow> {
  final int id;
  final int createdAt;
  final String reason;

  /// `AppDatabase.latestSchemaVersion` when taken, for diagnostics.
  final int appSchemaVersion;
  final String json;
  const BackupRow({
    required this.id,
    required this.createdAt,
    required this.reason,
    required this.appSchemaVersion,
    required this.json,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['reason'] = Variable<String>(reason);
    map['app_schema_version'] = Variable<int>(appSchemaVersion);
    map['json'] = Variable<String>(json);
    return map;
  }

  BackupsCompanion toCompanion(bool nullToAbsent) {
    return BackupsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      reason: Value(reason),
      appSchemaVersion: Value(appSchemaVersion),
      json: Value(json),
    );
  }

  factory BackupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      reason: serializer.fromJson<String>(json['reason']),
      appSchemaVersion: serializer.fromJson<int>(json['appSchemaVersion']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'reason': serializer.toJson<String>(reason),
      'appSchemaVersion': serializer.toJson<int>(appSchemaVersion),
      'json': serializer.toJson<String>(json),
    };
  }

  BackupRow copyWith({
    int? id,
    int? createdAt,
    String? reason,
    int? appSchemaVersion,
    String? json,
  }) => BackupRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    reason: reason ?? this.reason,
    appSchemaVersion: appSchemaVersion ?? this.appSchemaVersion,
    json: json ?? this.json,
  );
  BackupRow copyWithCompanion(BackupsCompanion data) {
    return BackupRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      reason: data.reason.present ? data.reason.value : this.reason,
      appSchemaVersion: data.appSchemaVersion.present
          ? data.appSchemaVersion.value
          : this.appSchemaVersion,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('reason: $reason, ')
          ..write('appSchemaVersion: $appSchemaVersion, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, reason, appSchemaVersion, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.reason == this.reason &&
          other.appSchemaVersion == this.appSchemaVersion &&
          other.json == this.json);
}

class BackupsCompanion extends UpdateCompanion<BackupRow> {
  final Value<int> id;
  final Value<int> createdAt;
  final Value<String> reason;
  final Value<int> appSchemaVersion;
  final Value<String> json;
  const BackupsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.reason = const Value.absent(),
    this.appSchemaVersion = const Value.absent(),
    this.json = const Value.absent(),
  });
  BackupsCompanion.insert({
    this.id = const Value.absent(),
    required int createdAt,
    required String reason,
    required int appSchemaVersion,
    required String json,
  }) : createdAt = Value(createdAt),
       reason = Value(reason),
       appSchemaVersion = Value(appSchemaVersion),
       json = Value(json);
  static Insertable<BackupRow> custom({
    Expression<int>? id,
    Expression<int>? createdAt,
    Expression<String>? reason,
    Expression<int>? appSchemaVersion,
    Expression<String>? json,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (reason != null) 'reason': reason,
      if (appSchemaVersion != null) 'app_schema_version': appSchemaVersion,
      if (json != null) 'json': json,
    });
  }

  BackupsCompanion copyWith({
    Value<int>? id,
    Value<int>? createdAt,
    Value<String>? reason,
    Value<int>? appSchemaVersion,
    Value<String>? json,
  }) {
    return BackupsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      reason: reason ?? this.reason,
      appSchemaVersion: appSchemaVersion ?? this.appSchemaVersion,
      json: json ?? this.json,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (appSchemaVersion.present) {
      map['app_schema_version'] = Variable<int>(appSchemaVersion.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('reason: $reason, ')
          ..write('appSchemaVersion: $appSchemaVersion, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }
}

abstract class _$BackupDatabase extends GeneratedDatabase {
  _$BackupDatabase(QueryExecutor e) : super(e);
  $BackupDatabaseManager get managers => $BackupDatabaseManager(this);
  late final $BackupsTable backups = $BackupsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [backups];
}

typedef $$BackupsTableCreateCompanionBuilder =
    BackupsCompanion Function({
      Value<int> id,
      required int createdAt,
      required String reason,
      required int appSchemaVersion,
      required String json,
    });
typedef $$BackupsTableUpdateCompanionBuilder =
    BackupsCompanion Function({
      Value<int> id,
      Value<int> createdAt,
      Value<String> reason,
      Value<int> appSchemaVersion,
      Value<String> json,
    });

class $$BackupsTableFilterComposer
    extends Composer<_$BackupDatabase, $BackupsTable> {
  $$BackupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get appSchemaVersion => $composableBuilder(
    column: $table.appSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupsTableOrderingComposer
    extends Composer<_$BackupDatabase, $BackupsTable> {
  $$BackupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get appSchemaVersion => $composableBuilder(
    column: $table.appSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupsTableAnnotationComposer
    extends Composer<_$BackupDatabase, $BackupsTable> {
  $$BackupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get appSchemaVersion => $composableBuilder(
    column: $table.appSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$BackupsTableTableManager
    extends
        RootTableManager<
          _$BackupDatabase,
          $BackupsTable,
          BackupRow,
          $$BackupsTableFilterComposer,
          $$BackupsTableOrderingComposer,
          $$BackupsTableAnnotationComposer,
          $$BackupsTableCreateCompanionBuilder,
          $$BackupsTableUpdateCompanionBuilder,
          (
            BackupRow,
            BaseReferences<_$BackupDatabase, $BackupsTable, BackupRow>,
          ),
          BackupRow,
          PrefetchHooks Function()
        > {
  $$BackupsTableTableManager(_$BackupDatabase db, $BackupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> appSchemaVersion = const Value.absent(),
                Value<String> json = const Value.absent(),
              }) => BackupsCompanion(
                id: id,
                createdAt: createdAt,
                reason: reason,
                appSchemaVersion: appSchemaVersion,
                json: json,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdAt,
                required String reason,
                required int appSchemaVersion,
                required String json,
              }) => BackupsCompanion.insert(
                id: id,
                createdAt: createdAt,
                reason: reason,
                appSchemaVersion: appSchemaVersion,
                json: json,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BackupsTable, BackupRow>(table),
                  BaseReferences<_$BackupDatabase, $BackupsTable, BackupRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupsTableProcessedTableManager =
    ProcessedTableManager<
      _$BackupDatabase,
      $BackupsTable,
      BackupRow,
      $$BackupsTableFilterComposer,
      $$BackupsTableOrderingComposer,
      $$BackupsTableAnnotationComposer,
      $$BackupsTableCreateCompanionBuilder,
      $$BackupsTableUpdateCompanionBuilder,
      (BackupRow, BaseReferences<_$BackupDatabase, $BackupsTable, BackupRow>),
      BackupRow,
      PrefetchHooks Function()
    >;

class $BackupDatabaseManager {
  final _$BackupDatabase _db;
  $BackupDatabaseManager(this._db);
  $$BackupsTableTableManager get backups =>
      $$BackupsTableTableManager(_db, _db.backups);
}
