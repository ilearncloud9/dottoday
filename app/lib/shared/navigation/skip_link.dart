import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "Skip to content" (docs/07 Web "keyboard-first … skip-to-content link",
/// docs/09 M5.7): the first stop on Tab, shown only while it has focus;
/// Enter moves focus past the navigation into the page.
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
  var _shown = false;

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
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
                onFocusChange: (f) => setState(() => _shown = f),
                child: Opacity(
                  opacity: _shown ? 1 : 0,
                  child: FilledButton(
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
        ],
      ),
    );
  }
}
