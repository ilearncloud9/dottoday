import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_title_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

/// 11:00 in Berlin, Wednesday 21 October 2026 (the demo day).
final addNow = DateTime.utc(2026, 10, 21, 9);

/// The demo day's timed tasks (Gym 17:30, Lunch 12:30 pinned, …).
List<Occurrence> demoTimed() => [
  for (final o in demoDayRows(DateTime(2026, 10, 21)))
    if (o.startUtc != null) o,
];

Finder get addTitle => find.descendant(
  of: find.byType(AddTitleField),
  matching: find.byType(TextField),
);

/// Opens Add from a plain host at [size] in [mode] over [rows]; returns
/// the repository the sheet writes to.
Future<FakeOccurrenceRepository> pumpAddHost(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  ThemeMode mode = ThemeMode.light,
  double textScale = 1,
  List<Occurrence>? rows,
  String text = '',
  DateTime? startUtc,
  DateTime? day,
  WriteFault? writeFault,
  List<Routine> routines = const [],
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeOccurrenceRepository(rows ?? demoTimed());
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: addNow,
        occurrences: repo,
        profile: testProfile(settings: const Settings(use24h: false)),
        writeFault: writeFault,
        routines: routines,
      ),
      child: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: testApp(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showAddFlow(
                    context,
                    text: text,
                    startUtc: startUtc,
                    day: day,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
          themeMode: mode,
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return repo;
}

/// The row Add wrote with [title] (created on the test day).
Occurrence? addedRow(FakeOccurrenceRepository repo, String title) => repo.rows
    .where(
      (o) =>
          o.title == title && o.createdAt.isAfter(DateTime.utc(2026, 10, 21)),
    )
    .firstOrNull;
