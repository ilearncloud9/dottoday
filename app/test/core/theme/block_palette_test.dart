import 'dart:convert';
import 'dart:io';

import 'package:dottoday/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/gen_block_palette.dart' as gen;

/// WCAG 2.x contrast ratio between two opaque colours.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

const _modes = [
  ('light', BlockPalette.light, AppColors.light),
  ('dark', BlockPalette.dark, AppColors.dark),
];

Object? _paletteJson() => jsonDecode(File(gen.inputPath).readAsStringSync());

void main() {
  test('the 12 names and order fixed in docs/03 §1', () {
    const spec = 'coral tangerine amber lime mint teal '
        'sky indigo violet magenta rose slate';
    expect(BlockColor.values.map((c) => c.key), spec.split(' '));
  });

  test('fill alpha is 18 % light, 28 % dark', () {
    expect(BlockPalette.light.fillAlpha, 0.18);
    expect(BlockPalette.dark.fillAlpha, 0.28);
  });

  test('fromKey round-trips and falls back to the DB default (indigo)', () {
    for (final c in BlockColor.values) {
      expect(BlockColor.fromKey(c.key), c);
    }
    expect(BlockColor.fallback, BlockColor.indigo);
    expect(BlockColor.fromKey('chartreuse'), BlockColor.indigo);
    expect(BlockColor.fromKey(null), BlockColor.indigo);
  });

  for (final (mode, blocks, colors) in _modes) {
    group('$mode contrast', () {
      for (final c in BlockColor.values) {
        test('${c.key} strong ≥ 3:1 on surface (spec)', () {
          expect(
            _contrast(blocks[c].strong, colors.surface),
            greaterThanOrEqualTo(3),
          );
        });

        // Block titles are body text sitting on the tinted fill, so hold the
        // stricter 4.5:1 there (03 §4, R-12).
        test('${c.key} strong ≥ 4.5:1 on its own block fill', () {
          final fill = blocks.fill(c, colors.surface);
          expect(fill.a, 1);
          expect(_contrast(blocks[c].strong, fill), greaterThanOrEqualTo(4.5));
        });
      }
    });
  }

  test('themes expose the palette for their brightness', () {
    expect(AppTheme.light().extension<AppTheme>()!.blocks, BlockPalette.light);
    expect(AppTheme.dark().extension<AppTheme>()!.blocks, BlockPalette.dark);
  });

  test('lerp endpoints match the source palettes', () {
    final mid = BlockPalette.light.lerp(BlockPalette.dark, 1);
    for (final c in BlockColor.values) {
      expect(mid[c].base, BlockPalette.dark[c].base);
      expect(mid[c].strong, BlockPalette.dark[c].strong);
    }
    expect(mid.fillAlpha, closeTo(0.28, 1e-9));
  });

  group('generator', () {
    // Freshness gate: block_palette.gen.dart must equal a fresh render of the
    // JSON, so an edited palette without a re-run fails CI.
    test('committed output is up to date with palette.json', () async {
      // Inside the package so `dart format` uses its language version
      // (a system temp file gets the newer tall style).
      final dir = await Directory('.dart_tool').createTemp('palette');
      addTearDown(() => dir.delete(recursive: true));
      final fresh = '${dir.path}/block_palette.gen.dart';
      await gen.writeFormatted(gen.renderBlockPalette(_paletteJson()), fresh);

      expect(
        File(fresh).readAsStringSync(),
        File(gen.outputPath).readAsStringSync(),
        reason: 'Run: dart run tool/gen_block_palette.dart',
      );
    });

    test('rejects malformed palettes', () {
      Map<String, Object?> doc() =>
          jsonDecode(jsonEncode(_paletteJson())) as Map<String, Object?>;
      List<Object?> colorsOf(Map<String, Object?> d) =>
          d['colors']! as List<Object?>;
      Map<String, Object?> first(Map<String, Object?> d) =>
          colorsOf(d).first! as Map<String, Object?>;

      final badHex = doc();
      (first(badHex)['light']! as Map<String, Object?>)['strong'] = '#12345';
      final dupe = doc();
      colorsOf(dupe).add(first(dupe));
      final badDefault = doc()..['default'] = 'chartreuse';
      final badAlpha = doc()..['fillAlpha'] = {'light': 1.2, 'dark': 0.28};

      for (final bad in [badHex, dupe, badDefault, badAlpha, null]) {
        expect(
          () => gen.renderBlockPalette(bad),
          throwsFormatException,
        );
      }
    });
  });
}
