import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/guest_backup_scrub.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/onboarding/starter_habits.dart';
import 'package:dottoday/domain/sync/stable_ids.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/guest_backup_world.dart';
import '../../support/owner_app.dart';

// P2 (CR-160 I1): once the deletion of the account guest work moved into
// is confirmed, the guest backups holding that work lose it, keep the
// guest's own work, and are the guest's again. Nothing happens on an
// unconfirmed or ambiguous deletion; a backup that can't be scrubbed
// safely stays hidden and is never deleted; reruns are safe.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _b = '01928c3e-0000-7000-8000-00000000000b';
const _secret = '01928c3e-0000-7000-8000-0000000006a1';
const _kept = '01928c3e-0000-7000-8000-0000000006b1';

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

  /// A backup holding the guest's kept work (an earlier session: it never
  /// moves) and the work that moves into [account].
  Future<int> mixedThenPromote(String account) async {
    await w.write(guest, [w.task(guest, _kept, 'Kept')]);
    await w.app.owners.signOut(); // a new guest session
    await w.write(guest, [w.task(guest, _secret, 'Secret plan')]);
    final mixed = await w.backup(guest);
    await w.promote(account);
    return mixed;
  }

  test('confirmed deletion: the mixed backup keeps the guest\'s work, loses '
      'the account\'s, and is the guest\'s again', () async {
    final mixed = await mixedThenPromote(_a);
    expect(await w.json(mixed), contains(_secret));
    await w.app.owners.accountDeleted(_a);
    expect(await w.app.shown(), guest);
    expect(await w.json(mixed), isNot(contains(_secret)));
    expect(await w.json(mixed), contains(_kept));
    expect(await w.listed(), contains(mixed));
    expect(await w.backups.restore(guest, mixed), isA<Ok<void, AppFailure>>());
    final titles = await w.titlesOf(guest);
    expect(titles, contains('Kept'));
    expect(titles, isNot(contains('Secret plan')));
  });

  test('no confirmed deletion: sign-out, a sealed (unknown-outcome) account '
      'or a removal never begun scrub nothing', () async {
    final mixed = await mixedThenPromote(_a);
    await sealForDeletion(w.db, _a); // an outcome not known
    await w.app.owners.signOut();
    await w.app.owners.finishRemoval(_a); // no removal pending: no-op
    expect(await w.json(mixed), contains(_secret));
    expect(await w.listed(), isNot(contains(mixed)));
    expect(await w.backups.restore(guest, mixed), isA<Err<void, AppFailure>>());
  });

  test('a re-keyed starter task is scrubbed out too', () async {
    final day = DateTime.utc(
      ownerAppNow.year,
      ownerAppNow.month,
      ownerAppNow.day,
    );
    final starter = occurrenceFixture().copyWith(
      id: starterTaskId(guest, StarterHabit.walk, day),
      userId: guest,
      seriesId: null,
      tzId: 'UTC',
      startUtc: ownerAppNow,
      title: 'Walk',
    );
    await w.write(guest, [starter]);
    final before = await w.backup(guest);
    await w.promote(_a);
    await w.app.owners.accountDeleted(_a);
    expect(await w.json(before), isNot(contains(starter.id)));
    await w.backups.restore(guest, before);
    expect(await w.titlesOf(guest), isNot(contains('Walk')));
  });

  test('several promotions: deleting A scrubs only what A governs; B\'s stay '
      'hidden; account backups untouched', () async {
    await w.write(guest, [w.task(guest, _secret, 'For A')]);
    final g1 = await w.backup(guest);
    await w.promote(_a);
    final aOwn = await w.backup(_a);
    await w.app.owners.signOut();
    await w.write(guest, [
      w.task(guest, '01928c3e-0000-7000-8000-0000000006c1', 'For B'),
    ]);
    final g2 = await w.backup(guest);
    await w.promote(_b);
    final bOwn = await w.backup(_b);
    await w.app.signIn(_a);
    await w.app.owners.accountDeleted(_a);
    final stored = {
      for (final r in await w.store.select(w.store.backups).get()) r.id,
    };
    expect(stored, isNot(contains(aOwn)), reason: "A's own: deleted with A");
    expect(stored, contains(bOwn));
    expect(await w.json(g1), isNot(contains(_secret)));
    expect(await w.json(g2), contains('For B'));
    final v = await guestBackupVisibility(w.db, guest);
    expect(v.hides(g1), isFalse);
    expect(v.hides(g2), isTrue);
    expect(
      await w.backups.restore(guest, g2),
      isA<Err<void, AppFailure>>(),
      reason: 'direct restore of a hidden one',
    );
  });

  test('crash after the rewrite, before it was recorded: still hidden; the '
      'rerun records it, content unchanged; reruns are no-ops', () async {
    final mixed = await mixedThenPromote(_a);
    final p = (await guestPromotions(w.db, guest)).single;
    final clean = scrubbedBackupJson(await w.json(mixed), guest, p.moved)!;
    await (w.store.update(w.store.backups)..where((b) => b.id.equals(mixed)))
        .write(BackupsCompanion(json: Value(clean)));
    expect((await guestBackupVisibility(w.db, guest)).hides(mixed), isTrue);
    expect(await scrubForDeletedAccount(w.db, w.store, _a), 0);
    expect((await guestBackupVisibility(w.db, guest)).hides(mixed), isFalse);
    expect(await w.json(mixed), clean);
    expect(await scrubForDeletedAccount(w.db, w.store, _a), 0);
    expect(await w.json(mixed), clean);
  });

  test('a backup that can\'t be scrubbed safely stays hidden and is never '
      'deleted; the removal still finishes', () async {
    final mixed = await mixedThenPromote(_a);
    final original = await w.json(mixed);
    // Corrupt it the way a restore would refuse (not a backup of the guest).
    await (w.store.update(w.store.backups)..where((b) => b.id.equals(mixed)))
        .write(BackupsCompanion(json: Value(original.replaceFirst(guest, _b))));
    await w.app.owners.accountDeleted(_a);
    expect(await w.json(mixed), original.replaceFirst(guest, _b));
    expect(await w.listed(), isNot(contains(mixed)));
    expect(await scrubForDeletedAccount(w.db, w.store, _a), 1, reason: 'left');
  });

  test('a backup taken while the deletion cleans up never holds the '
      'account\'s work and is never hidden wrongly', () async {
    await mixedThenPromote(_a);
    final deleting = w.app.owners.accountDeleted(_a);
    final during = w.backups.create(guest, BackupReason.daily);
    await deleting;
    final id = (await during).when(ok: (b) => b.id, err: (f) => fail(f.code));
    expect(await w.json(id), isNot(contains(_secret)));
    for (final b in await w.backups.list()) {
      expect(await w.json(b.id), isNot(contains(_secret)));
    }
  });

  test('a hidden backup is never the last restorable one kept', () async {
    final mixed = await mixedThenPromote(_a);
    final v = await guestBackupVisibility(w.db, guest);
    expect(v.hides(mixed), isTrue);
  });
}
