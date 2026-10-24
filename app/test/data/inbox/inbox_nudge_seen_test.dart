import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/inbox/inbox_nudge_seen.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// The day "Plan your inbox" was put away, per device (docs/05, M8.4c).

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('never put away: null', () async {
    expect(await container().read(inboxNudgeSeenProvider.future), isNull);
  });

  test('put away survives a restart as a local date', () async {
    final c = container();
    await c.read(inboxNudgeSeenProvider.future);
    await c
        .read(inboxNudgeSeenProvider.notifier)
        .putAway(DateTime(2026, 10, 21, 9, 30));
    expect(c.read(inboxNudgeSeenProvider).value, DateTime(2026, 10, 21));
    final again = container();
    expect(
      await again.read(inboxNudgeSeenProvider.future),
      DateTime(2026, 10, 21),
    );
  });
}
