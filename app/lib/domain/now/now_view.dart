import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

/// What Minimal's Now shows at a moment (ED-066, ED-329 "Now through the
/// day"): the same rule as the widgets and the Mac menu bar, Now, then
/// Next up, then Nothing else today; an open day when nothing is planned.
sealed class NowView {
  const NowView();
}

/// A task under way: the one that began first leads ([task]); any other
/// running task is "Also now"; [next] is the first one still ahead.
final class NowRunning extends NowView {
  const NowRunning({required this.task, required this.alsoNow, this.next});

  final Occurrence task;
  final List<Occurrence> alsoNow;
  final Occurrence? next;
}

/// Nothing running: the next task and the free time until it, the task
/// [after] it, and the [earlier] ones that ended without a tick, which
/// stay reachable "· not done" (E-R2-26 frames 6–8).
final class NowNextUp extends NowView {
  const NowNextUp({
    required this.next,
    required this.free,
    this.after,
    this.earlier = const [],
  });

  final Occurrence next;
  final Duration free;
  final Occurrence? after;
  final List<Occurrence> earlier;
}

/// Nothing planned today: the free time until Wind Down.
final class NowOpenDay extends NowView {
  const NowOpenDay({required this.free});

  final Duration free;
}

/// Everything planned is behind now: "Nothing else today".
final class NowNothingElse extends NowView {
  const NowNothingElse();
}

/// [blocks] (today's timed tasks) as Now sees them at [nowUtc], with
/// Wind Down at [windDownUtc]. Done and skipped tasks are never Now or
/// Next; a task that ran past its end without a tick isn't either.
///
/// ```dart
/// nowViewOf(blocks: [run, lunch], nowUtc: tenAm, windDownUtc: elevenPm);
/// // NowRunning(task: run, alsoNow: [], next: lunch)
/// ```
NowView nowViewOf({
  required List<Occurrence> blocks,
  required DateTime nowUtc,
  required DateTime windDownUtc,
}) {
  bool open(Occurrence o) =>
      o.status != OccurrenceStatus.done &&
      o.status != OccurrenceStatus.skipped &&
      o.startUtc != null;
  final timed = blocks.where((o) => o.startUtc != null).toList()
    ..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  final running = [
    for (final o in timed)
      if (open(o) &&
          !nowUtc.isBefore(o.startUtc!) &&
          nowUtc.isBefore(o.endUtc!))
        o,
  ];
  final ahead = timed
      .where((o) => open(o) && o.startUtc!.isAfter(nowUtc))
      .toList();
  final next = ahead.firstOrNull;
  if (running.isNotEmpty) {
    return NowRunning(
      task: running.first,
      alsoNow: running.skip(1).toList(),
      next: next,
    );
  }
  if (next != null) {
    return NowNextUp(
      next: next,
      free: next.startUtc!.difference(nowUtc),
      after: ahead.skip(1).firstOrNull,
      earlier: [
        for (final o in timed)
          if (open(o) && !o.endUtc!.isAfter(nowUtc)) o,
      ],
    );
  }
  if (timed.where((o) => o.status != OccurrenceStatus.skipped).isEmpty) {
    final left = windDownUtc.difference(nowUtc);
    return NowOpenDay(free: left.isNegative ? Duration.zero : left);
  }
  return const NowNothingElse();
}
