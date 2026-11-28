import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/horizon_dot.dart';
import 'package:flutter/material.dart';

/// The horizon's labels under its line (ED-241): wake, now, the middle
/// hour and Wind Down, each measured at the person's text size; now's
/// always shows, the others give way where they would touch it (at 6:30
/// only "6:30", E-R2-26) or each other. [nowX] and [midX] are where now
/// and the middle hour sit on a line [width] wide.
List<Widget> horizonLabels(
  DotTheme t,
  HorizonLabels labels, {
  required double nowX,
  required double midX,
  required double width,
  required TextStyle style,
  required TextScaler scaler,
}) {
  final w = width;
  const top = DotSize.horizonCap + DotSpace.xxs;
  final now = t.styles.threadMeta.copyWith(
    color: t.colors.accentText,
    fontWeight: FontWeight.w700,
  );
  // Each label measured at the person's text size (M19.7: at 200 %
  // fixed clearances let "7 AM", "10:42 AM" and "2 PM" run together).
  double measure(String text, TextStyle s) {
    final p = TextPainter(
      text: TextSpan(text: text, style: s),
      textScaler: scaler,
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final v = p.width.ceilToDouble() + 1;
    p.dispose();
    return v;
  }

  (double, double) box(double x, double wide) {
    final l = (x - wide / 2).clamp(0.0, math.max(0.0, w - wide)).toDouble();
    return (l, l + wide);
  }

  bool apart((double, double) a, (double, double) b) =>
      a.$2 + DotSpace.s <= b.$1 || b.$2 + DotSpace.s <= a.$1;

  final nowW = measure(labels.now, now);
  final nowBox = box(nowX, nowW);
  final wakeBox = (0.0, measure(labels.wake, style));
  final windW = measure(labels.windDown, style);
  final windBox = (w - windW, w);
  final midW = measure(labels.mid, style);
  final midBox = box(midX, midW);
  // Now's label always shows; the others give way where they'd touch it
  // (at 6:30 only "6:30" shows, E-R2-26) or each other.
  final wakeClear = apart(wakeBox, nowBox);
  final windClear = apart(windBox, nowBox) && apart(windBox, wakeBox);
  final midClear =
      apart(midBox, nowBox) &&
      (!wakeClear || apart(midBox, wakeBox)) &&
      (!windClear || apart(midBox, windBox));
  Widget place((double, double) b, String text, TextStyle s) => Positioned(
    top: top,
    left: b.$1,
    width: b.$2 - b.$1,
    child: Text(text, style: s, textAlign: TextAlign.center, maxLines: 1),
  );
  return [
    if (wakeClear)
      Positioned(
        top: top,
        left: 0,
        child: Text(labels.wake, style: style, maxLines: 1),
      ),
    if (windClear)
      Positioned(
        top: top,
        right: 0,
        child: Text(labels.windDown, style: style, maxLines: 1),
      ),
    if (midClear) place(midBox, labels.mid, style),
    place(nowBox, labels.now, now),
  ];
}
