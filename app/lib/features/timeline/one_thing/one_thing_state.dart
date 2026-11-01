import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/wake_up/one_thing.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'one_thing_state.g.dart';

/// What the pick screen offers now (docs/15 §8), with the day it is for.
final class OneThingOffer {
  const OneThingOffer({
    required this.dateKey,
    required this.dots,
    required this.inbox,
    required this.location,
    required this.use24h,
    this.pickedId,
  });

  /// `yyyy-MM-dd` the pick is stored for.
  final String dateKey;
  final List<Occurrence> dots;
  final List<Occurrence> inbox;
  final tz.Location location;
  final bool? use24h;

  /// Today's one thing so far, or null.
  final String? pickedId;

  bool get isEmpty => dots.isEmpty && inbox.isEmpty;
}

/// Today's dots still to do and the Inbox (owner, 2026-11-01). [mission]
/// caps each at five, as the morning mission offers (15 §8).
@riverpod
Future<OneThingOffer> oneThingOffer(Ref ref, {required bool mission}) async {
  final date = await ref.watch(todayDateProvider.future);
  final data = await ref.watch(timelineDataProvider(date).future);
  final now = ref.watch(clockProvider).nowUtc();
  final inbox = await ref
      .watch(occurrenceRepositoryProvider)
      .watchInbox(data.userId)
      .first;
  final key = wakeUpDateKey(now, data.day.location.name);
  final choices = oneThingChoices(
    dots: data.blocks,
    inbox: inbox,
    nowUtc: now,
    mission: mission,
  );
  return OneThingOffer(
    dateKey: key,
    dots: choices.dots,
    inbox: choices.inbox,
    location: data.day.location,
    use24h: data.settings.use24h,
    pickedId: oneThingOn(data.settings.oneThing, key),
  );
}

/// Stores [occurrenceId] as the one thing of [dateKey]; any earlier pick
/// is quietly replaced (owner, 2026-11-01). Nothing else is written.
Future<Result<void, AppFailure>> pickOneThing(
  ProviderContainer container, {
  required String dateKey,
  required String occurrenceId,
}) => updateSettings(
  container,
  (s) => s.copyWith(
    oneThing: OneThing(date: dateKey, occurrenceId: occurrenceId),
  ),
);
