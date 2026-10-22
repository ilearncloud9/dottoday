import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/quick_add/draft_rows.dart';
import 'package:dottoday/domain/quick_add/quick_add_lexicon.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

final class _Ids implements IdGenerator {
  var _n = 0;
  @override
  String newId() => 'id-${_n++}';
}

// 10:00 Berlin, Wednesday 21 October 2026.
final _now = DateTime.utc(2026, 10, 21, 8);

DraftRows _rows(String line, {List<Alert> alerts = const []}) {
  final ctx = QuickAddContext(
    nowUtc: _now,
    tzId: 'Europe/Berlin',
    language: QuickAddLanguage.en,
  );
  final draft = switch (const QuickAddParser().parse(line, ctx)) {
    Ok(:final value) => value,
    Err(:final failure) => throw StateError('$failure'),
  };
  return rowsFromDraft(
    draft,
    userId: 'u',
    tzId: 'Europe/Berlin',
    nowUtc: _now,
    defaultDurationMin: 30,
    untitled: 'New task',
    alerts: alerts,
    ids: _Ids(),
  );
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('no time → inbox item with the default length', () {
    final o = _rows('Call Mum').occurrence!;
    expect(o.startUtc, isNull);
    expect(o.title, 'Call Mum');
    expect(o.durationMin, 30);
  });

  test('a time → on the timeline, the typed length', () {
    final o = _rows('Call Mum tomorrow 3pm 20m').occurrence!;
    expect(o.startUtc, DateTime.utc(2026, 10, 22, 13));
    expect(o.durationMin, 20);
  });

  test('@inbox wins over a time', () {
    expect(_rows('Gym 7am @inbox').occurrence!.startUtc, isNull);
  });

  test('a time and "every …" → a series from that day', () {
    final s = _rows('Gym 7am every day 45m').series!;
    expect(s.rrule, 'FREQ=DAILY');
    expect(s.dtstartLocal, '2026-10-21T07:00');
    expect(s.durationMin, 45);
    expect(s.title, 'Gym');
  });

  test('"every …" without a time keeps the whole line', () {
    final o = _rows('Water plants every Monday').occurrence!;
    expect(o.startUtc, isNull);
    expect(o.title, 'Water plants every Monday');
  });

  test('an empty title gets the fallback', () {
    expect(_rows('3pm').occurrence!.title, 'New task');
  });

  test('new tasks carry the default alerts (M3f.2, R-10)', () {
    const ten = [Alert(kind: AlertKind.before, offsetMin: 10)];
    expect(_rows('Call Mum 3pm', alerts: ten).occurrence!.alerts, ten);
    expect(_rows('Gym 7am every day', alerts: ten).series!.alerts, ten);
  });
}
