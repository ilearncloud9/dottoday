import 'dart:async';

import 'package:dottoday/data/layout/reduce_transparency_stub.dart'
    if (dart.library.js_interop) 'package:dottoday/data/layout/reduce_transparency_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reduce_transparency.g.dart';

const _channel = MethodChannel('dottoday/reduce_transparency');

/// Whether the system's Reduce Transparency is on (ED-248 C), which
/// Flutter does not report: asked of iOS and macOS
/// (`ReduceTransparencyBridge.swift`) and of the browser; false on Android
/// (it has no such setting; its blur switch is `frostedChrome`), in tests
/// and when the native side is missing.
@Riverpod(keepAlive: true)
Stream<bool> reduceTransparency(Ref ref) async* {
  final browser = browserReducedTransparency();
  if (browser != null) {
    yield* browser;
    return;
  }
  final native = switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.macOS => true,
    _ => false,
  };
  final first = native ? await _ask() : null;
  yield first ?? false;
  if (first == null) return;
  final changes = StreamController<bool>();
  _channel.setMethodCallHandler((call) async {
    if (call.method == 'changed') changes.add(call.arguments as bool);
  });
  ref.onDispose(() {
    _channel.setMethodCallHandler(null);
    unawaited(changes.close());
  });
  yield* changes.stream;
}

Future<bool?> _ask() async {
  try {
    return await _channel.invokeMethod<bool>('get');
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}
