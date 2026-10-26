import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/focus/deep_work.dart';
import 'package:dottoday/domain/notifications/reminder_sound.dart';
import 'package:dottoday/features/focus/focus_view.dart';
import 'package:dottoday/shared/dot/focus_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/focus_fakes.dart';
import '../../support/timeline_fakes.dart';

// Focus (11 A3, `B-ios-focus`, docs/09 M10.5): what it shows, that opening
// it is a start, Done / +15 / Next step, the step timer, the chime, Deep
// work per platform, and reduced motion.

final _date = DateTime(2026, 10, 21);
// 9:40:40 Berlin: Deep work runs 9:00 – 11:00.
final _now = DateTime.utc(2026, 10, 21, 7, 40, 40);

late FakeOccurrenceRepository _repo;
late FakeSubtaskRepository _subs;
late Occurrence _deep;

/// Deep work's steps with lengths; the first ticked at 9:25 (as Break it
/// down's accepted steps would be).
List<Subtask> _steps() {
  final all = demoDaySubtasks(_date);
  final mine = [
    for (final s in all)
      if (s.occurrenceId == _deep.id) s,
  ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return [
    for (final s in all)
      if (s.occurrenceId != _deep.id) s,
    mine[0].copyWith(
      done: true,
      durationMin: 25,
      doneAt: DateTime.utc(2026, 10, 21, 7, 25),
    ),
    mine[1].copyWith(done: false, durationMin: 30),
    mine[2].copyWith(done: false, durationMin: 20),
  ];
}

Future<({FakeDeepWork deepWork, FakeSoundPlayer sounds, List<int> left})> _pump(
  WidgetTester tester, {
  DeepWorkKind kind = DeepWorkKind.dnd,
  bool granted = true,
  bool reduceMotion = false,
  double width = 390,
}) async {
  tester.view
    ..physicalSize = Size(width, 1500)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final rows = demoDayRows(_date);
  _deep = rows.firstWhere((o) => o.title == 'Deep work: roadmap');
  _repo = FakeOccurrenceRepository(rows);
  _subs = FakeSubtaskRepository(_steps());
  final deepWork = FakeDeepWork(kind: kind, granted: granted);
  final sounds = FakeSoundPlayer();
  final left = <int>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...timelineOverrides(
          now: _now,
          occurrences: _repo,
          subtasks: _subs,
          profile: testProfile(settings: const Settings(use24h: false)),
        ),
        ...focusOverrides(deepWork: deepWork, sounds: sounds),
      ],
      child: MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
        home: Scaffold(
          body: FocusView(id: _deep.id, onLeave: () => left.add(1)),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  // The periodic step timer would outlive the test.
  addTearDown(() => tester.pumpWidget(const SizedBox()));
  return (deepWork: deepWork, sounds: sounds, left: left);
}

Occurrence _task() => _repo.rows.firstWhere((o) => o.id == _deep.id);

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.tap(f);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the render: ring, time, title, left, step 2 of 3 with 14:20', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('FOCUS'), findsOneWidget);
    expect(find.byType(FocusRing), findsOneWidget);
    expect(find.text('9:00 AM – 11:00 AM · 2 h'), findsOneWidget);
    expect(find.text('Deep work: roadmap'), findsOneWidget);
    expect(find.text('80 min left'), findsOneWidget);
    expect(find.text('STEP 2 OF 3'), findsOneWidget);
    expect(find.text('14:20 left'), findsOneWidget);
    expect(
      find.text('Dot starts still break through Focus (time-sensitive)'),
      findsOneWidget,
    );
    await expectA11yGuidelines(tester);
  });

  testWidgets('opening Focus marks the dot started, once', (tester) async {
    await _pump(tester);
    expect(_task().actualStartUtc, isNotNull);
  });

  testWidgets('Next step ticks the current step; the next one is current', (
    tester,
  ) async {
    await _pump(tester);
    final current = _subs.rows.firstWhere(
      (s) => s.occurrenceId == _deep.id && !s.done,
    );
    await _tap(tester, find.text('Next step'));
    final ticked = _subs.rows.firstWhere((s) => s.id == current.id);
    expect((ticked.done, ticked.doneAt), (true, _now));
    expect(find.text('STEP 3 OF 3'), findsOneWidget);
  });

  testWidgets('+15 min lengthens it; Done ticks it, leaves, ends deep work', (
    tester,
  ) async {
    final h = await _pump(tester);
    await _tap(tester, find.text('+15 min'));
    expect(_task().durationMin, 135);
    await _tap(tester, find.byType(Switch).last);
    expect(h.deepWork.on, isTrue);
    await _tap(tester, find.text('Done'));
    expect(_task().status, OccurrenceStatus.done);
    expect(h.left, [1]);
    expect(h.deepWork.on, isFalse);
  });

  testWidgets('the chime sounds every 15 min once on, and stops', (
    tester,
  ) async {
    final h = await _pump(tester);
    await _tap(tester, find.byType(Switch).first);
    await tester.pump(const Duration(minutes: 15));
    await tester.pump(const Duration(minutes: 15));
    expect(h.sounds.played, [ReminderSound.chime, ReminderSound.chime]);
    await _tap(tester, find.byType(Switch).first);
    await tester.pump(const Duration(minutes: 15));
    expect(h.sounds.played, hasLength(2));
  });

  testWidgets('Android deep work: until the planned end; asks for access', (
    tester,
  ) async {
    final h = await _pump(tester);
    expect(find.text('Allow Dottoday to turn on Do Not Disturb'), findsNothing);
    await _tap(tester, find.byType(Switch).last);
    expect(h.deepWork.until, _task().endUtc);
    final denied = await _pump(tester, granted: false);
    expect(
      find.text('Allow Dottoday to turn on Do Not Disturb'),
      findsOneWidget,
    );
    await _tap(tester, find.byType(Switch).last);
    expect((denied.deepWork.on, denied.deepWork.settingsOpened), (false, 1));
  });

  testWidgets('iPhone and Mac: deep work explains the Shortcuts way', (
    tester,
  ) async {
    final h = await _pump(tester, kind: DeepWorkKind.shortcuts);
    await _tap(tester, find.byType(Switch).last);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Turn on Focus with Shortcuts'), findsOneWidget);
    await _tap(tester, find.text('Open Shortcuts'));
    expect(h.deepWork.settingsOpened, 1);
  });

  testWidgets('the web: deep work says to use the computer, no switch', (
    tester,
  ) async {
    await _pump(tester, kind: DeepWorkKind.none);
    expect(find.byType(Switch), findsOneWidget, reason: 'only the chime');
    expect(
      find.text(
        "Use your computer's Do Not Disturb; the browser can't change it",
      ),
      findsOneWidget,
    );
  });

  testWidgets('reduced motion: the ring jumps, no animation', (tester) async {
    await _pump(tester, reduceMotion: true);
    final tween = tester.widget<TweenAnimationBuilder<double>>(
      find.descendant(
        of: find.byType(FocusRing),
        matching: find.byType(TweenAnimationBuilder<double>),
      ),
    );
    expect(tween.duration, Duration.zero);
  });
}
