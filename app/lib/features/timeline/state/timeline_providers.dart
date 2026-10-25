import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/scheduling/start_nudge.dart';
import 'package:dottoday/features/timeline/layout/timeline_day.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

export 'package:dottoday/core/clock/minute_tick.dart' show minuteTickProvider;

part 'timeline_providers.g.dart';

/// Today's local calendar date in the profile's zone; changes at midnight.
@riverpod
Future<DateTime> todayDate(Ref ref) async {
  // Watch everything before the await: the ref may be disposed after it.
  final now =
      ref.watch(minuteTickProvider).value ?? ref.watch(clockProvider).nowUtc();
  final profile = await ref.watch(currentProfileProvider.future);
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
///
/// Stream providers here read their dependencies synchronously and return
/// the stream: an `async*` body starts on first listen, by which time a
/// pager page may already be disposed and its ref unusable (Riverpod 3).
@riverpod
Stream<TimelineData> timelineData(Ref ref, DateTime date) {
  final profile = ref.watch(currentProfileProvider.future);
  final repo = ref.watch(occurrenceRepositoryProvider);
  return Stream.fromFuture(profile).asyncExpand((profile) {
    final day = TimelineDay.of(date, tz.getLocation(profile.tzId));
    return repo
        .watchRange(profile.id, day.startUtc, day.endUtc)
        .map(
          (all) => TimelineData(
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
          ),
        );
  });
}

/// Subtask progress per occurrence of [date], for the progress rings (R-09:
/// counts are per occurrence, never per series).
@riverpod
Stream<Map<String, ({int done, int total})>> daySubtaskProgress(
  Ref ref,
  DateTime date,
) {
  final data = ref.watch(timelineDataProvider(date).future);
  final repo = ref.watch(subtaskRepositoryProvider);
  return Stream.fromFuture(data).asyncExpand((data) {
    final ids = {for (final o in data.blocks) o.id};
    if (ids.isEmpty) return Stream.value(const {});
    return repo.watchForOccurrences(data.userId, ids).map((subtasks) {
      final out = <String, ({int done, int total})>{};
      for (final s in subtasks) {
        final p = out[s.occurrenceId] ?? (done: 0, total: 0);
        out[s.occurrenceId] = (
          done: p.done + (s.done ? 1 : 0),
          total: p.total + 1,
        );
      }
      return out;
    });
  });
}

/// The first step still to do of each task on [date] whose steps aren't
/// started (Smallest step, 11 B2, docs/09 M10.6), by occurrence id.
@riverpod
Stream<Map<String, Subtask>> dayFirstSteps(Ref ref, DateTime date) {
  final data = ref.watch(timelineDataProvider(date).future);
  final repo = ref.watch(subtaskRepositoryProvider);
  return Stream.fromFuture(data).asyncExpand((data) {
    final ids = {for (final o in data.blocks) o.id};
    if (ids.isEmpty) return Stream.value(const {});
    return repo.watchForOccurrences(data.userId, ids).map((subtasks) {
      final byTask = <String, List<Subtask>>{};
      for (final s in subtasks) {
        (byTask[s.occurrenceId] ??= []).add(s);
      }
      return {
        for (final MapEntry(:key, :value) in byTask.entries)
          if (stepsNotStarted(value)) key: ?smallestStep(value),
      };
    });
  });
}

/// Alerts of each active series, inherited by occurrences without their
/// own (`alerts` null, docs/05).
@Riverpod(keepAlive: true)
Stream<Map<String, List<Alert>>> seriesAlerts(Ref ref) {
  final profile = ref.watch(currentProfileProvider.future);
  final repo = ref.watch(seriesRepositoryProvider);
  return Stream.fromFuture(profile).asyncExpand(
    (profile) => repo
        .watchActive(profile.id)
        .map((all) => {for (final s in all) s.id: s.alerts}),
  );
}

/// [date]'s timeline, held while it loads: nothing may be watching it
/// (tomorrow, or a closed sheet's today), and an unwatched day is
/// disposed mid-load.
Future<TimelineData> readTimelineDay(
  ProviderContainer container,
  DateTime date,
) async {
  final hold = container.listen(timelineDataProvider(date), (_, _) {});
  try {
    return await container.read(timelineDataProvider(date).future);
  } finally {
    hold.close();
  }
}
