import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/widgets.dart';

/// One frame of the night dial: where the band is, where the night runs
/// and in which colours. A value, so `shouldRepaint` is one compare.
@immutable
final class NightDialScene {
  const NightDialScene({
    required this.windDown,
    required this.wake,
    required this.track,
    required this.nightBand,
    required this.nightLine,
    required this.ticks,
    required this.dots,
  });

  /// Minutes after midnight.
  final int windDown;
  final int wake;

  final Color track;
  final Color nightBand;
  final Color nightLine;
  final Color ticks;
  final Color dots;

  @override
  bool operator ==(Object other) =>
      other is NightDialScene &&
      other.windDown == windDown &&
      other.wake == wake &&
      other.track == track &&
      other.nightBand == nightBand &&
      other.nightLine == nightLine &&
      other.ticks == ticks &&
      other.dots == dots;

  @override
  int get hashCode =>
      Object.hash(windDown, wake, track, nightBand, nightLine, ticks, dots);
}

/// The dial's geometry for a square of [size]: shared by the painter, the
/// handles and the drag, so they always agree. Midnight is at the top and
/// time runs clockwise (6 AM on the right).
@immutable
final class NightDialGeometry {
  const NightDialGeometry(this.size);

  final double size;

  Offset get centre => Offset(size / 2, size / 2);
  double get band => size * DotDial.bandShare;

  /// The middle of the band, where the handles ride.
  double get radius => size / 2 - DotDial.labelRoom - band / 2;
  double get inner => radius - band / 2;

  /// The free disc in the middle, inside the ticks.
  double get disc => inner - DotDial.tickInset - DotDial.tickMajor;

  /// The angle of [minute], clockwise from the top, in radians.
  static double angleOf(int minute) =>
      minute / Duration.minutesPerDay * 2 * math.pi;

  /// The point on the band at [minute].
  Offset at(int minute, [double? r]) {
    final a = angleOf(minute) - math.pi / 2;
    final rr = r ?? radius;
    return centre + Offset(math.cos(a) * rr, math.sin(a) * rr);
  }

  /// The minute under [p], snapped to [snap].
  int minuteAt(Offset p, {int snap = DotDial.step}) {
    final d = p - centre;
    var a = math.atan2(d.dy, d.dx) + math.pi / 2;
    if (a < 0) a += 2 * math.pi;
    final raw = a / (2 * math.pi) * Duration.minutesPerDay;
    return ((raw / snap).round() * snap) % Duration.minutesPerDay;
  }
}

/// Paints the band, the night on it, the hour ticks and the dotted day.
/// The handles, labels and the night's length are widgets on top.
class NightDialPainter extends CustomPainter {
  const NightDialPainter(this.scene);

  final NightDialScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final g = NightDialGeometry(size.shortestSide);
    final rect = Rect.fromCircle(center: g.centre, radius: g.radius);
    canvas.drawCircle(
      g.centre,
      g.radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = g.band
        ..color = scene.track,
    );
    final start = NightDialGeometry.angleOf(scene.windDown) - math.pi / 2;
    final sweep = NightDialGeometry.angleOf(
      (scene.wake - scene.windDown) % Duration.minutesPerDay,
    );
    canvas
      ..drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = g.band
          ..color = scene.nightBand,
      )
      ..drawArc(
        Rect.fromCircle(center: g.centre, radius: g.radius - g.band / 4),
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = DotDial.nightLine
          ..strokeCap = StrokeCap.round
          ..color = scene.nightLine,
      );
    _ticks(canvas, g);
    _dots(canvas, g);
  }

  void _ticks(Canvas canvas, NightDialGeometry g) {
    final paint = Paint()
      ..color = scene.ticks
      ..strokeWidth = DotSpace.hairline * 1.5
      ..strokeCap = StrokeCap.round;
    final from = g.inner - DotDial.tickInset;
    for (var h = 0; h < 24; h++) {
      final major = h % 6 == 0;
      final m = h * 60;
      canvas.drawLine(
        g.at(m, from),
        g.at(m, from - (major ? DotDial.tickMajor : DotDial.tick)),
        paint,
      );
    }
  }

  /// The day (Wake Up to Wind Down) as a dotted ring just inside the band.
  void _dots(Canvas canvas, NightDialGeometry g) {
    final paint = Paint()..color = scene.dots;
    final r = g.inner - DotDial.dotInset;
    final day = (scene.windDown - scene.wake) % Duration.minutesPerDay;
    for (var m = 0; m <= day; m += DotDial.dotEvery) {
      canvas.drawCircle(g.at(scene.wake + m, r), DotDial.dot, paint);
    }
  }

  @override
  bool shouldRepaint(NightDialPainter old) => old.scene != scene;
}
