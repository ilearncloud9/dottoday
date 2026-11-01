import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:dottoday/features/timeline/widgets/day_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/test_l10n.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// docs/15 §8 rule 5 (M17.7c): "Make sure I'm up" in the Wind Down review
// (tomorrow, one morning) and the task sheet (this dot's morning); both
// hidden while missions are off.

const _asked = Settings(use24h: false, missionMode: MissionMode.whenAsked);

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  Settings settings = _asked,
  List<Occurrence>? rows,
}) async {
  tester.view
    ..physicalSize = const Size(390, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: todayTestNow,
        occurrences: FakeOccurrenceRepository(
          rows ?? demoDayRows(todayTestDate),
        ),
        profile: testProfile(settings: settings),
      ),
      child: MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: testL10nDelegates,
        supportedLocales: testL10nLocales,
        locale: testL10nLocale,
        home: home is TaskScreen
            ? home
            : Scaffold(body: SingleChildScrollView(child: home)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<Settings> _stored(WidgetTester tester) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(Scaffold).first),
  );
  final p = await container.read(settingsRepositoryProvider).findLocalProfile();
  return p!.settings;
}

Occurrence _later() =>
    demoDayRows(todayTestDate).firstWhere((o) => o.title == 'Design review');

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('the Wind Down review', () {
    testWidgets('flags tomorrow, off by default; off again clears it', (
      tester,
    ) async {
      await _pump(tester, DayReviewBody(day: todayTestDate));
      final toggle = find.text("Tomorrow matters: make sure I'm up");
      expect(toggle, findsOneWidget);
      expect((await _stored(tester)).missionFlagDate, isNull);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect((await _stored(tester)).missionFlagDate, '2026-10-22');
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect((await _stored(tester)).missionFlagDate, isNull);
    });

    testWidgets('nothing to pick tomorrow: says Breathe is used instead', (
      tester,
    ) async {
      await _pump(
        tester,
        DayReviewBody(day: todayTestDate),
        settings: _asked.copyWith(
          missionKind: MissionKind.oneThing,
          missionFlagDate: '2026-10-22',
        ),
      );
      expect(
        find.text(
          'Tomorrow has nothing to pick from yet; Breathe will be used '
          'instead.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('hidden while missions are off', (tester) async {
      await _pump(
        tester,
        DayReviewBody(day: todayTestDate),
        settings: const Settings(use24h: false),
      );
      expect(find.text("Tomorrow matters: make sure I'm up"), findsNothing);
    });
  });

  group('the task sheet', () {
    testWidgets("flags this dot's morning", (tester) async {
      final dot = _later();
      await _pump(tester, TaskScreen(id: dot.id));
      final row = find.text("Make sure I'm up for this");
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect((await _stored(tester)).missionFlagIds, [dot.id]);
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect((await _stored(tester)).missionFlagIds, isEmpty);
    });

    testWidgets('not for a dot that has begun, nor with missions off', (
      tester,
    ) async {
      final begun = demoDayRows(
        todayTestDate,
      ).firstWhere((o) => o.title == 'Deep work: roadmap');
      await _pump(tester, TaskScreen(id: begun.id));
      expect(find.text("Make sure I'm up for this"), findsNothing);
      await _pump(
        tester,
        TaskScreen(id: _later().id),
        settings: const Settings(use24h: false),
      );
      expect(find.text("Make sure I'm up for this"), findsNothing);
    });
  });
}
