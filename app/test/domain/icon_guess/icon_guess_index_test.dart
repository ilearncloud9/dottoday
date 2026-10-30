import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/gen_icon_guess.dart' as gen;
import '../../../tool/gen_task_icons.dart' as icons;

icons.IconLibrary _library() => icons.IconLibrary.parse(
  jsonDecode(File(icons.inputPath).readAsStringSync()),
);

Map<String, Object?> _keywords() =>
    jsonDecode(File(gen.keywordsPath).readAsStringSync())
        as Map<String, Object?>;

void main() {
  // Freshness gate: an edited keyword or icon JSON without a re-run fails CI.
  test('${gen.outputPath} is up to date', () async {
    final dir = await Directory('.dart_tool').createTemp('guess');
    addTearDown(() => dir.delete(recursive: true));
    final fresh = '${dir.path}/out.dart';
    await icons.writeFormatted(
      gen.renderIconGuessIndex(_library(), _keywords()),
      fresh,
    );
    expect(
      File(fresh).readAsStringSync(),
      File(gen.outputPath).readAsStringSync(),
      reason: 'Run: dart run tool/gen_icon_guess.dart',
    );
  });

  group('rejects', () {
    void rejects(void Function(Map<String, Object?> doc) change) {
      final doc = _keywords();
      change(doc);
      expect(
        () => gen.renderIconGuessIndex(_library(), doc),
        throwsFormatException,
      );
    }

    Map<String, Object?> kw(Map<String, Object?> d) =>
        d['keywords']! as Map<String, Object?>;

    test('an unknown icon', () {
      rejects(
        (d) => kw(d)['nope'] = {
          for (final l in icons.languages) l: ['x'],
        },
      );
    });

    test('a missing language', () {
      rejects((d) => (kw(d)['gym']! as Map).remove('fr'));
    });

    test('a strong term on two icons', () {
      rejects(
        (d) => (kw(d)['pizza'] = {
          for (final l in icons.languages) l: ['gym'],
        }),
      );
    });

    test('an unknown colour', () {
      rejects((d) => (d['colors']! as Map)['health'] = 'plaid');
    });
  });
}
