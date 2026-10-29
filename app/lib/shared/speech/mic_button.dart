import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// What the mic is doing (docs/10 §3 `MicButton`, docs/09 M14.5).
enum MicState {
  idle,

  /// Listening: the accent dot breathes (still under reduced motion).
  listening,

  /// Asking for permission or starting: shown, not tappable.
  busy,
}

/// The dictation button inside a text box's bottom-end corner (docs/10 §3,
/// ADR-0014): the mic glyph when idle, the Concept A dot while listening.
/// Dumb: [state] in, [onPressed] out. A 48 px target (both floors), a
/// toggle button for screen readers ("Dictate" / "Stop dictation"), Space
/// and Enter from the keyboard, and a haptic tick on start and stop.
class MicButton extends StatelessWidget {
  const MicButton({
    required this.state,
    required this.onPressed,
    this.focusNode,
    super.key,
  });

  final MicState state;
  final VoidCallback onPressed;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final listening = state == MicState.listening;
    final label = listening ? l10n.micStop : l10n.micDictate;
    return Semantics(
      button: true,
      toggled: listening,
      label: label,
      excludeSemantics: true,
      onTap: state == MicState.busy ? null : onPressed,
      child: IconButton(
        focusNode: focusNode,
        tooltip: label,
        onPressed: state == MicState.busy
            ? null
            : () {
                // A tick as listening starts or stops (M14.5).
                HapticFeedback.selectionClick().ignore();
                onPressed();
              },
        constraints: const BoxConstraints.tightFor(
          width: DotTouch.android,
          height: DotTouch.android,
        ),
        icon: switch (state) {
          MicState.listening => const _ListeningDot(),
          MicState.idle => DotIcon(DotGlyphs.mic, color: t.colors.accentInk),
          MicState.busy => DotIcon(DotGlyphs.mic, color: t.colors.muted),
        },
      ),
    );
  }
}

/// The accent dot, breathing once per [DotMotion.pulse].
class _ListeningDot extends StatefulWidget {
  const _ListeningDot();

  @override
  State<_ListeningDot> createState() => _ListeningDotState();
}

class _ListeningDotState extends State<_ListeningDot>
    with SingleTickerProviderStateMixin {
  // Leaf animation state (CLAUDE.md §4).
  late final AnimationController _breath = AnimationController(vsync: this);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pulse = DotTheme.of(context).motion.pulse;
    if (pulse == Duration.zero) {
      _breath
        ..stop()
        ..value = 1;
    } else if (_breath.duration != pulse || !_breath.isAnimating) {
      _breath
        ..duration = pulse
        ..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return SizedBox.square(
      dimension: DotSize.navIcon,
      child: Center(
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1).animate(_breath),
          child: Container(
            width: DotSize.micDot,
            height: DotSize.micDot,
            decoration: BoxDecoration(
              color: t.colors.accent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
