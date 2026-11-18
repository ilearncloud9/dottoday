import 'dart:async';

import 'package:dottoday/data/shell/window_material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Mac window's chrome around every route; nothing elsewhere.
///
/// - Keeps the window's light or dark appearance on the app's theme, so
///   the sidebar's material and the window buttons follow a theme chosen
///   in Settings, not only the system's (ED-130, ED-176).
/// - Adds the transparent title bar's height to the top inset (ED-377):
///   the content runs under it, so the sidebar fills the window's height
///   behind the window buttons, and anything that keeps to the safe area
///   stays out of the strip the system drags the window by.
class MacWindowChrome extends ConsumerStatefulWidget {
  const MacWindowChrome({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<MacWindowChrome> createState() => _MacWindowChromeState();
}

class _MacWindowChromeState extends ConsumerState<MacWindowChrome> {
  Brightness? _sent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (brightness == _sent) return;
    _sent = brightness;
    unawaited(setWindowAppearance(brightness));
  }

  @override
  Widget build(BuildContext context) {
    final titlebar = ref.watch(macTitlebarProvider).value ?? 0;
    if (titlebar <= 0) return widget.child;
    final media = MediaQuery.of(context);
    EdgeInsets lift(EdgeInsets e) => e.copyWith(top: e.top + titlebar);
    return MediaQuery(
      data: media.copyWith(
        padding: lift(media.padding),
        viewPadding: lift(media.viewPadding),
      ),
      child: widget.child,
    );
  }
}
