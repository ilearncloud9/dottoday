import 'package:flutter/widgets.dart';

/// Marks a screen as inside the Workspace frame (M19.2): the frame's
/// toolbar carries the date, ‹ › Today, the views and the Day menu, so
/// Today, Week and Month leave out their own headers there.
class WorkspaceScope extends InheritedWidget {
  const WorkspaceScope({required super.child, super.key});

  /// Whether [context] is inside the Workspace frame.
  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WorkspaceScope>() != null;

  @override
  bool updateShouldNotify(WorkspaceScope oldWidget) => false;
}
