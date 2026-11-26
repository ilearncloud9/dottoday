import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_layout.dart';
import 'package:flutter/widgets.dart';

/// A row's title and subtitle styles (`.trow .lb b`, `small`).
(TextStyle, TextStyle) fillRowStyles(
  DotTheme t,
  FillRowKind k, {
  required bool compact,
}) {
  final s = t.styles;
  if (compact) return (s.onbRowTitleSmall, s.onbRowSubPick);
  return k == FillRowKind.pick
      ? (s.onbRowTitlePick, s.onbRowSubPick)
      : (s.onbRowTitle, s.onbRowSub);
}

/// Where the thread's parts go across, as the prototype places them at
/// normal text (time to 72, thread at 98, words from 132, NOW from 86).
/// At large text (ED-488, the prototype has none) the time column widens
/// to fit the longest time, moving the rest along, and heights grow with
/// the text ([scale]).
final class FillsGeometry {
  const FillsGeometry._(this.scale, this.shift);

  /// For [times] at the context's text size.
  factory FillsGeometry.of(
    BuildContext context, {
    required List<String> times,
  }) {
    final t = DotTheme.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    double width(String s, TextStyle style) {
      final p = TextPainter(
        text: TextSpan(text: s, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final w = p.width;
      p.dispose();
      return w;
    }

    final widest = times.fold<double>(
      0,
      (m, s) => math.max(m, width(s, t.styles.onbRowTime)),
    );
    const room = OnbSize.threadX - OnbSize.anchorDot / 2 - OnbSize.rowTimeEnd;
    return FillsGeometry._(
      math.max(1, scaler.scale(1)),
      math.max(0, widest + room - OnbSize.rowTimeEnd),
    );
  }

  /// The text size, 1 or more.
  final double scale;

  /// Text large enough that rows' words wrap rather than cut.
  bool get large => scale > largeText;

  /// From here the words wrap (the duration chips' threshold, §5.4).
  static const largeText = 1.3;

  /// How far the time column has grown.
  final double shift;

  double get timeEnd => OnbSize.rowTimeEnd + shift;
  double get thread => OnbSize.threadX + shift;
  double get wordsStart => OnbSize.rowWords + shift;
  double get nowLine => OnbSize.nowLine + shift;

  /// How far a row's words sit above its line.
  double wordsTop(FillRowKind kind, {required bool compact}) =>
      scale *
      (compact
          ? OnbSize.wordsTopSmall
          : kind == FillRowKind.pick
          ? OnbSize.wordsTopPick
          : OnbSize.wordsTop);

  /// The box a row's [text] (title, subtitle) takes, for NOW to stop
  /// short of.
  Rect words(
    BuildContext context,
    (String, String) text,
    FillRowKind kind,
    double y, {
    required bool compact,
    required double width,
  }) {
    final t = DotTheme.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final (title, sub) = fillRowStyles(t, kind, compact: compact);
    Size measure(String s, TextStyle st) {
      final p = TextPainter(
        text: TextSpan(text: s, style: st),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: large ? null : 1,
      )..layout(maxWidth: math.max(0, width - wordsStart));
      final out = p.size;
      p.dispose();
      return out;
    }

    final a = measure(text.$1, title);
    final b = compact ? Size.zero : measure(text.$2, sub);
    final w = math.max(a.width, b.width);
    final h = a.height + b.height;
    return Rect.fromLTWH(
      wordsStart,
      y - wordsTop(kind, compact: compact),
      w,
      h,
    );
  }

  /// How far a row reaches above and below its line at large text: its
  /// dot, its time and its wrapped [text].
  FillRowRoom room(
    BuildContext context,
    (String, String) text,
    FillRowKind kind, {
    required double width,
  }) {
    final box = words(context, text, kind, 0, compact: false, width: width);
    final dot =
        (kind == FillRowKind.pick ? OnbSize.pickDot : OnbSize.anchorDot) / 2;
    return (
      above: math.max(math.max(-box.top, dot), OnbSize.rowTimeTop * scale),
      below: math.max(box.bottom, dot),
    );
  }
}
