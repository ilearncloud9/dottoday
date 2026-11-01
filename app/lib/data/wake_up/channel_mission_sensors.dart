import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/wake_up/mission_progress.dart';
import 'package:dottoday/domain/wake_up/mission_sensors.dart';
import 'package:flutter/services.dart';

/// [MissionSensors] over the in-house bridge (docs/15 §8; owner,
/// 2026-11-01): `dottoday/mission` answers support, permission and
/// driving; `dottoday/mission/readings` streams one sensor while listened
/// to (Android `MissionSensors.kt`, iPhone `MissionSensors.swift`). A
/// missing handler (macOS, the web, tests) reads as no sensors, so only
/// the on-screen missions run there.
final class ChannelMissionSensors implements MissionSensors {
  const ChannelMissionSensors({
    MethodChannel channel = const MethodChannel('dottoday/mission'),
    EventChannel readingsChannel = const EventChannel(
      'dottoday/mission/readings',
    ),
  }) : _channel = channel,
       _readings = readingsChannel;

  final MethodChannel _channel;
  final EventChannel _readings;

  @override
  Future<MissionSupport> support(MissionKind kind) async {
    if (!_sensor(kind)) return MissionSupport.ready;
    try {
      final name = await _channel.invokeMethod<String>('support', {
        'kind': _bridgeKind(kind),
      });
      return MissionSupport.values.asNameMap()[name] ?? MissionSupport.missing;
    } on MissingPluginException {
      return MissionSupport.missing;
    }
  }

  @override
  Future<bool> request(MissionKind kind) async {
    if (!_sensor(kind)) return true;
    try {
      return await _channel.invokeMethod<bool>('request', {
            'kind': _bridgeKind(kind),
          }) ??
          false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Stream<SensorReading> readings(MissionKind kind) {
    if (!_sensor(kind)) return const Stream.empty();
    return _readings
        .receiveBroadcastStream({'kind': _bridgeKind(kind)})
        .map(_reading)
        .where((r) => r != null)
        .cast<SensorReading>();
  }

  @override
  Future<bool> driving() async {
    try {
      return await _channel.invokeMethod<bool>('driving') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Stand up reads motion too, but every phone has it (15 §8): the bridge
  /// still answers, so a tablet without a gyroscope says so.
  static bool _sensor(MissionKind kind) =>
      kind.usesSensor || kind == MissionKind.standUp;

  static String _bridgeKind(MissionKind kind) => switch (kind) {
    MissionKind.walk => 'steps',
    MissionKind.light => 'light',
    _ => 'motion',
  };

  /// `{t: ms since start, steps | lux | brightness | upright + moving}`.
  static SensorReading? _reading(Object? raw) {
    if (raw is! Map) return null;
    final t = raw['t'];
    if (t is! num) return null;
    final at = Duration(milliseconds: t.round());
    return switch (raw) {
      {'steps': final num steps} => StepsReading(at, steps.toInt()),
      {'lux': final num lux} => LuxReading(at, lux.toDouble()),
      {'brightness': final num b} => BrightnessReading(at, b.toDouble()),
      {'upright': final num up, 'moving': final num moving} => MotionReading(
        at,
        upright: up.toDouble(),
        moving: moving.toDouble(),
      ),
      _ => null,
    };
  }
}
