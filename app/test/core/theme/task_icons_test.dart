import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dottoday/core/l10n/generated/app_localizations_en.dart';
import 'package:dottoday/core/l10n/generated/app_localizations_es.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/icon_keys.dart';
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:dottoday/shared/pickers/task_icon_grid.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/gen_task_icons.dart' as gen;

gen.IconLibrary _library() =>
    gen.IconLibrary.parse(jsonDecode(File(gen.inputPath).readAsStringSync()));

void main() {
  group('task icon library (docs/10 §3, ADR-0012)', () {
    test('Dottoday planning icons first, then the other categories', () {
      expect(TaskIconCategory.values.first, TaskIconCategory.planning);
      expect(TaskIcon.picker.first, TaskIcon.focusBlock);
      final order = TaskIcon.picker.map((i) => i.category.index).toList();
      expect(order, [...order]..sort(), reason: 'grouped by category');
      for (final c in TaskIconCategory.values) {
        expect(TaskIcon.picker.where((i) => i.category == c), isNotEmpty);
      }
    });

    test('every icon is unique, keyed and drawn; circle is the default', () {
      final keys = TaskIcon.values.map((i) => i.key).toSet();
      expect(keys, hasLength(TaskIcon.values.length));
      expect(TaskIcon.picker, hasLength(TaskIcon.values.length - 1));
      expect(TaskIcon.picker, isNot(contains(TaskIcon.circle)));
      expect(TaskIcon.fallback.key, defaultIconKey);
      expect(TaskIcon.fallback.glyph, isNull);
    });

    for (final icon in TaskIcon.picker) {
      test('${icon.key} parses on the grid', () {
        expect(iconKeyPattern.hasMatch(icon.key), isTrue);
        expectOnGrid(icon.glyph!);
      });
    }

    test("Concept A's 26 keys still resolve (stored data, docs/05)", () {
      const conceptA =
          'code run mail call meal book list language heart travel cart '
          'home tv bag music meds water pet gym car money gift camera star '
          'people document';
      for (final key in conceptA.split(' ')) {
        expect(TaskIcon.fromKey(key).key, key);
      }
    });

    test('fromKey: retired, newly real and unknown keys', () {
      expect(TaskIcon.fromKey('meeting'), TaskIcon.people);
      expect(TaskIcon.fromKey('flight'), TaskIcon.travel);
      expect(TaskIcon.fromKey('shopping'), TaskIcon.cart);
      // Pre-Concept A keys that are icons of their own now show them.
      expect(TaskIcon.fromKey('bike'), TaskIcon.bike);
      expect(TaskIcon.fromKey('coffee'), TaskIcon.coffee);
      expect(TaskIcon.fromKey('from_a_newer_app'), TaskIcon.circle);
      expect(TaskIcon.fromKey(null), TaskIcon.circle);
    });
  });

  group('names and search', () {
    final en = AppLocalizationsEn();
    test("Structured's names in English", () {
      expect(taskIconName(en, TaskIcon.run), 'Running');
      expect(taskIconName(en, TaskIcon.washingMachine), 'Washing Machine');
      expect(taskIconName(en, TaskIcon.keyIcon), 'Key');
      expect(taskIconName(en, TaskIcon.caseIcon), 'Case');
    });

    test('matches name, category and key words, ignoring accents', () {
      final es = AppLocalizationsEs();
      expect(iconMatches(en, TaskIcon.washingMachine, 'wash'), isTrue);
      expect(iconMatches(en, TaskIcon.washingMachine, 'Home'), isTrue);
      expect(iconMatches(es, TaskIcon.gym, 'gym'), isTrue);
      expect(iconMatches(es, TaskIcon.coffee, 'cafe'), isTrue);
      expect(iconMatches(en, TaskIcon.coffee, 'zzz'), isFalse);
      expect(iconMatches(en, TaskIcon.coffee, '  '), isTrue);
    });
  });

  group('generator', () {
    // Freshness gate: an edited task_icons.json without a re-run fails CI.
    final outputs = {
      gen.enumOutputPath: gen.renderTaskIcons,
      gen.namesOutputPath: gen.renderTaskIconNames,
    };
    for (final MapEntry(key: path, value: render) in outputs.entries) {
      test('$path is up to date with task_icons.json', () async {
        // Inside the package so `dart format` uses its language version.
        final dir = await Directory('.dart_tool').createTemp('icons');
        addTearDown(() => dir.delete(recursive: true));
        final fresh = '${dir.path}/out.dart';
        await gen.writeFormatted(render(_library()), fresh);
        expect(
          File(fresh).readAsStringSync(),
          File(path).readAsStringSync(),
          reason: 'Run: dart run tool/gen_task_icons.dart',
        );
      });
    }

    for (final lang in gen.languages) {
      test('app_$lang.arb carries the icon names', () {
        final arb = File(gen.arbPath(lang)).readAsStringSync();
        expect(
          gen.mergeArb(arb, _library(), lang),
          arb,
          reason: 'Run: dart run tool/gen_task_icons.dart && flutter gen-l10n',
        );
      });
    }

    test('rejects malformed libraries', () {
      Map<String, Object?> doc() =>
          jsonDecode(File(gen.inputPath).readAsStringSync())
              as Map<String, Object?>;
      List<Object?> iconsOf(Map<String, Object?> d) =>
          d['icons']! as List<Object?>;
      final dup = doc();
      iconsOf(dup).add(iconsOf(dup).first);
      expect(() => gen.IconLibrary.parse(dup), throwsFormatException);
      final badCategory = doc();
      (iconsOf(badCategory).first! as Map)['category'] = 'nope';
      expect(() => gen.IconLibrary.parse(badCategory), throwsFormatException);
      final noName = doc();
      ((iconsOf(noName).first! as Map)['name'] as Map).remove('fr');
      expect(() => gen.IconLibrary.parse(noName), throwsFormatException);
    });
  });
}

/// Stroke 2 needs 1 unit of room: the drawn outline stays within
/// 0.5…23.5. Sampled along the path, because `Path.getBounds` includes the
/// control points of curves, which large arcs push off the grid.
void expectOnGrid(DotGlyph glyph) {
  var (left, top, right, bottom) = (24.0, 24.0, 0.0, 0.0);
  for (final metric in glyph.path.computeMetrics()) {
    for (var d = 0.0; d <= metric.length; d += 0.05) {
      final p = metric.getTangentForOffset(d)!.position;
      left = math.min(left, p.dx);
      top = math.min(top, p.dy);
      right = math.max(right, p.dx);
      bottom = math.max(bottom, p.dy);
    }
  }
  expect(right - left + bottom - top, greaterThan(0));
  const tolerance = 0.01;
  expect(left, greaterThanOrEqualTo(0.5 - tolerance));
  expect(top, greaterThanOrEqualTo(0.5 - tolerance));
  expect(right, lessThanOrEqualTo(23.5 + tolerance));
  expect(bottom, lessThanOrEqualTo(23.5 + tolerance));
}
