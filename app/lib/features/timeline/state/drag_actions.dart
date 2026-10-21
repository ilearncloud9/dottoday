import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/drag_math.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Writes [changed] (already edited) through the undoable path, stamping
/// the edit time.
Future<Result<UndoToken, AppFailure>> _write(
  WidgetRef ref,
  Occurrence changed,
) {
  final row = changed.copyWith(updatedAt: ref.read(clockProvider).nowUtc());
  return ref
      .read(undoServiceProvider)
      .applyUndoable(WriteBatch(userId: row.userId, occurrences: [row]));
}

/// Moves [o] to start at [startUtc], keeping its length (drag onto a gap,
/// R-05). Other tasks stay put.
Future<Result<UndoToken, AppFailure>> moveTask(
  WidgetRef ref,
  Occurrence o,
  DateTime startUtc,
) => _write(ref, o.copyWith(startUtc: startUtc));

/// Gives [o] [durationMin] (resize grip, R-05).
Future<Result<UndoToken, AppFailure>> resizeTask(
  WidgetRef ref,
  Occurrence o,
  int durationMin,
) => _write(ref, o.copyWith(durationMin: durationMin));

/// Moves task [id] onto [date] at the same wall time (drop on a week-strip
/// day, PRD F8). Returns the moved row with the token, or null when the
/// task is gone or can't move (pinned, untimed).
Future<Result<(Occurrence, UndoToken)?, AppFailure>> moveToDay(
  WidgetRef ref,
  String id,
  DateTime date,
) async {
  final profile = await ref.read(currentProfileProvider.future);
  final o = await ref
      .read(occurrenceRepositoryProvider)
      .findById(profile.id, id);
  final start = o?.startUtc;
  if (o == null || start == null || o.pinned) return const Ok(null);
  final zone = tz.getLocation(o.tzId);
  final moved = o.copyWith(startUtc: sameTimeOn(zone, start, date));
  final result = await _write(ref, moved);
  return switch (result) {
    Ok(:final value) => Ok((moved, value)),
    Err(:final failure) => Err(failure),
  };
}
