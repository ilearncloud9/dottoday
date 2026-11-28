import 'dart:async';
import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:flutter/material.dart';

/// Catch the dot on the dawn sky (E-R2-19-B, ED-314; ED-336): four dots,
/// each its own colour and shape (never colour alone, no red), glide on
/// smooth loops across the screen; [catchTaps] taps on the blue circle
/// finish. A miss doesn't count and nothing says so (no-shame rule). With
/// reduced motion the dots hold still and the circle hops after each catch.
/// Screen readers get one "Tap the blue circle" button that counts a catch.
///
/// [CatchDotField] draws the dots over the whole sky; [CatchDotHint] sits
/// under the time with the target and the count. Both read [caught].
enum CatchShape { circle, triangle, square, plus }

/// One dot's loop on the board's 390 × 844 sky (`ct-dot` offset paths): an
/// ellipse round [centre] with radii [rx] × [ry] turned [turn] degrees,
/// once every [period], [reverse]d or not, started [lead] in; with reduced
/// motion it rests [still] of the way round.
typedef _Loop = ({
  CatchShape shape,
  Color colour,
  Offset centre,
  double rx,
  double ry,
  double turn,
  Duration period,
  bool reverse,
  Duration lead,
  double still,
});

/// The four dots as E-R2-19-B draws them; the first is the one to tap.
const List<_Loop> _loops = [
  (
    shape: CatchShape.circle,
    colour: DotDawn.catchBlue,
    centre: Offset(195, 258),
    rx: 135,
    ry: 215,
    turn: 12,
    period: Duration(seconds: 19),
    reverse: false,
    lead: Duration.zero,
    still: 0.12,
  ),
  (
    shape: CatchShape.triangle,
    colour: DotDawn.catchViolet,
    centre: Offset(195, 250),
    rx: 150,
    ry: 150,
    turn: -30,
    period: Duration(seconds: 23),
    reverse: true,
    lead: Duration(seconds: 6),
    still: 0.37,
  ),
  (
    shape: CatchShape.square,
    colour: DotDawn.catchYellow,
    centre: Offset(195, 260),
    rx: 100,
    ry: 210,
    turn: 38,
    period: Duration(seconds: 17),
    reverse: false,
    lead: Duration(seconds: 11),
    still: 0.62,
  ),
  (
    shape: CatchShape.plus,
    colour: DotDawn.catchGreen,
    centre: Offset(195, 258),
    rx: 150,
    ry: 130,
    turn: 4,
    period: Duration(seconds: 29),
    reverse: true,
    lead: Duration(seconds: 3),
    still: 0.87,
  ),
];

class CatchDotField extends StatefulWidget {
  const CatchDotField({required this.caught, required this.onDone, super.key});

  final ValueNotifier<int> caught;
  final VoidCallback onDone;

  @override
  State<CatchDotField> createState() => _CatchDotFieldState();
}

class _CatchDotFieldState extends State<CatchDotField>
    with TickerProviderStateMixin {
  /// Time on the sky; each dot reads its own place from it.
  final _clock = ValueNotifier(Duration.zero);
  late final _ticker = createTicker((elapsed) => _clock.value = elapsed);

  /// The ring that spreads from a catch (`ctTap`).
  late final _tap = AnimationController(
    vsync: this,
    duration: DotDawnMotion.catchTap,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = DotTheme.of(context).motion.isReduced;
    if (reduced && _ticker.isActive) _ticker.stop();
    if (!reduced && !_ticker.isActive) unawaited(_ticker.start());
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    _tap.dispose();
    super.dispose();
  }

  void _catch() {
    if (!DotTheme.of(context).motion.isReduced) {
      unawaited(_tap.forward(from: 0));
    }
    catchOne(widget.caught, widget.onDone);
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final size = AppLayout.classOf(context) == WidthClass.expanded
        ? DotSize.catchDotTablet
        : DotSize.catchDot;
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, box) => AnimatedBuilder(
          animation: Listenable.merge([_clock, widget.caught, _tap]),
          builder: (context, _) {
            final reduced = t.motion.isReduced;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (final (i, loop) in _loops.indexed)
                  _placed(
                    box,
                    size,
                    _spot(loop, reduced),
                    _Dot(
                      shape: loop.shape,
                      colour: loop.colour,
                      size: size,
                      tap: i == 0 ? _tap.value : 0,
                      onTap: i == 0 ? _catch : null,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Keeps a dot's centre on the sky and its whole above Can't right now.
  Widget _placed(BoxConstraints box, double size, Offset at, Widget dot) {
    final x = at.dx / DotSize.dawnSkyWidth * box.maxWidth - size / 2;
    final y = at.dy / DotSize.dawnSkyHeight * box.maxHeight - size / 2;
    return Positioned(
      left: x.clamp(0, box.maxWidth - size),
      top: y.clamp(0, box.maxHeight * _fieldBottom - size),
      child: dot,
    );
  }

  /// [loop]'s place now, on the board's sky (390 × 844).
  Offset _spot(_Loop loop, bool reduced) {
    final caughtTurn = widget.caught.value / _loops.length;
    final f = reduced
        ? loop.still + (identical(loop, _loops.first) ? caughtTurn : 0)
        : ((_clock.value + loop.lead).inMicroseconds /
                  loop.period.inMicroseconds) %
              1;
    final along = loop.reverse ? 1 - f : f;
    // The board's paths start at the ellipse's far end and sweep forward.
    final phi = math.pi + 2 * math.pi * along;
    final th = loop.turn * math.pi / 180;
    return loop.centre +
        Offset(
          loop.rx * math.cos(phi) * math.cos(th) -
              loop.ry * math.sin(phi) * math.sin(th),
          loop.rx * math.cos(phi) * math.sin(th) +
              loop.ry * math.sin(phi) * math.cos(th),
        );
  }
}

/// Where the dots may go: the top of the sky down to above Can't right now.
const _fieldBottom = 0.8;

/// Counts a catch of the blue circle; [onDone] after [catchTaps].
void catchOne(ValueNotifier<int> caught, VoidCallback onDone) {
  if (caught.value >= catchTaps) return;
  caught.value++;
  if (caught.value >= catchTaps) onDone();
}

/// One dot: its colour as a disc with the board's shadow, its shape inside,
/// and on the blue circle the white ring spreading from a catch ([tap]).
class _Dot extends StatelessWidget {
  const _Dot({
    required this.shape,
    required this.colour,
    required this.size,
    this.tap = 0,
    this.onTap,
  });

  final CatchShape shape;
  final Color colour;
  final double size;

  /// The catch ring, 0–1.
  final double tap;
  final VoidCallback? onTap;

  /// The ring grows to 2.3 as it fades (`ctTap`).
  static const _grow = 1.3;

  @override
  Widget build(BuildContext context) {
    final dot = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: DotDawn.dotShadow,
                offset: Offset(0, DotSpace.s),
                blurRadius: DotSpace.xl - DotSpace.xs,
              ),
            ],
          ),
          child: CustomPaint(
            size: Size.square(size),
            painter: _DotPainter(shape: shape, colour: colour),
          ),
        ),
        if (tap > 0 && tap < 1)
          Positioned.fill(
            child: Transform.scale(
              scale: 1 + _grow * tap,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DotDawn.ink.withValues(alpha: 1 - tap),
                    width: DotSpace.xxs + 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    if (onTap == null) return IgnorePointer(child: dot);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: dot,
    );
  }
}

class _DotPainter extends CustomPainter {
  const _DotPainter({required this.shape, required this.colour});

  final CatchShape shape;
  final Color colour;

  /// The board's 24 × 24 box for the shapes.
  static const _box = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    canvas
      ..drawCircle(Offset(r, r), r, Paint()..color = colour)
      ..save()
      ..scale(size.width / _box);
    final white = Paint()..color = DotDawn.ink;
    switch (shape) {
      case CatchShape.circle:
        canvas.drawCircle(const Offset(12, 12), 5.2, white);
      case CatchShape.triangle:
        canvas.drawPath(
          Path()
            ..moveTo(12, 6.4)
            ..lineTo(18.2, 17.3)
            ..lineTo(5.8, 17.3)
            ..close(),
          white,
        );
      case CatchShape.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(7.4, 7.4, 9.2, 9.2),
            DotDawn.catchSquareCorner,
          ),
          Paint()..color = DotDawn.inkDark,
        );
      case CatchShape.plus:
        final bar = Paint()
          ..color = DotDawn.ink
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
        canvas
          ..drawLine(const Offset(12, 7), const Offset(12, 17), bar)
          ..drawLine(const Offset(7, 12), const Offset(17, 12), bar);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DotPainter old) =>
      old.shape != shape || old.colour != colour;
}

/// Under the time: "● Tap the blue circle" and "1 of 3". Screen readers
/// get it as one button that counts a catch.
class CatchDotHint extends StatelessWidget {
  const CatchDotHint({required this.caught, required this.onDone, super.key});

  final ValueNotifier<int> caught;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final first = _loops.first;
    return ValueListenableBuilder<int>(
      valueListenable: caught,
      builder: (context, n, _) => Semantics(
        button: true,
        label: l10n.missionCatchTap,
        value: l10n.missionCatchCount(n, catchTaps),
        excludeSemantics: true,
        onTap: () => catchOne(caught, onDone),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: DotSpace.xs,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: DotSpace.s,
              children: [
                CustomPaint(
                  size: const Size.square(DotSize.formCheck),
                  painter: _DotPainter(
                    shape: first.shape,
                    colour: first.colour,
                  ),
                ),
                Text(l10n.missionCatchTap, style: t.styles.smallChip),
              ],
            ),
            Text(
              l10n.missionCatchCount(n, catchTaps),
              style: t.styles.gridMetaTouch.copyWith(color: t.colors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
