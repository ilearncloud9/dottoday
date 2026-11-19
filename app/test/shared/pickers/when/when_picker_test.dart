import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/shared/pickers/when/day_bar.dart';
import 'package:dottoday/shared/pickers/when/when_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/a11y.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The one When picker (G2-12 Q2, ED-099; M19.4 part 4b): free time, the
/// day chips, the day bar, and the start it returns; nothing written.
final _date = DateTime(2026, 10, 21);
final _now = DateTime.utc(2026, 10, 21, 9); // 11:00 Berlin

late FakeOccurrenceRepository _rows;
DateTime? _picked;

Occurrence get _reply =>
    _rows.rows.firstWhere((o) => o.title == 'Reply to email');

Future<void> _open(
  WidgetTester tester,
  WhenMode mode, {
  Size size = const Size(390, 900),
  ThemeMode theme = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _rows = FakeOccurrenceRepository(demoDayRows(_date));
  _picked = null;
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: _now,
        occurrences: _rows,
        profile: testProfile(settings: const Settings(use24h: false)),
      ),
      child: testApp(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  final task = mode == WhenMode.move
                      ? _reply
                      : _reply.copyWith(id: 'inbox-1', startUtc: null);
                  _picked = await showWhenPicker(
                    context,
                    task: task,
                    mode: mode,
                    today: _date,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
        themeMode: theme,
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _slide(WidgetTester tester, SemanticsAction action, int n) async {
  final bar = tester.getSemantics(find.bySemanticsLabel('Start time'));
  for (var i = 0; i < n; i++) {
    tester.binding.performSemanticsAction(
      SemanticsActionEvent(
        type: action,
        nodeId: bar.id,
        viewId: tester.view.viewId,
      ),
    );
    await tester.pump();
  }
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets("Move starts at the task's own time and keeps it on any day", (
    tester,
  ) async {
    await _open(tester, WhenMode.move);
    expect(find.text('Move Reply to email'), findsOneWidget);
    expect(find.textContaining('keeps its length'), findsOneWidget);
    expect(find.text('Move to 11:30 AM'), findsOneWidget);
    await tester.tap(find.text('Fri 23'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to 11:30 AM'));
    await tester.pumpAndSettle();
    expect(_picked, DateTime.utc(2026, 10, 23, 9, 30));
    expect(
      _rows.rows.firstWhere((o) => o.id == _reply.id).startUtc,
      DateTime.utc(2026, 10, 21, 9, 30),
      reason: 'the picker writes nothing',
    );
  });

  testWidgets('a free time places at once', (tester) async {
    await _open(tester, WhenMode.schedule);
    expect(find.text('Schedule Reply to email'), findsOneWidget);
    expect(find.text('FREE TIME'), findsOneWidget);
    await tester.tap(find.text('Place').first);
    await tester.pumpAndSettle();
    expect(_picked, isNotNull);
    expect(_picked!.isAfter(_now), isTrue);
  });

  testWidgets('the bar steps by the snap; the line says free or overlaps', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _open(tester, WhenMode.move);
    expect(find.text('11:30 AM – 12:00 PM · free'), findsOneWidget);
    await _slide(tester, SemanticsAction.increase, 12); // +60 min
    expect(find.textContaining('12:30 PM – 1:00 PM · overlaps'), findsOne);
    await _slide(tester, SemanticsAction.decrease, 12);
    expect(find.text('11:30 AM – 12:00 PM · free'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('arrow keys move it once the bar has focus', (tester) async {
    await _open(tester, WhenMode.move);
    final bar = tester.getRect(find.byType(DayBar));
    // On its first hour mark: the ring jumps there, and the bar is focused.
    await tester.tapAt(bar.centerLeft + const Offset(12, -10));
    await tester.pumpAndSettle();
    final before = tester.widget<DayBar>(find.byType(DayBar)).startMinute;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(tester.widget<DayBar>(find.byType(DayBar)).startMinute, before + 5);
  });

  testWidgets('Date… opens the month', (tester) async {
    await _open(tester, WhenMode.schedule);
    await tester.tap(find.text('Date…'));
    await tester.pumpAndSettle();
    expect(find.text('Change day'), findsOneWidget);
  });

  testWidgets('the Mac popover: a typed time, and Return places', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await _open(tester, WhenMode.move, size: const Size(1280, 800));
      expect(find.byType(TextField), findsOneWidget, reason: 'typed time');
      expect(find.text('↵'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(_picked, DateTime.utc(2026, 10, 21, 9, 30));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('a11y guidelines hold, ${mode.name}', (tester) async {
      await _open(tester, WhenMode.schedule, theme: mode);
      await expectA11yGuidelines(tester);
    });
  }
}
