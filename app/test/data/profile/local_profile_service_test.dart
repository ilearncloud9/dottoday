import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/profile/local_profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_ids.dart';
import '../writes/write_harness.dart';

final _now = DateTime.utc(2026, 10, 21, 6);

void main() {
  late WriteHarness h;
  late LocalProfileService service;

  setUpAll(tz_data.initializeTimeZones);

  setUp(() {
    h = WriteHarness(_now);
    service = LocalProfileService(
      settings: DriftSettingsRepository(h.db),
      writes: h.writes,
      clock: h.clock,
      ids: FakeIds('profile'),
    );
  });
  tearDown(() => h.dispose());

  Profile ok(Result<Profile, AppFailure> r) =>
      (r as Ok<Profile, AppFailure>).value;

  test('creates the profile once in the device zone', () async {
    final first = ok(await service.ensure('Europe/Berlin'));
    expect(first.id, 'profile-1');
    expect(first.tzId, 'Europe/Berlin');
    expect(first.createdAt, _now);

    final again = ok(await service.ensure('America/New_York'));
    expect(again.id, 'profile-1');
    expect(again.tzId, 'Europe/Berlin');
    final stored = await DriftSettingsRepository(h.db).findLocalProfile();
    expect(stored?.id, 'profile-1');
  });

  test('an unknown device zone falls back to UTC', () async {
    expect(ok(await service.ensure('Mars/Olympus_Mons')).tzId, 'UTC');
  });

  test('a new profile starts in the device language (M8.3)', () async {
    final created = ok(await service.ensure('Europe/Berlin', language: 'de'));
    expect(created.locale, 'de');
  });
}
