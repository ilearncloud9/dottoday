import 'dart:convert';
import 'dart:math';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/reveal/hint_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/writes/write_harness.dart';
import '../domain/fixtures.dart';

// docs/14 §2.1 and §7, M16: "Hide, never remove". For any seeded database,
// full → minimal → full through the switch's own write leaves every table
// byte-identical. The profile row's write bookkeeping (updated_at,
// version, dirty) and the sync outbox move, as for any settings change;
// nothing else does.

/// Local write bookkeeping, not user data (docs/04 §4).
const _bookkeeping = {'change_log', 'field_seen', 'sync_cursors', 'local_meta'};
const _profileStamps = {'updated_at', 'version', 'dirty'};

Future<String> _snapshot(WriteHarness h) async {
  final out = <String, Object?>{};
  for (final t in h.db.allTables) {
    final name = t.actualTableName;
    if (_bookkeeping.contains(name)) continue;
    final rows = await h.db
        .customSelect('SELECT * FROM $name ORDER BY 1')
        .get();
    out[name] = [
      for (final r in rows)
        {
          for (final MapEntry(:key, :value) in r.data.entries)
            if (name != 'profiles' || !_profileStamps.contains(key)) key: value,
        },
    ];
  }
  return jsonEncode(out);
}

/// A random day's worth of rows for [seed]: tasks, a series, a routine,
/// hint records, odd settings — whatever a real profile might hold.
Future<void> _seed(WriteHarness h, int seed) async {
  final rnd = Random(seed);
  String id(int n) =>
      '01928c3e-0000-7000-8000-${n.toString().padLeft(12, '0')}';
  final settings = profileFixture().settings.copyWith(
    snapMinutes: const [1, 5, 10, 15][rnd.nextInt(4)],
    showFreeTime: rnd.nextBool(),
    inboxNudge: rnd.nextBool(),
    energySuggestions: rnd.nextBool() ? true : null,
    defaultDurationMin: 15 + rnd.nextInt(60),
  );
  await h.writes.apply(
    WriteBatch(
      userId: userId,
      profile: profileFixture().copyWith(settings: settings),
      series: [if (rnd.nextBool()) seriesFixture()],
      occurrences: [
        for (var i = 0; i < 1 + rnd.nextInt(12); i++)
          occurrenceFixture().copyWith(
            id: id(1000 + i),
            title: 'Task $seed.$i',
            startUtc: rnd.nextInt(4) == 0
                ? null
                : t0.add(Duration(minutes: 15 * rnd.nextInt(40))),
            durationMin: 5 + rnd.nextInt(120),
            moveCount: rnd.nextInt(5),
          ),
      ],
      routines: [if (rnd.nextBool()) routineFixture()],
      revealHints: [
        for (final hint in HintId.values)
          if (rnd.nextBool())
            RevealHint(
              id: revealHintRowId(userId, hint),
              userId: userId,
              hintId: hint,
              shownCount: rnd.nextInt(3),
              createdAt: t0,
              updatedAt: t0,
            ),
      ],
    ),
  );
}

void main() {
  for (var seed = 0; seed < 25; seed++) {
    test('seed $seed: full → minimal → full changes no row', () async {
      final h = WriteHarness(t1);
      addTearDown(h.dispose);
      await _seed(h, seed);
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            DriftSettingsRepository(h.db),
          ),
          writeUseCaseProvider.overrideWithValue(h.writes),
          clockProvider.overrideWithValue(h.clock),
          localProfileProvider.overrideWith((ref) async => profileFixture()),
        ],
      );
      addTearDown(container.dispose);
      final before = await _snapshot(h);
      final logged = (await h.changeLog()).length;
      for (final layout in [UiLayout.minimal, UiLayout.full]) {
        h.clock.advance(const Duration(minutes: 1));
        // The switch's own write (setLayout → updateSettings).
        await updateSettings(container, (s) => s.copyWith(uiLayout: layout));
      }
      expect(await _snapshot(h), before);
      // The flips queued the profile's settings for sync, and nothing else.
      final flips = (await h.changeLog()).skip(logged);
      expect(
        {for (final c in flips) (c.entity, c.field)},
        {('profiles', 'settings')},
      );
    });
  }
}
