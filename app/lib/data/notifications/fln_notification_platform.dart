import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/sound_files.dart';
import 'package:dottoday/data/notifications/sound_names.gen.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
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

  /// Smallest step's reminders: Start only (M10.6).
  static const _startCategory = 'smallest_step';
  static const _channelIds = {
    NotificationChannelKind.alerts: 'alerts',
    NotificationChannelKind.summary: 'summary',
    NotificationChannelKind.alarms: 'alarms',
  };

  /// `res/raw/dot_alarm.m4a`, the same chime as [alarmSoundFile].
  static const _alarmSound = RawResourceAndroidNotificationSound('dot_alarm');

  // docs/12 §4: groups keep the per-sound channels readable in Android's
  // settings; legacy channels join them, never renamed or deleted.
  static const _dotsGroup = 'dottoday.group.dots';
  static const _startGroup = 'dottoday.group.start';

  /// Task alerts whose sound is "None": shown and vibrating, silent.
  static const _silentChannelId = 'dottoday.alert.none';

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
            for (final a in NotificationAction.osActions)
              DarwinNotificationAction.plain(
                a.name,
                _label(a),
                options: {DarwinNotificationActionOption.foreground},
              ),
          ],
        ),
        // Smallest step's one button (M10.6).
        DarwinNotificationCategory(
          _startCategory,
          actions: [
            DarwinNotificationAction.plain(
              NotificationAction.start.name,
              _label(NotificationAction.start),
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
    await _createChannels(android);
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

  /// Sounds whose channel the user turned below sound-making importance
  /// in Android's settings (docs/12 §4, the health panel). Empty elsewhere.
  @override
  Future<Set<String>> mutedSoundIds() async {
    final channels = await _android?.getNotificationChannels() ?? const [];
    return {
      for (final c in channels)
        if (c.importance.value < Importance.defaultImportance.value)
          ?soundIdOfChannel(c.id),
    };
  }

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

  /// What [schedule] hands the plugin for [n]. iOS can't report a pending
  /// or delivered notification's sound, so the device test reads it here.
  @visibleForTesting
  NotificationDetails detailsFor(OsNotification n) => _details(n);

  NotificationDetails _details(OsNotification n) {
    final channel = _channelFor(n);
    final darwin = DarwinNotificationDetails(
      categoryIdentifier: n.startAction
          ? _startCategory
          : n.withActions
          ? _category
          : null,
      presentBanner: !n.silent,
      presentSound: !n.silent && !n.soundOff,
      sound: switch (n) {
        // A loud dot only ever plays a Start sound (D2).
        OsNotification(loud: true, :final sound) => appleSoundFile(
          resolveStartSound(sound?.id),
        ),
        OsNotification(soundOff: true) => null,
        OsNotification(:final sound?) => appleSoundFile(sound),
        _ => null,
      },
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
        sound: channel.sound,
        audioAttributesUsage: n.loud
            ? AudioAttributesUsage.alarm
            : AudioAttributesUsage.notification,
        silent: n.silent,
        actions: [
          for (final a in [
            if (n.withActions) ...NotificationAction.osActions,
            if (n.startAction) NotificationAction.start,
          ])
            AndroidNotificationAction(
              a.name,
              _label(a),
              showsUserInterface: true,
            ),
        ],
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
          groupId: _dotsGroup,
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
          groupId: _startGroup,
        ),
      };

  Future<void> _createChannels(
    AndroidFlutterLocalNotificationsPlugin android,
  ) async {
    for (final (id, name) in [
      (_dotsGroup, _l10n.notifGroupDots),
      (_startGroup, _l10n.notifGroupStart),
    ]) {
      await android.createNotificationChannelGroup(
        AndroidNotificationChannelGroup(id, name),
      );
    }
    for (final channel in androidChannels) {
      await android.createNotificationChannel(channel);
    }
  }

  /// Every channel Dottoday posts on: the kinds, one per bundled sound
  /// (Android fixes a channel's sound), and None. Created idempotently on
  /// every start, so a new sound or a renamed one appears without loss.
  @visibleForTesting
  List<AndroidNotificationChannel> get androidChannels => [
    for (final kind in NotificationChannelKind.values) _channel(kind),
    for (final sound in soundCatalogue) ?_soundChannel(sound),
    _silentChannel,
  ];

  /// The channel [n] posts on (docs/12 §4).
  AndroidNotificationChannel _channelFor(OsNotification n) {
    if (n.loud || n.channel == NotificationChannelKind.alarms) {
      return switch (n.sound) {
        final s? when s.category == SoundCategory.start =>
          _soundChannel(s) ?? _channel(NotificationChannelKind.alarms),
        _ => _channel(NotificationChannelKind.alarms),
      };
    }
    if (n.channel != NotificationChannelKind.alerts) return _channel(n.channel);
    if (n.soundOff) return _silentChannel;
    return switch (n.sound) {
      final s? when s.category.isNormalTier =>
        _soundChannel(s) ?? _channel(NotificationChannelKind.alerts),
      _ => _channel(NotificationChannelKind.alerts),
    };
  }

  /// [sound]'s own channel, or null when it has none: `dot_alarm` is the
  /// legacy `alarms` channel and Done sounds never notify. Ids are
  /// permanent (docs/12 §4): `alerts_<id>` for the first-party tones (F6.6),
  /// `dottoday.alert.<id>` / `dottoday.alarm.<id>` for the rest.
  AndroidNotificationChannel? _soundChannel(CatalogueSound sound) {
    final id = channelIdForSound(sound);
    if (id == null) return null;
    final name = soundDisplayName(_l10n, sound);
    final raw = RawResourceAndroidNotificationSound(
      androidSoundResource(sound),
    );
    if (sound.category == SoundCategory.start) {
      return AndroidNotificationChannel(
        id,
        _l10n.notifChannelAlarmsSound(name),
        description: _l10n.notifChannelAlarmsDetail,
        importance: Importance.max,
        sound: raw,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        groupId: _startGroup,
      );
    }
    return AndroidNotificationChannel(
      id,
      _l10n.notifChannelAlertsSound(name),
      description: _l10n.notifChannelAlertsDetail,
      importance: Importance.high,
      sound: raw,
      groupId: _dotsGroup,
    );
  }

  AndroidNotificationChannel get _silentChannel => AndroidNotificationChannel(
    _silentChannelId,
    _l10n.notifChannelAlertsSilent,
    description: _l10n.notifChannelAlertsDetail,
    importance: Importance.high,
    playSound: false,
    groupId: _dotsGroup,
  );

  String _label(NotificationAction a) => switch (a) {
    NotificationAction.done => _l10n.notifActionDone,
    NotificationAction.snooze => _l10n.notifActionSnooze,
    NotificationAction.open => _l10n.notifActionOpen,
    NotificationAction.plus15 => _l10n.liveExtend,
    NotificationAction.start => _l10n.smallestStepStart,
  };

  static NotificationTap _tap(NotificationResponse r) =>
      NotificationTap(id: r.id, actionId: r.actionId, payload: r.payload);
}

/// The permanent Android channel id of [sound]'s own channel (docs/12 §4),
/// or null for `dot_alarm` (the legacy `alarms` channel) and Done sounds.
///
/// ```dart
/// channelIdForSound(resolveSound('chime'));       // 'alerts_chime'
/// channelIdForSound(resolveSound('clear.lift'));  // 'dottoday.alert.clear.lift'
/// channelIdForSound(resolveSound('start.swing')); // 'dottoday.alarm.start.swing'
/// ```
String? channelIdForSound(CatalogueSound sound) => switch (sound.category) {
  SoundCategory.dottoday => 'alerts_${sound.id}',
  SoundCategory.done => null,
  SoundCategory.start when sound.id == defaultStartSoundId => null,
  SoundCategory.start => 'dottoday.alarm.${sound.id}',
  _ => 'dottoday.alert.${sound.id}',
};

/// The sound id a Dottoday channel plays, or null for one that plays no
/// catalogue sound (`alerts`, `summary`, None) or isn't ours.
String? soundIdOfChannel(String? channelId) {
  if (channelId == 'alarms') return defaultStartSoundId;
  for (final prefix in ['alerts_', 'dottoday.alert.', 'dottoday.alarm.']) {
    if (channelId != null && channelId.startsWith(prefix)) {
      final sound = catalogueSound(channelId.substring(prefix.length));
      return sound?.id;
    }
  }
  return null;
}
