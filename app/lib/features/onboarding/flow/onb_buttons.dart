import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The step's main pill (prototype `.pbtn`): 56 high, the accent, 17/800;
/// it presses in to .97 and is at .38 while off.
class OnbPrimary extends StatelessWidget {
  const OnbPrimary({
    required this.label,
    required this.onPressed,
    this.focusNode,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  /// For a step that moves focus to it (the nudge's Allow nudges).
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return OnbPress(
      enabled: onPressed != null,
      child: FilledButton(
        onPressed: onPressed,
        focusNode: focusNode,
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          disabledBackgroundColor: c.accent.withValues(
            alpha: OnbMotion.offOpacity,
          ),
          disabledForegroundColor: c.onAccent.withValues(
            alpha: OnbMotion.offOpacity,
          ),
          textStyle: t.styles.onbPrimary,
          minimumSize: const Size.fromHeight(OnbSize.primary),
          shape: const StadiumBorder(),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Its text button (prototype `.tbtn`): 50 high, the accent's ink, 17/700.
class OnbSecondary extends StatelessWidget {
  const OnbSecondary({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: t.colors.accentText,
        textStyle: t.styles.onbSecondary,
        minimumSize: const Size.fromHeight(OnbSize.secondary),
        shape: const StadiumBorder(),
      ),
      child: Text(label),
    );
  }
}

/// Pressed in while held: `.pbtn:active{transform:scale(.97)}` over .12 s
/// by default (a chip: .95 over .15 s); the prototype keeps it under
/// Reduce Motion too.
class OnbPress extends StatefulWidget {
  const OnbPress({
    required this.enabled,
    required this.child,
    this.scale = OnbMotion.pressScale,
    this.duration = OnbMotion.press,
    super.key,
  });

  final bool enabled;
  final Widget child;
  final double scale;
  final Duration duration;

  @override
  State<OnbPress> createState() => _OnbPressState();
}

/// A leaf: only whether it is held.
class _OnbPressState extends State<OnbPress> {
  var _down = false;

  void _set(bool down) {
    if (widget.enabled && _down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: widget.duration,
        child: widget.child,
      ),
    );
  }
}
