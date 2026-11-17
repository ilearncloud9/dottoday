import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_reality.dart';
import 'package:flutter/foundation.dart';

export 'thread_reality.dart';

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
    this.movable = true,
    this.travel,
    this.smallestStep,
    this.unstick = false,
    this.reality,
    this.startUtc,
    this.minutes = 0,
    this.oneThing = false,
  });

  /// Today's one thing (docs/15 §8): an accent ring outside the dot and
  /// "Your one thing" in the row's small text, never colour alone.
  final bool oneThing;

  /// When the task starts, for drops onto its row (feature-supplied; null
  /// leaves the row out of drops).
  final DateTime? startUtc;

  /// Its length: the row stretches with it (ADR-0015).
  final int minutes;

  /// Where a drop onto this row lands: anywhere along it, overlap allowed
  /// (ADR-0015); null without [startUtc].
  DropSpan? get span => switch (startUtc) {
    final at? => DropSpan(startUtc: at, minutes: minutes, fit: false),
    null => null,
  };

  /// Set on the Reality thread (11 C3, docs/09 M11.2): what really
  /// happened, drawn beside the plan's ghost lane. Null on the plan.
  final ThreadReality? reality;

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

/// The sun cap ("Wake Up · 7:00") or moon cap ("Wind Down · 22:00").
final class ThreadCap extends ThreadEntry {
  const ThreadCap.wake(this.time) : windDown = false;
  const ThreadCap.bed(this.time) : windDown = true;

  /// Formatted clock time of the day's boundary.
  final String time;
  final bool windDown;
}

/// A task row; the live one renders as a `LiveRow`.
final class ThreadTaskEntry extends ThreadEntry {
  const ThreadTaskEntry(this.task);

  final ThreadTask task;
}

/// Tasks wholly before Wake Up or from Wind Down on, folded into one row
/// above the sun cap or below the moon cap (docs/02 F1.15, R-17): they
/// still render, without stretching the day's shape.
final class ThreadOutside extends ThreadEntry {
  const ThreadOutside({
    required this.tasks,
    required this.windDown,
    this.open = false,
    this.counted = true,
  });

  /// "1 task before Wake Up" (Full); false: "Before Wake Up", no count
  /// (Minimal, ED-246).
  final bool counted;

  /// In start order.
  final List<ThreadTask> tasks;

  /// After Wind Down (below the moon cap); false: before Wake Up.
  final bool windDown;

  /// Starts unfolded: it holds the live task, which never hides.
  final bool open;
}

/// The Earlier fold (ED-164): done tasks before now, folded into one quiet
/// row at the top of the rest of today. No count; up to three [dots] in
/// the folded tasks' colours. Folded ([open] false), the tasks are left
/// out of the entries; open, they follow in their own rows.
final class ThreadEarlier extends ThreadEntry {
  const ThreadEarlier({
    required this.dots,
    required this.first,
    required this.last,
    this.open = false,
  });

  /// The first three folded tasks' colours, in thread order.
  final List<TaskColor> dots;

  /// The first and last folded task's colour: the thread runs in [first]
  /// into the open rows, and leaves the folded row in [last].
  final TaskColor first;
  final TaskColor last;

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
      case ThreadCap() ||
          ThreadGap() ||
          ThreadOverlap() ||
          ThreadNow() ||
          ThreadEarlier():
        break;
    }
  }
}

/// Two overlapping tasks (ADR-0015): the knot between their dots, beside
/// "Run and Sleep share 15 min".
final class ThreadOverlap extends ThreadEntry {
  const ThreadOverlap({
    required this.above,
    required this.below,
    required this.aboveTitle,
    required this.belowTitle,
    required this.minutes,
    required this.range,
  });

  /// The shared stretch, "10:30–11:00": the row reads "Overlap ·
  /// 10:30–11:00" (E-Phones Today).
  final String range;

  /// The earlier task it runs into (the one ending last) and its title.
  final TaskColor above;
  final String aboveTitle;

  /// The task that starts inside it.
  final TaskColor below;
  final String belowTitle;

  /// How long the two share.
  final int minutes;
}

/// Now on today's thread (E rules §5.3, ED-246): the bead with the time
/// in a pill, after the live tasks or where now falls in free time.
final class ThreadNow extends ThreadEntry {
  const ThreadNow(this.time);

  /// Formatted clock time, "10:42".
  final String time;
}

/// Free time between tasks (docs/10 §6 "Free gaps are drop targets").
final class ThreadGap extends ThreadEntry {
  const ThreadGap({
    required this.minutes,
    required this.startLabel,
    this.addable = false,
    this.startUtc,
    this.labelled = true,
    this.fits,
  });

  final int minutes;

  /// Formatted start of the gap, for "add here" and drop targets.
  final String startLabel;

  /// Future gaps carry "N h free · add here"; past ones just "N h free".
  final bool addable;

  /// The instant the gap opens, for drops (feature-supplied).
  final DateTime? startUtc;

  /// Settings › Show free time: off, the gap keeps its dotted line but no
  /// "N h free · add here" label (still a drop target).
  final bool labelled;

  /// The title of an inbox task that fits here ("1 h free · Go for a run
  /// fits", `A-mac-inbox`'s Drop onto today).
  final String? fits;

  /// Where a drop onto this gap lands: snapped and kept inside it when the
  /// task fits; null without [startUtc].
  DropSpan? get span => switch (startUtc) {
    final at? => DropSpan(startUtc: at, minutes: minutes),
    null => null,
  };

  /// This gap naming [title] as what fits it.
  ThreadGap fitting(String title) => ThreadGap(
    minutes: minutes,
    startLabel: startLabel,
    addable: addable,
    startUtc: startUtc,
    labelled: labelled,
    fits: title,
  );
}

/// The stretch of the day a thread row stands for, as a drop target (docs/10
/// §6, ADR-0015): a drop [fraction] down the row lands that far into
/// [minutes] from [startUtc]. A gap keeps a dropped task inside it ([fit]);
/// a task's row does not, so a drop there overlaps it.
@immutable
final class DropSpan {
  const DropSpan({
    required this.startUtc,
    required this.minutes,
    this.fit = true,
  });

  final DateTime startUtc;
  final int minutes;
  final bool fit;
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

/// Where "now" sits on a thread: the row at [index] of its entries, and
/// how far down that row ([fraction], 0–1).
typedef ThreadAnchor = ({int index, double fraction});

/// The live task's row (a folded zone holding it included) or else the
/// now-bead's row; null when the thread shows neither, e.g. any day but
/// today. Today opens scrolled to it (ED-336).
ThreadAnchor? nowAnchor(List<ThreadEntry> entries) {
  bool live(ThreadTask t) => t.state == DotState.live;
  final task = entries.indexWhere(
    (e) => switch (e) {
      ThreadTaskEntry(:final task) => live(task),
      ThreadOutside(:final tasks) => tasks.any(live),
      ThreadCap() ||
      ThreadGap() ||
      ThreadOverlap() ||
      ThreadNow() ||
      ThreadEarlier() => false,
    },
  );
  if (task >= 0) return (index: task, fraction: 0);
  final now = entries.indexWhere((e) => e is ThreadNow);
  return now < 0 ? null : (index: now, fraction: 0.5);
}

/// For each of [entries], the task colour the thread runs in where it is
/// solid (behind now, E rules §5.2), or null where it runs dotted ahead.
///
/// A task row's value is the colour the thread arrives in (the task
/// before it, or its own for the first); a gap's, the now-bead's and Wind
/// Down's the last task's; Wake Up's the first task's. Behind now means
/// before the [ThreadNow]; a day without one is behind now up to its last
/// done, missed or live task, or wholly when no task is still ahead.
///
/// ```dart
/// threadSolid([wake, run, gap, now, lunch, bed]);
/// // [coral, coral, coral, coral, null, null]
/// ```
List<TaskColor?> threadSolid(List<ThreadEntry> entries) {
  final tasks = [
    for (final e in entries)
      if (e case ThreadTaskEntry(:final task)) task,
  ];
  final end = _behindNowEnd(entries, tasks);
  final out = <TaskColor?>[];
  TaskColor? last;
  for (final (i, e) in entries.indexed) {
    final behind = i < end;
    switch (e) {
      case ThreadTaskEntry(:final task):
        out.add(behind ? last ?? task.color : null);
        last = task.color;
      case ThreadCap(windDown: false):
        out.add(behind ? tasks.firstOrNull?.color : null);
      case ThreadCap() || ThreadGap() || ThreadNow():
        out.add(behind || e is ThreadNow ? last : null);
      case ThreadEarlier(:final open, :final first, last: final leaves):
        // Open, the thread runs on into the first folded row; folded, it
        // leaves in the last folded task's colour (E-Earlier).
        out.add(behind ? (open ? first : leaves) : null);
        if (!open) last = leaves;
      case ThreadOverlap() || ThreadOutside():
        out.add(null);
    }
  }
  return out;
}

int _behindNowEnd(List<ThreadEntry> entries, List<ThreadTask> tasks) {
  final now = entries.indexWhere((e) => e is ThreadNow);
  if (now >= 0) return now;
  if (tasks.isEmpty) return 0;
  bool behind(ThreadTask t) => switch (t.state) {
    DotState.done || DotState.missed || DotState.live => true,
    DotState.upcoming || DotState.skipped => false,
  };
  if (!tasks.any((t) => t.state == DotState.upcoming)) {
    return tasks.any(behind) ? entries.length : 0;
  }
  return entries.lastIndexWhere((e) => e is ThreadTaskEntry && behind(e.task)) +
      1;
}
