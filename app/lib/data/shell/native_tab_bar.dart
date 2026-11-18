import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/native_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'native_tab_bar.g.dart';

/// The iPhone's native row (ED-128 N3) when this is an iPhone that has
/// it; null elsewhere, in tests and if the native side is missing, and
/// the shell keeps its Flutter bar.
@Riverpod(keepAlive: true)
Future<NativeBar?> nativeBar(Ref ref) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return null;
  final bar = ChannelNativeBar();
  try {
    final available = await bar._channel.invokeMethod<bool>('available');
    return available ?? false ? bar : null;
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}

/// [NativeBar] over `dottoday/native_tab_bar` (`NativeTabBar.swift`).
final class ChannelNativeBar implements NativeBar {
  ChannelNativeBar() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'select':
          _events.add(NativeBarSelect(call.arguments as int));
        case 'add':
          _events.add(const NativeBarAdd());
      }
    });
  }

  final _channel = const MethodChannel('dottoday/native_tab_bar');
  final _events = StreamController<NativeBarEvent>.broadcast();

  @override
  Stream<NativeBarEvent> get events => _events.stream;

  @override
  Future<void> configure(ShellBar bar) => _channel.invokeMethod('configure', {
    'items': [
      for (final d in bar.items)
        {
          'label': d.label,
          'semanticLabel': d.semanticLabel,
          'symbol': _symbol(d.glyph, selected: false),
          'selectedSymbol': _symbol(d.glyph, selected: true),
          'badge': d.badge ?? 0,
        },
    ],
    'selected': bar.selected,
    'addLabel': bar.addLabel,
    'showAdd': bar.onAdd != null,
  });

  @override
  Future<void> setVisible({required bool visible}) =>
      _channel.invokeMethod('visible', visible);

  @override
  Future<void> remove() => _channel.invokeMethod('remove');

  /// SF Symbols in native chrome (ED-260, CR-014); Today keeps the app's
  /// own dot, drawn natively as "dot".
  static String _symbol(DotGlyph glyph, {required bool selected}) {
    if (glyph == DotGlyphs.today) return 'dot';
    if (glyph == DotGlyphs.inbox) return selected ? 'tray.fill' : 'tray';
    if (glyph == DotGlyphs.search) return 'magnifyingglass';
    if (glyph == DotGlyphs.settings) {
      return selected ? 'gearshape.fill' : 'gearshape';
    }
    if (glyph == DotGlyphs.week) return 'calendar';
    return 'circle';
  }
}
