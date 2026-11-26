import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The step's main pill (prototype `.pbtn`): 56 high, the accent, 17/800;
/// it presses in to .97 and is at .38 while off.
class OnbPrimary extends StatelessWidget {
  const OnbPrimary({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return _Press(
      enabled: onPressed != null,
      child: FilledButton(
        onPressed: onPressed,
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
        foregroundColor: t.colors.accentInk,
        textStyle: t.styles.onbSecondary,
        minimumSize: const Size.fromHeight(OnbSize.secondary),
        shape: const StadiumBorder(),
      ),
      child: Text(label),
    );
  }
}

/// `.pbtn:active{transform:scale(.97)}` over .12 s; the prototype keeps
/// it under Reduce Motion too.
class _Press extends StatefulWidget {
  const _Press({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  State<_Press> createState() => _PressState();
}

/// A leaf: only whether it is held.
class _PressState extends State<_Press> {
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
        scale: _down ? OnbMotion.pressScale : 1,
        duration: OnbMotion.press,
        child: widget.child,
      ),
    );
  }
}
