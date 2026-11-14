import 'package:drift/drift.dart';

// CR-160 blocker 8 (`data/sync/legacy_switch.dart`): what the upgrade from
// schema < 18 records for the first account sync to check.

/// The outbox's last `seq` when the device upgraded from schema < 18.
const legacyOutboxUntilKey = 'legacy_outbox_until';

/// Present until the first account sync after that upgrade has checked.
const legacyCheckDueKey = 'legacy_check_due';

/// Inside the upgrade from schema < 18: the outbox as it stands, and the
/// check due.
Future<void> recordLegacyOutbox(GeneratedDatabase db) async {
  await db.customStatement(
    'INSERT OR REPLACE INTO local_meta (key, value) '
    "SELECT '$legacyOutboxUntilKey', CAST(coalesce(max(seq), 0) AS TEXT) "
    'FROM change_log',
  );
  await db.customStatement(
    'INSERT OR REPLACE INTO local_meta (key, value) '
    "VALUES ('$legacyCheckDueKey', '1')",
  );
}
