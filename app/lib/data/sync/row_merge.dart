import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/data/sync/outbox.dart';
import 'package:dottoday/data/sync/server_columns.dart';
import 'package:dottoday/domain/sync/conflict_resolver.dart';
import 'package:dottoday/domain/sync/hlc.dart';

/// A same-field edit within the conflict window (docs/04 §4): the server's
/// value is in the row; [mine] waits for "keep mine".
typedef MergeConflict = ({String field, Object? mine, Object? theirs});

/// What a pulled row becomes locally.
typedef MergedRow = ({
  Map<String, Object?> row,
  Set<String> settled,
  List<MergeConflict> conflicts,
});

/// Merges a pulled [remote] row into the [local] one, field by field
/// (ADR-0002, docs/09 M6.2). Both in the local JSON form.
///
/// A field with no pending local write takes the server's value. A pending
/// one is resolved against the HLC the server holds for it ([versions]),
/// unless that is the version this device last pulled ([seen]): then the
/// local edit was made on top of it and simply goes up. Otherwise: local
/// newer → kept (it goes up next push); server newer → taken; both within
/// a minute and different → a conflict, server value applied.
/// [MergedRow.settled] are the pending fields the server now decides.
/// Device-only fields (not in [pushableColumns]) keep the local value.
///
/// ```dart
/// mergeRemote(entity: 'occurrences', local: l, remote: r,
///     pending: p, versions: v);
/// ```
MergedRow mergeRemote({
  required String entity,
  required Map<String, Object?>? local,
  required Map<String, Object?> remote,
  required Map<String, PendingField> pending,
  required Map<String, String> versions,
  Map<String, String> seen = const {},
  ConflictResolver resolver = const ConflictResolver(),
}) {
  final row = {...?local};
  final settled = <String>{};
  final conflicts = <MergeConflict>[];
  final synced = pushableColumns[entity] ?? const <String>{};
  for (final MapEntry(key: field, value: theirs) in remote.entries) {
    final deviceOnly = !synced.contains(field) && !_identity.contains(field);
    if (local != null && deviceOnly) continue;
    final mine = pending[field];
    final serverHlc = Hlc.tryParse(versions[field] ?? '');
    final localHlc = Hlc.tryParse(mine?.hlc ?? '');
    if (mine == null) {
      row[field] = theirs;
      continue;
    }
    // The server never had this field from a device, or hasn't changed it
    // since this device last looked: the local edit stands.
    if (serverHlc == null ||
        localHlc == null ||
        versions[field] == seen[field]) {
      continue;
    }
    final kind = _kinds[entity] ?? EntityKind.occurrence;
    final id = remote['id']! as String;
    FieldChange change(Object? value, Hlc hlc) => FieldChange(
      entity: kind,
      entityId: id,
      field: field,
      value: value,
      hlc: hlc,
    );
    switch (resolver.resolve(
      change(mine.value, localHlc),
      change(theirs, serverHlc),
    )) {
      case KeepLocal():
        row[field] = mine.value;
      case TakeRemote():
        row[field] = theirs;
        settled.add(field);
      case Conflict():
        row[field] = theirs;
        settled.add(field);
        conflicts.add((field: field, mine: mine.value, theirs: theirs));
    }
  }
  return (row: row, settled: settled, conflicts: conflicts);
}

const _identity = {'id', 'user_id', 'updated_at'};

const _kinds = {
  'profiles': EntityKind.profile,
  'series': EntityKind.series,
  'occurrences': EntityKind.occurrence,
  'subtasks': EntityKind.subtask,
};
