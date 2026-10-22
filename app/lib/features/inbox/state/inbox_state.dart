import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/week_plan.dart';
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

/// The Mac/web Sort menu (`A-mac-inbox`); resets when the Inbox is left.
@riverpod
class InboxSortChoice extends _$InboxSortChoice {
  @override
  InboxSort build() => InboxSort.added;

  void pick(InboxSort sort) => state = sort;
}

/// How many days "the week" spans for fits and Auto-plan: today and the
/// six after it.
const inboxWeekDays = 7;

/// The room left on [today] (from now) and the six days after it, live,
/// for "Fits Thu 12:00" and Auto-plan the week (M3e.2).
@riverpod
Future<List<DayRoom>> inboxWeekRooms(Ref ref, DateTime today) async => [
  for (var d = 0; d < inboxWeekDays; d++)
    await ref.watch(
      dayRoomProvider(DateTime(today.year, today.month, today.day + d)).future,
    ),
];
