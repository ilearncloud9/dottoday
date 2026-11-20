import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom colour…'s field (E-G3-9b "Mac · Colour popover", ED-156):
/// saturation across, brightness up, at [value]'s hue. Click or drag
/// picks; the arrow keys step it (←→ saturation, ↑↓ brightness), and a
/// screen reader hears the hex and steps brightness.
class ColourField extends StatefulWidget {
  const ColourField({required this.value, required this.onChanged, super.key});

  final HSVColor value;
  final ValueChanged<HSVColor> onChanged;

  @override
  State<ColourField> createState() => _ColourFieldState();
}

/// A leaf: its focus, for the arrow keys.
class _ColourFieldState extends State<ColourField> {
  static const _step = 0.02;
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _set({double? s, double? v}) => widget.onChanged(
    widget.value
        .withSaturation((s ?? widget.value.saturation).clamp(0, 1))
        .withValue((v ?? widget.value.value).clamp(0, 1)),
  );

  void _at(Offset p, Size size) =>
      _set(s: p.dx / size.width, v: 1 - p.dy / size.height);

  KeyEventResult _key(KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final c = widget.value;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowRight) _set(s: c.saturation + _step);
    if (k == LogicalKeyboardKey.arrowLeft) _set(s: c.saturation - _step);
    if (k == LogicalKeyboardKey.arrowUp) _set(v: c.value + _step);
    if (k == LogicalKeyboardKey.arrowDown) _set(v: c.value - _step);
    final arrows = {
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
    };
    return arrows.contains(k) ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  String _hex(double v) =>
      hexOf(widget.value.withValue(v.clamp(0, 1)).toColor());

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = widget.value;
    return Focus(
      focusNode: _focus,
      onFocusChange: (_) => setState(() {}),
      onKeyEvent: (_, e) => _key(e),
      child: Semantics(
        slider: true,
        label: context.l10n.lookFieldLabel,
        value: _hex(c.value),
        increasedValue: _hex(c.value + _step),
        decreasedValue: _hex(c.value - _step),
        onIncrease: () => _set(v: c.value + _step),
        onDecrease: () => _set(v: c.value - _step),
        child: LayoutBuilder(
          builder: (context, box) {
            final size = Size(box.maxWidth, DotLook.field);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: (d) {
                _focus.requestFocus();
                _at(d.localPosition, size);
              },
              onPanUpdate: (d) => _at(d.localPosition, size),
              child: CustomPaint(
                size: size,
                painter: _FieldPainter(
                  value: c,
                  edge: t.colors.hairline,
                  ring: DotPrimitives.white,
                  halo: _focus.hasFocus ? t.colors.accent : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FieldPainter extends CustomPainter {
  const _FieldPainter({
    required this.value,
    required this.edge,
    required this.ring,
    required this.halo,
  });

  final HSVColor value;
  final Color edge;
  final Color ring;
  final Color? halo;

  @override
  void paint(Canvas canvas, Size size) {
    final box = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(DotLook.fieldRadius),
    );
    final pure = HSVColor.fromAHSV(1, value.hue, 1, 1).toColor();
    final white = HSVColor.fromAHSV(1, value.hue, 0, 1).toColor();
    final black = HSVColor.fromAHSV(1, value.hue, 0, 0).toColor();
    canvas
      ..drawRRect(
        box,
        Paint()
          ..shader = LinearGradient(
            colors: [white, pure],
          ).createShader(box.outerRect),
      )
      ..drawRRect(
        box,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [black.withValues(alpha: 0), black],
          ).createShader(box.outerRect),
      )
      ..drawRRect(
        box,
        Paint()
          ..color = halo ?? edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = halo == null ? DotSpace.hairline : DotLook.outline,
      );
    final at = Offset(
      value.saturation * size.width,
      (1 - value.value) * size.height,
    );
    const r = DotLook.fieldThumb / 2;
    canvas
      ..drawCircle(
        at,
        r,
        Paint()
          ..color = ring
          ..style = PaintingStyle.stroke
          ..strokeWidth = DotLook.outline * 2,
      )
      ..drawCircle(
        at,
        r + DotLook.outline,
        Paint()
          ..color = edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = DotSpace.hairline,
      );
  }

  @override
  bool shouldRepaint(_FieldPainter old) =>
      old.value != value || old.halo != halo || old.edge != edge;
}
