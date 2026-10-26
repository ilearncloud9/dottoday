import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/scheduling/learning_meta.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_l10n.dart';
import 'timeline_fakes.dart';

/// The demo day the Today tests run on.
final todayTestDate = DateTime(2026, 10, 21);

/// 09:22 in Berlin: Deep work (9:00–11:00) is live.
final todayTestNow = DateTime.utc(2026, 10, 21, 7, 22);

/// Pumps [TodayScreen] on the demo day at [todayTestNow], 1 px per pt.
Future<void> pumpToday(
  WidgetTester tester, {
  List<Occurrence>? rows,
  FakeOccurrenceRepository? repo,
  Size size = const Size(390, 844),
  ThemeMode mode = ThemeMode.light,
  DateTime? date,
  String? name = 'Kody',
  int firstDayOfWeek = 7,
  Settings? settings,
  Stream<DateTime>? ticks,
  ValueChanged<AddTaskIntent>? onAddTask,
  Widget Function(Widget today)? wrap,
  Set<String> readOnlyCalendarIds = const {},
  LearningMetaState learningMeta = const LearningMetaState(),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final profile = testProfile(
    settings:
        settings ?? Settings(use24h: false, firstDayOfWeek: firstDayOfWeek),
  ).copyWith(displayName: name);
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        readOnlyCalendarIds: readOnlyCalendarIds,
        now: todayTestNow,
        occurrences:
            repo ??
            FakeOccurrenceRepository(rows ?? demoDayRows(todayTestDate)),
        profile: profile,
        minuteTicks: ticks,
        learningMeta: learningMeta,
      ),
      child: MaterialApp(
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: testL10nDelegates,
        supportedLocales: testL10nLocales,
        locale: testL10nLocale,
        // The app root handles AddTaskIntent (M3c.5); tests may listen.
        builder: (context, child) => Actions(
          actions: {
            AddTaskIntent: CallbackAction<AddTaskIntent>(
              onInvoke: (i) => onAddTask?.call(i),
            ),
          },
          child: child!,
        ),
        home: (wrap ?? (w) => w)(TodayScreen(date: date)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
