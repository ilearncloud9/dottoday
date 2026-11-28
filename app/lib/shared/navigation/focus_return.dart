import 'package:flutter/widgets.dart';

/// Gives focus back to what opened a panel when the panel closes (ED-248
/// A, E-G4-7-States D2): the Day column's task and review, the
/// Workspace's inspector and Plan panel. Without it, closing dropped
/// focus and the next Tab started from the top of the window.
///
/// ```dart
/// final back = FocusReturn();
/// ref.listen(editingTaskProvider, (a, b) => back.track(a != null, b != null));
/// ```
final class FocusReturn {
  FocusNode? _opener;

  /// Call on every change of whether the panel is open.
  void track(bool wasOpen, bool isOpen) {
    if (!wasOpen && isOpen) _opener = FocusManager.instance.primaryFocus;
    if (wasOpen && !isOpen) _giveBack();
  }

  /// After the frame that removes the panel; skipped when the opener has
  /// gone with it (a row inside a closed panel).
  void _giveBack() {
    final node = _opener;
    _opener = null;
    if (node == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!(node.context?.mounted ?? false) || !node.canRequestFocus) return;
      node.requestFocus();
    });
  }
}
