import 'dart:convert';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:crypto/crypto.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Turns a planned notification into what the OS shows (docs/02 F6): the
/// task's title over a line that says when, or the Bedtime summary.
///
/// [task] is the alerted task (for Bedtime, tomorrow's first one); null for
/// a task alert means the task is gone, and nothing should be posted.
OsNotification? composeNotification(
  PlannedNotification planned, {
  required Occurrence? task,
  required Profile profile,
}) {
  final l10n = _l10n(profile.locale);
  final String title;
  final String body;
  if (planned.purpose == NotificationPurpose.testAlarm) {
    title = l10n.testAlarmTitle;
    body = l10n.testAlarmBody;
  } else if (planned.purpose == NotificationPurpose.bedtime) {
    title = l10n.notifBedtimeTitle;
    body = task?.startUtc == null
        ? l10n.notifBedtimeFree
        : l10n.notifBedtimeFirst(task!.title, _time(task.startUtc!, profile));
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
    channel: planned.purpose == NotificationPurpose.bedtime
        ? NotificationChannelKind.summary
        : planned.loud
        ? NotificationChannelKind.alarms
        : NotificationChannelKind.alerts,
    silent: planned.silent,
    timeSensitive: planned.timeSensitive,
    loud: planned.loud,
    withActions: planned.purpose == NotificationPurpose.task,
  );
}

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
