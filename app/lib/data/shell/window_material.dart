import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'window_material.g.dart';

const _channel = MethodChannel('dottoday/window_material');

/// Whether the Mac app's sidebar shows the system's vibrant material
/// (ED-130): false with Reduce Transparency or Increase Contrast on, on
/// every other target, in tests and if the native side is missing, and the
/// sidebar is painted solid then (macos/Runner `WindowMaterialBridge.swift`).
@Riverpod(keepAlive: true)
Stream<bool> sidebarVibrancy(Ref ref) async* {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.macOS) {
    yield false;
    return;
  }
  final changes = StreamController<bool>();
  ref.onDispose(changes.close);
  _channel.setMethodCallHandler((call) async {
    if (call.method == 'changed') changes.add(call.arguments as bool);
  });
  try {
    yield await _channel.invokeMethod<bool>('vibrant') ?? false;
  } on MissingPluginException {
    yield false;
    return;
  } on PlatformException {
    yield false;
    return;
  }
  yield* changes.stream;
}

/// Gives the Mac window the app's theme, so the material and the title bar
/// match a theme chosen in Settings, not only the system's (ED-176).
Future<void> setWindowAppearance(Brightness brightness) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.macOS) return;
  try {
    await _channel.invokeMethod<void>('appearance', brightness.name);
  } on MissingPluginException {
    return;
  } on PlatformException {
    return;
  }
}
