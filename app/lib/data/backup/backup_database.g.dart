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
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    reason,
    appSchemaVersion,
    json,
    owner,
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
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
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
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      ),
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

  /// The profile id the backup was taken for (CR-160 I2). Listing,
  /// restoring, the daily check and retention only ever see one owner's
  /// backups. Null only for a schema-1 backup whose owner could not be
  /// proven: such a backup belongs to nobody and is never listed or
  /// restored.
  final String? owner;
  const BackupRow({
    required this.id,
    required this.createdAt,
    required this.reason,
    required this.appSchemaVersion,
    required this.json,
    this.owner,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['reason'] = Variable<String>(reason);
    map['app_schema_version'] = Variable<int>(appSchemaVersion);
    map['json'] = Variable<String>(json);
    if (!nullToAbsent || owner != null) {
      map['owner'] = Variable<String>(owner);
    }
    return map;
  }

  BackupsCompanion toCompanion(bool nullToAbsent) {
    return BackupsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      reason: Value(reason),
      appSchemaVersion: Value(appSchemaVersion),
      json: Value(json),
      owner: owner == null && nullToAbsent
          ? const Value.absent()
          : Value(owner),
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
      owner: serializer.fromJson<String?>(json['owner']),
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
      'owner': serializer.toJson<String?>(owner),
    };
  }

  BackupRow copyWith({
    int? id,
    int? createdAt,
    String? reason,
    int? appSchemaVersion,
    String? json,
    Value<String?> owner = const Value.absent(),
  }) => BackupRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    reason: reason ?? this.reason,
    appSchemaVersion: appSchemaVersion ?? this.appSchemaVersion,
    json: json ?? this.json,
    owner: owner.present ? owner.value : this.owner,
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
      owner: data.owner.present ? data.owner.value : this.owner,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('reason: $reason, ')
          ..write('appSchemaVersion: $appSchemaVersion, ')
          ..write('json: $json, ')
          ..write('owner: $owner')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, reason, appSchemaVersion, json, owner);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.reason == this.reason &&
          other.appSchemaVersion == this.appSchemaVersion &&
          other.json == this.json &&
          other.owner == this.owner);
}

class BackupsCompanion extends UpdateCompanion<BackupRow> {
  final Value<int> id;
  final Value<int> createdAt;
  final Value<String> reason;
  final Value<int> appSchemaVersion;
  final Value<String> json;
  final Value<String?> owner;
  const BackupsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.reason = const Value.absent(),
    this.appSchemaVersion = const Value.absent(),
    this.json = const Value.absent(),
    this.owner = const Value.absent(),
  });
  BackupsCompanion.insert({
    this.id = const Value.absent(),
    required int createdAt,
    required String reason,
    required int appSchemaVersion,
    required String json,
    this.owner = const Value.absent(),
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
    Expression<String>? owner,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (reason != null) 'reason': reason,
      if (appSchemaVersion != null) 'app_schema_version': appSchemaVersion,
      if (json != null) 'json': json,
      if (owner != null) 'owner': owner,
    });
  }

  BackupsCompanion copyWith({
    Value<int>? id,
    Value<int>? createdAt,
    Value<String>? reason,
    Value<int>? appSchemaVersion,
    Value<String>? json,
    Value<String?>? owner,
  }) {
    return BackupsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      reason: reason ?? this.reason,
      appSchemaVersion: appSchemaVersion ?? this.appSchemaVersion,
      json: json ?? this.json,
      owner: owner ?? this.owner,
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
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
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
          ..write('json: $json, ')
          ..write('owner: $owner')
          ..write(')'))
        .toString();
  }
}

class $BackupPartsTable extends BackupParts
    with TableInfo<$BackupPartsTable, BackupPartRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupPartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _backupIdMeta = const VerificationMeta(
    'backupId',
  );
  @override
  late final GeneratedColumn<int> backupId = GeneratedColumn<int>(
    'backup_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partIndexMeta = const VerificationMeta(
    'partIndex',
  );
  @override
  late final GeneratedColumn<int> partIndex = GeneratedColumn<int>(
    'part_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
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
    backupId,
    partIndex,
    sha256,
    bytes,
    json,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_parts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupPartRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('backup_id')) {
      context.handle(
        _backupIdMeta,
        backupId.isAcceptableOrUnknown(data['backup_id']!, _backupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_backupIdMeta);
    }
    if (data.containsKey('part_index')) {
      context.handle(
        _partIndexMeta,
        partIndex.isAcceptableOrUnknown(data['part_index']!, _partIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_partIndexMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
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
  Set<GeneratedColumn> get $primaryKey => {backupId, partIndex};
  @override
  BackupPartRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupPartRow(
      backupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backup_id'],
      )!,
      partIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}part_index'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $BackupPartsTable createAlias(String alias) {
    return $BackupPartsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class BackupPartRow extends DataClass implements Insertable<BackupPartRow> {
  final int backupId;

  /// 1-based, as the manifest numbers them.
  final int partIndex;
  final String sha256;
  final int bytes;
  final String json;
  const BackupPartRow({
    required this.backupId,
    required this.partIndex,
    required this.sha256,
    required this.bytes,
    required this.json,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['backup_id'] = Variable<int>(backupId);
    map['part_index'] = Variable<int>(partIndex);
    map['sha256'] = Variable<String>(sha256);
    map['bytes'] = Variable<int>(bytes);
    map['json'] = Variable<String>(json);
    return map;
  }

  BackupPartsCompanion toCompanion(bool nullToAbsent) {
    return BackupPartsCompanion(
      backupId: Value(backupId),
      partIndex: Value(partIndex),
      sha256: Value(sha256),
      bytes: Value(bytes),
      json: Value(json),
    );
  }

  factory BackupPartRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupPartRow(
      backupId: serializer.fromJson<int>(json['backupId']),
      partIndex: serializer.fromJson<int>(json['partIndex']),
      sha256: serializer.fromJson<String>(json['sha256']),
      bytes: serializer.fromJson<int>(json['bytes']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'backupId': serializer.toJson<int>(backupId),
      'partIndex': serializer.toJson<int>(partIndex),
      'sha256': serializer.toJson<String>(sha256),
      'bytes': serializer.toJson<int>(bytes),
      'json': serializer.toJson<String>(json),
    };
  }

  BackupPartRow copyWith({
    int? backupId,
    int? partIndex,
    String? sha256,
    int? bytes,
    String? json,
  }) => BackupPartRow(
    backupId: backupId ?? this.backupId,
    partIndex: partIndex ?? this.partIndex,
    sha256: sha256 ?? this.sha256,
    bytes: bytes ?? this.bytes,
    json: json ?? this.json,
  );
  BackupPartRow copyWithCompanion(BackupPartsCompanion data) {
    return BackupPartRow(
      backupId: data.backupId.present ? data.backupId.value : this.backupId,
      partIndex: data.partIndex.present ? data.partIndex.value : this.partIndex,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupPartRow(')
          ..write('backupId: $backupId, ')
          ..write('partIndex: $partIndex, ')
          ..write('sha256: $sha256, ')
          ..write('bytes: $bytes, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(backupId, partIndex, sha256, bytes, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupPartRow &&
          other.backupId == this.backupId &&
          other.partIndex == this.partIndex &&
          other.sha256 == this.sha256 &&
          other.bytes == this.bytes &&
          other.json == this.json);
}

class BackupPartsCompanion extends UpdateCompanion<BackupPartRow> {
  final Value<int> backupId;
  final Value<int> partIndex;
  final Value<String> sha256;
  final Value<int> bytes;
  final Value<String> json;
  final Value<int> rowid;
  const BackupPartsCompanion({
    this.backupId = const Value.absent(),
    this.partIndex = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.bytes = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupPartsCompanion.insert({
    required int backupId,
    required int partIndex,
    required String sha256,
    required int bytes,
    required String json,
    this.rowid = const Value.absent(),
  }) : backupId = Value(backupId),
       partIndex = Value(partIndex),
       sha256 = Value(sha256),
       bytes = Value(bytes),
       json = Value(json);
  static Insertable<BackupPartRow> custom({
    Expression<int>? backupId,
    Expression<int>? partIndex,
    Expression<String>? sha256,
    Expression<int>? bytes,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (backupId != null) 'backup_id': backupId,
      if (partIndex != null) 'part_index': partIndex,
      if (sha256 != null) 'sha256': sha256,
      if (bytes != null) 'bytes': bytes,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupPartsCompanion copyWith({
    Value<int>? backupId,
    Value<int>? partIndex,
    Value<String>? sha256,
    Value<int>? bytes,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return BackupPartsCompanion(
      backupId: backupId ?? this.backupId,
      partIndex: partIndex ?? this.partIndex,
      sha256: sha256 ?? this.sha256,
      bytes: bytes ?? this.bytes,
      json: json ?? this.json,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (backupId.present) {
      map['backup_id'] = Variable<int>(backupId.value);
    }
    if (partIndex.present) {
      map['part_index'] = Variable<int>(partIndex.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupPartsCompanion(')
          ..write('backupId: $backupId, ')
          ..write('partIndex: $partIndex, ')
          ..write('sha256: $sha256, ')
          ..write('bytes: $bytes, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BackupDatabase extends GeneratedDatabase {
  _$BackupDatabase(QueryExecutor e) : super(e);
  $BackupDatabaseManager get managers => $BackupDatabaseManager(this);
  late final $BackupsTable backups = $BackupsTable(this);
  late final $BackupPartsTable backupParts = $BackupPartsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [backups, backupParts];
}

typedef $$BackupsTableCreateCompanionBuilder =
    BackupsCompanion Function({
      Value<int> id,
      required int createdAt,
      required String reason,
      required int appSchemaVersion,
      required String json,
      Value<String?> owner,
    });
typedef $$BackupsTableUpdateCompanionBuilder =
    BackupsCompanion Function({
      Value<int> id,
      Value<int> createdAt,
      Value<String> reason,
      Value<int> appSchemaVersion,
      Value<String> json,
      Value<String?> owner,
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

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
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

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
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

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);
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
                Value<String?> owner = const Value.absent(),
              }) => BackupsCompanion(
                id: id,
                createdAt: createdAt,
                reason: reason,
                appSchemaVersion: appSchemaVersion,
                json: json,
                owner: owner,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdAt,
                required String reason,
                required int appSchemaVersion,
                required String json,
                Value<String?> owner = const Value.absent(),
              }) => BackupsCompanion.insert(
                id: id,
                createdAt: createdAt,
                reason: reason,
                appSchemaVersion: appSchemaVersion,
                json: json,
                owner: owner,
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
typedef $$BackupPartsTableCreateCompanionBuilder =
    BackupPartsCompanion Function({
      required int backupId,
      required int partIndex,
      required String sha256,
      required int bytes,
      required String json,
      Value<int> rowid,
    });
typedef $$BackupPartsTableUpdateCompanionBuilder =
    BackupPartsCompanion Function({
      Value<int> backupId,
      Value<int> partIndex,
      Value<String> sha256,
      Value<int> bytes,
      Value<String> json,
      Value<int> rowid,
    });

class $$BackupPartsTableFilterComposer
    extends Composer<_$BackupDatabase, $BackupPartsTable> {
  $$BackupPartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get backupId => $composableBuilder(
    column: $table.backupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partIndex => $composableBuilder(
    column: $table.partIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupPartsTableOrderingComposer
    extends Composer<_$BackupDatabase, $BackupPartsTable> {
  $$BackupPartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get backupId => $composableBuilder(
    column: $table.backupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partIndex => $composableBuilder(
    column: $table.partIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupPartsTableAnnotationComposer
    extends Composer<_$BackupDatabase, $BackupPartsTable> {
  $$BackupPartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get backupId =>
      $composableBuilder(column: $table.backupId, builder: (column) => column);

  GeneratedColumn<int> get partIndex =>
      $composableBuilder(column: $table.partIndex, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$BackupPartsTableTableManager
    extends
        RootTableManager<
          _$BackupDatabase,
          $BackupPartsTable,
          BackupPartRow,
          $$BackupPartsTableFilterComposer,
          $$BackupPartsTableOrderingComposer,
          $$BackupPartsTableAnnotationComposer,
          $$BackupPartsTableCreateCompanionBuilder,
          $$BackupPartsTableUpdateCompanionBuilder,
          (
            BackupPartRow,
            BaseReferences<_$BackupDatabase, $BackupPartsTable, BackupPartRow>,
          ),
          BackupPartRow,
          PrefetchHooks Function()
        > {
  $$BackupPartsTableTableManager(_$BackupDatabase db, $BackupPartsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupPartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupPartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupPartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> backupId = const Value.absent(),
                Value<int> partIndex = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int> bytes = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupPartsCompanion(
                backupId: backupId,
                partIndex: partIndex,
                sha256: sha256,
                bytes: bytes,
                json: json,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int backupId,
                required int partIndex,
                required String sha256,
                required int bytes,
                required String json,
                Value<int> rowid = const Value.absent(),
              }) => BackupPartsCompanion.insert(
                backupId: backupId,
                partIndex: partIndex,
                sha256: sha256,
                bytes: bytes,
                json: json,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BackupPartsTable, BackupPartRow>(table),
                  BaseReferences<
                    _$BackupDatabase,
                    $BackupPartsTable,
                    BackupPartRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupPartsTableProcessedTableManager =
    ProcessedTableManager<
      _$BackupDatabase,
      $BackupPartsTable,
      BackupPartRow,
      $$BackupPartsTableFilterComposer,
      $$BackupPartsTableOrderingComposer,
      $$BackupPartsTableAnnotationComposer,
      $$BackupPartsTableCreateCompanionBuilder,
      $$BackupPartsTableUpdateCompanionBuilder,
      (
        BackupPartRow,
        BaseReferences<_$BackupDatabase, $BackupPartsTable, BackupPartRow>,
      ),
      BackupPartRow,
      PrefetchHooks Function()
    >;

class $BackupDatabaseManager {
  final _$BackupDatabase _db;
  $BackupDatabaseManager(this._db);
  $$BackupsTableTableManager get backups =>
      $$BackupsTableTableManager(_db, _db.backups);
  $$BackupPartsTableTableManager get backupParts =>
      $$BackupPartsTableTableManager(_db, _db.backupParts);
}
