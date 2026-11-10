/// Guest backups taken before the guest's work moved into an account (CR-160
/// guest-backup privacy, P1): they hold that work, so later guest sessions
/// can neither list nor restore them. A backup taken after the move stays
/// the guest's.
///
/// Which backups came "before" is decided by backup id, never by time
/// (clocks move; ids only grow: `backups.id` is AUTOINCREMENT). The move
/// writes `pending` for the guest inside its own transaction; the cutoff is
/// then the last backup id issued, recorded under [guestBackupFence].
///
/// Why that is exact: a backup is its read of the account plus its insert
/// into the backups file, two databases. [guestBackupFence] runs every
/// backup, list, import and restore, and the sign-in step that moves guest
/// work followed by recording the cutoff, one at a time. So a backup either
/// finished before the move (its id is at or below the cutoff: hidden) or
/// started after the cutoff was recorded (above it: the guest's). A backup
/// read before the move but stored after it cannot happen.
///
/// After a crash between the move and recording the cutoff, `pending`
/// stays: hiding fails closed (every backup of that guest is hidden), and
/// the first fenced operation records the cutoff before anything else.
/// No backup of the guest can have been taken in between (taking one
/// records the cutoff first), so recovery never hides a post-move backup
/// or reveals a pre-move one. Backups are only made in the app's main
/// isolate (housekeeping, Settings), never in background refresh, and a
/// web database belongs to one tab, so one fence per isolate serialises
/// them all. That is the supported set today; a backup made from another
/// isolate or process would need a lock this fence does not provide.
///
/// Known limits: a move made before this existed recorded no cutoff, so
/// that guest's earlier backups stay visible (an open privacy risk: Finding
/// X still refuses rows another account holds, but not re-keyed starters or
/// a deleted account's work). If the backups file is ever recreated, its ids
/// start again and a guest's new backups can fall under an old cutoff:
/// hidden too (fail closed), never the reverse. "Start fresh" moves only the
/// app database aside; the new guest profile has a new id, so the old
/// guest's backups are never listed again.
library;

import 'dart:async';

import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owned_local_meta.dart';
import 'package:drift/drift.dart';

const _kind = 'guest_backup_cutoff';
const _pending = 'pending';

/// Runs backup work and guest-work moves one at a time (see the library
/// doc). Never call [SerialFence.run] from inside a fenced body: it would
/// wait for itself.
final guestBackupFence = SerialFence();

/// One body at a time, in call order.
final class SerialFence {
  Future<void> _tail = Future.value();

  Future<T> run<T>(Future<T> Function() body) {
    final result = _tail.then((_) => body());
    _tail = result.then((_) {}, onError: (Object _) {});
    return result;
  }
}

/// Whether, and up to which backup id, [guest]'s backups are hidden.
sealed class GuestCutoff {
  const GuestCutoff();

  /// Whether backup [id] of this owner is hidden.
  bool hides(int id);
}

/// No guest work of this owner ever moved: nothing hidden.
final class NoCutoff extends GuestCutoff {
  const NoCutoff();
  @override
  bool hides(int id) => false;
}

/// Work moved, cutoff not recorded yet: everything hidden (fail closed).
final class PendingCutoff extends GuestCutoff {
  const PendingCutoff();
  @override
  bool hides(int id) => true;
}

/// Backups up to [upTo] were taken before the last move.
final class CutoffAt extends GuestCutoff {
  const CutoffAt(this.upTo);
  final int upTo;
  @override
  bool hides(int id) => id <= upTo;
}

/// In the transaction that moves [guest]'s work into an account: from its
/// commit, every backup of [guest] is hidden until the cutoff is recorded.
Future<void> markGuestBackupsPending(AppDatabase db, String guest) => db
    .into(db.localMeta)
    .insertOnConflictUpdate(
      LocalMetaCompanion.insert(key: ownedKey(_kind, guest), value: _pending),
    );

/// [owner]'s cutoff (only ever set for a guest whose work moved).
Future<GuestCutoff> guestBackupCutoff(AppDatabase db, String owner) async {
  final value =
      (await (db.select(db.localMeta)
                ..where((m) => m.key.equals(ownedKey(_kind, owner))))
              .getSingleOrNull())
          ?.value;
  if (value == null) return const NoCutoff();
  final upTo = int.tryParse(value);
  return upTo == null ? const PendingCutoff() : CutoffAt(upTo);
}

/// Records every pending cutoff as the last backup id issued. Only under
/// [guestBackupFence], right after a move or before any fenced backup work
/// (crash recovery).
Future<void> recordPendingGuestCutoffs(
  AppDatabase db,
  BackupDatabase backups,
) async {
  final pending = await (db.select(
    db.localMeta,
  )..where((m) => m.key.like('$_kind:%') & m.value.equals(_pending))).get();
  if (pending.isEmpty) return;
  final issued = await backups
      .customSelect(
        'SELECT COALESCE((SELECT seq FROM sqlite_sequence WHERE name = '
        "'backups'), 0) AS seq",
      )
      .getSingle()
      .then((r) => r.read<int>('seq'));
  for (final row in pending) {
    await db
        .into(db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(key: row.key, value: '$issued'),
        );
  }
}
