import 'package:flutter/widgets.dart';

/// A panel's heading that takes the keyboard's focus when the panel opens
/// (ED-248 A): a screen reader starts on the title, and the next Tab goes
/// to the panel's first control. Not a Tab stop of its own.
class LandingTitle extends StatelessWidget {
  const LandingTitle({required this.child, this.land = true, super.key});

  /// The heading, already a `Semantics(header: true)` or plain text.
  final Widget child;

  /// Off where the panel is not one focus lands in (the phones' sheet).
  final bool land;

  @override
  Widget build(BuildContext context) {
    final heading = Semantics(header: true, child: child);
    if (!land) return heading;
    return Focus(autofocus: true, skipTraversal: true, child: heading);
  }
}
