import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:dottoday/domain/scheduling/task_progress.dart' as progress;
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Inbox writes (docs/02 F3). All take a ProviderContainer: rows leave the
// list (and unmount) as soon as the write lands.

/// Puts inbox item [o] on the timeline at [startUtc] (Schedule, Place).
Future<Result<UndoToken, AppFailure>> scheduleItem(
  ProviderContainer ref,
  Occurrence o,
  DateTime startUtc,
) => ref
    .read(undoServiceProvider)
    .applyUndoable(
      WriteBatch(
        userId: o.userId,
        occurrences: [
          o.copyWith(
            startUtc: startUtc,
            updatedAt: ref.read(clockProvider).nowUtc(),
          ),
        ],
      ),
    );

/// Puts every [placed] item at its slot as one write, so one Undo takes
/// them all back (Auto-plan the week, M3e.2).
Future<Result<UndoToken, AppFailure>> scheduleItems(
  ProviderContainer ref,
  List<({Occurrence item, Slot slot})> placed,
) {
  final now = ref.read(clockProvider).nowUtc();
  return ref
      .read(undoServiceProvider)
      .applyUndoable(
        WriteBatch(
          userId: placed.first.item.userId,
          occurrences: [
            for (final p in placed)
              p.item.copyWith(startUtc: p.slot.startUtc, updatedAt: now),
          ],
        ),
      );
}

/// Moves inbox item [o] to Trash (swipe right, R-11).
Future<Result<UndoToken, AppFailure>> trashItem(
  ProviderContainer ref,
  Occurrence o,
) => ref.read(trashServiceProvider).trashOccurrences(o.userId, {o.id});

/// Puts completed inbox item [o] back in the Inbox, not done (Completed
/// group, docs/09 M3f.6).
Future<Result<UndoToken, AppFailure>> markNotDone(
  ProviderContainer ref,
  Occurrence o,
) => ref
    .read(undoServiceProvider)
    .applyUndoable(
      WriteBatch(
        userId: o.userId,
        occurrences: [
          progress
              .markNotDone(o)
              .copyWith(updatedAt: ref.read(clockProvider).nowUtc()),
        ],
      ),
    );

/// Moves every completed item in [done] to Trash ("Clear completed",
/// R-11): one Undo brings them all back.
Future<Result<UndoToken, AppFailure>> trashItems(
  ProviderContainer ref,
  List<Occurrence> done,
) => ref.read(trashServiceProvider).trashOccurrences(done.first.userId, {
  for (final o in done) o.id,
});

/// Writes the Inbox's new order (see `reorderInbox`).
Future<Result<UndoToken, AppFailure>> reorderItems(
  ProviderContainer ref,
  List<Occurrence> changed,
) => _writeAll(ref, changed);

/// Gives every one of [items] [colorKey] (the selection bar's Colour).
Future<Result<UndoToken, AppFailure>> recolourItems(
  ProviderContainer ref,
  List<Occurrence> items,
  String colorKey,
) => _writeAll(ref, [for (final o in items) o.copyWith(colorKey: colorKey)]);

Future<Result<UndoToken, AppFailure>> _writeAll(
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
