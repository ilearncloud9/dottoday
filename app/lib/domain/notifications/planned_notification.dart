import 'package:dottoday/domain/entities/enums.dart';

/// What a planned notification is for.
enum NotificationPurpose {
  /// An alert of a task.
  task,

  /// Settings › Wind Down reminder: once a day at Wind Down, with tomorrow's
  /// first task (M3d.3, R-10).
  windDown,

  /// "Send me a test alarm" (11 A0, docs/09 M6.5.9): one loud alert in 60 s
  /// so the user can check it gets through.
  testAlarm,

  /// Settings › Reminders › Day-start summary: "Your day: 6 blocks, first
  /// at 08:00" at Wake Up on the chosen weekdays (docs/02 F6.2, M8.4d).
  daySummary,

  /// Smallest step (11 B2, docs/09 M10.6): planned start + 10 min with no
  /// real start and steps to do — "Just `step` · 2 min?" with Start.
  smallestStep,

  /// Settings › Day shape › Wake Up alarm (docs/15 W1, M17.1): loud at the
  /// Wake Up time on each planned day, on phones only.
  wakeUp,
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
    this.blocks,
  });

  /// Index used for the snooze reminder, after the ≤ 5 alert slots.
  static const snoozeIndex = 5;

  /// Index of the Wind Down reminder.
  static const windDownIndex = 6;

  /// Index of the test alarm (M6.5.9).
  static const testAlarmIndex = 7;

  /// Index of the day-start summary (M8.4d).
  static const daySummaryIndex = 8;

  /// Index of the Smallest step reminder (M10.6): one per occurrence.
  static const smallestStepIndex = 9;

  /// Index of the Wake Up alarm (M17.1): one per day.
  static const wakeUpIndex = 10;

  /// Stable OS notification ID; see `notificationIdFor`.
  final int id;

  /// The task alerted; for a Wind Down reminder, tomorrow's first task, or
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

  /// For a day-start summary, how many blocks the day has (a count, not
  /// task text, so it may ride in the payload; 06 §1).
  final int? blocks;

  /// Whether iOS should use the time-sensitive interruption level (07 iOS).
  bool get timeSensitive =>
      purpose == NotificationPurpose.testAlarm ||
      purpose == NotificationPurpose.wakeUp ||
      (purpose == NotificationPurpose.task &&
          kind == AlertKind.atStart &&
          !silent);

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
      other.purpose == purpose &&
      other.blocks == blocks;

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
    blocks,
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
