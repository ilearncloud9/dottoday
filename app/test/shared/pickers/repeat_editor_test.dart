import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';

// The Repeat editor (docs/09 M3f.1, R-01). The instance is Wed 21 Oct.
final _wed = DateTime(2026, 10, 21);

Future<Future<RepeatResult?>> _open(
  WidgetTester tester,
  RepeatRule? initial, {
  ThemeMode mode = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = const Size(390, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  late BuildContext ctx;
  await tester.pumpWidget(
    MaterialApp(
      theme: DotTheme.light(),
      darkTheme: DotTheme.dark(),
      themeMode: mode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (c) {
          ctx = c;
          return const Scaffold();
        },
      ),
    ),
  );
  final result = showRepeatEditor(
    ctx,
    initial: initial,
    start: _wed,
    today: _wed,
  );
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('every week on chosen days', (tester) async {
    final result = await _open(tester, null);
    expect(find.text('Never'), findsWidgets);
    await tester.tap(find.text('Every week'));
    await tester.pumpAndSettle();
    expect(find.text('Every week on Wed'), findsOneWidget);
    await tester.tap(find.text('Fri'));
    await tester.pumpAndSettle();
    expect(find.text('Every week on Wed, Fri'), findsOneWidget);
    await tester.tap(find.text('Done'));
    expect((await result)!.rule!.days, {Weekday.wed, Weekday.fri});
  });

  testWidgets('custom: every 2 weeks, ending after 10 times', (tester) async {
    final result = await _open(tester, null);
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('After'));
    await tester.pumpAndSettle();
    expect(find.text('Every 2 weeks on Wed · 10 times'), findsOneWidget);
    await tester.tap(find.text('Done'));
    final rule = (await result)!.rule!;
    expect((rule.interval, rule.end), (2, const EndsAfter(10)));
  });

  testWidgets('monthly by weekday reads "the third Wednesday"', (tester) async {
    final result = await _open(tester, null);
    await tester.tap(find.text('Every month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('On the third Wednesday'));
    await tester.pumpAndSettle();
    expect(find.text('Every month on the third Wednesday'), findsOneWidget);
    await tester.tap(find.text('Done'));
    expect((await result)!.rule!.monthlyBy, MonthlyBy.weekday);
  });

  testWidgets('weekdays shows as such; Never returns no rule', (tester) async {
    final result = await _open(tester, const RepeatRule.weekdays());
    expect(find.text('Every weekday'), findsWidgets);
    await tester.tap(find.text('Never').first); // the row, not Ends
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    expect((await result)!.rule, isNull);
  });

  testWidgets('meets a11y guidelines in both themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await _open(tester, const RepeatRule.weekdays(), mode: mode);
      await expectA11yGuidelines(tester);
    }
  });
}
