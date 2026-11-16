import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/intents/intent_providers.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_notification_platform.dart';
import '../../support/owner_app.dart';
import '../../support/shared_action_queue.dart';
import '../../support/timeline_fakes.dart';
import '../writes/write_harness.dart';

// The world of the CR-160 I7 queue tests (queue_owner_*_test.dart): the
// real OwnerSwitch, drainer and write path on an in-memory database, with
// a queue that behaves as the native one (stamped from the owner the app
// publishes, appended to by "another process" mid-drain or mid-switch).
// A is signed in with one task, [a1], before each test.

const ownerA = '01928c3e-0000-7000-8000-00000000000a';
const ownerB = '01928c3e-0000-7000-8000-00000000000b';

late AppDatabase db;
late SharedActionQueue queue;
late OwnerApp app;
late DriftOccurrenceRepository repo;

/// A's task.
final a1 = occurrenceFixture().copyWith(
  id: '01928c3e-0000-7000-8000-0000000001a1',
  userId: ownerA,
  tzId: 'UTC',
  startUtc: ownerAppNow.add(const Duration(hours: 1)),
  durationMin: 30,
);

/// One app run on [db] and [queue]; they outlive it, as on a device.
OwnerApp run() => OwnerApp(
  db,
  FakeNotificationPlatform(),
  FakeSink(),
  FakeAlarmGateway(),
  queue,
);

Future<void> drain() => app.container.read(actionQueueDrainerProvider).drain();

/// Rows of [owner] the share [id] made (occurrence or repeat).
Future<Occurrence?> made(String owner, String id) => repo.findById(owner, id);

/// Owners [id] exists under, whoever they are.
Future<Set<String>> ownersOf(String id) async => {
  for (final r in await (db.select(
    db.occurrences,
  )..where((o) => o.id.equals(id))).get())
    r.userId,
};

/// Change-log entries for [entityId]: an applied action, queued to sync.
Future<List<String>> pushedBy(String entityId) async => [
  for (final r in await (db.select(
    db.changeLog,
  )..where((c) => c.entityId.equals(entityId))).get())
    r.ownerId,
];

/// Registers the set-up and tear-down every queue test shares.
void useQueueWorld() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });
  setUp(() async {
    ownerAppLogs.records.clear();
    db = AppDatabase(NativeDatabase.memory());
    queue = SharedActionQueue();
    repo = DriftOccurrenceRepository(db);
    app = run();
    await app.shown();
    await app.signIn(ownerA);
    await app.write([a1]);
  });
  tearDown(() async {
    // Ids and outcomes only in the log (CLAUDE.md §4): no shared text.
    for (final r in ownerAppLogs.records) {
      expect('${r.fields}', isNot(contains('Dentist')));
    }
    app.container.dispose();
    await db.close();
  });
}
