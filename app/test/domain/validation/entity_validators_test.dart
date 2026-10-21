import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/validation/entity_validators.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../fixtures.dart';

/// Unwraps the failure code (or 'ok') so expectations read as one value.
String _code<T>(Validated<T> r) => r.when(ok: (_) => 'ok', err: (f) => f.code);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('validateOccurrence', () {
    test('accepts the fixture and trims the title', () {
      final r = validateOccurrence(
        occurrenceFixture().copyWith(title: '  Dentist  '),
      );
      expect(r.when(ok: (o) => o.title, err: (f) => f.code), 'Dentist');
    });

    final cases = <String, (Object?, String)>{
      'blank title': ('   ', 'validation.title.required'),
      'title 201 chars': ('x' * 201, 'validation.title.tooLong'),
    };
    for (final MapEntry(key: name, value: (title, code)) in cases.entries) {
      test(name, () {
        final o = occurrenceFixture().copyWith(title: title! as String);
        expect(_code(validateOccurrence(o)), code);
      });
    }

    test('title of exactly 200 chars is fine', () {
      final o = occurrenceFixture().copyWith(title: 'x' * 200);
      expect(_code(validateOccurrence(o)), 'ok');
    });

    test('notes ≤ 10 000', () {
      final ok = occurrenceFixture().copyWith(notes: 'n' * 10000);
      final long = occurrenceFixture().copyWith(notes: 'n' * 10001);
      expect(_code(validateOccurrence(ok)), 'ok');
      expect(_code(validateOccurrence(long)), 'validation.notes.tooLong');
    });

    test('duration 5–1440', () {
      for (final (min, code) in [
        (4, 'validation.duration.outOfRange'),
        (5, 'ok'),
        (1440, 'ok'),
        (1441, 'validation.duration.outOfRange'),
      ]) {
        final o = occurrenceFixture().copyWith(durationMin: min);
        expect(_code(validateOccurrence(o)), code, reason: '$min');
      }
    });

    test('colour and icon keys from the allowed sets', () {
      final color = occurrenceFixture().copyWith(colorKey: 'chartreuse');
      final icon = occurrenceFixture().copyWith(iconKey: 'Bad Icon');
      expect(
        _code(validateOccurrence(color)),
        'validation.color.invalidFormat',
      );
      expect(_code(validateOccurrence(icon)), 'validation.icon.invalidFormat');
      final fine = occurrenceFixture().copyWith(
        colorKey: 'slate',
        iconKey: 'fitness_center',
      );
      expect(_code(validateOccurrence(fine)), 'ok');
    });

    test('tz_id must be a known IANA zone', () {
      final o = occurrenceFixture().copyWith(tzId: 'Mars/Olympus');
      expect(_code(validateOccurrence(o)), 'validation.timeZone.invalidFormat');
      expect(
        _code(validateOccurrence(occurrenceFixture().copyWith(tzId: 'UTC'))),
        'ok',
      );
    });

    test('travel buffer 0–180', () {
      final o = occurrenceFixture().copyWith(travelBufferMin: 181);
      expect(
        _code(validateOccurrence(o)),
        'validation.travelBuffer.outOfRange',
      );
    });

    test('alerts: ≤ 5, offsets 0–1440', () {
      const a = Alert(kind: AlertKind.before, offsetMin: 10);
      final six = occurrenceFixture().copyWith(alerts: List.filled(6, a));
      final five = occurrenceFixture().copyWith(alerts: List.filled(5, a));
      final bad = occurrenceFixture().copyWith(
        alerts: [a.copyWith(offsetMin: 1441)],
      );
      expect(_code(validateOccurrence(six)), 'validation.alerts.tooLarge');
      expect(_code(validateOccurrence(five)), 'ok');
      expect(
        _code(validateOccurrence(bad)),
        'validation.alertOffset.outOfRange',
      );
    });
  });

  group('validateSeries', () {
    test('accepts the fixture', () {
      expect(_code(validateSeries(seriesFixture())), 'ok');
    });

    test('rrule must parse and start with FREQ', () {
      for (final rule in [
        'WEEKLY',
        'BYDAY=MO;FREQ=WEEKLY',
        'FREQ=SOMETIMES',
        'FREQ=MINUTELY;INTERVAL=30',
      ]) {
        final s = seriesFixture().copyWith(rrule: rule);
        expect(
          _code(validateSeries(s)),
          'validation.recurrence.invalidFormat',
          reason: rule,
        );
      }
    });

    test('dtstart_local is wall-clock ISO without offset', () {
      for (final bad in [
        '2026-10-21T07:00Z',
        '2026-10-21T07:00+02:00',
        '2026-10-21',
        '2026-02-30T07:00',
      ]) {
        final s = seriesFixture().copyWith(dtstartLocal: bad);
        expect(
          _code(validateSeries(s)),
          'validation.startTime.invalidFormat',
          reason: bad,
        );
      }
      final secs = seriesFixture().copyWith(
        dtstartLocal: '2026-10-21T07:00:30',
      );
      expect(_code(validateSeries(secs)), 'ok');
    });

    test('count 1–10000 and never together with until', () {
      expect(
        _code(validateSeries(seriesFixture().copyWith(count: 0))),
        'validation.recurrence.outOfRange',
      );
      final both = seriesFixture().copyWith(count: 3, untilUtc: t1);
      expect(
        _code(validateSeries(both)),
        'validation.recurrence.invalidFormat',
      );
    });

    test('subtask template ≤ 50 items with valid titles', () {
      final item = seriesFixture().subtaskTemplate.single;
      final many = seriesFixture().copyWith(
        subtaskTemplate: List.filled(51, item),
      );
      final blank = seriesFixture().copyWith(
        subtaskTemplate: [item.copyWith(title: ' ')],
      );
      expect(_code(validateSeries(many)), 'validation.subtasks.tooLarge');
      expect(_code(validateSeries(blank)), 'validation.title.required');
    });
  });

  test('validateSubtask trims and requires a title', () {
    final ok = validateSubtask(subtaskFixture().copyWith(title: ' Card '));
    expect(ok.when(ok: (s) => s.title, err: (f) => f.code), 'Card');
    final blank = subtaskFixture().copyWith(title: '');
    expect(_code(validateSubtask(blank)), 'validation.title.required');
    expect(checkSubtaskCount(50), isNull);
    expect(checkSubtaskCount(51)?.code, 'validation.subtasks.tooLarge');
  });

  group('validateSettings', () {
    test('defaults are valid', () {
      expect(_code(validateSettings(const Settings())), 'ok');
    });

    final bad = <String, (Settings, String)>{
      'snap 7': (
        const Settings(snapMinutes: 7),
        'validation.settings.outOfRange',
      ),
      'boundary format': (
        const Settings(
          dayBoundaries: {Weekday.mon: TimeWindow(start: '7:00', end: '22:00')},
        ),
        'validation.settings.invalidFormat',
      ),
      'boundary end before start': (
        const Settings(
          dayBoundaries: {
            Weekday.mon: TimeWindow(start: '22:00', end: '07:00'),
          },
        ),
        'validation.settings.outOfRange',
      ),
      'quiet hours empty window': (
        const Settings(
          quietHours: TimeWindow(start: '22:00', end: '22:00'),
        ),
        'validation.settings.outOfRange',
      ),
      'quiet hours 24:00': (
        const Settings(
          quietHours: TimeWindow(start: '22:00', end: '24:00'),
        ),
        'validation.settings.invalidFormat',
      ),
      'default duration': (
        const Settings(defaultDurationMin: 2),
        'validation.duration.outOfRange',
      ),
      'first day of week': (
        const Settings(firstDayOfWeek: 8),
        'validation.settings.outOfRange',
      ),
      'accent': (
        const Settings(accent: 'gold'),
        'validation.color.invalidFormat',
      ),
    };
    for (final MapEntry(key: name, value: (s, code)) in bad.entries) {
      test(name, () => expect(_code(validateSettings(s)), code));
    }

    test('quiet hours may wrap past midnight', () {
      const s = Settings(quietHours: Settings.suggestedQuietHours);
      expect(_code(validateSettings(s)), 'ok');
    });
  });

  group('validateProfile', () {
    test('accepts the fixture and trims the display name', () {
      final r = validateProfile(
        profileFixture().copyWith(displayName: ' Sam '),
      );
      expect(r.when(ok: (p) => p.displayName, err: (f) => f.code), 'Sam');
    });

    test('rejects long names, unknown zones, empty locale, bad settings', () {
      final p = profileFixture();
      expect(
        _code(validateProfile(p.copyWith(displayName: 'x' * 81))),
        'validation.displayName.tooLong',
      );
      expect(
        _code(validateProfile(p.copyWith(tzId: 'Nowhere'))),
        'validation.timeZone.invalidFormat',
      );
      expect(
        _code(validateProfile(p.copyWith(locale: ''))),
        'validation.locale.required',
      );
      expect(
        _code(
          validateProfile(p.copyWith(settings: const Settings(snapMinutes: 3))),
        ),
        'validation.settings.outOfRange',
      );
    });
  });

  group('calendar', () {
    test('account label 1–80, trimmed', () {
      expect(_code(validateCalendarAccount(accountFixture())), 'ok');
      final blank = accountFixture().copyWith(label: '  ');
      final long = accountFixture().copyWith(externalAccountId: 'a' * 257);
      expect(
        _code(validateCalendarAccount(blank)),
        'validation.label.required',
      );
      expect(_code(validateCalendarAccount(long)), 'validation.label.tooLong');
    });

    test('link external ids bounded (06 §7)', () {
      expect(_code(validateCalendarLink(linkFixture)), 'ok');
      final long = linkFixture.copyWith(externalEventId: 'e' * 513);
      expect(_code(validateCalendarLink(long)), 'validation.label.tooLong');
    });
  });
}
