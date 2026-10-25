import 'dart:async';

import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/day_cues.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/dot/unstick_line.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [d]'s timed tasks with their states and cues at [nowUtc], as the
/// thread reads them.
List<ThreadTask> weekTasks(
  BuildContext context,
  WidgetRef ref,
  TimelineData d,
  DayShape shape,
  String Function(DateTime utc) time, {
  required DateTime nowUtc,
}) {
  final l10n = context.l10n;
  final date = d.day.date;
  final cues = dayCues(
    l10n,
    blocks: d.blocks,
    firstSteps: ref.watch(dayFirstStepsProvider(date)).value ?? const {},
    subtasks: ref.watch(daySubtaskProgressProvider(date)).value,
    now: nowUtc,
  );
  return threadTasks(
    threadEntries(
      blocks: d.blocks,
      shape: shape,
      nowUtc: nowUtc,
      format: ThreadFormat(
        time: time,
        range: l10n.threadTimeRange,
        duration: (m) => formatDurationShort(l10n, m),
      ),
      smallestSteps: cues.smallestSteps,
      unstick: cues.unstick,
    ),
  ).toList();
}

/// A Week card's cue tapped (M10.6, M10.7): Smallest step starts [task]
/// in Focus, as its Start does on Today; Unstick asks its question in a
/// sheet (the same `UnstickLine`, opened only by this tap — never on its
/// own, 11 B3). [find] looks the task up for the write.
void openWeekCue(
  BuildContext context,
  WidgetRef ref,
  ThreadTask? task, {
  required Occurrence? Function(String id) find,
}) {
  if (task == null) return;
  if (task.smallestStep != null) return openFocus(context, task.id);
  if (!task.unstick) return;
  unawaited(_unstick(context, ref, task, find));
}

Future<void> _unstick(
  BuildContext context,
  WidgetRef ref,
  ThreadTask task,
  Occurrence? Function(String id) find,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final undo = ref.read(undoServiceProvider);
  final answer = await showAppSheet<String>(
    context: context,
    title: task.title,
    builder: (sheet) =>
        UnstickLine(onAnswer: (a) => Navigator.of(sheet).pop(a)),
  );
  final o = find(task.id);
  if (answer == null || o == null || !context.mounted) return;
  reportUndoable(
    messenger,
    l10n,
    undo,
    await answerUnstick(ref, o, answer),
    message: (_) => l10n.unstickSaved(o.title),
    tokenOf: (t) => t,
  );
}
