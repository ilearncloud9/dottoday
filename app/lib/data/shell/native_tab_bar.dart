import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/native_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'native_tab_bar.g.dart';

/// The native navigation when this device has one: the iPhone's row
/// (ED-128 N3) or the iPad's tabs and sidebar (iPadOS 18+); null
/// elsewhere, in tests and if the native side is missing, and the shell
/// keeps its Flutter bars.
@Riverpod(keepAlive: true)
Future<NativeBar?> nativeBar(Ref ref) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return null;
  try {
    final kind = await _channel.invokeMethod<String>('available');
    return switch (kind) {
      'phone' => ChannelNativeBar(NativeBarKind.phone),
      'pad' => ChannelNativeBar(NativeBarKind.pad),
      _ => null,
    };
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}

const _channel = MethodChannel('dottoday/native_tab_bar');

/// [NativeBar] over `dottoday/native_tab_bar` (`NativeTabBar.swift`,
/// `NativeIPadTabs.swift`).
final class ChannelNativeBar implements NativeBar {
  ChannelNativeBar(this.kind) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'select':
          _events.add(NativeBarSelect(call.arguments as int));
        case 'add':
          _events.add(const NativeBarAdd());
      }
    });
  }

  @override
  final NativeBarKind kind;

  final _events = StreamController<NativeBarEvent>.broadcast();

  @override
  Stream<NativeBarEvent> get events => _events.stream;

  @override
  Future<void> configure(ShellBar bar) => _channel.invokeMethod('configure', {
    'items': [
      for (final d in bar.items)
        {
          // Stable across languages: the place's symbol.
          'id': _symbol(d.glyph, selected: false),
          'label': d.label,
          'semanticLabel': d.semanticLabel,
          'symbol': _symbol(d.glyph, selected: false),
          'selectedSymbol': _symbol(d.glyph, selected: true),
          'badge': d.badge ?? 0,
          // Settings: the iPad sidebar only, never a tab (ED-265).
          'foot': d.foot,
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
    if (glyph == DotGlyphs.week || glyph == DotGlyphs.calendar) {
      return 'calendar';
    }
    if (glyph == DotGlyphs.now) {
      return selected
          ? 'smallcircle.filled.circle.fill'
          : 'smallcircle.filled.circle';
    }
    return 'circle';
  }
}
