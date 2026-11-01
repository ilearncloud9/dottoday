import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/calendar/calendar_series_actions.dart';
import 'package:dottoday/data/recurrence/series_actions.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/recurrence/series_edit.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// One door for scoped writes, whether the task repeats here (M3f.1) or is
// an instance of a repeating calendar event (docs/02 F5.7).

/// The scopes [task] offers. A calendar series has no "This and
/// following": that would split the series in the person's calendar.
List<EditScope> scopesFor(TaskView task) => task.series != null
    ? EditScope.values
    : const [EditScope.thisOne, EditScope.all];

/// [change] to [task]'s series by [scope] (beyond this one); null when
/// [task] doesn't repeat.
Future<Result<UndoToken, AppFailure>>? writeScoped(
  ProviderContainer ref, {
  required TaskView task,
  required Occurrence target,
  required SeriesChange change,
  required EditScope scope,
}) => switch ((task.series, task.imported)) {
  (final s?, _) => editSeries(
    ref,
    series: s,
    target: target,
    change: change,
    scope: scope,
  ),
  (_, final i?) => editImported(ref, series: i, target: target, change: change),
  _ => null,
};

/// Deletes [target] and the rest of [task]'s series by [scope]; null
/// when [task] doesn't repeat.
Future<Result<UndoToken, AppFailure>>? deleteScopedWrite(
  ProviderContainer ref, {
  required TaskView task,
  required Occurrence target,
  required EditScope scope,
}) => switch ((task.series, task.imported)) {
  (final s?, _) => deleteSeries(ref, series: s, target: target, scope: scope),
  (_, final i?) => deleteImported(ref, series: i, target: target),
  _ => null,
};

/// "Use this list every time" for [task]'s series; null when it doesn't
/// repeat.
Future<Result<UndoToken, AppFailure>>? listEveryTime(
  ProviderContainer ref, {
  required TaskView task,
  required List<Subtask> subtasks,
}) => switch ((task.series, task.imported)) {
  (final s?, _) => useListEveryTime(
    ref,
    series: s,
    source: task.occurrence,
    subtasks: subtasks,
  ),
  (_, final i?) => importedListEveryTime(
    ref,
    series: i,
    source: task.occurrence,
    subtasks: subtasks,
  ),
  _ => null,
};
