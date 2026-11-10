/// Scrubbing a hidden guest backup (CR-160 I1, P2 and P3): the rows its
/// governing promotion moved into an account are taken out, the rest of the
/// guest's work is kept, and the backup is shown to the guest again.
///
/// - P2: when the account the work moved into is deleted, confirmed
///   (`finishAccountRemoval` runs only after the server's "deleted",
///   recorded durably by `beginAccountRemoval`), so the deleted account's
///   work never stays on the device in a guest backup.
/// - P3: 30 days after the promotion's cutoff was recorded, at the next
///   maintenance run, so moved work is not kept indefinitely.
///
/// A backup is rewritten in place (same id, date and reason) only after the
/// scrubbed copy reads back as the guest's complete, restorable backup and
/// holds none of the moved ids; then it is recorded as scrubbed. A crash
/// between the two leaves it hidden; the next run finds nothing to remove
/// and records it. A backup that can't be read safely (over the import
/// limit, or not a valid backup of the guest) is left as it is, hidden:
/// never deleted, never shown. Runs under `guestBackupFence`.
library;

import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/backup/backup_restorability.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/drift.dart';

/// How long a promotion keeps its backups hidden before P3 scrubs them.
const hiddenGuestBackupLifetime = Duration(days: 30);

/// P2: scrubs every guest backup governed by a promotion into [account],
/// whose deletion is confirmed. Returns how many backups could not be
/// scrubbed (left hidden).
Future<int> scrubForDeletedAccount(
  AppDatabase db,
  BackupDatabase backups,
  String account,
) => _scrubWhere(db, backups, (p) => p.account == account);

/// P3: scrubs every guest backup governed by a promotion hidden for at
/// least [hiddenGuestBackupLifetime] at [nowUtc]. A cutoff recorded "in the
/// future" (the clock went back) waits until it is in the past. Returns how
/// many backups could not be scrubbed (left hidden).
Future<int> scrubExpiredGuestBackups(
  AppDatabase db,
  BackupDatabase backups, {
  required DateTime nowUtc,
}) {
  final now = nowUtc.millisecondsSinceEpoch;
  return _scrubWhere(db, backups, (p) {
    final at = p.hiddenAtMs;
    // Also false for a time "in the future": never early.
    return at != null && now - at >= hiddenGuestBackupLifetime.inMilliseconds;
  });
}

Future<int> _scrubWhere(
  AppDatabase db,
  BackupDatabase backups,
  bool Function(GuestPromotion) due,
) async {
  var left = 0;
  for (final guest in await guestsWithPromotions(db)) {
    final promotions = await guestPromotions(db, guest);
    for (var i = 0; i < promotions.length; i++) {
      final p = promotions[i];
      if (p.pending || !due(p)) continue;
      left += await _scrubPromotion(db, backups, guest, i);
    }
  }
  return left;
}

/// Scrubs the backups promotion [index] of [guest] governs; returns how
/// many were left hidden.
Future<int> _scrubPromotion(
  AppDatabase db,
  BackupDatabase backups,
  String guest,
  int index,
) async {
  var left = 0;
  final rows = await (backups.select(
    backups.backups,
  )..where((b) => b.owner.equals(guest))).get();
  for (final row in rows) {
    final promotions = await guestPromotions(db, guest);
    final p = promotions[index];
    final visibility = GuestBackupVisibility(promotions);
    if (!identical(visibility.governing(row.id), p)) continue;
    if (p.scrubbed.contains(row.id)) continue;
    final clean = scrubbedBackupJson(row.json, guest, p.moved);
    if (clean == null) {
      left++;
      continue;
    }
    if (clean != row.json) {
      await (backups.update(backups.backups)
            ..where((b) => b.id.equals(row.id) & b.owner.equals(guest)))
          .write(BackupsCompanion(json: Value(clean)));
    }
    await saveGuestPromotions(db, guest, [
      for (var j = 0; j < promotions.length; j++)
        j == index
            ? p.copyWith(scrubbed: {...p.scrubbed, row.id})
            : promotions[j],
    ]);
  }
  return left;
}

/// [json] without the rows in [moved] (and the steps and instances that
/// hang on them), or [json] itself when it holds none of them; null when it
/// can't be scrubbed safely: over the import limit, not a valid backup of
/// [guest], or the scrubbed copy would not restore.
String? scrubbedBackupJson(
  String json,
  String guest,
  Map<String, Set<String>> moved,
) {
  if (exceedsImportLimit(json)) return null;
  final ExportBundle b;
  switch (decodeExportJson(json)) {
    case Ok(:final value):
      b = value;
    case Err():
      return null;
  }
  if (b.profile.id != guest) return null;
  final series = moved['series'] ?? const <String>{};
  final occurrences = {
    ...?moved['occurrences'],
    for (final o in b.occurrences)
      if (o.seriesId != null && series.contains(o.seriesId)) o.id,
  };
  final subtasks = {
    ...?moved['subtasks'],
    for (final s in b.subtasks)
      if (occurrences.contains(s.occurrenceId)) s.id,
  };
  final routines = moved['routines'] ?? const <String>{};
  final kept = ExportBundle(
    exportedAt: b.exportedAt,
    profile: b.profile,
    series: [
      for (final s in b.series)
        if (!series.contains(s.id)) s,
    ],
    occurrences: [
      for (final o in b.occurrences)
        if (!occurrences.contains(o.id)) o,
    ],
    subtasks: [
      for (final s in b.subtasks)
        if (!subtasks.contains(s.id)) s,
    ],
    routines: [
      for (final r in b.routines)
        if (!routines.contains(r.id)) r,
    ],
  );
  final removed =
      b.series.length -
      kept.series.length +
      b.occurrences.length -
      kept.occurrences.length +
      b.subtasks.length -
      kept.subtasks.length +
      b.routines.length -
      kept.routines.length;
  if (removed == 0) return json;
  final out = encodeExportJson(kept);
  return isRestorableBackup(out, guest, matches: kept) ? out : null;
}
