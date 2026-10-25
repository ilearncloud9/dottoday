import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/quick_add/draft_rows.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_lexicon.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/domain/quick_add/shared_capture.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Quick Add from text, shared by the Inbox field and Add's paste (M3c.5).

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
  final profile = await readProfile(ref);
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
  // A line with a link is titled like a share and keeps it as its note
  // (the web's capture path, 11 B6, M12.4).
  final captured = [for (final d in drafts) capturedDraft(d)];
  final rows = [
    for (final (d, note) in captured)
      _withNote(
        rowsFromDraft(
          d,
          userId: profile.id,
          tzId: profile.tzId,
          nowUtc: now,
          defaultDurationMin: profile.settings.defaultDurationMin,
          untitled: untitled,
          alerts: profile.settings.defaultAlerts,
        ),
        note,
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

DraftRows _withNote(DraftRows rows, String? note) => note == null
    ? rows
    : (
        series: rows.series?.copyWith(notes: note),
        occurrence: rows.occurrence?.copyWith(notes: note),
      );
