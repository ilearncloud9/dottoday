import 'dart:async';

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
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/data/widgets/mac_menu_actions.dart';
import 'package:dottoday/data/widgets/mac_status_item_sink.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Runs [runHousekeeping] once after the first frame and on each resume.
class AppLifecycleScope extends ConsumerStatefulWidget {
  const AppLifecycleScope({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLifecycleScope> createState() => _AppLifecycleScopeState();
}

class _AppLifecycleScopeState extends ConsumerState<AppLifecycleScope>
    with WidgetsBindingObserver {
  /// A Mac or browser window can stay open for days without a resume, so
  /// housekeeping also runs on this timer (M5.2).
  static const _period = Duration(hours: 6);
  Timer? _timer;

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
    _timer = Timer.periodic(_period, (_) => unawaited(runHousekeeping(ref)));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(runHousekeeping(ref)),
    );
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
      ..invalidate(powerStateProvider)
      ..invalidate(mutedSoundsProvider)
      ..invalidate(currentDeviceZoneProvider)
      // Apple Intelligence switched on, Gemini Nano downloaded (M14.2).
      ..invalidate(thinkingStatusProvider)
      // The microphone switched on in Settings (M14.5).
      ..invalidate(speechAvailabilityProvider);
    unawaited(runHousekeeping(ref));
    // Back in the foreground: catch up with other devices (docs/04 §4).
    unawaited(ref.read(syncServiceProvider).syncNow());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
