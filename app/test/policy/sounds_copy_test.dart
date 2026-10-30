import 'dart:convert';
import 'dart:io';

import 'package:dottoday/core/l10n/generated/app_localizations_en.dart';
import 'package:dottoday/data/notifications/sound_credits.gen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/gen_sound_catalogue.dart' as gen;

// docs/12 §1, §7: the Sounds strings pass the no-shame audit — beyond the
// app-wide words (no_shame_copy_test), no sound is "annoying" and none is an
// "error", in any language — and the one credit line names every credited
// source, rendered from the manifest.

/// The Sounds feature's keys: sound names and sections, the Sounds page,
/// the sound channels and groups, and the muted-sound health row.
final _soundKey = RegExp(
  r'^(sound|sounds|notifGroup|notifChannelAlarmsSound|'
  r'notifChannelAlertsSilent|healthSounds|sheetSound)',
);

final _banned = RegExp(
  r'(annoy|error|lästig|nervig|fehler|agaçant|ennuyeux|erreur|molest)',
  caseSensitive: false,
);

void main() {
  for (final locale in ['en', 'de', 'fr', 'es']) {
    test('$locale: no sound is annoying or an error', () {
      final arb =
          jsonDecode(
                File('lib/core/l10n/arb/app_$locale.arb').readAsStringSync(),
              )
              as Map<String, Object?>;
      final hits = [
        for (final MapEntry(:key, :value) in arb.entries)
          if (_soundKey.hasMatch(key) &&
              value is String &&
              _banned.hasMatch(value))
            '$key: $value',
      ];
      expect(hits, isEmpty);
      expect(
        arb.keys.where(_soundKey.hasMatch),
        isNotEmpty,
        reason: 'the key pattern still finds the Sounds strings',
      );
    });
  }

  test('the credits match the manifest (run the generator)', () {
    final manifest = jsonDecode(File(gen.inputPath).readAsStringSync());
    expect([
      for (final s in soundCreditSources) (s.name, s.url, s.license, s.notice),
    ], gen.creditEntries(manifest));
  });

  test('the credit line names every credited source and its licence', () {
    expect(soundCreditSources, isNotEmpty);
    final l10n = AppLocalizationsEn();
    for (final source in soundCreditSources) {
      final line = l10n.soundsCredit(source.name, source.license);
      expect(line, contains(source.name));
      expect(line, contains(source.license));
    }
    expect(
      l10n.soundsCredit('notificationsounds.com', 'CC BY 4.0'),
      'Sounds from notificationsounds.com (CC BY 4.0).',
      reason: 'docs/12 §1, word for word',
    );
  });
}
