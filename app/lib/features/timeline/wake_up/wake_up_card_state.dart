import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:dottoday/domain/scheduling/low_energy.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/wake_up/wake_up_card.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:dottoday/features/timeline/state/day_ends.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wake_up_card_state.g.dart';

/// Everything the Wake Up card reads, at one moment (docs/15 §5): today's
/// blocks, this device's morning, the Inbox count and the first dot's
/// first step. Read-only: the card writes through Focus, Rebalance's
/// ProposalSheet and `wake_up_days` only.
final class WakeUpCardModel {
  const WakeUpCardModel({
    required this.data,
    required this.shape,
    required this.day,
    required this.nowUtc,
    required this.dateKey,
    required this.inbox,
    required this.steps,
    required this.nextWakeUtc,
  });

  final TimelineData data;
  final DayShape shape;
  final WakeUpDay? day;
  final DateTime nowUtc;

  /// `wake_up_days` key of today.
  final String dateKey;
  final int inbox;

  /// First step to do of each task with untouched steps (B2).
  final Map<String, Subtask> steps;

  /// Where tonight's night ends, for the day dot (docs/15 W6).
  final DateTime nextWakeUtc;

  Settings get settings => data.settings;

  /// Dots still to come or under way, in start order.
  List<Occurrence> get ahead => [
    for (final o in data.blocks)
      if (o.status == OccurrenceStatus.planned && o.endUtc!.isAfter(nowUtc)) o,
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));

  Occurrence? get first => ahead.firstOrNull;

  /// Today's calendar events, timed and all-day (15 §5 step 5).
  List<Occurrence> get calendar => [
    for (final o in [...data.blocks, ...data.allDay])
      if (o.source == OccurrenceSource.calendar) o,
  ];

  /// "You're up N min after plan." when it applies (15 §5 step 6).
  int? get lateMin =>
      lateStartMin(day: day, shape: shape, nowUtc: nowUtc, settings: settings);

  /// Low-energy mode (D2): the first dot and Start only.
  bool get lowEnergy => lowEnergyOn(settings, nowUtc);
}

/// Today's Wake Up card (docs/15 §5, M17.3).
@riverpod
Future<WakeUpCardModel> wakeUpCard(Ref ref) async {
  final date = await ref.watch(todayDateProvider.future);
  final data = await ref.watch(timelineDataProvider(date).future);
  final day = await ref.watch(wakeUpTodayProvider.future);
  final steps = await ref.watch(dayFirstStepsProvider(date).future);
  final now = ref.watch(clockProvider).nowUtc();
  final inbox = await ref
      .watch(occurrenceRepositoryProvider)
      .watchInbox(data.userId)
      .first;
  final ends = await ref.watch(dayEndsProvider(date).future);
  return WakeUpCardModel(
    data: data,
    shape: ends.shape,
    nextWakeUtc: ends.nextWakeUtc,
    day: day,
    nowUtc: now,
    dateKey: wakeUpDateKey(now, data.day.location.name),
    inbox: inbox.length,
    steps: steps,
  );
}

/// Today's key when the card should open by itself now, else null (15 §5,
/// `wakeUpCardDue`). Phones only. Minimal mode opens it only after "I'm
/// up" (15 §10): an unexpected full-screen route is what it avoids.
@riverpod
Future<String?> wakeUpCardDueNow(Ref ref) async {
  if (!currentHealthPlatform().isPhone) return null;
  final m = await ref.watch(wakeUpCardProvider.future);
  final firstOpen =
      ref.watch(layoutPolicyProvider).visibility(FeatureId.wakeUpCard) !=
      FeatureVisibility.simplified;
  final due = wakeUpCardDue(
    day: m.day,
    shape: m.shape,
    nowUtc: m.nowUtc,
    settings: m.settings,
    hasThread: m.data.blocks.isNotEmpty,
    firstOpen: firstOpen,
  );
  return due ? m.dateKey : null;
}
