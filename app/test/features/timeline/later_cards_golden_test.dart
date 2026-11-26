// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/onboarding/later_cards_store.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/dot_golden.dart';
import '../../support/timeline_fakes.dart';
import '../../support/youre_in_rows.dart';

// Later, when it helps (M20.11 part 6, ED-491): the four one-time cards at
// the foot of Today, in the owner's option A.

final _onboarded = DateTime.utc(2026, 10, 12, 8);

final _gym = Series(
  id: 'gym-series',
  userId: testUserId,
  title: 'Gym',
  durationMin: 60,
  rrule: 'FREQ=DAILY',
  dtstartLocal: '2026-10-12T18:00',
  tzId: 'Europe/Berlin',
  colorKey: 'violet',
  iconKey: 'gym',
  createdAt: DateTime.utc(2026, 10, 12),
  updatedAt: DateTime.utc(2026, 10, 12),
);

Occurrence _gymOn(int d, {bool done = true}) => Occurrence(
  id: 'gym-$d',
  userId: testUserId,
  seriesId: _gym.id,
  title: 'Gym',
  colorKey: 'violet',
  iconKey: 'gym',
  startUtc: DateTime.utc(2026, 10, d, 16),
  tzId: 'Europe/Berlin',
  durationMin: 60,
  status: done ? OccurrenceStatus.done : OccurrenceStatus.planned,
  createdAt: DateTime.utc(2026, 10, 12),
  updatedAt: DateTime.utc(2026, 10, 12),
);

void _card(
  String name,
  LaterCardsState later, {
  DateTime? now,
  bool habit = false,
}) => goldenMatrix(
  'today_later_$name',
  height: 844,
  widths: const {'compact', 'expanded'},
  a11yVariants: name == 'simpler',
  overrides: timelineOverrides(
    now: now ?? DateTime.utc(2026, 10, 21, 7, 22),
    occurrences: FakeOccurrenceRepository([
      ...youreInRows(),
      if (habit) ...[
        _gymOn(12),
        _gymOn(14),
        _gymOn(16),
        _gymOn(22, done: false),
      ],
    ]),
    series: [if (habit) _gym],
    profile: testProfile(
      settings: Settings(
        use24h: false,
        firstDayOfWeek: 7,
        dayBoundaries: {
          for (final d in Weekday.values)
            d: const TimeWindow(start: '07:00', end: '23:00'),
        },
      ),
    ).copyWith(displayName: 'Kody'),
    laterCards: later,
  ),
  build: (_) => const TodayScreen(),
);

void main() {
  tz_data.initializeTimeZones();
  setUpAll(loadAppFonts);
  _card('simpler', LaterCardsState(onboardedUtc: _onboarded));
  _card(
    'habit',
    LaterCardsState(onboardedUtc: _onboarded, habits: [_gym.id]),
    habit: true,
  );
  _card(
    'close',
    LaterCardsState(onboardedUtc: _onboarded),
    now: DateTime.utc(2026, 10, 21, 21, 30),
  );
  _card('sync', LaterCardsState(onboardedUtc: _onboarded, simpler: true));
}
