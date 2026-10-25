import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/calendar/travel_time.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/validation/entity_validators.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/09 M7.5, R-17: the travel time rule.
final _now = DateTime.utc(2026, 10, 21, 6);
const _on = Settings(suggestTravelTime: true, travelTimeMin: 30);

final _event = Occurrence(
  id: 'e',
  userId: 'u',
  title: 'Dentist',
  startUtc: DateTime.utc(2026, 10, 21, 8),
  tzId: 'UTC',
  durationMin: 45,
  source: OccurrenceSource.calendar,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

int? _suggest(Occurrence o, {String? place = 'Main St 4', Settings s = _on}) =>
    travelSuggestion(o, location: place, settings: s, nowUtc: _now);

void main() {
  test('an upcoming imported event with a place gets the setting', () {
    expect(_suggest(_event), 30);
  });

  test('off by default (docs/02 F5 "if the user enables it")', () {
    expect(_suggest(_event, s: const Settings()), isNull);
  });

  test('needs a place', () {
    expect(_suggest(_event, place: null), isNull);
    expect(_suggest(_event, place: '  '), isNull);
  });

  test('only before the event starts', () {
    expect(_suggest(_event.copyWith(startUtc: _now)), isNull);
    expect(
      _suggest(_event.copyWith(startUtc: _now.add(const Duration(minutes: 1)))),
      30,
    );
  });

  test('never for own tasks, done, skipped, deleted or unscheduled ones', () {
    expect(_suggest(_event.copyWith(source: OccurrenceSource.user)), isNull);
    expect(_suggest(_event.copyWith(status: OccurrenceStatus.done)), isNull);
    expect(_suggest(_event.copyWith(status: OccurrenceStatus.skipped)), isNull);
    expect(_suggest(_event.copyWith(deletedAt: _now)), isNull);
    expect(_suggest(_event.copyWith(startUtc: null)), isNull);
  });

  test('not again once it has travel time', () {
    expect(_suggest(_event.copyWith(travelBufferMin: 10)), isNull);
  });

  test('not for an all-day item', () {
    expect(_suggest(_event.copyWith(durationMin: maxDurationMin)), isNull);
  });

  test('every offered length is a valid travel buffer and passes', () {
    for (final m in Settings.travelChoices) {
      expect(m, inInclusiveRange(1, maxTravelBufferMin));
      expect(
        validateSettings(Settings(travelTimeMin: m)) is Ok,
        isTrue,
        reason: '$m',
      );
    }
    expect(
      validateSettings(const Settings(travelTimeMin: 7)),
      isA<Err<Settings, ValidationFailure>>(),
    );
  });
}
