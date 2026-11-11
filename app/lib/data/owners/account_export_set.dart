/// D1's export as a multipart set (CR-160 Stage B6,
/// docs/cr-160-multipart-export.md §10): only possession confirmed ends
/// well; a handoff without it is uncertain and, like a cancelled export,
/// leaves the deletion refused until the files are confirmed or the person
/// chooses to delete without a saved copy. The single-file D1 rule is
/// unchanged (decision 7). Reachable from tests only until B7.
library;

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/part_stream.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/domain/export/export_handoff.dart';
import 'package:dottoday/domain/export/multipart_format.dart';

/// How a multipart D1 export ended.
enum OwnerSetOutcome {
  /// Possession confirmed: every file picked back and matched.
  done,

  /// Handed over, not confirmed: deletion refused like [cancelled].
  uncertain,

  /// The share sheet or save dialog was closed.
  cancelled,

  /// A part wasn't prepared, rows were missing, or the handoff failed.
  failed,

  /// One row larger than any part (§4); exporting again won't help.
  tooLarge,

  /// The account fits one file: D1's single-file export applies.
  singleFile,
}

/// A prepared, handed-over set and where it stands.
typedef OwnerSet = ({OwnerSetOutcome outcome, PreparedSet? set});

/// Prepares [owner]'s D1 set (imported calendar events as tasks, every
/// template), checks it holds every row the device has in the same read,
/// and hands it to [deliver].
Future<OwnerSet> exportOwnerSet(
  AppDatabase db,
  String owner, {
  required PreparedFileStore store,
  required Logger logger,
  required Future<DeliveryOutcome> Function(List<PreparedFile>) deliver,
  required DateTime nowUtc,
  required String exportId,
  required String appVersion,
  required int schemaVersion,
  required String date,
  int targetBytes = partTargetBytes,
}) async {
  final prepared = await prepareMultipartExport(
    db,
    owner,
    scope: RowScope.accountDeletion,
    store: store,
    logger: logger,
    nowUtc: nowUtc,
    exportId: exportId,
    appVersion: appVersion,
    schemaVersion: schemaVersion,
    date: date,
    targetBytes: targetBytes,
    complete: ownerSetComplete(db, owner),
  );
  final PreparedSet set;
  switch (prepared) {
    case Ok(value: FitsOneFile()):
      return (outcome: OwnerSetOutcome.singleFile, set: null);
    case Ok(value: final PreparedSet value):
      set = value;
    case Err(failure: ExportTooLargeFailure()):
      return (outcome: OwnerSetOutcome.tooLarge, set: null);
    case Err():
      return (outcome: OwnerSetOutcome.failed, set: null);
  }
  try {
    final handed = await deliver(set.files);
    return (
      outcome: handed == DeliveryOutcome.delivered
          ? OwnerSetOutcome.uncertain
          : OwnerSetOutcome.cancelled,
      set: set,
    );
  } on Exception catch (e, s) {
    logger.error('account.export_hand_off_failed', error: e, stackTrace: s);
    return (outcome: OwnerSetOutcome.failed, set: set);
  }
}

/// D1's completeness check: the set's totals equal every row and template
/// [owner] has on this device (as the single-file export checks).
CompleteCheck ownerSetComplete(AppDatabase db, String owner) => (totals) async {
  final local = await localOwnerCounts(db, owner);
  return totals['series'] == local.series &&
      totals['occurrences'] == local.tasks &&
      totals['subtasks'] == local.steps &&
      totals['routines'] == local.routines &&
      totals['calendarSeries'] == local.calendarSeries;
};

/// [set] confirmed from the files picked back: [OwnerSetOutcome.done]
/// only when they are exactly the prepared set; otherwise it stays
/// [OwnerSetOutcome.uncertain].
OwnerSetOutcome confirmOwnerSet(
  PreparedSet set,
  String manifestText,
  Iterable<String> parts,
) => checkPossession(set.manifest, manifestText, parts) is PossessionConfirmed
    ? OwnerSetOutcome.done
    : OwnerSetOutcome.uncertain;

/// Why the last multipart D1 export left no confirmed copy, or null (none,
/// confirmed, or a single file whose own rule applies): the deletion waits
/// for a confirmation, another export or "Delete without a saved copy",
/// as for a cancelled single-file export.
ExportNotSavedFailure? setShortfall(OwnerSetOutcome? outcome) =>
    switch (outcome) {
      null || OwnerSetOutcome.done || OwnerSetOutcome.singleFile => null,
      OwnerSetOutcome.tooLarge => const ExportNotSavedFailure(retryable: false),
      OwnerSetOutcome.uncertain ||
      OwnerSetOutcome.cancelled ||
      OwnerSetOutcome.failed => const ExportNotSavedFailure(retryable: true),
    };
