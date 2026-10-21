import 'dart:convert';
import 'dart:io';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/task_color_keys.gen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/gen_task_palette.dart' as gen;

Object? _paletteJson() => jsonDecode(File(gen.inputPath).readAsStringSync());

final _themes = [
  for (final a in DotAccent.values) ...[
    ('light ${a.key}', DotColors.light(a)),
    ('dark ${a.key}', DotColors.dark(a)),
  ],
];

void main() {
  test('the 9 task colours and order of docs/10 §2.1', () {
    expect(
      TaskColor.values.map((c) => c.key).join(' '),
      'coral amber mint teal sky indigo violet rose slate',
    );
    expect(TaskColor.amber.color.toARGB32(), 0xFFD99A1F);
    expect(TaskColor.slate.color.toARGB32(), 0xFF6B6B70);
  });

  test('the 4 accents of Settings › Look', () {
    expect(DotAccent.values.map((a) => a.key), [
      'indigo',
      'teal',
      'coral',
      'violet',
    ]);
    expect(DotAccent.teal.dark.toARGB32(), 0xFF4CC9C9);
    expect(DotAccent.fallback, DotAccent.indigo);
  });

  test('domain key sets mirror the enums', () {
    expect(taskColorKeys, TaskColor.values.map((c) => c.key));
    expect(defaultTaskColorKey, TaskColor.fallback.key);
    expect(accentKeys, DotAccent.values.map((a) => a.key));
    expect(defaultAccentKey, DotAccent.fallback.key);
  });

  test('fromKey: current keys, retired keys, unknown keys', () {
    for (final c in TaskColor.values) {
      expect(TaskColor.fromKey(c.key), c);
    }
    expect(TaskColor.fromKey('tangerine'), TaskColor.amber);
    expect(TaskColor.fromKey('lime'), TaskColor.mint);
    expect(TaskColor.fromKey('magenta'), TaskColor.rose);
    expect(TaskColor.fromKey('chartreuse'), TaskColor.indigo);
    expect(TaskColor.fromKey(null), TaskColor.indigo);
    expect(legacyTaskColorKeys, ['tangerine', 'lime', 'magenta']);
  });

  test('segment alphas sit in the spec ranges', () {
    expect(TaskAlpha.upcoming, inInclusiveRange(0.28, 0.35));
    expect(TaskAlpha.done, 0.45);
  });

  for (final (name, colors) in _themes) {
    group('$name: task ink is text-grade (§7.4)', () {
      final tasks = TaskPalette.resolve(colors);
      for (final c in TaskColor.values) {
        test(c.key, () {
          final s = tasks[c];
          expect(s.color, c.color, reason: 'graphics keep the spec hue');
          expect(s.tint.a, 1);
          for (final bg in [colors.surface, colors.raised, s.tint]) {
            expect(contrastRatio(s.ink, bg), greaterThanOrEqualTo(4.5));
          }
        });
      }
    });
  }

  group('generator', () {
    // Freshness gate: an edited palette.json without a re-run fails CI.
    final outputs = {
      gen.outputPath: gen.renderTaskPalette,
      gen.keysOutputPath: gen.renderTaskColorKeys,
    };
    for (final MapEntry(key: path, value: render) in outputs.entries) {
      test('$path is up to date with palette.json', () async {
        // Inside the package so `dart format` uses its language version.
        final dir = await Directory('.dart_tool').createTemp('palette');
        addTearDown(() => dir.delete(recursive: true));
        final fresh = '${dir.path}/out.dart';
        await gen.writeFormatted(render(_paletteJson()), fresh);
        expect(
          File(fresh).readAsStringSync(),
          File(path).readAsStringSync(),
          reason: 'Run: dart run tool/gen_task_palette.dart',
        );
      });
    }

    test('rejects malformed palettes', () {
      Map<String, Object?> doc() =>
          jsonDecode(jsonEncode(_paletteJson())) as Map<String, Object?>;
      List<Object?> colorsOf(Map<String, Object?> d) =>
          d['colors']! as List<Object?>;

      final badHex = doc();
      (colorsOf(badHex).first! as Map<String, Object?>)['hex'] = '#12345';
      final dupe = doc();
      colorsOf(dupe).add(colorsOf(dupe).first);
      final badDefault = doc()..['default'] = 'chartreuse';
      final badAccent = doc()..['defaultAccent'] = 'amber';
      final legacyToLegacy = doc()..['legacy'] = {'lime': 'tangerine'};
      final legacyShadows = doc()..['legacy'] = {'coral': 'amber'};

      for (final bad in [
        badHex,
        dupe,
        badDefault,
        badAccent,
        legacyToLegacy,
        legacyShadows,
        null,
      ]) {
        expect(() => gen.renderTaskPalette(bad), throwsFormatException);
        expect(() => gen.renderTaskColorKeys(bad), throwsFormatException);
      }
    });
  });
}
