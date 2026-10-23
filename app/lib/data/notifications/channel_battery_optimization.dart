import 'package:dottoday/domain/notifications/battery_optimization.dart';
import 'package:flutter/services.dart';

/// [BatteryOptimization] over MainActivity's `dottoday/power` channel
/// (Android). A missing handler reads as "not restricted" so the panel
/// never shows a problem it can't explain.
final class ChannelBatteryOptimization implements BatteryOptimization {
  const ChannelBatteryOptimization([
    this._channel = const MethodChannel('dottoday/power'),
  ]);

  final MethodChannel _channel;

  @override
  Future<bool> restricted() async {
    try {
      return await _channel.invokeMethod<bool>('isRestricted') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> openSettings() => _channel.invokeMethod<void>('openSettings');

  @override
  Future<bool> doNotDisturb() async {
    try {
      return await _channel.invokeMethod<bool>('isDndOn') ?? false;
    } on MissingPluginException {
      return false;
    }
  }
}
