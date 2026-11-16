import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/guest_backup_scrub.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/guest_backup_world.dart';
import '../../support/owner_app.dart';

// P3 (CR-160 I1): a promotion's hidden backups are scrubbed (its moved work
// out, the guest's kept) at the first maintenance run once 30 days have
// passed since its cutoff was recorded: not before, whatever the clock
// does; not exactly at day 30 if the app isn't running then.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _b = '01928c3e-0000-7000-8000-00000000000b';
const _secret = '01928c3e-0000-7000-8000-0000000007a1';
const _day = Duration(days: 1);

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late GuestBackupWorld w;
  late String guest;
  setUp(() async {
    w = GuestBackupWorld();
    guest = await w.app.shown();
  });
  tearDown(() => w.dispose());

  Future<int> hiddenBackup(String account) async {
    await w.write(guest, [w.task(guest, _secret, 'Moved')]);
    final id = await w.backup(guest);
    await w.promote(account);
    return id;
  }

  /// Housekeeping's maintenance run.
  Future<void> maintain() async {
    await w.backups.runDailyIfDue(await w.app.shown());
  }

  Future<bool> hidden(int id) async =>
      (await guestBackupVisibility(w.db, guest)).hides(id);

  test('29 days: still hidden; exactly 30: scrubbed at the next run', () async {
    final id = await hiddenBackup(_a);
    w.clock.advance(_day * 29);
    await maintain();
    expect(await hidden(id), isTrue);
    expect(await w.json(id), contains(_secret));
    w.clock.advance(_day);
    await maintain();
    expect(await hidden(id), isFalse);
    expect(await w.json(id), isNot(contains(_secret)));
  });

  test('well past 30 days (the app was not running): the first run scrubs '
      'it', () async {
    final id = await hiddenBackup(_a);
    w.clock.advance(_day * 75);
    await maintain();
    expect(await hidden(id), isFalse);
  });

  test('the clock set back: nothing early; it waits for 30 days from the '
      'recorded time', () async {
    final id = await hiddenBackup(_a);
    w.clock.now = ownerAppNow.subtract(_day * 400);
    await maintain();
    expect(await hidden(id), isTrue, reason: 'recorded "in the future"');
    w.clock.now = ownerAppNow.add(_day * 29);
    await maintain();
    expect(await hidden(id), isTrue);
    w.clock.now = ownerAppNow.add(_day * 30);
    await maintain();
    expect(await hidden(id), isFalse);
  });

  test('an interrupted run (rewritten, not recorded) completes on the next '
      'run', () async {
    final id = await hiddenBackup(_a);
    final p = (await guestPromotions(w.db, guest)).single;
    final clean = scrubbedBackupJson(await w.json(id), guest, p.moved)!;
    await (w.store.update(w.store.backups)..where((b) => b.id.equals(id)))
        .write(BackupsCompanion(json: Value(clean)));
    expect(await hidden(id), isTrue);
    w.clock.advance(_day * 30);
    await maintain();
    expect(await hidden(id), isFalse);
    expect(await w.json(id), clean);
  });

  test('backups after the promotion are untouched; a deletion scrub first '
      'leaves nothing for P3 to do', () async {
    final id = await hiddenBackup(_a);
    await w.app.owners.signOut();
    final after = await w.backup(guest);
    final afterJson = await w.json(after);
    w.clock.advance(_day * 5);
    await w.app.signIn(_a);
    await w.app.owners.accountDeleted(_a);
    expect(await hidden(id), isFalse, reason: 'P2 came first');
    final scrubbed = await w.json(id);
    w.clock.advance(_day * 30);
    await maintain();
    expect(await w.json(id), scrubbed);
    expect(await w.json(after), afterJson);
    expect(await hidden(after), isFalse);
  });

  test('repeated promotions and A -> B -> A: each expires 30 days after its '
      'own cutoff', () async {
    final g1 = await hiddenBackup(_a);
    await w.app.owners.signOut();
    w.clock.advance(_day * 10);
    await w.write(guest, [
      w.task(guest, '01928c3e-0000-7000-8000-0000000007b1', 'Moved to B'),
    ]);
    final g2 = await w.backup(guest);
    await w.promote(_b);
    await w.app.signIn(_a);
    w.clock.advance(_day * 20); // day 30 for A, day 20 for B
    await maintain();
    expect(await hidden(g1), isFalse);
    expect(await hidden(g2), isTrue);
    w.clock.advance(_day * 10);
    await maintain();
    expect(await hidden(g2), isFalse);
    expect(await w.json(g2), isNot(contains('Moved to B')));
  });

  test('a backup over the import limit is never scrubbed or deleted', () {
    final oversized = '{"pad":"${'a' * (maxImportBytes + 1)}"}';
    expect(scrubbedBackupJson(oversized, guest, const {}), isNull);
  });
}
