import 'dart:ui' show Rect;

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/export/export_service.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/drift.dart';

/// How "Export my data first" on the delete screen ended (CR-160 policy
/// §4: the only recovery once the account is gone).
enum OwnerExportOutcome {
  /// Every task, repeat, step and routine is in the file, and the file was
  /// handed to the share sheet, save dialog or download. That is not proof
  /// the person kept it.
  done,

  /// The person closed the share sheet or save dialog: nothing was saved.
  cancelled,

  /// The file couldn't be built, was missing rows, or couldn't be handed
  /// over. Nothing is deleted on the strength of it.
  failed,

  /// The file is over the import limit: the app couldn't restore it, and
  /// exporting again won't change that (CR-160).
  tooLarge,
}

/// Exports [owner]'s full JSON backup (local and unsynced work included:
/// it is read from this device) and checks it before saying it worked:
/// the decoded file holds as many series, tasks, steps and routines as the
/// device has for [owner] (imported calendar events included, as ordinary
/// tasks: CR-160), and the hand-off reported no error. A file over the
/// import limit fails the decode, so it is never reported as done.
Future<OwnerExportOutcome> exportOwnerChecked({
  required AppDatabase db,
  required ExportService exports,
  required FileGateway files,
  required Logger logger,
  required String owner,
  Rect? origin,
}) async {
  final List<ExportFile> list;
  switch (await exports.build(
    owner,
    ExportFormat.json,
    forAccountDeletion: true,
  )) {
    case Ok(:final value) when value.length == 1:
      list = value;
    case _:
      return OwnerExportOutcome.failed;
  }
  final ExportBundle bundle;
  switch (decodeExportJson(list.single.content)) {
    case Ok(:final value):
      bundle = value;
    case Err(failure: ValidationFailure(rule: ValidationRule.tooLarge)):
      logger.info('account.export_too_large');
      return OwnerExportOutcome.tooLarge;
    case Err():
      return OwnerExportOutcome.failed;
  }
  if (!_complete(bundle, await _localCounts(db, owner))) {
    logger.error('account.export_incomplete');
    return OwnerExportOutcome.failed;
  }
  try {
    final outcome = await files.deliver(list, origin: origin);
    return outcome == DeliveryOutcome.delivered
        ? OwnerExportOutcome.done
        : OwnerExportOutcome.cancelled;
  } on Exception catch (e, s) {
    logger.error('account.export_hand_off_failed', error: e, stackTrace: s);
    return OwnerExportOutcome.failed;
  }
}

typedef _Counts = ({int series, int tasks, int steps, int routines});

bool _complete(ExportBundle b, _Counts local) =>
    b.series.length == local.series &&
    b.occurrences.length == local.tasks &&
    b.subtasks.length == local.steps &&
    b.routines.length == local.routines;

Future<_Counts> _localCounts(AppDatabase db, String owner) async {
  final row = await db
      .customSelect(
        // Every row, imported calendar events and their steps included:
        // D1's file is the only copy of them after the deletion (CR-160).
        'SELECT (SELECT COUNT(*) FROM series WHERE user_id = ?1) AS s, '
        '(SELECT COUNT(*) FROM occurrences WHERE user_id = ?1) AS o, '
        '(SELECT COUNT(*) FROM subtasks WHERE user_id = ?1) AS st, '
        '(SELECT COUNT(*) FROM routines WHERE user_id = ?1) AS r',
        variables: [Variable<String>(owner)],
      )
      .getSingle();
  return (
    series: row.read<int>('s'),
    tasks: row.read<int>('o'),
    steps: row.read<int>('st'),
    routines: row.read<int>('r'),
  );
}
