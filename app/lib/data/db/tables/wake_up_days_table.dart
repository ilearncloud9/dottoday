import 'package:drift/drift.dart';

/// The Wake Up alarm and card per civil day on this device (docs/15 §3,
/// M17.3). Local only, like `local_meta`: no user, no sync columns. Times
/// are epoch milliseconds, UTC. Schema 10.
@DataClassName('WakeUpDayRow')
class WakeUpDaysTable extends Table {
  @override
  String get tableName => 'wake_up_days';

  /// `yyyy-MM-dd` in the profile's zone.
  TextColumn get date => text()();
  IntColumn get rangAtUtc => integer().nullable()();
  IntColumn get stoppedAtUtc => integer().nullable()();
  IntColumn get snoozes => integer().withDefault(const Constant(0))();
  IntColumn get cardShownAtUtc => integer().nullable()();
  IntColumn get startedAtUtc => integer().nullable()();

  /// "Can't right now" skipped the mission (15 §8). Schema 12.
  IntColumn get missionSkippedAtUtc => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {date};

  @override
  List<String> get customConstraints => const [
    "CHECK (date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')",
    'CHECK (snoozes >= 0)',
  ];

  @override
  bool get isStrict => true;
}
