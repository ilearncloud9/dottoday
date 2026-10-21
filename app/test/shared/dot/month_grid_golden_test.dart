// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';
import '../../support/sample_month.dart';

Widget _grid({
  required int month,
  required int weekStart,
  MonthCellStyle style = MonthCellStyle.compact,
  bool future = false,
}) => SingleChildScrollView(
  padding: const EdgeInsets.all(DotSpace.page),
  child: MonthGrid(
    weekdays: sampleWeekdays(weekStart),
    days: sampleMonth(
      year: 2026,
      month: month,
      weekStart: weekStart,
      future: future,
    ),
    style: style,
    selected: future
        ? null
        : sampleMonth(
            year: 2026,
            month: month,
            weekStart: weekStart,
          ).indexWhere((d) => d?.isToday ?? false),
    onSelect: (_) {},
  ),
);

/// The expanded cell is the Mac/web Month (§4); medium is its narrowest
/// window.
const _expandedOnly = {'medium', 'expanded'};

void main() {
  setUpAll(loadAppFonts);
  // October 2026 has 5 rows from either week start; August 2026 has 6.
  goldenMatrix(
    'month_compact_oct_sun',
    height: 420,
    build: (_) => _grid(month: 10, weekStart: 0),
  );
  goldenMatrix(
    'month_compact_aug_mon',
    height: 480,
    build: (_) => _grid(month: 8, weekStart: 1),
  );
  goldenMatrix(
    'month_compact_future_dec',
    height: 420,
    build: (_) => _grid(month: 12, weekStart: 0, future: true),
  );
  goldenMatrix(
    'month_expanded_oct_sun',
    height: 1000,
    widths: _expandedOnly,
    build: (_) =>
        _grid(month: 10, weekStart: 0, style: MonthCellStyle.expanded),
  );
  goldenMatrix(
    'month_expanded_aug_mon',
    height: 1180,
    widths: _expandedOnly,
    build: (_) => _grid(month: 8, weekStart: 1, style: MonthCellStyle.expanded),
  );
}
