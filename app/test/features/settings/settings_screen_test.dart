import 'package:dottoday/data/feedback/diagnostics_reader.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/sound/sound_player.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/feedback/feedback_diagnostics.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';
import 'settings_harness.dart';

/// Switch.adaptive draws a Cupertino switch on iPhone (§4 switch idiom).
Finder _cupertinoSwitches() => find.byType(CupertinoSwitch);

final class _FakePlayer implements SoundPlayer {
  final played = <CatalogueSound>[];

  @override
  Future<void> play(CatalogueSound sound) async => played.add(sound);

  @override
  Future<void> stop() async {}

  /// What [deviceMuted] answers.
  bool muted = false;

  @override
  Future<bool> deviceMuted() async => muted;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('root: Your account, Search settings, six groups', (
    tester,
  ) async {
    await pumpSettings(tester);
    for (final text in [
      'Settings',
      'Your account',
      'Kody · on this device',
      'Search settings',
      'Your day',
      'Planning',
      'Reminders',
      'Appearance',
      'Data and privacy',
      'Help and about',
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }
    // Rows live on their groups' pages now (M20.7 part 1).
    expect(find.text('Day shape'), findsNothing);
  });

  testWidgets('each group page shows its rows and values', (tester) async {
    final h = await pumpSettings(tester);
    for (final (row, values) in [
      (
        'Wake Up',
        [
          'Every day',
          '07:00',
          '22:00',
          '9 h of night',
          "At Wind Down, with tomorrow's first task",
        ],
      ),
      ('Snap to', ['30 min', '5 min', 'Ask each time']),
      ('Task starts', ['10 min before']),
      ('Theme', ['Auto', 'English', 'Monday', '24 h']),
      ('Trash', ['Data', 'Privacy', 'Help with thinking']),
      ('Send feedback', ['0.1.0 (1)']),
    ]) {
      await openSettingPage(tester, h, row);
      for (final text in [row, ...values]) {
        await tester.scrollUntilVisible(
          find.text(text).first,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(text), findsWidgets, reason: text);
      }
    }
  });

  testWidgets('switches write at once; the platform idiom draws them', (
    tester,
  ) async {
    final h = await pumpSettings(tester);
    // Off for an existing profile, so an upgrade rings nothing new (15 §11).
    expect((await storedSettings(h)).wakeUpAlarm, isFalse);
    await tapSettingRow(tester, h, 'Ring like an alarm');
    expect((await storedSettings(h)).wakeUpAlarm, isTrue);
    expect(_cupertinoSwitches(), findsWidgets);
    await tapSettingRow(tester, h, 'Show free time');
    expect((await storedSettings(h)).showFreeTime, isFalse);
    // F3.3: the plan-your-inbox nudge starts off.
    expect((await storedSettings(h)).inboxNudge, isFalse);
    await tapSettingRow(tester, h, 'Plan-your-inbox nudge');
    expect((await storedSettings(h)).inboxNudge, isTrue);
    await tapSettingRow(tester, h, 'Roll unfinished to tomorrow');
    expect((await storedSettings(h)).rollUnfinished, isTrue);
  });

  testWidgets('Android draws Material switches', (tester) async {
    await pumpSettings(
      tester,
      platform: TargetPlatform.android,
      location: '/settings/planning',
    );
    expect(_cupertinoSwitches(), findsNothing);
    expect(find.byType(Switch), findsWidgets);
  });

  testWidgets('choices: week start, time format, shift, snap, theme', (
    tester,
  ) async {
    final h = await pumpSettings(tester);
    Future<void> choose(String row, String option) async {
      await tapSettingRow(tester, h, row);
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
    await tapSettingRow(tester, h, 'Time format');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect((await storedSettings(h)).use24h, isTrue);
  });

  testWidgets('Task starts edits the default alert set (F6.2)', (tester) async {
    final h = await pumpSettings(tester);
    await tapSettingRow(tester, h, 'Task starts');
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
    await tapSettingRow(tester, h, 'Task starts');
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
    await tapSettingRow(tester, h, 'Quiet hours');
    expect((await storedSettings(h)).quietHours, Settings.suggestedQuietHours);
    expect(find.textContaining('22:00–07:00'), findsOneWidget);
    await tapSettingRow(tester, h, 'From');
    await tester.enterText(find.byType(TextField).last, '2330');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(
      (await storedSettings(h)).quietHours,
      const TimeWindow(start: '23:30', end: '07:00'),
    );
    await tapSettingRow(tester, h, 'Quiet hours');
    expect((await storedSettings(h)).quietHours, isNull);
  });

  testWidgets('Day-start summary: per weekday, off by default (F6.2)', (
    tester,
  ) async {
    final h = await pumpSettings(tester);
    // The summary's; Day shape's sleep target is on its own page now.
    await openSettingPage(tester, h, 'Day-start summary');
    expect(find.text('Off'), findsOneWidget);
    await tapSettingRow(tester, h, 'Day-start summary');
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
    // docs/12 §3: unset is the Dot tone; the OS sound is "system".
    await openSettingPage(tester, h, 'Sound');
    expect(find.text('Dot'), findsOneWidget);
    await tapSettingRow(tester, h, 'Sound');
    // Its own page now (docs/12 §6).
    expect(find.text('Sounds'), findsOneWidget);
    await tester.tap(find.text('Chime'));
    await tester.pumpAndSettle();
    expect((await storedSettings(h)).reminderSound, 'chime');
    expect(player.played, [resolveSound('chime')]);
    await tester.tap(find.text('System sound'));
    await tester.pumpAndSettle();
    expect((await storedSettings(h)).reminderSound, 'system');
    expect(player.played, [resolveSound('chime')], reason: 'nothing to play');
    await tester.tap(settingsBack('Reminders'));
    await tester.pumpAndSettle();
    expect(find.text('System sound'), findsOneWidget);
  });

  testWidgets('App colour, Theme and language (ED-161, ED-221)', (
    tester,
  ) async {
    final h = await pumpSettings(tester, location: '/settings/appearance');
    // A warm suggestion: its hex, and the nearest built-in accent beside
    // it for older apps.
    final blush = find.bySemanticsLabel('Blush');
    await tester.ensureVisible(blush);
    await tester.tap(blush);
    await tester.pumpAndSettle();
    expect((await storedProfile(h)).accentHex, '#E9958E');
    expect((await storedSettings(h)).accent, 'coral');
    // Teal, the default, clears the hex.
    final teal = find.bySemanticsLabel('Teal');
    await tester.ensureVisible(teal);
    await tester.tap(teal);
    await tester.pumpAndSettle();
    expect((await storedProfile(h)).accentHex, isNull);
    expect((await storedSettings(h)).accent, 'teal');
    // Theme: the Dark thumbnail.
    await tester.ensureVisible(find.text('Dark'));
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect((await storedSettings(h)).theme, ThemePreference.dark);
    await tapSettingRow(tester, h, 'Language');
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    expect((await storedProfile(h)).locale, 'en');
  });

  testWidgets('feedback: a mail draft, diagnostics only when opted in', (
    tester,
  ) async {
    final h = await pumpSettings(tester);
    await tapSettingRow(tester, h, 'Send feedback');
    expect(find.textContaining('Nothing your tasks say'), findsOneWidget);
    expect(find.textContaining('diagnostics.json'), findsNothing);
    await tester.tap(find.text('Write email'));
    await tester.pumpAndSettle();
    final plain = h.links.opened.single;
    expect(plain.scheme, 'mailto');
    expect(plain.query, contains('0.1.0'));
    expect(plain.query, isNot(contains('body')));
    await tapSettingRow(tester, h, 'Send feedback');
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
    await tapSettingRow(tester, h, 'Send feedback');
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
    await tapSettingRow(tester, h, 'Send feedback');
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
    await tapSettingRow(tester, h, 'Trash');
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
        final h = await pumpSettings(tester, size: size, mode: mode);
        await tapSettingRow(tester, h, 'Send feedback');
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
