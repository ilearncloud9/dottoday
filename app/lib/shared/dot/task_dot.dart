import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// What a task's dot shows (docs/10 §1, §3 `TaskDot`).
enum DotState {
  /// The task has not started.
  upcoming,

  /// A ring inside the dot fills with the task's progress.
  live,

  /// Done: the dot is unchanged; the row's done circle is filled.
  done,

  /// Dashed ring, faded icon: skipped, or a repeat not yet materialised.
  skipped,

  /// Drawn like [upcoming]; its row says "not done" (§5.2, `A-mac-month`).
  missed,
}

/// Screen-reader label of a dot with its state (docs/10 §5.4):
/// "Deep work, live, 38 minutes left".
String taskDotLabel(
  AppLocalizations l10n, {
  required String title,
  required DotState state,
  int? minutesLeft,
}) => switch (state) {
  DotState.upcoming => l10n.dotUpcoming(title),
  DotState.live when minutesLeft != null => l10n.dotLiveLeft(
    title,
    minutesLeft,
  ),
  DotState.live => l10n.dotLive(title),
  DotState.done => l10n.dotDone(title),
  DotState.skipped => l10n.dotSkipped(title),
  DotState.missed => l10n.dotMissed(title),
};

/// The icon dot every task is drawn as, in Concept E's states (E rules
/// §4.4, §5.1; ED-198 to ED-200):
/// - **done:** solid in the task's colour, the icon in [TaskSwatch.check]
///   (white; the ground's ink in dark; ink on amber, ED-196);
/// - **ahead** (upcoming, missed): the card colour inside an inset ring in
///   the task's ring shade, the icon in that shade;
/// - **now** (live): a progress ring over a track of the task's colour at
///   20 % (dark: 25 %), clockwise from 12 o'clock;
/// - **skipped:** a dashed, faded ring and icon (R2-27);
/// - **calendar event** ([calendar]): the ground's colour inside a 2.5 px
///   grey ring, a dark icon (ED-200).
///
/// With [onTap] it opens the task (or Focus for the live one) and its hit
/// area is at least 48 dp whatever its [size]; without, it is decorative
/// and merges into the row's own label.
class TaskDot extends StatelessWidget {
  const TaskDot({
    required this.color,
    required this.icon,
    required this.state,
    required this.label,
    this.progress = 0,
    this.size = DotSize.rowDot,
    this.onTap,
    this.tapHint,
    this.oneThing = false,
    this.calendar = false,
    super.key,
  });

  /// An imported calendar event: drawn in the event recipe (ED-200), not
  /// the task's colour.
  final bool calendar;

  /// Today's one thing (docs/15 §8): the single accent ring outside the
  /// dot. The row says "Your one thing" too, so it never relies on colour.
  final bool oneThing;

  final TaskColor color;
  final TaskIcon icon;
  final DotState state;

  /// From [taskDotLabel].
  final String label;

  /// 0–1 share of a live task that has elapsed; ignored in other states.
  final double progress;

  /// [DotSize.threadDot] (56), [DotSize.rowDot] (36), [DotSize.macRowDot]
  /// (26) or [DotSize.pickerDot] (22).
  final double size;
  final VoidCallback? onTap;

  /// What a tap does, read after the label ("Open").
  final String? tapHint;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final swatch = t.tasks[color];
    final look = _look(c, swatch);
    final dot = TweenAnimationBuilder<double>(
      tween: Tween(end: state == DotState.live ? progress.clamp(0, 1) : 0),
      duration: t.motion.base,
      curve: t.motion.curve,
      builder: (context, sweep, child) => CustomPaint(
        size: Size.square(size),
        painter: _DotPainter(
          look: look,
          state: state,
          sweep: sweep,
          ring: calendar ? _calendarRing(size) : _ring(size),
          halo: oneThing ? c.accent : null,
        ),
        child: child,
      ),
      child: SizedBox.square(dimension: size, child: _glyph(look.glyph)),
    );
    if (onTap == null) {
      return Semantics(label: label, excludeSemantics: true, child: dot);
    }
    final target = math.max(size, DotTouch.android);
    return Semantics(
      button: true,
      label: label,
      onTapHint: tapHint,
      onTap: onTap,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: target / 2,
        child: SizedBox.square(
          dimension: target,
          child: Center(child: dot),
        ),
      ),
    );
  }

  /// The colours of this dot's state.
  _Look _look(DotColors c, TaskSwatch swatch) {
    if (calendar) {
      // A live event keeps the recipe; its progress runs in the ring grey.
      return _Look(
        fill: c.surface,
        ring: c.tertiary,
        glyph: c.calendarIcon,
        track: c.tertiary.withValues(alpha: c.isDark ? 0.25 : 0.2),
      );
    }
    return switch (state) {
      DotState.done => _Look(
        fill: swatch.color,
        ring: swatch.color,
        glyph: swatch.check,
      ),
      DotState.live => _Look(
        fill: c.raised,
        ring: swatch.ring,
        glyph: swatch.ring,
        track: swatch.color.withValues(alpha: c.isDark ? 0.25 : 0.2),
      ),
      DotState.skipped => _Look(
        fill: c.raised,
        ring: swatch.ring.withValues(alpha: TaskAlpha.faded),
        glyph: swatch.ring.withValues(alpha: TaskAlpha.faded),
      ),
      DotState.upcoming || DotState.missed => _Look(
        fill: c.raised,
        ring: swatch.ring,
        glyph: swatch.ring,
      ),
    };
  }

  Widget? _glyph(Color ink) {
    final glyph = icon.glyph;
    if (glyph == null) return null;
    return Center(
      child: DotIcon(glyph, color: ink, size: _iconSize(size), bold: true),
    );
  }
}

/// Concept E's icon sizes: 18 in a 32 dot, 19 in 34, 24 in the 45 ring
/// (§5.1); other sizes keep that share.
double _iconSize(double size) =>
    size >= DotSize.liveDot ? size * 24 / 45 : size * 19 / 34;

/// The ring's width for a dot of [size] (ED-199, ED-104).
double _ring(double size) => size >= DotSize.liveDot
    ? DotSize.liveRing
    : size >= 30
    ? DotSize.dotOutline
    : size > 16
    ? DotSize.midDotOutline
    : DotSize.tinyDotOutline;

double _calendarRing(double size) =>
    size > 16 ? DotSize.calendarOutline : DotSize.smallDotOutline;

/// What one dot state paints: its centre, ring and icon colours, and a
/// live dot's track.
@immutable
final class _Look {
  const _Look({
    required this.fill,
    required this.ring,
    required this.glyph,
    this.track,
  });

  final Color fill;
  final Color ring;
  final Color glyph;
  final Color? track;

  @override
  bool operator ==(Object other) =>
      other is _Look &&
      other.fill == fill &&
      other.ring == ring &&
      other.glyph == glyph &&
      other.track == track;

  @override
  int get hashCode => Object.hash(fill, ring, glyph, track);
}

final class _DotPainter extends CustomPainter {
  const _DotPainter({
    required this.look,
    required this.state,
    required this.sweep,
    required this.ring,
    this.halo,
  });

  final _Look look;
  final DotState state;
  final double sweep;
  final double ring;

  /// The one-thing ring's colour, or null; drawn outside the dot's box
  /// so the layout around it never moves.
  final Color? halo;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    if (halo case final h?) {
      canvas.drawCircle(
        c,
        size.shortestSide / 2 + DotSize.oneThingGap + DotSize.oneThingRing / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = DotSize.oneThingRing
          ..color = h,
      );
    }
    canvas.drawCircle(c, size.shortestSide / 2, Paint()..color = look.fill);
    if (state == DotState.done) return;
    // Inset: the ring sits inside the dot, so its outside size never moves.
    final r = size.shortestSide / 2 - ring / 2;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ring
      ..color = look.ring;
    switch (state) {
      case DotState.live:
        _live(canvas, c, r, stroke);
      case DotState.skipped:
        _dashed(canvas, c, r, stroke);
      case DotState.upcoming || DotState.missed || DotState.done:
        canvas.drawCircle(c, r, stroke);
    }
  }

  /// The track all round, then the elapsed share clockwise from 12.
  void _live(Canvas canvas, Offset c, double r, Paint stroke) {
    canvas.drawCircle(c, r, Paint.from(stroke)..color = look.track!);
    if (sweep <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * sweep,
      false,
      stroke..strokeCap = StrokeCap.round,
    );
  }

  void _dashed(Canvas canvas, Offset c, double r, Paint stroke) {
    const dashes = 10;
    final rect = Rect.fromCircle(center: c, radius: r);
    const step = 2 * math.pi / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * step, step * 0.55, false, stroke);
    }
  }

  @override
  bool shouldRepaint(_DotPainter old) =>
      old.look != look ||
      old.state != state ||
      old.sweep != sweep ||
      old.ring != ring ||
      old.halo != halo;
}
