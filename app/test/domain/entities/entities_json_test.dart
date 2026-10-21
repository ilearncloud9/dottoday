import 'dart:convert';

import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

/// Encodes to a JSON string and back, as storage and export do.
Map<String, Object?> _wire(Map<String, Object?> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, Object?>;

void main() {
  group('JSON round-trip', () {
    test('Series', () {
      final s = seriesFixture().copyWith(
        energy: Energy.high,
        untilUtc: DateTime.utc(2027),
      );
      expect(Series.fromJson(_wire(s.toJson())), s);
    });

    test('Occurrence (scheduled and inbox)', () {
      final o = occurrenceFixture().copyWith(
        status: OccurrenceStatus.done,
        completedAtUtc: t1,
        source: OccurrenceSource.calendar,
        alerts: const [Alert(kind: AlertKind.atEnd)],
      );
      expect(Occurrence.fromJson(_wire(o.toJson())), o);
      final inbox = occurrenceFixture().copyWith(startUtc: null);
      expect(Occurrence.fromJson(_wire(inbox.toJson())), inbox);
    });

    test('Subtask, Profile, CalendarAccount, CalendarLink', () {
      final s = subtaskFixture();
      expect(Subtask.fromJson(_wire(s.toJson())), s);
      final p = profileFixture().copyWith(
        settings: const Settings(
          dayBoundaries: {
            Weekday.mon: TimeWindow(start: '06:00', end: '21:00'),
          },
          quietHours: Settings.suggestedQuietHours,
          use24h: true,
        ),
      );
      expect(Profile.fromJson(_wire(p.toJson())), p);
      final a = accountFixture();
      expect(CalendarAccount.fromJson(_wire(a.toJson())), a);
      expect(CalendarLink.fromJson(_wire(linkFixture.toJson())), linkFixture);
    });
  });

  group('wire format (docs/05)', () {
    test('rows use snake_case columns and UTC epoch ms', () {
      final json = occurrenceFixture().toJson();
      expect(json['start_utc'], t0.millisecondsSinceEpoch);
      expect(json['duration_min'], 45);
      expect(json['color_key'], 'indigo');
      expect(json['icon_key'], 'circle');
      expect(json['status'], 'planned');
    });

    test('decoded instants are UTC', () {
      final o = Occurrence.fromJson(_wire(occurrenceFixture().toJson()));
      expect(o.startUtc!.isUtc, isTrue);
      expect(o.createdAt.isUtc, isTrue);
    });

    test('enum values match the SQL enums', () {
      expect(const Alert(kind: AlertKind.atStart).toJson()['kind'], 'at_start');
      expect(
        accountFixture()
            .copyWith(provider: CalendarProvider.appleDevice)
            .toJson()['provider'],
        'apple_device',
      );
      expect(
        seriesFixture().copyWith(energy: Energy.low).toJson()['energy'],
        1,
      );
    });

    test('alerts and settings JSON keep camelCase keys', () {
      expect(const Alert(kind: AlertKind.before, offsetMin: 10).toJson(), {
        'kind': 'before',
        'offsetMin': 10,
        'sound': null,
      });
      expect(const Settings().toJson()['snapMinutes'], 5);
    });

    test('occurrence alerts: null inherits, [] overrides with none', () {
      expect(occurrenceFixture().toJson()['alerts'], isNull);
      final none = occurrenceFixture().copyWith(alerts: const []);
      expect(Occurrence.fromJson(_wire(none.toJson())).alerts, isEmpty);
    });
  });

  group('Settings defaults equal docs/05 example', () {
    test('decoding the stored default {"dayBoundaries":{}}', () {
      final s = Settings.fromJson({'dayBoundaries': <String, Object?>{}});
      expect(s, const Settings());
      expect(s.snapMinutes, 5);
      expect(s.shiftFollowers, ShiftFollowersPolicy.ask);
      expect(s.defaultDurationMin, 30);
      expect(s.defaultAlerts, [
        const Alert(kind: AlertKind.before, offsetMin: 10),
      ]);
      expect(s.firstDayOfWeek, 1);
      expect(s.theme, ThemePreference.system);
      expect(s.accent, 'indigo');
    });

    test('quiet hours off round-trips (null is not replaced by a default)', () {
      const off = Settings();
      expect(Settings.fromJson(_wire(off.toJson())).quietHours, isNull);
    });

    test('boundaryFor falls back to 07:00–22:00', () {
      const s = Settings(
        dayBoundaries: {Weekday.sat: TimeWindow(start: '09:00', end: '23:00')},
      );
      expect(s.boundaryFor(Weekday.sat).start, '09:00');
      expect(s.boundaryFor(Weekday.mon), Settings.defaultDayBoundary);
    });
  });

  test('Occurrence derived getters', () {
    final o = occurrenceFixture();
    expect(o.isInbox, isFalse);
    expect(o.endUtc, t0.add(const Duration(minutes: 45)));
    final inbox = o.copyWith(startUtc: null);
    expect(inbox.isInbox, isTrue);
    expect(inbox.endUtc, isNull);
  });
}
