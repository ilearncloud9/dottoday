import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_blocks.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';

/// Formats the display strings the thread needs, so [threadEntries] stays
/// free of `BuildContext` (the screen passes l10n + 12/24 h).
final class ThreadFormat {
  const ThreadFormat({
    required this.time,
    required this.range,
    required this.duration,
  });

  /// "7:30" in the profile zone and clock style.
  final String Function(DateTime utc) time;

  /// "7:30 – 8:00".
  final String Function(String start, String end) range;

  /// "2 h", "45 min".
  final String Function(int minutes) duration;
}

/// Shortest gap the thread draws as free time; anything less is just the
/// thread running between two dots.
const minGapMinutes = 15;

/// The day as thread entries (docs/10 §1, §6): Wake Up cap, tasks in start
/// order with free gaps between them, Wind Down cap. A task that starts
/// before an earlier one ends follows a [ThreadOverlap] (ADR-0015). Tasks that end by Wake
/// Up or start at Wind Down or later fold into a [ThreadOutside] row before
/// the sun cap or after the moon cap (F1.15); a task across a cap stays
/// inline.
///
/// Each task's state comes from its status and [nowUtc]: done and skipped
/// as stored; live while now is inside it; missed once it ended undone;
/// upcoming otherwise. Gaps from now on are "add here" targets. On today
/// a [ThreadNow] marks now: after the live tasks, or where it falls.
///
/// With [reality] (the Reality thread, 11 C3) [blocks] carry the times
/// tasks really ran, every task is decorated (a missing id gets an empty
/// [ThreadReality]), and only a task [ThreadReality.underWay] is live.
///
/// ```dart
/// threadEntries(blocks: day, shape: shape, nowUtc: clock.nowUtc(), …);
/// ```
List<ThreadEntry> threadEntries({
  required List<Occurrence> blocks,
  required DayShape shape,
  required DateTime nowUtc,
  required ThreadFormat format,
  Map<String, ({int done, int total})> subtasks = const {},
  Map<String, String> smallestSteps = const {},
  Set<String> unstick = const {},
  bool showFreeTime = true,
  Map<String, ThreadReality>? reality,
  String? oneThingId,
}) {
  final sorted = [
    for (final o in blocks)
      if (o.startUtc != null) o,
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  ThreadTask task(Occurrence o) => _task(
    o,
    nowUtc,
    format,
    subtasks[o.id],
    smallestSteps[o.id],
    unstick.contains(o.id),
    reality == null ? null : reality[o.id] ?? const ThreadReality(),
    o.id == oneThingId,
  );
  final (:before, :inside, :after) = _split(sorted, shape);
  final out = <ThreadEntry>[
    ?_outside(before.map(task).toList(), windDown: false),
    ThreadCap.wake(format.time(shape.wakeUtc)),
  ];
  final overlaps = _overlaps(inside);
  var cursor = shape.wakeUtc;
  for (final (i, o) in inside.indexed) {
    // Travel time before a task is not free (R-17, docs/04 §5).
    _gap(out, cursor, footprintStart(o), nowUtc, format, showFreeTime);
    if (overlaps[i] case final earlier?) {
      out.add(_overlap(earlier, o, format));
    }
    out.add(ThreadTaskEntry(task(o)));
    if (o.endUtc!.isAfter(cursor)) cursor = o.endUtc!;
  }
  _gap(out, cursor, shape.bedUtc, nowUtc, format, showFreeTime);
  _placeNow(out, shape, nowUtc, format);
  out
    ..add(ThreadCap.bed(format.time(shape.bedUtc)))
    ..addAll([?_outside(after.map(task).toList(), windDown: true)]);
  return out;
}

/// For each of [sorted], the earlier task it starts inside (the one ending
/// last), or null (ADR-0015: the knot).
List<Occurrence?> _overlaps(List<Occurrence> sorted) {
  final out = <Occurrence?>[];
  Occurrence? last;
  for (final o in sorted) {
    final end = last?.endUtc;
    out.add(end != null && o.startUtc!.isBefore(end) ? last : null);
    if (end == null || o.endUtc!.isAfter(end)) last = o;
  }
  return out;
}

/// The knot between [earlier] and [o], which starts inside it.
ThreadOverlap _overlap(Occurrence earlier, Occurrence o, ThreadFormat format) {
  final end = o.endUtc!.isBefore(earlier.endUtc!) ? o.endUtc! : earlier.endUtc!;
  return ThreadOverlap(
    above: TaskColor.fromKey(earlier.colorKey),
    below: TaskColor.fromKey(o.colorKey),
    aboveTitle: earlier.title,
    belowTitle: o.title,
    minutes: end.difference(o.startUtc!).inMinutes,
    range: format.range(format.time(o.startUtc!), format.time(end)),
  );
}

/// [sorted] split by the day's caps: ended by Wake Up, crossing the waking
/// day, from Wind Down on.
({List<Occurrence> before, List<Occurrence> inside, List<Occurrence> after})
_split(List<Occurrence> sorted, DayShape shape) => (
  before: [
    for (final o in sorted)
      if (!o.endUtc!.isAfter(shape.wakeUtc)) o,
  ],
  inside: [
    for (final o in sorted)
      if (o.endUtc!.isAfter(shape.wakeUtc) &&
          o.startUtc!.isBefore(shape.bedUtc))
        o,
  ],
  after: [
    for (final o in sorted)
      if (!o.startUtc!.isBefore(shape.bedUtc)) o,
  ],
);

/// [tasks] as a folded row, or null when there are none.
ThreadOutside? _outside(List<ThreadTask> tasks, {required bool windDown}) =>
    tasks.isEmpty
    ? null
    : ThreadOutside(
        tasks: tasks,
        windDown: windDown,
        open: tasks.any((t) => t.state == DotState.live),
      );

void _gap(
  List<ThreadEntry> out,
  DateTime from,
  DateTime to,
  DateTime now,
  ThreadFormat format,
  bool labelled,
) {
  // Now inside free time: the bead splits it into what is behind and what
  // is still ahead (E rules §5.3).
  if (now.isAfter(from) && now.isBefore(to)) {
    _gap(out, from, now, now, format, labelled);
    out.add(ThreadNow(format.time(now)));
    _gap(out, now, to, now, format, labelled);
    return;
  }
  final minutes = to.difference(from).inMinutes;
  if (minutes < minGapMinutes) return;
  out.add(
    ThreadGap(
      minutes: minutes,
      startLabel: format.time(from),
      addable: to.isAfter(now),
      startUtc: from,
      labelled: labelled,
    ),
  );
}

/// Puts the now-bead (E rules §5.3) after the live tasks, or before the
/// first task still ahead, when now is inside the waking day and no free
/// time placed it already.
void _placeNow(
  List<ThreadEntry> out,
  DayShape shape,
  DateTime now,
  ThreadFormat format,
) {
  if (now.isBefore(shape.wakeUtc) || !now.isBefore(shape.bedUtc)) return;
  if (out.any((e) => e is ThreadNow)) return;
  final bead = ThreadNow(format.time(now));
  final live = out.lastIndexWhere(
    (e) => e is ThreadTaskEntry && e.task.state == DotState.live,
  );
  if (live >= 0) return out.insert(live + 1, bead);
  bool ahead(ThreadEntry e) =>
      e is ThreadTaskEntry && (e.task.startUtc?.isAfter(now) ?? false);
  var at = out.indexWhere(ahead);
  if (at < 0) at = out.lastIndexWhere((e) => e is ThreadCap);
  // A knot belongs with the task under it.
  if (at > 0 && out[at - 1] is ThreadOverlap) at--;
  out.insert(at, bead);
}

ThreadTask _task(
  Occurrence o,
  DateTime now,
  ThreadFormat format,
  ({int done, int total})? subtasks, [
  String? smallestStep,
  bool unstick = false,
  ThreadReality? reality,
  bool oneThing = false,
]) {
  final start = o.startUtc!;
  final end = o.endUtc!;
  final planState = dotStateOf(o, now);
  // On the Reality thread a task is live only once it really started.
  final state =
      reality != null && planState == DotState.live && !reality.underWay
      ? DotState.upcoming
      : planState;
  final live = state == DotState.live;
  return ThreadTask(
    id: o.id,
    title: o.title,
    color: TaskColor.fromKey(o.colorKey),
    icon: TaskIcon.fromKey(o.iconKey),
    state: state,
    timeRange: format.range(format.time(start), format.time(end)),
    duration: live ? format.duration(o.durationMin) : null,
    pinned: o.pinned,
    recurring: o.seriesId != null,
    imported: o.source == OccurrenceSource.calendar,
    progress: live
        ? now.difference(start).inSeconds / end.difference(start).inSeconds
        : 0,
    // Round up: "1 min left" until the task's last second.
    minutesLeft: live ? (end.difference(now).inSeconds / 60).ceil() : null,
    subtasksDone: subtasks?.done ?? 0,
    subtasksTotal: subtasks?.total ?? 0,
    movable: !o.pinned && o.status != OccurrenceStatus.done,
    travel: o.travelBufferMin > 0 ? format.duration(o.travelBufferMin) : null,
    smallestStep: smallestStep,
    unstick: unstick,
    reality: reality,
    startUtc: start,
    minutes: o.durationMin,
    oneThing: oneThing,
  );
}

/// The dot state of [o] at [now] (docs/10 §1, §3 `TaskDot`).
DotState dotStateOf(Occurrence o, DateTime now) {
  if (o.status == OccurrenceStatus.done) return DotState.done;
  if (o.status == OccurrenceStatus.skipped) return DotState.skipped;
  final start = o.startUtc;
  final end = o.endUtc;
  if (start == null || end == null) return DotState.upcoming;
  if (!now.isBefore(end)) return DotState.missed;
  if (!now.isBefore(start)) return DotState.live;
  return DotState.upcoming;
}
