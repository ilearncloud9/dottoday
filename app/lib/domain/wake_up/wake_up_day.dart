import 'package:freezed_annotation/freezed_annotation.dart';

part 'wake_up_day.freezed.dart';

/// One civil day's morning on this device (docs/15 §3, M17.3): what the
/// Wake Up alarm did and what the card did. Local only, never synced: each
/// phone rings and opens its own card (ADR-0017).
@freezed
abstract class WakeUpDay with _$WakeUpDay {
  const factory WakeUpDay({
    /// `yyyy-MM-dd` in the profile's zone.
    required String date,

    /// When the alarm first rang (Android; AlarmKit doesn't tell the app).
    DateTime? rangAtUtc,

    /// When "I'm up" stopped it.
    DateTime? stoppedAtUtc,
    @Default(0) int snoozes,

    /// When the Wake Up card was shown: it opens once a day (15 §5).
    DateTime? cardShownAtUtc,

    /// "Start the day" with no dot to start yet (15 §5 step 7).
    DateTime? startedAtUtc,

    /// "Can't right now" skipped the mission (15 §8).
    DateTime? missionSkippedAtUtc,
  }) = _WakeUpDay;
}

/// What the alarm reported, drained from the OS side on launch and resume.
/// [mission]: "I'm up" (iOS's Stop) opened a mission the app must show
/// (15 §8); AlarmKit can't open a link itself.
enum AlarmEventKind { rang, snoozed, stopped, mission }

/// One alarm event: [id] is the alarm's (`wakeup:<yyyy-MM-dd>`).
final class AlarmEvent {
  const AlarmEvent(this.id, this.kind, this.atUtc, {this.mission});

  final String id;
  final AlarmEventKind kind;
  final DateTime atUtc;

  /// A [AlarmEventKind.mission] event's `MissionKind` name.
  final String? mission;

  /// The civil day of a Wake Up alarm, or null for the test alarm and a
  /// Wake Up Check's re-ring (`wakeup:<date>:check`).
  String? get date => _dayId.firstMatch(id)?.group(1);

  static final _dayId = RegExp(r'^wakeup:(\d{4}-\d{2}-\d{2})$');

  @override
  bool operator ==(Object other) =>
      other is AlarmEvent &&
      other.id == id &&
      other.kind == kind &&
      other.atUtc == atUtc &&
      other.mission == mission;

  @override
  int get hashCode => Object.hash(id, kind, atUtc, mission);
}

/// [day] after [event]: the first ring counts, each snooze adds one, and
/// "I'm up" is the last stop.
///
/// ```dart
/// applyAlarmEvent(const WakeUpDay(date: '2026-11-02'),
///     AlarmEvent('wakeup:2026-11-02', AlarmEventKind.snoozed, at)).snoozes;
/// // 1
/// ```
WakeUpDay applyAlarmEvent(WakeUpDay day, AlarmEvent event) =>
    switch (event.kind) {
      AlarmEventKind.rang => day.copyWith(
        rangAtUtc: day.rangAtUtc ?? event.atUtc,
      ),
      AlarmEventKind.snoozed => day.copyWith(snoozes: day.snoozes + 1),
      AlarmEventKind.stopped => day.copyWith(stoppedAtUtc: event.atUtc),
      // Not up yet: the mission is (15 §8).
      AlarmEventKind.mission => day,
    };

/// The mission [events] leave open (15 §8): the last one "I'm up" opened
/// that no later stop ended, as `(date, kind)`, or null.
///
/// ```dart
/// openMission([AlarmEvent('wakeup:2026-11-02', AlarmEventKind.mission,
///     at, mission: 'walk')]); // ('2026-11-02', 'walk')
/// ```
(String, String)? openMission(List<AlarmEvent> events) {
  for (final e in events.reversed) {
    if (e.kind == AlarmEventKind.stopped) return null;
    if (e.kind != AlarmEventKind.mission) continue;
    final date = e.date;
    final kind = e.mission;
    return date == null || kind == null ? null : (date, kind);
  }
  return null;
}
