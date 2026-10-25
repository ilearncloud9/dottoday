import 'dart:convert';

import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';

/// The payload the OS keeps with a scheduled notification (docs/04 §6).
///
/// It carries IDs and timing only, never a title or notes (06 §1), and
/// round-trips a [PlannedNotification] exactly, so the scheduler can diff
/// the OS pending set against the plan without a store of its own (R-10).
///
/// ```dart
/// final raw = encodeNotificationPayload(planned);
/// decodeNotificationPayload(planned.id, raw) == planned; // true
/// ```
///
/// [contentHash] fingerprints the text the OS shows, so a renamed task is
/// re-posted even though its plan is unchanged; read it back with
/// [notificationPayloadContentHash].
String encodeNotificationPayload(
  PlannedNotification n, {
  String? contentHash,
}) => jsonEncode({
  'v': 1,
  'h': ?contentHash,
  'o': n.occurrenceId,
  'a': n.alertIndex,
  't': n.fireAtUtc.millisecondsSinceEpoch,
  'k': n.kind.name,
  's': ?n.sound,
  if (n.silent) 'q': true,
  if (n.loud) 'l': true,
  if (n.purpose != NotificationPurpose.task) 'p': n.purpose.name,
  'n': ?n.blocks,
});

/// Reads a payload written by [encodeNotificationPayload] for OS id [id].
///
/// Returns null for anything else (an older format, a foreign or corrupt
/// payload); the scheduler then treats that notification as stale.
PlannedNotification? decodeNotificationPayload(int id, String? raw) {
  if (raw == null) return null;
  try {
    final map = jsonDecode(raw);
    if (map is! Map<String, Object?> || map['v'] != 1) return null;
    return PlannedNotification(
      id: id,
      occurrenceId: map['o']! as String,
      alertIndex: map['a']! as int,
      fireAtUtc: DateTime.fromMillisecondsSinceEpoch(
        map['t']! as int,
        isUtc: true,
      ),
      kind: AlertKind.values.byName(map['k']! as String),
      sound: map['s'] as String?,
      silent: map['q'] == true,
      loud: map['l'] == true,
      purpose: NotificationPurpose.values.byName(
        (map['p'] as String?) ?? NotificationPurpose.task.name,
      ),
      blocks: map['n'] as int?,
    );
  } on Object {
    // FormatException, a missing key (TypeError) or an unknown enum name
    // (ArgumentError): all mean "not ours", which the caller handles.
    return null;
  }
}

/// The content hash [encodeNotificationPayload] stored, if any.
String? notificationPayloadContentHash(String? raw) {
  if (raw == null) return null;
  try {
    final map = jsonDecode(raw);
    return map is Map<String, Object?> ? map['h'] as String? : null;
  } on Object {
    return null;
  }
}

/// What the user chose on a notification (docs/02 F6).
enum NotificationAction {
  /// Mark the task done.
  done,

  /// Remind again in [snoozeMinutes].
  snooze,

  /// Open the task (also a plain tap on the notification).
  open;

  /// Minutes a Snooze waits (docs/02 F6 "Snooze 10 min").
  static const snoozeMinutes = 10;

  /// The action for an OS action id; null or unknown is a plain tap.
  static NotificationAction fromId(String? id) =>
      values.where((a) => a.name == id).firstOrNull ?? open;
}
