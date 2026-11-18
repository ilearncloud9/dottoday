import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'window_material.g.dart';

const _channel = MethodChannel('dottoday/window_material');

/// What the Mac window sends on its own, one stream per method; one
/// handler for the channel, so neither provider replaces the other's.
final _vibrancyChanges = StreamController<bool>.broadcast();
final _titlebarChanges = StreamController<double>.broadcast();
var _listening = false;

void _listen() {
  if (_listening) return;
  _listening = true;
  _channel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'changed':
        _vibrancyChanges.add(call.arguments as bool);
      case 'titlebar':
        _titlebarChanges.add((call.arguments as num).toDouble());
    }
  });
}

bool get _macApp => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

/// Asks the Mac window; null on other targets, in tests and when the
/// native side is missing.
Future<T?> _ask<T>(String method, [Object? arguments]) async {
  if (!_macApp) return null;
  try {
    return await _channel.invokeMethod<T>(method, arguments);
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}

/// Whether the Mac app's sidebar shows the system's vibrant material
/// (ED-130): false with Reduce Transparency or Increase Contrast on, on
/// every other target, in tests and if the native side is missing, and the
/// sidebar is painted solid then (macos/Runner `WindowMaterialBridge.swift`).
@Riverpod(keepAlive: true)
Stream<bool> sidebarVibrancy(Ref ref) async* {
  final first = await _ask<bool>('vibrant');
  yield first ?? false;
  if (first == null) return;
  _listen();
  yield* _vibrancyChanges.stream;
}

/// The height of the Mac window's transparent title bar, which the content
/// runs under (ED-377): the window buttons sit there and the system drags
/// the window by it, so the app keeps it free of controls. 0 in full
/// screen, on other targets and without the native side.
@Riverpod(keepAlive: true)
Stream<double> macTitlebar(Ref ref) async* {
  final first = await _ask<num>('titlebar');
  yield first?.toDouble() ?? 0;
  if (first == null) return;
  _listen();
  yield* _titlebarChanges.stream;
}

/// Gives the Mac window the app's theme, so the material and the title bar
/// match a theme chosen in Settings, not only the system's (ED-176).
Future<void> setWindowAppearance(Brightness brightness) =>
    _ask<void>('appearance', brightness.name);
