/// D1's export as a multipart set (CR-160 Stage B6/B7c,
/// docs/cr-160-multipart-export.md §10): only possession confirmed ends
/// well; a handoff without it is [OwnerExportOutcome.uncertain] and, like
/// a cancelled export, leaves the deletion waiting until the files are
/// confirmed or the person chooses to delete without a saved copy. The
/// single-file D1 rule is unchanged (decision 7).
library;

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/export/export_service.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/picked_set_check.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/data/owners/account_export.dart';

/// A handed-over set and how its handoff ended ([OwnerExportOutcome.done]
/// only once its files are confirmed: [confirmOwnerSet]).
typedef OwnerSet = ({OwnerExportOutcome outcome, PreparedSet? set});

/// Prepares [owner]'s D1 set (imported calendar events as tasks, every
/// template), checks it holds every row the device has in the same read,
/// and hands it to [deliver]. Null when the account fits one file: D1's
/// single-file export applies, unchanged (decision 7).
Future<OwnerSet?> exportOwnerSet(
  AppDatabase db,
  String owner, {
  required ExportService exports,
  required Logger logger,
  required Future<DeliveryOutcome> Function(List<PreparedFile>) deliver,
  required Future<String> Function() appVersion,
}) async {
  final prepared = await exports.prepareSet(
    owner,
    appVersion: appVersion,
    forAccountDeletion: true,
    complete: ownerSetComplete(db, owner),
  );
  final PreparedSet set;
  switch (prepared) {
    case Ok(value: FitsOneFile()):
      return null;
    case Ok(value: final PreparedSet value):
      set = value;
    case Err(failure: ExportTooLargeFailure()):
      return (outcome: OwnerExportOutcome.tooLarge, set: null);
    case Err():
      return (outcome: OwnerExportOutcome.failed, set: null);
  }
  try {
    if (await deliver(set.files) == DeliveryOutcome.delivered) {
      return (outcome: OwnerExportOutcome.uncertain, set: set);
    }
    await set.discard();
    return (outcome: OwnerExportOutcome.cancelled, set: null);
  } on Exception catch (e, s) {
    logger.error('account.export_hand_off_failed', error: e, stackTrace: s);
    await set.discard();
    return (outcome: OwnerExportOutcome.failed, set: null);
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

/// [picked] against [set], read one file at a time: only
/// [PickedSetComplete] confirms it ([OwnerExportOutcome.done]).
Future<PickedSetCheck> confirmOwnerSet(
  PreparedSet set,
  List<PickedFile> picked,
) => checkPickedSet(set.manifest, picked);

/// Why a D1 export left no restorable copy, so the deletion waits for
/// another export, a confirmation or "Delete without a saved copy"; null
/// when none was [asked] for or it was [OwnerExportOutcome.done]. A running
/// one ([outcome] null) and a too-large one can't be retried.
ExportNotSavedFailure? exportShortfall({
  required bool asked,
  required OwnerExportOutcome? outcome,
}) {
  if (!asked) return null;
  return switch (outcome) {
    OwnerExportOutcome.done => null,
    null || OwnerExportOutcome.tooLarge => const ExportNotSavedFailure(
      retryable: false,
    ),
    OwnerExportOutcome.uncertain ||
    OwnerExportOutcome.cancelled ||
    OwnerExportOutcome.failed => const ExportNotSavedFailure(retryable: true),
  };
}
