import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/drag_math.dart';
import 'package:dottoday/domain/scheduling/unstick.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

// The Running late sheet's Skip and Shorten, and the Day review's move
// (docs/09 M3f.5, R-04): one undoable batch each (R-11). They take a
// ProviderContainer because the sheet or prompt that started them closes
// at once.

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

/// Skips [o] on this day only (a repeating task's other days stay).
Future<Result<UndoToken, AppFailure>> skipTask(
  ProviderContainer ref,
  Occurrence o,
) => _write(ref, [o.copyWith(status: OccurrenceStatus.skipped)]);

/// Writes [shortened] (see `shortenStart`).
Future<Result<UndoToken, AppFailure>> shortenTask(
  ProviderContainer ref,
  Occurrence shortened,
) => _write(ref, [shortened]);

/// The Day review: [rows] onto [date] at their own wall times, pinned
/// ones too (the review asked about every unfinished one-off). Each counts
/// a move (Unstick, M10.7): rolling forward is how a task gets stuck.
Future<Result<UndoToken, AppFailure>> rollToDay(
  ProviderContainer ref,
  List<Occurrence> rows,
  DateTime date,
) => _write(ref, [
  for (final o in rows)
    countMove(
      o,
      o.copyWith(
        startUtc: sameTimeOn(tz.getLocation(o.tzId), o.startUtc!, date),
      ),
    ),
]);

/// The Day review with "Roll unfinished to tomorrow" off: [rows] back to
/// the Inbox.
Future<Result<UndoToken, AppFailure>> sendToInbox(
  ProviderContainer ref,
  List<Occurrence> rows,
) => _write(ref, [for (final o in rows) o.copyWith(startUtc: null)]);
