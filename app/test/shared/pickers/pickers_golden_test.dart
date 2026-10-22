// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'dart:async';

import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:dottoday/shared/pickers/zone_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';

/// The A4 sub-pickers (derived, docs/10 §5.3): a button that opens one;
/// each golden taps it.
Widget _opener(void Function(BuildContext context) open) => Builder(
  builder: (context) => Center(
    child: TextButton(
      onPressed: () => open(context),
      child: const Text('open'), // l10n-ignore: test fixture
    ),
  ),
);

Future<void> _open(WidgetTester tester) => tester.tap(find.text('open'));

final _today = DateTime(2026, 10, 21);

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  const widths = {'compact', 'expanded'};
  goldenMatrix(
    'picker_change_day',
    height: 700,
    widths: widths,
    act: _open,
    build: (_) => _opener(
      (c) => unawaited(
        showMonthDayPicker(c, initial: DateTime(2026, 10, 23), today: _today),
      ),
    ),
  );
  goldenMatrix(
    'picker_week',
    height: 400,
    widths: widths,
    act: _open,
    build: (_) => _opener(
      (c) => unawaited(showWeekDayPicker(c, initial: _today, today: _today)),
    ),
  );
  goldenMatrix(
    'picker_zone',
    height: 700,
    widths: widths,
    act: (tester) async {
      await _open(tester);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'new');
    },
    build: (_) =>
        _opener((c) => unawaited(showZonePicker(c, current: 'Europe/Berlin'))),
  );
}
