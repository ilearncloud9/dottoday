/// Guest backups taken before the guest's work moved into an account (CR-160
/// I1, guest-backup privacy): they hold that work, so later guest sessions
/// can neither list nor restore them until it has been scrubbed out
/// (guest_backup_scrub.dart). A backup taken after the move is the guest's.
///
/// Each move is recorded as a [GuestPromotion]: the destination account,
/// the ids it moved (as the guest's backups hold them, before starters were
/// re-keyed), and its cutoff, the last backup id issued when the move
/// committed (ids only grow: `backups.id` is AUTOINCREMENT; never a time).
///
/// Why one promotion governs each hidden backup: [guestBackupFence] runs
/// every backup, list, import, restore and scrub, and the sign-in step that
/// moves guest work followed by recording its cutoff, one at a time. So a
/// backup at or below a cutoff finished before that move, and one above it
/// started after. Only work first written in the guest session a move ends
/// can move, and every change of owner starts a new session. So a backup
/// can hold the moved work of only the first promotion whose cutoff is at
/// or above its id: earlier promotions' work had left the guest before it
/// was taken, later ones' wasn't written yet. Scrubbing removes exactly that
/// promotion's ids.
///
/// The move records its promotion `pending` inside its own transaction.
/// While one is pending, every backup no recorded promotion governs is
/// hidden (fail closed); the first fenced operation records the cutoff
/// before anything else, and no backup can be taken in between (taking one
/// records it first), so recovery never hides a post-move backup or reveals
/// a pre-move one.
///
/// Scope of the fence: backups are only made in the app's main isolate
/// (housekeeping, Settings), never in background refresh, and a web
/// database belongs to one tab, so one fence per isolate serialises them.
/// A backup made from another isolate or process would need a lock this
/// fence does not provide.
///
/// Known limits: a move made before this existed recorded nothing, so that
/// guest's earlier backups stay visible (an open privacy risk). If the
/// backups file is ever recreated, ids start again and new backups can fall
/// under an old cutoff: hidden too (fail closed), never the reverse. "Start
/// fresh" moves only the app database aside; the new guest profile has a
/// new id, so the old guest's backups are never listed again.
library;

import 'dart:async';
import 'dart:convert';

import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/owned_local_meta.dart';
import 'package:drift/drift.dart';

const _kind = 'guest_backup_promotions';

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

/// The tables a move takes rows from, as `ExportBundle` names them.
const movedTables = ['series', 'occurrences', 'subtasks', 'routines'];

/// One move of a guest's work into [account].
final class GuestPromotion {
  const GuestPromotion({
    required this.account,
    required this.moved,
    this.cutoff,
    this.hiddenAtMs,
    this.scrubbed = const {},
  });

  factory GuestPromotion.fromJson(Map<String, Object?> json) {
    final moved = json['moved']! as Map<String, Object?>;
    return GuestPromotion(
      account: json['account']! as String,
      cutoff: json['cutoff'] as int?,
      hiddenAtMs: json['hiddenAt'] as int?,
      moved: {
        for (final t in movedTables)
          t: {for (final id in moved[t]! as List) id as String},
      },
      scrubbed: {for (final id in json['scrubbed']! as List) id as int},
    );
  }

  /// The account the work moved into.
  final String account;

  /// Row ids moved, per table, as the guest's backups hold them.
  final Map<String, Set<String>> moved;

  /// The last backup id issued at the move; null while pending.
  final int? cutoff;

  /// When the cutoff was recorded (UTC ms): the start of the 30 days.
  final int? hiddenAtMs;

  /// Backups this promotion governs that hold none of its work any more.
  final Set<int> scrubbed;

  bool get pending => cutoff == null;

  GuestPromotion copyWith({int? cutoff, int? hiddenAtMs, Set<int>? scrubbed}) =>
      GuestPromotion(
        account: account,
        moved: moved,
        cutoff: cutoff ?? this.cutoff,
        hiddenAtMs: hiddenAtMs ?? this.hiddenAtMs,
        scrubbed: scrubbed ?? this.scrubbed,
      );

  Map<String, Object?> toJson() => {
    'account': account,
    'cutoff': cutoff,
    'hiddenAt': hiddenAtMs,
    'moved': {
      for (final t in movedTables) t: [...?moved[t]]..sort(),
    },
    'scrubbed': [...scrubbed]..sort(),
  };
}

/// Which of one owner's backups are hidden, from its promotions in order.
final class GuestBackupVisibility {
  const GuestBackupVisibility(this.promotions);

  final List<GuestPromotion> promotions;

  /// The promotion whose moved work backup [id] may hold, if recorded.
  GuestPromotion? governing(int id) {
    for (final p in promotions) {
      if (!p.pending && id <= p.cutoff!) return p;
    }
    return null;
  }

  /// Whether backup [id] is hidden from listing and restoring.
  bool hides(int id) {
    final g = governing(id);
    if (g != null) return !g.scrubbed.contains(id);
    return promotions.any((p) => p.pending);
  }
}

/// [owner]'s promotions, oldest first (none for an account).
Future<List<GuestPromotion>> guestPromotions(
  AppDatabase db,
  String owner,
) async {
  final value =
      (await (db.select(db.localMeta)
                ..where((m) => m.key.equals(ownedKey(_kind, owner))))
              .getSingleOrNull())
          ?.value;
  if (value == null) return const [];
  return [
    for (final p in jsonDecode(value) as List)
      GuestPromotion.fromJson(p as Map<String, Object?>),
  ];
}

/// Replaces [guest]'s promotions.
Future<void> saveGuestPromotions(
  AppDatabase db,
  String guest,
  List<GuestPromotion> promotions,
) => db
    .into(db.localMeta)
    .insertOnConflictUpdate(
      LocalMetaCompanion.insert(
        key: ownedKey(_kind, guest),
        value: jsonEncode([for (final p in promotions) p.toJson()]),
      ),
    );

/// The guests that have promotions recorded.
Future<List<String>> guestsWithPromotions(AppDatabase db) async => [
  for (final m in await (db.select(
    db.localMeta,
  )..where((m) => m.key.like('$_kind:%'))).get())
    m.key.substring(_kind.length + 1),
];

/// [owner]'s backup visibility.
Future<GuestBackupVisibility> guestBackupVisibility(
  AppDatabase db,
  String owner,
) async => GuestBackupVisibility(await guestPromotions(db, owner));

/// In the transaction that moves [guest]'s work into [account]: records the
/// promotion, pending, so from its commit the guest's earlier backups are
/// hidden. [moved] holds the ids as they were before the move.
Future<void> markGuestBackupsPending(
  AppDatabase db,
  String guest, {
  required String account,
  required Map<String, Set<String>> moved,
}) async {
  final promotions = await guestPromotions(db, guest);
  await saveGuestPromotions(db, guest, [
    ...promotions,
    GuestPromotion(account: account, moved: moved),
  ]);
}

/// Records every pending promotion's cutoff as the last backup id issued,
/// at [nowUtc]. Only under [guestBackupFence], right after a move or before
/// any fenced backup work (crash recovery).
Future<void> recordPendingGuestCutoffs(
  AppDatabase db,
  BackupDatabase backups, {
  required DateTime nowUtc,
}) async {
  for (final guest in await guestsWithPromotions(db)) {
    final promotions = await guestPromotions(db, guest);
    if (!promotions.any((p) => p.pending)) continue;
    final issued = await lastBackupIdIssued(backups);
    await saveGuestPromotions(db, guest, [
      for (final p in promotions)
        p.pending
            ? p.copyWith(
                cutoff: issued,
                hiddenAtMs: nowUtc.millisecondsSinceEpoch,
              )
            : p,
    ]);
  }
}

/// The highest backup id ever issued in [backups] (0 before the first).
Future<int> lastBackupIdIssued(BackupDatabase backups) => backups
    .customSelect(
      'SELECT COALESCE((SELECT seq FROM sqlite_sequence WHERE name = '
      "'backups'), 0) AS seq",
    )
    .getSingle()
    .then((r) => r.read<int>('seq'));
