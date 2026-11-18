import 'dart:async';

import 'package:dottoday/data/shell/window_material.dart';
import 'package:flutter/material.dart';

/// Keeps the Mac window's light or dark appearance on the app's theme, so
/// the sidebar's material and the title bar follow a theme chosen in
/// Settings, not only the system's (ED-130, ED-176). Nothing elsewhere.
class WindowAppearance extends StatefulWidget {
  const WindowAppearance({required this.child, super.key});

  final Widget child;

  @override
  State<WindowAppearance> createState() => _WindowAppearanceState();
}

class _WindowAppearanceState extends State<WindowAppearance> {
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
  Widget build(BuildContext context) => widget.child;
}
