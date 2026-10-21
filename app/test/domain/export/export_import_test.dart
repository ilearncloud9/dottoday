import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'export_fixtures.dart';

// docs/08 §2 `export_import_test` (R-11). The pre-import backup is the
// data layer's job (M2.4, BackupService).

String _code(Result<ExportBundle, ValidationFailure> r) =>
    r.when(ok: (_) => 'ok', err: (f) => f.code);

String _mutate(void Function(Map<String, Object?> json) edit) {
  final json =
      jsonDecode(encodeExportJson(hostileBundle())) as Map<String, Object?>;
  edit(json);
  return jsonEncode(json);
}

List<Object?> _rows(Map<String, Object?> json, String table) =>
    json[table]! as List<Object?>;

Map<String, Object?> _first(Map<String, Object?> json, String table) =>
    _rows(json, table).first! as Map<String, Object?>;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('round trip equals the original (hostile fixture)', () {
    final original = hostileBundle();
    final text = encodeExportJson(original);
    final decoded = decodeExportJson(text);
    final back = decoded.when(ok: (b) => b, err: (f) => fail(f.code));
    expect(back.toJson(), original.toJson());
    // And export → import → export is byte-identical.
    expect(encodeExportJson(back), text);
  });

  test('v1 envelope keys and canonical values (docs/05)', () {
    final json =
        jsonDecode(encodeExportJson(hostileBundle())) as Map<String, Object?>;
    expect(json.keys, [
      'version',
      'exportedAt',
      'profile',
      'series',
      'occurrences',
      'subtasks',
    ]);
    expect(json['version'], 1);
    expect(json['exportedAt'], isA<int>());
    expect(_first(json, 'occurrences')['start_utc'], isA<int>());
  });

  group('import rejects', () {
    final cases = <String, String Function()>{
      'non-JSON': () => '{"version":1,',
      'array root': () => '[]',
      'newer version': () => _mutate((j) => j['version'] = 2),
      'missing version': () => _mutate((j) => j.remove('version')),
      'missing table': () => _mutate((j) => j.remove('subtasks')),
      'wrong type': () => _mutate(
            (j) => _first(j, 'occurrences')['duration_min'] = 'long',
          ),
      'unknown enum': () => _mutate(
            (j) => _first(j, 'occurrences')['status'] = 'archived',
          ),
      'dangling subtask': () => _mutate(
            (j) => _first(j, 'subtasks')['occurrence_id'] = 'nope',
          ),
      'dangling series': () => _mutate(
            (j) => _first(j, 'occurrences')['series_id'] = 'nope',
          ),
      'duplicate id': () => _mutate(
            (j) => _rows(j, 'subtasks').add(_first(j, 'subtasks')),
          ),
      'rows of another user': () => _mutate(
            (j) => _first(j, 'series')['user_id'] = 'someone-else',
          ),
    };
    for (final MapEntry(key: name, value: input) in cases.entries) {
      test(name, () {
        expect(
          _code(decodeExportJson(input())),
          'validation.importFile.invalidFormat',
        );
      });
    }

    test('rows that fail entity validation, with the field', () {
      final text = _mutate((j) => _first(j, 'occurrences')['title'] = '  ');
      expect(_code(decodeExportJson(text)), 'validation.title.required');
      final rule = _mutate((j) => _first(j, 'series')['rrule'] = 'WEEKLY');
      expect(
        _code(decodeExportJson(rule)),
        'validation.recurrence.invalidFormat',
      );
    });

    test('oversize files (> 25 MB)', () {
      final huge = ' ' * (maxImportBytes + 1);
      expect(_code(decodeExportJson(huge)), 'validation.importFile.tooLarge');
      // Multi-byte text is measured in UTF-8 bytes, not characters.
      final wide = 'é' * (maxImportBytes ~/ 2 + 1);
      expect(_code(decodeExportJson(wide)), 'validation.importFile.tooLarge');
    });
  });

  test('import trims titles and drops calendar links', () {
    final text = _mutate((j) {
      _first(j, 'occurrences')['title'] = '  Padded  ';
      _first(j, 'occurrences')['calendar_link_id'] = 'link-1';
    });
    final b =
        decodeExportJson(text).when(ok: (b) => b, err: (f) => fail(f.code));
    expect(b.occurrences.first.title, 'Padded');
    expect(b.occurrences.first.calendarLinkId, isNull);
  });

  test('reownedTo rewrites every owner id', () {
    final b = hostileBundle().reownedTo('me');
    expect(b.profile.id, 'me');
    expect(
      {
        ...b.series.map((s) => s.userId),
        ...b.occurrences.map((o) => o.userId),
        ...b.subtasks.map((s) => s.userId),
      },
      {'me'},
    );
  });

  test('profile settings survive the trip', () {
    final b = hostileBundle();
    final back = decodeExportJson(encodeExportJson(b))
        .when(ok: (b) => b, err: (f) => fail(f.code));
    expect(back.profile.settings.quietHours, Settings.suggestedQuietHours);
    expect(
      back.series.first.alerts,
      const [Alert(kind: AlertKind.overdue, offsetMin: 15, sound: 'bell')],
    );
  });
}
