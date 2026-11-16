import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/db/owned_local_meta.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/search/recent_searches.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/shown_owner.dart';

// Search › RECENT is the shown owner's alone (CR-160 I4): a switch, a
// restart and a switch back each show only that owner's queries.

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await addProfile(db, ownerA);
    await showOwner(db, ownerA);
  });
  tearDown(() => db.close());

  ProviderContainer open() {
    final c = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<List<String>> recent(ProviderContainer c) =>
      c.read(recentSearchesProvider.future);

  Future<void> switchTo(ProviderContainer c, String owner) async {
    await showOwner(db, owner);
    c.read(ownerEpochProvider.notifier).next();
  }

  test('remember puts a query first and keeps it across a restart', () async {
    final c = open();
    await recent(c);
    await c.read(recentSearchesProvider.notifier).remember('gym');
    await c.read(recentSearchesProvider.notifier).remember('dentist');
    expect(await recent(c), ['dentist', 'gym']);
    expect(await recent(open()), ['dentist', 'gym']);
  });

  test('a switch shows nothing of the previous owner; A→B→A', () async {
    await addProfile(db, ownerB);
    final c = open();
    await recent(c);
    await c.read(recentSearchesProvider.notifier).remember('A secret');
    await switchTo(c, ownerB);
    expect(await recent(c), isEmpty);
    await c.read(recentSearchesProvider.notifier).remember('B query');
    expect(await recent(open()), ['B query'], reason: 'after a restart');
    await switchTo(c, ownerA);
    expect(await recent(c), ['A secret']);
  });

  test(
    'a query committed across a switch is not given to the next owner',
    () async {
      await addProfile(db, ownerB);
      final c = open();
      await recent(c);
      final notifier = c.read(recentSearchesProvider.notifier);
      final late = notifier.remember('A late');
      await switchTo(c, ownerB);
      await late;
      expect(await recent(c), isEmpty);
    },
  );

  test('clear forgets the shown owner only', () async {
    await addProfile(db, ownerB);
    final c = open();
    await recent(c);
    await c.read(recentSearchesProvider.notifier).remember('A');
    await switchTo(c, ownerB);
    await recent(c);
    await c.read(recentSearchesProvider.notifier).remember('B');
    await c.read(recentSearchesProvider.notifier).clear();
    expect(await recent(c), isEmpty);
    await switchTo(c, ownerA);
    expect(await recent(c), ['A']);
  });

  group('the pre-CR-160 global list', () {
    Future<void> legacy() => db
        .into(db.localMeta)
        .insert(
          LocalMetaCompanion.insert(key: RecentSearches.kind, value: '["old"]'),
        );

    test('moves to the only profile', () async {
      await legacy();
      expect(await recent(open()), ['old']);
      expect(
        await (db.select(db.localMeta)..where(
              (m) => m.key.equals(ownedKey(RecentSearches.kind, ownerA)),
            ))
            .getSingleOrNull(),
        isNotNull,
      );
    });

    test('is never shown when the device has two profiles', () async {
      await addProfile(db, ownerB);
      await legacy();
      expect(await recent(open()), isEmpty);
      await showOwner(db, ownerB);
      expect(await recent(open()), isEmpty);
      final kept = await (db.select(
        db.localMeta,
      )..where((m) => m.key.equals(RecentSearches.kind))).getSingle();
      expect(kept.value, '["old"]', reason: 'kept untouched, shown to nobody');
    });
  });
}
