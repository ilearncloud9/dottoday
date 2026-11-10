import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';

/// Whether stored backup text [json] would pass today's restore of
/// [owner]'s backup before it writes anything (CR-160 backup safety): within
/// the import limit, a valid v1 bundle (every row validated, references
/// resolved, one owner), and [owner]'s own profile. Being under 25 MB alone
/// proves nothing; this is the same decode the restore runs.
///
/// With [matches], the decoded backup must also hold as many series, tasks,
/// steps and routines as [matches] (the account it was just taken of), so
/// a backup that silently lost rows never counts as a safety copy.
///
/// The restore's other checks depend on the moment it runs (rows another
/// account holds, CR-160 Finding X) and are not part of this answer.
///
/// ```dart
/// isRestorableBackup(row.json, owner, matches: bundle); // true or false
/// ```
bool isRestorableBackup(String json, String owner, {ExportBundle? matches}) {
  if (exceedsImportLimit(json)) return false;
  final ExportBundle b;
  switch (decodeExportJson(json)) {
    case Ok(:final value):
      b = value;
    case Err():
      return false;
  }
  if (b.profile.id != owner) return false;
  if (matches == null) return true;
  return b.series.length == matches.series.length &&
      b.occurrences.length == matches.occurrences.length &&
      b.subtasks.length == matches.subtasks.length &&
      b.routines.length == matches.routines.length;
}
