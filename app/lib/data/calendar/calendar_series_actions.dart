import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/calendar/calendar_series_edit.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/recurrence/series_change.dart';
import 'package:dottoday/domain/recurrence/subtask_template.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

// Scope All for repeating calendar events (docs/02 F5.7): each is one
// batch — the series' settings and its instances — so one Undo reverts it.

Future<List<Occurrence>> _instances(
  ProviderContainer ref,
  String userId,
  ImportedSeries s,
) => ref
    .read(calendarSeriesRepositoryProvider)
    .instances(userId, s.accountId, s.seriesKey);

/// The start of today in [tzId]: scope All reaches instances from here.
DateTime _today(ProviderContainer ref, String tzId) {
  final zone = tz.getLocation(tzId);
  final w = utcToWallClock(zone, ref.read(clockProvider).nowUtc());
  return wallClockToUtc(zone, DateTime(w.year, w.month, w.day));
}

Future<Result<UndoToken, AppFailure>> _write(
  ProviderContainer ref,
  String userId,
  ImportedSeriesWrite w, {
  List<Subtask> subtasks = const [],
}) => ref
    .read(undoServiceProvider)
    .applyUndoable(
      WriteBatch(
        userId: userId,
        calendarSeries: [w.settings],
        occurrences: w.occurrences,
        subtasks: subtasks,
      ),
    );

/// [change] to every instance of [series] from today, and to later ones.
Future<Result<UndoToken, AppFailure>> editImported(
  ProviderContainer ref, {
  required ImportedSeries series,
  required Occurrence target,
  required SeriesChange change,
  IdGenerator ids = const UuidV7Generator(),
}) async => _write(
  ref,
  target.userId,
  editImportedSeries(
    series: series,
    instances: await _instances(ref, target.userId, series),
    target: target,
    change: change,
    fromUtc: _today(ref, target.tzId),
    now: ref.read(clockProvider).nowUtc(),
    newId: ids.newId,
  ),
);

/// Deletes [series] here with scope All: it never comes back on import.
Future<Result<UndoToken, AppFailure>> deleteImported(
  ProviderContainer ref, {
  required ImportedSeries series,
  required Occurrence target,
  IdGenerator ids = const UuidV7Generator(),
}) async => _write(
  ref,
  target.userId,
  deleteImportedSeries(
    series: series,
    instances: await _instances(ref, target.userId, series),
    target: target,
    fromUtc: _today(ref, target.tzId),
    now: ref.read(clockProvider).nowUtc(),
    newId: ids.newId,
  ),
);

/// "Use this list every time" (R-09): [subtasks] become the steps of
/// every later planned instance with nothing ticked, and of the ones the
/// import brings later.
Future<Result<UndoToken, AppFailure>> importedListEveryTime(
  ProviderContainer ref, {
  required ImportedSeries series,
  required Occurrence source,
  required List<Subtask> subtasks,
  IdGenerator ids = const UuidV7Generator(),
}) async {
  final now = ref.read(clockProvider).nowUtc();
  final template = templateOf(subtasks, ids);
  final later = [
    for (final o in await _instances(ref, source.userId, series))
      if (o.id != source.id &&
          o.deletedAt == null &&
          o.status == OccurrenceStatus.planned &&
          (o.startUtc?.isAfter(now) ?? false))
        o,
  ];
  final existing = await ref
      .read(subtaskRepositoryProvider)
      .watchForOccurrences(source.userId, {for (final o in later) o.id})
      .first;
  final settings = series
      .settingsOr(userId: source.userId, newId: ids.newId, now: now)
      .copyWith(subtaskTemplate: template, updatedAt: now);
  return _write(
    ref,
    source.userId,
    (settings: settings, occurrences: const []),
    subtasks: applyTemplate(
      template: template,
      days: {
        for (final o in later)
          o: [
            for (final s in existing)
              if (s.occurrenceId == o.id) s,
          ],
      },
      nowUtc: now,
      ids: ids,
    ),
  );
}
