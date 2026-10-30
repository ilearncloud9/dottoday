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

  test('a file from before 0008 imports its steps with no tick time', () {
    final json =
        jsonDecode(encodeExportJson(hostileBundle())) as Map<String, Object?>;
    final steps = (json['subtasks']! as List).cast<Map<String, Object?>>();
    expect(steps.first['done_at'], isNotNull);
    for (final s in steps) {
      s.remove('done_at');
    }
    final back = decodeExportJson(
      jsonEncode(json),
    ).when(ok: (b) => b, err: (f) => fail(f.code));
    expect(back.subtasks.map((s) => s.doneAt), everyElement(isNull));
    expect(back.subtasks.first.done, isTrue);
  });

  test('a file from before sounds imports every task as inherit', () {
    final json =
        jsonDecode(encodeExportJson(hostileBundle())) as Map<String, Object?>;
    final settings =
        (json['profile']! as Map<String, Object?>)['settings']!
            as Map<String, Object?>;
    for (final key in ['startSoundId', 'doneSoundId', 'inAppSoundsEnabled']) {
      settings.remove(key);
    }
    for (final table in ['series', 'occurrences']) {
      for (final row in (json[table]! as List).cast<Map<String, Object?>>()) {
        row.remove('sound_id');
      }
    }
    final back = decodeExportJson(
      jsonEncode(json),
    ).when(ok: (b) => b, err: (f) => fail(f.code));
    expect(back.series.single.soundId, isNull);
    expect(back.occurrences.map((o) => o.soundId), everyElement(isNull));
    final s = back.profile.settings;
    expect(
      (s.startSoundId, s.doneSoundId, s.inAppSoundsEnabled),
      ('dot_alarm', 'done.swift', true),
    );
  });

  test('a file from before routines imports with none (M11.4)', () {
    final json =
        jsonDecode(encodeExportJson(hostileBundle())) as Map<String, Object?>
          ..remove('routines');
    final back = decodeExportJson(
      jsonEncode(json),
    ).when(ok: (b) => b, err: (f) => fail(f.code));
    expect(back.routines, isEmpty);
    expect(back.occurrences, isNotEmpty);
  });

  test('a routine with no steps or a foreign owner is refused', () {
    final b = hostileBundle();
    final routine = b.routines.single;
    for (final bad in [
      routine.copyWith(items: const []),
      routine.copyWith(userId: 'someone-else'),
    ]) {
      final file = ExportBundle(
        exportedAt: b.exportedAt,
        profile: b.profile,
        series: b.series,
        occurrences: b.occurrences,
        subtasks: b.subtasks,
        routines: [bad],
      );
      expect(
        decodeExportJson(encodeExportJson(file)),
        isA<Err<Object?, Object?>>(),
      );
    }
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
      'routines',
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
      'wrong type': () =>
          _mutate((j) => _first(j, 'occurrences')['duration_min'] = 'long'),
      'unknown enum': () =>
          _mutate((j) => _first(j, 'occurrences')['status'] = 'archived'),
      'dangling subtask': () =>
          _mutate((j) => _first(j, 'subtasks')['occurrence_id'] = 'nope'),
      'dangling series': () =>
          _mutate((j) => _first(j, 'occurrences')['series_id'] = 'nope'),
      'duplicate id': () =>
          _mutate((j) => _rows(j, 'subtasks').add(_first(j, 'subtasks'))),
      'rows of another user': () =>
          _mutate((j) => _first(j, 'series')['user_id'] = 'someone-else'),
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

    test('a malformed sound id, with the field (docs/12 §3)', () {
      final text = _mutate((j) => _first(j, 'series')['sound_id'] = 'A b!');
      expect(_code(decodeExportJson(text)), 'validation.sound.invalidFormat');
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
    final b = decodeExportJson(
      text,
    ).when(ok: (b) => b, err: (f) => fail(f.code));
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
    final back = decodeExportJson(
      encodeExportJson(b),
    ).when(ok: (b) => b, err: (f) => fail(f.code));
    expect(back.profile.settings.quietHours, Settings.suggestedQuietHours);
    expect(back.series.first.alerts, const [
      Alert(kind: AlertKind.overdue, offsetMin: 15, sound: 'bell'),
    ]);
  });

  group('imported calendar events (M8.1)', () {
    ExportBundle withImport() {
      final b = hostileBundle();
      final event = b.occurrences.first.copyWith(
        id: '01928c3e-0000-7000-8000-0000000000e1',
        source: OccurrenceSource.calendar,
        seriesId: null,
      );
      final note = b.subtasks.first.copyWith(
        id: '01928c3e-0000-7000-8000-0000000000e2',
        occurrenceId: event.id,
      );
      return ExportBundle(
        exportedAt: b.exportedAt,
        profile: b.profile,
        series: b.series,
        occurrences: [...b.occurrences, event],
        subtasks: [...b.subtasks, note],
      );
    }

    test('withoutImported drops them and their subtasks only', () {
      final b = withImport().withoutImported();
      expect(b.occurrences.map((o) => o.id), [
        for (final o in hostileBundle().occurrences) o.id,
      ]);
      expect(b.subtasks, hasLength(hostileBundle().subtasks.length));
    });

    test('a file written before M8.1 imports without them', () {
      final text = encodeExportJson(withImport());
      final b = decodeExportJson(
        text,
      ).when(ok: (b) => b, err: (f) => fail(f.code));
      expect(
        b.occurrences.any((o) => o.source == OccurrenceSource.calendar),
        isFalse,
      );
      expect(
        b.subtasks.map((s) => s.id),
        isNot(contains('01928c3e-0000-7000-8000-0000000000e2')),
      );
    });
  });
}
