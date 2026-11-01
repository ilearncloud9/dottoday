// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/mission_progress.dart';
import 'package:dottoday/features/timeline/wake_up/mission/mission_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/dot_golden.dart';
import '../../../support/timeline_fakes.dart';
import '../../../support/today_harness.dart';

// The mission screen (derived — docs/15 §8; no reference render): the
// ring, one line, the mission and "Can't right now"; the same in minimal
// mode.

const _date = '2026-10-21';

List<Override> _overrides(
  FakeMissionSensors sensors, {
  UiLayout layout = UiLayout.full,
}) => timelineOverrides(
  now: todayTestNow,
  occurrences: FakeOccurrenceRepository(demoDayRows(todayTestDate)),
  profile: testProfile(
    settings: Settings(
      wakeUpAlarm: true,
      missionMode: MissionMode.always,
      uiLayout: layout,
    ),
  ),
  missionSensors: sensors,
);

/// Pushes [reading] and lets the screen show it.
Future<void> Function(WidgetTester) _show(
  FakeMissionSensors sensors,
  SensorReading reading,
) => (tester) async {
  sensors.push(reading);
  await tester.pump();
};

/// Catch the dot drifts forever; with reduced motion it holds still.
Widget _still(Widget child) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child,
  ),
);

void main() {
  tz_data.initializeTimeZones();
  setUpAll(loadAppFonts);
  final walk = FakeMissionSensors();
  goldenMatrix(
    'mission_walk',
    height: 800,
    a11yVariants: true,
    overrides: _overrides(walk),
    act: _show(walk, const StepsReading(Duration(seconds: 4), 7)),
    build: (_) => const MissionScreen(date: _date, kind: MissionKind.walk),
  );
  final minimal = FakeMissionSensors();
  goldenMatrix(
    'mission_walk_minimal',
    height: 800,
    widths: const {'compact'},
    overrides: _overrides(minimal, layout: UiLayout.minimal),
    act: _show(minimal, const StepsReading(Duration(seconds: 4), 7)),
    build: (_) => const MissionScreen(date: _date, kind: MissionKind.walk),
  );
  final light = FakeMissionSensors();
  goldenMatrix(
    'mission_light',
    height: 800,
    widths: const {'compact'},
    overrides: _overrides(light),
    act: _show(light, const LuxReading(Duration.zero, 40)),
    build: (_) => const MissionScreen(date: _date, kind: MissionKind.light),
  );
  final up = FakeMissionSensors();
  goldenMatrix(
    'mission_stand_up',
    height: 800,
    widths: const {'compact'},
    overrides: _overrides(up),
    build: (_) => const MissionScreen(date: _date, kind: MissionKind.standUp),
  );
  goldenMatrix(
    'mission_breathe',
    height: 800,
    widths: const {'compact'},
    overrides: _overrides(FakeMissionSensors()),
    build: (_) => const MissionScreen(date: _date, kind: MissionKind.breathe),
  );
  goldenMatrix(
    'mission_catch_dot',
    height: 800,
    widths: const {'compact'},
    overrides: _overrides(FakeMissionSensors()),
    build: (_) => _still(
      const MissionScreen(date: _date, kind: MissionKind.catchDot),
    ),
  );
}
