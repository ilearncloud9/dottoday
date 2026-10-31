import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/calendar/cloud_calendar_providers.dart';
import 'package:dottoday/data/intents/intent_providers.dart';
import 'package:dottoday/data/intents/intent_queue_channel.dart';
import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/refresh/refresh_providers.dart';
import 'package:dottoday/data/snapshot/snapshot_providers.dart';
import 'package:dottoday/data/speech/speech_providers.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/data/system/system_events.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/data/widgets/mac_menu_actions.dart';
import 'package:dottoday/data/widgets/mac_status_item_sink.dart';
import 'package:dottoday/domain/time/housekeeping_due.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Housekeeping on app start and on every resume (docs/09 M3.2, M2.3–M2.5):
/// ensure the local profile, take the daily backup if due, purge expired
/// Trash, apply queued intents (M9.2), then the daily refresh: roll repeats forward and re-plan OS
/// notifications (M5.2), arm the Wind Down snapshot (M9.1), then bring
/// calendar events in (device M7.2,
/// Google/Microsoft M7.4). Each step is idempotent and runs
/// after the first frame, so it never delays the UI; failures are logged
/// and the next start/resume repairs them.
Future<void> runHousekeeping(WidgetRef ref) async {
  final logger = ref.read(loggerProvider);
  try {
    final profile = await ref.read(localProfileProvider.future);
    final backup = await ref
        .read(backupServiceProvider)
        .runDailyIfDue(profile.id);
    if (backup case Err(:final failure)) {
      logger.warn('housekeeping.backup_failed', error: failure);
    }
    final purge = await ref.read(trashServiceProvider).purgeExpired(profile.id);
    if (purge case Err(:final failure)) {
      logger.warn('housekeeping.purge_failed', error: failure);
    }
    // What widgets, controls and notifications queued while the app was
    // closed, before the refresh redraws everything (M9.2).
    await _drainQueue(ref);
    await ref.read(dailyRefreshProvider).run(profile.id);
    await ref.read(bedtimeSnapshotProvider).arm(profile.id);
    await ref.read(calendarActionsProvider).importEvents();
  } on Object catch (e, st) {
    logger.error('housekeeping.failed', error: e, stackTrace: st);
  }
}

// A queue that can't be read must not hold up the refresh.
Future<void> _drainQueue(WidgetRef ref) async {
  try {
    await ref.read(actionQueueDrainerProvider).drain();
  } on Object catch (e, st) {
    ref
        .read(loggerProvider)
        .error('intent.drain_failed', error: e, stackTrace: st);
  }
}

/// Runs [runHousekeeping] after the first frame, on each resume, when the
/// OS says the Mac woke or the clock or zone changed, and at the moment the
/// next run is due while the app stays open ([housekeepingDueUtc]: local
/// midnight or the daily backup). Nothing runs on a polling period
/// (docs/04 §4 "Triggers"). Device calendar changes import their events.
class AppLifecycleScope extends ConsumerStatefulWidget {
  const AppLifecycleScope({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLifecycleScope> createState() => _AppLifecycleScopeState();
}

class _AppLifecycleScopeState extends ConsumerState<AppLifecycleScope>
    with WidgetsBindingObserver {
  /// The next due run, re-armed after every run (a Mac or browser window
  /// can stay open for days without a resume, M5.2).
  Timer? _due;
  StreamSubscription<SystemEvent>? _events;
  var _running = false;
  var _again = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // A widget or Siri queued an action while the app is open (M9.2).
    listenForQueuedIntents(() => _drainQueue(ref));
    // Done / +15 from the Mac menu bar (M9.6).
    if (MacStatusItemSink.supported) {
      listenForMenuBarActions(ref.read(dotIntentsProvider));
    }
    _events = ref.read(systemEventsProvider).events.listen(_onSystemEvent);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_housekeep()),
    );
  }

  void _onSystemEvent(SystemEvent event) {
    switch (event) {
      // Timers may have slept through their moment, or the day moved.
      case SystemEvent.wake || SystemEvent.clock:
        ref.invalidate(currentDeviceZoneProvider);
        unawaited(_housekeep());
      case SystemEvent.calendar:
        ref.read(calendarActionsProvider).deviceCalendarChanged();
    }
  }

  /// One run at a time (a resume and a wake can coincide; one asked for
  /// meanwhile runs once after), then the next due run is armed.
  Future<void> _housekeep() async {
    if (_running) {
      _again = true;
      return;
    }
    _running = true;
    try {
      do {
        _again = false;
        await runHousekeeping(ref);
      } while (_again && mounted);
      if (mounted) await _armNext();
    } finally {
      _running = false;
    }
  }

  Future<void> _armNext() async {
    try {
      final profile = await ref.read(localProfileProvider.future);
      final backupDue = await ref
          .read(backupServiceProvider)
          .nextDailyDueUtc(profile.id);
      if (!mounted) return;
      final now = ref.read(clockProvider).nowUtc();
      final at = housekeepingDueUtc(
        location: tz.getLocation(profile.tzId),
        nowUtc: now,
        backupDueUtc: backupDue,
      );
      _due?.cancel();
      _due = Timer(at.difference(now), () => unawaited(_housekeep()));
    } on Object catch (e, st) {
      // The next start, resume or OS event arms it again.
      ref
          .read(loggerProvider)
          .error('housekeeping.arm_failed', error: e, stackTrace: st);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // Back from the system settings: what the OS allows may have changed;
    // back from a flight: the zone may have (M5.9).
    ref
      ..invalidate(notificationPermissionStateProvider)
      ..invalidate(calendarPermissionStateProvider)
      // Back from connecting a Google/Microsoft account (M7.4).
      ..invalidate(cloudAccountsProvider)
      ..invalidate(exactAlarmsAllowedProvider)
      // The full-screen intent re-allowed for the Wake Up alarm (M17.1).
      ..invalidate(alarmCapabilitiesNowProvider)
      ..invalidate(powerStateProvider)
      ..invalidate(mutedSoundsProvider)
      ..invalidate(currentDeviceZoneProvider)
      // Apple Intelligence switched on, Gemini Nano downloaded (M14.2).
      ..invalidate(thinkingStatusProvider)
      // The microphone switched on in Settings (M14.5).
      ..invalidate(speechAvailabilityProvider);
    unawaited(_housekeep());
    // Back in the foreground: catch up with other devices (docs/04 §4).
    unawaited(ref.read(syncServiceProvider).syncNow());
  }

  @override
  void dispose() {
    _due?.cancel();
    unawaited(_events?.cancel());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
