import 'package:dottoday/domain/entities/enums.dart';

/// What a planned notification is for.
enum NotificationPurpose {
  /// An alert of a task.
  task,

  /// Settings › Bedtime reminder: once a day at Bedtime, with tomorrow's
  /// first task (M3d.3, R-10).
  bedtime,
}

/// One notification the OS should hold (docs/04 §6).
///
/// Deliberately carries no title or notes: the payload is the occurrence ID
/// only, and the scheduler looks the text up when it posts (06 §1, §7).
final class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.occurrenceId,
    required this.alertIndex,
    required this.fireAtUtc,
    required this.kind,
    this.sound,
    this.silent = false,
    this.loud = false,
    this.purpose = NotificationPurpose.task,
  });

  /// Index used for the snooze reminder, after the ≤ 5 alert slots.
  static const snoozeIndex = 5;

  /// Index of the Bedtime reminder.
  static const bedtimeIndex = 6;

  /// Stable OS notification ID; see `notificationIdFor`.
  final int id;

  /// The task alerted; for a Bedtime reminder, tomorrow's first task, or
  /// empty when tomorrow has none.
  final String occurrenceId;

  /// Position in the occurrence's alert list, or [snoozeIndex].
  final int alertIndex;
  final DateTime fireAtUtc;
  final AlertKind kind;
  final String? sound;

  /// Delivered without sound or banner because it falls in quiet hours.
  final bool silent;

  /// Rings like an alarm: the day's first dot-start or a routine start
  /// (11 A0, `loudStartIds`). Never silent, even in quiet hours.
  final bool loud;
  final NotificationPurpose purpose;

  /// Whether iOS should use the time-sensitive interruption level (07 iOS).
  bool get timeSensitive =>
      purpose == NotificationPurpose.task &&
      kind == AlertKind.atStart &&
      !silent;

  @override
  bool operator ==(Object other) =>
      other is PlannedNotification &&
      other.id == id &&
      other.occurrenceId == occurrenceId &&
      other.alertIndex == alertIndex &&
      other.fireAtUtc == fireAtUtc &&
      other.kind == kind &&
      other.sound == sound &&
      other.silent == silent &&
      other.loud == loud &&
      other.purpose == purpose;

  @override
  int get hashCode => Object.hash(
    id,
    occurrenceId,
    alertIndex,
    fireAtUtc,
    kind,
    sound,
    silent,
    loud,
    purpose,
  );

  @override
  String toString() =>
      'PlannedNotification($id, $occurrenceId#$alertIndex, '
      '$fireAtUtc, ${kind.name}${silent ? ', silent' : ''}'
      '${loud ? ', loud' : ''})';
}

/// What the scheduler must change to turn the OS pending set into the
/// desired set: cancel first, then schedule (docs/02 F6).
final class NotificationDiff {
  const NotificationDiff({required this.schedule, required this.cancel});

  final List<PlannedNotification> schedule;
  final List<int> cancel;

  bool get isEmpty => schedule.isEmpty && cancel.isEmpty;
}
