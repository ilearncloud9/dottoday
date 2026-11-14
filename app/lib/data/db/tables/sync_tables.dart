import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:drift/drift.dart';

/// Same-field edits within 60 s awaiting "keep mine / theirs" (docs/05
/// `conflicts`, ADR-0002).
@DataClassName('ConflictRow')
@TableIndex.sql(
  'CREATE INDEX conflicts_open ON conflicts (user_id) WHERE resolved_at IS NULL',
)
class Conflicts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get field => text()();

  /// JSON-encoded field values (`null` allowed).
  TextColumn get mine => text().nullable()();
  TextColumn get theirs => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get resolvedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    "CHECK (entity IN ('series', 'occurrences', 'subtasks', 'profiles', "
        "'routines', 'reveal_hints'))",
    'CHECK (length(field) <= 64)',
    'CHECK (mine IS NULL OR json_valid(mine))',
    'CHECK (theirs IS NULL OR json_valid(theirs))',
  ];

  @override
  bool get isStrict => true;
}

/// Local-only outbox: one row per field written locally, pushed in [seq]
/// order via `sync_push` (docs/04 §4). Rows are deleted once acknowledged.
@DataClassName('ChangeLogRow')
@TableIndex(name: 'change_log_entity', columns: {#entity, #entityId})
@TableIndex(name: 'change_log_owner', columns: {#ownerId})
class ChangeLog extends Table {
  IntColumn get seq => integer().autoIncrement()();

  /// Whose change this is (CR-160): the guest profile or one account. Only
  /// that account's sync pushes it. Follows a guest's re-key to the account
  /// it is adopted into; no delete action, so a profile with pending work
  /// can't be removed (never silent loss, R-08).
  TextColumn get ownerId =>
      text().references(Profiles, #id, onUpdate: KeyAction.cascade)();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get field => text()();

  /// JSON-encoded new value of [field].
  TextColumn get value => text()();

  /// Fixed-width HLC string (`Hlc`, ADR-0002); string order = clock order.
  TextColumn get hlc => text()();

  @override
  List<String> get customConstraints => const [
    // The `sync_push` allow-list (supabase/migrations/0002).
    "CHECK (entity IN ('series', 'occurrences', 'subtasks', 'profiles', "
        "'routines', 'reveal_hints'))",
    'CHECK (length(field) <= 64)',
    'CHECK (json_valid(value))',
  ];

  @override
  bool get isStrict => true;
}

/// Local-only pull cursors: the last row pulled per table, in the server's
/// (`updated_at`, `id`) order (docs/04 §4 "periodic since pull").
@DataClassName('SyncCursorRow')
class SyncCursors extends Table {
  /// The account whose pull this is (CR-160): each account on the device
  /// resumes its own pull.
  TextColumn get ownerId => text()();
  TextColumn get entity => text()();
  IntColumn get sinceUtc => integer()();

  /// That row's `updated_at` exactly as the server sent it (microseconds,
  /// which [sinceUtc] drops) and its id: the keyset the next pull resumes
  /// after. One `sync_push` stamps all its rows with one instant, so the
  /// id is what moves past a page of them. Null on a cursor from before
  /// v17, which resumes from [sinceUtc] on.
  TextColumn get sinceAt => text().nullable()();
  TextColumn get sinceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, entity};

  @override
  bool get isStrict => true;
}

/// Local-only key/value state that must survive restarts but is not user
/// data: the HLC node id and last issued HLC (ADR-0002).
@DataClassName('LocalMetaRow')
class LocalMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};

  @override
  bool get isStrict => true;
}

/// Local-only: the server's HLC per field as last pulled (docs/09 M6.2).
/// A pending local edit conflicts only with a server version this device
/// had not seen yet; one it had seen is the base the edit was made on.
@DataClassName('FieldSeenRow')
class FieldSeen extends Table {
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get field => text()();
  TextColumn get hlc => text()();

  @override
  Set<Column<Object>> get primaryKey => {entity, entityId, field};

  @override
  bool get isStrict => true;
}

/// Local-only (CR-160): which guest session first wrote each guest row.
/// A session is a random id in `local_meta` (`guest_session`), replaced at
/// every change of owner on the device (sign-in, sign-out, account removal),
/// so it doesn't depend on clocks and survives restarts and offline use. Only
/// rows first written in the current session may be brought into an account.
/// A row with no entry (written before schema 19) is never eligible.
@DataClassName('GuestRowSessionRow')
class GuestRowSessions extends Table {
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get session => text()();

  @override
  Set<Column<Object>> get primaryKey => {entity, entityId};

  @override
  bool get isStrict => true;
}
