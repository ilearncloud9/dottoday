import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'learning_providers.g.dart';

/// How far back learning looks: ten runs of a weekly task fit.
const learningHistoryDays = 90;

/// What the user's last [learningHistoryDays] days of actual timestamps
/// say per task (11 C3, docs/09 M11.3), live. On this device's data only.
@riverpod
Stream<LearningIndex> learningIndex(Ref ref) {
  final profile = ref.watch(currentProfileProvider.future);
  final repo = ref.watch(occurrenceRepositoryProvider);
  final now = ref.watch(clockProvider).nowUtc();
  return Stream.fromFuture(profile).asyncExpand(
    (p) => repo
        .watchRange(
          p.id,
          now.subtract(const Duration(days: learningHistoryDays)),
          now.add(const Duration(days: 1)),
        )
        .map(LearningIndex.from),
  );
}
