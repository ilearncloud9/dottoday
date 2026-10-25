import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/release/whats_new_seen.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/release/releases.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        appVersionNameProvider.overrideWith((ref) async => '0.1.0'),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<String?> stored() async => (await (db.select(
    db.localMeta,
  )..where((m) => m.key.equals('whats_new_seen'))).getSingleOrNull())?.value;

  Future<List<Release>> unseen(ProviderContainer c) async {
    c.listen(unseenReleasesNowProvider, (_, _) {});
    await c.read(whatsNewSeenProvider.future);
    await c.read(appVersionNameProvider.future);
    return c.read(unseenReleasesNowProvider);
  }

  test('a fresh install records the running version: nothing new', () async {
    final c = container();
    expect(await unseen(c), isEmpty);
    expect(await stored(), '0.1.0');
  });

  test('after an update the new notes are offered once', () async {
    await db
        .into(db.localMeta)
        .insert(
          LocalMetaCompanion.insert(key: 'whats_new_seen', value: '0.0.9'),
        );
    final c = container();
    expect(await unseen(c), [Release.v0_1_0]);
    await c.read(whatsNewSeenProvider.notifier).markSeen('0.1.0');
    expect(c.read(unseenReleasesNowProvider), isEmpty);
    expect(await stored(), '0.1.0');
    // A later restart remembers.
    expect(await unseen(container()), isEmpty);
  });

  test('marking an older version never moves it back', () async {
    final c = container();
    await c.read(whatsNewSeenProvider.future);
    await c.read(whatsNewSeenProvider.notifier).markSeen('0.0.1');
    expect(await stored(), '0.1.0');
  });
}
