import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// All colours' Colour and Shade (E-Phones-3, ED-156): a 28 pt track drawn
/// as [colours], a 24 pt thumb in [thumb] with a white ring. Drag or tap
/// sets [value] (0–1); arrow keys and a screen reader step it by [step],
/// hearing [valueText] of each value.
class GradientSlider extends StatefulWidget {
  const GradientSlider({
    required this.label,
    required this.colours,
    required this.value,
    required this.thumb,
    required this.valueText,
    required this.onChanged,
    this.step = 0.02,
    super.key,
  });

  final String label;
  final List<Color> colours;
  final double value;
  final Color thumb;
  final String Function(double value) valueText;
  final ValueChanged<double> onChanged;
  final double step;

  @override
  State<GradientSlider> createState() => _GradientSliderState();
}

/// A leaf: its focus, for the arrow keys.
class _GradientSliderState extends State<GradientSlider> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _set(double v) => widget.onChanged(v.clamp(0, 1));

  void _at(double dx, double width, bool rtl) {
    const r = DotLook.thumb / 2;
    final p = ((dx - r) / (width - 2 * r)).clamp(0.0, 1.0);
    _set(rtl ? 1 - p : p);
  }

  KeyEventResult _key(KeyEvent e, bool rtl) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final up = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final down = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    if (e.logicalKey == up) _set(widget.value + widget.step);
    if (e.logicalKey == down) _set(widget.value - widget.step);
    final handled = e.logicalKey == up || e.logicalKey == down;
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Focus(
      focusNode: _focus,
      onFocusChange: (_) => setState(() {}),
      onKeyEvent: (_, e) => _key(e, rtl),
      child: Semantics(
        slider: true,
        label: widget.label,
        value: widget.valueText(widget.value),
        increasedValue: widget.valueText(
          (widget.value + widget.step).clamp(0, 1),
        ),
        decreasedValue: widget.valueText(
          (widget.value - widget.step).clamp(0, 1),
        ),
        onIncrease: () => _set(widget.value + widget.step),
        onDecrease: () => _set(widget.value - widget.step),
        child: LayoutBuilder(
          builder: (context, box) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) {
              _focus.requestFocus();
              _at(d.localPosition.dx, box.maxWidth, rtl);
            },
            onHorizontalDragUpdate: (d) =>
                _at(d.localPosition.dx, box.maxWidth, rtl),
            // 44 pt to touch; the track is drawn 28 high.
            child: SizedBox(
              height: DotTouch.min,
              width: box.maxWidth,
              child: CustomPaint(
                painter: _TrackPainter(
                  colours: rtl
                      ? widget.colours.reversed.toList()
                      : widget.colours,
                  value: rtl ? 1 - widget.value : widget.value,
                  thumb: widget.thumb,
                  ring: DotPrimitives.white,
                  edge: t.colors.hairline,
                  halo: _focus.hasFocus ? t.colors.accentTint : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  const _TrackPainter({
    required this.colours,
    required this.value,
    required this.thumb,
    required this.ring,
    required this.edge,
    required this.halo,
  });

  final List<Color> colours;
  final double value;
  final Color thumb;
  final Color ring;
  final Color edge;
  final Color? halo;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, y - DotLook.track / 2, size.width, DotLook.track),
      const Radius.circular(DotLook.track / 2),
    );
    canvas
      ..drawRRect(
        track,
        Paint()
          ..shader = LinearGradient(
            colors: colours,
          ).createShader(track.outerRect),
      )
      ..drawRRect(
        track,
        Paint()
          ..color = edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = DotSpace.hairline,
      );
    const r = DotLook.thumb / 2;
    final c = Offset(r + value * (size.width - 2 * r), y);
    if (halo case final h?) {
      canvas.drawCircle(c, r + DotLook.thumbRing * 2, Paint()..color = h);
    }
    canvas
      ..drawCircle(c, r + DotLook.thumbRing, Paint()..color = ring)
      ..drawCircle(c, r, Paint()..color = thumb);
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      old.value != value ||
      old.thumb != thumb ||
      old.halo != halo ||
      old.colours.length != colours.length ||
      old.colours.first != colours.first ||
      old.colours[colours.length ~/ 2] != colours[colours.length ~/ 2];
}
