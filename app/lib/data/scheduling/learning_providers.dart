import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/energy_window.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'learning_providers.g.dart';

/// How far back learning looks: ten runs of a weekly task fit.
const learningHistoryDays = 90;

/// The user's last [learningHistoryDays] days, live: what learning (11 C3)
/// and energy suggestions (11 C4) read. On this device's data only.
@riverpod
Stream<List<Occurrence>> learningHistory(Ref ref) {
  final profile = ref.watch(currentProfileProvider.future);
  final repo = ref.watch(occurrenceRepositoryProvider);
  final now = ref.watch(clockProvider).nowUtc();
  return Stream.fromFuture(profile).asyncExpand(
    (p) => repo.watchRange(
      p.id,
      now.subtract(const Duration(days: learningHistoryDays)),
      now.add(const Duration(days: 1)),
    ),
  );
}

/// What the history says per task (11 C3, docs/09 M11.3).
@riverpod
Future<LearningIndex> learningIndex(Ref ref) async =>
    LearningIndex.from(await ref.watch(learningHistoryProvider.future));

/// When the user finishes high-energy work best, and how many such tasks
/// it is read from (11 C4, docs/09 M11.5); the window is null under
/// [energyMinCompletions].
@riverpod
Future<({EnergyWindow? window, int completions})> energyWindow(Ref ref) async {
  final history = await ref.watch(learningHistoryProvider.future);
  final profile = await ref.watch(currentProfileProvider.future);
  return (
    window: bestEnergyWindow(history, tz.getLocation(profile.tzId)),
    completions: highEnergyRuns(history).length,
  );
}
