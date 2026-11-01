// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/shared/pickers/alerts/alerts_editor.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_editor.dart';
import 'package:dottoday/shared/pickers/repeat/scope_sheet.dart';
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
  // M3f.4: each day's planned colours (past days too, for Copy a day).
  goldenMatrix(
    'picker_change_day',
    height: 700,
    widths: widths,
    act: _open,
    build: (_) => _opener(
      (c) => unawaited(
        showMonthDayPicker(
          c,
          initial: DateTime(2026, 10, 23),
          today: _today,
          plannedFor: (_) => Stream.value({
            DateTime(2026, 10, 19): const [TaskColor.sky, TaskColor.mint],
            DateTime(2026, 10, 21): const [
              TaskColor.coral,
              TaskColor.sky,
              TaskColor.amber,
            ],
            DateTime(2026, 10, 22): const [TaskColor.violet],
            DateTime(2026, 10, 26): const [TaskColor.mint],
          }),
        ),
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
  // M3f.1: the Repeat editor (every 2 weeks on Mon and Wed, 10 times)
  // and the scope sheet.
  goldenMatrix(
    'picker_repeat',
    height: 900,
    widths: widths,
    act: _open,
    build: (_) => _opener(
      (c) => unawaited(
        showRepeatEditor(
          c,
          initial: const RepeatRule(
            frequency: RepeatFrequency.weekly,
            interval: 2,
            days: {Weekday.mon, Weekday.wed},
            end: EndsAfter(10),
          ),
          start: _today,
          today: _today,
        ),
      ),
    ),
  );
  goldenMatrix(
    'picker_scope',
    height: 500,
    widths: widths,
    act: _open,
    build: (_) => _opener((c) => unawaited(showScopeSheet(c, delete: false))),
  );
  // M3f.2: the Alerts editor with two alerts and the Wind Down switch.
  goldenMatrix(
    'picker_alerts',
    height: 700,
    widths: widths,
    act: _open,
    build: (_) => _opener(
      (c) => unawaited(
        showAlertsEditor(
          c,
          initial: const [
            Alert(kind: AlertKind.before, offsetMin: 10),
            Alert(kind: AlertKind.atStart),
          ],
          windDown: true,
          onWindDown: (_) {},
        ),
      ),
    ),
  );
}
