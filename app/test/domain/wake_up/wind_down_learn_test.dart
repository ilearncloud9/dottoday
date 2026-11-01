import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:dottoday/domain/wake_up/wind_down_learn.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// docs/15 §7b: "You usually get up ~12 min after Wake Up. Move Wind Down
// 15 min earlier?" — learned from this phone's mornings, offered once,
// never again inside 30 days, never automatic.

late tz.Location _berlin;

/// A morning on 2026-10-[day] stopped [late] minutes after 07:00 Berlin
/// (05:00Z in summer time, 06:00Z after 25 Oct).
WakeUpDay _morning(int day, int late) {
  final wake = tz.TZDateTime(_berlin, 2026, 10, day, 7).toUtc();
  return WakeUpDay(
    date: '2026-10-${day.toString().padLeft(2, '0')}',
    stoppedAtUtc: wake.add(Duration(minutes: late)),
  );
}

int? _median(List<WakeUpDay> days) =>
    medianDismissOffsetMin(days, settings: const Settings(), location: _berlin);

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    _berlin = tz.getLocation('Europe/Berlin');
  });

  group('medianDismissOffsetMin', () {
    test('the median of the mornings, across the DST change', () {
      final days = [
        for (final (d, late) in [
          (22, 8),
          (23, 12),
          (24, 30),
          (26, 11),
          (27, 14),
        ])
          _morning(d, late),
      ];
      expect(_median(days), 12);
    });

    test('even count: the middle two averaged', () {
      final days = [
        for (final (d, late) in [
          (20, 10),
          (21, 12),
          (22, 14),
          (23, 20),
          (26, 2),
          (27, 40),
        ])
          _morning(d, late),
      ];
      expect(_median(days), 13);
    });

    test('too few mornings: nothing learned', () {
      expect(_median([for (var d = 20; d < 24; d++) _morning(d, 15)]), isNull);
    });

    test('only the last ten count', () {
      final days = [
        for (var d = 1; d <= 10; d++) _morning(d, 12),
        for (var d = 11; d <= 20; d++) _morning(d, 60),
      ];
      expect(_median(days), 12);
    });
  });

  group('windDownLearnOfferMin', () {
    const target = Settings(sleepTargetMin: 480);
    final now = DateTime.utc(2026, 11, 2, 12);

    test('rounds up to the target steps', () {
      expect(windDownLearnOfferMin(target, offsetMin: 12, nowUtc: now), 15);
      expect(windDownLearnOfferMin(target, offsetMin: 16, nowUtc: now), 30);
    });

    test('not without a sleep target, nor with the switch off', () {
      expect(
        windDownLearnOfferMin(const Settings(), offsetMin: 12, nowUtc: now),
        isNull,
      );
      expect(
        windDownLearnOfferMin(
          target.copyWith(windDownLearnOffer: false),
          offsetMin: 12,
          nowUtc: now,
        ),
        isNull,
      );
    });

    test('not for a few minutes, nor past the longest target', () {
      expect(windDownLearnOfferMin(target, offsetMin: 6, nowUtc: now), isNull);
      expect(
        windDownLearnOfferMin(
          const Settings(sleepTargetMin: 600),
          offsetMin: 12,
          nowUtc: now,
        ),
        isNull,
      );
    });

    test('quiet for 30 days after an answer', () {
      final answered = target.copyWith(
        windDownLearnOfferAt: now.subtract(const Duration(days: 29)),
      );
      expect(
        windDownLearnOfferMin(answered, offsetMin: 12, nowUtc: now),
        isNull,
      );
      expect(
        windDownLearnOfferMin(
          answered,
          offsetMin: 12,
          nowUtc: now.add(const Duration(days: 2)),
        ),
        15,
      );
    });
  });
}
