import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/layout/timeline_day.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'timeline_providers.g.dart';

/// "Now", emitted immediately and then on every minute boundary, so the
/// now-line moves once per minute (docs/03 §3.1) without a busy timer.
@Riverpod(keepAlive: true)
Stream<DateTime> minuteTick(Ref ref) {
  final clock = ref.watch(clockProvider);
  final controller = StreamController<DateTime>();
  Timer? timer;
  void tick() {
    final now = clock.nowUtc();
    controller.add(now);
    final untilNext = 60000 - now.millisecondsSinceEpoch % 60000;
    timer = Timer(Duration(milliseconds: untilNext), tick);
  }

  tick();
  ref.onDispose(() {
    timer?.cancel();
    unawaited(controller.close());
  });
  return controller.stream;
}

/// Today's local calendar date in the profile's zone; changes at midnight.
@riverpod
Future<DateTime> todayDate(Ref ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  final now =
      ref.watch(minuteTickProvider).value ?? ref.watch(clockProvider).nowUtc();
  final local = tz.TZDateTime.from(now, tz.getLocation(profile.tzId));
  return DateTime(local.year, local.month, local.day);
}

/// Everything the timeline needs for one day.
final class TimelineData {
  const TimelineData({
    required this.userId,
    required this.day,
    required this.settings,
    required this.blocks,
    required this.allDay,
  });

  final String userId;
  final TimelineDay day;
  final Settings settings;

  /// Timed blocks overlapping the day (incl. ones crossing midnight).
  final List<Occurrence> blocks;

  /// All-day items for the strip (see [TimelineDay.isAllDay]).
  final List<Occurrence> allDay;
}

/// The live contents of [date] (year/month/day) for the local profile.
@riverpod
Stream<TimelineData> timelineData(Ref ref, DateTime date) async* {
  final profile = await ref.watch(currentProfileProvider.future);
  final day = TimelineDay.of(date, tz.getLocation(profile.tzId));
  final rows = ref
      .watch(occurrenceRepositoryProvider)
      .watchRange(profile.id, day.startUtc, day.endUtc);
  await for (final all in rows) {
    yield TimelineData(
      userId: profile.id,
      day: day,
      settings: profile.settings,
      blocks: [
        for (final o in all)
          if (!day.isAllDay(o)) o,
      ],
      allDay: [
        for (final o in all)
          if (day.isAllDay(o)) o,
      ],
    );
  }
}

/// Which collapsed outside-hours zones the user has opened this session.
@Riverpod(keepAlive: true)
class OutsideHours extends _$OutsideHours {
  @override
  ({bool before, bool after}) build() => (before: false, after: false);

  void toggleBefore() => state = (before: !state.before, after: state.after);

  void toggleAfter() => state = (before: state.before, after: !state.after);
}

/// Subtask progress per occurrence of [date], for the progress rings (R-09:
/// counts are per occurrence, never per series).
@riverpod
Stream<Map<String, ({int done, int total})>> daySubtaskProgress(
  Ref ref,
  DateTime date,
) async* {
  final data = await ref.watch(timelineDataProvider(date).future);
  final ids = {for (final o in data.blocks) o.id};
  if (ids.isEmpty) {
    yield const {};
    return;
  }
  final rows = ref
      .watch(subtaskRepositoryProvider)
      .watchForOccurrences(data.userId, ids);
  await for (final subtasks in rows) {
    final out = <String, ({int done, int total})>{};
    for (final s in subtasks) {
      final p = out[s.occurrenceId] ?? (done: 0, total: 0);
      out[s.occurrenceId] = (
        done: p.done + (s.done ? 1 : 0),
        total: p.total + 1,
      );
    }
    yield out;
  }
}

/// Alerts of each active series, inherited by occurrences without their
/// own (`alerts` null, docs/05).
@Riverpod(keepAlive: true)
Stream<Map<String, List<Alert>>> seriesAlerts(Ref ref) async* {
  final profile = await ref.watch(currentProfileProvider.future);
  yield* ref
      .watch(seriesRepositoryProvider)
      .watchActive(profile.id)
      .map((all) => {for (final s in all) s.id: s.alerts});
}
