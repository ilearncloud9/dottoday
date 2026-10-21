// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/day_pager.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';
import '../../support/sample_day.dart';

void _noop(Object? _) {}

const _actions = ThreadActions(
  onToggleDone: _noop,
  onOpen: _noop,
  onExtend: _noop,
  onShiftRest: _noop,
  onAddHere: _noop,
);

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'day_pager',
    height: 844,
    build: (_) => DayPager(
      itemCount: 7,
      initialIndex: 3,
      itemBuilder: (context, i) => DayCard(
        title: 'Wednesday',
        isToday: i == 3,
        summary: const DaySummary(
          done: 2,
          total: 7,
          plannedMinutes: 345,
          freeMinutes: 555,
        ),
        entries: mainThread,
        actions: _actions,
      ),
    ),
  );
}
