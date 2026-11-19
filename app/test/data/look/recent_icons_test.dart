import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/look/recent_icons.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Recently used icons (ED-086; owner, 4c: on the device, the last 8).
void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  ProviderContainer app() {
    final c = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('newest first, no repeats, at most 8, and kept across runs', () async {
    final first = app();
    await first.read(recentIconsProvider.future);
    for (final k in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'b']) {
      await first.read(recentIconsProvider.notifier).use(k);
    }
    const want = ['b', 'i', 'h', 'g', 'f', 'e', 'd', 'c'];
    expect(first.read(recentIconsProvider).value, want);
    expect(await app().read(recentIconsProvider.future), want);
  });

  test('an unreadable stored value is an empty list', () async {
    await db
        .into(db.localMeta)
        .insert(LocalMetaCompanion.insert(key: 'recent_icons', value: '{'));
    expect(await app().read(recentIconsProvider.future), isEmpty);
  });
}
