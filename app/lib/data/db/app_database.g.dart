// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class SearchIndex extends Table
    with
        TableInfo<SearchIndex, SearchIndexData>,
        VirtualTableInfo<SearchIndex, SearchIndexData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SearchIndex(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _subtasksMeta = const VerificationMeta(
    'subtasks',
  );
  late final GeneratedColumn<String> subtasks = GeneratedColumn<String>(
    'subtasks',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [userId, title, notes, subtasks];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchIndexData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('subtasks')) {
      context.handle(
        _subtasksMeta,
        subtasks.isAcceptableOrUnknown(data['subtasks']!, _subtasksMeta),
      );
    } else if (isInserting) {
      context.missing(_subtasksMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  SearchIndexData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchIndexData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      subtasks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtasks'],
      )!,
    );
  }

  @override
  SearchIndex createAlias(String alias) {
    return SearchIndex(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(user_id UNINDEXED, title, notes, subtasks, tokenize = \'unicode61 remove_diacritics 2\')';
}

class SearchIndexData extends DataClass implements Insertable<SearchIndexData> {
  final String userId;
  final String title;
  final String notes;
  final String subtasks;
  const SearchIndexData({
    required this.userId,
    required this.title,
    required this.notes,
    required this.subtasks,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['notes'] = Variable<String>(notes);
    map['subtasks'] = Variable<String>(subtasks);
    return map;
  }

  SearchIndexCompanion toCompanion(bool nullToAbsent) {
    return SearchIndexCompanion(
      userId: Value(userId),
      title: Value(title),
      notes: Value(notes),
      subtasks: Value(subtasks),
    );
  }

  factory SearchIndexData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchIndexData(
      userId: serializer.fromJson<String>(json['user_id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
      subtasks: serializer.fromJson<String>(json['subtasks']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'user_id': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String>(notes),
      'subtasks': serializer.toJson<String>(subtasks),
    };
  }

  SearchIndexData copyWith({
    String? userId,
    String? title,
    String? notes,
    String? subtasks,
  }) => SearchIndexData(
    userId: userId ?? this.userId,
    title: title ?? this.title,
    notes: notes ?? this.notes,
    subtasks: subtasks ?? this.subtasks,
  );
  SearchIndexData copyWithCompanion(SearchIndexCompanion data) {
    return SearchIndexData(
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      subtasks: data.subtasks.present ? data.subtasks.value : this.subtasks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchIndexData(')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('subtasks: $subtasks')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, title, notes, subtasks);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchIndexData &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.subtasks == this.subtasks);
}

class SearchIndexCompanion extends UpdateCompanion<SearchIndexData> {
  final Value<String> userId;
  final Value<String> title;
  final Value<String> notes;
  final Value<String> subtasks;
  final Value<int> rowid;
  const SearchIndexCompanion({
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.subtasks = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchIndexCompanion.insert({
    required String userId,
    required String title,
    required String notes,
    required String subtasks,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       title = Value(title),
       notes = Value(notes),
       subtasks = Value(subtasks);
  static Insertable<SearchIndexData> custom({
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? subtasks,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (subtasks != null) 'subtasks': subtasks,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchIndexCompanion copyWith({
    Value<String>? userId,
    Value<String>? title,
    Value<String>? notes,
    Value<String>? subtasks,
    Value<int>? rowid,
  }) {
    return SearchIndexCompanion(
      userId: userId ?? this.userId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      subtasks: subtasks ?? this.subtasks,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (subtasks.present) {
      map['subtasks'] = Variable<String>(subtasks.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchIndexCompanion(')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('subtasks: $subtasks, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tzIdMeta = const VerificationMeta('tzId');
  @override
  late final GeneratedColumn<String> tzId = GeneratedColumn<String>(
    'tz_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UTC'),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _settingsMeta = const VerificationMeta(
    'settings',
  );
  @override
  late final GeneratedColumn<String> settings = GeneratedColumn<String>(
    'settings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{"dayBoundaries":{}}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    dirty,
    version,
    id,
    displayName,
    tzId,
    locale,
    settings,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('tz_id')) {
      context.handle(
        _tzIdMeta,
        tzId.isAcceptableOrUnknown(data['tz_id']!, _tzIdMeta),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('settings')) {
      context.handle(
        _settingsMeta,
        settings.isAcceptableOrUnknown(data['settings']!, _settingsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      tzId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tz_id'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      settings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final int createdAt;
  final int updatedAt;
  final bool dirty;
  final int version;
  final String id;
  final String? displayName;
  final String tzId;
  final String locale;

  /// `Settings` JSON (docs/05 "Settings JSON"); validated in the repository.
  final String settings;
  const ProfileRow({
    required this.createdAt,
    required this.updatedAt,
    required this.dirty,
    required this.version,
    required this.id,
    this.displayName,
    required this.tzId,
    required this.locale,
    required this.settings,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    map['version'] = Variable<int>(version);
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['tz_id'] = Variable<String>(tzId);
    map['locale'] = Variable<String>(locale);
    map['settings'] = Variable<String>(settings);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      version: Value(version),
      id: Value(id),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      tzId: Value(tzId),
      locale: Value(locale),
      settings: Value(settings),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      version: serializer.fromJson<int>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      tzId: serializer.fromJson<String>(json['tzId']),
      locale: serializer.fromJson<String>(json['locale']),
      settings: serializer.fromJson<String>(json['settings']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'version': serializer.toJson<int>(version),
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String?>(displayName),
      'tzId': serializer.toJson<String>(tzId),
      'locale': serializer.toJson<String>(locale),
      'settings': serializer.toJson<String>(settings),
    };
  }

  ProfileRow copyWith({
    int? createdAt,
    int? updatedAt,
    bool? dirty,
    int? version,
    String? id,
    Value<String?> displayName = const Value.absent(),
    String? tzId,
    String? locale,
    String? settings,
  }) => ProfileRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dirty: dirty ?? this.dirty,
    version: version ?? this.version,
    id: id ?? this.id,
    displayName: displayName.present ? displayName.value : this.displayName,
    tzId: tzId ?? this.tzId,
    locale: locale ?? this.locale,
    settings: settings ?? this.settings,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      tzId: data.tzId.present ? data.tzId.value : this.tzId,
      locale: data.locale.present ? data.locale.value : this.locale,
      settings: data.settings.present ? data.settings.value : this.settings,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('tzId: $tzId, ')
          ..write('locale: $locale, ')
          ..write('settings: $settings')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    dirty,
    version,
    id,
    displayName,
    tzId,
    locale,
    settings,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.version == this.version &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.tzId == this.tzId &&
          other.locale == this.locale &&
          other.settings == this.settings);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> dirty;
  final Value<int> version;
  final Value<String> id;
  final Value<String?> displayName;
  final Value<String> tzId;
  final Value<String> locale;
  final Value<String> settings;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.tzId = const Value.absent(),
    this.locale = const Value.absent(),
    this.settings = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required int createdAt,
    required int updatedAt,
    this.dirty = const Value.absent(),
    this.version = const Value.absent(),
    required String id,
    this.displayName = const Value.absent(),
    this.tzId = const Value.absent(),
    this.locale = const Value.absent(),
    this.settings = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id);
  static Insertable<ProfileRow> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? dirty,
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? tzId,
    Expression<String>? locale,
    Expression<String>? settings,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (tzId != null) 'tz_id': tzId,
      if (locale != null) 'locale': locale,
      if (settings != null) 'settings': settings,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? dirty,
    Value<int>? version,
    Value<String>? id,
    Value<String?>? displayName,
    Value<String>? tzId,
    Value<String>? locale,
    Value<String>? settings,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      version: version ?? this.version,
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      tzId: tzId ?? this.tzId,
      locale: locale ?? this.locale,
      settings: settings ?? this.settings,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (tzId.present) {
      map['tz_id'] = Variable<String>(tzId.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (settings.present) {
      map['settings'] = Variable<String>(settings.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('tzId: $tzId, ')
          ..write('locale: $locale, ')
          ..write('settings: $settings, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesTableTable extends SeriesTable
    with TableInfo<$SeriesTableTable, SeriesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorKeyMeta = const VerificationMeta(
    'colorKey',
  );
  @override
  late final GeneratedColumn<String> colorKey = GeneratedColumn<String>(
    'color_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('indigo'),
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('circle'),
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rruleMeta = const VerificationMeta('rrule');
  @override
  late final GeneratedColumn<String> rrule = GeneratedColumn<String>(
    'rrule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dtstartLocalMeta = const VerificationMeta(
    'dtstartLocal',
  );
  @override
  late final GeneratedColumn<String> dtstartLocal = GeneratedColumn<String>(
    'dtstart_local',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tzIdMeta = const VerificationMeta('tzId');
  @override
  late final GeneratedColumn<String> tzId = GeneratedColumn<String>(
    'tz_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _untilUtcMeta = const VerificationMeta(
    'untilUtc',
  );
  @override
  late final GeneratedColumn<int> untilUtc = GeneratedColumn<int>(
    'until_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _travelBufferMinMeta = const VerificationMeta(
    'travelBufferMin',
  );
  @override
  late final GeneratedColumn<int> travelBufferMin = GeneratedColumn<int>(
    'travel_buffer_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationFromStepsMeta = const VerificationMeta(
    'durationFromSteps',
  );
  @override
  late final GeneratedColumn<bool> durationFromSteps = GeneratedColumn<bool>(
    'duration_from_steps',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("duration_from_steps" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
    'energy',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alertsMeta = const VerificationMeta('alerts');
  @override
  late final GeneratedColumn<String> alerts = GeneratedColumn<String>(
    'alerts',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _soundIdMeta = const VerificationMeta(
    'soundId',
  );
  @override
  late final GeneratedColumn<String> soundId = GeneratedColumn<String>(
    'sound_id',
    aliasedName,
    true,
    check: () => soundIdCheck,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtaskTemplateMeta = const VerificationMeta(
    'subtaskTemplate',
  );
  @override
  late final GeneratedColumn<String> subtaskTemplate = GeneratedColumn<String>(
    'subtask_template',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _materialisedThroughUtcMeta =
      const VerificationMeta('materialisedThroughUtc');
  @override
  late final GeneratedColumn<int> materialisedThroughUtc = GeneratedColumn<int>(
    'materialised_through_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<int> archivedAt = GeneratedColumn<int>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    dirty,
    version,
    id,
    userId,
    title,
    notes,
    colorKey,
    iconKey,
    durationMin,
    rrule,
    dtstartLocal,
    tzId,
    untilUtc,
    count,
    pinned,
    travelBufferMin,
    durationFromSteps,
    energy,
    alerts,
    soundId,
    subtaskTemplate,
    materialisedThroughUtc,
    archivedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('color_key')) {
      context.handle(
        _colorKeyMeta,
        colorKey.isAcceptableOrUnknown(data['color_key']!, _colorKeyMeta),
      );
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinMeta);
    }
    if (data.containsKey('rrule')) {
      context.handle(
        _rruleMeta,
        rrule.isAcceptableOrUnknown(data['rrule']!, _rruleMeta),
      );
    } else if (isInserting) {
      context.missing(_rruleMeta);
    }
    if (data.containsKey('dtstart_local')) {
      context.handle(
        _dtstartLocalMeta,
        dtstartLocal.isAcceptableOrUnknown(
          data['dtstart_local']!,
          _dtstartLocalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dtstartLocalMeta);
    }
    if (data.containsKey('tz_id')) {
      context.handle(
        _tzIdMeta,
        tzId.isAcceptableOrUnknown(data['tz_id']!, _tzIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tzIdMeta);
    }
    if (data.containsKey('until_utc')) {
      context.handle(
        _untilUtcMeta,
        untilUtc.isAcceptableOrUnknown(data['until_utc']!, _untilUtcMeta),
      );
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('travel_buffer_min')) {
      context.handle(
        _travelBufferMinMeta,
        travelBufferMin.isAcceptableOrUnknown(
          data['travel_buffer_min']!,
          _travelBufferMinMeta,
        ),
      );
    }
    if (data.containsKey('duration_from_steps')) {
      context.handle(
        _durationFromStepsMeta,
        durationFromSteps.isAcceptableOrUnknown(
          data['duration_from_steps']!,
          _durationFromStepsMeta,
        ),
      );
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    }
    if (data.containsKey('alerts')) {
      context.handle(
        _alertsMeta,
        alerts.isAcceptableOrUnknown(data['alerts']!, _alertsMeta),
      );
    }
    if (data.containsKey('sound_id')) {
      context.handle(
        _soundIdMeta,
        soundId.isAcceptableOrUnknown(data['sound_id']!, _soundIdMeta),
      );
    }
    if (data.containsKey('subtask_template')) {
      context.handle(
        _subtaskTemplateMeta,
        subtaskTemplate.isAcceptableOrUnknown(
          data['subtask_template']!,
          _subtaskTemplateMeta,
        ),
      );
    }
    if (data.containsKey('materialised_through_utc')) {
      context.handle(
        _materialisedThroughUtcMeta,
        materialisedThroughUtc.isAcceptableOrUnknown(
          data['materialised_through_utc']!,
          _materialisedThroughUtcMeta,
        ),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeriesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      colorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_key'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      )!,
      rrule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rrule'],
      )!,
      dtstartLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dtstart_local'],
      )!,
      tzId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tz_id'],
      )!,
      untilUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}until_utc'],
      ),
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      ),
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      travelBufferMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}travel_buffer_min'],
      )!,
      durationFromSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}duration_from_steps'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy'],
      ),
      alerts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alerts'],
      )!,
      soundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound_id'],
      ),
      subtaskTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtask_template'],
      )!,
      materialisedThroughUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}materialised_through_utc'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SeriesTableTable createAlias(String alias) {
    return $SeriesTableTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class SeriesRow extends DataClass implements Insertable<SeriesRow> {
  final int createdAt;
  final int updatedAt;
  final bool dirty;
  final int version;
  final String id;
  final String userId;
  final String title;
  final String? notes;
  final String colorKey;
  final String iconKey;
  final int durationMin;
  final String rrule;

  /// ISO-8601 wall clock without offset, read in [tzId] (R-01).
  final String dtstartLocal;
  final String tzId;
  final int? untilUtc;
  final int? count;
  final bool pinned;
  final int travelBufferMin;

  /// Schema 3 (M6.5.1, 11 B2).
  final bool durationFromSteps;
  final int? energy;
  final String alerts;

  /// The reminder sound (docs/12 §3); column-level CHECK so the v8
  /// migration's ADD COLUMN carries it (a table CHECK needs a rebuild).
  final String? soundId;
  final String subtaskTemplate;
  final int? materialisedThroughUtc;
  final int? archivedAt;
  final int? deletedAt;
  const SeriesRow({
    required this.createdAt,
    required this.updatedAt,
    required this.dirty,
    required this.version,
    required this.id,
    required this.userId,
    required this.title,
    this.notes,
    required this.colorKey,
    required this.iconKey,
    required this.durationMin,
    required this.rrule,
    required this.dtstartLocal,
    required this.tzId,
    this.untilUtc,
    this.count,
    required this.pinned,
    required this.travelBufferMin,
    required this.durationFromSteps,
    this.energy,
    required this.alerts,
    this.soundId,
    required this.subtaskTemplate,
    this.materialisedThroughUtc,
    this.archivedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    map['version'] = Variable<int>(version);
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['color_key'] = Variable<String>(colorKey);
    map['icon_key'] = Variable<String>(iconKey);
    map['duration_min'] = Variable<int>(durationMin);
    map['rrule'] = Variable<String>(rrule);
    map['dtstart_local'] = Variable<String>(dtstartLocal);
    map['tz_id'] = Variable<String>(tzId);
    if (!nullToAbsent || untilUtc != null) {
      map['until_utc'] = Variable<int>(untilUtc);
    }
    if (!nullToAbsent || count != null) {
      map['count'] = Variable<int>(count);
    }
    map['pinned'] = Variable<bool>(pinned);
    map['travel_buffer_min'] = Variable<int>(travelBufferMin);
    map['duration_from_steps'] = Variable<bool>(durationFromSteps);
    if (!nullToAbsent || energy != null) {
      map['energy'] = Variable<int>(energy);
    }
    map['alerts'] = Variable<String>(alerts);
    if (!nullToAbsent || soundId != null) {
      map['sound_id'] = Variable<String>(soundId);
    }
    map['subtask_template'] = Variable<String>(subtaskTemplate);
    if (!nullToAbsent || materialisedThroughUtc != null) {
      map['materialised_through_utc'] = Variable<int>(materialisedThroughUtc);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(archivedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  SeriesTableCompanion toCompanion(bool nullToAbsent) {
    return SeriesTableCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      version: Value(version),
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      colorKey: Value(colorKey),
      iconKey: Value(iconKey),
      durationMin: Value(durationMin),
      rrule: Value(rrule),
      dtstartLocal: Value(dtstartLocal),
      tzId: Value(tzId),
      untilUtc: untilUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(untilUtc),
      count: count == null && nullToAbsent
          ? const Value.absent()
          : Value(count),
      pinned: Value(pinned),
      travelBufferMin: Value(travelBufferMin),
      durationFromSteps: Value(durationFromSteps),
      energy: energy == null && nullToAbsent
          ? const Value.absent()
          : Value(energy),
      alerts: Value(alerts),
      soundId: soundId == null && nullToAbsent
          ? const Value.absent()
          : Value(soundId),
      subtaskTemplate: Value(subtaskTemplate),
      materialisedThroughUtc: materialisedThroughUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(materialisedThroughUtc),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SeriesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesRow(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      version: serializer.fromJson<int>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      colorKey: serializer.fromJson<String>(json['colorKey']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      durationMin: serializer.fromJson<int>(json['durationMin']),
      rrule: serializer.fromJson<String>(json['rrule']),
      dtstartLocal: serializer.fromJson<String>(json['dtstartLocal']),
      tzId: serializer.fromJson<String>(json['tzId']),
      untilUtc: serializer.fromJson<int?>(json['untilUtc']),
      count: serializer.fromJson<int?>(json['count']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      travelBufferMin: serializer.fromJson<int>(json['travelBufferMin']),
      durationFromSteps: serializer.fromJson<bool>(json['durationFromSteps']),
      energy: serializer.fromJson<int?>(json['energy']),
      alerts: serializer.fromJson<String>(json['alerts']),
      soundId: serializer.fromJson<String?>(json['soundId']),
      subtaskTemplate: serializer.fromJson<String>(json['subtaskTemplate']),
      materialisedThroughUtc: serializer.fromJson<int?>(
        json['materialisedThroughUtc'],
      ),
      archivedAt: serializer.fromJson<int?>(json['archivedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'version': serializer.toJson<int>(version),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'colorKey': serializer.toJson<String>(colorKey),
      'iconKey': serializer.toJson<String>(iconKey),
      'durationMin': serializer.toJson<int>(durationMin),
      'rrule': serializer.toJson<String>(rrule),
      'dtstartLocal': serializer.toJson<String>(dtstartLocal),
      'tzId': serializer.toJson<String>(tzId),
      'untilUtc': serializer.toJson<int?>(untilUtc),
      'count': serializer.toJson<int?>(count),
      'pinned': serializer.toJson<bool>(pinned),
      'travelBufferMin': serializer.toJson<int>(travelBufferMin),
      'durationFromSteps': serializer.toJson<bool>(durationFromSteps),
      'energy': serializer.toJson<int?>(energy),
      'alerts': serializer.toJson<String>(alerts),
      'soundId': serializer.toJson<String?>(soundId),
      'subtaskTemplate': serializer.toJson<String>(subtaskTemplate),
      'materialisedThroughUtc': serializer.toJson<int?>(materialisedThroughUtc),
      'archivedAt': serializer.toJson<int?>(archivedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  SeriesRow copyWith({
    int? createdAt,
    int? updatedAt,
    bool? dirty,
    int? version,
    String? id,
    String? userId,
    String? title,
    Value<String?> notes = const Value.absent(),
    String? colorKey,
    String? iconKey,
    int? durationMin,
    String? rrule,
    String? dtstartLocal,
    String? tzId,
    Value<int?> untilUtc = const Value.absent(),
    Value<int?> count = const Value.absent(),
    bool? pinned,
    int? travelBufferMin,
    bool? durationFromSteps,
    Value<int?> energy = const Value.absent(),
    String? alerts,
    Value<String?> soundId = const Value.absent(),
    String? subtaskTemplate,
    Value<int?> materialisedThroughUtc = const Value.absent(),
    Value<int?> archivedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
  }) => SeriesRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dirty: dirty ?? this.dirty,
    version: version ?? this.version,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    colorKey: colorKey ?? this.colorKey,
    iconKey: iconKey ?? this.iconKey,
    durationMin: durationMin ?? this.durationMin,
    rrule: rrule ?? this.rrule,
    dtstartLocal: dtstartLocal ?? this.dtstartLocal,
    tzId: tzId ?? this.tzId,
    untilUtc: untilUtc.present ? untilUtc.value : this.untilUtc,
    count: count.present ? count.value : this.count,
    pinned: pinned ?? this.pinned,
    travelBufferMin: travelBufferMin ?? this.travelBufferMin,
    durationFromSteps: durationFromSteps ?? this.durationFromSteps,
    energy: energy.present ? energy.value : this.energy,
    alerts: alerts ?? this.alerts,
    soundId: soundId.present ? soundId.value : this.soundId,
    subtaskTemplate: subtaskTemplate ?? this.subtaskTemplate,
    materialisedThroughUtc: materialisedThroughUtc.present
        ? materialisedThroughUtc.value
        : this.materialisedThroughUtc,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SeriesRow copyWithCompanion(SeriesTableCompanion data) {
    return SeriesRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      colorKey: data.colorKey.present ? data.colorKey.value : this.colorKey,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      rrule: data.rrule.present ? data.rrule.value : this.rrule,
      dtstartLocal: data.dtstartLocal.present
          ? data.dtstartLocal.value
          : this.dtstartLocal,
      tzId: data.tzId.present ? data.tzId.value : this.tzId,
      untilUtc: data.untilUtc.present ? data.untilUtc.value : this.untilUtc,
      count: data.count.present ? data.count.value : this.count,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      travelBufferMin: data.travelBufferMin.present
          ? data.travelBufferMin.value
          : this.travelBufferMin,
      durationFromSteps: data.durationFromSteps.present
          ? data.durationFromSteps.value
          : this.durationFromSteps,
      energy: data.energy.present ? data.energy.value : this.energy,
      alerts: data.alerts.present ? data.alerts.value : this.alerts,
      soundId: data.soundId.present ? data.soundId.value : this.soundId,
      subtaskTemplate: data.subtaskTemplate.present
          ? data.subtaskTemplate.value
          : this.subtaskTemplate,
      materialisedThroughUtc: data.materialisedThroughUtc.present
          ? data.materialisedThroughUtc.value
          : this.materialisedThroughUtc,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('colorKey: $colorKey, ')
          ..write('iconKey: $iconKey, ')
          ..write('durationMin: $durationMin, ')
          ..write('rrule: $rrule, ')
          ..write('dtstartLocal: $dtstartLocal, ')
          ..write('tzId: $tzId, ')
          ..write('untilUtc: $untilUtc, ')
          ..write('count: $count, ')
          ..write('pinned: $pinned, ')
          ..write('travelBufferMin: $travelBufferMin, ')
          ..write('durationFromSteps: $durationFromSteps, ')
          ..write('energy: $energy, ')
          ..write('alerts: $alerts, ')
          ..write('soundId: $soundId, ')
          ..write('subtaskTemplate: $subtaskTemplate, ')
          ..write('materialisedThroughUtc: $materialisedThroughUtc, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    updatedAt,
    dirty,
    version,
    id,
    userId,
    title,
    notes,
    colorKey,
    iconKey,
    durationMin,
    rrule,
    dtstartLocal,
    tzId,
    untilUtc,
    count,
    pinned,
    travelBufferMin,
    durationFromSteps,
    energy,
    alerts,
    soundId,
    subtaskTemplate,
    materialisedThroughUtc,
    archivedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.version == this.version &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.colorKey == this.colorKey &&
          other.iconKey == this.iconKey &&
          other.durationMin == this.durationMin &&
          other.rrule == this.rrule &&
          other.dtstartLocal == this.dtstartLocal &&
          other.tzId == this.tzId &&
          other.untilUtc == this.untilUtc &&
          other.count == this.count &&
          other.pinned == this.pinned &&
          other.travelBufferMin == this.travelBufferMin &&
          other.durationFromSteps == this.durationFromSteps &&
          other.energy == this.energy &&
          other.alerts == this.alerts &&
          other.soundId == this.soundId &&
          other.subtaskTemplate == this.subtaskTemplate &&
          other.materialisedThroughUtc == this.materialisedThroughUtc &&
          other.archivedAt == this.archivedAt &&
          other.deletedAt == this.deletedAt);
}

class SeriesTableCompanion extends UpdateCompanion<SeriesRow> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> dirty;
  final Value<int> version;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String?> notes;
  final Value<String> colorKey;
  final Value<String> iconKey;
  final Value<int> durationMin;
  final Value<String> rrule;
  final Value<String> dtstartLocal;
  final Value<String> tzId;
  final Value<int?> untilUtc;
  final Value<int?> count;
  final Value<bool> pinned;
  final Value<int> travelBufferMin;
  final Value<bool> durationFromSteps;
  final Value<int?> energy;
  final Value<String> alerts;
  final Value<String?> soundId;
  final Value<String> subtaskTemplate;
  final Value<int?> materialisedThroughUtc;
  final Value<int?> archivedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const SeriesTableCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.colorKey = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.rrule = const Value.absent(),
    this.dtstartLocal = const Value.absent(),
    this.tzId = const Value.absent(),
    this.untilUtc = const Value.absent(),
    this.count = const Value.absent(),
    this.pinned = const Value.absent(),
    this.travelBufferMin = const Value.absent(),
    this.durationFromSteps = const Value.absent(),
    this.energy = const Value.absent(),
    this.alerts = const Value.absent(),
    this.soundId = const Value.absent(),
    this.subtaskTemplate = const Value.absent(),
    this.materialisedThroughUtc = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesTableCompanion.insert({
    required int createdAt,
    required int updatedAt,
    this.dirty = const Value.absent(),
    this.version = const Value.absent(),
    required String id,
    required String userId,
    required String title,
    this.notes = const Value.absent(),
    this.colorKey = const Value.absent(),
    this.iconKey = const Value.absent(),
    required int durationMin,
    required String rrule,
    required String dtstartLocal,
    required String tzId,
    this.untilUtc = const Value.absent(),
    this.count = const Value.absent(),
    this.pinned = const Value.absent(),
    this.travelBufferMin = const Value.absent(),
    this.durationFromSteps = const Value.absent(),
    this.energy = const Value.absent(),
    this.alerts = const Value.absent(),
    this.soundId = const Value.absent(),
    this.subtaskTemplate = const Value.absent(),
    this.materialisedThroughUtc = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       userId = Value(userId),
       title = Value(title),
       durationMin = Value(durationMin),
       rrule = Value(rrule),
       dtstartLocal = Value(dtstartLocal),
       tzId = Value(tzId);
  static Insertable<SeriesRow> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? dirty,
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? colorKey,
    Expression<String>? iconKey,
    Expression<int>? durationMin,
    Expression<String>? rrule,
    Expression<String>? dtstartLocal,
    Expression<String>? tzId,
    Expression<int>? untilUtc,
    Expression<int>? count,
    Expression<bool>? pinned,
    Expression<int>? travelBufferMin,
    Expression<bool>? durationFromSteps,
    Expression<int>? energy,
    Expression<String>? alerts,
    Expression<String>? soundId,
    Expression<String>? subtaskTemplate,
    Expression<int>? materialisedThroughUtc,
    Expression<int>? archivedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (colorKey != null) 'color_key': colorKey,
      if (iconKey != null) 'icon_key': iconKey,
      if (durationMin != null) 'duration_min': durationMin,
      if (rrule != null) 'rrule': rrule,
      if (dtstartLocal != null) 'dtstart_local': dtstartLocal,
      if (tzId != null) 'tz_id': tzId,
      if (untilUtc != null) 'until_utc': untilUtc,
      if (count != null) 'count': count,
      if (pinned != null) 'pinned': pinned,
      if (travelBufferMin != null) 'travel_buffer_min': travelBufferMin,
      if (durationFromSteps != null) 'duration_from_steps': durationFromSteps,
      if (energy != null) 'energy': energy,
      if (alerts != null) 'alerts': alerts,
      if (soundId != null) 'sound_id': soundId,
      if (subtaskTemplate != null) 'subtask_template': subtaskTemplate,
      if (materialisedThroughUtc != null)
        'materialised_through_utc': materialisedThroughUtc,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesTableCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? dirty,
    Value<int>? version,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String?>? notes,
    Value<String>? colorKey,
    Value<String>? iconKey,
    Value<int>? durationMin,
    Value<String>? rrule,
    Value<String>? dtstartLocal,
    Value<String>? tzId,
    Value<int?>? untilUtc,
    Value<int?>? count,
    Value<bool>? pinned,
    Value<int>? travelBufferMin,
    Value<bool>? durationFromSteps,
    Value<int?>? energy,
    Value<String>? alerts,
    Value<String?>? soundId,
    Value<String>? subtaskTemplate,
    Value<int?>? materialisedThroughUtc,
    Value<int?>? archivedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SeriesTableCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      version: version ?? this.version,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      colorKey: colorKey ?? this.colorKey,
      iconKey: iconKey ?? this.iconKey,
      durationMin: durationMin ?? this.durationMin,
      rrule: rrule ?? this.rrule,
      dtstartLocal: dtstartLocal ?? this.dtstartLocal,
      tzId: tzId ?? this.tzId,
      untilUtc: untilUtc ?? this.untilUtc,
      count: count ?? this.count,
      pinned: pinned ?? this.pinned,
      travelBufferMin: travelBufferMin ?? this.travelBufferMin,
      durationFromSteps: durationFromSteps ?? this.durationFromSteps,
      energy: energy ?? this.energy,
      alerts: alerts ?? this.alerts,
      soundId: soundId ?? this.soundId,
      subtaskTemplate: subtaskTemplate ?? this.subtaskTemplate,
      materialisedThroughUtc:
          materialisedThroughUtc ?? this.materialisedThroughUtc,
      archivedAt: archivedAt ?? this.archivedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (colorKey.present) {
      map['color_key'] = Variable<String>(colorKey.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (rrule.present) {
      map['rrule'] = Variable<String>(rrule.value);
    }
    if (dtstartLocal.present) {
      map['dtstart_local'] = Variable<String>(dtstartLocal.value);
    }
    if (tzId.present) {
      map['tz_id'] = Variable<String>(tzId.value);
    }
    if (untilUtc.present) {
      map['until_utc'] = Variable<int>(untilUtc.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (travelBufferMin.present) {
      map['travel_buffer_min'] = Variable<int>(travelBufferMin.value);
    }
    if (durationFromSteps.present) {
      map['duration_from_steps'] = Variable<bool>(durationFromSteps.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (alerts.present) {
      map['alerts'] = Variable<String>(alerts.value);
    }
    if (soundId.present) {
      map['sound_id'] = Variable<String>(soundId.value);
    }
    if (subtaskTemplate.present) {
      map['subtask_template'] = Variable<String>(subtaskTemplate.value);
    }
    if (materialisedThroughUtc.present) {
      map['materialised_through_utc'] = Variable<int>(
        materialisedThroughUtc.value,
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(archivedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesTableCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('colorKey: $colorKey, ')
          ..write('iconKey: $iconKey, ')
          ..write('durationMin: $durationMin, ')
          ..write('rrule: $rrule, ')
          ..write('dtstartLocal: $dtstartLocal, ')
          ..write('tzId: $tzId, ')
          ..write('untilUtc: $untilUtc, ')
          ..write('count: $count, ')
          ..write('pinned: $pinned, ')
          ..write('travelBufferMin: $travelBufferMin, ')
          ..write('durationFromSteps: $durationFromSteps, ')
          ..write('energy: $energy, ')
          ..write('alerts: $alerts, ')
          ..write('soundId: $soundId, ')
          ..write('subtaskTemplate: $subtaskTemplate, ')
          ..write('materialisedThroughUtc: $materialisedThroughUtc, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarAccountsTable extends CalendarAccounts
    with TableInfo<$CalendarAccountsTable, CalendarAccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarAccountsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalAccountIdMeta = const VerificationMeta(
    'externalAccountId',
  );
  @override
  late final GeneratedColumn<String> externalAccountId =
      GeneratedColumn<String>(
        'external_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _writeBackMeta = const VerificationMeta(
    'writeBack',
  );
  @override
  late final GeneratedColumn<bool> writeBack = GeneratedColumn<bool>(
    'write_back',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("write_back" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    userId,
    provider,
    label,
    externalAccountId,
    writeBack,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarAccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('external_account_id')) {
      context.handle(
        _externalAccountIdMeta,
        externalAccountId.isAcceptableOrUnknown(
          data['external_account_id']!,
          _externalAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('write_back')) {
      context.handle(
        _writeBackMeta,
        writeBack.isAcceptableOrUnknown(data['write_back']!, _writeBackMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarAccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarAccountRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      externalAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_account_id'],
      ),
      writeBack: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}write_back'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $CalendarAccountsTable createAlias(String alias) {
    return $CalendarAccountsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class CalendarAccountRow extends DataClass
    implements Insertable<CalendarAccountRow> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String userId;
  final String provider;
  final String label;
  final String? externalAccountId;
  final bool writeBack;
  final bool enabled;
  const CalendarAccountRow({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.userId,
    required this.provider,
    required this.label,
    this.externalAccountId,
    required this.writeBack,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['provider'] = Variable<String>(provider);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || externalAccountId != null) {
      map['external_account_id'] = Variable<String>(externalAccountId);
    }
    map['write_back'] = Variable<bool>(writeBack);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  CalendarAccountsCompanion toCompanion(bool nullToAbsent) {
    return CalendarAccountsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      userId: Value(userId),
      provider: Value(provider),
      label: Value(label),
      externalAccountId: externalAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalAccountId),
      writeBack: Value(writeBack),
      enabled: Value(enabled),
    );
  }

  factory CalendarAccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarAccountRow(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      provider: serializer.fromJson<String>(json['provider']),
      label: serializer.fromJson<String>(json['label']),
      externalAccountId: serializer.fromJson<String?>(
        json['externalAccountId'],
      ),
      writeBack: serializer.fromJson<bool>(json['writeBack']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'provider': serializer.toJson<String>(provider),
      'label': serializer.toJson<String>(label),
      'externalAccountId': serializer.toJson<String?>(externalAccountId),
      'writeBack': serializer.toJson<bool>(writeBack),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  CalendarAccountRow copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    String? userId,
    String? provider,
    String? label,
    Value<String?> externalAccountId = const Value.absent(),
    bool? writeBack,
    bool? enabled,
  }) => CalendarAccountRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    provider: provider ?? this.provider,
    label: label ?? this.label,
    externalAccountId: externalAccountId.present
        ? externalAccountId.value
        : this.externalAccountId,
    writeBack: writeBack ?? this.writeBack,
    enabled: enabled ?? this.enabled,
  );
  CalendarAccountRow copyWithCompanion(CalendarAccountsCompanion data) {
    return CalendarAccountRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      provider: data.provider.present ? data.provider.value : this.provider,
      label: data.label.present ? data.label.value : this.label,
      externalAccountId: data.externalAccountId.present
          ? data.externalAccountId.value
          : this.externalAccountId,
      writeBack: data.writeBack.present ? data.writeBack.value : this.writeBack,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarAccountRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('provider: $provider, ')
          ..write('label: $label, ')
          ..write('externalAccountId: $externalAccountId, ')
          ..write('writeBack: $writeBack, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    userId,
    provider,
    label,
    externalAccountId,
    writeBack,
    enabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarAccountRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.provider == this.provider &&
          other.label == this.label &&
          other.externalAccountId == this.externalAccountId &&
          other.writeBack == this.writeBack &&
          other.enabled == this.enabled);
}

class CalendarAccountsCompanion extends UpdateCompanion<CalendarAccountRow> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> provider;
  final Value<String> label;
  final Value<String?> externalAccountId;
  final Value<bool> writeBack;
  final Value<bool> enabled;
  final Value<int> rowid;
  const CalendarAccountsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.provider = const Value.absent(),
    this.label = const Value.absent(),
    this.externalAccountId = const Value.absent(),
    this.writeBack = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarAccountsCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String userId,
    required String provider,
    required String label,
    this.externalAccountId = const Value.absent(),
    this.writeBack = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       userId = Value(userId),
       provider = Value(provider),
       label = Value(label);
  static Insertable<CalendarAccountRow> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? provider,
    Expression<String>? label,
    Expression<String>? externalAccountId,
    Expression<bool>? writeBack,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (provider != null) 'provider': provider,
      if (label != null) 'label': label,
      if (externalAccountId != null) 'external_account_id': externalAccountId,
      if (writeBack != null) 'write_back': writeBack,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarAccountsCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? provider,
    Value<String>? label,
    Value<String?>? externalAccountId,
    Value<bool>? writeBack,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return CalendarAccountsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
      label: label ?? this.label,
      externalAccountId: externalAccountId ?? this.externalAccountId,
      writeBack: writeBack ?? this.writeBack,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (externalAccountId.present) {
      map['external_account_id'] = Variable<String>(externalAccountId.value);
    }
    if (writeBack.present) {
      map['write_back'] = Variable<bool>(writeBack.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarAccountsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('provider: $provider, ')
          ..write('label: $label, ')
          ..write('externalAccountId: $externalAccountId, ')
          ..write('writeBack: $writeBack, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarLinksTable extends CalendarLinks
    with TableInfo<$CalendarLinksTable, CalendarLinkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES calendar_accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _externalCalendarIdMeta =
      const VerificationMeta('externalCalendarId');
  @override
  late final GeneratedColumn<String> externalCalendarId =
      GeneratedColumn<String>(
        'external_calendar_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _externalEventIdMeta = const VerificationMeta(
    'externalEventId',
  );
  @override
  late final GeneratedColumn<String> externalEventId = GeneratedColumn<String>(
    'external_event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedUtcMeta = const VerificationMeta(
    'lastSyncedUtc',
  );
  @override
  late final GeneratedColumn<int> lastSyncedUtc = GeneratedColumn<int>(
    'last_synced_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readOnlyMeta = const VerificationMeta(
    'readOnly',
  );
  @override
  late final GeneratedColumn<bool> readOnly = GeneratedColumn<bool>(
    'read_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read_only" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    check: () => const CustomExpression<bool>(
      'location IS NULL OR length(location) <= 200',
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    accountId,
    externalCalendarId,
    externalEventId,
    etag,
    lastSyncedUtc,
    readOnly,
    location,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarLinkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('external_calendar_id')) {
      context.handle(
        _externalCalendarIdMeta,
        externalCalendarId.isAcceptableOrUnknown(
          data['external_calendar_id']!,
          _externalCalendarIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_externalCalendarIdMeta);
    }
    if (data.containsKey('external_event_id')) {
      context.handle(
        _externalEventIdMeta,
        externalEventId.isAcceptableOrUnknown(
          data['external_event_id']!,
          _externalEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_externalEventIdMeta);
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    if (data.containsKey('last_synced_utc')) {
      context.handle(
        _lastSyncedUtcMeta,
        lastSyncedUtc.isAcceptableOrUnknown(
          data['last_synced_utc']!,
          _lastSyncedUtcMeta,
        ),
      );
    }
    if (data.containsKey('read_only')) {
      context.handle(
        _readOnlyMeta,
        readOnly.isAcceptableOrUnknown(data['read_only']!, _readOnlyMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarLinkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarLinkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      externalCalendarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_calendar_id'],
      )!,
      externalEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_event_id'],
      )!,
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
      lastSyncedUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_utc'],
      ),
      readOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}read_only'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
    );
  }

  @override
  $CalendarLinksTable createAlias(String alias) {
    return $CalendarLinksTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class CalendarLinkRow extends DataClass implements Insertable<CalendarLinkRow> {
  final String id;
  final String userId;
  final String accountId;
  final String externalCalendarId;
  final String externalEventId;
  final String? etag;
  final int? lastSyncedUtc;
  final bool readOnly;

  /// The event's place (M7.5, R-17): travel time is suggested before an
  /// event that has one. Column-level CHECK so ALTER TABLE keeps it.
  final String? location;
  const CalendarLinkRow({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.externalCalendarId,
    required this.externalEventId,
    this.etag,
    this.lastSyncedUtc,
    required this.readOnly,
    this.location,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['account_id'] = Variable<String>(accountId);
    map['external_calendar_id'] = Variable<String>(externalCalendarId);
    map['external_event_id'] = Variable<String>(externalEventId);
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    if (!nullToAbsent || lastSyncedUtc != null) {
      map['last_synced_utc'] = Variable<int>(lastSyncedUtc);
    }
    map['read_only'] = Variable<bool>(readOnly);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    return map;
  }

  CalendarLinksCompanion toCompanion(bool nullToAbsent) {
    return CalendarLinksCompanion(
      id: Value(id),
      userId: Value(userId),
      accountId: Value(accountId),
      externalCalendarId: Value(externalCalendarId),
      externalEventId: Value(externalEventId),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      lastSyncedUtc: lastSyncedUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedUtc),
      readOnly: Value(readOnly),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
    );
  }

  factory CalendarLinkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarLinkRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      externalCalendarId: serializer.fromJson<String>(
        json['externalCalendarId'],
      ),
      externalEventId: serializer.fromJson<String>(json['externalEventId']),
      etag: serializer.fromJson<String?>(json['etag']),
      lastSyncedUtc: serializer.fromJson<int?>(json['lastSyncedUtc']),
      readOnly: serializer.fromJson<bool>(json['readOnly']),
      location: serializer.fromJson<String?>(json['location']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'accountId': serializer.toJson<String>(accountId),
      'externalCalendarId': serializer.toJson<String>(externalCalendarId),
      'externalEventId': serializer.toJson<String>(externalEventId),
      'etag': serializer.toJson<String?>(etag),
      'lastSyncedUtc': serializer.toJson<int?>(lastSyncedUtc),
      'readOnly': serializer.toJson<bool>(readOnly),
      'location': serializer.toJson<String?>(location),
    };
  }

  CalendarLinkRow copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? externalCalendarId,
    String? externalEventId,
    Value<String?> etag = const Value.absent(),
    Value<int?> lastSyncedUtc = const Value.absent(),
    bool? readOnly,
    Value<String?> location = const Value.absent(),
  }) => CalendarLinkRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    accountId: accountId ?? this.accountId,
    externalCalendarId: externalCalendarId ?? this.externalCalendarId,
    externalEventId: externalEventId ?? this.externalEventId,
    etag: etag.present ? etag.value : this.etag,
    lastSyncedUtc: lastSyncedUtc.present
        ? lastSyncedUtc.value
        : this.lastSyncedUtc,
    readOnly: readOnly ?? this.readOnly,
    location: location.present ? location.value : this.location,
  );
  CalendarLinkRow copyWithCompanion(CalendarLinksCompanion data) {
    return CalendarLinkRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      externalCalendarId: data.externalCalendarId.present
          ? data.externalCalendarId.value
          : this.externalCalendarId,
      externalEventId: data.externalEventId.present
          ? data.externalEventId.value
          : this.externalEventId,
      etag: data.etag.present ? data.etag.value : this.etag,
      lastSyncedUtc: data.lastSyncedUtc.present
          ? data.lastSyncedUtc.value
          : this.lastSyncedUtc,
      readOnly: data.readOnly.present ? data.readOnly.value : this.readOnly,
      location: data.location.present ? data.location.value : this.location,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarLinkRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('externalCalendarId: $externalCalendarId, ')
          ..write('externalEventId: $externalEventId, ')
          ..write('etag: $etag, ')
          ..write('lastSyncedUtc: $lastSyncedUtc, ')
          ..write('readOnly: $readOnly, ')
          ..write('location: $location')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    accountId,
    externalCalendarId,
    externalEventId,
    etag,
    lastSyncedUtc,
    readOnly,
    location,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarLinkRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.accountId == this.accountId &&
          other.externalCalendarId == this.externalCalendarId &&
          other.externalEventId == this.externalEventId &&
          other.etag == this.etag &&
          other.lastSyncedUtc == this.lastSyncedUtc &&
          other.readOnly == this.readOnly &&
          other.location == this.location);
}

class CalendarLinksCompanion extends UpdateCompanion<CalendarLinkRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> accountId;
  final Value<String> externalCalendarId;
  final Value<String> externalEventId;
  final Value<String?> etag;
  final Value<int?> lastSyncedUtc;
  final Value<bool> readOnly;
  final Value<String?> location;
  final Value<int> rowid;
  const CalendarLinksCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.externalCalendarId = const Value.absent(),
    this.externalEventId = const Value.absent(),
    this.etag = const Value.absent(),
    this.lastSyncedUtc = const Value.absent(),
    this.readOnly = const Value.absent(),
    this.location = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarLinksCompanion.insert({
    required String id,
    required String userId,
    required String accountId,
    required String externalCalendarId,
    required String externalEventId,
    this.etag = const Value.absent(),
    this.lastSyncedUtc = const Value.absent(),
    this.readOnly = const Value.absent(),
    this.location = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       accountId = Value(accountId),
       externalCalendarId = Value(externalCalendarId),
       externalEventId = Value(externalEventId);
  static Insertable<CalendarLinkRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? accountId,
    Expression<String>? externalCalendarId,
    Expression<String>? externalEventId,
    Expression<String>? etag,
    Expression<int>? lastSyncedUtc,
    Expression<bool>? readOnly,
    Expression<String>? location,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (accountId != null) 'account_id': accountId,
      if (externalCalendarId != null)
        'external_calendar_id': externalCalendarId,
      if (externalEventId != null) 'external_event_id': externalEventId,
      if (etag != null) 'etag': etag,
      if (lastSyncedUtc != null) 'last_synced_utc': lastSyncedUtc,
      if (readOnly != null) 'read_only': readOnly,
      if (location != null) 'location': location,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarLinksCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? accountId,
    Value<String>? externalCalendarId,
    Value<String>? externalEventId,
    Value<String?>? etag,
    Value<int?>? lastSyncedUtc,
    Value<bool>? readOnly,
    Value<String?>? location,
    Value<int>? rowid,
  }) {
    return CalendarLinksCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      externalCalendarId: externalCalendarId ?? this.externalCalendarId,
      externalEventId: externalEventId ?? this.externalEventId,
      etag: etag ?? this.etag,
      lastSyncedUtc: lastSyncedUtc ?? this.lastSyncedUtc,
      readOnly: readOnly ?? this.readOnly,
      location: location ?? this.location,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (externalCalendarId.present) {
      map['external_calendar_id'] = Variable<String>(externalCalendarId.value);
    }
    if (externalEventId.present) {
      map['external_event_id'] = Variable<String>(externalEventId.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (lastSyncedUtc.present) {
      map['last_synced_utc'] = Variable<int>(lastSyncedUtc.value);
    }
    if (readOnly.present) {
      map['read_only'] = Variable<bool>(readOnly.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarLinksCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('externalCalendarId: $externalCalendarId, ')
          ..write('externalEventId: $externalEventId, ')
          ..write('etag: $etag, ')
          ..write('lastSyncedUtc: $lastSyncedUtc, ')
          ..write('readOnly: $readOnly, ')
          ..write('location: $location, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OccurrencesTable extends Occurrences
    with TableInfo<$OccurrencesTable, OccurrenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OccurrencesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES series (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _originalStartUtcMeta = const VerificationMeta(
    'originalStartUtc',
  );
  @override
  late final GeneratedColumn<int> originalStartUtc = GeneratedColumn<int>(
    'original_start_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorKeyMeta = const VerificationMeta(
    'colorKey',
  );
  @override
  late final GeneratedColumn<String> colorKey = GeneratedColumn<String>(
    'color_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('indigo'),
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('circle'),
  );
  static const VerificationMeta _startUtcMeta = const VerificationMeta(
    'startUtc',
  );
  @override
  late final GeneratedColumn<int> startUtc = GeneratedColumn<int>(
    'start_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tzIdMeta = const VerificationMeta('tzId');
  @override
  late final GeneratedColumn<String> tzId = GeneratedColumn<String>(
    'tz_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _travelBufferMinMeta = const VerificationMeta(
    'travelBufferMin',
  );
  @override
  late final GeneratedColumn<int> travelBufferMin = GeneratedColumn<int>(
    'travel_buffer_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
    'energy',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alertsMeta = const VerificationMeta('alerts');
  @override
  late final GeneratedColumn<String> alerts = GeneratedColumn<String>(
    'alerts',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soundIdMeta = const VerificationMeta(
    'soundId',
  );
  @override
  late final GeneratedColumn<String> soundId = GeneratedColumn<String>(
    'sound_id',
    aliasedName,
    true,
    check: () => soundIdCheck,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  static const VerificationMeta _completedAtUtcMeta = const VerificationMeta(
    'completedAtUtc',
  );
  @override
  late final GeneratedColumn<int> completedAtUtc = GeneratedColumn<int>(
    'completed_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<double> sortOrder = GeneratedColumn<double>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user'),
  );
  static const VerificationMeta _calendarLinkIdMeta = const VerificationMeta(
    'calendarLinkId',
  );
  @override
  late final GeneratedColumn<String> calendarLinkId = GeneratedColumn<String>(
    'calendar_link_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES calendar_links (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _snoozedUntilUtcMeta = const VerificationMeta(
    'snoozedUntilUtc',
  );
  @override
  late final GeneratedColumn<int> snoozedUntilUtc = GeneratedColumn<int>(
    'snoozed_until_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualStartUtcMeta = const VerificationMeta(
    'actualStartUtc',
  );
  @override
  late final GeneratedColumn<int> actualStartUtc = GeneratedColumn<int>(
    'actual_start_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualEndUtcMeta = const VerificationMeta(
    'actualEndUtc',
  );
  @override
  late final GeneratedColumn<int> actualEndUtc = GeneratedColumn<int>(
    'actual_end_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationFromStepsMeta = const VerificationMeta(
    'durationFromSteps',
  );
  @override
  late final GeneratedColumn<bool> durationFromSteps = GeneratedColumn<bool>(
    'duration_from_steps',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("duration_from_steps" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _moveCountMeta = const VerificationMeta(
    'moveCount',
  );
  @override
  late final GeneratedColumn<int> moveCount = GeneratedColumn<int>(
    'move_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _routineStartMeta = const VerificationMeta(
    'routineStart',
  );
  @override
  late final GeneratedColumn<bool> routineStart = GeneratedColumn<bool>(
    'routine_start',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("routine_start" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    dirty,
    version,
    id,
    userId,
    seriesId,
    originalStartUtc,
    title,
    notes,
    colorKey,
    iconKey,
    startUtc,
    tzId,
    durationMin,
    pinned,
    travelBufferMin,
    energy,
    alerts,
    soundId,
    status,
    completedAtUtc,
    sortOrder,
    source,
    calendarLinkId,
    snoozedUntilUtc,
    actualStartUtc,
    actualEndUtc,
    durationFromSteps,
    moveCount,
    routineStart,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<OccurrenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('original_start_utc')) {
      context.handle(
        _originalStartUtcMeta,
        originalStartUtc.isAcceptableOrUnknown(
          data['original_start_utc']!,
          _originalStartUtcMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('color_key')) {
      context.handle(
        _colorKeyMeta,
        colorKey.isAcceptableOrUnknown(data['color_key']!, _colorKeyMeta),
      );
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('start_utc')) {
      context.handle(
        _startUtcMeta,
        startUtc.isAcceptableOrUnknown(data['start_utc']!, _startUtcMeta),
      );
    }
    if (data.containsKey('tz_id')) {
      context.handle(
        _tzIdMeta,
        tzId.isAcceptableOrUnknown(data['tz_id']!, _tzIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tzIdMeta);
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinMeta);
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('travel_buffer_min')) {
      context.handle(
        _travelBufferMinMeta,
        travelBufferMin.isAcceptableOrUnknown(
          data['travel_buffer_min']!,
          _travelBufferMinMeta,
        ),
      );
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    }
    if (data.containsKey('alerts')) {
      context.handle(
        _alertsMeta,
        alerts.isAcceptableOrUnknown(data['alerts']!, _alertsMeta),
      );
    }
    if (data.containsKey('sound_id')) {
      context.handle(
        _soundIdMeta,
        soundId.isAcceptableOrUnknown(data['sound_id']!, _soundIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('completed_at_utc')) {
      context.handle(
        _completedAtUtcMeta,
        completedAtUtc.isAcceptableOrUnknown(
          data['completed_at_utc']!,
          _completedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('calendar_link_id')) {
      context.handle(
        _calendarLinkIdMeta,
        calendarLinkId.isAcceptableOrUnknown(
          data['calendar_link_id']!,
          _calendarLinkIdMeta,
        ),
      );
    }
    if (data.containsKey('snoozed_until_utc')) {
      context.handle(
        _snoozedUntilUtcMeta,
        snoozedUntilUtc.isAcceptableOrUnknown(
          data['snoozed_until_utc']!,
          _snoozedUntilUtcMeta,
        ),
      );
    }
    if (data.containsKey('actual_start_utc')) {
      context.handle(
        _actualStartUtcMeta,
        actualStartUtc.isAcceptableOrUnknown(
          data['actual_start_utc']!,
          _actualStartUtcMeta,
        ),
      );
    }
    if (data.containsKey('actual_end_utc')) {
      context.handle(
        _actualEndUtcMeta,
        actualEndUtc.isAcceptableOrUnknown(
          data['actual_end_utc']!,
          _actualEndUtcMeta,
        ),
      );
    }
    if (data.containsKey('duration_from_steps')) {
      context.handle(
        _durationFromStepsMeta,
        durationFromSteps.isAcceptableOrUnknown(
          data['duration_from_steps']!,
          _durationFromStepsMeta,
        ),
      );
    }
    if (data.containsKey('move_count')) {
      context.handle(
        _moveCountMeta,
        moveCount.isAcceptableOrUnknown(data['move_count']!, _moveCountMeta),
      );
    }
    if (data.containsKey('routine_start')) {
      context.handle(
        _routineStartMeta,
        routineStart.isAcceptableOrUnknown(
          data['routine_start']!,
          _routineStartMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OccurrenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OccurrenceRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      ),
      originalStartUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_start_utc'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      colorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_key'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      startUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_utc'],
      ),
      tzId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tz_id'],
      )!,
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      travelBufferMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}travel_buffer_min'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy'],
      ),
      alerts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alerts'],
      ),
      soundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_utc'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sort_order'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      calendarLinkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_link_id'],
      ),
      snoozedUntilUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snoozed_until_utc'],
      ),
      actualStartUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_start_utc'],
      ),
      actualEndUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_end_utc'],
      ),
      durationFromSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}duration_from_steps'],
      )!,
      moveCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}move_count'],
      )!,
      routineStart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}routine_start'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $OccurrencesTable createAlias(String alias) {
    return $OccurrencesTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class OccurrenceRow extends DataClass implements Insertable<OccurrenceRow> {
  final int createdAt;
  final int updatedAt;
  final bool dirty;
  final int version;
  final String id;
  final String userId;
  final String? seriesId;
  final int? originalStartUtc;
  final String title;
  final String? notes;
  final String colorKey;
  final String iconKey;

  /// Null = inbox.
  final int? startUtc;
  final String tzId;
  final int durationMin;
  final bool pinned;
  final int travelBufferMin;
  final int? energy;

  /// Null inherits the series alerts; `[]` is an explicit "no alerts".
  final String? alerts;

  /// The reminder sound (docs/12 §3); null inherits the series'.
  final String? soundId;
  final String status;
  final int? completedAtUtc;
  final double sortOrder;
  final String source;
  final String? calendarLinkId;
  final int? snoozedUntilUtc;
  final int? actualStartUtc;
  final int? actualEndUtc;
  final bool durationFromSteps;
  final int moveCount;
  final bool routineStart;
  final int? deletedAt;
  const OccurrenceRow({
    required this.createdAt,
    required this.updatedAt,
    required this.dirty,
    required this.version,
    required this.id,
    required this.userId,
    this.seriesId,
    this.originalStartUtc,
    required this.title,
    this.notes,
    required this.colorKey,
    required this.iconKey,
    this.startUtc,
    required this.tzId,
    required this.durationMin,
    required this.pinned,
    required this.travelBufferMin,
    this.energy,
    this.alerts,
    this.soundId,
    required this.status,
    this.completedAtUtc,
    required this.sortOrder,
    required this.source,
    this.calendarLinkId,
    this.snoozedUntilUtc,
    this.actualStartUtc,
    this.actualEndUtc,
    required this.durationFromSteps,
    required this.moveCount,
    required this.routineStart,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    map['version'] = Variable<int>(version);
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    if (!nullToAbsent || originalStartUtc != null) {
      map['original_start_utc'] = Variable<int>(originalStartUtc);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['color_key'] = Variable<String>(colorKey);
    map['icon_key'] = Variable<String>(iconKey);
    if (!nullToAbsent || startUtc != null) {
      map['start_utc'] = Variable<int>(startUtc);
    }
    map['tz_id'] = Variable<String>(tzId);
    map['duration_min'] = Variable<int>(durationMin);
    map['pinned'] = Variable<bool>(pinned);
    map['travel_buffer_min'] = Variable<int>(travelBufferMin);
    if (!nullToAbsent || energy != null) {
      map['energy'] = Variable<int>(energy);
    }
    if (!nullToAbsent || alerts != null) {
      map['alerts'] = Variable<String>(alerts);
    }
    if (!nullToAbsent || soundId != null) {
      map['sound_id'] = Variable<String>(soundId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAtUtc != null) {
      map['completed_at_utc'] = Variable<int>(completedAtUtc);
    }
    map['sort_order'] = Variable<double>(sortOrder);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || calendarLinkId != null) {
      map['calendar_link_id'] = Variable<String>(calendarLinkId);
    }
    if (!nullToAbsent || snoozedUntilUtc != null) {
      map['snoozed_until_utc'] = Variable<int>(snoozedUntilUtc);
    }
    if (!nullToAbsent || actualStartUtc != null) {
      map['actual_start_utc'] = Variable<int>(actualStartUtc);
    }
    if (!nullToAbsent || actualEndUtc != null) {
      map['actual_end_utc'] = Variable<int>(actualEndUtc);
    }
    map['duration_from_steps'] = Variable<bool>(durationFromSteps);
    map['move_count'] = Variable<int>(moveCount);
    map['routine_start'] = Variable<bool>(routineStart);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  OccurrencesCompanion toCompanion(bool nullToAbsent) {
    return OccurrencesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      version: Value(version),
      id: Value(id),
      userId: Value(userId),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      originalStartUtc: originalStartUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(originalStartUtc),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      colorKey: Value(colorKey),
      iconKey: Value(iconKey),
      startUtc: startUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(startUtc),
      tzId: Value(tzId),
      durationMin: Value(durationMin),
      pinned: Value(pinned),
      travelBufferMin: Value(travelBufferMin),
      energy: energy == null && nullToAbsent
          ? const Value.absent()
          : Value(energy),
      alerts: alerts == null && nullToAbsent
          ? const Value.absent()
          : Value(alerts),
      soundId: soundId == null && nullToAbsent
          ? const Value.absent()
          : Value(soundId),
      status: Value(status),
      completedAtUtc: completedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtUtc),
      sortOrder: Value(sortOrder),
      source: Value(source),
      calendarLinkId: calendarLinkId == null && nullToAbsent
          ? const Value.absent()
          : Value(calendarLinkId),
      snoozedUntilUtc: snoozedUntilUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntilUtc),
      actualStartUtc: actualStartUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(actualStartUtc),
      actualEndUtc: actualEndUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(actualEndUtc),
      durationFromSteps: Value(durationFromSteps),
      moveCount: Value(moveCount),
      routineStart: Value(routineStart),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory OccurrenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OccurrenceRow(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      version: serializer.fromJson<int>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
      originalStartUtc: serializer.fromJson<int?>(json['originalStartUtc']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      colorKey: serializer.fromJson<String>(json['colorKey']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      startUtc: serializer.fromJson<int?>(json['startUtc']),
      tzId: serializer.fromJson<String>(json['tzId']),
      durationMin: serializer.fromJson<int>(json['durationMin']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      travelBufferMin: serializer.fromJson<int>(json['travelBufferMin']),
      energy: serializer.fromJson<int?>(json['energy']),
      alerts: serializer.fromJson<String?>(json['alerts']),
      soundId: serializer.fromJson<String?>(json['soundId']),
      status: serializer.fromJson<String>(json['status']),
      completedAtUtc: serializer.fromJson<int?>(json['completedAtUtc']),
      sortOrder: serializer.fromJson<double>(json['sortOrder']),
      source: serializer.fromJson<String>(json['source']),
      calendarLinkId: serializer.fromJson<String?>(json['calendarLinkId']),
      snoozedUntilUtc: serializer.fromJson<int?>(json['snoozedUntilUtc']),
      actualStartUtc: serializer.fromJson<int?>(json['actualStartUtc']),
      actualEndUtc: serializer.fromJson<int?>(json['actualEndUtc']),
      durationFromSteps: serializer.fromJson<bool>(json['durationFromSteps']),
      moveCount: serializer.fromJson<int>(json['moveCount']),
      routineStart: serializer.fromJson<bool>(json['routineStart']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'version': serializer.toJson<int>(version),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'seriesId': serializer.toJson<String?>(seriesId),
      'originalStartUtc': serializer.toJson<int?>(originalStartUtc),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'colorKey': serializer.toJson<String>(colorKey),
      'iconKey': serializer.toJson<String>(iconKey),
      'startUtc': serializer.toJson<int?>(startUtc),
      'tzId': serializer.toJson<String>(tzId),
      'durationMin': serializer.toJson<int>(durationMin),
      'pinned': serializer.toJson<bool>(pinned),
      'travelBufferMin': serializer.toJson<int>(travelBufferMin),
      'energy': serializer.toJson<int?>(energy),
      'alerts': serializer.toJson<String?>(alerts),
      'soundId': serializer.toJson<String?>(soundId),
      'status': serializer.toJson<String>(status),
      'completedAtUtc': serializer.toJson<int?>(completedAtUtc),
      'sortOrder': serializer.toJson<double>(sortOrder),
      'source': serializer.toJson<String>(source),
      'calendarLinkId': serializer.toJson<String?>(calendarLinkId),
      'snoozedUntilUtc': serializer.toJson<int?>(snoozedUntilUtc),
      'actualStartUtc': serializer.toJson<int?>(actualStartUtc),
      'actualEndUtc': serializer.toJson<int?>(actualEndUtc),
      'durationFromSteps': serializer.toJson<bool>(durationFromSteps),
      'moveCount': serializer.toJson<int>(moveCount),
      'routineStart': serializer.toJson<bool>(routineStart),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  OccurrenceRow copyWith({
    int? createdAt,
    int? updatedAt,
    bool? dirty,
    int? version,
    String? id,
    String? userId,
    Value<String?> seriesId = const Value.absent(),
    Value<int?> originalStartUtc = const Value.absent(),
    String? title,
    Value<String?> notes = const Value.absent(),
    String? colorKey,
    String? iconKey,
    Value<int?> startUtc = const Value.absent(),
    String? tzId,
    int? durationMin,
    bool? pinned,
    int? travelBufferMin,
    Value<int?> energy = const Value.absent(),
    Value<String?> alerts = const Value.absent(),
    Value<String?> soundId = const Value.absent(),
    String? status,
    Value<int?> completedAtUtc = const Value.absent(),
    double? sortOrder,
    String? source,
    Value<String?> calendarLinkId = const Value.absent(),
    Value<int?> snoozedUntilUtc = const Value.absent(),
    Value<int?> actualStartUtc = const Value.absent(),
    Value<int?> actualEndUtc = const Value.absent(),
    bool? durationFromSteps,
    int? moveCount,
    bool? routineStart,
    Value<int?> deletedAt = const Value.absent(),
  }) => OccurrenceRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dirty: dirty ?? this.dirty,
    version: version ?? this.version,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    originalStartUtc: originalStartUtc.present
        ? originalStartUtc.value
        : this.originalStartUtc,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    colorKey: colorKey ?? this.colorKey,
    iconKey: iconKey ?? this.iconKey,
    startUtc: startUtc.present ? startUtc.value : this.startUtc,
    tzId: tzId ?? this.tzId,
    durationMin: durationMin ?? this.durationMin,
    pinned: pinned ?? this.pinned,
    travelBufferMin: travelBufferMin ?? this.travelBufferMin,
    energy: energy.present ? energy.value : this.energy,
    alerts: alerts.present ? alerts.value : this.alerts,
    soundId: soundId.present ? soundId.value : this.soundId,
    status: status ?? this.status,
    completedAtUtc: completedAtUtc.present
        ? completedAtUtc.value
        : this.completedAtUtc,
    sortOrder: sortOrder ?? this.sortOrder,
    source: source ?? this.source,
    calendarLinkId: calendarLinkId.present
        ? calendarLinkId.value
        : this.calendarLinkId,
    snoozedUntilUtc: snoozedUntilUtc.present
        ? snoozedUntilUtc.value
        : this.snoozedUntilUtc,
    actualStartUtc: actualStartUtc.present
        ? actualStartUtc.value
        : this.actualStartUtc,
    actualEndUtc: actualEndUtc.present ? actualEndUtc.value : this.actualEndUtc,
    durationFromSteps: durationFromSteps ?? this.durationFromSteps,
    moveCount: moveCount ?? this.moveCount,
    routineStart: routineStart ?? this.routineStart,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  OccurrenceRow copyWithCompanion(OccurrencesCompanion data) {
    return OccurrenceRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      originalStartUtc: data.originalStartUtc.present
          ? data.originalStartUtc.value
          : this.originalStartUtc,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      colorKey: data.colorKey.present ? data.colorKey.value : this.colorKey,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      tzId: data.tzId.present ? data.tzId.value : this.tzId,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      travelBufferMin: data.travelBufferMin.present
          ? data.travelBufferMin.value
          : this.travelBufferMin,
      energy: data.energy.present ? data.energy.value : this.energy,
      alerts: data.alerts.present ? data.alerts.value : this.alerts,
      soundId: data.soundId.present ? data.soundId.value : this.soundId,
      status: data.status.present ? data.status.value : this.status,
      completedAtUtc: data.completedAtUtc.present
          ? data.completedAtUtc.value
          : this.completedAtUtc,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      source: data.source.present ? data.source.value : this.source,
      calendarLinkId: data.calendarLinkId.present
          ? data.calendarLinkId.value
          : this.calendarLinkId,
      snoozedUntilUtc: data.snoozedUntilUtc.present
          ? data.snoozedUntilUtc.value
          : this.snoozedUntilUtc,
      actualStartUtc: data.actualStartUtc.present
          ? data.actualStartUtc.value
          : this.actualStartUtc,
      actualEndUtc: data.actualEndUtc.present
          ? data.actualEndUtc.value
          : this.actualEndUtc,
      durationFromSteps: data.durationFromSteps.present
          ? data.durationFromSteps.value
          : this.durationFromSteps,
      moveCount: data.moveCount.present ? data.moveCount.value : this.moveCount,
      routineStart: data.routineStart.present
          ? data.routineStart.value
          : this.routineStart,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OccurrenceRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('seriesId: $seriesId, ')
          ..write('originalStartUtc: $originalStartUtc, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('colorKey: $colorKey, ')
          ..write('iconKey: $iconKey, ')
          ..write('startUtc: $startUtc, ')
          ..write('tzId: $tzId, ')
          ..write('durationMin: $durationMin, ')
          ..write('pinned: $pinned, ')
          ..write('travelBufferMin: $travelBufferMin, ')
          ..write('energy: $energy, ')
          ..write('alerts: $alerts, ')
          ..write('soundId: $soundId, ')
          ..write('status: $status, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('source: $source, ')
          ..write('calendarLinkId: $calendarLinkId, ')
          ..write('snoozedUntilUtc: $snoozedUntilUtc, ')
          ..write('actualStartUtc: $actualStartUtc, ')
          ..write('actualEndUtc: $actualEndUtc, ')
          ..write('durationFromSteps: $durationFromSteps, ')
          ..write('moveCount: $moveCount, ')
          ..write('routineStart: $routineStart, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    updatedAt,
    dirty,
    version,
    id,
    userId,
    seriesId,
    originalStartUtc,
    title,
    notes,
    colorKey,
    iconKey,
    startUtc,
    tzId,
    durationMin,
    pinned,
    travelBufferMin,
    energy,
    alerts,
    soundId,
    status,
    completedAtUtc,
    sortOrder,
    source,
    calendarLinkId,
    snoozedUntilUtc,
    actualStartUtc,
    actualEndUtc,
    durationFromSteps,
    moveCount,
    routineStart,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OccurrenceRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.version == this.version &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.seriesId == this.seriesId &&
          other.originalStartUtc == this.originalStartUtc &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.colorKey == this.colorKey &&
          other.iconKey == this.iconKey &&
          other.startUtc == this.startUtc &&
          other.tzId == this.tzId &&
          other.durationMin == this.durationMin &&
          other.pinned == this.pinned &&
          other.travelBufferMin == this.travelBufferMin &&
          other.energy == this.energy &&
          other.alerts == this.alerts &&
          other.soundId == this.soundId &&
          other.status == this.status &&
          other.completedAtUtc == this.completedAtUtc &&
          other.sortOrder == this.sortOrder &&
          other.source == this.source &&
          other.calendarLinkId == this.calendarLinkId &&
          other.snoozedUntilUtc == this.snoozedUntilUtc &&
          other.actualStartUtc == this.actualStartUtc &&
          other.actualEndUtc == this.actualEndUtc &&
          other.durationFromSteps == this.durationFromSteps &&
          other.moveCount == this.moveCount &&
          other.routineStart == this.routineStart &&
          other.deletedAt == this.deletedAt);
}

class OccurrencesCompanion extends UpdateCompanion<OccurrenceRow> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> dirty;
  final Value<int> version;
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> seriesId;
  final Value<int?> originalStartUtc;
  final Value<String> title;
  final Value<String?> notes;
  final Value<String> colorKey;
  final Value<String> iconKey;
  final Value<int?> startUtc;
  final Value<String> tzId;
  final Value<int> durationMin;
  final Value<bool> pinned;
  final Value<int> travelBufferMin;
  final Value<int?> energy;
  final Value<String?> alerts;
  final Value<String?> soundId;
  final Value<String> status;
  final Value<int?> completedAtUtc;
  final Value<double> sortOrder;
  final Value<String> source;
  final Value<String?> calendarLinkId;
  final Value<int?> snoozedUntilUtc;
  final Value<int?> actualStartUtc;
  final Value<int?> actualEndUtc;
  final Value<bool> durationFromSteps;
  final Value<int> moveCount;
  final Value<bool> routineStart;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const OccurrencesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.originalStartUtc = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.colorKey = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.tzId = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.pinned = const Value.absent(),
    this.travelBufferMin = const Value.absent(),
    this.energy = const Value.absent(),
    this.alerts = const Value.absent(),
    this.soundId = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAtUtc = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.source = const Value.absent(),
    this.calendarLinkId = const Value.absent(),
    this.snoozedUntilUtc = const Value.absent(),
    this.actualStartUtc = const Value.absent(),
    this.actualEndUtc = const Value.absent(),
    this.durationFromSteps = const Value.absent(),
    this.moveCount = const Value.absent(),
    this.routineStart = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OccurrencesCompanion.insert({
    required int createdAt,
    required int updatedAt,
    this.dirty = const Value.absent(),
    this.version = const Value.absent(),
    required String id,
    required String userId,
    this.seriesId = const Value.absent(),
    this.originalStartUtc = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    this.colorKey = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.startUtc = const Value.absent(),
    required String tzId,
    required int durationMin,
    this.pinned = const Value.absent(),
    this.travelBufferMin = const Value.absent(),
    this.energy = const Value.absent(),
    this.alerts = const Value.absent(),
    this.soundId = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAtUtc = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.source = const Value.absent(),
    this.calendarLinkId = const Value.absent(),
    this.snoozedUntilUtc = const Value.absent(),
    this.actualStartUtc = const Value.absent(),
    this.actualEndUtc = const Value.absent(),
    this.durationFromSteps = const Value.absent(),
    this.moveCount = const Value.absent(),
    this.routineStart = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       userId = Value(userId),
       title = Value(title),
       tzId = Value(tzId),
       durationMin = Value(durationMin);
  static Insertable<OccurrenceRow> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? dirty,
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? seriesId,
    Expression<int>? originalStartUtc,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? colorKey,
    Expression<String>? iconKey,
    Expression<int>? startUtc,
    Expression<String>? tzId,
    Expression<int>? durationMin,
    Expression<bool>? pinned,
    Expression<int>? travelBufferMin,
    Expression<int>? energy,
    Expression<String>? alerts,
    Expression<String>? soundId,
    Expression<String>? status,
    Expression<int>? completedAtUtc,
    Expression<double>? sortOrder,
    Expression<String>? source,
    Expression<String>? calendarLinkId,
    Expression<int>? snoozedUntilUtc,
    Expression<int>? actualStartUtc,
    Expression<int>? actualEndUtc,
    Expression<bool>? durationFromSteps,
    Expression<int>? moveCount,
    Expression<bool>? routineStart,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (seriesId != null) 'series_id': seriesId,
      if (originalStartUtc != null) 'original_start_utc': originalStartUtc,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (colorKey != null) 'color_key': colorKey,
      if (iconKey != null) 'icon_key': iconKey,
      if (startUtc != null) 'start_utc': startUtc,
      if (tzId != null) 'tz_id': tzId,
      if (durationMin != null) 'duration_min': durationMin,
      if (pinned != null) 'pinned': pinned,
      if (travelBufferMin != null) 'travel_buffer_min': travelBufferMin,
      if (energy != null) 'energy': energy,
      if (alerts != null) 'alerts': alerts,
      if (soundId != null) 'sound_id': soundId,
      if (status != null) 'status': status,
      if (completedAtUtc != null) 'completed_at_utc': completedAtUtc,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (source != null) 'source': source,
      if (calendarLinkId != null) 'calendar_link_id': calendarLinkId,
      if (snoozedUntilUtc != null) 'snoozed_until_utc': snoozedUntilUtc,
      if (actualStartUtc != null) 'actual_start_utc': actualStartUtc,
      if (actualEndUtc != null) 'actual_end_utc': actualEndUtc,
      if (durationFromSteps != null) 'duration_from_steps': durationFromSteps,
      if (moveCount != null) 'move_count': moveCount,
      if (routineStart != null) 'routine_start': routineStart,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OccurrencesCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? dirty,
    Value<int>? version,
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? seriesId,
    Value<int?>? originalStartUtc,
    Value<String>? title,
    Value<String?>? notes,
    Value<String>? colorKey,
    Value<String>? iconKey,
    Value<int?>? startUtc,
    Value<String>? tzId,
    Value<int>? durationMin,
    Value<bool>? pinned,
    Value<int>? travelBufferMin,
    Value<int?>? energy,
    Value<String?>? alerts,
    Value<String?>? soundId,
    Value<String>? status,
    Value<int?>? completedAtUtc,
    Value<double>? sortOrder,
    Value<String>? source,
    Value<String?>? calendarLinkId,
    Value<int?>? snoozedUntilUtc,
    Value<int?>? actualStartUtc,
    Value<int?>? actualEndUtc,
    Value<bool>? durationFromSteps,
    Value<int>? moveCount,
    Value<bool>? routineStart,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return OccurrencesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      version: version ?? this.version,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      seriesId: seriesId ?? this.seriesId,
      originalStartUtc: originalStartUtc ?? this.originalStartUtc,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      colorKey: colorKey ?? this.colorKey,
      iconKey: iconKey ?? this.iconKey,
      startUtc: startUtc ?? this.startUtc,
      tzId: tzId ?? this.tzId,
      durationMin: durationMin ?? this.durationMin,
      pinned: pinned ?? this.pinned,
      travelBufferMin: travelBufferMin ?? this.travelBufferMin,
      energy: energy ?? this.energy,
      alerts: alerts ?? this.alerts,
      soundId: soundId ?? this.soundId,
      status: status ?? this.status,
      completedAtUtc: completedAtUtc ?? this.completedAtUtc,
      sortOrder: sortOrder ?? this.sortOrder,
      source: source ?? this.source,
      calendarLinkId: calendarLinkId ?? this.calendarLinkId,
      snoozedUntilUtc: snoozedUntilUtc ?? this.snoozedUntilUtc,
      actualStartUtc: actualStartUtc ?? this.actualStartUtc,
      actualEndUtc: actualEndUtc ?? this.actualEndUtc,
      durationFromSteps: durationFromSteps ?? this.durationFromSteps,
      moveCount: moveCount ?? this.moveCount,
      routineStart: routineStart ?? this.routineStart,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (originalStartUtc.present) {
      map['original_start_utc'] = Variable<int>(originalStartUtc.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (colorKey.present) {
      map['color_key'] = Variable<String>(colorKey.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<int>(startUtc.value);
    }
    if (tzId.present) {
      map['tz_id'] = Variable<String>(tzId.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (travelBufferMin.present) {
      map['travel_buffer_min'] = Variable<int>(travelBufferMin.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (alerts.present) {
      map['alerts'] = Variable<String>(alerts.value);
    }
    if (soundId.present) {
      map['sound_id'] = Variable<String>(soundId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAtUtc.present) {
      map['completed_at_utc'] = Variable<int>(completedAtUtc.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<double>(sortOrder.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (calendarLinkId.present) {
      map['calendar_link_id'] = Variable<String>(calendarLinkId.value);
    }
    if (snoozedUntilUtc.present) {
      map['snoozed_until_utc'] = Variable<int>(snoozedUntilUtc.value);
    }
    if (actualStartUtc.present) {
      map['actual_start_utc'] = Variable<int>(actualStartUtc.value);
    }
    if (actualEndUtc.present) {
      map['actual_end_utc'] = Variable<int>(actualEndUtc.value);
    }
    if (durationFromSteps.present) {
      map['duration_from_steps'] = Variable<bool>(durationFromSteps.value);
    }
    if (moveCount.present) {
      map['move_count'] = Variable<int>(moveCount.value);
    }
    if (routineStart.present) {
      map['routine_start'] = Variable<bool>(routineStart.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OccurrencesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('seriesId: $seriesId, ')
          ..write('originalStartUtc: $originalStartUtc, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('colorKey: $colorKey, ')
          ..write('iconKey: $iconKey, ')
          ..write('startUtc: $startUtc, ')
          ..write('tzId: $tzId, ')
          ..write('durationMin: $durationMin, ')
          ..write('pinned: $pinned, ')
          ..write('travelBufferMin: $travelBufferMin, ')
          ..write('energy: $energy, ')
          ..write('alerts: $alerts, ')
          ..write('soundId: $soundId, ')
          ..write('status: $status, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('source: $source, ')
          ..write('calendarLinkId: $calendarLinkId, ')
          ..write('snoozedUntilUtc: $snoozedUntilUtc, ')
          ..write('actualStartUtc: $actualStartUtc, ')
          ..write('actualEndUtc: $actualEndUtc, ')
          ..write('durationFromSteps: $durationFromSteps, ')
          ..write('moveCount: $moveCount, ')
          ..write('routineStart: $routineStart, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubtasksTable extends Subtasks
    with TableInfo<$SubtasksTable, SubtaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubtasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _occurrenceIdMeta = const VerificationMeta(
    'occurrenceId',
  );
  @override
  late final GeneratedColumn<String> occurrenceId = GeneratedColumn<String>(
    'occurrence_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES occurrences (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<double> sortOrder = GeneratedColumn<double>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    true,
    check: () => const CustomExpression<bool>(
      'duration_min IS NULL OR duration_min BETWEEN 1 AND 1440',
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<int> doneAt = GeneratedColumn<int>(
    'done_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    dirty,
    version,
    id,
    userId,
    occurrenceId,
    title,
    done,
    sortOrder,
    durationMin,
    doneAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subtasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubtaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('occurrence_id')) {
      context.handle(
        _occurrenceIdMeta,
        occurrenceId.isAcceptableOrUnknown(
          data['occurrence_id']!,
          _occurrenceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurrenceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubtaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubtaskRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      occurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sort_order'],
      )!,
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      ),
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}done_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SubtasksTable createAlias(String alias) {
    return $SubtasksTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class SubtaskRow extends DataClass implements Insertable<SubtaskRow> {
  final int createdAt;
  final int updatedAt;
  final bool dirty;
  final int version;
  final String id;
  final String userId;
  final String occurrenceId;
  final String title;
  final bool done;
  final double sortOrder;

  /// Schema 3 (M6.5.1, 11 B2): optional step length, 1–1440 min.
  final int? durationMin;

  /// Schema 7 (M13.2, ADR-0012): when it was ticked done, epoch ms.
  final int? doneAt;
  final int? deletedAt;
  const SubtaskRow({
    required this.createdAt,
    required this.updatedAt,
    required this.dirty,
    required this.version,
    required this.id,
    required this.userId,
    required this.occurrenceId,
    required this.title,
    required this.done,
    required this.sortOrder,
    this.durationMin,
    this.doneAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    map['version'] = Variable<int>(version);
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['occurrence_id'] = Variable<String>(occurrenceId);
    map['title'] = Variable<String>(title);
    map['done'] = Variable<bool>(done);
    map['sort_order'] = Variable<double>(sortOrder);
    if (!nullToAbsent || durationMin != null) {
      map['duration_min'] = Variable<int>(durationMin);
    }
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<int>(doneAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  SubtasksCompanion toCompanion(bool nullToAbsent) {
    return SubtasksCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      version: Value(version),
      id: Value(id),
      userId: Value(userId),
      occurrenceId: Value(occurrenceId),
      title: Value(title),
      done: Value(done),
      sortOrder: Value(sortOrder),
      durationMin: durationMin == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMin),
      doneAt: doneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(doneAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SubtaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubtaskRow(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      version: serializer.fromJson<int>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      occurrenceId: serializer.fromJson<String>(json['occurrenceId']),
      title: serializer.fromJson<String>(json['title']),
      done: serializer.fromJson<bool>(json['done']),
      sortOrder: serializer.fromJson<double>(json['sortOrder']),
      durationMin: serializer.fromJson<int?>(json['durationMin']),
      doneAt: serializer.fromJson<int?>(json['doneAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'version': serializer.toJson<int>(version),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'occurrenceId': serializer.toJson<String>(occurrenceId),
      'title': serializer.toJson<String>(title),
      'done': serializer.toJson<bool>(done),
      'sortOrder': serializer.toJson<double>(sortOrder),
      'durationMin': serializer.toJson<int?>(durationMin),
      'doneAt': serializer.toJson<int?>(doneAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  SubtaskRow copyWith({
    int? createdAt,
    int? updatedAt,
    bool? dirty,
    int? version,
    String? id,
    String? userId,
    String? occurrenceId,
    String? title,
    bool? done,
    double? sortOrder,
    Value<int?> durationMin = const Value.absent(),
    Value<int?> doneAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
  }) => SubtaskRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dirty: dirty ?? this.dirty,
    version: version ?? this.version,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    occurrenceId: occurrenceId ?? this.occurrenceId,
    title: title ?? this.title,
    done: done ?? this.done,
    sortOrder: sortOrder ?? this.sortOrder,
    durationMin: durationMin.present ? durationMin.value : this.durationMin,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SubtaskRow copyWithCompanion(SubtasksCompanion data) {
    return SubtaskRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      occurrenceId: data.occurrenceId.present
          ? data.occurrenceId.value
          : this.occurrenceId,
      title: data.title.present ? data.title.value : this.title,
      done: data.done.present ? data.done.value : this.done,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubtaskRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('durationMin: $durationMin, ')
          ..write('doneAt: $doneAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    dirty,
    version,
    id,
    userId,
    occurrenceId,
    title,
    done,
    sortOrder,
    durationMin,
    doneAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubtaskRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.version == this.version &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.occurrenceId == this.occurrenceId &&
          other.title == this.title &&
          other.done == this.done &&
          other.sortOrder == this.sortOrder &&
          other.durationMin == this.durationMin &&
          other.doneAt == this.doneAt &&
          other.deletedAt == this.deletedAt);
}

class SubtasksCompanion extends UpdateCompanion<SubtaskRow> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> dirty;
  final Value<int> version;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> occurrenceId;
  final Value<String> title;
  final Value<bool> done;
  final Value<double> sortOrder;
  final Value<int?> durationMin;
  final Value<int?> doneAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const SubtasksCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.occurrenceId = const Value.absent(),
    this.title = const Value.absent(),
    this.done = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubtasksCompanion.insert({
    required int createdAt,
    required int updatedAt,
    this.dirty = const Value.absent(),
    this.version = const Value.absent(),
    required String id,
    required String userId,
    required String occurrenceId,
    required String title,
    this.done = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       userId = Value(userId),
       occurrenceId = Value(occurrenceId),
       title = Value(title);
  static Insertable<SubtaskRow> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? dirty,
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? occurrenceId,
    Expression<String>? title,
    Expression<bool>? done,
    Expression<double>? sortOrder,
    Expression<int>? durationMin,
    Expression<int>? doneAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (occurrenceId != null) 'occurrence_id': occurrenceId,
      if (title != null) 'title': title,
      if (done != null) 'done': done,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (durationMin != null) 'duration_min': durationMin,
      if (doneAt != null) 'done_at': doneAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubtasksCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? dirty,
    Value<int>? version,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? occurrenceId,
    Value<String>? title,
    Value<bool>? done,
    Value<double>? sortOrder,
    Value<int?>? durationMin,
    Value<int?>? doneAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SubtasksCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      version: version ?? this.version,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      title: title ?? this.title,
      done: done ?? this.done,
      sortOrder: sortOrder ?? this.sortOrder,
      durationMin: durationMin ?? this.durationMin,
      doneAt: doneAt ?? this.doneAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (occurrenceId.present) {
      map['occurrence_id'] = Variable<String>(occurrenceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<double>(sortOrder.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<int>(doneAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubtasksCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('durationMin: $durationMin, ')
          ..write('doneAt: $doneAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTableTable extends RoutinesTable
    with TableInfo<$RoutinesTableTable, RoutineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anchorMeta = const VerificationMeta('anchor');
  @override
  late final GeneratedColumn<String> anchor = GeneratedColumn<String>(
    'anchor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('wake'),
  );
  static const VerificationMeta _anchorMinuteMeta = const VerificationMeta(
    'anchorMinute',
  );
  @override
  late final GeneratedColumn<int> anchorMinute = GeneratedColumn<int>(
    'anchor_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemsMeta = const VerificationMeta('items');
  @override
  late final GeneratedColumn<String> items = GeneratedColumn<String>(
    'items',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<double> sortOrder = GeneratedColumn<double>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    dirty,
    version,
    id,
    userId,
    title,
    anchor,
    anchorMinute,
    items,
    sortOrder,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('anchor')) {
      context.handle(
        _anchorMeta,
        anchor.isAcceptableOrUnknown(data['anchor']!, _anchorMeta),
      );
    }
    if (data.containsKey('anchor_minute')) {
      context.handle(
        _anchorMinuteMeta,
        anchorMinute.isAcceptableOrUnknown(
          data['anchor_minute']!,
          _anchorMinuteMeta,
        ),
      );
    }
    if (data.containsKey('items')) {
      context.handle(
        _itemsMeta,
        items.isAcceptableOrUnknown(data['items']!, _itemsMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      anchor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor'],
      )!,
      anchorMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anchor_minute'],
      ),
      items: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sort_order'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $RoutinesTableTable createAlias(String alias) {
    return $RoutinesTableTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class RoutineRow extends DataClass implements Insertable<RoutineRow> {
  final int createdAt;
  final int updatedAt;
  final bool dirty;
  final int version;
  final String id;
  final String userId;
  final String title;
  final String anchor;
  final int? anchorMinute;

  /// JSON array of steps (camelCase keys, as `series.subtask_template`).
  final String items;
  final double sortOrder;
  final int? deletedAt;
  const RoutineRow({
    required this.createdAt,
    required this.updatedAt,
    required this.dirty,
    required this.version,
    required this.id,
    required this.userId,
    required this.title,
    required this.anchor,
    this.anchorMinute,
    required this.items,
    required this.sortOrder,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    map['version'] = Variable<int>(version);
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['anchor'] = Variable<String>(anchor);
    if (!nullToAbsent || anchorMinute != null) {
      map['anchor_minute'] = Variable<int>(anchorMinute);
    }
    map['items'] = Variable<String>(items);
    map['sort_order'] = Variable<double>(sortOrder);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  RoutinesTableCompanion toCompanion(bool nullToAbsent) {
    return RoutinesTableCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      version: Value(version),
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      anchor: Value(anchor),
      anchorMinute: anchorMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorMinute),
      items: Value(items),
      sortOrder: Value(sortOrder),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory RoutineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineRow(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      version: serializer.fromJson<int>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      anchor: serializer.fromJson<String>(json['anchor']),
      anchorMinute: serializer.fromJson<int?>(json['anchorMinute']),
      items: serializer.fromJson<String>(json['items']),
      sortOrder: serializer.fromJson<double>(json['sortOrder']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'version': serializer.toJson<int>(version),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'anchor': serializer.toJson<String>(anchor),
      'anchorMinute': serializer.toJson<int?>(anchorMinute),
      'items': serializer.toJson<String>(items),
      'sortOrder': serializer.toJson<double>(sortOrder),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  RoutineRow copyWith({
    int? createdAt,
    int? updatedAt,
    bool? dirty,
    int? version,
    String? id,
    String? userId,
    String? title,
    String? anchor,
    Value<int?> anchorMinute = const Value.absent(),
    String? items,
    double? sortOrder,
    Value<int?> deletedAt = const Value.absent(),
  }) => RoutineRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dirty: dirty ?? this.dirty,
    version: version ?? this.version,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    anchor: anchor ?? this.anchor,
    anchorMinute: anchorMinute.present ? anchorMinute.value : this.anchorMinute,
    items: items ?? this.items,
    sortOrder: sortOrder ?? this.sortOrder,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  RoutineRow copyWithCompanion(RoutinesTableCompanion data) {
    return RoutineRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      anchor: data.anchor.present ? data.anchor.value : this.anchor,
      anchorMinute: data.anchorMinute.present
          ? data.anchorMinute.value
          : this.anchorMinute,
      items: data.items.present ? data.items.value : this.items,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('anchor: $anchor, ')
          ..write('anchorMinute: $anchorMinute, ')
          ..write('items: $items, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    dirty,
    version,
    id,
    userId,
    title,
    anchor,
    anchorMinute,
    items,
    sortOrder,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.version == this.version &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.anchor == this.anchor &&
          other.anchorMinute == this.anchorMinute &&
          other.items == this.items &&
          other.sortOrder == this.sortOrder &&
          other.deletedAt == this.deletedAt);
}

class RoutinesTableCompanion extends UpdateCompanion<RoutineRow> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> dirty;
  final Value<int> version;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> anchor;
  final Value<int?> anchorMinute;
  final Value<String> items;
  final Value<double> sortOrder;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const RoutinesTableCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.anchor = const Value.absent(),
    this.anchorMinute = const Value.absent(),
    this.items = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutinesTableCompanion.insert({
    required int createdAt,
    required int updatedAt,
    this.dirty = const Value.absent(),
    this.version = const Value.absent(),
    required String id,
    required String userId,
    required String title,
    this.anchor = const Value.absent(),
    this.anchorMinute = const Value.absent(),
    this.items = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       userId = Value(userId),
       title = Value(title);
  static Insertable<RoutineRow> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? dirty,
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? anchor,
    Expression<int>? anchorMinute,
    Expression<String>? items,
    Expression<double>? sortOrder,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (anchor != null) 'anchor': anchor,
      if (anchorMinute != null) 'anchor_minute': anchorMinute,
      if (items != null) 'items': items,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutinesTableCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? dirty,
    Value<int>? version,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? anchor,
    Value<int?>? anchorMinute,
    Value<String>? items,
    Value<double>? sortOrder,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return RoutinesTableCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      version: version ?? this.version,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      anchor: anchor ?? this.anchor,
      anchorMinute: anchorMinute ?? this.anchorMinute,
      items: items ?? this.items,
      sortOrder: sortOrder ?? this.sortOrder,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (anchor.present) {
      map['anchor'] = Variable<String>(anchor.value);
    }
    if (anchorMinute.present) {
      map['anchor_minute'] = Variable<int>(anchorMinute.value);
    }
    if (items.present) {
      map['items'] = Variable<String>(items.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<double>(sortOrder.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesTableCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('anchor: $anchor, ')
          ..write('anchorMinute: $anchorMinute, ')
          ..write('items: $items, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RevealHintsTableTable extends RevealHintsTable
    with TableInfo<$RevealHintsTableTable, RevealHintRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RevealHintsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _hintIdMeta = const VerificationMeta('hintId');
  @override
  late final GeneratedColumn<String> hintId = GeneratedColumn<String>(
    'hint_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shownCountMeta = const VerificationMeta(
    'shownCount',
  );
  @override
  late final GeneratedColumn<int> shownCount = GeneratedColumn<int>(
    'shown_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastShownUtcMeta = const VerificationMeta(
    'lastShownUtc',
  );
  @override
  late final GeneratedColumn<int> lastShownUtc = GeneratedColumn<int>(
    'last_shown_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dismissedAtUtcMeta = const VerificationMeta(
    'dismissedAtUtc',
  );
  @override
  late final GeneratedColumn<int> dismissedAtUtc = GeneratedColumn<int>(
    'dismissed_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    dirty,
    version,
    id,
    userId,
    hintId,
    shownCount,
    lastShownUtc,
    dismissedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reveal_hints';
  @override
  VerificationContext validateIntegrity(
    Insertable<RevealHintRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('hint_id')) {
      context.handle(
        _hintIdMeta,
        hintId.isAcceptableOrUnknown(data['hint_id']!, _hintIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hintIdMeta);
    }
    if (data.containsKey('shown_count')) {
      context.handle(
        _shownCountMeta,
        shownCount.isAcceptableOrUnknown(data['shown_count']!, _shownCountMeta),
      );
    }
    if (data.containsKey('last_shown_utc')) {
      context.handle(
        _lastShownUtcMeta,
        lastShownUtc.isAcceptableOrUnknown(
          data['last_shown_utc']!,
          _lastShownUtcMeta,
        ),
      );
    }
    if (data.containsKey('dismissed_at_utc')) {
      context.handle(
        _dismissedAtUtcMeta,
        dismissedAtUtc.isAcceptableOrUnknown(
          data['dismissed_at_utc']!,
          _dismissedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RevealHintRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RevealHintRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      hintId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hint_id'],
      )!,
      shownCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shown_count'],
      )!,
      lastShownUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_shown_utc'],
      ),
      dismissedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dismissed_at_utc'],
      ),
    );
  }

  @override
  $RevealHintsTableTable createAlias(String alias) {
    return $RevealHintsTableTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class RevealHintRow extends DataClass implements Insertable<RevealHintRow> {
  final int createdAt;
  final int updatedAt;
  final bool dirty;
  final int version;
  final String id;
  final String userId;
  final String hintId;
  final int shownCount;
  final int? lastShownUtc;
  final int? dismissedAtUtc;
  const RevealHintRow({
    required this.createdAt,
    required this.updatedAt,
    required this.dirty,
    required this.version,
    required this.id,
    required this.userId,
    required this.hintId,
    required this.shownCount,
    this.lastShownUtc,
    this.dismissedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    map['version'] = Variable<int>(version);
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['hint_id'] = Variable<String>(hintId);
    map['shown_count'] = Variable<int>(shownCount);
    if (!nullToAbsent || lastShownUtc != null) {
      map['last_shown_utc'] = Variable<int>(lastShownUtc);
    }
    if (!nullToAbsent || dismissedAtUtc != null) {
      map['dismissed_at_utc'] = Variable<int>(dismissedAtUtc);
    }
    return map;
  }

  RevealHintsTableCompanion toCompanion(bool nullToAbsent) {
    return RevealHintsTableCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      version: Value(version),
      id: Value(id),
      userId: Value(userId),
      hintId: Value(hintId),
      shownCount: Value(shownCount),
      lastShownUtc: lastShownUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastShownUtc),
      dismissedAtUtc: dismissedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(dismissedAtUtc),
    );
  }

  factory RevealHintRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RevealHintRow(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      version: serializer.fromJson<int>(json['version']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      hintId: serializer.fromJson<String>(json['hintId']),
      shownCount: serializer.fromJson<int>(json['shownCount']),
      lastShownUtc: serializer.fromJson<int?>(json['lastShownUtc']),
      dismissedAtUtc: serializer.fromJson<int?>(json['dismissedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'version': serializer.toJson<int>(version),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'hintId': serializer.toJson<String>(hintId),
      'shownCount': serializer.toJson<int>(shownCount),
      'lastShownUtc': serializer.toJson<int?>(lastShownUtc),
      'dismissedAtUtc': serializer.toJson<int?>(dismissedAtUtc),
    };
  }

  RevealHintRow copyWith({
    int? createdAt,
    int? updatedAt,
    bool? dirty,
    int? version,
    String? id,
    String? userId,
    String? hintId,
    int? shownCount,
    Value<int?> lastShownUtc = const Value.absent(),
    Value<int?> dismissedAtUtc = const Value.absent(),
  }) => RevealHintRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dirty: dirty ?? this.dirty,
    version: version ?? this.version,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    hintId: hintId ?? this.hintId,
    shownCount: shownCount ?? this.shownCount,
    lastShownUtc: lastShownUtc.present ? lastShownUtc.value : this.lastShownUtc,
    dismissedAtUtc: dismissedAtUtc.present
        ? dismissedAtUtc.value
        : this.dismissedAtUtc,
  );
  RevealHintRow copyWithCompanion(RevealHintsTableCompanion data) {
    return RevealHintRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      version: data.version.present ? data.version.value : this.version,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      hintId: data.hintId.present ? data.hintId.value : this.hintId,
      shownCount: data.shownCount.present
          ? data.shownCount.value
          : this.shownCount,
      lastShownUtc: data.lastShownUtc.present
          ? data.lastShownUtc.value
          : this.lastShownUtc,
      dismissedAtUtc: data.dismissedAtUtc.present
          ? data.dismissedAtUtc.value
          : this.dismissedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RevealHintRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('hintId: $hintId, ')
          ..write('shownCount: $shownCount, ')
          ..write('lastShownUtc: $lastShownUtc, ')
          ..write('dismissedAtUtc: $dismissedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    dirty,
    version,
    id,
    userId,
    hintId,
    shownCount,
    lastShownUtc,
    dismissedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RevealHintRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.version == this.version &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.hintId == this.hintId &&
          other.shownCount == this.shownCount &&
          other.lastShownUtc == this.lastShownUtc &&
          other.dismissedAtUtc == this.dismissedAtUtc);
}

class RevealHintsTableCompanion extends UpdateCompanion<RevealHintRow> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> dirty;
  final Value<int> version;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> hintId;
  final Value<int> shownCount;
  final Value<int?> lastShownUtc;
  final Value<int?> dismissedAtUtc;
  final Value<int> rowid;
  const RevealHintsTableCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.version = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.hintId = const Value.absent(),
    this.shownCount = const Value.absent(),
    this.lastShownUtc = const Value.absent(),
    this.dismissedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RevealHintsTableCompanion.insert({
    required int createdAt,
    required int updatedAt,
    this.dirty = const Value.absent(),
    this.version = const Value.absent(),
    required String id,
    required String userId,
    required String hintId,
    this.shownCount = const Value.absent(),
    this.lastShownUtc = const Value.absent(),
    this.dismissedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       userId = Value(userId),
       hintId = Value(hintId);
  static Insertable<RevealHintRow> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? dirty,
    Expression<int>? version,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? hintId,
    Expression<int>? shownCount,
    Expression<int>? lastShownUtc,
    Expression<int>? dismissedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (version != null) 'version': version,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (hintId != null) 'hint_id': hintId,
      if (shownCount != null) 'shown_count': shownCount,
      if (lastShownUtc != null) 'last_shown_utc': lastShownUtc,
      if (dismissedAtUtc != null) 'dismissed_at_utc': dismissedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RevealHintsTableCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? dirty,
    Value<int>? version,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? hintId,
    Value<int>? shownCount,
    Value<int?>? lastShownUtc,
    Value<int?>? dismissedAtUtc,
    Value<int>? rowid,
  }) {
    return RevealHintsTableCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      version: version ?? this.version,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hintId: hintId ?? this.hintId,
      shownCount: shownCount ?? this.shownCount,
      lastShownUtc: lastShownUtc ?? this.lastShownUtc,
      dismissedAtUtc: dismissedAtUtc ?? this.dismissedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (hintId.present) {
      map['hint_id'] = Variable<String>(hintId.value);
    }
    if (shownCount.present) {
      map['shown_count'] = Variable<int>(shownCount.value);
    }
    if (lastShownUtc.present) {
      map['last_shown_utc'] = Variable<int>(lastShownUtc.value);
    }
    if (dismissedAtUtc.present) {
      map['dismissed_at_utc'] = Variable<int>(dismissedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RevealHintsTableCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('version: $version, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('hintId: $hintId, ')
          ..write('shownCount: $shownCount, ')
          ..write('lastShownUtc: $lastShownUtc, ')
          ..write('dismissedAtUtc: $dismissedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConflictsTable extends Conflicts
    with TableInfo<$ConflictsTable, ConflictRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mineMeta = const VerificationMeta('mine');
  @override
  late final GeneratedColumn<String> mine = GeneratedColumn<String>(
    'mine',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _theirsMeta = const VerificationMeta('theirs');
  @override
  late final GeneratedColumn<String> theirs = GeneratedColumn<String>(
    'theirs',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<int> resolvedAt = GeneratedColumn<int>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    entity,
    entityId,
    field,
    mine,
    theirs,
    createdAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConflictRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('mine')) {
      context.handle(
        _mineMeta,
        mine.isAcceptableOrUnknown(data['mine']!, _mineMeta),
      );
    }
    if (data.containsKey('theirs')) {
      context.handle(
        _theirsMeta,
        theirs.isAcceptableOrUnknown(data['theirs']!, _theirsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConflictRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConflictRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      mine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mine'],
      ),
      theirs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theirs'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $ConflictsTable createAlias(String alias) {
    return $ConflictsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class ConflictRow extends DataClass implements Insertable<ConflictRow> {
  final String id;
  final String userId;
  final String entity;
  final String entityId;
  final String field;

  /// JSON-encoded field values (`null` allowed).
  final String? mine;
  final String? theirs;
  final int createdAt;
  final int? resolvedAt;
  const ConflictRow({
    required this.id,
    required this.userId,
    required this.entity,
    required this.entityId,
    required this.field,
    this.mine,
    this.theirs,
    required this.createdAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['field'] = Variable<String>(field);
    if (!nullToAbsent || mine != null) {
      map['mine'] = Variable<String>(mine);
    }
    if (!nullToAbsent || theirs != null) {
      map['theirs'] = Variable<String>(theirs);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<int>(resolvedAt);
    }
    return map;
  }

  ConflictsCompanion toCompanion(bool nullToAbsent) {
    return ConflictsCompanion(
      id: Value(id),
      userId: Value(userId),
      entity: Value(entity),
      entityId: Value(entityId),
      field: Value(field),
      mine: mine == null && nullToAbsent ? const Value.absent() : Value(mine),
      theirs: theirs == null && nullToAbsent
          ? const Value.absent()
          : Value(theirs),
      createdAt: Value(createdAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory ConflictRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConflictRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      field: serializer.fromJson<String>(json['field']),
      mine: serializer.fromJson<String?>(json['mine']),
      theirs: serializer.fromJson<String?>(json['theirs']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      resolvedAt: serializer.fromJson<int?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'field': serializer.toJson<String>(field),
      'mine': serializer.toJson<String?>(mine),
      'theirs': serializer.toJson<String?>(theirs),
      'createdAt': serializer.toJson<int>(createdAt),
      'resolvedAt': serializer.toJson<int?>(resolvedAt),
    };
  }

  ConflictRow copyWith({
    String? id,
    String? userId,
    String? entity,
    String? entityId,
    String? field,
    Value<String?> mine = const Value.absent(),
    Value<String?> theirs = const Value.absent(),
    int? createdAt,
    Value<int?> resolvedAt = const Value.absent(),
  }) => ConflictRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    field: field ?? this.field,
    mine: mine.present ? mine.value : this.mine,
    theirs: theirs.present ? theirs.value : this.theirs,
    createdAt: createdAt ?? this.createdAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  ConflictRow copyWithCompanion(ConflictsCompanion data) {
    return ConflictRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      field: data.field.present ? data.field.value : this.field,
      mine: data.mine.present ? data.mine.value : this.mine,
      theirs: data.theirs.present ? data.theirs.value : this.theirs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConflictRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('mine: $mine, ')
          ..write('theirs: $theirs, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    entity,
    entityId,
    field,
    mine,
    theirs,
    createdAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConflictRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.field == this.field &&
          other.mine == this.mine &&
          other.theirs == this.theirs &&
          other.createdAt == this.createdAt &&
          other.resolvedAt == this.resolvedAt);
}

class ConflictsCompanion extends UpdateCompanion<ConflictRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> field;
  final Value<String?> mine;
  final Value<String?> theirs;
  final Value<int> createdAt;
  final Value<int?> resolvedAt;
  final Value<int> rowid;
  const ConflictsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.field = const Value.absent(),
    this.mine = const Value.absent(),
    this.theirs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConflictsCompanion.insert({
    required String id,
    required String userId,
    required String entity,
    required String entityId,
    required String field,
    this.mine = const Value.absent(),
    this.theirs = const Value.absent(),
    required int createdAt,
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       entity = Value(entity),
       entityId = Value(entityId),
       field = Value(field),
       createdAt = Value(createdAt);
  static Insertable<ConflictRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? field,
    Expression<String>? mine,
    Expression<String>? theirs,
    Expression<int>? createdAt,
    Expression<int>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (field != null) 'field': field,
      if (mine != null) 'mine': mine,
      if (theirs != null) 'theirs': theirs,
      if (createdAt != null) 'created_at': createdAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? field,
    Value<String?>? mine,
    Value<String?>? theirs,
    Value<int>? createdAt,
    Value<int?>? resolvedAt,
    Value<int>? rowid,
  }) {
    return ConflictsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      field: field ?? this.field,
      mine: mine ?? this.mine,
      theirs: theirs ?? this.theirs,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (mine.present) {
      map['mine'] = Variable<String>(mine.value);
    }
    if (theirs.present) {
      map['theirs'] = Variable<String>(theirs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<int>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConflictsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('mine: $mine, ')
          ..write('theirs: $theirs, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChangeLogTable extends ChangeLog
    with TableInfo<$ChangeLogTable, ChangeLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChangeLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    entity,
    entityId,
    field,
    value,
    hlc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'change_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChangeLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  ChangeLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChangeLogRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
    );
  }

  @override
  $ChangeLogTable createAlias(String alias) {
    return $ChangeLogTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class ChangeLogRow extends DataClass implements Insertable<ChangeLogRow> {
  final int seq;
  final String entity;
  final String entityId;
  final String field;

  /// JSON-encoded new value of [field].
  final String value;

  /// Fixed-width HLC string (`Hlc`, ADR-0002); string order = clock order.
  final String hlc;
  const ChangeLogRow({
    required this.seq,
    required this.entity,
    required this.entityId,
    required this.field,
    required this.value,
    required this.hlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['field'] = Variable<String>(field);
    map['value'] = Variable<String>(value);
    map['hlc'] = Variable<String>(hlc);
    return map;
  }

  ChangeLogCompanion toCompanion(bool nullToAbsent) {
    return ChangeLogCompanion(
      seq: Value(seq),
      entity: Value(entity),
      entityId: Value(entityId),
      field: Value(field),
      value: Value(value),
      hlc: Value(hlc),
    );
  }

  factory ChangeLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChangeLogRow(
      seq: serializer.fromJson<int>(json['seq']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      field: serializer.fromJson<String>(json['field']),
      value: serializer.fromJson<String>(json['value']),
      hlc: serializer.fromJson<String>(json['hlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'field': serializer.toJson<String>(field),
      'value': serializer.toJson<String>(value),
      'hlc': serializer.toJson<String>(hlc),
    };
  }

  ChangeLogRow copyWith({
    int? seq,
    String? entity,
    String? entityId,
    String? field,
    String? value,
    String? hlc,
  }) => ChangeLogRow(
    seq: seq ?? this.seq,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    field: field ?? this.field,
    value: value ?? this.value,
    hlc: hlc ?? this.hlc,
  );
  ChangeLogRow copyWithCompanion(ChangeLogCompanion data) {
    return ChangeLogRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      field: data.field.present ? data.field.value : this.field,
      value: data.value.present ? data.value.value : this.value,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLogRow(')
          ..write('seq: $seq, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('value: $value, ')
          ..write('hlc: $hlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seq, entity, entityId, field, value, hlc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeLogRow &&
          other.seq == this.seq &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.field == this.field &&
          other.value == this.value &&
          other.hlc == this.hlc);
}

class ChangeLogCompanion extends UpdateCompanion<ChangeLogRow> {
  final Value<int> seq;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> field;
  final Value<String> value;
  final Value<String> hlc;
  const ChangeLogCompanion({
    this.seq = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.field = const Value.absent(),
    this.value = const Value.absent(),
    this.hlc = const Value.absent(),
  });
  ChangeLogCompanion.insert({
    this.seq = const Value.absent(),
    required String entity,
    required String entityId,
    required String field,
    required String value,
    required String hlc,
  }) : entity = Value(entity),
       entityId = Value(entityId),
       field = Value(field),
       value = Value(value),
       hlc = Value(hlc);
  static Insertable<ChangeLogRow> custom({
    Expression<int>? seq,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? field,
    Expression<String>? value,
    Expression<String>? hlc,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (field != null) 'field': field,
      if (value != null) 'value': value,
      if (hlc != null) 'hlc': hlc,
    });
  }

  ChangeLogCompanion copyWith({
    Value<int>? seq,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? field,
    Value<String>? value,
    Value<String>? hlc,
  }) {
    return ChangeLogCompanion(
      seq: seq ?? this.seq,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      field: field ?? this.field,
      value: value ?? this.value,
      hlc: hlc ?? this.hlc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLogCompanion(')
          ..write('seq: $seq, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('value: $value, ')
          ..write('hlc: $hlc')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sinceUtcMeta = const VerificationMeta(
    'sinceUtc',
  );
  @override
  late final GeneratedColumn<int> sinceUtc = GeneratedColumn<int>(
    'since_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entity, sinceUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('since_utc')) {
      context.handle(
        _sinceUtcMeta,
        sinceUtc.isAcceptableOrUnknown(data['since_utc']!, _sinceUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_sinceUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity};
  @override
  SyncCursorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorRow(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      sinceUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}since_utc'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class SyncCursorRow extends DataClass implements Insertable<SyncCursorRow> {
  final String entity;
  final int sinceUtc;
  const SyncCursorRow({required this.entity, required this.sinceUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['since_utc'] = Variable<int>(sinceUtc);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      entity: Value(entity),
      sinceUtc: Value(sinceUtc),
    );
  }

  factory SyncCursorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorRow(
      entity: serializer.fromJson<String>(json['entity']),
      sinceUtc: serializer.fromJson<int>(json['sinceUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'sinceUtc': serializer.toJson<int>(sinceUtc),
    };
  }

  SyncCursorRow copyWith({String? entity, int? sinceUtc}) => SyncCursorRow(
    entity: entity ?? this.entity,
    sinceUtc: sinceUtc ?? this.sinceUtc,
  );
  SyncCursorRow copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursorRow(
      entity: data.entity.present ? data.entity.value : this.entity,
      sinceUtc: data.sinceUtc.present ? data.sinceUtc.value : this.sinceUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorRow(')
          ..write('entity: $entity, ')
          ..write('sinceUtc: $sinceUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, sinceUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorRow &&
          other.entity == this.entity &&
          other.sinceUtc == this.sinceUtc);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursorRow> {
  final Value<String> entity;
  final Value<int> sinceUtc;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.entity = const Value.absent(),
    this.sinceUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String entity,
    required int sinceUtc,
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       sinceUtc = Value(sinceUtc);
  static Insertable<SyncCursorRow> custom({
    Expression<String>? entity,
    Expression<int>? sinceUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (sinceUtc != null) 'since_utc': sinceUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? entity,
    Value<int>? sinceUtc,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      entity: entity ?? this.entity,
      sinceUtc: sinceUtc ?? this.sinceUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (sinceUtc.present) {
      map['since_utc'] = Variable<int>(sinceUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('entity: $entity, ')
          ..write('sinceUtc: $sinceUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FieldSeenTable extends FieldSeen
    with TableInfo<$FieldSeenTable, FieldSeenRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FieldSeenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entity, entityId, field, hlc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'field_seen';
  @override
  VerificationContext validateIntegrity(
    Insertable<FieldSeenRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity, entityId, field};
  @override
  FieldSeenRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FieldSeenRow(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
    );
  }

  @override
  $FieldSeenTable createAlias(String alias) {
    return $FieldSeenTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class FieldSeenRow extends DataClass implements Insertable<FieldSeenRow> {
  final String entity;
  final String entityId;
  final String field;
  final String hlc;
  const FieldSeenRow({
    required this.entity,
    required this.entityId,
    required this.field,
    required this.hlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['field'] = Variable<String>(field);
    map['hlc'] = Variable<String>(hlc);
    return map;
  }

  FieldSeenCompanion toCompanion(bool nullToAbsent) {
    return FieldSeenCompanion(
      entity: Value(entity),
      entityId: Value(entityId),
      field: Value(field),
      hlc: Value(hlc),
    );
  }

  factory FieldSeenRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FieldSeenRow(
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      field: serializer.fromJson<String>(json['field']),
      hlc: serializer.fromJson<String>(json['hlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'field': serializer.toJson<String>(field),
      'hlc': serializer.toJson<String>(hlc),
    };
  }

  FieldSeenRow copyWith({
    String? entity,
    String? entityId,
    String? field,
    String? hlc,
  }) => FieldSeenRow(
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    field: field ?? this.field,
    hlc: hlc ?? this.hlc,
  );
  FieldSeenRow copyWithCompanion(FieldSeenCompanion data) {
    return FieldSeenRow(
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      field: data.field.present ? data.field.value : this.field,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FieldSeenRow(')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('hlc: $hlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, entityId, field, hlc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FieldSeenRow &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.field == this.field &&
          other.hlc == this.hlc);
}

class FieldSeenCompanion extends UpdateCompanion<FieldSeenRow> {
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> field;
  final Value<String> hlc;
  final Value<int> rowid;
  const FieldSeenCompanion({
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.field = const Value.absent(),
    this.hlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FieldSeenCompanion.insert({
    required String entity,
    required String entityId,
    required String field,
    required String hlc,
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       entityId = Value(entityId),
       field = Value(field),
       hlc = Value(hlc);
  static Insertable<FieldSeenRow> custom({
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? field,
    Expression<String>? hlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (field != null) 'field': field,
      if (hlc != null) 'hlc': hlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FieldSeenCompanion copyWith({
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? field,
    Value<String>? hlc,
    Value<int>? rowid,
  }) {
    return FieldSeenCompanion(
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      field: field ?? this.field,
      hlc: hlc ?? this.hlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FieldSeenCompanion(')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('hlc: $hlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMetaTable extends LocalMeta
    with TableInfo<$LocalMetaTable, LocalMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $LocalMetaTable createAlias(String alias) {
    return $LocalMetaTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class LocalMetaRow extends DataClass implements Insertable<LocalMetaRow> {
  final String key;
  final String value;
  const LocalMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LocalMetaCompanion toCompanion(bool nullToAbsent) {
    return LocalMetaCompanion(key: Value(key), value: Value(value));
  }

  factory LocalMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  LocalMetaRow copyWith({String? key, String? value}) =>
      LocalMetaRow(key: key ?? this.key, value: value ?? this.value);
  LocalMetaRow copyWithCompanion(LocalMetaCompanion data) {
    return LocalMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class LocalMetaCompanion extends UpdateCompanion<LocalMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LocalMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<LocalMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return LocalMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WakeUpDaysTableTable extends WakeUpDaysTable
    with TableInfo<$WakeUpDaysTableTable, WakeUpDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WakeUpDaysTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rangAtUtcMeta = const VerificationMeta(
    'rangAtUtc',
  );
  @override
  late final GeneratedColumn<int> rangAtUtc = GeneratedColumn<int>(
    'rang_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stoppedAtUtcMeta = const VerificationMeta(
    'stoppedAtUtc',
  );
  @override
  late final GeneratedColumn<int> stoppedAtUtc = GeneratedColumn<int>(
    'stopped_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozesMeta = const VerificationMeta(
    'snoozes',
  );
  @override
  late final GeneratedColumn<int> snoozes = GeneratedColumn<int>(
    'snoozes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cardShownAtUtcMeta = const VerificationMeta(
    'cardShownAtUtc',
  );
  @override
  late final GeneratedColumn<int> cardShownAtUtc = GeneratedColumn<int>(
    'card_shown_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtUtcMeta = const VerificationMeta(
    'startedAtUtc',
  );
  @override
  late final GeneratedColumn<int> startedAtUtc = GeneratedColumn<int>(
    'started_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    rangAtUtc,
    stoppedAtUtc,
    snoozes,
    cardShownAtUtc,
    startedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wake_up_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<WakeUpDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('rang_at_utc')) {
      context.handle(
        _rangAtUtcMeta,
        rangAtUtc.isAcceptableOrUnknown(data['rang_at_utc']!, _rangAtUtcMeta),
      );
    }
    if (data.containsKey('stopped_at_utc')) {
      context.handle(
        _stoppedAtUtcMeta,
        stoppedAtUtc.isAcceptableOrUnknown(
          data['stopped_at_utc']!,
          _stoppedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('snoozes')) {
      context.handle(
        _snoozesMeta,
        snoozes.isAcceptableOrUnknown(data['snoozes']!, _snoozesMeta),
      );
    }
    if (data.containsKey('card_shown_at_utc')) {
      context.handle(
        _cardShownAtUtcMeta,
        cardShownAtUtc.isAcceptableOrUnknown(
          data['card_shown_at_utc']!,
          _cardShownAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('started_at_utc')) {
      context.handle(
        _startedAtUtcMeta,
        startedAtUtc.isAcceptableOrUnknown(
          data['started_at_utc']!,
          _startedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  WakeUpDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WakeUpDayRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      rangAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rang_at_utc'],
      ),
      stoppedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stopped_at_utc'],
      ),
      snoozes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snoozes'],
      )!,
      cardShownAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_shown_at_utc'],
      ),
      startedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_utc'],
      ),
    );
  }

  @override
  $WakeUpDaysTableTable createAlias(String alias) {
    return $WakeUpDaysTableTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class WakeUpDayRow extends DataClass implements Insertable<WakeUpDayRow> {
  /// `yyyy-MM-dd` in the profile's zone.
  final String date;
  final int? rangAtUtc;
  final int? stoppedAtUtc;
  final int snoozes;
  final int? cardShownAtUtc;
  final int? startedAtUtc;
  const WakeUpDayRow({
    required this.date,
    this.rangAtUtc,
    this.stoppedAtUtc,
    required this.snoozes,
    this.cardShownAtUtc,
    this.startedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || rangAtUtc != null) {
      map['rang_at_utc'] = Variable<int>(rangAtUtc);
    }
    if (!nullToAbsent || stoppedAtUtc != null) {
      map['stopped_at_utc'] = Variable<int>(stoppedAtUtc);
    }
    map['snoozes'] = Variable<int>(snoozes);
    if (!nullToAbsent || cardShownAtUtc != null) {
      map['card_shown_at_utc'] = Variable<int>(cardShownAtUtc);
    }
    if (!nullToAbsent || startedAtUtc != null) {
      map['started_at_utc'] = Variable<int>(startedAtUtc);
    }
    return map;
  }

  WakeUpDaysTableCompanion toCompanion(bool nullToAbsent) {
    return WakeUpDaysTableCompanion(
      date: Value(date),
      rangAtUtc: rangAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(rangAtUtc),
      stoppedAtUtc: stoppedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(stoppedAtUtc),
      snoozes: Value(snoozes),
      cardShownAtUtc: cardShownAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(cardShownAtUtc),
      startedAtUtc: startedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAtUtc),
    );
  }

  factory WakeUpDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WakeUpDayRow(
      date: serializer.fromJson<String>(json['date']),
      rangAtUtc: serializer.fromJson<int?>(json['rangAtUtc']),
      stoppedAtUtc: serializer.fromJson<int?>(json['stoppedAtUtc']),
      snoozes: serializer.fromJson<int>(json['snoozes']),
      cardShownAtUtc: serializer.fromJson<int?>(json['cardShownAtUtc']),
      startedAtUtc: serializer.fromJson<int?>(json['startedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'rangAtUtc': serializer.toJson<int?>(rangAtUtc),
      'stoppedAtUtc': serializer.toJson<int?>(stoppedAtUtc),
      'snoozes': serializer.toJson<int>(snoozes),
      'cardShownAtUtc': serializer.toJson<int?>(cardShownAtUtc),
      'startedAtUtc': serializer.toJson<int?>(startedAtUtc),
    };
  }

  WakeUpDayRow copyWith({
    String? date,
    Value<int?> rangAtUtc = const Value.absent(),
    Value<int?> stoppedAtUtc = const Value.absent(),
    int? snoozes,
    Value<int?> cardShownAtUtc = const Value.absent(),
    Value<int?> startedAtUtc = const Value.absent(),
  }) => WakeUpDayRow(
    date: date ?? this.date,
    rangAtUtc: rangAtUtc.present ? rangAtUtc.value : this.rangAtUtc,
    stoppedAtUtc: stoppedAtUtc.present ? stoppedAtUtc.value : this.stoppedAtUtc,
    snoozes: snoozes ?? this.snoozes,
    cardShownAtUtc: cardShownAtUtc.present
        ? cardShownAtUtc.value
        : this.cardShownAtUtc,
    startedAtUtc: startedAtUtc.present ? startedAtUtc.value : this.startedAtUtc,
  );
  WakeUpDayRow copyWithCompanion(WakeUpDaysTableCompanion data) {
    return WakeUpDayRow(
      date: data.date.present ? data.date.value : this.date,
      rangAtUtc: data.rangAtUtc.present ? data.rangAtUtc.value : this.rangAtUtc,
      stoppedAtUtc: data.stoppedAtUtc.present
          ? data.stoppedAtUtc.value
          : this.stoppedAtUtc,
      snoozes: data.snoozes.present ? data.snoozes.value : this.snoozes,
      cardShownAtUtc: data.cardShownAtUtc.present
          ? data.cardShownAtUtc.value
          : this.cardShownAtUtc,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WakeUpDayRow(')
          ..write('date: $date, ')
          ..write('rangAtUtc: $rangAtUtc, ')
          ..write('stoppedAtUtc: $stoppedAtUtc, ')
          ..write('snoozes: $snoozes, ')
          ..write('cardShownAtUtc: $cardShownAtUtc, ')
          ..write('startedAtUtc: $startedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    rangAtUtc,
    stoppedAtUtc,
    snoozes,
    cardShownAtUtc,
    startedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WakeUpDayRow &&
          other.date == this.date &&
          other.rangAtUtc == this.rangAtUtc &&
          other.stoppedAtUtc == this.stoppedAtUtc &&
          other.snoozes == this.snoozes &&
          other.cardShownAtUtc == this.cardShownAtUtc &&
          other.startedAtUtc == this.startedAtUtc);
}

class WakeUpDaysTableCompanion extends UpdateCompanion<WakeUpDayRow> {
  final Value<String> date;
  final Value<int?> rangAtUtc;
  final Value<int?> stoppedAtUtc;
  final Value<int> snoozes;
  final Value<int?> cardShownAtUtc;
  final Value<int?> startedAtUtc;
  final Value<int> rowid;
  const WakeUpDaysTableCompanion({
    this.date = const Value.absent(),
    this.rangAtUtc = const Value.absent(),
    this.stoppedAtUtc = const Value.absent(),
    this.snoozes = const Value.absent(),
    this.cardShownAtUtc = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WakeUpDaysTableCompanion.insert({
    required String date,
    this.rangAtUtc = const Value.absent(),
    this.stoppedAtUtc = const Value.absent(),
    this.snoozes = const Value.absent(),
    this.cardShownAtUtc = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<WakeUpDayRow> custom({
    Expression<String>? date,
    Expression<int>? rangAtUtc,
    Expression<int>? stoppedAtUtc,
    Expression<int>? snoozes,
    Expression<int>? cardShownAtUtc,
    Expression<int>? startedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (rangAtUtc != null) 'rang_at_utc': rangAtUtc,
      if (stoppedAtUtc != null) 'stopped_at_utc': stoppedAtUtc,
      if (snoozes != null) 'snoozes': snoozes,
      if (cardShownAtUtc != null) 'card_shown_at_utc': cardShownAtUtc,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WakeUpDaysTableCompanion copyWith({
    Value<String>? date,
    Value<int?>? rangAtUtc,
    Value<int?>? stoppedAtUtc,
    Value<int>? snoozes,
    Value<int?>? cardShownAtUtc,
    Value<int?>? startedAtUtc,
    Value<int>? rowid,
  }) {
    return WakeUpDaysTableCompanion(
      date: date ?? this.date,
      rangAtUtc: rangAtUtc ?? this.rangAtUtc,
      stoppedAtUtc: stoppedAtUtc ?? this.stoppedAtUtc,
      snoozes: snoozes ?? this.snoozes,
      cardShownAtUtc: cardShownAtUtc ?? this.cardShownAtUtc,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (rangAtUtc.present) {
      map['rang_at_utc'] = Variable<int>(rangAtUtc.value);
    }
    if (stoppedAtUtc.present) {
      map['stopped_at_utc'] = Variable<int>(stoppedAtUtc.value);
    }
    if (snoozes.present) {
      map['snoozes'] = Variable<int>(snoozes.value);
    }
    if (cardShownAtUtc.present) {
      map['card_shown_at_utc'] = Variable<int>(cardShownAtUtc.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<int>(startedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WakeUpDaysTableCompanion(')
          ..write('date: $date, ')
          ..write('rangAtUtc: $rangAtUtc, ')
          ..write('stoppedAtUtc: $stoppedAtUtc, ')
          ..write('snoozes: $snoozes, ')
          ..write('cardShownAtUtc: $cardShownAtUtc, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final SearchIndex searchIndex = SearchIndex(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $SeriesTableTable seriesTable = $SeriesTableTable(this);
  late final $CalendarAccountsTable calendarAccounts = $CalendarAccountsTable(
    this,
  );
  late final $CalendarLinksTable calendarLinks = $CalendarLinksTable(this);
  late final $OccurrencesTable occurrences = $OccurrencesTable(this);
  late final $SubtasksTable subtasks = $SubtasksTable(this);
  late final Trigger searchOccurrenceInsert = Trigger(
    'CREATE TRIGGER search_occurrence_insert AFTER INSERT ON occurrences WHEN new.deleted_at IS NULL BEGIN INSERT INTO search_index ("rowid", user_id, title, notes, subtasks) VALUES (new."rowid", new.user_id, new.title, coalesce(new.notes, \'\'), (SELECT coalesce(group_concat(title, \' \'), \'\') FROM subtasks WHERE occurrence_id = new.id AND deleted_at IS NULL));END',
    'search_occurrence_insert',
  );
  late final Trigger searchOccurrenceUpdate = Trigger(
    'CREATE TRIGGER search_occurrence_update AFTER UPDATE OF title, notes, deleted_at, user_id ON occurrences BEGIN DELETE FROM search_index WHERE "rowid" = old."rowid";INSERT INTO search_index ("rowid", user_id, title, notes, subtasks) SELECT new."rowid", new.user_id, new.title, coalesce(new.notes, \'\'), (SELECT coalesce(group_concat(title, \' \'), \'\') FROM subtasks WHERE occurrence_id = new.id AND deleted_at IS NULL) WHERE new.deleted_at IS NULL;END',
    'search_occurrence_update',
  );
  late final Trigger searchOccurrenceDelete = Trigger(
    'CREATE TRIGGER search_occurrence_delete AFTER DELETE ON occurrences BEGIN DELETE FROM search_index WHERE "rowid" = old."rowid";END',
    'search_occurrence_delete',
  );
  late final Trigger searchSubtaskInsert = Trigger(
    'CREATE TRIGGER search_subtask_insert AFTER INSERT ON subtasks BEGIN UPDATE search_index SET subtasks = (SELECT coalesce(group_concat(title, \' \'), \'\') FROM subtasks WHERE occurrence_id = new.occurrence_id AND deleted_at IS NULL) WHERE "rowid" = (SELECT "rowid" FROM occurrences WHERE id = new.occurrence_id);END',
    'search_subtask_insert',
  );
  late final Trigger searchSubtaskUpdate = Trigger(
    'CREATE TRIGGER search_subtask_update AFTER UPDATE OF title, deleted_at ON subtasks BEGIN UPDATE search_index SET subtasks = (SELECT coalesce(group_concat(title, \' \'), \'\') FROM subtasks WHERE occurrence_id = new.occurrence_id AND deleted_at IS NULL) WHERE "rowid" = (SELECT "rowid" FROM occurrences WHERE id = new.occurrence_id);END',
    'search_subtask_update',
  );
  late final Trigger searchSubtaskDelete = Trigger(
    'CREATE TRIGGER search_subtask_delete AFTER DELETE ON subtasks BEGIN UPDATE search_index SET subtasks = (SELECT coalesce(group_concat(title, \' \'), \'\') FROM subtasks WHERE occurrence_id = old.occurrence_id AND deleted_at IS NULL) WHERE "rowid" = (SELECT "rowid" FROM occurrences WHERE id = old.occurrence_id);END',
    'search_subtask_delete',
  );
  late final Index occurrencesUserStart = Index(
    'occurrences_user_start',
    'CREATE INDEX occurrences_user_start ON occurrences (user_id, start_utc)',
  );
  late final Index occurrencesUserUpdated = Index(
    'occurrences_user_updated',
    'CREATE INDEX occurrences_user_updated ON occurrences (user_id, updated_at)',
  );
  late final Index occurrencesSeriesOriginal = Index(
    'occurrences_series_original',
    'CREATE UNIQUE INDEX occurrences_series_original ON occurrences (user_id, series_id, original_start_utc)',
  );
  late final Index occurrencesUserDeleted = Index(
    'occurrences_user_deleted',
    'CREATE INDEX occurrences_user_deleted ON occurrences (user_id, deleted_at) WHERE deleted_at IS NOT NULL',
  );
  late final Index occurrencesInbox = Index(
    'occurrences_inbox',
    'CREATE INDEX occurrences_inbox ON occurrences (user_id, sort_order) WHERE start_utc IS NULL AND deleted_at IS NULL',
  );
  late final Index occurrencesDirty = Index(
    'occurrences_dirty',
    'CREATE INDEX occurrences_dirty ON occurrences (dirty) WHERE dirty = 1',
  );
  late final Index subtasksOccurrence = Index(
    'subtasks_occurrence',
    'CREATE INDEX subtasks_occurrence ON subtasks (occurrence_id)',
  );
  late final Index subtasksUserUpdated = Index(
    'subtasks_user_updated',
    'CREATE INDEX subtasks_user_updated ON subtasks (user_id, updated_at)',
  );
  late final Index subtasksDirty = Index(
    'subtasks_dirty',
    'CREATE INDEX subtasks_dirty ON subtasks (dirty) WHERE dirty = 1',
  );
  late final Index seriesUser = Index(
    'series_user',
    'CREATE INDEX series_user ON series (user_id)',
  );
  late final Index seriesUserUpdated = Index(
    'series_user_updated',
    'CREATE INDEX series_user_updated ON series (user_id, updated_at)',
  );
  late final Index seriesDirty = Index(
    'series_dirty',
    'CREATE INDEX series_dirty ON series (dirty) WHERE dirty = 1',
  );
  late final Index calendarAccountsUserUpdated = Index(
    'calendar_accounts_user_updated',
    'CREATE INDEX calendar_accounts_user_updated ON calendar_accounts (user_id, updated_at)',
  );
  late final Index calendarLinksUserEvent = Index(
    'calendar_links_user_event',
    'CREATE INDEX calendar_links_user_event ON calendar_links (user_id, external_event_id)',
  );
  late final Index calendarLinksAccountEvent = Index(
    'calendar_links_account_event',
    'CREATE UNIQUE INDEX calendar_links_account_event ON calendar_links (user_id, account_id, external_event_id)',
  );
  late final $RoutinesTableTable routinesTable = $RoutinesTableTable(this);
  late final $RevealHintsTableTable revealHintsTable = $RevealHintsTableTable(
    this,
  );
  late final $ConflictsTable conflicts = $ConflictsTable(this);
  late final $ChangeLogTable changeLog = $ChangeLogTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $FieldSeenTable fieldSeen = $FieldSeenTable(this);
  late final $LocalMetaTable localMeta = $LocalMetaTable(this);
  late final $WakeUpDaysTableTable wakeUpDaysTable = $WakeUpDaysTableTable(
    this,
  );
  late final Index routinesUser = Index(
    'routines_user',
    'CREATE INDEX routines_user ON routines (user_id)',
  );
  late final Index routinesUserUpdated = Index(
    'routines_user_updated',
    'CREATE INDEX routines_user_updated ON routines (user_id, updated_at)',
  );
  late final Index routinesDirty = Index(
    'routines_dirty',
    'CREATE INDEX routines_dirty ON routines (dirty) WHERE dirty = 1',
  );
  late final Index revealHintsUser = Index(
    'reveal_hints_user',
    'CREATE INDEX reveal_hints_user ON reveal_hints (user_id)',
  );
  late final Index revealHintsDirty = Index(
    'reveal_hints_dirty',
    'CREATE INDEX reveal_hints_dirty ON reveal_hints (dirty) WHERE dirty = 1',
  );
  late final Index conflictsOpen = Index(
    'conflicts_open',
    'CREATE INDEX conflicts_open ON conflicts (user_id) WHERE resolved_at IS NULL',
  );
  late final Index changeLogEntity = Index(
    'change_log_entity',
    'CREATE INDEX change_log_entity ON change_log (entity, entity_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    searchIndex,
    profiles,
    seriesTable,
    calendarAccounts,
    calendarLinks,
    occurrences,
    subtasks,
    searchOccurrenceInsert,
    searchOccurrenceUpdate,
    searchOccurrenceDelete,
    searchSubtaskInsert,
    searchSubtaskUpdate,
    searchSubtaskDelete,
    occurrencesUserStart,
    occurrencesUserUpdated,
    occurrencesSeriesOriginal,
    occurrencesUserDeleted,
    occurrencesInbox,
    occurrencesDirty,
    subtasksOccurrence,
    subtasksUserUpdated,
    subtasksDirty,
    seriesUser,
    seriesUserUpdated,
    seriesDirty,
    calendarAccountsUserUpdated,
    calendarLinksUserEvent,
    calendarLinksAccountEvent,
    routinesTable,
    revealHintsTable,
    conflicts,
    changeLog,
    syncCursors,
    fieldSeen,
    localMeta,
    wakeUpDaysTable,
    routinesUser,
    routinesUserUpdated,
    routinesDirty,
    revealHintsUser,
    revealHintsDirty,
    conflictsOpen,
    changeLogEntity,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('series', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('series', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('calendar_accounts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('calendar_accounts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('calendar_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('calendar_links', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'calendar_accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('calendar_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('occurrences', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('occurrences', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'series',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('occurrences', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'calendar_links',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('occurrences', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('subtasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('subtasks', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'occurrences',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('subtasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'occurrences',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('search_index', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'occurrences',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('search_index', kind: UpdateKind.delete),
        TableUpdate('search_index', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'occurrences',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('search_index', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'subtasks',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('search_index', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'subtasks',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('search_index', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'subtasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('search_index', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routines', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('routines', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reveal_hints', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('reveal_hints', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('conflicts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('conflicts', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $SearchIndexCreateCompanionBuilder =
    SearchIndexCompanion Function({
      required String userId,
      required String title,
      required String notes,
      required String subtasks,
      Value<int> rowid,
    });
typedef $SearchIndexUpdateCompanionBuilder =
    SearchIndexCompanion Function({
      Value<String> userId,
      Value<String> title,
      Value<String> notes,
      Value<String> subtasks,
      Value<int> rowid,
    });

class $SearchIndexFilterComposer extends Composer<_$AppDatabase, SearchIndex> {
  $SearchIndexFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtasks => $composableBuilder(
    column: $table.subtasks,
    builder: (column) => ColumnFilters(column),
  );
}

class $SearchIndexOrderingComposer
    extends Composer<_$AppDatabase, SearchIndex> {
  $SearchIndexOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtasks => $composableBuilder(
    column: $table.subtasks,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SearchIndexAnnotationComposer
    extends Composer<_$AppDatabase, SearchIndex> {
  $SearchIndexAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get subtasks =>
      $composableBuilder(column: $table.subtasks, builder: (column) => column);
}

class $SearchIndexTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SearchIndex,
          SearchIndexData,
          $SearchIndexFilterComposer,
          $SearchIndexOrderingComposer,
          $SearchIndexAnnotationComposer,
          $SearchIndexCreateCompanionBuilder,
          $SearchIndexUpdateCompanionBuilder,
          (
            SearchIndexData,
            BaseReferences<_$AppDatabase, SearchIndex, SearchIndexData>,
          ),
          SearchIndexData,
          PrefetchHooks Function()
        > {
  $SearchIndexTableManager(_$AppDatabase db, SearchIndex table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SearchIndexFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SearchIndexOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SearchIndexAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> subtasks = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchIndexCompanion(
                userId: userId,
                title: title,
                notes: notes,
                subtasks: subtasks,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String title,
                required String notes,
                required String subtasks,
                Value<int> rowid = const Value.absent(),
              }) => SearchIndexCompanion.insert(
                userId: userId,
                title: title,
                notes: notes,
                subtasks: subtasks,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SearchIndex, SearchIndexData>(table),
                  BaseReferences<_$AppDatabase, SearchIndex, SearchIndexData>(
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

typedef $SearchIndexProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SearchIndex,
      SearchIndexData,
      $SearchIndexFilterComposer,
      $SearchIndexOrderingComposer,
      $SearchIndexAnnotationComposer,
      $SearchIndexCreateCompanionBuilder,
      $SearchIndexUpdateCompanionBuilder,
      (
        SearchIndexData,
        BaseReferences<_$AppDatabase, SearchIndex, SearchIndexData>,
      ),
      SearchIndexData,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required int createdAt,
      required int updatedAt,
      Value<bool> dirty,
      Value<int> version,
      required String id,
      Value<String?> displayName,
      Value<String> tzId,
      Value<String> locale,
      Value<String> settings,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> dirty,
      Value<int> version,
      Value<String> id,
      Value<String?> displayName,
      Value<String> tzId,
      Value<String> locale,
      Value<String> settings,
      Value<int> rowid,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SeriesTableTable, List<SeriesRow>>
  _seriesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.seriesTable,
    aliasName: 'profiles__id__series__user_id',
  );

  $$SeriesTableTableProcessedTableManager get seriesTableRefs {
    final manager = $$SeriesTableTableTableManager(
      $_db,
      $_db.seriesTable,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_seriesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CalendarAccountsTable, List<CalendarAccountRow>>
  _calendarAccountsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.calendarAccounts,
    aliasName: 'profiles__id__calendar_accounts__user_id',
  );

  $$CalendarAccountsTableProcessedTableManager get calendarAccountsRefs {
    final manager = $$CalendarAccountsTableTableManager(
      $_db,
      $_db.calendarAccounts,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _calendarAccountsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CalendarLinksTable, List<CalendarLinkRow>>
  _calendarLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.calendarLinks,
    aliasName: 'profiles__id__calendar_links__user_id',
  );

  $$CalendarLinksTableProcessedTableManager get calendarLinksRefs {
    final manager = $$CalendarLinksTableTableManager(
      $_db,
      $_db.calendarLinks,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_calendarLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OccurrencesTable, List<OccurrenceRow>>
  _occurrencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.occurrences,
    aliasName: 'profiles__id__occurrences__user_id',
  );

  $$OccurrencesTableProcessedTableManager get occurrencesRefs {
    final manager = $$OccurrencesTableTableManager(
      $_db,
      $_db.occurrences,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_occurrencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SubtasksTable, List<SubtaskRow>>
  _subtasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.subtasks,
    aliasName: 'profiles__id__subtasks__user_id',
  );

  $$SubtasksTableProcessedTableManager get subtasksRefs {
    final manager = $$SubtasksTableTableManager(
      $_db,
      $_db.subtasks,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_subtasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RoutinesTableTable, List<RoutineRow>>
  _routinesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routinesTable,
    aliasName: 'profiles__id__routines__user_id',
  );

  $$RoutinesTableTableProcessedTableManager get routinesTableRefs {
    final manager = $$RoutinesTableTableTableManager(
      $_db,
      $_db.routinesTable,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routinesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RevealHintsTableTable, List<RevealHintRow>>
  _revealHintsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.revealHintsTable,
    aliasName: 'profiles__id__reveal_hints__user_id',
  );

  $$RevealHintsTableTableProcessedTableManager get revealHintsTableRefs {
    final manager = $$RevealHintsTableTableTableManager(
      $_db,
      $_db.revealHintsTable,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _revealHintsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConflictsTable, List<ConflictRow>>
  _conflictsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conflicts,
    aliasName: 'profiles__id__conflicts__user_id',
  );

  $$ConflictsTableProcessedTableManager get conflictsRefs {
    final manager = $$ConflictsTableTableManager(
      $_db,
      $_db.conflicts,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_conflictsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tzId => $composableBuilder(
    column: $table.tzId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settings => $composableBuilder(
    column: $table.settings,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> seriesTableRefs(
    Expression<bool> Function($$SeriesTableTableFilterComposer f) f,
  ) {
    final $$SeriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesTable,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableTableFilterComposer(
            $db: $db,
            $table: $db.seriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> calendarAccountsRefs(
    Expression<bool> Function($$CalendarAccountsTableFilterComposer f) f,
  ) {
    final $$CalendarAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarAccounts,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarAccountsTableFilterComposer(
            $db: $db,
            $table: $db.calendarAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> calendarLinksRefs(
    Expression<bool> Function($$CalendarLinksTableFilterComposer f) f,
  ) {
    final $$CalendarLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarLinks,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarLinksTableFilterComposer(
            $db: $db,
            $table: $db.calendarLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> occurrencesRefs(
    Expression<bool> Function($$OccurrencesTableFilterComposer f) f,
  ) {
    final $$OccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> subtasksRefs(
    Expression<bool> Function($$SubtasksTableFilterComposer f) f,
  ) {
    final $$SubtasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableFilterComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routinesTableRefs(
    Expression<bool> Function($$RoutinesTableTableFilterComposer f) f,
  ) {
    final $$RoutinesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routinesTable,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableTableFilterComposer(
            $db: $db,
            $table: $db.routinesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> revealHintsTableRefs(
    Expression<bool> Function($$RevealHintsTableTableFilterComposer f) f,
  ) {
    final $$RevealHintsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.revealHintsTable,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RevealHintsTableTableFilterComposer(
            $db: $db,
            $table: $db.revealHintsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conflictsRefs(
    Expression<bool> Function($$ConflictsTableFilterComposer f) f,
  ) {
    final $$ConflictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conflicts,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConflictsTableFilterComposer(
            $db: $db,
            $table: $db.conflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tzId => $composableBuilder(
    column: $table.tzId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settings => $composableBuilder(
    column: $table.settings,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tzId =>
      $composableBuilder(column: $table.tzId, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get settings =>
      $composableBuilder(column: $table.settings, builder: (column) => column);

  Expression<T> seriesTableRefs<T extends Object>(
    Expression<T> Function($$SeriesTableTableAnnotationComposer a) f,
  ) {
    final $$SeriesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesTable,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.seriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> calendarAccountsRefs<T extends Object>(
    Expression<T> Function($$CalendarAccountsTableAnnotationComposer a) f,
  ) {
    final $$CalendarAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarAccounts,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> calendarLinksRefs<T extends Object>(
    Expression<T> Function($$CalendarLinksTableAnnotationComposer a) f,
  ) {
    final $$CalendarLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarLinks,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> occurrencesRefs<T extends Object>(
    Expression<T> Function($$OccurrencesTableAnnotationComposer a) f,
  ) {
    final $$OccurrencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableAnnotationComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> subtasksRefs<T extends Object>(
    Expression<T> Function($$SubtasksTableAnnotationComposer a) f,
  ) {
    final $$SubtasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableAnnotationComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> routinesTableRefs<T extends Object>(
    Expression<T> Function($$RoutinesTableTableAnnotationComposer a) f,
  ) {
    final $$RoutinesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routinesTable,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.routinesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> revealHintsTableRefs<T extends Object>(
    Expression<T> Function($$RevealHintsTableTableAnnotationComposer a) f,
  ) {
    final $$RevealHintsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.revealHintsTable,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RevealHintsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.revealHintsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> conflictsRefs<T extends Object>(
    Expression<T> Function($$ConflictsTableAnnotationComposer a) f,
  ) {
    final $$ConflictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conflicts,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConflictsTableAnnotationComposer(
            $db: $db,
            $table: $db.conflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (ProfileRow, $$ProfilesTableReferences),
          ProfileRow,
          PrefetchHooks Function({
            bool seriesTableRefs,
            bool calendarAccountsRefs,
            bool calendarLinksRefs,
            bool occurrencesRefs,
            bool subtasksRefs,
            bool routinesTableRefs,
            bool revealHintsTableRefs,
            bool conflictsRefs,
          })
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String> tzId = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> settings = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                version: version,
                id: id,
                displayName: displayName,
                tzId: tzId,
                locale: locale,
                settings: settings,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                Value<bool> dirty = const Value.absent(),
                Value<int> version = const Value.absent(),
                required String id,
                Value<String?> displayName = const Value.absent(),
                Value<String> tzId = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> settings = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                version: version,
                id: id,
                displayName: displayName,
                tzId: tzId,
                locale: locale,
                settings: settings,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, ProfileRow>(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                seriesTableRefs = false,
                calendarAccountsRefs = false,
                calendarLinksRefs = false,
                occurrencesRefs = false,
                subtasksRefs = false,
                routinesTableRefs = false,
                revealHintsTableRefs = false,
                conflictsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (seriesTableRefs) db.seriesTable,
                    if (calendarAccountsRefs) db.calendarAccounts,
                    if (calendarLinksRefs) db.calendarLinks,
                    if (occurrencesRefs) db.occurrences,
                    if (subtasksRefs) db.subtasks,
                    if (routinesTableRefs) db.routinesTable,
                    if (revealHintsTableRefs) db.revealHintsTable,
                    if (conflictsRefs) db.conflicts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (seriesTableRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          SeriesRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._seriesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).seriesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (calendarAccountsRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          CalendarAccountRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._calendarAccountsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).calendarAccountsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (calendarLinksRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          CalendarLinkRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._calendarLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).calendarLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (occurrencesRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          OccurrenceRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._occurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).occurrencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (subtasksRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          SubtaskRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._subtasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).subtasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (routinesTableRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          RoutineRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._routinesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).routinesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (revealHintsTableRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          RevealHintRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._revealHintsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).revealHintsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (conflictsRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          ConflictRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._conflictsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).conflictsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, $$ProfilesTableReferences),
      ProfileRow,
      PrefetchHooks Function({
        bool seriesTableRefs,
        bool calendarAccountsRefs,
        bool calendarLinksRefs,
        bool occurrencesRefs,
        bool subtasksRefs,
        bool routinesTableRefs,
        bool revealHintsTableRefs,
        bool conflictsRefs,
      })
    >;
typedef $$SeriesTableTableCreateCompanionBuilder =
    SeriesTableCompanion Function({
      required int createdAt,
      required int updatedAt,
      Value<bool> dirty,
      Value<int> version,
      required String id,
      required String userId,
      required String title,
      Value<String?> notes,
      Value<String> colorKey,
      Value<String> iconKey,
      required int durationMin,
      required String rrule,
      required String dtstartLocal,
      required String tzId,
      Value<int?> untilUtc,
      Value<int?> count,
      Value<bool> pinned,
      Value<int> travelBufferMin,
      Value<bool> durationFromSteps,
      Value<int?> energy,
      Value<String> alerts,
      Value<String?> soundId,
      Value<String> subtaskTemplate,
      Value<int?> materialisedThroughUtc,
      Value<int?> archivedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$SeriesTableTableUpdateCompanionBuilder =
    SeriesTableCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> dirty,
      Value<int> version,
      Value<String> id,
      Value<String> userId,
      Value<String> title,
      Value<String?> notes,
      Value<String> colorKey,
      Value<String> iconKey,
      Value<int> durationMin,
      Value<String> rrule,
      Value<String> dtstartLocal,
      Value<String> tzId,
      Value<int?> untilUtc,
      Value<int?> count,
      Value<bool> pinned,
      Value<int> travelBufferMin,
      Value<bool> durationFromSteps,
      Value<int?> energy,
      Value<String> alerts,
      Value<String?> soundId,
      Value<String> subtaskTemplate,
      Value<int?> materialisedThroughUtc,
      Value<int?> archivedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

final class $$SeriesTableTableReferences
    extends BaseReferences<_$AppDatabase, $SeriesTableTable, SeriesRow> {
  $$SeriesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _userIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('series__user_id__profiles__id');

  $$ProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OccurrencesTable, List<OccurrenceRow>>
  _occurrencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.occurrences,
    aliasName: 'series__id__occurrences__series_id',
  );

  $$OccurrencesTableProcessedTableManager get occurrencesRefs {
    final manager = $$OccurrencesTableTableManager(
      $_db,
      $_db.occurrences,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_occurrencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SeriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesTableTable> {
  $$SeriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rrule => $composableBuilder(
    column: $table.rrule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dtstartLocal => $composableBuilder(
    column: $table.dtstartLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tzId => $composableBuilder(
    column: $table.tzId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get untilUtc => $composableBuilder(
    column: $table.untilUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get travelBufferMin => $composableBuilder(
    column: $table.travelBufferMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get durationFromSteps => $composableBuilder(
    column: $table.durationFromSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alerts => $composableBuilder(
    column: $table.alerts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soundId => $composableBuilder(
    column: $table.soundId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtaskTemplate => $composableBuilder(
    column: $table.subtaskTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get materialisedThroughUtc => $composableBuilder(
    column: $table.materialisedThroughUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get userId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> occurrencesRefs(
    Expression<bool> Function($$OccurrencesTableFilterComposer f) f,
  ) {
    final $$OccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SeriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesTableTable> {
  $$SeriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rrule => $composableBuilder(
    column: $table.rrule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dtstartLocal => $composableBuilder(
    column: $table.dtstartLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tzId => $composableBuilder(
    column: $table.tzId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get untilUtc => $composableBuilder(
    column: $table.untilUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get travelBufferMin => $composableBuilder(
    column: $table.travelBufferMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get durationFromSteps => $composableBuilder(
    column: $table.durationFromSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alerts => $composableBuilder(
    column: $table.alerts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soundId => $composableBuilder(
    column: $table.soundId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtaskTemplate => $composableBuilder(
    column: $table.subtaskTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get materialisedThroughUtc => $composableBuilder(
    column: $table.materialisedThroughUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get userId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesTableTable> {
  $$SeriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get colorKey =>
      $composableBuilder(column: $table.colorKey, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rrule =>
      $composableBuilder(column: $table.rrule, builder: (column) => column);

  GeneratedColumn<String> get dtstartLocal => $composableBuilder(
    column: $table.dtstartLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tzId =>
      $composableBuilder(column: $table.tzId, builder: (column) => column);

  GeneratedColumn<int> get untilUtc =>
      $composableBuilder(column: $table.untilUtc, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<int> get travelBufferMin => $composableBuilder(
    column: $table.travelBufferMin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get durationFromSteps => $composableBuilder(
    column: $table.durationFromSteps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<String> get alerts =>
      $composableBuilder(column: $table.alerts, builder: (column) => column);

  GeneratedColumn<String> get soundId =>
      $composableBuilder(column: $table.soundId, builder: (column) => column);

  GeneratedColumn<String> get subtaskTemplate => $composableBuilder(
    column: $table.subtaskTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get materialisedThroughUtc => $composableBuilder(
    column: $table.materialisedThroughUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get userId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> occurrencesRefs<T extends Object>(
    Expression<T> Function($$OccurrencesTableAnnotationComposer a) f,
  ) {
    final $$OccurrencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableAnnotationComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SeriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesTableTable,
          SeriesRow,
          $$SeriesTableTableFilterComposer,
          $$SeriesTableTableOrderingComposer,
          $$SeriesTableTableAnnotationComposer,
          $$SeriesTableTableCreateCompanionBuilder,
          $$SeriesTableTableUpdateCompanionBuilder,
          (SeriesRow, $$SeriesTableTableReferences),
          SeriesRow,
          PrefetchHooks Function({bool userId, bool occurrencesRefs})
        > {
  $$SeriesTableTableTableManager(_$AppDatabase db, $SeriesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> colorKey = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int> durationMin = const Value.absent(),
                Value<String> rrule = const Value.absent(),
                Value<String> dtstartLocal = const Value.absent(),
                Value<String> tzId = const Value.absent(),
                Value<int?> untilUtc = const Value.absent(),
                Value<int?> count = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> travelBufferMin = const Value.absent(),
                Value<bool> durationFromSteps = const Value.absent(),
                Value<int?> energy = const Value.absent(),
                Value<String> alerts = const Value.absent(),
                Value<String?> soundId = const Value.absent(),
                Value<String> subtaskTemplate = const Value.absent(),
                Value<int?> materialisedThroughUtc = const Value.absent(),
                Value<int?> archivedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesTableCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                version: version,
                id: id,
                userId: userId,
                title: title,
                notes: notes,
                colorKey: colorKey,
                iconKey: iconKey,
                durationMin: durationMin,
                rrule: rrule,
                dtstartLocal: dtstartLocal,
                tzId: tzId,
                untilUtc: untilUtc,
                count: count,
                pinned: pinned,
                travelBufferMin: travelBufferMin,
                durationFromSteps: durationFromSteps,
                energy: energy,
                alerts: alerts,
                soundId: soundId,
                subtaskTemplate: subtaskTemplate,
                materialisedThroughUtc: materialisedThroughUtc,
                archivedAt: archivedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                Value<bool> dirty = const Value.absent(),
                Value<int> version = const Value.absent(),
                required String id,
                required String userId,
                required String title,
                Value<String?> notes = const Value.absent(),
                Value<String> colorKey = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                required int durationMin,
                required String rrule,
                required String dtstartLocal,
                required String tzId,
                Value<int?> untilUtc = const Value.absent(),
                Value<int?> count = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> travelBufferMin = const Value.absent(),
                Value<bool> durationFromSteps = const Value.absent(),
                Value<int?> energy = const Value.absent(),
                Value<String> alerts = const Value.absent(),
                Value<String?> soundId = const Value.absent(),
                Value<String> subtaskTemplate = const Value.absent(),
                Value<int?> materialisedThroughUtc = const Value.absent(),
                Value<int?> archivedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesTableCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                version: version,
                id: id,
                userId: userId,
                title: title,
                notes: notes,
                colorKey: colorKey,
                iconKey: iconKey,
                durationMin: durationMin,
                rrule: rrule,
                dtstartLocal: dtstartLocal,
                tzId: tzId,
                untilUtc: untilUtc,
                count: count,
                pinned: pinned,
                travelBufferMin: travelBufferMin,
                durationFromSteps: durationFromSteps,
                energy: energy,
                alerts: alerts,
                soundId: soundId,
                subtaskTemplate: subtaskTemplate,
                materialisedThroughUtc: materialisedThroughUtc,
                archivedAt: archivedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeriesTableTable, SeriesRow>(table),
                  $$SeriesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false, occurrencesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (occurrencesRefs) db.occurrences],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$SeriesTableTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$SeriesTableTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (occurrencesRefs)
                    await $_getPrefetchedData<
                      SeriesRow,
                      $SeriesTableTable,
                      OccurrenceRow
                    >(
                      currentTable: table,
                      referencedTable: $$SeriesTableTableReferences
                          ._occurrencesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SeriesTableTableReferences(
                            db,
                            table,
                            p0,
                          ).occurrencesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.seriesId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SeriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesTableTable,
      SeriesRow,
      $$SeriesTableTableFilterComposer,
      $$SeriesTableTableOrderingComposer,
      $$SeriesTableTableAnnotationComposer,
      $$SeriesTableTableCreateCompanionBuilder,
      $$SeriesTableTableUpdateCompanionBuilder,
      (SeriesRow, $$SeriesTableTableReferences),
      SeriesRow,
      PrefetchHooks Function({bool userId, bool occurrencesRefs})
    >;
typedef $$CalendarAccountsTableCreateCompanionBuilder =
    CalendarAccountsCompanion Function({
      required int createdAt,
      required int updatedAt,
      required String id,
      required String userId,
      required String provider,
      required String label,
      Value<String?> externalAccountId,
      Value<bool> writeBack,
      Value<bool> enabled,
      Value<int> rowid,
    });
typedef $$CalendarAccountsTableUpdateCompanionBuilder =
    CalendarAccountsCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> id,
      Value<String> userId,
      Value<String> provider,
      Value<String> label,
      Value<String?> externalAccountId,
      Value<bool> writeBack,
      Value<bool> enabled,
      Value<int> rowid,
    });

final class $$CalendarAccountsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CalendarAccountsTable,
          CalendarAccountRow
        > {
  $$CalendarAccountsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _userIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('calendar_accounts__user_id__profiles__id');

  $$ProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CalendarLinksTable, List<CalendarLinkRow>>
  _calendarLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.calendarLinks,
    aliasName: 'calendar_accounts__id__calendar_links__account_id',
  );

  $$CalendarLinksTableProcessedTableManager get calendarLinksRefs {
    final manager = $$CalendarLinksTableTableManager(
      $_db,
      $_db.calendarLinks,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_calendarLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CalendarAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarAccountsTable> {
  $$CalendarAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalAccountId => $composableBuilder(
    column: $table.externalAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get writeBack => $composableBuilder(
    column: $table.writeBack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get userId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> calendarLinksRefs(
    Expression<bool> Function($$CalendarLinksTableFilterComposer f) f,
  ) {
    final $$CalendarLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarLinks,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarLinksTableFilterComposer(
            $db: $db,
            $table: $db.calendarLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CalendarAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarAccountsTable> {
  $$CalendarAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalAccountId => $composableBuilder(
    column: $table.externalAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get writeBack => $composableBuilder(
    column: $table.writeBack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get userId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarAccountsTable> {
  $$CalendarAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get externalAccountId => $composableBuilder(
    column: $table.externalAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get writeBack =>
      $composableBuilder(column: $table.writeBack, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get userId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> calendarLinksRefs<T extends Object>(
    Expression<T> Function($$CalendarLinksTableAnnotationComposer a) f,
  ) {
    final $$CalendarLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarLinks,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CalendarAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalendarAccountsTable,
          CalendarAccountRow,
          $$CalendarAccountsTableFilterComposer,
          $$CalendarAccountsTableOrderingComposer,
          $$CalendarAccountsTableAnnotationComposer,
          $$CalendarAccountsTableCreateCompanionBuilder,
          $$CalendarAccountsTableUpdateCompanionBuilder,
          (CalendarAccountRow, $$CalendarAccountsTableReferences),
          CalendarAccountRow,
          PrefetchHooks Function({bool userId, bool calendarLinksRefs})
        > {
  $$CalendarAccountsTableTableManager(
    _$AppDatabase db,
    $CalendarAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> externalAccountId = const Value.absent(),
                Value<bool> writeBack = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarAccountsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                userId: userId,
                provider: provider,
                label: label,
                externalAccountId: externalAccountId,
                writeBack: writeBack,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                required String id,
                required String userId,
                required String provider,
                required String label,
                Value<String?> externalAccountId = const Value.absent(),
                Value<bool> writeBack = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarAccountsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                userId: userId,
                provider: provider,
                label: label,
                externalAccountId: externalAccountId,
                writeBack: writeBack,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CalendarAccountsTable, CalendarAccountRow>(
                    table,
                  ),
                  $$CalendarAccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false, calendarLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (calendarLinksRefs) db.calendarLinks,
              ],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$CalendarAccountsTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$CalendarAccountsTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (calendarLinksRefs)
                    await $_getPrefetchedData<
                      CalendarAccountRow,
                      $CalendarAccountsTable,
                      CalendarLinkRow
                    >(
                      currentTable: table,
                      referencedTable: $$CalendarAccountsTableReferences
                          ._calendarLinksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CalendarAccountsTableReferences(
                            db,
                            table,
                            p0,
                          ).calendarLinksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.accountId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CalendarAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalendarAccountsTable,
      CalendarAccountRow,
      $$CalendarAccountsTableFilterComposer,
      $$CalendarAccountsTableOrderingComposer,
      $$CalendarAccountsTableAnnotationComposer,
      $$CalendarAccountsTableCreateCompanionBuilder,
      $$CalendarAccountsTableUpdateCompanionBuilder,
      (CalendarAccountRow, $$CalendarAccountsTableReferences),
      CalendarAccountRow,
      PrefetchHooks Function({bool userId, bool calendarLinksRefs})
    >;
typedef $$CalendarLinksTableCreateCompanionBuilder =
    CalendarLinksCompanion Function({
      required String id,
      required String userId,
      required String accountId,
      required String externalCalendarId,
      required String externalEventId,
      Value<String?> etag,
      Value<int?> lastSyncedUtc,
      Value<bool> readOnly,
      Value<String?> location,
      Value<int> rowid,
    });
typedef $$CalendarLinksTableUpdateCompanionBuilder =
    CalendarLinksCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> accountId,
      Value<String> externalCalendarId,
      Value<String> externalEventId,
      Value<String?> etag,
      Value<int?> lastSyncedUtc,
      Value<bool> readOnly,
      Value<String?> location,
      Value<int> rowid,
    });

final class $$CalendarLinksTableReferences
    extends
        BaseReferences<_$AppDatabase, $CalendarLinksTable, CalendarLinkRow> {
  $$CalendarLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _userIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('calendar_links__user_id__profiles__id');

  $$ProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CalendarAccountsTable _accountIdTable(_$AppDatabase db) => db
      .calendarAccounts
      .createAlias('calendar_links__account_id__calendar_accounts__id');

  $$CalendarAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$CalendarAccountsTableTableManager(
      $_db,
      $_db.calendarAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OccurrencesTable, List<OccurrenceRow>>
  _occurrencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.occurrences,
    aliasName: 'calendar_links__id__occurrences__calendar_link_id',
  );

  $$OccurrencesTableProcessedTableManager get occurrencesRefs {
    final manager = $$OccurrencesTableTableManager(
      $_db,
      $_db.occurrences,
    ).filter((f) => f.calendarLinkId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_occurrencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CalendarLinksTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarLinksTable> {
  $$CalendarLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalCalendarId => $composableBuilder(
    column: $table.externalCalendarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalEventId => $composableBuilder(
    column: $table.externalEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedUtc => $composableBuilder(
    column: $table.lastSyncedUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get readOnly => $composableBuilder(
    column: $table.readOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get userId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CalendarAccountsTableFilterComposer get accountId {
    final $$CalendarAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.calendarAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarAccountsTableFilterComposer(
            $db: $db,
            $table: $db.calendarAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> occurrencesRefs(
    Expression<bool> Function($$OccurrencesTableFilterComposer f) f,
  ) {
    final $$OccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.calendarLinkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CalendarLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarLinksTable> {
  $$CalendarLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalCalendarId => $composableBuilder(
    column: $table.externalCalendarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalEventId => $composableBuilder(
    column: $table.externalEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedUtc => $composableBuilder(
    column: $table.lastSyncedUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get readOnly => $composableBuilder(
    column: $table.readOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get userId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CalendarAccountsTableOrderingComposer get accountId {
    final $$CalendarAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.calendarAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.calendarAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarLinksTable> {
  $$CalendarLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get externalCalendarId => $composableBuilder(
    column: $table.externalCalendarId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalEventId => $composableBuilder(
    column: $table.externalEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<int> get lastSyncedUtc => $composableBuilder(
    column: $table.lastSyncedUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get readOnly =>
      $composableBuilder(column: $table.readOnly, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get userId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CalendarAccountsTableAnnotationComposer get accountId {
    final $$CalendarAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.calendarAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> occurrencesRefs<T extends Object>(
    Expression<T> Function($$OccurrencesTableAnnotationComposer a) f,
  ) {
    final $$OccurrencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.calendarLinkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableAnnotationComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CalendarLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalendarLinksTable,
          CalendarLinkRow,
          $$CalendarLinksTableFilterComposer,
          $$CalendarLinksTableOrderingComposer,
          $$CalendarLinksTableAnnotationComposer,
          $$CalendarLinksTableCreateCompanionBuilder,
          $$CalendarLinksTableUpdateCompanionBuilder,
          (CalendarLinkRow, $$CalendarLinksTableReferences),
          CalendarLinkRow,
          PrefetchHooks Function({
            bool userId,
            bool accountId,
            bool occurrencesRefs,
          })
        > {
  $$CalendarLinksTableTableManager(_$AppDatabase db, $CalendarLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> externalCalendarId = const Value.absent(),
                Value<String> externalEventId = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<int?> lastSyncedUtc = const Value.absent(),
                Value<bool> readOnly = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarLinksCompanion(
                id: id,
                userId: userId,
                accountId: accountId,
                externalCalendarId: externalCalendarId,
                externalEventId: externalEventId,
                etag: etag,
                lastSyncedUtc: lastSyncedUtc,
                readOnly: readOnly,
                location: location,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String accountId,
                required String externalCalendarId,
                required String externalEventId,
                Value<String?> etag = const Value.absent(),
                Value<int?> lastSyncedUtc = const Value.absent(),
                Value<bool> readOnly = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarLinksCompanion.insert(
                id: id,
                userId: userId,
                accountId: accountId,
                externalCalendarId: externalCalendarId,
                externalEventId: externalEventId,
                etag: etag,
                lastSyncedUtc: lastSyncedUtc,
                readOnly: readOnly,
                location: location,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CalendarLinksTable, CalendarLinkRow>(table),
                  $$CalendarLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({userId = false, accountId = false, occurrencesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (occurrencesRefs) db.occurrences,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable:
                                        $$CalendarLinksTableReferences
                                            ._userIdTable(db),
                                    referencedColumn:
                                        $$CalendarLinksTableReferences
                                            ._userIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (accountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountId,
                                    referencedTable:
                                        $$CalendarLinksTableReferences
                                            ._accountIdTable(db),
                                    referencedColumn:
                                        $$CalendarLinksTableReferences
                                            ._accountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (occurrencesRefs)
                        await $_getPrefetchedData<
                          CalendarLinkRow,
                          $CalendarLinksTable,
                          OccurrenceRow
                        >(
                          currentTable: table,
                          referencedTable: $$CalendarLinksTableReferences
                              ._occurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CalendarLinksTableReferences(
                                db,
                                table,
                                p0,
                              ).occurrencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.calendarLinkId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CalendarLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalendarLinksTable,
      CalendarLinkRow,
      $$CalendarLinksTableFilterComposer,
      $$CalendarLinksTableOrderingComposer,
      $$CalendarLinksTableAnnotationComposer,
      $$CalendarLinksTableCreateCompanionBuilder,
      $$CalendarLinksTableUpdateCompanionBuilder,
      (CalendarLinkRow, $$CalendarLinksTableReferences),
      CalendarLinkRow,
      PrefetchHooks Function({
        bool userId,
        bool accountId,
        bool occurrencesRefs,
      })
    >;
typedef $$OccurrencesTableCreateCompanionBuilder =
    OccurrencesCompanion Function({
      required int createdAt,
      required int updatedAt,
      Value<bool> dirty,
      Value<int> version,
      required String id,
      required String userId,
      Value<String?> seriesId,
      Value<int?> originalStartUtc,
      required String title,
      Value<String?> notes,
      Value<String> colorKey,
      Value<String> iconKey,
      Value<int?> startUtc,
      required String tzId,
      required int durationMin,
      Value<bool> pinned,
      Value<int> travelBufferMin,
      Value<int?> energy,
      Value<String?> alerts,
      Value<String?> soundId,
      Value<String> status,
      Value<int?> completedAtUtc,
      Value<double> sortOrder,
      Value<String> source,
      Value<String?> calendarLinkId,
      Value<int?> snoozedUntilUtc,
      Value<int?> actualStartUtc,
      Value<int?> actualEndUtc,
      Value<bool> durationFromSteps,
      Value<int> moveCount,
      Value<bool> routineStart,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$OccurrencesTableUpdateCompanionBuilder =
    OccurrencesCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> dirty,
      Value<int> version,
      Value<String> id,
      Value<String> userId,
      Value<String?> seriesId,
      Value<int?> originalStartUtc,
      Value<String> title,
      Value<String?> notes,
      Value<String> colorKey,
      Value<String> iconKey,
      Value<int?> startUtc,
      Value<String> tzId,
      Value<int> durationMin,
      Value<bool> pinned,
      Value<int> travelBufferMin,
      Value<int?> energy,
      Value<String?> alerts,
      Value<String?> soundId,
      Value<String> status,
      Value<int?> completedAtUtc,
      Value<double> sortOrder,
      Value<String> source,
      Value<String?> calendarLinkId,
      Value<int?> snoozedUntilUtc,
      Value<int?> actualStartUtc,
      Value<int?> actualEndUtc,
      Value<bool> durationFromSteps,
      Value<int> moveCount,
      Value<bool> routineStart,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

final class $$OccurrencesTableReferences
    extends BaseReferences<_$AppDatabase, $OccurrencesTable, OccurrenceRow> {
  $$OccurrencesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _userIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('occurrences__user_id__profiles__id');

  $$ProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SeriesTableTable _seriesIdTable(_$AppDatabase db) =>
      db.seriesTable.createAlias('occurrences__series_id__series__id');

  $$SeriesTableTableProcessedTableManager? get seriesId {
    final $_column = $_itemColumn<String>('series_id');
    if ($_column == null) return null;
    final manager = $$SeriesTableTableTableManager(
      $_db,
      $_db.seriesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CalendarLinksTable _calendarLinkIdTable(_$AppDatabase db) => db
      .calendarLinks
      .createAlias('occurrences__calendar_link_id__calendar_links__id');

  $$CalendarLinksTableProcessedTableManager? get calendarLinkId {
    final $_column = $_itemColumn<String>('calendar_link_id');
    if ($_column == null) return null;
    final manager = $$CalendarLinksTableTableManager(
      $_db,
      $_db.calendarLinks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_calendarLinkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SubtasksTable, List<SubtaskRow>>
  _subtasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.subtasks,
    aliasName: 'occurrences__id__subtasks__occurrence_id',
  );

  $$SubtasksTableProcessedTableManager get subtasksRefs {
    final manager = $$SubtasksTableTableManager(
      $_db,
      $_db.subtasks,
    ).filter((f) => f.occurrenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_subtasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalStartUtc => $composableBuilder(
    column: $table.originalStartUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startUtc => $composableBuilder(
    column: $table.startUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tzId => $composableBuilder(
    column: $table.tzId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get travelBufferMin => $composableBuilder(
    column: $table.travelBufferMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alerts => $composableBuilder(
    column: $table.alerts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soundId => $composableBuilder(
    column: $table.soundId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozedUntilUtc => $composableBuilder(
    column: $table.snoozedUntilUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualStartUtc => $composableBuilder(
    column: $table.actualStartUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualEndUtc => $composableBuilder(
    column: $table.actualEndUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get durationFromSteps => $composableBuilder(
    column: $table.durationFromSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get moveCount => $composableBuilder(
    column: $table.moveCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get routineStart => $composableBuilder(
    column: $table.routineStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get userId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SeriesTableTableFilterComposer get seriesId {
    final $$SeriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.seriesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableTableFilterComposer(
            $db: $db,
            $table: $db.seriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CalendarLinksTableFilterComposer get calendarLinkId {
    final $$CalendarLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.calendarLinkId,
      referencedTable: $db.calendarLinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarLinksTableFilterComposer(
            $db: $db,
            $table: $db.calendarLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> subtasksRefs(
    Expression<bool> Function($$SubtasksTableFilterComposer f) f,
  ) {
    final $$SubtasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.occurrenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableFilterComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalStartUtc => $composableBuilder(
    column: $table.originalStartUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startUtc => $composableBuilder(
    column: $table.startUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tzId => $composableBuilder(
    column: $table.tzId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get travelBufferMin => $composableBuilder(
    column: $table.travelBufferMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alerts => $composableBuilder(
    column: $table.alerts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soundId => $composableBuilder(
    column: $table.soundId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozedUntilUtc => $composableBuilder(
    column: $table.snoozedUntilUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualStartUtc => $composableBuilder(
    column: $table.actualStartUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualEndUtc => $composableBuilder(
    column: $table.actualEndUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get durationFromSteps => $composableBuilder(
    column: $table.durationFromSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get moveCount => $composableBuilder(
    column: $table.moveCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get routineStart => $composableBuilder(
    column: $table.routineStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get userId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SeriesTableTableOrderingComposer get seriesId {
    final $$SeriesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.seriesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableTableOrderingComposer(
            $db: $db,
            $table: $db.seriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CalendarLinksTableOrderingComposer get calendarLinkId {
    final $$CalendarLinksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.calendarLinkId,
      referencedTable: $db.calendarLinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarLinksTableOrderingComposer(
            $db: $db,
            $table: $db.calendarLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get originalStartUtc => $composableBuilder(
    column: $table.originalStartUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get colorKey =>
      $composableBuilder(column: $table.colorKey, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumn<String> get tzId =>
      $composableBuilder(column: $table.tzId, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<int> get travelBufferMin => $composableBuilder(
    column: $table.travelBufferMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<String> get alerts =>
      $composableBuilder(column: $table.alerts, builder: (column) => column);

  GeneratedColumn<String> get soundId =>
      $composableBuilder(column: $table.soundId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get snoozedUntilUtc => $composableBuilder(
    column: $table.snoozedUntilUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualStartUtc => $composableBuilder(
    column: $table.actualStartUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualEndUtc => $composableBuilder(
    column: $table.actualEndUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get durationFromSteps => $composableBuilder(
    column: $table.durationFromSteps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get moveCount =>
      $composableBuilder(column: $table.moveCount, builder: (column) => column);

  GeneratedColumn<bool> get routineStart => $composableBuilder(
    column: $table.routineStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get userId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SeriesTableTableAnnotationComposer get seriesId {
    final $$SeriesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.seriesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.seriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CalendarLinksTableAnnotationComposer get calendarLinkId {
    final $$CalendarLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.calendarLinkId,
      referencedTable: $db.calendarLinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> subtasksRefs<T extends Object>(
    Expression<T> Function($$SubtasksTableAnnotationComposer a) f,
  ) {
    final $$SubtasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.occurrenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableAnnotationComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OccurrencesTable,
          OccurrenceRow,
          $$OccurrencesTableFilterComposer,
          $$OccurrencesTableOrderingComposer,
          $$OccurrencesTableAnnotationComposer,
          $$OccurrencesTableCreateCompanionBuilder,
          $$OccurrencesTableUpdateCompanionBuilder,
          (OccurrenceRow, $$OccurrencesTableReferences),
          OccurrenceRow,
          PrefetchHooks Function({
            bool userId,
            bool seriesId,
            bool calendarLinkId,
            bool subtasksRefs,
          })
        > {
  $$OccurrencesTableTableManager(_$AppDatabase db, $OccurrencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OccurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OccurrencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<int?> originalStartUtc = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> colorKey = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int?> startUtc = const Value.absent(),
                Value<String> tzId = const Value.absent(),
                Value<int> durationMin = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> travelBufferMin = const Value.absent(),
                Value<int?> energy = const Value.absent(),
                Value<String?> alerts = const Value.absent(),
                Value<String?> soundId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> completedAtUtc = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> calendarLinkId = const Value.absent(),
                Value<int?> snoozedUntilUtc = const Value.absent(),
                Value<int?> actualStartUtc = const Value.absent(),
                Value<int?> actualEndUtc = const Value.absent(),
                Value<bool> durationFromSteps = const Value.absent(),
                Value<int> moveCount = const Value.absent(),
                Value<bool> routineStart = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OccurrencesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                version: version,
                id: id,
                userId: userId,
                seriesId: seriesId,
                originalStartUtc: originalStartUtc,
                title: title,
                notes: notes,
                colorKey: colorKey,
                iconKey: iconKey,
                startUtc: startUtc,
                tzId: tzId,
                durationMin: durationMin,
                pinned: pinned,
                travelBufferMin: travelBufferMin,
                energy: energy,
                alerts: alerts,
                soundId: soundId,
                status: status,
                completedAtUtc: completedAtUtc,
                sortOrder: sortOrder,
                source: source,
                calendarLinkId: calendarLinkId,
                snoozedUntilUtc: snoozedUntilUtc,
                actualStartUtc: actualStartUtc,
                actualEndUtc: actualEndUtc,
                durationFromSteps: durationFromSteps,
                moveCount: moveCount,
                routineStart: routineStart,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                Value<bool> dirty = const Value.absent(),
                Value<int> version = const Value.absent(),
                required String id,
                required String userId,
                Value<String?> seriesId = const Value.absent(),
                Value<int?> originalStartUtc = const Value.absent(),
                required String title,
                Value<String?> notes = const Value.absent(),
                Value<String> colorKey = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int?> startUtc = const Value.absent(),
                required String tzId,
                required int durationMin,
                Value<bool> pinned = const Value.absent(),
                Value<int> travelBufferMin = const Value.absent(),
                Value<int?> energy = const Value.absent(),
                Value<String?> alerts = const Value.absent(),
                Value<String?> soundId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> completedAtUtc = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> calendarLinkId = const Value.absent(),
                Value<int?> snoozedUntilUtc = const Value.absent(),
                Value<int?> actualStartUtc = const Value.absent(),
                Value<int?> actualEndUtc = const Value.absent(),
                Value<bool> durationFromSteps = const Value.absent(),
                Value<int> moveCount = const Value.absent(),
                Value<bool> routineStart = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OccurrencesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                version: version,
                id: id,
                userId: userId,
                seriesId: seriesId,
                originalStartUtc: originalStartUtc,
                title: title,
                notes: notes,
                colorKey: colorKey,
                iconKey: iconKey,
                startUtc: startUtc,
                tzId: tzId,
                durationMin: durationMin,
                pinned: pinned,
                travelBufferMin: travelBufferMin,
                energy: energy,
                alerts: alerts,
                soundId: soundId,
                status: status,
                completedAtUtc: completedAtUtc,
                sortOrder: sortOrder,
                source: source,
                calendarLinkId: calendarLinkId,
                snoozedUntilUtc: snoozedUntilUtc,
                actualStartUtc: actualStartUtc,
                actualEndUtc: actualEndUtc,
                durationFromSteps: durationFromSteps,
                moveCount: moveCount,
                routineStart: routineStart,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OccurrencesTable, OccurrenceRow>(table),
                  $$OccurrencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                userId = false,
                seriesId = false,
                calendarLinkId = false,
                subtasksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (subtasksRefs) db.subtasks],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable:
                                        $$OccurrencesTableReferences
                                            ._userIdTable(db),
                                    referencedColumn:
                                        $$OccurrencesTableReferences
                                            ._userIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (seriesId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.seriesId,
                                    referencedTable:
                                        $$OccurrencesTableReferences
                                            ._seriesIdTable(db),
                                    referencedColumn:
                                        $$OccurrencesTableReferences
                                            ._seriesIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (calendarLinkId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.calendarLinkId,
                                    referencedTable:
                                        $$OccurrencesTableReferences
                                            ._calendarLinkIdTable(db),
                                    referencedColumn:
                                        $$OccurrencesTableReferences
                                            ._calendarLinkIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (subtasksRefs)
                        await $_getPrefetchedData<
                          OccurrenceRow,
                          $OccurrencesTable,
                          SubtaskRow
                        >(
                          currentTable: table,
                          referencedTable: $$OccurrencesTableReferences
                              ._subtasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OccurrencesTableReferences(
                                db,
                                table,
                                p0,
                              ).subtasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.occurrenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OccurrencesTable,
      OccurrenceRow,
      $$OccurrencesTableFilterComposer,
      $$OccurrencesTableOrderingComposer,
      $$OccurrencesTableAnnotationComposer,
      $$OccurrencesTableCreateCompanionBuilder,
      $$OccurrencesTableUpdateCompanionBuilder,
      (OccurrenceRow, $$OccurrencesTableReferences),
      OccurrenceRow,
      PrefetchHooks Function({
        bool userId,
        bool seriesId,
        bool calendarLinkId,
        bool subtasksRefs,
      })
    >;
typedef $$SubtasksTableCreateCompanionBuilder =
    SubtasksCompanion Function({
      required int createdAt,
      required int updatedAt,
      Value<bool> dirty,
      Value<int> version,
      required String id,
      required String userId,
      required String occurrenceId,
      required String title,
      Value<bool> done,
      Value<double> sortOrder,
      Value<int?> durationMin,
      Value<int?> doneAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$SubtasksTableUpdateCompanionBuilder =
    SubtasksCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> dirty,
      Value<int> version,
      Value<String> id,
      Value<String> userId,
      Value<String> occurrenceId,
      Value<String> title,
      Value<bool> done,
      Value<double> sortOrder,
      Value<int?> durationMin,
      Value<int?> doneAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

final class $$SubtasksTableReferences
    extends BaseReferences<_$AppDatabase, $SubtasksTable, SubtaskRow> {
  $$SubtasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _userIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('subtasks__user_id__profiles__id');

  $$ProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OccurrencesTable _occurrenceIdTable(_$AppDatabase db) =>
      db.occurrences.createAlias('subtasks__occurrence_id__occurrences__id');

  $$OccurrencesTableProcessedTableManager get occurrenceId {
    final $_column = $_itemColumn<String>('occurrence_id')!;

    final manager = $$OccurrencesTableTableManager(
      $_db,
      $_db.occurrences,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_occurrenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SubtasksTableFilterComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get userId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OccurrencesTableFilterComposer get occurrenceId {
    final $$OccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occurrenceId,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtasksTableOrderingComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get userId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OccurrencesTableOrderingComposer get occurrenceId {
    final $$OccurrencesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occurrenceId,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableOrderingComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<double> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get userId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OccurrencesTableAnnotationComposer get occurrenceId {
    final $$OccurrencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occurrenceId,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableAnnotationComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubtasksTable,
          SubtaskRow,
          $$SubtasksTableFilterComposer,
          $$SubtasksTableOrderingComposer,
          $$SubtasksTableAnnotationComposer,
          $$SubtasksTableCreateCompanionBuilder,
          $$SubtasksTableUpdateCompanionBuilder,
          (SubtaskRow, $$SubtasksTableReferences),
          SubtaskRow,
          PrefetchHooks Function({bool userId, bool occurrenceId})
        > {
  $$SubtasksTableTableManager(_$AppDatabase db, $SubtasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubtasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubtasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubtasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> occurrenceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<int?> doneAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubtasksCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                version: version,
                id: id,
                userId: userId,
                occurrenceId: occurrenceId,
                title: title,
                done: done,
                sortOrder: sortOrder,
                durationMin: durationMin,
                doneAt: doneAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                Value<bool> dirty = const Value.absent(),
                Value<int> version = const Value.absent(),
                required String id,
                required String userId,
                required String occurrenceId,
                required String title,
                Value<bool> done = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<int?> doneAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubtasksCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                version: version,
                id: id,
                userId: userId,
                occurrenceId: occurrenceId,
                title: title,
                done: done,
                sortOrder: sortOrder,
                durationMin: durationMin,
                doneAt: doneAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubtasksTable, SubtaskRow>(table),
                  $$SubtasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false, occurrenceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$SubtasksTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$SubtasksTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (occurrenceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.occurrenceId,
                                referencedTable: $$SubtasksTableReferences
                                    ._occurrenceIdTable(db),
                                referencedColumn: $$SubtasksTableReferences
                                    ._occurrenceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SubtasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubtasksTable,
      SubtaskRow,
      $$SubtasksTableFilterComposer,
      $$SubtasksTableOrderingComposer,
      $$SubtasksTableAnnotationComposer,
      $$SubtasksTableCreateCompanionBuilder,
      $$SubtasksTableUpdateCompanionBuilder,
      (SubtaskRow, $$SubtasksTableReferences),
      SubtaskRow,
      PrefetchHooks Function({bool userId, bool occurrenceId})
    >;
typedef $$RoutinesTableTableCreateCompanionBuilder =
    RoutinesTableCompanion Function({
      required int createdAt,
      required int updatedAt,
      Value<bool> dirty,
      Value<int> version,
      required String id,
      required String userId,
      required String title,
      Value<String> anchor,
      Value<int?> anchorMinute,
      Value<String> items,
      Value<double> sortOrder,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$RoutinesTableTableUpdateCompanionBuilder =
    RoutinesTableCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> dirty,
      Value<int> version,
      Value<String> id,
      Value<String> userId,
      Value<String> title,
      Value<String> anchor,
      Value<int?> anchorMinute,
      Value<String> items,
      Value<double> sortOrder,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

final class $$RoutinesTableTableReferences
    extends BaseReferences<_$AppDatabase, $RoutinesTableTable, RoutineRow> {
  $$RoutinesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _userIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('routines__user_id__profiles__id');

  $$ProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutinesTableTableFilterComposer
    extends Composer<_$AppDatabase, $RoutinesTableTable> {
  $$RoutinesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anchor => $composableBuilder(
    column: $table.anchor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anchorMinute => $composableBuilder(
    column: $table.anchorMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get items => $composableBuilder(
    column: $table.items,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get userId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutinesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutinesTableTable> {
  $$RoutinesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchor => $composableBuilder(
    column: $table.anchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anchorMinute => $composableBuilder(
    column: $table.anchorMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get items => $composableBuilder(
    column: $table.items,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get userId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutinesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutinesTableTable> {
  $$RoutinesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get anchor =>
      $composableBuilder(column: $table.anchor, builder: (column) => column);

  GeneratedColumn<int> get anchorMinute => $composableBuilder(
    column: $table.anchorMinute,
    builder: (column) => column,
  );

  GeneratedColumn<String> get items =>
      $composableBuilder(column: $table.items, builder: (column) => column);

  GeneratedColumn<double> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get userId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutinesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutinesTableTable,
          RoutineRow,
          $$RoutinesTableTableFilterComposer,
          $$RoutinesTableTableOrderingComposer,
          $$RoutinesTableTableAnnotationComposer,
          $$RoutinesTableTableCreateCompanionBuilder,
          $$RoutinesTableTableUpdateCompanionBuilder,
          (RoutineRow, $$RoutinesTableTableReferences),
          RoutineRow,
          PrefetchHooks Function({bool userId})
        > {
  $$RoutinesTableTableTableManager(_$AppDatabase db, $RoutinesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> anchor = const Value.absent(),
                Value<int?> anchorMinute = const Value.absent(),
                Value<String> items = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesTableCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                version: version,
                id: id,
                userId: userId,
                title: title,
                anchor: anchor,
                anchorMinute: anchorMinute,
                items: items,
                sortOrder: sortOrder,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                Value<bool> dirty = const Value.absent(),
                Value<int> version = const Value.absent(),
                required String id,
                required String userId,
                required String title,
                Value<String> anchor = const Value.absent(),
                Value<int?> anchorMinute = const Value.absent(),
                Value<String> items = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesTableCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                version: version,
                id: id,
                userId: userId,
                title: title,
                anchor: anchor,
                anchorMinute: anchorMinute,
                items: items,
                sortOrder: sortOrder,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutinesTableTable, RoutineRow>(table),
                  $$RoutinesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$RoutinesTableTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$RoutinesTableTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutinesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutinesTableTable,
      RoutineRow,
      $$RoutinesTableTableFilterComposer,
      $$RoutinesTableTableOrderingComposer,
      $$RoutinesTableTableAnnotationComposer,
      $$RoutinesTableTableCreateCompanionBuilder,
      $$RoutinesTableTableUpdateCompanionBuilder,
      (RoutineRow, $$RoutinesTableTableReferences),
      RoutineRow,
      PrefetchHooks Function({bool userId})
    >;
typedef $$RevealHintsTableTableCreateCompanionBuilder =
    RevealHintsTableCompanion Function({
      required int createdAt,
      required int updatedAt,
      Value<bool> dirty,
      Value<int> version,
      required String id,
      required String userId,
      required String hintId,
      Value<int> shownCount,
      Value<int?> lastShownUtc,
      Value<int?> dismissedAtUtc,
      Value<int> rowid,
    });
typedef $$RevealHintsTableTableUpdateCompanionBuilder =
    RevealHintsTableCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> dirty,
      Value<int> version,
      Value<String> id,
      Value<String> userId,
      Value<String> hintId,
      Value<int> shownCount,
      Value<int?> lastShownUtc,
      Value<int?> dismissedAtUtc,
      Value<int> rowid,
    });

final class $$RevealHintsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $RevealHintsTableTable, RevealHintRow> {
  $$RevealHintsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _userIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('reveal_hints__user_id__profiles__id');

  $$ProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RevealHintsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RevealHintsTableTable> {
  $$RevealHintsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hintId => $composableBuilder(
    column: $table.hintId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shownCount => $composableBuilder(
    column: $table.shownCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastShownUtc => $composableBuilder(
    column: $table.lastShownUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dismissedAtUtc => $composableBuilder(
    column: $table.dismissedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get userId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevealHintsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RevealHintsTableTable> {
  $$RevealHintsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hintId => $composableBuilder(
    column: $table.hintId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shownCount => $composableBuilder(
    column: $table.shownCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastShownUtc => $composableBuilder(
    column: $table.lastShownUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dismissedAtUtc => $composableBuilder(
    column: $table.dismissedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get userId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevealHintsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RevealHintsTableTable> {
  $$RevealHintsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hintId =>
      $composableBuilder(column: $table.hintId, builder: (column) => column);

  GeneratedColumn<int> get shownCount => $composableBuilder(
    column: $table.shownCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastShownUtc => $composableBuilder(
    column: $table.lastShownUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dismissedAtUtc => $composableBuilder(
    column: $table.dismissedAtUtc,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get userId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevealHintsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RevealHintsTableTable,
          RevealHintRow,
          $$RevealHintsTableTableFilterComposer,
          $$RevealHintsTableTableOrderingComposer,
          $$RevealHintsTableTableAnnotationComposer,
          $$RevealHintsTableTableCreateCompanionBuilder,
          $$RevealHintsTableTableUpdateCompanionBuilder,
          (RevealHintRow, $$RevealHintsTableTableReferences),
          RevealHintRow,
          PrefetchHooks Function({bool userId})
        > {
  $$RevealHintsTableTableTableManager(
    _$AppDatabase db,
    $RevealHintsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RevealHintsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RevealHintsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RevealHintsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> hintId = const Value.absent(),
                Value<int> shownCount = const Value.absent(),
                Value<int?> lastShownUtc = const Value.absent(),
                Value<int?> dismissedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RevealHintsTableCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                version: version,
                id: id,
                userId: userId,
                hintId: hintId,
                shownCount: shownCount,
                lastShownUtc: lastShownUtc,
                dismissedAtUtc: dismissedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                Value<bool> dirty = const Value.absent(),
                Value<int> version = const Value.absent(),
                required String id,
                required String userId,
                required String hintId,
                Value<int> shownCount = const Value.absent(),
                Value<int?> lastShownUtc = const Value.absent(),
                Value<int?> dismissedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RevealHintsTableCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                version: version,
                id: id,
                userId: userId,
                hintId: hintId,
                shownCount: shownCount,
                lastShownUtc: lastShownUtc,
                dismissedAtUtc: dismissedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RevealHintsTableTable, RevealHintRow>(table),
                  $$RevealHintsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$RevealHintsTableTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$RevealHintsTableTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RevealHintsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RevealHintsTableTable,
      RevealHintRow,
      $$RevealHintsTableTableFilterComposer,
      $$RevealHintsTableTableOrderingComposer,
      $$RevealHintsTableTableAnnotationComposer,
      $$RevealHintsTableTableCreateCompanionBuilder,
      $$RevealHintsTableTableUpdateCompanionBuilder,
      (RevealHintRow, $$RevealHintsTableTableReferences),
      RevealHintRow,
      PrefetchHooks Function({bool userId})
    >;
typedef $$ConflictsTableCreateCompanionBuilder =
    ConflictsCompanion Function({
      required String id,
      required String userId,
      required String entity,
      required String entityId,
      required String field,
      Value<String?> mine,
      Value<String?> theirs,
      required int createdAt,
      Value<int?> resolvedAt,
      Value<int> rowid,
    });
typedef $$ConflictsTableUpdateCompanionBuilder =
    ConflictsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> entity,
      Value<String> entityId,
      Value<String> field,
      Value<String?> mine,
      Value<String?> theirs,
      Value<int> createdAt,
      Value<int?> resolvedAt,
      Value<int> rowid,
    });

final class $$ConflictsTableReferences
    extends BaseReferences<_$AppDatabase, $ConflictsTable, ConflictRow> {
  $$ConflictsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _userIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('conflicts__user_id__profiles__id');

  $$ProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $ConflictsTable> {
  $$ConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mine => $composableBuilder(
    column: $table.mine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theirs => $composableBuilder(
    column: $table.theirs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get userId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConflictsTable> {
  $$ConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mine => $composableBuilder(
    column: $table.mine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theirs => $composableBuilder(
    column: $table.theirs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get userId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConflictsTable> {
  $$ConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get mine =>
      $composableBuilder(column: $table.mine, builder: (column) => column);

  GeneratedColumn<String> get theirs =>
      $composableBuilder(column: $table.theirs, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get userId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConflictsTable,
          ConflictRow,
          $$ConflictsTableFilterComposer,
          $$ConflictsTableOrderingComposer,
          $$ConflictsTableAnnotationComposer,
          $$ConflictsTableCreateCompanionBuilder,
          $$ConflictsTableUpdateCompanionBuilder,
          (ConflictRow, $$ConflictsTableReferences),
          ConflictRow,
          PrefetchHooks Function({bool userId})
        > {
  $$ConflictsTableTableManager(_$AppDatabase db, $ConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String?> mine = const Value.absent(),
                Value<String?> theirs = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConflictsCompanion(
                id: id,
                userId: userId,
                entity: entity,
                entityId: entityId,
                field: field,
                mine: mine,
                theirs: theirs,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String entity,
                required String entityId,
                required String field,
                Value<String?> mine = const Value.absent(),
                Value<String?> theirs = const Value.absent(),
                required int createdAt,
                Value<int?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConflictsCompanion.insert(
                id: id,
                userId: userId,
                entity: entity,
                entityId: entityId,
                field: field,
                mine: mine,
                theirs: theirs,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConflictsTable, ConflictRow>(table),
                  $$ConflictsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$ConflictsTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$ConflictsTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConflictsTable,
      ConflictRow,
      $$ConflictsTableFilterComposer,
      $$ConflictsTableOrderingComposer,
      $$ConflictsTableAnnotationComposer,
      $$ConflictsTableCreateCompanionBuilder,
      $$ConflictsTableUpdateCompanionBuilder,
      (ConflictRow, $$ConflictsTableReferences),
      ConflictRow,
      PrefetchHooks Function({bool userId})
    >;
typedef $$ChangeLogTableCreateCompanionBuilder =
    ChangeLogCompanion Function({
      Value<int> seq,
      required String entity,
      required String entityId,
      required String field,
      required String value,
      required String hlc,
    });
typedef $$ChangeLogTableUpdateCompanionBuilder =
    ChangeLogCompanion Function({
      Value<int> seq,
      Value<String> entity,
      Value<String> entityId,
      Value<String> field,
      Value<String> value,
      Value<String> hlc,
    });

class $$ChangeLogTableFilterComposer
    extends Composer<_$AppDatabase, $ChangeLogTable> {
  $$ChangeLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChangeLogTableOrderingComposer
    extends Composer<_$AppDatabase, $ChangeLogTable> {
  $$ChangeLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChangeLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChangeLogTable> {
  $$ChangeLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);
}

class $$ChangeLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChangeLogTable,
          ChangeLogRow,
          $$ChangeLogTableFilterComposer,
          $$ChangeLogTableOrderingComposer,
          $$ChangeLogTableAnnotationComposer,
          $$ChangeLogTableCreateCompanionBuilder,
          $$ChangeLogTableUpdateCompanionBuilder,
          (
            ChangeLogRow,
            BaseReferences<_$AppDatabase, $ChangeLogTable, ChangeLogRow>,
          ),
          ChangeLogRow,
          PrefetchHooks Function()
        > {
  $$ChangeLogTableTableManager(_$AppDatabase db, $ChangeLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChangeLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChangeLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChangeLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> hlc = const Value.absent(),
              }) => ChangeLogCompanion(
                seq: seq,
                entity: entity,
                entityId: entityId,
                field: field,
                value: value,
                hlc: hlc,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String entity,
                required String entityId,
                required String field,
                required String value,
                required String hlc,
              }) => ChangeLogCompanion.insert(
                seq: seq,
                entity: entity,
                entityId: entityId,
                field: field,
                value: value,
                hlc: hlc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChangeLogTable, ChangeLogRow>(table),
                  BaseReferences<_$AppDatabase, $ChangeLogTable, ChangeLogRow>(
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

typedef $$ChangeLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChangeLogTable,
      ChangeLogRow,
      $$ChangeLogTableFilterComposer,
      $$ChangeLogTableOrderingComposer,
      $$ChangeLogTableAnnotationComposer,
      $$ChangeLogTableCreateCompanionBuilder,
      $$ChangeLogTableUpdateCompanionBuilder,
      (
        ChangeLogRow,
        BaseReferences<_$AppDatabase, $ChangeLogTable, ChangeLogRow>,
      ),
      ChangeLogRow,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String entity,
      required int sinceUtc,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> entity,
      Value<int> sinceUtc,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sinceUtc => $composableBuilder(
    column: $table.sinceUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sinceUtc => $composableBuilder(
    column: $table.sinceUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<int> get sinceUtc =>
      $composableBuilder(column: $table.sinceUtc, builder: (column) => column);
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursorRow,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursorRow,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>,
          ),
          SyncCursorRow,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<int> sinceUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                entity: entity,
                sinceUtc: sinceUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required int sinceUtc,
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                entity: entity,
                sinceUtc: sinceUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursorRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncCursorsTable,
                    SyncCursorRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursorRow,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursorRow,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>,
      ),
      SyncCursorRow,
      PrefetchHooks Function()
    >;
typedef $$FieldSeenTableCreateCompanionBuilder =
    FieldSeenCompanion Function({
      required String entity,
      required String entityId,
      required String field,
      required String hlc,
      Value<int> rowid,
    });
typedef $$FieldSeenTableUpdateCompanionBuilder =
    FieldSeenCompanion Function({
      Value<String> entity,
      Value<String> entityId,
      Value<String> field,
      Value<String> hlc,
      Value<int> rowid,
    });

class $$FieldSeenTableFilterComposer
    extends Composer<_$AppDatabase, $FieldSeenTable> {
  $$FieldSeenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FieldSeenTableOrderingComposer
    extends Composer<_$AppDatabase, $FieldSeenTable> {
  $$FieldSeenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FieldSeenTableAnnotationComposer
    extends Composer<_$AppDatabase, $FieldSeenTable> {
  $$FieldSeenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);
}

class $$FieldSeenTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FieldSeenTable,
          FieldSeenRow,
          $$FieldSeenTableFilterComposer,
          $$FieldSeenTableOrderingComposer,
          $$FieldSeenTableAnnotationComposer,
          $$FieldSeenTableCreateCompanionBuilder,
          $$FieldSeenTableUpdateCompanionBuilder,
          (
            FieldSeenRow,
            BaseReferences<_$AppDatabase, $FieldSeenTable, FieldSeenRow>,
          ),
          FieldSeenRow,
          PrefetchHooks Function()
        > {
  $$FieldSeenTableTableManager(_$AppDatabase db, $FieldSeenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FieldSeenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FieldSeenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FieldSeenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FieldSeenCompanion(
                entity: entity,
                entityId: entityId,
                field: field,
                hlc: hlc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required String entityId,
                required String field,
                required String hlc,
                Value<int> rowid = const Value.absent(),
              }) => FieldSeenCompanion.insert(
                entity: entity,
                entityId: entityId,
                field: field,
                hlc: hlc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FieldSeenTable, FieldSeenRow>(table),
                  BaseReferences<_$AppDatabase, $FieldSeenTable, FieldSeenRow>(
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

typedef $$FieldSeenTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FieldSeenTable,
      FieldSeenRow,
      $$FieldSeenTableFilterComposer,
      $$FieldSeenTableOrderingComposer,
      $$FieldSeenTableAnnotationComposer,
      $$FieldSeenTableCreateCompanionBuilder,
      $$FieldSeenTableUpdateCompanionBuilder,
      (
        FieldSeenRow,
        BaseReferences<_$AppDatabase, $FieldSeenTable, FieldSeenRow>,
      ),
      FieldSeenRow,
      PrefetchHooks Function()
    >;
typedef $$LocalMetaTableCreateCompanionBuilder =
    LocalMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$LocalMetaTableUpdateCompanionBuilder =
    LocalMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$LocalMetaTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMetaTable> {
  $$LocalMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMetaTable> {
  $$LocalMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMetaTable> {
  $$LocalMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$LocalMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMetaTable,
          LocalMetaRow,
          $$LocalMetaTableFilterComposer,
          $$LocalMetaTableOrderingComposer,
          $$LocalMetaTableAnnotationComposer,
          $$LocalMetaTableCreateCompanionBuilder,
          $$LocalMetaTableUpdateCompanionBuilder,
          (
            LocalMetaRow,
            BaseReferences<_$AppDatabase, $LocalMetaTable, LocalMetaRow>,
          ),
          LocalMetaRow,
          PrefetchHooks Function()
        > {
  $$LocalMetaTableTableManager(_$AppDatabase db, $LocalMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => LocalMetaCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalMetaTable, LocalMetaRow>(table),
                  BaseReferences<_$AppDatabase, $LocalMetaTable, LocalMetaRow>(
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

typedef $$LocalMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMetaTable,
      LocalMetaRow,
      $$LocalMetaTableFilterComposer,
      $$LocalMetaTableOrderingComposer,
      $$LocalMetaTableAnnotationComposer,
      $$LocalMetaTableCreateCompanionBuilder,
      $$LocalMetaTableUpdateCompanionBuilder,
      (
        LocalMetaRow,
        BaseReferences<_$AppDatabase, $LocalMetaTable, LocalMetaRow>,
      ),
      LocalMetaRow,
      PrefetchHooks Function()
    >;
typedef $$WakeUpDaysTableTableCreateCompanionBuilder =
    WakeUpDaysTableCompanion Function({
      required String date,
      Value<int?> rangAtUtc,
      Value<int?> stoppedAtUtc,
      Value<int> snoozes,
      Value<int?> cardShownAtUtc,
      Value<int?> startedAtUtc,
      Value<int> rowid,
    });
typedef $$WakeUpDaysTableTableUpdateCompanionBuilder =
    WakeUpDaysTableCompanion Function({
      Value<String> date,
      Value<int?> rangAtUtc,
      Value<int?> stoppedAtUtc,
      Value<int> snoozes,
      Value<int?> cardShownAtUtc,
      Value<int?> startedAtUtc,
      Value<int> rowid,
    });

class $$WakeUpDaysTableTableFilterComposer
    extends Composer<_$AppDatabase, $WakeUpDaysTableTable> {
  $$WakeUpDaysTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rangAtUtc => $composableBuilder(
    column: $table.rangAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stoppedAtUtc => $composableBuilder(
    column: $table.stoppedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozes => $composableBuilder(
    column: $table.snoozes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardShownAtUtc => $composableBuilder(
    column: $table.cardShownAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WakeUpDaysTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WakeUpDaysTableTable> {
  $$WakeUpDaysTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rangAtUtc => $composableBuilder(
    column: $table.rangAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stoppedAtUtc => $composableBuilder(
    column: $table.stoppedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozes => $composableBuilder(
    column: $table.snoozes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardShownAtUtc => $composableBuilder(
    column: $table.cardShownAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WakeUpDaysTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WakeUpDaysTableTable> {
  $$WakeUpDaysTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get rangAtUtc =>
      $composableBuilder(column: $table.rangAtUtc, builder: (column) => column);

  GeneratedColumn<int> get stoppedAtUtc => $composableBuilder(
    column: $table.stoppedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozes =>
      $composableBuilder(column: $table.snoozes, builder: (column) => column);

  GeneratedColumn<int> get cardShownAtUtc => $composableBuilder(
    column: $table.cardShownAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => column,
  );
}

class $$WakeUpDaysTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WakeUpDaysTableTable,
          WakeUpDayRow,
          $$WakeUpDaysTableTableFilterComposer,
          $$WakeUpDaysTableTableOrderingComposer,
          $$WakeUpDaysTableTableAnnotationComposer,
          $$WakeUpDaysTableTableCreateCompanionBuilder,
          $$WakeUpDaysTableTableUpdateCompanionBuilder,
          (
            WakeUpDayRow,
            BaseReferences<_$AppDatabase, $WakeUpDaysTableTable, WakeUpDayRow>,
          ),
          WakeUpDayRow,
          PrefetchHooks Function()
        > {
  $$WakeUpDaysTableTableTableManager(
    _$AppDatabase db,
    $WakeUpDaysTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WakeUpDaysTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WakeUpDaysTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WakeUpDaysTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int?> rangAtUtc = const Value.absent(),
                Value<int?> stoppedAtUtc = const Value.absent(),
                Value<int> snoozes = const Value.absent(),
                Value<int?> cardShownAtUtc = const Value.absent(),
                Value<int?> startedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WakeUpDaysTableCompanion(
                date: date,
                rangAtUtc: rangAtUtc,
                stoppedAtUtc: stoppedAtUtc,
                snoozes: snoozes,
                cardShownAtUtc: cardShownAtUtc,
                startedAtUtc: startedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                Value<int?> rangAtUtc = const Value.absent(),
                Value<int?> stoppedAtUtc = const Value.absent(),
                Value<int> snoozes = const Value.absent(),
                Value<int?> cardShownAtUtc = const Value.absent(),
                Value<int?> startedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WakeUpDaysTableCompanion.insert(
                date: date,
                rangAtUtc: rangAtUtc,
                stoppedAtUtc: stoppedAtUtc,
                snoozes: snoozes,
                cardShownAtUtc: cardShownAtUtc,
                startedAtUtc: startedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WakeUpDaysTableTable, WakeUpDayRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WakeUpDaysTableTable,
                    WakeUpDayRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WakeUpDaysTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WakeUpDaysTableTable,
      WakeUpDayRow,
      $$WakeUpDaysTableTableFilterComposer,
      $$WakeUpDaysTableTableOrderingComposer,
      $$WakeUpDaysTableTableAnnotationComposer,
      $$WakeUpDaysTableTableCreateCompanionBuilder,
      $$WakeUpDaysTableTableUpdateCompanionBuilder,
      (
        WakeUpDayRow,
        BaseReferences<_$AppDatabase, $WakeUpDaysTableTable, WakeUpDayRow>,
      ),
      WakeUpDayRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $SearchIndexTableManager get searchIndex =>
      $SearchIndexTableManager(_db, _db.searchIndex);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$SeriesTableTableTableManager get seriesTable =>
      $$SeriesTableTableTableManager(_db, _db.seriesTable);
  $$CalendarAccountsTableTableManager get calendarAccounts =>
      $$CalendarAccountsTableTableManager(_db, _db.calendarAccounts);
  $$CalendarLinksTableTableManager get calendarLinks =>
      $$CalendarLinksTableTableManager(_db, _db.calendarLinks);
  $$OccurrencesTableTableManager get occurrences =>
      $$OccurrencesTableTableManager(_db, _db.occurrences);
  $$SubtasksTableTableManager get subtasks =>
      $$SubtasksTableTableManager(_db, _db.subtasks);
  $$RoutinesTableTableTableManager get routinesTable =>
      $$RoutinesTableTableTableManager(_db, _db.routinesTable);
  $$RevealHintsTableTableTableManager get revealHintsTable =>
      $$RevealHintsTableTableTableManager(_db, _db.revealHintsTable);
  $$ConflictsTableTableManager get conflicts =>
      $$ConflictsTableTableManager(_db, _db.conflicts);
  $$ChangeLogTableTableManager get changeLog =>
      $$ChangeLogTableTableManager(_db, _db.changeLog);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$FieldSeenTableTableManager get fieldSeen =>
      $$FieldSeenTableTableManager(_db, _db.fieldSeen);
  $$LocalMetaTableTableManager get localMeta =>
      $$LocalMetaTableTableManager(_db, _db.localMeta);
  $$WakeUpDaysTableTableTableManager get wakeUpDaysTable =>
      $$WakeUpDaysTableTableTableManager(_db, _db.wakeUpDaysTable);
}
