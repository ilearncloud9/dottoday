import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/dev/demo_day.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'demo_day_loader.g.dart';

/// Writes the demo day (see `demo_day.dart`) for today in the profile's
/// zone. DEBUG ONLY: every caller sits behind [kDebugMode], so this and the
/// demo data are compiled out of release builds.
final class DemoDayLoader {
  DemoDayLoader({
    required Future<Profile> Function() profile,
    required WriteUseCase writes,
    required Clock clock,
  }) : _profile = profile,
       _writes = writes,
       _clock = clock;

  final Future<Profile> Function() _profile;
  final WriteUseCase _writes;
  final Clock _clock;

  /// Loads (or resets) today's demo rows.
  Future<Result<void, AppFailure>> load() async {
    assert(kDebugMode, 'The demo day is a debug-only tool.');
    final profile = await _profile();
    final location = tz.getLocation(profile.tzId);
    final now = _clock.nowUtc();
    final today = tz.TZDateTime.from(now, location);
    return _writes.apply(
      buildDemoDay(
        userId: profile.id,
        location: location,
        date: DateTime(today.year, today.month, today.day),
        nowUtc: now,
      ),
    );
  }
}

@riverpod
DemoDayLoader demoDayLoader(Ref ref) => DemoDayLoader(
  profile: () => ref.read(localProfileProvider.future),
  writes: ref.watch(writeUseCaseProvider),
  clock: ref.watch(clockProvider),
);
