import 'package:dottoday/core/theme/colour_math.dart';
import 'package:dottoday/data/look/colour_sampler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Mac's sampler and panel (macos/Runner/ColourSamplerBridge.swift);
/// iOS and Android offer neither (the phones' sliders and hex instead).
ColourSampler platformColourSampler() => const _ChannelSampler();

const _channel = MethodChannel('dottoday/colour_sampler');

final class _ChannelSampler implements ColourSampler {
  const _ChannelSampler();

  bool get _mac => defaultTargetPlatform == TargetPlatform.macOS;

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
