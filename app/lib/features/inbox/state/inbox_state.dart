import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
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
