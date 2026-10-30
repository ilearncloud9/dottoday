import 'dart:math';

import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/12-sounds.md §3: alert → occurrence → series → settings → Dot;
// "none" stops the chain silent, "system" only counts in settings, and an
// unknown id never crashes and never silences.
BundledSound _bundled(String id) => BundledSound(resolveSound(id));

void main() {
  group('resolveReminderSound', () {
    test('nothing chosen anywhere plays the Dot tone', () {
      expect(resolveReminderSound(), _bundled('dot'));
      expect(
        resolveReminderSound(
          alert: null,
          occurrence: null,
          series: null,
          settings: null,
        ),
        _bundled('dot'),
      );
    });

    test('"none" at any level is silent', () {
      expect(
        resolveReminderSound(alert: 'none', occurrence: 'bell'),
        const SilentSound(),
      );
      expect(
        resolveReminderSound(occurrence: 'none', series: 'bell'),
        const SilentSound(),
      );
      expect(
        resolveReminderSound(series: 'none', settings: 'bell'),
        const SilentSound(),
      );
      expect(resolveReminderSound(settings: 'none'), const SilentSound());
    });

    test('an explicit id beats inherit, nearest level first', () {
      expect(resolveReminderSound(settings: 'chime'), _bundled('chime'));
      expect(
        resolveReminderSound(series: 'clear.lift', settings: 'chime'),
        _bundled('clear.lift'),
      );
      expect(
        resolveReminderSound(
          occurrence: 'play.frog',
          series: 'clear.lift',
          settings: 'chime',
        ),
        _bundled('play.frog'),
      );
      expect(
        resolveReminderSound(
          alert: 'bell',
          occurrence: 'play.frog',
          series: 'clear.lift',
          settings: 'none',
        ),
        _bundled('bell'),
      );
    });

    test('"system" is the OS sound only in settings', () {
      expect(resolveReminderSound(settings: 'system'), const SystemSound());
      expect(
        resolveReminderSound(series: 'clear.lift', settings: 'system'),
        _bundled('clear.lift'),
        reason: 'a task choice still beats the default',
      );
      for (final task in [
        resolveReminderSound(alert: 'system', settings: 'none'),
        resolveReminderSound(occurrence: 'system', settings: 'none'),
        resolveReminderSound(series: 'system', settings: 'none'),
      ]) {
        expect(task, _bundled('dot'), reason: 'unknown on a task: Dot');
      }
    });

    test('an unknown or other-tier id on a task plays Dot, never nothing', () {
      expect(resolveReminderSound(series: 'quiet.gone'), _bundled('dot'));
      expect(resolveReminderSound(series: 'start.morning'), _bundled('dot'));
      expect(resolveReminderSound(series: 'done.swift'), _bundled('dot'));
      expect(resolveReminderSound(settings: 'start.morning'), _bundled('dot'));
    });
  });

  group('tier sounds', () {
    test('Start keeps a Start sound, else the Dottoday alarm', () {
      expect(resolveStartSound('start.morning').id, 'start.morning');
      expect(resolveStartSound(null).id, 'dot_alarm');
      expect(resolveStartSound('start.gone').id, 'dot_alarm');
      expect(resolveStartSound('clear.lift').id, 'dot_alarm');
      expect(resolveStartSound('none').id, 'dot_alarm', reason: 'D2: loud');
    });

    test('Done keeps a Done sound, else Swift', () {
      expect(resolveDoneSound('done.checked').id, 'done.checked');
      expect(resolveDoneSound(null).id, 'done.swift');
      expect(resolveDoneSound('bell').id, 'done.swift');
    });
  });

  test('resolveSound maps an unknown id to its category default', () {
    expect(resolveSound('clear.lift').id, 'clear.lift');
    expect(resolveSound('start.gone').id, 'dot_alarm');
    expect(resolveSound('done.gone').id, 'done.swift');
    expect(resolveSound('quiet.gone').id, 'dot');
    expect(resolveSound(null).id, 'dot');
  });

  // Property: total over any stored string — never throws, never null,
  // always a sound this version ships (docs/12 §7).
  test('resolution is total over arbitrary ids (seeded)', () {
    final rnd = Random(12);
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789._- /\\"é\u{1F514}';
    String? any() {
      final pick = rnd.nextInt(10);
      if (pick == 0) return null;
      if (pick == 1) return soundNoneKey;
      if (pick == 2) return soundSystemKey;
      if (pick == 3) {
        return soundCatalogue[rnd.nextInt(soundCatalogue.length)].id;
      }
      return String.fromCharCodes([
        for (var i = 0; i < rnd.nextInt(70); i++)
          alphabet.codeUnitAt(rnd.nextInt(alphabet.length)),
      ]);
    }

    for (var i = 0; i < 2000; i++) {
      final id = any();
      expect(soundCatalogue, contains(resolveSound(id)));
      expect(resolveStartSound(id).category, SoundCategory.start);
      expect(resolveDoneSound(id).category, SoundCategory.done);
      final choice = resolveReminderSound(
        alert: any(),
        occurrence: any(),
        series: any(),
        settings: any(),
      );
      if (choice case BundledSound(:final sound)) {
        expect(sound.category.isNormalTier, isTrue);
      }
    }
  });
}
