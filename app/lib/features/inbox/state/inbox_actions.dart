import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/quick_add/draft_rows.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_lexicon.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Inbox writes (docs/02 F3). All take a ProviderContainer: rows leave the
// list (and unmount) as soon as the write lands.

/// What a Quick Add submit wrote: every row, and an undo token when the
/// batch can be undone (a new series can't yet; M3f adds series edits).
typedef Added = ({List<DraftRows> rows, UndoToken? token});

/// Parses [text] (one task per line, R-07) and writes the tasks: timed
/// ones onto their day, the rest into the Inbox (R-06).
Future<Result<Added, AppFailure>> addFromText(
  ProviderContainer ref,
  String text, {
  required String languageCode,
  required String untitled,
}) async {
  final profile = await ref.read(currentProfileProvider.future);
  final now = ref.read(clockProvider).nowUtc();
  final parsed = const QuickAddParser().parseMany(
    text,
    QuickAddContext(
      nowUtc: now,
      tzId: profile.tzId,
      language:
          QuickAddLanguage.values.asNameMap()[languageCode] ??
          QuickAddLanguage.en,
    ),
  );
  final List<QuickAddDraft> drafts;
  switch (parsed) {
    case Ok(:final value):
      drafts = value;
    case Err(:final failure):
      return Err(failure);
  }
  final rows = [
    for (final d in drafts)
      rowsFromDraft(
        d,
        userId: profile.id,
        tzId: profile.tzId,
        nowUtc: now,
        defaultDurationMin: profile.settings.defaultDurationMin,
        untitled: untitled,
      ),
  ];
  final batch = WriteBatch(
    userId: profile.id,
    series: [for (final r in rows) ?r.series],
    occurrences: [for (final r in rows) ?r.occurrence],
  );
  if (batch.series.isNotEmpty) {
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

/// Puts inbox item [o] on the timeline at [startUtc] (Schedule, Place).
Future<Result<UndoToken, AppFailure>> scheduleItem(
  ProviderContainer ref,
  Occurrence o,
  DateTime startUtc,
) => ref
    .read(undoServiceProvider)
    .applyUndoable(
      WriteBatch(
        userId: o.userId,
        occurrences: [
          o.copyWith(
            startUtc: startUtc,
            updatedAt: ref.read(clockProvider).nowUtc(),
          ),
        ],
      ),
    );

/// Moves inbox item [o] to Trash (swipe right, R-11).
Future<Result<UndoToken, AppFailure>> trashItem(
  ProviderContainer ref,
  Occurrence o,
) => ref.read(trashServiceProvider).trashOccurrences(o.userId, {o.id});
