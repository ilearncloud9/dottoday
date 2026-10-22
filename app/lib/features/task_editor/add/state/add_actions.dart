import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/domain/quick_add/draft_rows.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What Add wrote, and an undo token when it can be undone (a new series
/// can't yet: series undo lands with M3f.1).
typedef AddedTask = ({DraftRows rows, UndoToken? token});

/// Writes [draft] (docs/02 F2 "Saving is optimistic"): on its day, or in
/// the Inbox when it has no time or [toInbox].
Future<Result<AddedTask, AppFailure>> saveDraft(
  ProviderContainer ref,
  AddDraft draft, {
  required String untitled,
  bool toInbox = false,
}) async {
  final profile = await readProfile(ref);
  final rows = draft.toRows(
    userId: profile.id,
    nowUtc: ref.read(clockProvider).nowUtc(),
    untitled: untitled,
    toInbox: toInbox,
  );
  final batch = WriteBatch(
    userId: profile.id,
    series: [?rows.series],
    occurrences: [?rows.occurrence],
  );
  if (rows.series != null) {
    final written = await ref.read(writeUseCaseProvider).apply(batch);
    return switch (written) {
      Ok() => Ok((rows: rows, token: null)),
      Err(:final failure) => Err(failure),
    };
  }
  final applied = await ref.read(undoServiceProvider).applyUndoable(batch);
  return switch (applied) {
    Ok(:final value) => Ok((rows: rows, token: value)),
    Err(:final failure) => Err(failure),
  };
}
