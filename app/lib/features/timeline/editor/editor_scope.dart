import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/calendar/calendar_series_actions.dart';
import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/data/recurrence/series_actions.dart';
import 'package:dottoday/domain/calendar/calendar_series_edit.dart';
import 'package:dottoday/domain/calendar/calendar_series_sender.dart';
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

/// A scoped write, and whether the calendar's series took it too.
typedef ScopedWrite = ({
  Result<UndoToken, AppFailure> result,
  SeriesSend calendar,
});

/// [change] to [task]'s series by [scope] (beyond this one); null when
/// [task] doesn't repeat. A calendar series' time, length and title also
/// go to its calendar when Send changes back is on (docs/02 F5.7).
Future<ScopedWrite>? writeScoped(
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
  ).then((r) => (result: r, calendar: SeriesSend.stayed)),
  (_, final i?) => _importedEdit(ref, i, target, change),
  _ => null,
};

Future<ScopedWrite> _importedEdit(
  ProviderContainer ref,
  ImportedSeries series,
  Occurrence target,
  SeriesChange change,
) async {
  final result = await editImported(
    ref,
    series: series,
    target: target,
    change: change,
  );
  if (result is Err) return (result: result, calendar: SeriesSend.stayed);
  final calendar = await ref
      .read(calendarSeriesWriteBackProvider)
      .edit(target, change);
  return (result: result, calendar: calendar);
}

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
