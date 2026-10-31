import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "Skip to content" (docs/07 Web "keyboard-first … skip-to-content link",
/// docs/09 M5.7): the first stop on Tab, shown only while it has focus;
/// Enter moves focus past the navigation into the page.
///
/// A screen may hold focus on a key catcher at load (Today's and Week's
/// arrow keys: a `Focus(autofocus: true, skipTraversal: true)`), so Tab would
/// start after it, inside the page. Until the link has had focus once, a Tab
/// from such a node goes to the link: a catcher is not a stop the person
/// chose. After that Tab walks on as usual, so the link never traps focus
/// (found in M8.7, 08 §6.2).
///
/// [builder] gets the node to put around the page.
class SkipLink extends StatefulWidget {
  const SkipLink({required this.label, required this.builder, super.key});

  final String label;
  final Widget Function(FocusNode content) builder;

  @override
  State<SkipLink> createState() => _SkipLinkState();
}

/// A leaf: only whether the link has focus.
class _SkipLinkState extends State<SkipLink> {
  final _content = FocusNode(skipTraversal: true);
  final _link = FocusNode();
  var _shown = false;

  /// Whether the link has had focus since this shell was built.
  var _offered = false;

  @override
  void dispose() {
    _content.dispose();
    _link.dispose();
    super.dispose();
  }

  /// The first Tab from a key catcher (a focused node that is no Tab stop)
  /// lands on the link instead of the stop after the catcher.
  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (_offered ||
        event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.tab ||
        HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    final focused = FocusManager.instance.primaryFocus;
    if (focused == null || focused == _content || !focused.skipTraversal) {
      return KeyEventResult.ignored;
    }
    _link.requestFocus();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onKeyEvent: _onKey,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Stack(
          children: [
            FocusTraversalOrder(
              order: const NumericFocusOrder(1),
              child: widget.builder(_content),
            ),
            PositionedDirectional(
              top: DotSpace.s,
              start: DotSpace.s,
              child: FocusTraversalOrder(
                order: const NumericFocusOrder(0),
                child: Focus(
                  skipTraversal: true,
                  onFocusChange: (f) => setState(() {
                    _shown = f;
                    _offered = _offered || f;
                  }),
                  // Unseen, it takes no clicks: the rail's add button sits
                  // under it (found by the M16 web sweep). Keyboard focus,
                  // which shows it, is unaffected.
                  child: IgnorePointer(
                    ignoring: !_shown,
                    child: Opacity(
                      opacity: _shown ? 1 : 0,
                      child: FilledButton(
                        focusNode: _link,
                        onPressed: () {
                          _content.requestFocus();
                          // On into the page's first stop.
                          _content.nextFocus();
                        },
                        child: Text(widget.label),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
