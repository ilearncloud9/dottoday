import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/wake_up/tier_seen_store.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

// docs/15 §11: each look stores this phone's tier and OS build in
// local_meta; an OS update that brings the alarm tier is remembered.
void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());
  final now = DateTime.utc(2026, 11, 2, 8);

  Future<DateTime?> look(AlarmCapabilities caps, String os) async {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        alarmCapabilitiesNowProvider.overrideWith((ref) async => caps),
        osVersionProvider.overrideWithValue(os),
        clockProvider.overrideWithValue(FakeClock(now)),
      ],
    );
    addTearDown(c.dispose);
    return c.read(alarmTierGainedAtProvider.future);
  }

  const banner = AlarmCapabilities(AlarmTier.timeSensitive);
  const alarm = AlarmCapabilities(AlarmTier.alarm);

  test('first look: nothing; an update to the alarm tier: now', () async {
    expect(await look(banner, '18.6'), isNull);
    expect(await look(banner, '18.6'), isNull);
    expect(await look(alarm, '26.1'), now);
    // Remembered on later looks, until the next update.
    expect(await look(alarm, '26.1'), now);
  });

  test('the tier given on the same OS is not an update', () async {
    await look(banner, '26.1');
    expect(await look(alarm, '26.1'), isNull);
  });

  test('off a phone: nothing, and nothing stored', () async {
    expect(
      await look(
        const AlarmCapabilities(AlarmTier.none, [AlarmBlocker.notAPhone]),
        'macOS 26',
      ),
      isNull,
    );
    expect(await db.select(db.localMeta).get(), isEmpty);
  });
}
