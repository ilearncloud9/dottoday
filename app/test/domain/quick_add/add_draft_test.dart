import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_lexicon.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

final class _Ids implements IdGenerator {
  var _n = 0;
  @override
  String newId() => 'id-${_n++}';
}

// 10:00 Berlin, Wednesday 21 October 2026.
final _now = DateTime.utc(2026, 10, 21, 8);

QuickAddDraft _parse(String line) => switch (const QuickAddParser().parse(
  line,
  QuickAddContext(
    nowUtc: _now,
    tzId: 'Europe/Berlin',
    language: QuickAddLanguage.en,
  ),
)) {
  Ok(:final value) => value,
  Err(:final failure) => throw StateError('$failure'),
};

final _shopping = HabitSuggestion(
  title: 'Go shopping',
  minuteOfDay: 17 * 60,
  durationMin: 60,
  colorKey: 'coral',
  iconKey: 'bag',
  uses: 3,
  lastUsedUtc: DateTime.utc(2026, 10, 14, 15),
);

AddDraft _draft() => AddDraft(
  today: DateTime(2026, 10, 21),
  tzId: 'Europe/Berlin',
  defaultDurationMin: 30,
);

void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('defaults: today, no time, default length and look', () {
    final d = _draft();
    expect(d.day, DateTime(2026, 10, 21));
    expect(d.startMinute, isNull);
    expect(d.startUtc, isNull);
    expect(d.length, 30);
    expect((d.color, d.icon), ('indigo', 'circle'));
  });

  test('typing "Go shopping 5pm 1h" fills time and length (R-06)', () {
    final d = _draft().withTyped(_parse('Go shopping 5pm 1h'));
    expect(d.title, 'Go shopping');
    expect(d.startMinute, 17 * 60);
    expect(d.length, 60);
    expect(d.startUtc, DateTime.utc(2026, 10, 21, 15));
  });

  test('a habit fills what was not typed; typing wins over it', () {
    final habit = _draft().withHabit(_shopping);
    expect((habit.startMinute, habit.length), (17 * 60, 60));
    expect((habit.color, habit.icon), ('coral', 'bag'));
    final typed = habit.withTyped(_parse('Go shopping 9am 20m'));
    expect((typed.startMinute, typed.length), (9 * 60, 20));
  });

  test('explicit choices win over typing and the habit', () {
    final d = _draft()
        .withHabit(_shopping)
        .withTyped(_parse('Go shopping 9am'))
        .withStartMinute(11 * 60)
        .withDuration(45)
        .withColor('teal')
        .withIcon('cart')
        .withDay(DateTime(2026, 10, 23, 13));
    expect((d.startMinute, d.length), (11 * 60, 45));
    expect((d.color, d.icon), ('teal', 'cart'));
    expect(d.day, DateTime(2026, 10, 23));
    expect(d.withHabit(null).color, 'teal');
  });

  test('all-day: local midnight for 24 h, a pick clears it', () {
    final d = _draft().withTyped(_parse('Trip 9am')).withAllDay(value: true);
    expect((d.startMinute, d.length), (0, 1440));
    expect(d.startUtc, DateTime.utc(2026, 10, 20, 22));
    expect(d.withStartMinute(600).allDay, isFalse);
  });

  test('withStartUtc: local day and minute, rounded up to the grid', () {
    final d = _draft().withStartUtc(DateTime.utc(2026, 10, 22, 7, 2), snap: 15);
    expect(d.day, DateTime(2026, 10, 22));
    expect(d.startMinute, 9 * 60 + 15);
    final late = _draft().withStartUtc(DateTime.utc(2026, 10, 21, 21, 58));
    expect(late.startMinute, 1435);
  });

  test('where Add opened is a default: typing wins over it (R-17)', () {
    final gap = _draft().openedAt(DateTime.utc(2026, 10, 21, 6, 13));
    expect((gap.day, gap.startMinute), (DateTime(2026, 10, 21), 8 * 60 + 15));
    final typed = gap.withTyped(_parse('Go shopping 5pm'));
    expect(typed.startMinute, 17 * 60);
    final tomorrow = gap.withTyped(_parse('Run tomorrow'));
    expect(tomorrow.day, DateTime(2026, 10, 22));
    expect(tomorrow.startMinute, 8 * 60 + 15);
    final habit = HabitSuggestion(
      title: 'Run',
      minuteOfDay: 6 * 60,
      durationMin: 30,
      colorKey: 'mint',
      iconKey: 'run',
      uses: 2,
      lastUsedUtc: DateTime.utc(2026, 10, 1),
    );
    expect(gap.withHabit(habit).startMinute, 8 * 60 + 15);
    final day = _draft().openedOn(DateTime(2026, 10, 24, 9));
    expect(day.day, DateTime(2026, 10, 24));
    expect(day.withTyped(_parse('Hike today')).day, DateTime(2026, 10, 21));
  });

  test('another zone moves the instant, not the wall clock', () {
    final d = _draft().withTyped(_parse('Call 5pm')).withZone('Europe/London');
    expect(d.startUtc, DateTime.utc(2026, 10, 21, 16));
  });

  test('textWithout drops a token and tidies spaces', () {
    final typed = _parse('Read 9pm 45m');
    final time = typed.tokens.firstWhere(
      (t) => t.kind == QuickAddTokenKind.time,
    );
    expect(textWithout(typed, time), 'Read 45m');
    expect(
      textWithout(typed, const QuickAddToken(QuickAddTokenKind.time, 0, 99)),
      'Read 9pm 45m',
    );
  });

  group('toRows', () {
    test('timed → one occurrence with the chosen look', () {
      final rows = _draft()
          .withTyped(_parse('Go shopping 5pm 1h'))
          .withColor('coral')
          .withIcon('bag')
          .toRows(userId: 'u', nowUtc: _now, untitled: 'New', ids: _Ids());
      final o = rows.occurrence!;
      expect(rows.series, isNull);
      expect(o.startUtc, DateTime.utc(2026, 10, 21, 15));
      expect((o.durationMin, o.colorKey, o.iconKey), (60, 'coral', 'bag'));
    });

    test('no time → inbox; toInbox drops a typed time', () {
      final none = _draft().withTyped(_parse('Call Mum'));
      expect(
        none
            .toRows(userId: 'u', nowUtc: _now, untitled: 'N')
            .occurrence!
            .isInbox,
        isTrue,
      );
      final timed = _draft().withTyped(_parse('Call Mum 3pm'));
      final rows = timed.toRows(
        userId: 'u',
        nowUtc: _now,
        untitled: 'N',
        toInbox: true,
      );
      expect(rows.occurrence!.startUtc, isNull);
      expect(rows.occurrence!.title, 'Call Mum');
    });

    test('timed "every …" → a series in the chosen look', () {
      final rows = _draft()
          .withTyped(_parse('Gym 7am every day 45m'))
          .withColor('mint')
          .toRows(userId: 'u', nowUtc: _now, untitled: 'N', ids: _Ids());
      final s = rows.series!;
      expect(rows.occurrence, isNull);
      expect(s.rrule, 'FREQ=DAILY');
      expect((s.colorKey, s.durationMin), ('mint', 45));
      expect(s.dtstartLocal, '2026-10-21T07:00');
    });

    test('empty title → untitled', () {
      final rows = _draft().toRows(userId: 'u', nowUtc: _now, untitled: 'New');
      expect(rows.occurrence!.title, 'New');
    });
  });
}
