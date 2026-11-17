import 'dart:convert';

import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/export/export_json.dart';

/// Why a stored backup can or can't be restored by the paths the app
/// supports today: Settings › restore and import, both through
/// `decodeExportJson` (CR-160 I1 recovery classification). Only
/// [oversized] has a planned path (Stage B4's row-by-row reader); the
/// others fail the same validation whatever reads them. [storageError] and
/// [unknown] are not judgements about the content: try again later.
enum BackupRecovery {
  /// Passes the restore check for its owner.
  restorable,

  /// Over the 25 MB import limit; otherwise unread. Stage B4 candidate.
  oversized,

  /// Not JSON, not a v1 backup, or rows the validators refuse.
  malformed,

  /// A valid shape, but the profile or a row names someone other than the
  /// backup's owner.
  wrongOwner,

  /// No owner recorded (a schema-1 backup whose owner was never proven):
  /// no supported path restores it.
  noOwner,

  /// Reading it from storage failed (decryption, I/O): transient or not,
  /// the content was never seen.
  storageError,

  /// Anything else that went wrong while classifying.
  unknown,
}

/// Classifies backup text [json] stored for [owner] (null: no owner).
///
/// ```dart
/// classifyBackupJson(row.json, row.owner); // BackupRecovery.restorable
/// ```
BackupRecovery classifyBackupJson(String json, String? owner) {
  if (exceedsImportLimit(json)) return BackupRecovery.oversized;
  final Object? raw;
  try {
    raw = jsonDecode(json);
  } on FormatException {
    return BackupRecovery.malformed;
  }
  if (raw is! Map<String, Object?> || raw['version'] != 1) {
    return BackupRecovery.malformed;
  }
  if (owner == null) return BackupRecovery.noOwner;
  final profile = raw['profile'];
  final id = profile is Map<String, Object?> ? profile['id'] : null;
  if (id is! String) return BackupRecovery.malformed;
  if (id != owner || _otherRowOwner(raw, owner)) {
    return BackupRecovery.wrongOwner;
  }
  return switch (decodeExportJson(json)) {
    Ok() => BackupRecovery.restorable,
    Err() => BackupRecovery.malformed,
  };
}

/// Whether any row in a table names a `user_id` other than [owner].
bool _otherRowOwner(Map<String, Object?> raw, String owner) {
  for (final table in ['series', 'occurrences', 'subtasks', 'routines']) {
    final rows = raw[table];
    if (rows is! List) continue;
    for (final r in rows) {
      if (r is Map<String, Object?> && r['user_id'] != owner) return true;
    }
  }
  return false;
}
