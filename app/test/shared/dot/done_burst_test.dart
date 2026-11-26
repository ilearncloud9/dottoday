import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/done_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_l10n.dart';

// Marking done (ED-490): a ring fades outward from the circle, in the
// overlay; not on undo, not with Reduce Motion.

Finder get _burst =>
    find.byWidgetPredicate((w) => w.runtimeType.toString() == '_Burst');

Future<void> _pump(
  WidgetTester tester, {
  required bool done,
  bool reduce = false,
}) async {
  var taps = 0;
  await tester.pumpWidget(
    MaterialApp(
      theme: DotTheme.light(),
      localizationsDelegates: testL10nDelegates,
      supportedLocales: testL10nLocales,
      locale: testL10nLocale,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduce),
        child: Scaffold(
          body: Center(
            child: DoneCircle(
              color: TaskColor.coral,
              done: done,
              title: 'Morning run', // l10n-ignore: test fixture
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('marking done: the ring grows and fades over 500 ms', (
    tester,
  ) async {
    await _pump(tester, done: false);
    await tester.tap(find.byType(DoneCircle));
    await tester.pump();
    expect(_burst, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 250));
    expect(_burst, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    expect(_burst, findsNothing);
  });

  testWidgets('undoing never bursts', (tester) async {
    await _pump(tester, done: true);
    await tester.tap(find.byType(DoneCircle));
    await tester.pump();
    expect(_burst, findsNothing);
  });

  testWidgets('Reduce Motion: only the tick', (tester) async {
    await _pump(tester, done: false, reduce: true);
    await tester.tap(find.byType(DoneCircle));
    await tester.pump();
    expect(_burst, findsNothing);
  });
}
