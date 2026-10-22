import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/time/duration_presets.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

Widget _row(
  int value,
  List<int> out, {
  ThemeMode mode = ThemeMode.light,
  double scale = 1,
}) => testApp(
  Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: DurationRow(
            presets: defaultDurationPresets,
            value: value,
            onChanged: out.add,
          ),
        ),
      ),
    ),
  ),
  themeMode: mode,
);

void main() {
  testWidgets('short labels, one row; the full length is read out', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_row(90, []));
    for (final label in ['15', '30', '45', '1h', '1.5h', '2h']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(Row), findsWidgets);
    expect(
      tester.getSemantics(find.bySemanticsLabel('1 h 30')),
      matchesSemantics(
        label: '1 h 30',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('tapping a chip emits its minutes', (tester) async {
    final out = <int>[];
    await tester.pumpWidget(_row(30, out));
    await tester.tap(find.text('45'));
    expect(out, [45]);
  });

  testWidgets('at 200 % text the chips wrap instead of clipping', (
    tester,
  ) async {
    await tester.pumpWidget(_row(30, [], scale: 2));
    expect(find.byType(Wrap), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('presetLabel and formatDurationShort', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(formatDurationShort(l10n, 90), '1 h 30');
    expect(formatDuration(l10n, 90), '1 h 30 min');
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines ($mode)', (tester) async {
      await tester.pumpWidget(_row(60, [], mode: mode));
      await expectA11yGuidelines(tester);
    });
  }
}
