import 'package:drift/drift.dart';

/// The Wake Up alarm and card per owner and civil day on this device
/// (docs/15 §3, M17.3). Local only, like `local_meta`: no sync columns.
/// Times are epoch milliseconds, UTC. Schema 10; per owner since 22 (CR-160
/// Wake Up audit: one person's mornings never steer another's).
@DataClassName('WakeUpDayRow')
class WakeUpDaysTable extends Table {
  @override
  String get tableName => 'wake_up_days';

  /// The profile whose morning this is; '' for rows from before 22 that
  /// no profile can claim, which no one sees.
  TextColumn get ownerId => text().withDefault(const Constant(''))();

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
  Set<Column<Object>> get primaryKey => {ownerId, date};

  @override
  List<String> get customConstraints => const [
    "CHECK (date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')",
    'CHECK (snoozes >= 0)',
  ];

  @override
  bool get isStrict => true;
}
