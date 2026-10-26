import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/scheduling/energy_window.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:dottoday/domain/scheduling/learning_thresholds.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'learning_providers.g.dart';

/// The numbers learning answers by (docs/13 §2); tests override it.
@Riverpod(keepAlive: true)
LearningThresholds learningThresholds(Ref ref) => LearningThresholds.standard;

/// The user's last [LearningThresholds.historyDays] days, live: what learning (11 C3)
/// and energy suggestions (11 C4) read. On this device's data only.
@riverpod
Stream<List<Occurrence>> learningHistory(Ref ref) {
  final profile = ref.watch(currentProfileProvider.future);
  final repo = ref.watch(occurrenceRepositoryProvider);
  final now = ref.watch(clockProvider).nowUtc();
  final days = ref.watch(learningThresholdsProvider).historyDays;
  return Stream.fromFuture(profile).asyncExpand(
    (p) => repo.watchRange(
      p.id,
      now.subtract(Duration(days: days)),
      now.add(const Duration(days: 1)),
    ),
  );
}

/// What the history says per task (11 C3, docs/09 M11.3).
@riverpod
Future<LearningIndex> learningIndex(Ref ref) async {
  final thresholds = ref.watch(learningThresholdsProvider);
  return LearningIndex.from(
    await ref.watch(learningHistoryProvider.future),
    thresholds: thresholds,
  );
}

/// [learningIndex] read once, for kept-alive callers that ask now and
/// then (B4's length suggestion) and must not hold the live stream open.
Future<LearningIndex> readLearningIndex(Ref ref) async {
  final thresholds = ref.read(learningThresholdsProvider);
  // Held while awaited: nothing else may be watching the profile now, and
  // an unwatched auto-dispose provider would go before it answers.
  final hold = ref.listen(currentProfileProvider, (_, _) {});
  final Profile profile;
  try {
    profile = await ref.read(currentProfileProvider.future);
  } finally {
    hold.close();
  }
  final now = ref.read(clockProvider).nowUtc();
  final rows = await ref
      .read(occurrenceRepositoryProvider)
      .watchRange(
        profile.id,
        now.subtract(Duration(days: thresholds.historyDays)),
        now.add(const Duration(days: 1)),
      )
      .first;
  return LearningIndex.from(rows, thresholds: thresholds);
}

/// When the user finishes high-energy work best, and how many such tasks
/// it is read from (11 C4, docs/09 M11.5); the window is null under
/// [LearningThresholds.energyMinCompletions].
@riverpod
Future<({EnergyWindow? window, int completions})> energyWindow(Ref ref) async {
  final thresholds = ref.watch(learningThresholdsProvider);
  final history = await ref.watch(learningHistoryProvider.future);
  final profile = await ref.watch(currentProfileProvider.future);
  return (
    window: bestEnergyWindow(
      history,
      tz.getLocation(profile.tzId),
      thresholds: thresholds,
    ),
    completions: highEnergyRuns(history).length,
  );
}
