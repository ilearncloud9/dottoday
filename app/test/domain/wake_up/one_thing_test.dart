import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/one_thing.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/15 §8 (M17.7b): today's one thing — one a day, cleared by its date,
// picked from today's dots or the Inbox.

final _now = DateTime.utc(2026, 11, 2, 7);

Occurrence _o(
  String id, {
  int? atHour,
  OccurrenceStatus status = OccurrenceStatus.planned,
}) => Occurrence(
  id: id,
  userId: 'u',
  title: id,
  startUtc: atHour == null ? null : DateTime.utc(2026, 11, 2, atHour),
  tzId: 'UTC',
  durationMin: 30,
  status: status,
  createdAt: _now,
  updatedAt: _now,
);

void main() {
  group('oneThingOn', () {
    const pick = OneThing(date: '2026-11-02', occurrenceId: 'a');

    test('the pick on its own day', () {
      expect(oneThingOn(pick, '2026-11-02'), 'a');
    });

    test('clears when the day ends', () {
      expect(oneThingOn(pick, '2026-11-03'), isNull);
      expect(oneThingOn(null, '2026-11-02'), isNull);
    });

    test('one field, so a new pick replaces the old', () {
      const settings = Settings(oneThing: pick);
      final next = settings.copyWith(
        oneThing: const OneThing(date: '2026-11-02', occurrenceId: 'b'),
      );
      expect(oneThingOn(next.oneThing, '2026-11-02'), 'b');
    });

    test('round-trips through the synced settings JSON', () {
      const settings = Settings(oneThing: pick);
      expect(Settings.fromJson(settings.toJson()).oneThing, pick);
      expect(Settings.fromJson(const Settings().toJson()).oneThing, isNull);
    });
  });

  group('oneThingChoices', () {
    test("today's open dots in start order, then the Inbox", () {
      final c = oneThingChoices(
        dots: [_o('late', atHour: 12), _o('early', atHour: 8)],
        inbox: [_o('box')],
        nowUtc: _now,
      );
      expect(c.dots.map((o) => o.id), ['early', 'late']);
      expect(c.inbox.map((o) => o.id), ['box']);
    });

    test('done, skipped, over and untimed dots are left out', () {
      final c = oneThingChoices(
        dots: [
          _o('done', atHour: 9, status: OccurrenceStatus.done),
          _o('skipped', atHour: 9, status: OccurrenceStatus.skipped),
          _o('over', atHour: 5),
          _o('untimed'),
          _o('open', atHour: 9),
        ],
        inbox: [_o('doneBox', status: OccurrenceStatus.done)],
        nowUtc: _now,
      );
      expect(c.dots.map((o) => o.id), ['open']);
      expect(c.inbox, isEmpty);
    });

    test('the mission offers the first five of each', () {
      final c = oneThingChoices(
        dots: [for (var h = 8; h < 16; h++) _o('d$h', atHour: h)],
        inbox: [for (var i = 0; i < 7; i++) _o('i$i')],
        nowUtc: _now,
        mission: true,
      );
      expect(c.dots.map((o) => o.id), ['d8', 'd9', 'd10', 'd11', 'd12']);
      expect(c.inbox, hasLength(oneThingMaxDots));
    });

    test('picked from Today, every open dot is offered', () {
      final c = oneThingChoices(
        dots: [for (var h = 8; h < 16; h++) _o('d$h', atHour: h)],
        inbox: const [],
        nowUtc: _now,
      );
      expect(c.dots, hasLength(8));
    });
  });
}
