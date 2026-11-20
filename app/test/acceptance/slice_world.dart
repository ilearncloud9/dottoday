import 'dart:async';

import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../domain/fixtures.dart';
import '../support/test_app.dart';
import '../support/timeline_fakes.dart';

/// The first slice's acceptance cases (docs/09 M19.7; playbook step 11):
/// Today in Full and Now in Minimal, each empty, dense, loading, failed,
/// with long titles and at 200 % text, at the three width classes.

/// The cases every screen of the slice is checked in.
enum SliceCase { empty, dense, loading, error, long, large }

/// The widths, each on the platform that lives there: an iPhone
/// (compact), an iPad in portrait (medium), the Mac (expanded).
enum SliceWidth {
  compact(Size(390, 844), TargetPlatform.iOS),
  medium(Size(820, 1180), TargetPlatform.iOS),
  expanded(Size(1280, 800), TargetPlatform.macOS);

  const SliceWidth(this.size, this.platform);
  final Size size;
  final TargetPlatform platform;
}

/// 9:42 on Tuesday 3 November 2026, UTC (10:42 in Berlin).
DateTime sliceAt(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);

Occurrence _task(
  String title,
  String color,
  String icon,
  int h,
  int m,
  int min,
) => occurrenceFixture().copyWith(
  id: '$title $h:$m', // l10n-ignore: test fixture id
  title: title,
  colorKey: color,
  iconKey: icon,
  startUtc: sliceAt(h, m),
  tzId: 'Europe/Berlin',
  durationMin: min,
  status: OccurrenceStatus.planned,
);

/// A full day: twelve tasks, two overlaps, one done (UTC hours).
List<Occurrence> denseDay() => [
  _task(
    'Run',
    'coral',
    'run',
    5,
    30,
    30,
  ).copyWith(status: OccurrenceStatus.done),
  _task('Standup', 'teal', 'call', 7, 0, 15),
  _task('Email', 'slate', 'mail', 7, 30, 30),
  _task('Deep work: roadmap', 'indigo', 'focus_block', 8, 30, 120),
  _task('Call with Sam', 'teal', 'call', 9, 30, 30),
  _task('Lunch', 'rose', 'meal', 11, 0, 45),
  _task('Review', 'violet', 'focus_block', 12, 0, 60),
  _task('Dentist', 'slate', 'call', 13, 30, 30),
  _task('Pick up parcel', 'olive', 'call', 14, 30, 15),
  _task('Gym', 'violet', 'focus_block', 16, 0, 60),
  _task('Dinner', 'rose', 'meal', 18, 0, 60),
  _task('Read', 'brown', 'meal', 20, 0, 30),
];

/// Three tasks whose titles run long, one of them on now.
List<Occurrence> longDay() => [
  _task(
    'Finish the quarterly roadmap review with the design and engineering leads before Friday', // l10n-ignore: test data
    'indigo',
    'focus_block',
    9,
    0,
    120,
  ),
  _task(
    'Call the dentist about moving Thursday’s appointment to next week', // l10n-ignore: test data
    'teal',
    'call',
    11,
    30,
    30,
  ),
  _task(
    'Pick up the parcel from the post office on Hauptstraße', // l10n-ignore: test data
    'olive',
    'call',
    15,
    0,
    15,
  ),
];

/// Today (Full) or Now (Minimal) in [c] at [w]'s size; returns once
/// drawn. The test sets [w]'s platform (`TargetPlatformVariant`).
Future<void> pumpSlice(
  WidgetTester tester, {
  required bool minimal,
  required SliceCase c,
  required SliceWidth w,
  ThemeMode mode = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = w.size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  if (c == SliceCase.large) {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  final router = buildRouter(appScreens);
  addTearDown(router.dispose);
  final rows = switch (c) {
    SliceCase.empty || SliceCase.loading || SliceCase.error => <Occurrence>[],
    SliceCase.dense || SliceCase.large => denseDay(),
    SliceCase.long => longDay(),
  };
  await tester.pumpWidget(
    testRouterApp(
      router,
      themeMode: mode,
      overrides: [
        ...timelineOverrides(
          now: sliceAt(9, 42),
          occurrences: FakeOccurrenceRepository(rows),
          profile: testProfile(
            settings: Settings(
              uiLayout: minimal ? UiLayout.minimal : UiLayout.full,
              use24h: false,
            ),
          ),
        ),
        siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
        if (c == SliceCase.loading)
          currentProfileProvider.overrideWith(
            (ref) => Stream.fromFuture(Completer<Profile>().future),
          ),
        if (c == SliceCase.error)
          currentProfileProvider.overrideWith(
            (ref) => Stream.error(const StorageFailure()),
          ),
      ],
    ),
  );
  if (c == SliceCase.loading) {
    await tester.pump(const Duration(milliseconds: 400));
  } else {
    await tester.pumpAndSettle();
  }
}
