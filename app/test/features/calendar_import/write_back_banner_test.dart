import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/domain/calendar/write_back_merge.dart';
import 'package:dottoday/features/calendar_import/write_back_banner.dart';
import 'package:dottoday/features/timeline/widgets/calendar_write_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/calendar_fakes.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

// Write-back's banner and the editor line (docs/02 F5 "a non-blocking
// banner with retry", docs/03 §3.4 "calendar write-back status", M7.3).

final _now = DateTime.utc(2026, 10, 21, 10);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<WriteBackTaps> pump(
    WidgetTester tester,
    WriteBackState state, {
    ThemeMode mode = ThemeMode.light,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final taps = WriteBackTaps();
    final controller = IdleWriteBackController(initial: state, taps: taps);
    await tester.pumpWidget(
      ProviderScope(
        overrides: timelineOverrides(now: _now, writeBack: () => controller),
        child: testApp(
          const Scaffold(body: Column(children: [WriteBackBanner()])),
          themeMode: mode,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return taps;
  }

  testWidgets('all sent: nothing', (tester) async {
    await pump(tester, const WriteBackState());
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets("couldn't send: says so, Try again retries", (tester) async {
    final c = await pump(tester, const WriteBackState(failed: 2));
    expect(
      find.text("2 changes haven't reached your calendar yet"),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    expect(c.retries, 1);
  });

  testWidgets('changed on both sides: Keep mine / Use calendar\'s', (
    tester,
  ) async {
    final c = await pump(tester, const WriteBackState(clashes: 1, failed: 1));
    expect(find.text('This event changed in your calendar too'), findsOne);
    await tester.tap(find.text('Keep mine'));
    await tester.tap(find.text("Use calendar's"));
    expect(c.resolved, [WriteBackPrefer.mine, WriteBackPrefer.calendar]);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (width, size) in [
      ('compact', const Size(390, 844)),
      ('expanded', const Size(1280, 800)),
    ]) {
      testWidgets('the editor line says where edits go: ${mode.name} $width', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ...timelineOverrides(now: _now),
              calendarWriteStatusProvider('l1').overrideWith(
                (ref) => Stream.value(
                  const CalendarWriteStatus(calendar: 'Work', sends: true),
                ),
              ),
              calendarWriteStatusProvider('l2').overrideWith(
                (ref) => Stream.value(
                  const CalendarWriteStatus(calendar: 'Holidays', sends: false),
                ),
              ),
            ],
            child: testApp(
              const Scaffold(
                body: Column(
                  children: [
                    CalendarWriteLine(linkId: 'l1'),
                    CalendarWriteLine(linkId: 'l2'),
                    CalendarWriteLine(linkId: null),
                  ],
                ),
              ),
              themeMode: mode,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Changes go back to Work'), findsOneWidget);
        expect(
          find.text('From Holidays · changes stay in Dottoday'),
          findsOneWidget,
        );
        await expectA11yGuidelines(tester);
      });
    }
  }

  // Both banners, both themes, compact and expanded (R-12).
  for (final state in const [
    WriteBackState(failed: 1),
    WriteBackState(clashes: 3),
  ]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      for (final (width, size) in [
        ('compact', const Size(390, 844)),
        ('expanded', const Size(1280, 800)),
      ]) {
        testWidgets(
          'a11y: ${state.clashes > 0 ? 'clash' : 'failed'} ${mode.name} $width',
          (tester) async {
            await pump(tester, state, mode: mode, size: size);
            await expectA11yGuidelines(tester);
          },
        );
      }
    }
  }
}
