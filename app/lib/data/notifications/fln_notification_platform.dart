import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// [NotificationPlatform] on `flutter_local_notifications`: iOS, Android
/// and macOS (docs/07, docs/09 M5.1). Web is M5.3.
///
/// Done / Snooze / Open bring the app forward and are handled in the main
/// isolate, where the one database connection lives (docs/02 F6).
final class FlnNotificationPlatform implements NotificationPlatform {
  FlnNotificationPlatform(
    this._plugin,
    this._l10n,
    this._clock, {
    Future<void> Function()? prepare,
  }) : _prepare = prepare;

  final FlutterLocalNotificationsPlugin _plugin;
  final AppLocalizations _l10n;
  final Clock _clock;

  /// Runs before anything is scheduled: on Apple platforms, installs the
  /// alarm chime (`installAlarmSound`).
  final Future<void> Function()? _prepare;

  /// Exact alarms when Android allows them; inexact otherwise, which
  /// Settings explains (M5.6).
  var _exact = false;

  static const _category = 'task';
  static const _channelIds = {
    NotificationChannelKind.alerts: 'alerts',
    NotificationChannelKind.summary: 'summary',
    NotificationChannelKind.alarms: 'alarms',
  };

  /// `res/raw/dot_alarm.m4a`, the same chime as [alarmSoundFile].
  static const _alarmSound = RawResourceAndroidNotificationSound('dot_alarm');

  @override
  Future<void> initialize(void Function(NotificationTap) onTap) async {
    await _prepare?.call();
    final darwin = DarwinInitializationSettings(
      // Asked from onboarding O4 / Settings, never at launch (docs/03).
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: [
        DarwinNotificationCategory(
          _category,
          actions: [
            for (final a in NotificationAction.values)
              DarwinNotificationAction.plain(
                a.name,
                _label(a),
                options: {DarwinNotificationActionOption.foreground},
              ),
          ],
        ),
      ],
    );
    await _plugin.initialize(
      InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: darwin,
        macOS: darwin,
      ),
      onDidReceiveNotificationResponse: (r) => onTap(_tap(r)),
    );
    final android = _android;
    if (android == null) return;
    for (final kind in NotificationChannelKind.values) {
      await android.createNotificationChannel(_channel(kind));
    }
    _exact = await android.canScheduleExactNotifications() ?? false;
  }

  @override
  Future<NotificationTap?> launchTap() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (!(details?.didNotificationLaunchApp ?? false) || response == null) {
      return null;
    }
    return _tap(response);
  }

  @override
  Future<List<(int, String?)>> pending() async {
    // The user can allow or revoke exact alarms at any time (M5.6). When it
    // changes, every pending alert is posted again in the new mode: the
    // empty pending set makes the next diff schedule them all.
    final exact = await _android?.canScheduleExactNotifications() ?? false;
    if (exact != _exact) {
      _exact = exact;
      await _plugin.cancelAll();
      return const [];
    }
    return [
      for (final r in await _plugin.pendingNotificationRequests())
        (r.id, r.payload),
    ];
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);

  @override
  Future<void> schedule(OsNotification n) async {
    // The OS refuses a time already past; the next resync re-plans.
    if (!n.fireAtUtc.isAfter(_clock.nowUtc())) return;
    await _plugin.zonedSchedule(
      n.id,
      n.title,
      n.body,
      tz.TZDateTime.from(n.fireAtUtc, tz.UTC),
      _details(n),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: _exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: n.payload,
    );
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  NotificationDetails _details(OsNotification n) {
    final channel = _channel(n.channel);
    final darwin = DarwinNotificationDetails(
      categoryIdentifier: n.withActions ? _category : null,
      presentBanner: !n.silent,
      presentSound: !n.silent,
      sound: n.loud ? alarmSoundFile : null,
      interruptionLevel: n.silent
          ? InterruptionLevel.passive
          : n.timeSensitive
          ? InterruptionLevel.timeSensitive
          : InterruptionLevel.active,
    );
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: switch (n.channel) {
          NotificationChannelKind.alarms => Priority.max,
          NotificationChannelKind.alerts => Priority.high,
          NotificationChannelKind.summary => Priority.defaultPriority,
        },
        category: n.loud
            ? AndroidNotificationCategory.alarm
            : AndroidNotificationCategory.reminder,
        // Wakes the screen like an alarm; MainActivity deliberately has no
        // showWhenLocked, so no task list appears over the lock screen.
        fullScreenIntent: n.loud,
        sound: n.loud ? _alarmSound : null,
        audioAttributesUsage: n.loud
            ? AudioAttributesUsage.alarm
            : AudioAttributesUsage.notification,
        silent: n.silent,
        actions: n.withActions
            ? [
                for (final a in NotificationAction.values)
                  AndroidNotificationAction(
                    a.name,
                    _label(a),
                    showsUserInterface: true,
                  ),
              ]
            : null,
      ),
      iOS: darwin,
      macOS: darwin,
    );
  }

  AndroidNotificationChannel _channel(NotificationChannelKind kind) =>
      switch (kind) {
        NotificationChannelKind.alerts => AndroidNotificationChannel(
          _channelIds[kind]!,
          _l10n.notifChannelAlerts,
          description: _l10n.notifChannelAlertsDetail,
          importance: Importance.high,
        ),
        NotificationChannelKind.summary => AndroidNotificationChannel(
          _channelIds[kind]!,
          _l10n.notifChannelSummary,
          description: _l10n.notifChannelSummaryDetail,
        ),
        NotificationChannelKind.alarms => AndroidNotificationChannel(
          _channelIds[kind]!,
          _l10n.notifChannelAlarms,
          description: _l10n.notifChannelAlarmsDetail,
          importance: Importance.max,
          sound: _alarmSound,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      };

  String _label(NotificationAction a) => switch (a) {
    NotificationAction.done => _l10n.notifActionDone,
    NotificationAction.snooze => _l10n.notifActionSnooze,
    NotificationAction.open => _l10n.notifActionOpen,
  };

  static NotificationTap _tap(NotificationResponse r) =>
      NotificationTap(id: r.id, actionId: r.actionId, payload: r.payload);
}
