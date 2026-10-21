import 'package:dottoday/domain/entities/enums.dart';

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
  });

  /// Index used for the snooze reminder, after the ≤ 5 alert slots.
  static const snoozeIndex = 5;

  /// Stable OS notification ID; see `notificationIdFor`.
  final int id;
  final String occurrenceId;

  /// Position in the occurrence's alert list, or [snoozeIndex].
  final int alertIndex;
  final DateTime fireAtUtc;
  final AlertKind kind;
  final String? sound;

  /// Delivered without sound or banner because it falls in quiet hours.
  final bool silent;

  /// Whether iOS should use the time-sensitive interruption level (07 iOS).
  bool get timeSensitive => kind == AlertKind.atStart && !silent;

  @override
  bool operator ==(Object other) =>
      other is PlannedNotification &&
      other.id == id &&
      other.occurrenceId == occurrenceId &&
      other.alertIndex == alertIndex &&
      other.fireAtUtc == fireAtUtc &&
      other.kind == kind &&
      other.sound == sound &&
      other.silent == silent;

  @override
  int get hashCode => Object.hash(
        id,
        occurrenceId,
        alertIndex,
        fireAtUtc,
        kind,
        sound,
        silent,
      );

  @override
  String toString() => 'PlannedNotification($id, $occurrenceId#$alertIndex, '
      '$fireAtUtc, ${kind.name}${silent ? ', silent' : ''})';
}

/// What the scheduler must change to turn the OS pending set into the
/// desired set: cancel first, then schedule (docs/02 F6).
final class NotificationDiff {
  const NotificationDiff({required this.schedule, required this.cancel});

  final List<PlannedNotification> schedule;
  final List<int> cancel;

  bool get isEmpty => schedule.isEmpty && cancel.isEmpty;
}
