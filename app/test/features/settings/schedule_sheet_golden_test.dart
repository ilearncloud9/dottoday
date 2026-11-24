// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';

// The schedule sheet (M20.7 part 4b) beside E-Phones (ED-084): iPhone
// Edit Weekdays (and its lower half, large text), Weekend with Wind Down
// after midnight, New schedule with its check, Android Edit Weekdays, and
// the alarm off (owner 2026-11-24: Ring on these days dimmed).

const _weekdays = {
  Weekday.mon,
  Weekday.tue,
  Weekday.wed,
  Weekday.thu,
  Weekday.fri,
};

Settings _week({bool alarm = true}) => Settings(
  use24h: false,
  wakeUpAlarm: alarm,
  wakeUpSoundId: 'start.dawn_chorus',
  sleepTargetMin: 8 * 60,
  wakeUpAlarmDays: _weekdays,
  dayBoundaries: {
    for (final d in Weekday.values)
      d: _weekdays.contains(d)
          ? const TimeWindow(start: '06:30', end: '23:00')
          : const TimeWindow(start: '08:30', end: '24:30'),
  },
);

List<Override> _overrides(Settings s) => timelineOverrides(
  now: DateTime.utc(2026, 10, 21, 9),
  profile: testProfile(settings: s),
);

Widget _sheet(Settings s, Set<Weekday> days) => Builder(
  builder: (context) => Material(
    color: DotTheme.of(context).colors.sheet,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: DotSpace.l),
        child: ScheduleSheet(settings: s, before: days),
      ),
    ),
  ),
);

void main() {
  setUpAll(loadAppFonts);
  setUpAll(tz_data.initializeTimeZones);
  goldenMatrix(
    'schedule_sheet_weekdays',
    height: 1500,
    widths: const {'compact'},
    a11yVariants: true,
    overrides: _overrides(_week()),
    build: (_) => _sheet(_week(), _weekdays),
  );
  goldenMatrix(
    'schedule_sheet_weekend',
    height: 1500,
    widths: const {'compact'},
    overrides: _overrides(_week()),
    build: (_) => _sheet(_week(), const {Weekday.sat, Weekday.sun}),
  );
  goldenMatrix(
    'schedule_sheet_new',
    height: 1500,
    widths: const {'compact'},
    overrides: _overrides(_week()),
    build: (_) => _sheet(_week(), const {}),
  );
  goldenMatrix(
    'schedule_sheet_android',
    height: 1500,
    widths: const {'compact'},
    platform: TargetPlatform.android,
    overrides: _overrides(_week()),
    build: (_) => _sheet(_week(), _weekdays),
  );
  goldenMatrix(
    'schedule_sheet_alarm_off',
    height: 1500,
    widths: const {'compact'},
    overrides: _overrides(_week(alarm: false)),
    build: (_) => _sheet(_week(alarm: false), _weekdays),
  );
}
