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
    this.progress = 0,
    this.minutesLeft,
    this.subtasksDone = 0,
    this.subtasksTotal = 0,
    this.overrunMinutes = 0,
    this.movable = true,
  });

  /// Occurrence id, for callbacks.
  final String id;
  final String title;
  final TaskColor color;
  final TaskIcon icon;
  final DotState state;

  /// "9:00 – 11:00".
  final String timeRange;

  /// "2 h", shown after the range on the live row and long tasks.
  final String? duration;
  final bool pinned;
  final bool recurring;

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

/// Free time between tasks (docs/10 §6 "Free gaps are drop targets").
final class ThreadGap extends ThreadEntry {
  const ThreadGap({
    required this.minutes,
    required this.startLabel,
    this.addable = false,
    this.nowFraction,
    this.startUtc,
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
}
