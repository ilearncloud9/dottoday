import 'dart:convert';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:crypto/crypto.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/domain/notifications/wake_up_alarm.dart';
import 'package:dottoday/domain/time/wind_down.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Turns a planned notification into what the OS shows (docs/02 F6): the
/// task's title over a line that says when, or the Wind Down summary.
///
/// [task] is the alerted task (for Wind Down, tomorrow's first one); null for
/// a task alert means the task is gone, and nothing should be posted.
OsNotification? composeNotification(
  PlannedNotification planned, {
  required Occurrence? task,
  required Profile profile,
  Subtask? step,
}) {
  final l10n = _l10n(profile.locale);
  final String title;
  final String body;
  if (planned.purpose == NotificationPurpose.testAlarm) {
    title = l10n.testAlarmTitle;
    body = l10n.testAlarmBody;
  } else if (planned.purpose == NotificationPurpose.windDown) {
    title = l10n.notifWindDownTitle;
    body = _windDownBody(l10n, planned, task, profile);
  } else if (planned.purpose == NotificationPurpose.wakeUp) {
    // Never dropped: an alarm whose first block just went still rings.
    title = l10n.notifWakeUpTitle;
    body = task?.startUtc == null
        ? l10n.notifWakeUpBody
        : l10n.notifWakeUpFirst(task!.title, _time(task.startUtc!, profile));
  } else if (planned.purpose == NotificationPurpose.daySummary) {
    // The first block gone since planning: the next resync re-counts.
    if (task?.startUtc == null) return null;
    title = l10n.notifDaySummaryTitle;
    body = l10n.notifDaySummaryBody(
      planned.blocks ?? 1,
      _time(task!.startUtc!, profile),
    );
  } else if (planned.purpose == NotificationPurpose.smallestStep) {
    // Started, or every step done, since planning: the next resync drops it.
    if (task == null || step == null) return null;
    title = smallestStepText(l10n, step);
    body = task.title;
  } else if (planned.purpose == NotificationPurpose.startNudge) {
    // Started or gone since planning: the next resync drops it.
    if (task == null) return null;
    title = l10n.startNudgeTitle(task.title);
    body = l10n.startNudgeBody;
  } else {
    if (task == null) return null;
    title = task.title;
    body = _taskBody(l10n, planned, task);
  }
  return OsNotification(
    id: planned.id,
    title: title,
    body: body,
    fireAtUtc: planned.fireAtUtc,
    payload: encodeNotificationPayload(
      planned,
      contentHash: notificationContentHash(title, body),
    ),
    channel: planned.loud
        ? NotificationChannelKind.alarms
        : planned.purpose == NotificationPurpose.task ||
              planned.purpose == NotificationPurpose.smallestStep ||
              planned.purpose == NotificationPurpose.startNudge
        ? NotificationChannelKind.alerts
        : NotificationChannelKind.summary,
    silent: planned.silent,
    timeSensitive: planned.timeSensitive,
    loud: planned.loud,
    alarmClock: planned.purpose == NotificationPurpose.wakeUp,
    withActions: planned.purpose == NotificationPurpose.task,
    startAction:
        planned.purpose == NotificationPurpose.smallestStep ||
        planned.purpose == NotificationPurpose.startNudge,
    sound: _soundOf(planned),
    soundOff:
        planned.purpose == NotificationPurpose.task &&
        !planned.loud &&
        planned.sound == soundNoneKey,
  );
}

/// The Wind Down reminder's line. With a sleep target it names what the
/// night protects, "Wind down now for 7 h 30 before Run at 06:30." (docs/15
/// W6); without one it is the same as before M17.5.
String _windDownBody(
  AppLocalizations l10n,
  PlannedNotification planned,
  Occurrence? task,
  Profile profile,
) {
  final start = task?.startUtc;
  if (profile.settings.sleepTargetMin == null) {
    return start == null
        ? l10n.notifWindDownFree
        : l10n.notifWindDownFirst(task!.title, _time(start, profile));
  }
  final location = tz.getLocation(profile.tzId);
  final local = tz.TZDateTime.from(planned.fireAtUtc, location);
  final wake = nextWakeUtc(
    location,
    DateTime(local.year, local.month, local.day),
    profile.settings,
  );
  final length = _length(l10n, nightMinutes(planned.fireAtUtc, wake));
  return start == null
      ? l10n.notifWindDownNudgeNoDot(length, _time(wake, profile))
      : l10n.notifWindDownNudge(length, task!.title, _time(start, profile));
}

/// [planned] (a Wake Up) as the alarm `AlarmGateway` arms (docs/15 W1b):
/// the notification's own words, the day's cue and [settings]' snooze and
/// ramp. [minimal] is minimal mode's ringing screen (15 §10), decided by
/// the caller's `LayoutPolicy` (ADR-0016: notification code never reads
/// the layout). [id] replaces the day's id (the test alarm's). [step] is
/// [task]'s Smallest step, which the Wake Up Check offers (15 W3).
WakeUpAlarm composeWakeUpAlarm(
  PlannedNotification planned, {
  required Occurrence? task,
  required Profile profile,
  bool minimal = false,
  String? id,
  Subtask? step,
}) {
  final l10n = _l10n(profile.locale);
  final settings = profile.settings;
  final shown = composeNotification(planned, task: task, profile: profile);
  final day = tz.TZDateTime.from(
    planned.fireAtUtc,
    tz.getLocation(profile.tzId),
  );
  return WakeUpAlarm(
    id: id ?? 'wakeup:${DateFormat('yyyy-MM-dd').format(day)}',
    fireAtUtc: planned.fireAtUtc,
    sound: resolveStartSound(planned.sound),
    title: shown?.title ?? l10n.notifWakeUpTitle,
    body: shown?.body ?? l10n.notifWakeUpBody,
    stopLabel: l10n.wakeUpStop,
    snoozeLabel: l10n.wakeUpSnooze,
    snoozeMinutes: settings.wakeUpSnooze ? settings.wakeUpSnoozeMin : 0,
    snoozeLimit: settings.wakeUpSnoozeMax,
    rampSeconds: settings.wakeUpRampSec,
    minimal: minimal,
    check: settings.wakeUpCheck && task != null && id == null
        ? WakeUpCheck(
            minutes: settings.wakeUpCheckMin,
            occurrenceId: task.id,
            title: step == null
                ? l10n.wakeUpCheckStart(task.title)
                : smallestStepText(l10n, step),
            body: step == null ? l10n.wakeUpCheckBody : task.title,
            startLabel: l10n.smallestStepStart,
            loud: settings.wakeUpCheckLoud,
          )
        : null,
  );
}

/// The sound [planned] plays (docs/12): the Start sound when loud and for
/// the test alarm, the planner's resolved key for a task reminder (null =
/// the OS sound), and none for the summaries, Wind Down and Smallest step.
CatalogueSound? _soundOf(PlannedNotification planned) {
  // The test alarm sounds like the real first dot (docs/12 D2); the Wake
  // Up alarm rings with the Start sound too (docs/15 W1).
  if (planned.purpose == NotificationPurpose.testAlarm ||
      planned.purpose == NotificationPurpose.wakeUp) {
    return resolveStartSound(planned.sound);
  }
  if (planned.purpose != NotificationPurpose.task) return null;
  if (planned.loud) return resolveStartSound(planned.sound);
  return switch (planned.sound) {
    null || soundNoneKey => null,
    final key => resolveSound(key),
  };
}

/// "Just Gather documents · 10 min?" (11 B2): the first step only.
String smallestStepText(AppLocalizations l10n, Subtask step) {
  final minutes = step.durationMin;
  if (minutes == null) return l10n.smallestStepTitleShort(step.title);
  return l10n.smallestStepTitle(step.title, _length(l10n, minutes));
}

/// "10 min", "2 h", "7 h 30".
String _length(AppLocalizations l10n, int minutes) => minutes < 60
    ? l10n.durationMinutes(minutes)
    : minutes % 60 == 0
    ? l10n.durationHours(minutes ~/ 60)
    : l10n.durationHoursMinutesShort(minutes ~/ 60, minutes % 60);

/// A short fingerprint of the shown text, so an edit re-posts (R-10).
String notificationContentHash(String title, String body) =>
    sha256.convert(utf8.encode('$title\n$body')).toString().substring(0, 12);

String _taskBody(
  AppLocalizations l10n,
  PlannedNotification planned,
  Occurrence task,
) {
  if (planned.alertIndex == PlannedNotification.snoozeIndex) {
    return l10n.notifSnoozed;
  }
  int minutesFrom(DateTime? at) =>
      at == null ? 0 : planned.fireAtUtc.difference(at).inMinutes.abs();
  return switch (planned.kind) {
    AlertKind.before => l10n.notifStartsIn(minutesFrom(task.startUtc)),
    AlertKind.atStart => l10n.notifStartsNow,
    AlertKind.atEnd => l10n.notifEndsNow,
    AlertKind.overdue => l10n.notifOverdue(minutesFrom(task.endUtc)),
  };
}

AppLocalizations _l10n(String locale) {
  final wanted = Locale(locale);
  final supported = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == wanted.languageCode,
  );
  return lookupAppLocalizations(supported ? wanted : const Locale('en'));
}

/// The task's start on the profile's clock, 12 h or 24 h as set (null
/// follows the OS, docs/05).
String _time(DateTime utc, Profile profile) {
  final local = tz.TZDateTime.from(utc, tz.getLocation(profile.tzId));
  final use24h =
      profile.settings.use24h ??
      PlatformDispatcher.instance.alwaysUse24HourFormat;
  return DateFormat(use24h ? 'HH:mm' : 'h:mm a', profile.locale).format(local);
}
