import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/focus/deep_work.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// [DeepWorkGateway] for this build (docs/09 M10.5): `dottoday/deep_work`
/// on Android (`focus/DeepWork.kt`), the Shortcuts explanation on iPhone
/// and Mac, nothing the browser could do on the web. Chosen by platform
/// behaviour, never for layout.
final class ChannelDeepWork implements DeepWorkGateway {
  ChannelDeepWork(
    this._links, {
    MethodChannel channel = const MethodChannel('dottoday/deep_work'),
    DeepWorkKind? kind,
  }) : _channel = channel,
       _kind = kind ?? _platformKind();

  final LinkLauncher _links;
  final MethodChannel _channel;
  final DeepWorkKind _kind;

  /// Opens the Shortcuts app on iPhone and Mac.
  static final shortcuts = Uri.parse('shortcuts://');

  static DeepWorkKind _platformKind() {
    if (kIsWeb) return DeepWorkKind.none;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => DeepWorkKind.dnd,
      TargetPlatform.iOS || TargetPlatform.macOS => DeepWorkKind.shortcuts,
      _ => DeepWorkKind.none,
    };
  }

  @override
  Future<DeepWorkStatus> status() async {
    if (_kind != DeepWorkKind.dnd) return DeepWorkStatus(kind: _kind);
    try {
      final s = await _channel.invokeMapMethod<String, Object?>('status');
      return DeepWorkStatus(
        kind: _kind,
        granted: s?['granted'] == true,
        on: s?['on'] == true,
      );
    } on MissingPluginException {
      return DeepWorkStatus(kind: _kind);
    }
  }

  @override
  Future<bool> turnOn(DateTime untilUtc) async {
    if (_kind != DeepWorkKind.dnd) return false;
    final ok = await _channel.invokeMethod<bool>('turnOn', {
      'level': deepWorkDndLevel,
      'until_ms': untilUtc.millisecondsSinceEpoch,
    });
    return ok ?? false;
  }

  @override
  Future<void> turnOff() async {
    if (_kind != DeepWorkKind.dnd) return;
    await _channel.invokeMethod<void>('turnOff');
  }

  @override
  Future<void> openSettings() => switch (_kind) {
    DeepWorkKind.dnd => _channel.invokeMethod<void>('openAccess'),
    DeepWorkKind.shortcuts => _links.open(shortcuts),
    DeepWorkKind.none => Future<void>.value(),
  };
}
