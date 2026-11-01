import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The task sheet's "Make sure I'm up for this" (docs/15 §8 rule 5) for
/// [occurrenceId]. Flags whose dot has started, gone or been deleted are
/// dropped on the way, so each lasts one morning. The alarm re-arms
/// after the write like any other (after-write effects).
Future<Result<void, AppFailure>> setMissionFlag(
  ProviderContainer container, {
  required String userId,
  required String occurrenceId,
  required bool on,
}) async {
  final now = container.read(clockProvider).nowUtc();
  final profile = await readProfile(container);
  final repo = container.read(occurrenceRepositoryProvider);
  final live = <String>{};
  for (final id in profile.settings.missionFlagIds) {
    final o = await repo.findById(userId, id);
    if (o != null && o.deletedAt == null && o.startUtc?.isAfter(now) == true) {
      live.add(id);
    }
  }
  return updateSettings(
    container,
    (s) => withMissionFlag(s, occurrenceId, on: on, live: live),
  );
}

/// The Wind Down review's "Tomorrow matters" (docs/15 §8 rule 5): flags
/// the morning of [dateKey], or clears it. One date, so it clears itself
/// once that day has come.
Future<Result<void, AppFailure>> setTomorrowMatters(
  ProviderContainer container, {
  required String dateKey,
  required bool on,
}) => updateSettings(
  container,
  (s) => s.copyWith(missionFlagDate: on ? dateKey : null),
);
