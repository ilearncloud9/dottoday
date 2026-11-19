import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';

/// A repeat picked on Create task's Repeat pill (the Repeat editor's
/// rule, with its end); null [rule] is Never.
typedef RepeatPick = ({RepeatRule? rule});

/// The choices Create task's form adds to a typed title (ED-140, M19.3):
/// Repeat, Alerts, Energy, Notes, and ⋯'s Sound, Travel time and Pinned.
/// All are written with the task in one write; none needs a second save.
///
/// ```dart
/// const AddDetails().copyWith(energy: () => Energy.high).energy; // high
/// ```
final class AddDetails {
  const AddDetails({
    this.repeat,
    this.alerts,
    this.energy,
    this.notes = '',
    this.soundId,
    this.travelMin = 0,
    this.pinned = false,
  });

  /// The picked repeat; null keeps what was typed ("every Monday").
  final RepeatPick? repeat;

  /// The picked alerts; null keeps Settings' default alerts.
  final List<Alert>? alerts;
  final Energy? energy;
  final String notes;

  /// The reminder sound: null the default, `"none"` silent (docs/12 §3).
  final String? soundId;
  final int travelMin;
  final bool pinned;

  /// Notes as stored: blank is none.
  String? get storedNotes => notes.trim().isEmpty ? null : notes.trim();

  AddDetails copyWith({
    RepeatPick? Function()? repeat,
    List<Alert>? Function()? alerts,
    Energy? Function()? energy,
    String? notes,
    String? Function()? soundId,
    int? travelMin,
    bool? pinned,
  }) => AddDetails(
    repeat: repeat == null ? this.repeat : repeat(),
    alerts: alerts == null ? this.alerts : alerts(),
    energy: energy == null ? this.energy : energy(),
    notes: notes ?? this.notes,
    soundId: soundId == null ? this.soundId : soundId(),
    travelMin: travelMin ?? this.travelMin,
    pinned: pinned ?? this.pinned,
  );
}
