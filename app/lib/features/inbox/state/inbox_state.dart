import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'inbox_state.g.dart';

/// The Inbox filter chips (`A-android-inbox`).
enum InboxFilter { all, under30, fitsToday }

/// The picked filter chip; resets when the Inbox is left.
@riverpod
class InboxFilterChoice extends _$InboxFilterChoice {
  @override
  InboxFilter build() => InboxFilter.all;

  void pick(InboxFilter filter) => state = filter;
}

/// The local date of today in the profile zone, read once (the Inbox
/// re-reads it when reopened).
@riverpod
Future<DateTime> inboxToday(Ref ref) async {
  final now = ref.watch(clockProvider).nowUtc();
  final profile = await ref.watch(currentProfileProvider.future);
  final local = tz.TZDateTime.from(now, tz.getLocation(profile.tzId));
  return DateTime(local.year, local.month, local.day);
}

/// What is left of [date] between Wake Up and Bedtime, live, for fitting
/// inbox items (docs/02 F3 "next free gap today, tomorrow morning").
/// Dependencies are read synchronously (see `timelineData`).
@riverpod
Stream<DayRoom> dayRoom(Ref ref, DateTime date) {
  final profile = ref.watch(currentProfileProvider.future);
  final repo = ref.watch(occurrenceRepositoryProvider);
  final now = ref.watch(clockProvider).nowUtc();
  return Stream.fromFuture(profile).asyncExpand((p) {
    final zone = tz.getLocation(p.tzId);
    const midnight = ClockTime(0, 0);
    final next = DateTime(date.year, date.month, date.day + 1);
    final shape = DayShape.on(
      zone,
      date,
      p.settings.boundaryFor(Weekday.values[date.weekday - 1]),
    );
    return repo
        .watchRange(
          p.id,
          midnight.onDate(zone, date),
          midnight.onDate(zone, next),
        )
        .map(
          (blocks) => DayRoom(
            blocks: blocks,
            fromUtc: now,
            startUtc: shape.wakeUtc,
            endUtc: shape.bedUtc,
            snapMinutes: p.settings.snapMinutes,
          ),
        );
  });
}
