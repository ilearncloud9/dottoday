import 'dart:convert';

import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/export/csv_export.dart';
import 'package:dottoday/domain/export/ics_export.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';
import 'export_fixtures.dart';

/// Minimal RFC 4180 reader, to prove the writer's quoting round-trips.
List<List<String>> _readCsv(String csv) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  for (var i = 0; i < csv.length; i++) {
    final c = csv[i];
    if (quoted) {
      if (c == '"' && i + 1 < csv.length && csv[i + 1] == '"') {
        cell.write('"');
        i++;
      } else if (c == '"') {
        quoted = false;
      } else {
        cell.write(c);
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == ',') {
      row.add(cell.toString());
      cell.clear();
    } else if (c == '\r' && csv[i + 1] == '\n') {
      row.add(cell.toString());
      cell.clear();
      rows.add(row);
      row = <String>[];
      i++;
    } else {
      cell.write(c);
    }
  }
  return rows;
}

void main() {
  group('CSV', () {
    test('quoting round-trips commas, quotes and newlines', () {
      final csv = toCsv([
        'a',
        'b',
      ], [
        ['x, "y"', 'two\nlines'],
        [null, 3],
      ]);
      expect(_readCsv(csv), [
        ['a', 'b'],
        ['x, "y"', 'two\nlines'],
        ['', '3'],
      ]);
      expect(csv.endsWith('\r\n'), isTrue);
    });

    test('formula injection is neutralised in text, not in numbers', () {
      final rows = _readCsv(
        toCsv([
          'v',
        ], [
          ['=1+1'],
          ['+SUM(A1)'],
          ['-cmd'],
          ['@x'],
          ['\tTab'],
          [-5],
        ]),
      );
      expect(rows.skip(1).map((r) => r.single), [
        "'=1+1",
        "'+SUM(A1)",
        "'-cmd",
        "'@x",
        "'\tTab",
        '-5',
      ]);
    });

    test('occurrences: snake_case header, ISO instants, JSON nested, no trash',
        () {
      final bundle = hostileBundle();
      final deleted = bundle.occurrences.first.copyWith(
        id: 'gone',
        deletedAt: t1,
      );
      final rows = _readCsv(occurrencesCsv([...bundle.occurrences, deleted]));
      final header = rows.first;
      expect(header.take(3), ['id', 'user_id', 'series_id']);
      final byId = {for (final r in rows.skip(1)) r[0]: r};
      expect(byId.containsKey('gone'), isFalse);
      final oneOff = byId[bundle.occurrences.first.id]!;
      expect(oneOff[header.indexOf('start_utc')], '2026-10-21T08:00:00.000Z');
      expect(oneOff[header.indexOf('alerts')], '[]');
      expect(oneOff[header.indexOf('notes')], "'$hostileNotes".substring(1));
      expect(oneOff[header.indexOf('status')], 'done');
      expect(
        byId[bundle.occurrences[2].id]![header.indexOf('title')],
        "'-5 minus first",
      );
    });

    test('series and subtasks', () {
      final b = hostileBundle();
      final series = _readCsv(seriesCsv(b.series));
      expect(series[1][series[0].indexOf('title')], "'$hostileTitle");
      expect(series[1][series[0].indexOf('alerts')], contains('overdue'));
      expect(_readCsv(subtasksCsv(b.subtasks)).length, 3);
      expect(seriesCsv(const []), isEmpty);
    });
  });

  group('ICS', () {
    String ics() {
      final b = hostileBundle();
      final s = b.series.single;
      final skipped = b.occurrences[1].copyWith(
        id: 'skipped',
        originalStartUtc: DateTime.utc(2026, 10, 26, 6),
        startUtc: DateTime.utc(2026, 10, 26, 6),
        status: OccurrenceStatus.skipped,
      );
      final untouched = b.occurrences[1].copyWith(
        id: 'same',
        originalStartUtc: DateTime.utc(2026, 10, 28, 6),
        startUtc: DateTime.utc(2026, 10, 28, 6),
        title: s.title,
      );
      return toIcs(
        stampUtc: b.exportedAt,
        series: b.series,
        occurrences: [...b.occurrences, skipped, untouched],
      );
    }

    /// Unfolded content lines.
    List<String> lines(String text) =>
        text.replaceAll('\r\n ', '').split('\r\n')..removeLast();

    test('calendar envelope with CRLF lines', () {
      final l = lines(ics());
      expect(l.first, 'BEGIN:VCALENDAR');
      expect(l.last, 'END:VCALENDAR');
      expect(l, contains('VERSION:2.0'));
      expect(ics().contains(RegExp(r'[^\r]\n')), isFalse);
    });

    test('series: TZID start, RRULE with COUNT, EXDATE for skipped', () {
      final l = lines(ics());
      expect(l, contains('DTSTART;TZID=Europe/Berlin:20261019T070000'));
      expect(l, contains('RRULE:FREQ=WEEKLY;BYDAY=MO,WE;COUNT=10'));
      expect(l, contains('EXDATE:20261026T060000Z'));
      expect(l, contains('DURATION:PT30M'));
    });

    test('moved instance is a RECURRENCE-ID override; untouched ones are not',
        () {
      final l = lines(ics());
      expect(l.where((x) => x.startsWith('RECURRENCE-ID')), [
        'RECURRENCE-ID:20261021T050000Z',
      ]);
      expect(
        l.where(
          (x) => x.startsWith('UID:01928c3e-0000-7000-8000-0000000000a1'),
        ),
        hasLength(2),
      );
    });

    test('one-off in UTC; inbox items left out', () {
      final l = lines(ics());
      expect(l, contains('DTSTART:20261021T080000Z'));
      expect(l.where((x) => x == 'BEGIN:VEVENT').length, 3);
      expect(ics(), isNot(contains('minus first')));
    });

    test('TEXT escaping', () {
      final l = lines(ics());
      expect(
        l,
        contains(
          r'DESCRIPTION:line 1\nline 2\n+SUM(A1)' '\t' r'@cmd\, end',
        ),
      );
      expect(
        l.where((x) => x.startsWith('SUMMARY:')),
        contains(endsWith(r'\, "quoted"\; semi\\colon 🧘‍♀️ Ünïcødé')),
      );
    });

    test('folds at 75 octets without splitting UTF-8 characters', () {
      for (final physical in ics().split('\r\n')) {
        expect(utf8.encode(physical).length, lessThanOrEqualTo(75));
      }
      expect(lines(ics()).join(), contains('🧘‍♀️ Ünïcødé'));
    });
  });
}
