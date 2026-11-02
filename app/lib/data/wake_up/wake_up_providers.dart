import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/reveal/hint_providers.dart';
import 'package:dottoday/data/wake_up/channel_mission_sensors.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/reveal/hint_scheduler.dart';
import 'package:dottoday/domain/reveal/hint_signals.dart';
import 'package:dottoday/domain/wake_up/mission_sensors.dart';
import 'package:dottoday/domain/wake_up/one_thing.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:dottoday/domain/wake_up/wind_down_learn.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'wake_up_providers.g.dart';

/// `yyyy-MM-dd` of [nowUtc] in [tzId]: the `wake_up_days` key and the
/// alarm id's day (docs/15 §3).
String wakeUpDateKey(DateTime nowUtc, String tzId) =>
    formatRouteDate(tz.TZDateTime.from(nowUtc, tz.getLocation(tzId)));

/// The occurrence id of today's one thing (docs/15 §8), or null: none
/// picked, or picked on another day (it clears when the day ends). Every
/// surface that rings it reads this, so they agree.
@riverpod
String? todayOneThingId(Ref ref) {
  final profile = ref.watch(currentProfileProvider).value;
  if (profile == null) return null;
  final now =
      ref.watch(minuteTickProvider).value ?? ref.watch(clockProvider).nowUtc();
  return oneThingOn(
    profile.settings.oneThing,
    wakeUpDateKey(now, profile.tzId),
  );
}

/// The learned Wind Down offer due now (docs/15 §7b): how long after Wake
/// Up the user usually gets up on this phone, and the minutes Wind Down
/// would move earlier; null when it isn't due.
@riverpod
Future<({int usual, int more})?> learnedWindDownOffer(Ref ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  final now = ref.watch(clockProvider).nowUtc();
  final days = await ref
      .watch(wakeUpDayRepositoryProvider)
      .recentStops(learnWakeUpDays);
  final usual = medianDismissOffsetMin(
    days,
    settings: profile.settings,
    location: tz.getLocation(profile.tzId),
  );
  final more = windDownLearnOfferMin(
    profile.settings,
    offsetMin: usual,
    nowUtc: now,
  );
  return usual == null || more == null ? null : (usual: usual, more: more);
}

/// The Wake Up discovery signals (docs/15 §11): whether this phone can
/// ring Wake Up while it is off (the promise), and whether its last
/// mornings were stopped late with missions off on the alarm tier (the
/// mission offer). Both false off a phone.
@riverpod
Future<({bool wakeUpOffer, bool lateMornings})> wakeUpDiscovery(Ref ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  final caps = await ref.watch(alarmCapabilitiesNowProvider.future);
  final settings = profile.settings;
  if (caps.blockers.contains(AlarmBlocker.notAPhone)) {
    return (wakeUpOffer: false, lateMornings: false);
  }
  final missions =
      settings.wakeUpAlarm &&
      settings.missionMode == MissionMode.off &&
      caps.tier == AlarmTier.alarm;
  final days = missions
      ? await ref
            .watch(wakeUpDayRepositoryProvider)
            .recentStops(lateMorningsForHint)
      : const <WakeUpDay>[];
  return (
    wakeUpOffer: !settings.wakeUpAlarm,
    lateMornings:
        missions &&
        lateMorningsOf(
          dismissOffsetsMin(
            days,
            settings: settings,
            location: tz.getLocation(profile.tzId),
          ),
        ),
  );
}

/// The sensors the missions read (docs/15 §8); tests override it.
@Riverpod(keepAlive: true)
MissionSensors missionSensors(Ref ref) => const ChannelMissionSensors();

/// Whether this device can run [kind] now (15 §8), re-read when Settings
/// asks for a permission.
@riverpod
Future<MissionSupport> missionSupport(Ref ref, MissionKind kind) =>
    ref.watch(missionSensorsProvider).support(kind);

/// Today's row on this device, null until the alarm or the card did
/// something (docs/15 §3, M17.3).
@riverpod
Stream<WakeUpDay?> wakeUpToday(Ref ref) async* {
  final profile = await ref.watch(currentProfileProvider.future);
  final now = ref.watch(clockProvider).nowUtc();
  yield* ref
      .watch(wakeUpDayRepositoryProvider)
      .watch(wakeUpDateKey(now, profile.tzId));
}

/// The newest morning the alarm rang or was stopped on this device, for
/// Notification health's "Last wake-up" line (docs/15 §4).
@riverpod
Future<WakeUpDay?> lastWakeUp(Ref ref) =>
    ref.watch(wakeUpDayRepositoryProvider).lastAlarm();

/// Folds what the alarms did while the app was closed (rang, snoozed,
/// "I'm up") into `wake_up_days`: run on launch and every resume, before
/// Today decides whether the Wake Up card opens (M17.3).
@Riverpod(keepAlive: true)
class AlarmEventsDrain extends _$AlarmEventsDrain {
  @override
  void build() {}

  /// Returns the mission location to open when "I'm up" opened one the
  /// OS side couldn't show itself (iOS, 15 §8), else null.
  Future<String?> run() async {
    final events = await ref.read(alarmGatewayProvider).drainEvents();
    if (events.isEmpty) return null;
    await ref.read(wakeUpDayRepositoryProvider).applyEvents(events);
    ref.invalidate(lastWakeUpProvider);
    await _countCheckPing(events);
    return switch (openMission(events)) {
      (final date, final kind) when AppRoutes.missionKinds.contains(kind) =>
        AppRoutes.mission(date, kind),
      _ => null,
    };
  }

  /// "I'm up" armed the check, whose notification says where to change it
  /// while that is due (15 §11): one of its two showings, counted without
  /// taking the day's hint slot.
  Future<void> _countCheckPing(List<AlarmEvent> events) async {
    final stopped = events.any(
      (e) => e.kind == AlarmEventKind.stopped && e.date != null,
    );
    if (!stopped) return;
    // The row, not a provider only read here (see `readProfile`).
    final profile = await readProfile(ref.container);
    if (!profile.settings.wakeUpCheck) return;
    final repo = ref.read(revealHintRepositoryProvider);
    if (!await checkPingDue(repo, profile.id)) return;
    await recordHintShown(
      ref.container,
      HintId.wakeUpCheckPing,
      spendDay: false,
    );
  }
}
