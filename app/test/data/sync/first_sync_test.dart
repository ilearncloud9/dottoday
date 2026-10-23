import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_sync_server.dart';
import '../../support/sync_device.dart';

// An account's first sync on a device (docs/09 M6.4): what was made here
// before signing in stays; a returning account keeps its settings.

const _account = '01928c3e-0000-7000-8000-0000000000ff';
final _t = DateTime.utc(2026, 10, 23, 9);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeSyncServer server;
  late SyncDevice laptop;

  setUp(() async {
    server = FakeSyncServer(_account);
    laptop = SyncDevice(server, _t, name: 'laptop');
    await laptop.start();
    await laptop.h.writes.apply(
      WriteBatch(
        userId: _account,
        profile: profileFixture().copyWith(
          id: _account,
          tzId: 'Europe/Berlin',
          locale: 'de',
          updatedAt: _t,
        ),
        occurrences: [
          occurrenceFixture().copyWith(userId: _account, title: 'Server'),
        ],
      ),
    );
    await laptop.sync();
  });
  tearDown(() => laptop.close());

  Future<String?> tzOf(SyncDevice d) async =>
      (await DriftSettingsRepository(d.h.db).findLocalProfile())?.tzId;

  test(
    'a returning account: its settings win over a new device defaults',
    () async {
      final phone = SyncDevice(server, _t.add(const Duration(hours: 1)));
      addTearDown(phone.close);
      await phone.start(); // a fresh profile, America/New_York defaults
      await phone.sync();
      expect(await tzOf(phone), 'Europe/Berlin');
      expect(server.table('profiles')[_account]!['tz_id'], 'Europe/Berlin');
      expect(server.table('profiles')[_account]!['locale'], 'de');
    },
  );

  test(
    'a choice made on the new device before signing in still wins',
    () async {
      final phone = SyncDevice(server, _t.add(const Duration(hours: 1)));
      addTearDown(phone.close);
      await phone.start();
      phone.h.clock.advance(const Duration(minutes: 5));
      final mine = (await DriftSettingsRepository(
        phone.h.db,
      ).findLocalProfile())!;
      await phone.h.writes.apply(
        WriteBatch(
          userId: _account,
          profile: mine.copyWith(tzId: 'Asia/Tokyo'),
        ),
      );
      await phone.sync();
      expect(await tzOf(phone), 'Asia/Tokyo');
      expect(server.table('profiles')[_account]!['tz_id'], 'Asia/Tokyo');
      // The untouched field took the account's value.
      expect(server.table('profiles')[_account]!['locale'], 'de');
    },
  );

  test('a row made here before signing in wins its first sync', () async {
    // The same row, edited on this device earlier than the server copy.
    final phone = SyncDevice(server, _t.subtract(const Duration(hours: 1)));
    addTearDown(phone.close);
    await phone.start();
    await phone.write([
      occurrenceFixture().copyWith(userId: _account, title: 'Mine'),
    ]);
    await phone.sync();
    expect((await phone.occurrence(occurrenceFixture().id))!.title, 'Mine');
    expect(server.table('occurrences').values.single['title'], 'Mine');
  });

  test('progress: from 0 to all of it', () async {
    final phone = SyncDevice(server, _t.add(const Duration(hours: 1)));
    addTearDown(phone.close);
    await phone.start();
    final seen = <(int, int)>[];
    await phone.engine.run(_account, onProgress: (d, t) => seen.add((d, t)));
    expect(seen.first.$1, 0);
    expect(seen.last.$1, seen.last.$2);
    expect(seen.last.$2, greaterThanOrEqualTo(2));
    // Later runs are not a restore.
    seen.clear();
    await phone.engine.run(_account, onProgress: (d, t) => seen.add((d, t)));
    expect(seen, isEmpty);
  });
}
