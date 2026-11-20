import 'package:dottoday/core/theme/colour_math.dart';
import 'package:dottoday/data/look/colour_sampler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Mac's sampler and panel (macos/Runner/ColourSamplerBridge.swift)
/// and iOS's system colour picker (ios/Runner/ColourPickerBridge.swift);
/// Android offers none (the sliders and hex instead).
ColourSampler platformColourSampler() => const _ChannelSampler();

const _channel = MethodChannel('dottoday/colour_sampler');

final class _ChannelSampler implements ColourSampler {
  const _ChannelSampler();

  bool get _mac => defaultTargetPlatform == TargetPlatform.macOS;
  bool get _ios => defaultTargetPlatform == TargetPlatform.iOS;

  @override
  bool get hasSystemPicker => _ios;

  @override
  Future<Color?> pickSystem(Color start) async {
    if (!_ios) return null;
    try {
      final hex = await _channel.invokeMethod<String>('system', hexOf(start));
      return hex == null ? null : parseHex(hex);
    } on MissingPluginException {
      return null;
    }
  }

  @override
  bool get canSample => _mac;

  @override
  bool get hasPanel => _mac;

  @override
  Future<Color?> sample() async {
    if (!_mac) return null;
    final hex = await _channel.invokeMethod<String>('sample');
    return hex == null ? null : parseHex(hex);
  }

  @override
  Future<void> openPanel(Color start, void Function(Color) onColour) async {
    if (!_mac) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'panel') return;
      if (parseHex(call.arguments as String) case final c?) onColour(c);
    });
    await _channel.invokeMethod<void>('openPanel', hexOf(start));
  }

  @override
  Future<void> closePanel() async {
    if (!_mac) return;
    _channel.setMethodCallHandler(null);
    await _channel.invokeMethod<void>('closePanel');
  }
}
