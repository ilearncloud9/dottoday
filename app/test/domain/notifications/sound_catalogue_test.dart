import 'dart:convert';
import 'dart:io';

import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.gen.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/gen_sound_catalogue.dart' as gen;

// The domain's copy of the manifest (docs/12 §3, §5) stays in step with
// assets/sounds/manifest.json; the defaults it falls back to exist.
void main() {
  test('the generated catalogue matches the manifest (run the generator)', () {
    final manifest = jsonDecode(File(gen.inputPath).readAsStringSync());
    expect([
      for (final e in soundCatalogueEntries) (e.id, e.category, e.file),
    ], gen.catalogueEntries(manifest));
  });

  test('every category name is a SoundCategory', () {
    expect(
      soundCatalogueEntries.map((e) => e.category).toSet(),
      everyElement(isIn(SoundCategory.values.map((c) => c.name))),
    );
  });

  test('the defaults ship, each in its tier', () {
    expect(catalogueSound(defaultReminderSoundId)?.category.isNormalTier, true);
    expect(catalogueSound(defaultStartSoundId)?.category, SoundCategory.start);
    expect(catalogueSound(defaultDoneSoundId)?.category, SoundCategory.done);
    expect(soundCatalogue.first.id, defaultReminderSoundId);
  });

  test('stored keys never collide with a sound id', () {
    expect(catalogueSound(soundNoneKey), isNull);
    expect(catalogueSound(soundSystemKey), isNull);
  });

  test('the first-party tones keep their stored keys', () {
    // Settings.reminderSound held these before docs/12; never remapped.
    for (final key in ['dot', 'chime', 'bell', 'ripple']) {
      expect(catalogueSound(key)?.category, SoundCategory.dottoday);
    }
  });
}
