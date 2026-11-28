import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The soft shadow under the sun, the moon and their labels (`--sh`).
BoxShadow onbSoftShadow(DotColors c) => BoxShadow(
  color: c.shadow.withValues(
    alpha: c.isDark ? OnbSize.shadowAlphaDark : OnbSize.shadowAlphaLight,
  ),
  offset: const Offset(0, OnbSize.shadowY),
  blurRadius: OnbSize.shadowBlur,
  spreadRadius: OnbSize.shadowSpread,
);

/// The sun or the moon (prototype `.hdl`): a slider. It follows the
/// finger ([onDragTo] gets the finger's global y) and grows to 1.12 while
/// held; arrow keys move 15 minutes and Page Up or Down an hour ([onStep]);
/// screen readers read "Wake Up, 7:00 AM" and swipe it up or down.
class DayDialHandle extends StatefulWidget {
  const DayDialHandle({
    required this.glyph,
    required this.glyphSize,
    required this.color,
    required this.label,
    required this.value,
    required this.increased,
    required this.decreased,
    required this.onDragTo,
    required this.onStep,
    super.key,
  });

  final DotGlyph glyph;
  final double glyphSize;
  final Color color;
  final String label;
  final String value;

  /// What [value] would be 15 minutes later, and earlier.
  final String increased;
  final String decreased;
  final ValueChanged<double> onDragTo;

  /// Minutes to move by: ±15, or ±60.
  final ValueChanged<int> onStep;

  @override
  State<DayDialHandle> createState() => _DayDialHandleState();
}

class _DayDialHandleState extends State<DayDialHandle> {
  var _held = false;
  var _focused = false;

  static final _steps = {
    LogicalKeyboardKey.arrowUp: -15,
    LogicalKeyboardKey.arrowLeft: -15,
    LogicalKeyboardKey.arrowDown: 15,
    LogicalKeyboardKey.arrowRight: 15,
    LogicalKeyboardKey.pageUp: -60,
    LogicalKeyboardKey.pageDown: 60,
  };

  KeyEventResult _key(FocusNode _, KeyEvent e) {
    if (e is KeyUpEvent) return KeyEventResult.ignored;
    final step = _steps[e.logicalKey];
    if (step == null) return KeyEventResult.ignored;
    widget.onStep(step);
    return KeyEventResult.handled;
  }

  void _hold(bool held) {
    if (_held != held) setState(() => _held = held);
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final hc = widget.color;
    final halo = _held ? OnbSize.handleHaloHeld : OnbSize.handleHalo;
    final haloAlpha = _held
        ? OnbSize.handleHaloHeldAlpha
        : OnbSize.handleHaloAlpha;
    return Semantics(
      slider: true,
      label: widget.label,
      value: widget.value,
      increasedValue: widget.increased,
      decreasedValue: widget.decreased,
      onIncrease: () => widget.onStep(15),
      onDecrease: () => widget.onStep(-15),
      child: Focus(
        onKeyEvent: _key,
        onFocusChange: (f) => setState(() => _focused = f),
        child: Listener(
          onPointerDown: (_) => _hold(true),
          onPointerUp: (_) => _hold(false),
          onPointerCancel: (_) => _hold(false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            dragStartBehavior: DragStartBehavior.down,
            onVerticalDragStart: (d) => widget.onDragTo(d.globalPosition.dy),
            onVerticalDragUpdate: (d) => widget.onDragTo(d.globalPosition.dy),
            child: AnimatedScale(
              scale: _held ? OnbSize.handleHeldScale : 1,
              // Kept with Reduce Motion: the prototype only stops the pop.
              duration: OnbMotion.handle,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.card,
                  border: Border.all(color: hc, width: OnbSize.handleRing),
                  boxShadow: [
                    if (_focused)
                      BoxShadow(
                        color: c.focus,
                        spreadRadius: halo + OnbSize.handleRing,
                      ),
                    BoxShadow(
                      color: hc.withValues(alpha: haloAlpha),
                      spreadRadius: halo,
                    ),
                    onbSoftShadow(c),
                  ],
                ),
                child: Center(
                  child: DotIcon(
                    widget.glyph,
                    color: hc,
                    size: widget.glyphSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The sun's or moon's label (prototype `.bub`): "WAKE UP" over "7:00 AM".
/// Each time [pops] changes (its time reached an hour) it pops to 1.06
/// and back over 220 ms (CSS `ease` each way); not with Reduce Motion.
class DayDialBubble extends StatefulWidget {
  const DayDialBubble({
    required this.caption,
    required this.time,
    required this.pops,
    super.key,
  });

  final String caption;
  final String time;
  final int pops;

  @override
  State<DayDialBubble> createState() => _DayDialBubbleState();
}

class _DayDialBubbleState extends State<DayDialBubble>
    with SingleTickerProviderStateMixin {
  late final _pop = AnimationController(vsync: this, duration: OnbMotion.tick);
  late final _scale = TweenSequence([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: OnbMotion.tickScale,
      ).chain(CurveTween(curve: OnbMotion.tickCurve)),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: OnbMotion.tickScale,
        end: 1,
      ).chain(CurveTween(curve: OnbMotion.tickCurve)),
      weight: 1,
    ),
  ]).animate(_pop);

  @override
  void didUpdateWidget(DayDialBubble old) {
    super.didUpdateWidget(old);
    if (old.pops == widget.pops) return;
    if (DotTheme.of(context).motion.isReduced) return;
    _pop.forward(from: 0);
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final locale = Localizations.localeOf(context);
    return ScaleTransition(
      scale: _scale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.card,
          borderRadius: BorderRadius.circular(OnbSize.bubbleRadius),
          boxShadow: [onbSoftShadow(t.colors)],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: OnbSize.bubblePadV,
            horizontal: OnbSize.bubblePadH,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.caption.toUpperCase(),
                style: t.styles.onbBubbleCap,
                locale: locale,
              ),
              Text(widget.time, style: t.styles.onbBubbleTime),
            ],
          ),
        ),
      ),
    );
  }
}
