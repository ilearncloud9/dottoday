// The browser's EyeDropper (ED-156: "browser-permitting on web"): only
// Chromium browsers have it, so the button shows only where it exists.
// Hand-written js_interop.
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dottoday/core/theme/colour_math.dart';
import 'package:dottoday/data/look/colour_sampler.dart';
import 'package:flutter/painting.dart';

ColourSampler platformColourSampler() => const _WebSampler();

@JS('EyeDropper')
extension type _EyeDropper._(JSObject _) implements JSObject {
  external factory _EyeDropper();
  external JSPromise<_Result> open();
}

extension type _Result._(JSObject _) implements JSObject {
  external String get sRGBHex;
}

@JS('document')
external _Document get _document;

extension type _Document._(JSObject _) implements JSObject {
  external _Input createElement(String tag);
}

extension type _Input._(JSObject _) implements JSObject {
  external set type(String value);
  external String get value;
  external set value(String value);
  external void addEventListener(String type, JSFunction listener);
  external void click();
}

final class _WebSampler implements ColourSampler {
  const _WebSampler();

  @override
  bool get canSample => globalContext.has('EyeDropper');

  @override
  bool get hasPanel => false;

  @override
  Future<Color?> sample() async {
    if (!canSample) return null;
    try {
      final picked = await _EyeDropper().open().toDart;
      return parseHex(picked.sRGBHex);
    } on Object {
      // Esc or a click away rejects the promise (an AbortError, a JS
      // value rather than a Dart exception): no colour, nothing failed.
      return null;
    }
  }

  @override
  bool get hasSystemPicker => true;

  /// The browser's own colour input, opened from the tap that asked for it.
  @override
  Future<Color?> pickSystem(Color start) {
    final done = Completer<Color?>();
    final input = _document.createElement('input')
      ..type = 'color'
      ..value = hexOf(start).toLowerCase();
    input.addEventListener(
      'change',
      ((JSObject _) {
        if (!done.isCompleted) done.complete(parseHex(input.value));
      }).toJS,
    );
    // Closed without a change: no event says so; a later tap starts anew.
    input.click();
    return done.future;
  }

  @override
  Future<void> openPanel(Color start, void Function(Color) onColour) async {}

  @override
  Future<void> closePanel() async {}
}
