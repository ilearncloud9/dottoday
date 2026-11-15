import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:drift/drift.dart';

/// The account's device list as last seen (ED-084, server `devices`,
/// migration 0016): a local cache for "Alarm sounds on", refreshed from the
/// server and holding this install's own row. Not in the outbox: each
/// install writes only its own row, straight to the server. Times are epoch
/// milliseconds, UTC. Schema 18.
@DataClassName('DeviceRow')
@TableIndex(name: 'devices_user', columns: {#userId})
class DevicesTable extends Table {
  @override
  String get tableName => 'devices';

  TextColumn get id => text()();
  TextColumn get userId => text().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get platform => text()();
  TextColumn get form => text()();
  BoolColumn get canRing => boolean().withDefault(const Constant(false))();
  BoolColumn get alarmOn => boolean().withDefault(const Constant(false))();
  BoolColumn get rings => boolean().withDefault(const Constant(false))();
  IntColumn get armedWakeUtc => integer().nullable()();
  IntColumn get lastSeenUtc => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  // Mirrors the server checks in supabase/migrations/0016_devices.sql.
  @override
  List<String> get customConstraints => const [
    "CHECK (platform IN ('ios', 'android', 'macos', 'web'))",
    "CHECK (form IN ('phone', 'tablet', 'desktop'))",
    "CHECK ((platform IN ('ios', 'android') AND form IN ('phone', 'tablet')) "
        "OR (platform IN ('macos', 'web') AND form = 'desktop'))",
    "CHECK (platform IN ('ios', 'android') OR (can_ring = 0 AND alarm_on = 0 "
        'AND rings = 0 AND armed_wake_utc IS NULL))',
  ];

  @override
  bool get isStrict => true;
}
