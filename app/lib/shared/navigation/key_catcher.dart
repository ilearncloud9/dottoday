import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A page's key catcher (Today's and Week's keys): it holds focus at load
/// so the page's keys work, with no Tab stop and nothing for screen
/// readers. The first Tab from it goes to Skip to content ([SkipLink]).
///
/// When Tab comes back into the page later, Flutter returns to the node
/// the page last had, this catcher, which skipped the toolbar and the
/// Plan panel (ED-248, E-G4-7-States D2). So focus arriving here by
/// traversal moves on to the page's first stop (its last with Shift).
class KeyCatcher extends StatefulWidget {
  const KeyCatcher({required this.child, this.autofocus = true, super.key});

  final Widget child;
  final bool autofocus;

  @override
  State<KeyCatcher> createState() => _KeyCatcherState();
}

/// A leaf: the catcher's node.
class _KeyCatcherState extends State<KeyCatcher> {
  final _node = FocusNode();

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  void _arrived(bool on) {
    // Autofocus at load and a click keep it; only Tab's re-entry passes on.
    // Only the catcher itself: a block inside it taking focus is not it.
    if (!on ||
        !_node.hasPrimaryFocus ||
        FocusManager.instance.highlightMode != FocusHighlightMode.traditional ||
        !HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.tab,
        )) {
      return;
    }
    final scope = _node.nearestScope;
    if (scope == null) return;
    final policy = FocusTraversalGroup.of(context);
    final back = HardwareKeyboard.instance.isShiftPressed;
    final stop = back
        ? policy.findLastFocus(scope, ignoreCurrentFocus: true)
        : policy.findFirstFocus(scope, ignoreCurrentFocus: true);
    if (stop != null && stop != _node) stop.requestFocus();
  }

  @override
  Widget build(BuildContext context) => Focus(
    focusNode: _node,
    autofocus: widget.autofocus,
    skipTraversal: true,
    includeSemantics: false,
    onFocusChange: _arrived,
    child: widget.child,
  );
}
