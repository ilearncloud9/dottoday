import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/scheduling/learning_meta.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/devices/device.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/shared/navigation/native_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../acceptance/slice_world.dart';
import '../../../domain/fixtures.dart';
import '../../../support/memory_database.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The Calendar tab's world (docs/09 M20.1; E-Phones Calendar, E-R2-12):
/// November 2026 on 3 Nov at 10:42 in Berlin, with tasks across the
/// month as the boards draw it (dots, "+n", a done morning run and the
/// live Deep work today).

Occurrence _on(
  int day,
  String title,
  String color,
  String icon,
  int h, {
  int m = 0,
  int min = 30,
  bool done = false,
}) => occurrenceFixture().copyWith(
  id: 'cal $day $title', // l10n-ignore: test fixture id
  title: title,
  colorKey: color,
  iconKey: icon,
  startUtc: DateTime.utc(2026, 11, day, h, m),
  tzId: 'Europe/Berlin',
  durationMin: min,
  status: done ? OccurrenceStatus.done : OccurrenceStatus.planned,
);

/// 23 tasks over November; today (the 3rd) holds nine.
List<Occurrence> calendarMonth() => [
  _on(1, 'Market', 'coral', 'meal', 9),
  _on(1, 'Call Mum', 'teal', 'call', 16),
  for (final (i, (t, c, ic)) in [
    ('Run', 'coral', 'run'),
    ('Email', 'slate', 'mail'),
    ('Gym', 'violet', 'focus_block'),
    ('Review', 'indigo', 'focus_block'),
    ('Dinner', 'rose', 'meal'),
  ].indexed)
    _on(2, t, c, ic, 7 + 2 * i, done: true),
  _on(3, 'Morning run', 'coral', 'run', 5, m: 45, min: 45, done: true),
  _on(3, 'Standup', 'teal', 'call', 7, done: true),
  _on(3, 'Email', 'slate', 'mail', 7, m: 30, done: true),
  _on(3, 'Deep work: roadmap', 'indigo', 'focus_block', 8, min: 120),
  _on(3, 'Call with Sam', 'teal', 'call', 10, m: 30),
  _on(3, 'Lunch', 'rose', 'meal', 11, m: 30, min: 45),
  _on(3, 'Dentist', 'slate', 'call', 13),
  _on(3, 'Pick up parcel', 'olive', 'call', 14),
  _on(3, 'Gym', 'violet', 'focus_block', 17),
  _on(5, 'Haircut', 'brown', 'call', 10),
  _on(5, 'Book club', 'plum', 'meal', 18),
  _on(9, 'Dentist check-up', 'slate', 'call', 15),
  _on(12, 'Weekly reset', 'violet', 'focus_block', 9),
  _on(19, 'Birthday dinner', 'rose', 'meal', 18),
  _on(26, 'Flight', 'teal', 'call', 6),
];

/// A year behind November: in each earlier month a different number of
/// days with one task, mostly done, so the year strip has something to
/// fill (E-R2-34 option B).
List<Occurrence> pastYear() => [
  for (var back = 1; back <= 11; back++)
    for (var d = 1; d <= 28; d += 1 + back % 4)
      occurrenceFixture().copyWith(
        id: 'year $back $d', // l10n-ignore: test fixture id
        title: 'Run',
        colorKey: 'coral',
        iconKey: 'run',
        startUtc: DateTime.utc(2026, 11 - back, d, 6),
        tzId: 'Europe/Berlin',
        durationMin: 30,
        status: d % 5 == 0 ? OccurrenceStatus.planned : OccurrenceStatus.done,
      ),
];

/// The app at [size] on its platform (the test's variant), opened on the
/// Calendar's month, in Full, at [now] (10:42 in Berlin unless given). A
/// device run passes no [size]: its own.
Future<GoRouter> pumpCalendar(
  WidgetTester tester, {
  Size? size,
  ThemeMode mode = ThemeMode.light,
  List<Occurrence>? rows,
  double text = 1,
  UiLayout layout = UiLayout.full,
  List<Routine> routines = const [],
  DateTime? lowEnergyUntil,
  List<Subtask> subtasks = const [],
  LearningMetaState learningMeta = const LearningMetaState(),
  DateTime? now,
  Settings Function(Settings)? settings,
  List<Device> devices = const [],
  AlarmCapabilities wakeUpAlarm = const AlarmCapabilities(AlarmTier.alarm),
  List<Override> extra = const [],
}) async {
  if (size != null) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }
  if (text != 1) {
    tester.platformDispatcher.textScaleFactorTestValue = text;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  // As bootstrap builds it: the iPhone's native row fades under sheets.
  final router = buildRouter(appScreens, observers: [NativeBarObserver()]);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    testRouterApp(
      router,
      themeMode: mode,
      overrides: [
        ...timelineOverrides(
          now: now ?? sliceAt(9, 42),
          occurrences: FakeOccurrenceRepository(
            rows ?? [...calendarMonth(), ...pastYear()],
          ),
          profile: testProfile(
            settings: (settings ?? (s) => s)(
              Settings(
                use24h: false,
                uiLayout: layout,
                lowEnergyUntil: lowEnergyUntil,
              ),
            ),
          ),
          devices: devices,
          wakeUpAlarm: wakeUpAlarm,
          routines: routines,
          subtasks: FakeSubtaskRepository(subtasks),
          learningMeta: learningMeta,
        ),
        siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
        // Settings › Privacy reads it (M8.6); bootstrap() sets it in the app.
        envProvider.overrideWithValue(
          Env(
            supabaseUrl: Uri.parse('https://example.supabase.co'),
            supabaseAnonKey: 'anon',
          ),
        ),
        // Never the person's own database on a device or the Mac.
        ...memoryDatabaseOverrides(),
        ...extra,
      ],
    ),
  );
  await tester.pumpAndSettle();
  router.go(AppRoutes.month);
  await tester.pumpAndSettle();
  return router;
}
