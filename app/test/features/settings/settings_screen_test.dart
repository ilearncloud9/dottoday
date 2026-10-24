import 'package:dottoday/data/feedback/diagnostics_reader.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/sound/sound_player.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/feedback/feedback_diagnostics.dart';
import 'package:dottoday/domain/notifications/reminder_sound.dart';
import 'package:dottoday/shared/dot/day_shape_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';
import 'settings_harness.dart';

Future<void> _tapRow(WidgetTester tester, String title) async {
  final row = find.text(title).first;
  await tester.ensureVisible(row);
  await tester.pumpAndSettle();
  await tester.tap(row);
  await tester.pumpAndSettle();
}

/// Switch.adaptive draws a Cupertino switch on iPhone (§4 switch idiom).
Finder _cupertinoSwitches() => find.byType(CupertinoSwitch);

final class _FakePlayer implements SoundPlayer {
  final played = <ReminderSound>[];

  @override
  Future<void> play(ReminderSound sound) async => played.add(sound);
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('header, groups and current values', (tester) async {
    await pumpSettings(tester);
    for (final text in [
      'Settings',
      'Kody · on this device',
      'DAY SHAPE',
      '15 h awake',
      'Monday',
      '24 h',
      'PLANNING',
      '30 min',
      '5 min',
      'Ask each time',
      'REMINDERS',
      '10 min before',
      'At 22:00, with tomorrow\'s first task',
      'LOOK',
      'Like this device',
      'English',
      'DATA',
      'ABOUT',
      '0.1.0 (1)',
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }
    // Wake Up / Bedtime under the handles and on their rows.
    expect(find.text('07:00'), findsNWidgets(2));
    expect(find.text('22:00'), findsNWidgets(2));
  });

  testWidgets('switches write at once; the platform idiom draws them', (
    tester,
  ) async {
    final h = await pumpSettings(tester);
    expect(_cupertinoSwitches(), findsNWidgets(6));
    await _tapRow(tester, 'Show free time');
    expect((await storedSettings(h)).showFreeTime, isFalse);
    // F3.3: the plan-your-inbox nudge starts off.
    expect((await storedSettings(h)).inboxNudge, isFalse);
    await _tapRow(tester, 'Plan-your-inbox nudge');
    expect((await storedSettings(h)).inboxNudge, isTrue);
    await _tapRow(tester, 'Roll unfinished to tomorrow');
    expect((await storedSettings(h)).rollUnfinished, isTrue);
  });

  testWidgets('Android draws Material switches', (tester) async {
    await pumpSettings(tester, platform: TargetPlatform.android);
    expect(_cupertinoSwitches(), findsNothing);
    expect(find.byType(Switch), findsNWidgets(6));
  });

  testWidgets('choices: week start, time format, shift, snap, theme', (
    tester,
  ) async {
    final h = await pumpSettings(tester);
    Future<void> choose(String row, String option) async {
      await _tapRow(tester, row);
      await tester.tap(find.text(option).last);
      await tester.pumpAndSettle();
    }

    await choose('Week starts', 'Sunday');
    await choose('Time format', '12 h');
    await choose('Shift later tasks', 'Never');
    await choose('Snap to', '15 min');
    await choose('Theme', 'Dark');
    final s = await storedSettings(h);
    expect(s.firstDayOfWeek, 7);
    expect(s.use24h, isFalse);
    expect(s.shiftFollowers, ShiftFollowersPolicy.never);
    expect(s.snapMinutes, 15);
    expect(s.theme, ThemePreference.dark);
  });

  testWidgets('dismissing the time-format sheet changes nothing', (
    tester,
  ) async {
    final h = await pumpSettings(tester);
    await _tapRow(tester, 'Time format');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect((await storedSettings(h)).use24h, isTrue);
  });

  testWidgets('Task starts edits the default alert set (F6.2)', (tester) async {
    final h = await pumpSettings(tester);
    await _tapRow(tester, 'Task starts');
    await tester.tap(find.text('at start'));
    await tester.tap(find.text('at end'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect((await storedSettings(h)).defaultAlerts, [
      const Alert(kind: AlertKind.before, offsetMin: 10),
      const Alert(kind: AlertKind.atStart),
      const Alert(kind: AlertKind.atEnd),
    ]);
    expect(find.text('10 min before +2'), findsOneWidget);
    await _tapRow(tester, 'Task starts');
    for (final a in ['10 min before', 'at start', 'at end']) {
      await tester.tap(find.byTooltip('Remove $a'));
      await tester.pump();
    }
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect((await storedSettings(h)).defaultAlerts, isEmpty);
    expect(find.text('No alert'), findsOneWidget);
  });

  testWidgets('Quiet hours: on with the suggested window, then From', (
    tester,
  ) async {
    final h = await pumpSettings(tester);
    expect((await storedSettings(h)).quietHours, isNull);
    expect(find.text('From'), findsNothing);
    await _tapRow(tester, 'Quiet hours');
    expect((await storedSettings(h)).quietHours, Settings.suggestedQuietHours);
    expect(find.textContaining('22:00–07:00'), findsOneWidget);
    await _tapRow(tester, 'From');
    await tester.enterText(find.byType(TextField).last, '2330');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(
      (await storedSettings(h)).quietHours,
      const TimeWindow(start: '23:30', end: '07:00'),
    );
    await _tapRow(tester, 'Quiet hours');
    expect((await storedSettings(h)).quietHours, isNull);
  });

  testWidgets('Day-start summary: per weekday, off by default (F6.2)', (
    tester,
  ) async {
    final h = await pumpSettings(tester);
    expect(find.text('Off'), findsOneWidget);
    await _tapRow(tester, 'Day-start summary');
    await tester.tap(find.text('Monday').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Friday').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect((await storedSettings(h)).daySummaryDays, {
      Weekday.mon,
      Weekday.fri,
    });
    expect(find.text('Mon, Fri'), findsOneWidget);
  });

  testWidgets('Sound: a tap picks and plays it (F6.6)', (tester) async {
    final player = _FakePlayer();
    final h = await pumpSettings(
      tester,
      overrides: [soundPlayerProvider.overrideWithValue(player)],
    );
    expect(find.text('System sound'), findsOneWidget);
    await _tapRow(tester, 'Sound');
    await tester.tap(find.text('Chime'));
    await tester.pumpAndSettle();
    expect((await storedSettings(h)).reminderSound, 'chime');
    expect(player.played, [ReminderSound.chime]);
    await tester.tap(find.text('System sound').last);
    await tester.pumpAndSettle();
    expect((await storedSettings(h)).reminderSound, isNull);
    expect(player.played, [ReminderSound.chime], reason: 'nothing to play');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('System sound'), findsOneWidget);
  });

  testWidgets('Wake Up typed moves every weekday (R-20)', (tester) async {
    final h = await pumpSettings(tester);
    await _tapRow(tester, 'Wake Up');
    await tester.enterText(find.byType(TextField).last, '630');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    final s = await storedSettings(h);
    for (final d in Weekday.values) {
      expect(s.boundaryFor(d).start, '06:30');
    }
    expect(find.text('15 h 30 awake'), findsOneWidget);
  });

  testWidgets('slider: the screen reader steps a handle; a drag is one write', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final h = await pumpSettings(tester);
    tester.semantics.increase(find.semantics.byLabel('Wake Up'));
    await tester.pumpAndSettle();
    expect((await storedSettings(h)).boundaryFor(Weekday.mon).start, '07:15');
    final writes = h.container.read(writeUseCaseProvider) as FakeWriteUseCase;
    final before = writes.applied.length;
    await tester.drag(
      find
          .descendant(
            of: find.byType(DayShapeSlider),
            matching: find.byType(GestureDetector),
          )
          .first,
      const Offset(-80, 0),
    );
    await tester.pumpAndSettle();
    expect(writes.applied.length, before + 1);
    handle.dispose();
  });

  testWidgets('Different days: a custom Saturday shows on the row', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final h = await pumpSettings(tester);
    await _tapRow(tester, 'Different days');
    // The sheet's seven Bedtime handles, Monday first (week starts Monday).
    final bedtimes = find.semantics.byPredicate((n) => n.label == 'Bedtime');
    expect(bedtimes.evaluate(), hasLength(7));
    tester.semantics.increase(bedtimes.at(5));
    await tester.pumpAndSettle();
    final s = await storedSettings(h);
    expect(s.boundaryFor(Weekday.sat).end, '22:15');
    expect(s.boundaryFor(Weekday.mon).end, '22:00');
    expect(find.text('Same as every day'), findsOneWidget);
    await tester.tap(find.text('Same as every day'));
    await tester.pumpAndSettle();
    expect((await storedSettings(h)).boundaryFor(Weekday.sat).end, '22:00');
    handle.dispose();
  });

  testWidgets('accent swatch and language', (tester) async {
    final h = await pumpSettings(tester);
    final teal = find.bySemanticsLabel('Teal accent');
    await tester.ensureVisible(teal);
    await tester.tap(teal);
    await tester.pumpAndSettle();
    expect((await storedSettings(h)).accent, 'teal');
    await _tapRow(tester, 'Language');
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    expect((await storedProfile(h)).locale, 'en');
  });

  testWidgets('feedback: a mail draft, diagnostics only when opted in', (
    tester,
  ) async {
    final h = await pumpSettings(tester);
    await _tapRow(tester, 'Send feedback');
    expect(find.textContaining('Nothing your tasks say'), findsOneWidget);
    expect(find.textContaining('diagnostics.json'), findsNothing);
    await tester.tap(find.text('Write email'));
    await tester.pumpAndSettle();
    final plain = h.links.opened.single;
    expect(plain.scheme, 'mailto');
    expect(plain.query, contains('0.1.0'));
    expect(plain.query, isNot(contains('body')));
    await _tapRow(tester, 'Send feedback');
    await tester.tap(find.text('Add diagnostics'));
    await tester.pumpAndSettle();
    // Exactly what will be added, before anything leaves the device.
    expect(find.text('Added to the end of your email:'), findsOneWidget);
    expect(find.textContaining('"tasks": 12'), findsOneWidget);
    await expectA11yGuidelines(tester);
    await tester.tap(find.text('Write email'));
    await tester.pumpAndSettle();
    final body = Uri.decodeComponent(h.links.opened.last.query);
    expect(body, contains('--- diagnostics.json ---'));
    expect(body, contains('"device": "0a1b2c3d4e5f6071"'));
    expect(body, contains('"platform": "android"'));
  });

  testWidgets('feedback: unreadable diagnostics are named; the email goes', (
    tester,
  ) async {
    final h = await pumpSettings(tester, diagnostics: _FailingReader());
    await _tapRow(tester, 'Send feedback');
    await tester.tap(find.text('Add diagnostics'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining("Couldn't read the diagnostics"),
      findsOneWidget,
    );
    await tester.tap(find.text('Write email'));
    await tester.pumpAndSettle();
    expect(h.links.opened.single.query, isNot(contains('body')));
  });

  testWidgets('no mail app: says so', (tester) async {
    final h = await pumpSettings(tester);
    h.links.handled = false;
    await _tapRow(tester, 'Send feedback');
    await tester.tap(find.text('Write email'));
    await tester.pumpAndSettle();
    expect(find.text('No mail app is set up on this device.'), findsOneWidget);
  });

  testWidgets('Trash lists deleted tasks; Restore brings one back', (
    tester,
  ) async {
    final gone = Occurrence(
      id: '0199f0c0-0000-7000-8000-000000000001',
      userId: testUserId,
      title: 'Old plan',
      tzId: 'Europe/Berlin',
      durationMin: 30,
      createdAt: DateTime.utc(2026, 10),
      updatedAt: DateTime.utc(2026, 10),
      deletedAt: DateTime.utc(2026, 10, 20),
    );
    final h = await pumpSettings(tester, rows: [gone]);
    await _tapRow(tester, 'Trash');
    expect(find.text('Old plan'), findsOneWidget);
    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
    expect(h.occurrences.rows.single.deletedAt, isNull);
    expect(find.text('Old plan restored'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (name, size) in [
      ('compact', const Size(390, 2600)),
      ('expanded', const Size(1280, 2600)),
    ]) {
      testWidgets('a11y ${mode.name} $name', (tester) async {
        await pumpSettings(tester, size: size, mode: mode);
        await expectA11yGuidelines(tester);
      });
      testWidgets('a11y feedback + diagnostics ${mode.name} $name', (
        tester,
      ) async {
        await pumpSettings(tester, size: size, mode: mode);
        await _tapRow(tester, 'Send feedback');
        await tester.tap(find.text('Add diagnostics'));
        await tester.pumpAndSettle();
        await expectA11yGuidelines(tester);
      });
      testWidgets('a11y changelog ${mode.name} $name, 200 % text', (
        tester,
      ) async {
        await pumpSettings(
          tester,
          size: size,
          mode: mode,
          location: '/settings/changelog',
        );
        await expectA11yGuidelines(tester);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('200 % text: nothing overflows', (tester) async {
    await pumpSettings(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

/// A database read that fails.
final class _FailingReader implements DiagnosticsReader {
  @override
  Future<({DiagnosticCounts counts, String? deviceId})> read() =>
      Future.error(Exception('db'));
}
