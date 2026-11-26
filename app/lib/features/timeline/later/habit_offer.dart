import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/onboarding/later_cards_store.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/onboarding/habit_days.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'habit_offer.g.dart';

const _daily = 'FREQ=DAILY'; // l10n-ignore: an RFC 5545 rule

/// "Make it a habit" for one of What fills your days' tasks (ED-491): the
/// task, the weekdays it was done on, and its next planned day, from
/// which the change applies.
typedef HabitOffer = ({Series series, Set<Weekday> days, Occurrence next});

/// The first of this device's onboarding tasks ready for "Make it a
/// habit" on [today], or null: still every day, three of its days done,
/// not every weekday, not offered before. Re-read as today's tasks change
/// (a tick can make one ready).
@riverpod
Future<HabitOffer?> habitOffer(Ref ref, DateTime today) async {
  ref.watch(timelineDataProvider(today));
  final later = await ref.watch(laterCardsProvider.future);
  if (later.onboardedUtc == null) return null;
  final profile = ref.watch(currentProfileProvider).value;
  if (profile == null) return null;
  final zone = tz.getLocation(profile.tzId);
  final now = ref.read(clockProvider).nowUtc();
  for (final id in later.habits) {
    if (later.habitsOffered.contains(id)) continue;
    final s = await ref.read(seriesRepositoryProvider).findById(profile.id, id);
    // Still every day, as What fills your days saved it.
    if (s == null || s.deletedAt != null || s.rrule != _daily) continue;
    final rows = await ref
        .read(occurrenceRepositoryProvider)
        .findBySeries(profile.id, id);
    final days = habitDays(rows, zone);
    if (days == null) continue;
    final next = [
      for (final o in rows)
        if (o.status == OccurrenceStatus.planned &&
            o.startUtc != null &&
            o.startUtc!.isAfter(now))
          o,
    ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
    if (next.isEmpty) continue;
    return (series: s, days: days, next: next.first);
  }
  return null;
}
