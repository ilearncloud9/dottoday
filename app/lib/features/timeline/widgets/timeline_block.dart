import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/layout/block_facts.dart';
import 'package:dottoday/features/timeline/layout/day_layout.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/block_tile.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// A [BlockTile] fed with live state: subtask progress, inherited alerts,
/// and "overdue", which only re-evaluates when the minute tick flips it.
class TimelineBlock extends ConsumerWidget {
  const TimelineBlock({
    required this.placement,
    required this.date,
    required this.location,
    required this.use24h,
    super.key,
  });

  final BlockPlacement placement;
  final DateTime date;
  final tz.Location location;
  final bool use24h;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = placement.block;
    final end = o.endUtc!;
    final ended = ref.watch(
      minuteTickProvider.select(
        (v) => v.value != null && !end.isAfter(v.value!),
      ),
    );
    final progress = ref.watch(
      daySubtaskProgressProvider(date).select((v) => v.value?[o.id]),
    );
    final seriesAlerts = o.seriesId == null
        ? null
        : ref.watch(seriesAlertsProvider.select((v) => v.value?[o.seriesId]));
    final facts = BlockFacts.of(
      o,
      // Only "has it ended" matters, so pass the end itself when it has.
      nowUtc: ended ? end : null,
      seriesAlerts: seriesAlerts,
      subtasks: progress,
      startsBefore: placement.startsBefore,
      endsAfter: placement.endsAfter,
    );
    return BlockTile(
      block: o,
      location: location,
      use24h: use24h,
      facts: facts,
      onToggleDone: () => unawaited(_toggle(context, ref)),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final o = placement.block;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final undo = ref.read(undoServiceProvider);
    final wasDone = o.status == OccurrenceStatus.done;
    final result = await toggleDone(ref, o);
    if (messenger == null) return;
    switch (result) {
      case Ok(:final value):
        showUndoSnackbarOn(
          messenger,
          l10n,
          message: wasDone ? l10n.undoMarkedNotDone : l10n.undoMarkedDone,
          onUndo: () => unawaited(undo.undo(value)),
        );
      case Err(:final failure):
        messenger.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
    }
  }
}
