import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/routines/routine_rules.dart';
import 'package:dottoday/domain/scheduling/drag_math.dart';
import 'package:dottoday/domain/scheduling/task_progress.dart' as progress;
import 'package:dottoday/domain/scheduling/unstick.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

// Multi-select actions (docs/03 §3.2, R-05): one undoable batch each, so
// one Undo puts every task back (R-11). All take a ProviderContainer: the
// bar that started them is gone as soon as the selection clears.

Future<Result<UndoToken, AppFailure>> _write(
  ProviderContainer ref,
  List<Occurrence> rows,
) {
  final now = ref.read(clockProvider).nowUtc();
  return ref
      .read(undoServiceProvider)
      .applyUndoable(
        WriteBatch(
          userId: rows.first.userId,
          occurrences: [for (final o in rows) o.copyWith(updatedAt: now)],
        ),
      );
}

/// Moves [rows] onto [date], each at its own wall time. Pinned tasks stay
/// (R-17).
Future<Result<UndoToken, AppFailure>> moveAllToDay(
  ProviderContainer ref,
  List<Occurrence> rows,
  DateTime date,
) => _write(ref, [
  for (final o in rows)
    if (!o.pinned && o.startUtc != null)
      o.copyWith(
        startUtc: sameTimeOn(tz.getLocation(o.tzId), o.startUtc!, date),
      ),
]);

/// Moves [rows] [minutes] later (earlier when negative): the keyboard's
/// ⌘/Ctrl+↑↓ (docs/02 F1.17). Pinned tasks stay (R-17); null when none
/// can move.
Future<Result<UndoToken, AppFailure>>? nudgeAll(
  ProviderContainer ref,
  List<Occurrence> rows,
  int minutes,
) {
  final moved = [
    for (final o in rows)
      if (!o.pinned && o.startUtc != null)
        countMove(
          o,
          o.copyWith(startUtc: o.startUtc!.add(Duration(minutes: minutes))),
        ),
  ];
  return moved.isEmpty ? null : _write(ref, moved);
}

/// Copies [rows] at the same times as new one-off, planned tasks.
Future<Result<UndoToken, AppFailure>> duplicateAll(
  ProviderContainer ref,
  List<Occurrence> rows, {
  IdGenerator ids = const UuidV7Generator(),
}) {
  final now = ref.read(clockProvider).nowUtc();
  return _write(ref, [
    for (final o in rows)
      progress
          .withoutProgress(o)
          .copyWith(
            id: ids.newId(),
            seriesId: null,
            originalStartUtc: null,
            createdAt: now,
          ),
  ]);
}

/// Gives [rows] the colour [colorKey].
Future<Result<UndoToken, AppFailure>> recolourAll(
  ProviderContainer ref,
  List<Occurrence> rows,
  String colorKey,
) => _write(ref, [for (final o in rows) o.copyWith(colorKey: colorKey)]);

/// Moves [rows] to Trash (R-11).
Future<Result<UndoToken, AppFailure>> trashAll(
  ProviderContainer ref,
  List<Occurrence> rows,
) => ref.read(trashServiceProvider).trashOccurrences(rows.first.userId, {
  for (final o in rows) o.id,
});

/// [picked] tasks of [day] as a new routine called [title] (11 C2 "Save
/// as routine"): anchored at Wake Up or Wind Down when they start or end
/// there, else at the first task's time.
Future<Routine> routineFromPicked(
  ProviderContainer ref,
  List<Occurrence> picked,
  DateTime day,
  String title, {
  IdGenerator ids = const UuidV7Generator(),
}) async {
  final data = await readTimelineDay(ref, day);
  final zone = data.day.location;
  return routineFromSelection(
    picked,
    shape: DayShape.on(zone, day, data.settings.boundaryFor(data.day.weekday)),
    zone: zone,
    id: ids.newId(),
    userId: data.userId,
    title: title,
    nowUtc: ref.read(clockProvider).nowUtc(),
    newId: ids.newId,
  );
}
