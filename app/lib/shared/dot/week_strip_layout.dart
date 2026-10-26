import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The widest of [labels] on one line in [style] at the current text size,
/// in whole pixels as it will render. Measured, never scaled down (docs/10
/// §5.4: nothing wraps or truncates).
///
/// ```dart
/// widestLabel(context, ['Sun', 'Wed'], style); // 39 at 1.0, 78 at 2.0
/// ```
double widestLabel(
  BuildContext context,
  Iterable<String> labels,
  TextStyle style,
) {
  final painter = TextPainter(
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  );
  try {
    var widest = 0.0;
    for (final label in labels) {
      painter
        ..text = TextSpan(text: label, style: style)
        ..layout();
      widest = math.max(widest, painter.width.ceilToDouble());
    }
    return widest;
  } finally {
    painter.dispose();
  }
}

/// The locale's one-letter, stand-alone weekday for [date] ("W"; CLDR
/// narrow form), for `StripDay.weekdayNarrow`.
String narrowWeekday(DateTime date, String locale) =>
    DateFormat('ccccc', locale).format(date); // l10n-ignore: CLDR pattern

/// Seven fixed-width columns that scroll sideways, opening on [selected]:
/// the week strip's last resort when even its dates don't fit a seventh
/// of the width (a phone of 375 px or less at the largest text).
class ScrollingWeek extends StatefulWidget {
  const ScrollingWeek({
    required this.columnWidth,
    required this.selected,
    required this.columns,
    super.key,
  });

  final double columnWidth;
  final int selected;
  final List<Widget> columns;

  @override
  State<ScrollingWeek> createState() => _ScrollingWeekState();
}

class _ScrollingWeekState extends State<ScrollingWeek> {
  ScrollController? _scroll;

  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      // The selected day centred where it can be, from the first frame.
      final w = widget.columnWidth;
      final most = math.max(0.0, w * widget.columns.length - box.maxWidth);
      final centred = widget.selected * w - (box.maxWidth - w) / 2;
      _scroll ??= ScrollController(
        initialScrollOffset: centred.clamp(0.0, most),
      );
      return SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final c in widget.columns) SizedBox(width: w, child: c),
          ],
        ),
      );
    },
  );
}
