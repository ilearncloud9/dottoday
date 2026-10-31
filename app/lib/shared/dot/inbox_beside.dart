import 'package:flutter/widgets.dart';

/// Marks a subtree drawn beside the Inbox sidebar (M3e.2): free gaps there
/// say "drop an inbox task here", since dragging from the sidebar is how a
/// wide screen plans. Without it (phones, and the minimal layout at any
/// width, docs/14 §3) they say "add here".
class InboxBeside extends InheritedWidget {
  const InboxBeside({required super.child, super.key});

  /// Whether [context] is beside the Inbox sidebar.
  static bool of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<InboxBeside>() != null;

  @override
  bool updateShouldNotify(InboxBeside oldWidget) => false;
}
