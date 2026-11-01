import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/wake_up/channel_mission_sensors.dart';
import 'package:dottoday/domain/wake_up/mission_sensors.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'wake_up_providers.g.dart';

/// `yyyy-MM-dd` of [nowUtc] in [tzId]: the `wake_up_days` key and the
/// alarm id's day (docs/15 §3).
String wakeUpDateKey(DateTime nowUtc, String tzId) =>
    formatRouteDate(tz.TZDateTime.from(nowUtc, tz.getLocation(tzId)));

/// The sensors the missions read (docs/15 §8); tests override it.
@Riverpod(keepAlive: true)
MissionSensors missionSensors(Ref ref) => const ChannelMissionSensors();

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

  Future<void> run() async {
    final events = await ref.read(alarmGatewayProvider).drainEvents();
    if (events.isEmpty) return;
    await ref.read(wakeUpDayRepositoryProvider).applyEvents(events);
    ref.invalidate(lastWakeUpProvider);
  }
}
