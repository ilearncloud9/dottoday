import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/wake_up/mission_progress.dart';

/// Whether this device can run a mission now (docs/15 §8 rule 3).
enum MissionSupport {
  ready,

  /// The permission was never asked (Walk's motion, Light's camera on
  /// iPhone); Settings asks when the mission is picked, never while ringing.
  needsPermission,
  denied,

  /// No such sensor on this device.
  missing,
}

/// The sensors the missions read (15 §8), through the in-house bridge
/// (`MissionSensors.kt`, `MissionSensors.swift`; owner, 2026-11-01). Data
/// is read only while a mission screen listens and never stored.
abstract interface class MissionSensors {
  /// Whether [kind] can run here; the on-screen missions always can.
  Future<MissionSupport> support(MissionKind kind);

  /// Asks for [kind]'s permission once; true when it is now [MissionSupport.ready].
  Future<bool> request(MissionKind kind);

  /// [kind]'s readings until the listener cancels.
  Stream<SensorReading> readings(MissionKind kind);

  /// CarPlay or Android Auto is connected: missions step aside (rule 3).
  Future<bool> driving();
}
