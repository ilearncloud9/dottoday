import 'package:dottoday/core/utils/switch_map.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_view.g.dart';

/// One task with what its sheet shows (docs/10 §3 `TaskSheet`).
final class TaskView {
  const TaskView({
    required this.occurrence,
    required this.subtasks,
    required this.series,
  });

  final Occurrence occurrence;

  /// This occurrence's own checklist (R-09), in order.
  final List<Subtask> subtasks;

  /// Its series when it repeats.
  final Series? series;

  /// The alerts that apply: its own, else its series' (docs/05).
  List<Alert> get alerts => occurrence.alerts ?? series?.alerts ?? const [];
}

/// The live task [id] of the current user, or null when there is none:
/// unknown, deleted or another user's id all read as not found (06 §9:
/// the id is looked up under the current user only).
@riverpod
Stream<TaskView?> taskView(Ref ref, String id) {
  final profile = ref.watch(currentProfileProvider.future);
  final occurrences = ref.watch(occurrenceRepositoryProvider);
  final subtasks = ref.watch(subtaskRepositoryProvider);
  final seriesRepo = ref.watch(seriesRepositoryProvider);
  return Stream.fromFuture(profile).asyncExpand((profile) async* {
    final first = await occurrences.findById(profile.id, id);
    if (first == null || first.deletedAt != null) {
      yield null;
      return;
    }
    final series = first.seriesId == null
        ? null
        : await seriesRepo.findById(profile.id, first.seriesId!);
    yield* _watch(occurrences, profile.id, first).switchMap(
      (o) => o == null
          ? Stream.value(null)
          : subtasks
                .watchForOccurrences(profile.id, {o.id})
                .map(
                  (s) => TaskView(occurrence: o, subtasks: s, series: series),
                ),
    );
  });
}

/// [first] as it changes. Inbox items and timed ones are both watched
/// through a window wide enough that a move by a day still finds it.
Stream<Occurrence?> _watch(
  OccurrenceRepository occurrences,
  String userId,
  Occurrence first,
) {
  final start = first.startUtc;
  final rows = start == null
      ? occurrences.watchInbox(userId)
      : occurrences.watchRange(
          userId,
          start.subtract(const Duration(days: 2)),
          start.add(const Duration(days: 3)),
        );
  return rows.map((all) => all.where((o) => o.id == first.id).firstOrNull);
}
