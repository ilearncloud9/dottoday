import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/entities/calendar_series_template.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/calendar_template_fixtures.dart';
import '../fixtures.dart';

// The D1 file's optional `calendarSeries` section (CR-160 Stage A): every
// setting round-trips, the file stays v1 and readable without the key, and
// a malformed or tampered item refuses the whole file.

const _tag = '0123456789abcdef';

ExportBundle _bundle(List<CalendarSeriesTemplate> templates) => ExportBundle(
  exportedAt: DateTime.utc(2026, 11, 10),
  profile: profileFixture(),
  occurrences: [occurrenceFixture()],
  calendarSeries: templates,
);

Result<ExportBundle, ValidationFailure> _decode(Object json) =>
    decodeExportJson(jsonEncode(json));

Map<String, Object?> _json(List<CalendarSeriesTemplate> t) =>
    jsonDecode(encodeExportJson(_bundle(t))) as Map<String, Object?>;

void main() {
  setUpAll(tz_data.initializeTimeZones);
  final device = fullTemplate(id: 't1', userId: userId, deviceTag: _tag);
  final cloud = fullTemplate(
    id: 't2',
    userId: userId,
    provider: CalendarProvider.google,
    calendarId: '7f0c…-conn/primary',
    seriesKey: 'g-weekly',
  );
  final hiddenOnly = fullTemplate(
    id: 't3',
    userId: userId,
    provider: CalendarProvider.androidDevice,
    calendarId: '3',
    seriesKey: '57',
    deviceTag: _tag,
    hidden: true,
  );

  test('every field round-trips, steps keep their order', () {
    final got =
        (_decode(_json([device, cloud, hiddenOnly])) as Ok).value
            as ExportBundle;
    expect(
      [for (final t in got.calendarSeries) t.toJson()],
      [
        for (final t in [device, cloud, hiddenOnly]) t.toJson(),
      ],
    );
    expect(
      got.calendarSeries.first.settings.subtaskTemplate!.map((s) => s.id),
      ['z', 'a', 'm'],
      reason: 'the stored order, not sorted',
    );
    expect(got.calendarSeries.last.settings.hidden, isTrue);
    expect(got.calendarSeries[1].deviceTag, isNull);
  });

  test('the file stays version 1; other exports carry no key at all', () {
    expect(_json([device])['version'], 1);
    expect(_json(const []).containsKey('calendarSeries'), isFalse);
  });

  test('an older file (no key) still imports, with no templates', () {
    final old = _json(const [])..remove('calendarSeries');
    final got = (_decode(old) as Ok).value as ExportBundle;
    expect(got.calendarSeries, isEmpty);
    expect(got.occurrences, hasLength(1));
  });

  test('an older importer (which ignores the key) reads the rest the same', () {
    final full = (_decode(_json([device])) as Ok).value as ExportBundle;
    final ignored =
        (_decode(_json([device])..remove('calendarSeries')) as Ok).value
            as ExportBundle;
    expect(
      ignored.occurrences.map((o) => o.toJson()),
      full.occurrences.map((o) => o.toJson()),
    );
  });

  test('a re-owned bundle re-owns its templates', () {
    final moved = _bundle([device]).reownedTo('someone-else');
    expect(moved.calendarSeries.single.userId, 'someone-else');
  });

  group('malformed or tampered items refuse the file', () {
    Map<String, Object?> item(Map<String, Object?> change) => {
      ...device.toJson(),
      ...change,
    };
    final cases = <String, Object?>{
      'unknown provider': item({'provider': 'icloud_web'}),
      'empty calendar id': item({'external_calendar_id': ''}),
      'calendar id too long': item({'external_calendar_id': 'c' * 257}),
      'calendar id not text': item({'external_calendar_id': 7}),
      'device tag on a cloud calendar': item({
        'provider': 'google',
        'device_tag': _tag,
      }),
      'device tag not its shape': item({'device_tag': '../../etc'}),
      'empty series key': item({'series_key': ''}),
      'series key too long': item({'series_key': 'k' * 513}),
      'settings out of range': item({'start_minute': 1440}),
      'another owner': item({'user_id': 'not-the-profile'}),
    };
    for (final MapEntry(:key, :value) in cases.entries) {
      test(key, () {
        final file = _json(const [])..['calendarSeries'] = [value];
        expect(_decode(file), isA<Err<ExportBundle, ValidationFailure>>());
      });
    }

    test('two templates for one calendar and series', () {
      final twin = fullTemplate(id: 't9', userId: userId, deviceTag: _tag);
      expect(
        _decode(_json([device, twin])),
        isA<Err<ExportBundle, ValidationFailure>>(),
      );
    });
  });
}
