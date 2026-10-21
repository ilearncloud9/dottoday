import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_lexicon.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

// Critical cases from docs/08 §2 `quick_add_parser_test` (R-06, R-07, R-20).
// Now: Wednesday 2026-10-21, 12:00 in Berlin (10:00Z).

const _parser = QuickAddParser();
final _now = DateTime.utc(2026, 10, 21, 10);

QuickAddContext _ctx([QuickAddLanguage lang = QuickAddLanguage.en]) =>
    QuickAddContext(nowUtc: _now, tzId: 'Europe/Berlin', language: lang);

QuickAddDraft _parse(
  String text, [
  QuickAddLanguage lang = QuickAddLanguage.en,
  List<QuickAddToken> ignored = const [],
]) =>
    switch (_parser.parse(text, _ctx(lang), ignored: ignored)) {
      Ok(:final value) => value,
      Err(:final failure) => fail(failure.code),
    };

String? _hhmm(QuickAddDraft d) => d.minuteOfDay == null
    ? null
    : '${(d.minuteOfDay! ~/ 60).toString().padLeft(2, '0')}:'
        '${(d.minuteOfDay! % 60).toString().padLeft(2, '0')}';

String? _day(QuickAddDraft d) => d.date?.toIso8601String().substring(0, 10);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('times (en)', () {
    final cases = {
      'Gym 7am': ('Gym', '07:00'),
      'Dinner 19:00': ('Dinner', '19:00'),
      'Lunch at noon': ('Lunch', '12:00'),
      'Call 7:30pm': ('Call', '19:30'),
      'Pills 12am': ('Pills', '00:00'),
      'Standup 12pm': ('Standup', '12:00'),
      'Read 9 p.m.': ('Read', '21:00'),
      'Backup at midnight': ('Backup', '00:00'),
    };
    for (final MapEntry(key: input, value: (title, time)) in cases.entries) {
      test(input, () {
        final d = _parse(input);
        expect((d.title, _hhmm(d)), (title, time));
      });
    }

    test('time without a date is today in the user zone', () {
      final d = _parse('Gym 7am');
      expect(d.startUtc, DateTime.utc(2026, 10, 21, 5)); // 07:00 CEST
    });

    test('invalid clock times stay in the title', () {
      final d = _parse('Meet 25:00 13pm');
      expect(d.minuteOfDay, isNull);
      expect(d.title, 'Meet 25:00 13pm');
    });
  });

  test('"tmrw 3pm 45m" → tomorrow 15:00 for 45 min', () {
    final d = _parse('tmrw 3pm 45m');
    expect((_day(d), _hhmm(d), d.durationMin), ('2026-10-22', '15:00', 45));
    expect(d.title, isEmpty);
    expect(d.startUtc, DateTime.utc(2026, 10, 22, 13));
    expect(d.tokens.map((t) => t.kind), [
      QuickAddTokenKind.date,
      QuickAddTokenKind.time,
      QuickAddTokenKind.duration,
    ]);
  });

  test('"every mon,wed 6pm gym" → weekly Mon/Wed at 18:00', () {
    final d = _parse('every mon,wed 6pm gym');
    expect(d.rrule, 'FREQ=WEEKLY;BYDAY=MO,WE');
    expect(_hhmm(d), '18:00');
    expect(d.title, 'gym');
  });

  test('"@inbox call mom" → no time, even if one is typed', () {
    expect(_parse('@inbox call mom').inbox, isTrue);
    expect(_parse('@inbox call mom').title, 'call mom');
    final timed = _parse('call mom 5pm @inbox');
    expect(timed.inbox, isTrue);
    expect(timed.startUtc, isNull);
  });

  group('relative days (en)', () {
    final cases = {
      'Pay rent today': '2026-10-21',
      'Dentist tomorrow': '2026-10-22',
      'Party on Friday': '2026-10-23',
      'Review wednesday': '2026-10-21', // today is Wednesday
      'Review next wed': '2026-10-28',
      'Plan next Mon': '2026-10-26',
      'Trip day after tomorrow': '2026-10-23',
    };
    for (final MapEntry(key: input, value: day) in cases.entries) {
      test(input, () => expect(_day(_parse(input)), day));
    }

    test('a date without a time has no start', () {
      final d = _parse('Dentist tomorrow');
      expect(d.startUtc, isNull);
      expect(d.title, 'Dentist');
    });
  });

  group('durations (en)', () {
    final cases = {
      'Run 45m': 45,
      'Write 1.5h': 90,
      'Study 2 hours': 120,
      'Movie 2h30': 150,
      'Hike 1h 15m': 75,
      'Nap for 20 min': 20,
      'Shift 24h': 1440,
    };
    for (final MapEntry(key: input, value: minutes) in cases.entries) {
      test(input, () => expect(_parse(input).durationMin, minutes));
    }

    test('out of range (5 min–24 h) stays title', () {
      expect(_parse('Tea 2m').durationMin, isNull);
      expect(_parse('Fast 25h').title, 'Fast 25h');
    });
  });

  group('recurrence (en)', () {
    final cases = {
      'Stretch every day': 'FREQ=DAILY',
      'Review every week': 'FREQ=WEEKLY',
      'Rent every month': 'FREQ=MONTHLY',
      'Water plants every 3 days': 'FREQ=DAILY;INTERVAL=3',
      'Bins every other week': 'FREQ=WEEKLY;INTERVAL=2',
      'Standup every weekday': 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',
      'Journal daily': 'FREQ=DAILY',
      'Gym every Mon, Wed and Fri': 'FREQ=WEEKLY;BYDAY=MO,WE,FR',
    };
    for (final MapEntry(key: input, value: rule) in cases.entries) {
      test(input, () => expect(_parse(input).rrule, rule));
    }
  });

  group('German', () {
    const de = QuickAddLanguage.de;
    test('"morgen 15 Uhr" → tomorrow 15:00', () {
      final d = _parse('Zahnarzt morgen 15 Uhr', de);
      expect((d.title, _day(d), _hhmm(d)), ('Zahnarzt', '2026-10-22', '15:00'));
    });
    test('times, days, durations, recurrence', () {
      expect(_hhmm(_parse('Essen um 18:30', de)), '18:30');
      expect(_hhmm(_parse('Pause mittags', de)), '12:00');
      expect(_day(_parse('Sport am Freitag', de)), '2026-10-23');
      expect(_day(_parse('Plan nächsten Mittwoch', de)), '2026-10-28');
      expect(_day(_parse('Reise übermorgen', de)), '2026-10-23');
      expect(_parse('Lesen 1,5 Std', de).durationMin, 90);
      expect(_parse('Joggen 30 Minuten', de).durationMin, 30);
      expect(_parse('Gießen jeden Tag', de).rrule, 'FREQ=DAILY');
      expect(
        _parse('Yoga jeden Montag und Donnerstag', de).rrule,
        'FREQ=WEEKLY;BYDAY=MO,TH',
      );
      expect(_parse('Müll alle 2 Wochen', de).rrule, 'FREQ=WEEKLY;INTERVAL=2');
    });
    test('everyday words are not weekdays', () {
      final d = _parse('Mach das so', de);
      expect(d.date, isNull);
      expect(d.title, 'Mach das so');
    });
  });

  group('French', () {
    const fr = QuickAddLanguage.fr;
    test('15h / 15h30 are clock times, not durations', () {
      final d = _parse('Réunion demain à 15h30', fr);
      expect((d.title, _day(d), _hhmm(d)), ('Réunion', '2026-10-22', '15:30'));
      expect(_parse('Café 9h', fr).durationMin, isNull);
    });
    test('days, durations, recurrence', () {
      expect(_hhmm(_parse('Déjeuner à midi', fr)), '12:00');
      expect(_day(_parse('Courses vendredi', fr)), '2026-10-23');
      expect(_day(_parse('Bilan mercredi prochain', fr)), '2026-10-28');
      expect(_day(_parse("Appel aujourd'hui", fr)), '2026-10-21');
      expect(_parse('Lecture pendant 2 heures', fr).durationMin, 120);
      expect(_parse('Marche 30 min', fr).durationMin, 30);
      expect(_parse('Méditer tous les jours', fr).rrule, 'FREQ=DAILY');
      expect(
        _parse('Piscine tous les lundis et jeudis', fr).rrule,
        'FREQ=WEEKLY;BYDAY=MO,TH',
      );
    });
  });

  group('Spanish', () {
    const es = QuickAddLanguage.es;
    test('days, times, durations, recurrence', () {
      final d = _parse('Médico mañana a las 16:00', es);
      expect((d.title, _day(d), _hhmm(d)), ('Médico', '2026-10-22', '16:00'));
      expect(_hhmm(_parse('Llamar a las 3pm', es)), '15:00');
      expect(_hhmm(_parse('Comer al mediodía', es)), '12:00');
      expect(_day(_parse('Viaje pasado mañana', es)), '2026-10-23');
      expect(_day(_parse('Clase el viernes', es)), '2026-10-23');
      expect(_day(_parse('Plan el próximo miércoles', es)), '2026-10-28');
      expect(_parse('Estudiar 2 horas', es).durationMin, 120);
      expect(_parse('Correr cada día', es).rrule, 'FREQ=DAILY');
      expect(
        _parse('Gimnasio todos los lunes y miércoles', es).rrule,
        'FREQ=WEEKLY;BYDAY=MO,WE',
      );
    });
    test('"mar" (sea) is not Tuesday', () {
      expect(_parse('Nadar en el mar', es).date, isNull);
    });
  });

  test('12/24-h: both notations parse in every language', () {
    for (final lang in QuickAddLanguage.values) {
      expect(_hhmm(_parse('X 19:00', lang)), '19:00', reason: lang.name);
    }
    expect(_hhmm(_parse('X 7pm')), '19:00');
    expect(_hhmm(_parse('X 7pm', QuickAddLanguage.es)), '19:00');
  });

  test('garbage input stays title', () {
    for (final input in ['asdf qwer', 'Buy 3 apples', 'Call 911', '  ', '@@']) {
      final d = _parse(input);
      expect(d.tokens, isEmpty, reason: input);
      expect(d.title, input.trim());
    }
  });

  test('only the first token of each kind is taken; the rest stays title', () {
    final d = _parse('Swap 9am 10am');
    expect(_hhmm(d), '09:00');
    expect(d.title, 'Swap 10am');
  });

  test('token offsets point at the typed text', () {
    const text = 'Gym at 7am for 45m';
    final d = _parse(text);
    expect(
      d.tokens.map((t) => text.substring(t.start, t.end)),
      ['at 7am', 'for 45m'],
    );
  });

  test('a removed chip goes back into the title', () {
    const text = 'Read Tomorrow 8pm';
    final date = _parse(text).tokens.firstWhere(
          (t) => t.kind == QuickAddTokenKind.date,
        );
    final d = _parse(text, QuickAddLanguage.en, [date]);
    expect(d.title, 'Read Tomorrow');
    expect(d.date, isNull);
    expect(_hhmm(d), '20:00');
  });

  test('control characters are stripped (06 §7)', () {
    final d = _parse('Gym\t7am\u0000');
    expect(d.title, 'Gym');
    expect(_hhmm(d), '07:00');
  });

  group('parseMany (R-07)', () {
    test('one draft per non-empty line, bullets removed', () {
      const paste = '- Buy milk\n\n* Call mom 5pm\r\n• Gym tomorrow\n'
          '1. Taxes\n[ ] Laundry\n   \n';
      final r = _parser.parseMany(paste, _ctx());
      final drafts = r.when(ok: (d) => d, err: (f) => fail(f.code));
      expect(drafts.map((d) => d.title), [
        'Buy milk',
        'Call mom',
        'Gym',
        'Taxes',
        'Laundry',
      ]);
      expect(_hhmm(drafts[1]), '17:00');
    });

    test('oversized input is rejected', () {
      final huge = 'x' * (QuickAddParser.maxInputLength + 1);
      expect(
        _parser.parseMany(huge, _ctx()).when(ok: (_) => '', err: (f) => f.code),
        'validation.quickAddText.tooLong',
      );
      expect(
        _parser.parse(huge, _ctx()).when(ok: (_) => '', err: (f) => f.code),
        'validation.quickAddText.tooLong',
      );
    });
  });

  test('dates resolve in the user zone, not UTC', () {
    // 23:30Z on the 21st is already the 22nd in Berlin.
    final late = QuickAddContext(
      nowUtc: DateTime.utc(2026, 10, 21, 23, 30),
      tzId: 'Europe/Berlin',
      language: QuickAddLanguage.en,
    );
    final d = _parser.parse('X tomorrow', late).when(
          ok: (d) => d,
          err: (f) => fail(f.code),
        );
    expect(_day(d), '2026-10-23');
  });
}
