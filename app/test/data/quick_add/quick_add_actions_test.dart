import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/quick_add/quick_add_actions.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';

/// 10:00 in Berlin, Wednesday 21 October 2026.
final _now = DateTime.utc(2026, 10, 21, 8);

/// A pasted three-line list per language (R-07, docs/02 F2 "en, de, fr,
/// es"): a timed task with a length, one for tomorrow at 15:00, one with
/// no time.
const _pastes = {
  'en': (
    '- Gym 7pm 45m\n- Call Mum tomorrow 3pm\n- Buy milk',
    'Gym',
    'Call Mum',
    'Buy milk',
  ),
  'de': (
    '- Sport 19 Uhr 45 min\n- Mama anrufen morgen 15 Uhr\n- Milch kaufen',
    'Sport',
    'Mama anrufen',
    'Milch kaufen',
  ),
  'fr': (
    '- Sport 19h 45 min\n- Appeler maman demain 15h\n- Acheter du lait',
    'Sport',
    'Appeler maman',
    'Acheter du lait',
  ),
  'es': (
    '- Gimnasio 19:00 45 min\n- Llamar a mamá mañana 15:00\n- Comprar leche',
    'Gimnasio',
    'Llamar a mamá',
    'Comprar leche',
  ),
};

void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final MapEntry(key: lang, value: (paste, timed, tomorrow, inbox))
      in _pastes.entries) {
    test('$lang: a pasted list → one task per line, one Undo', () async {
      final repo = FakeOccurrenceRepository();
      final container = ProviderContainer(
        overrides: timelineOverrides(now: _now, occurrences: repo),
      );
      addTearDown(container.dispose);
      final result = await addFromText(
        container,
        paste,
        languageCode: lang,
        untitled: 'New task',
      );
      final added = (result as Ok<Added, AppFailure>).value;
      expect(added.rows, hasLength(3));
      expect(added.token, isNotNull);
      Occurrence row(String title) =>
          repo.rows.singleWhere((o) => o.title == title);
      expect(row(timed).startUtc, DateTime.utc(2026, 10, 21, 17));
      expect(row(timed).durationMin, 45);
      expect(row(tomorrow).startUtc, DateTime.utc(2026, 10, 22, 13));
      expect(row(inbox).isInbox, isTrue);
    });
  }

  test(
    'web paste: a line with a link is titled and keeps it (M12.4)',
    () async {
      final repo = FakeOccurrenceRepository();
      final container = ProviderContainer(
        overrides: timelineOverrides(now: _now, occurrences: repo),
      );
      addTearDown(container.dispose);
      await addFromText(
        container,
        'Read https://blog.example/post\nhttps://www.example.com/x',
        languageCode: 'en',
        untitled: 'New task',
      );
      final byTitle = {for (final o in repo.rows) o.title: o};
      expect(byTitle.keys, containsAll(['Read', 'example.com/x']));
      expect(byTitle['Read']!.notes, 'Read https://blog.example/post');
      expect(byTitle['example.com/x']!.notes, 'https://www.example.com/x');
      expect(byTitle['Read']!.isInbox, isTrue);
    },
  );
}
