import 'package:flutter/widgets.dart';

/// Whether [text] in [style] fits [width] on one line at this context's
/// text size and direction. For layouts that change shape at large text
/// instead of breaking a word or shrinking it (accessibility-as-code: never
/// clamp the text scaler).
///
/// ```dart
/// textFitsOneLine(context, 'Wed', style, 40); // false at 200 %
/// ```
bool textFitsOneLine(
  BuildContext context,
  String text,
  TextStyle style,
  double width,
) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final fits = painter.width <= width;
  painter.dispose();
  return fits;
}

/// The widest word of [text] fits [width] in [style]: a title wraps at its
/// spaces, so only a single word wider than the line breaks mid-word.
bool longestWordFits(
  BuildContext context,
  String text,
  TextStyle style,
  double width,
) => text
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .every((w) => textFitsOneLine(context, w, style, width));
