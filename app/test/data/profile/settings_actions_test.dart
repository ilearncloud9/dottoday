import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/profile/local_profile_service.dart';
import 'package:dottoday/domain/time/duration_presets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_ids.dart';
import '../writes/write_harness.dart';

final _now = DateTime.utc(2026, 10, 21, 6);

/// Duration presets persist through the real write path (docs/09 M3c.3).
void main() {
  late WriteHarness h;
  late ProviderContainer container;

  setUpAll(tz_data.initializeTimeZones);

  setUp(() async {
    h = WriteHarness(_now);
    final repo = DriftSettingsRepository(h.db);
    final service = LocalProfileService(
      settings: repo,
      writes: h.writes,
      clock: h.clock,
      ids: FakeIds('profile'),
    );
    final profile =
        (await service.ensure('Europe/Berlin')) as Ok<Profile, AppFailure>;
    container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(h.clock),
        writeUseCaseProvider.overrideWithValue(h.writes),
        settingsRepositoryProvider.overrideWithValue(repo),
        localProfileProvider.overrideWith((ref) async => profile.value),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await h.dispose();
  });

  Future<Settings> stored() async =>
      (await DriftSettingsRepository(h.db).findLocalProfile())!.settings;

  test('a fresh profile has the default presets', () async {
    expect((await stored()).durationPresets, defaultDurationPresets);
  });

  test('edited presets are written and read back', () async {
    final result = await updateSettings(
      container,
      (s) => s.copyWith(durationPresets: withPreset(s.durationPresets, 40)),
    );
    expect(result, isA<Ok<void, AppFailure>>());
    expect((await stored()).durationPresets, [15, 30, 40, 45, 60, 90, 120]);
    await updateSettings(
      container,
      (s) => s.copyWith(durationPresets: withoutPreset(s.durationPresets, 120)),
    );
    expect((await stored()).durationPresets, [15, 30, 40, 45, 60, 90]);
    await updateSettings(
      container,
      (s) => s.copyWith(durationPresets: defaultDurationPresets),
    );
    expect((await stored()).durationPresets, defaultDurationPresets);
  });

  test('an invalid list is refused and nothing changes', () async {
    final result = await updateSettings(
      container,
      (s) => s.copyWith(durationPresets: const [2]),
    );
    expect(result, isA<Err<void, AppFailure>>());
    expect((await stored()).durationPresets, defaultDurationPresets);
  });
}
