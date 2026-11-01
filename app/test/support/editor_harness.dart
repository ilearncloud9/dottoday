import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/editor/task_editor.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'calendar_series_fakes.dart';
import 'test_l10n.dart';

import 'timeline_fakes.dart';

/// Opens the task page for [id] and its editor (Edit), over [repo] and
/// [series], at 09:22 in Berlin on Wed 21 Oct 2026. Returns the container
/// (for the fake repositories).
Future<ProviderContainer> pumpEditor(
  WidgetTester tester, {
  required String id,
  required FakeOccurrenceRepository repo,
  List<Series> series = const [],
  FakeSubtaskRepository? subtasks,
  FakeCalendarSeriesRepository? calendarSeries,
}) async {
  tester.view
    ..physicalSize = const Size(390, 2400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: timelineOverrides(
      now: DateTime.utc(2026, 10, 21, 7, 22),
      occurrences: repo,
      subtasks: subtasks,
      series: series,
      calendarSeries: calendarSeries,
      profile: testProfile(settings: const Settings(use24h: false)),
    ),
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: testL10nDelegates,
        supportedLocales: testL10nLocales,
        locale: testL10nLocale,
        home: TaskScreen(id: id),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Edit'));
  await tester.pumpAndSettle();
  return container;
}

/// [f] inside the open editor.
Finder inEditor(Finder f) =>
    find.descendant(of: find.byType(TaskEditor), matching: f);

/// The fake series store behind [container].
FakeSeriesRepository seriesStore(ProviderContainer container) =>
    container.read(seriesRepositoryProvider) as FakeSeriesRepository;
