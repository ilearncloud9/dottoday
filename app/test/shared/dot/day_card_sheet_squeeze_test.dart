import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The phone's day sheet squeezed by a keyboard and a prompt (found in the
// M18.8 iOS sweep: Brain dump left the page about 90 px tall and the
// pinned handle and Plan / Reality switch overflowed by 2–4 px). Below
// the short-card height they scroll with the thread instead.

const _entries = <ThreadEntry>[
  ThreadCap.wake('7:00'),
  ThreadTaskEntry(
    ThreadTask(
      id: 't1',
      title: 'Deep work', // l10n-ignore: test fixture
      color: TaskColor.indigo,
      icon: TaskIcon.code,
      state: DotState.upcoming,
      timeRange: '9:00 – 10:30',
      minutes: 90,
    ),
  ),
  ThreadCap.bed('23:00'),
];

Future<void> _pump(WidgetTester tester, double height, double scale) async {
  tester.view
    ..physicalSize = const Size(402, 874)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: DotTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(402, 874),
          textScaler: TextScaler.linear(scale),
        ),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: height,
              child: DayCard.page(
                entries: _entries,
                openAtNow: false,
                reality: RealityToggle(on: false, onChanged: (_) {}),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('a squeezed sheet never overflows at ${scale}x text', (
      tester,
    ) async {
      for (final height in [40.0, 60.0, 90.0, 120.0, 159.0, 160.0, 240.0]) {
        await _pump(tester, height, scale);
        expect(tester.takeException(), isNull, reason: 'at $height px');
      }
    });
  }

  testWidgets('a squeezed sheet still shows the switch, by scrolling', (
    tester,
  ) async {
    await _pump(tester, 90, 1);
    expect(
      find.byType(SegmentedButton<bool>, skipOffstage: false),
      findsWidgets,
    );
    expect(find.text('Deep work', skipOffstage: false), findsOneWidget);
  });
}
