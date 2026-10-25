import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/foundation.dart';

/// A task as the thread draws it (docs/10 §3 `TaskRow`). Display values
/// only: the feature formats times in the user's zone and 12/24 h setting,
/// so this stays free of domain and clock logic.
@immutable
final class ThreadTask {
  const ThreadTask({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
    required this.state,
    required this.timeRange,
    this.duration,
    this.pinned = false,
    this.recurring = false,
    this.imported = false,
    this.progress = 0,
    this.minutesLeft,
    this.subtasksDone = 0,
    this.subtasksTotal = 0,
    this.overrunMinutes = 0,
    this.movable = true,
    this.travel,
    this.smallestStep,
    this.unstick = false,
  });

  /// Occurrence id, for callbacks.
  final String id;
  final String title;

  /// "Just Gather documents · 10 min?" once Smallest step asks (11 B2,
  /// docs/09 M10.6); null otherwise.
  final String? smallestStep;

  /// Moved three times with no steps: the Unstick row shows (11 B3).
  final bool unstick;
  final TaskColor color;
  final TaskIcon icon;
  final DotState state;

  /// "9:00 – 11:00".
  final String timeRange;

  /// "2 h", shown after the range on the live row and long tasks.
  final String? duration;
  final bool pinned;
  final bool recurring;

  /// An imported calendar event: the row carries the calendar badge
  /// (docs/02 F1.10, R-16).
  final bool imported;

  /// 0–1 elapsed share of a live task.
  final double progress;

  /// Whole minutes until a live task ends.
  final int? minutesLeft;
  final int subtasksDone;
  final int subtasksTotal;

  /// Live task only: how far it runs into the next task. "Shift the rest"
  /// moves the later tasks by this much and is off when it is 0 (R-04).
  final int overrunMinutes;

  /// Long-press picks it up to drag (§6). Pinned tasks stay put (R-17).
  final bool movable;

  /// "15 min": the travel time held before it (R-17), or null for none.
  final String? travel;

  bool get hasSubtasks => subtasksTotal > 0;
}

/// One line of a [Thread], top to bottom.
@immutable
sealed class ThreadEntry {
  const ThreadEntry();
}

/// The sun cap ("Wake Up · 7:00") or moon cap ("Bedtime · 22:00").
final class ThreadCap extends ThreadEntry {
  const ThreadCap.wake(this.time) : bedtime = false;
  const ThreadCap.bed(this.time) : bedtime = true;

  /// Formatted clock time of the day's boundary.
  final String time;
  final bool bedtime;
}

/// A task row; the live one renders as a `LiveRow`.
final class ThreadTaskEntry extends ThreadEntry {
  const ThreadTaskEntry(this.task);

  final ThreadTask task;
}

/// Tasks wholly before Wake Up or from Bedtime on, folded into one row
/// above the sun cap or below the moon cap (docs/02 F1.15, R-17): they
/// still render, without stretching the day's shape.
final class ThreadOutside extends ThreadEntry {
  const ThreadOutside({
    required this.tasks,
    required this.bedtime,
    this.open = false,
  });

  /// In start order.
  final List<ThreadTask> tasks;

  /// After Bedtime (below the moon cap); false: before Wake Up.
  final bool bedtime;

  /// Starts unfolded: it holds the live task, which never hides.
  final bool open;
}

/// Every task of [entries], folded ones included, in thread order.
Iterable<ThreadTask> threadTasks(List<ThreadEntry> entries) sync* {
  for (final e in entries) {
    switch (e) {
      case ThreadTaskEntry(:final task):
        yield task;
      case ThreadOutside(:final tasks):
        yield* tasks;
      case ThreadCap() || ThreadGap():
        break;
    }
  }
}

/// Free time between tasks (docs/10 §6 "Free gaps are drop targets").
final class ThreadGap extends ThreadEntry {
  const ThreadGap({
    required this.minutes,
    required this.startLabel,
    this.addable = false,
    this.nowFraction,
    this.startUtc,
    this.labelled = true,
    this.fits,
  });

  final int minutes;

  /// Formatted start of the gap, for "add here" and drop targets.
  final String startLabel;

  /// Future gaps carry "N h free · add here"; past ones just "N h free".
  final bool addable;

  /// Where the now-marker sits in this gap (0–1), if now is inside it.
  final double? nowFraction;

  /// The instant the gap opens, for drops (feature-supplied).
  final DateTime? startUtc;

  /// Settings › Show free time: off, the gap keeps its dotted line but no
  /// "N h free · add here" label (still a drop target).
  final bool labelled;

  /// The title of an inbox task that fits here ("1 h free · Go for a run
  /// fits", `A-mac-inbox`'s Drop onto today).
  final String? fits;

  /// This gap naming [title] as what fits it.
  ThreadGap fitting(String title) => ThreadGap(
    minutes: minutes,
    startLabel: startLabel,
    addable: addable,
    nowFraction: nowFraction,
    startUtc: startUtc,
    labelled: labelled,
    fits: title,
  );
}

/// What the shift chips said when a task was let go (docs/03 §3.2).
@immutable
final class DropShift {
  const DropShift({this.followers = false, this.calendar = false});

  /// The later tasks follow ("Shift later tasks", inverted by Alt).
  final bool followers;

  /// Calendar events among them move too ("Calendar events too"); only
  /// meaningful with [followers].
  final bool calendar;
}
