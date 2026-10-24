import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/calendar/drift_calendar_source_repository.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../../support/fake_clock.dart';

// Per-calendar switches (docs/02 F5, docs/09 M7.1): one local
// `calendar_accounts` row per device calendar the person has switched.

final class _Ids implements IdGenerator {
  var _n = 0;

  @override
  String newId() => 'id-${++_n}';
}

void main() {
  late AppDatabase db;
  late DriftCalendarSourceRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await DriftSettingsRepository(db).upsert(profileFixture());
    repo = DriftCalendarSourceRepository(
      db,
      provider: CalendarProvider.appleDevice,
      clock: FakeClock(DateTime.utc(2026, 10, 21, 9)),
      ids: _Ids(),
    );
  });
  tearDown(() => db.close());

  const work = DeviceCalendar(id: 'cal-work', name: 'Work');

  test('the first switch creates the row; later ones update it', () async {
    await repo.setEnabled(userId, work, enabled: false);
    var rows = await repo.watchDevice(userId).first;
    expect(rows, hasLength(1));
    expect(rows.single.externalAccountId, 'cal-work');
    expect(rows.single.provider, CalendarProvider.appleDevice);
    expect(rows.single.label, 'Work');
    expect(rows.single.enabled, isFalse);

    await repo.setEnabled(userId, work, enabled: true);
    rows = await repo.watchDevice(userId).first;
    expect(rows, hasLength(1));
    expect(rows.single.id, 'id-1');
    expect(rows.single.enabled, isTrue);
  });

  test('a long calendar name fits the label limit', () async {
    final long = DeviceCalendar(id: 'cal-long', name: 'x' * 200);
    await repo.setEnabled(userId, long, enabled: true);
    final rows = await repo.watchDevice(userId).first;
    expect(rows.single.label, hasLength(80));
  });

  test('another user sees none of them', () async {
    await repo.setEnabled(userId, work, enabled: true);
    expect(await repo.watchDevice('someone-else').first, isEmpty);
  });

  test('a connected calendar keeps its own provider (M7.4)', () async {
    const google = DeviceCalendar(
      id: '0192f000-0000-7000-8000-000000000001/primary',
      name: 'Kody',
      provider: CalendarProvider.google,
    );
    await repo.setWriteBack(userId, google, writeBack: true);
    await repo.setEnabled(userId, work, enabled: false);
    final cloud = await repo.watchCloud(userId).first;
    expect(cloud.single.provider, CalendarProvider.google);
    expect(cloud.single.externalAccountId, google.id);
    expect(cloud.single.writeBack, isTrue);
    final device = await repo.watchDevice(userId).first;
    expect(device.single.externalAccountId, 'cal-work');
    expect((await repo.ensure(userId, google)).id, cloud.single.id);
  });
}
