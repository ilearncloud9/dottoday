import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/quick_add/draft_rows.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_lexicon.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/repositories/series_repository.dart';
import 'package:dottoday/domain/scheduling/task_progress.dart' as progress;
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/domain/writes/write_use_case.dart';

/// What applying one action did.
enum ActionOutcome {
  applied,

  /// A replay: the change is already there, nothing written.
  alreadyApplied,

  /// The task is gone (deleted, or another account's id); dropped.
  droppedMissing,

  /// +15 for an end the task no longer has (moved since); dropped.
  droppedStale,

  /// Text Quick Add refuses (too long); dropped.
  droppedInvalid,

  /// The write failed; the action stays queued for the next drain.
  failed,

  /// Queued for another owner than the one shown (CR-160 I7): nothing
  /// written, it stays queued until its owner is shown again.
  notOwner,

  /// An Add task whose id another owner's row already holds: nothing
  /// written; kept, since its text may be the only copy (CR-160 I7).
  foreign,

  /// Done, +15 or Start for a task another owner holds: permanently
  /// invalid for the owner it was queued for. Nothing written; dropped
  /// once the outcome is recorded (CR-160 I7, owner 2026-11-09).
  droppedForeign,
}

/// The five B6 intents (docs/11 §0, docs/09 M9.2), defined once. Widgets,
/// controls, the Live Activity, the menu bar, the service worker and Siri
/// all end up here — directly in process, or through the action queue —
/// and every change goes through the single write path, so the day
/// snapshot and notifications follow.
///
/// Ids come from the surface and are only trusted for the current profile
/// (06 §7): a lookup under another account finds nothing. An entry is
/// applied only for the owner it was queued for, and its write commits only
/// while that owner is still the one shown (CR-160 I7).
final class DotIntents {
  DotIntents({
    required Clock clock,
    required WriteUseCase writes,
    required OccurrenceRepository occurrences,
    required SeriesRepository series,
    required Future<Profile> Function() profile,
    required Future<DaySnapshot> Function() snapshot,
    required String Function(String languageCode) untitled,
    required Future<String?> Function(String id) ownerOf,
    IdGenerator ids = const UuidV7Generator(),
  }) : _clock = clock,
       _writes = writes,
       _occurrences = occurrences,
       _series = series,
       _profile = profile,
       _snapshot = snapshot,
       _untitled = untitled,
       _ownerOf = ownerOf,
       _ids = ids;

  final Clock _clock;
  final WriteUseCase _writes;
  final OccurrenceRepository _occurrences;
  final SeriesRepository _series;
  final Future<Profile> Function() _profile;
  final Future<DaySnapshot> Function() _snapshot;
  final String Function(String languageCode) _untitled;

  /// The owner of the task or repeat [id] under any owner, or null.
  final Future<String?> Function(String id) _ownerOf;
  final IdGenerator _ids;

  /// `WhatsNext`: the day snapshot, rewritten now, so every surface agrees
  /// with the answer ([DaySnapshot.current], [DaySnapshot.next]).
  Future<DaySnapshot> whatsNext() => _snapshot();

  /// Runs [action] now, as a fresh queue entry for the owner shown
  /// (in-process callers: the Mac menu bar, the app's own intent handlers).
  Future<ActionOutcome> run(DotAction action) async => apply(
    QueuedAction(
      id: _ids.newId(),
      createdAtUtc: _clock.nowUtc(),
      action: action,
      owner: (await _profile()).id,
    ),
  );

  /// Applies [queued] for its own owner only; safe to call again with the
  /// same entry. An entry with no owner, or another owner than the one
  /// shown, is [ActionOutcome.notOwner]: never applied here.
  Future<ActionOutcome> apply(QueuedAction queued) async {
    final profile = await _profile();
    if (queued.owner != profile.id) return ActionOutcome.notOwner;
    return switch (queued.action) {
      final AddTask a => _addTask(profile, queued.id, a),
      MarkDone(:final occurrenceId) => _change(
        profile.id,
        occurrenceId,
        (o) => o.status == OccurrenceStatus.done
            ? null
            : progress.markDone(o, _clock.nowUtc()),
      ),
      StartFocus(:final occurrenceId) => _change(profile.id, occurrenceId, (o) {
        final started = progress.markStarted(o, _clock.nowUtc());
        return identical(started, o) ? null : started;
      }),
      final AddFifteen a => _addFifteen(profile.id, a),
    };
  }

  Future<ActionOutcome> _addFifteen(String userId, AddFifteen a) async {
    final task = await _live(userId, a.occurrenceId);
    if (task == null) return _missing(userId, a.occurrenceId);
    // Compared in whole milliseconds: what every surface carries (a stored
    // time has no microseconds; one made in the app may).
    final end = task.endUtc!.millisecondsSinceEpoch;
    final planned = a.plannedEndUtc.millisecondsSinceEpoch;
    const extra = AddFifteen.minutes * 60000;
    if (end == planned + extra) return ActionOutcome.alreadyApplied;
    if (end != planned) return ActionOutcome.droppedStale;
    return _write(
      WriteBatch(
        userId: userId,
        occurrences: [
          task.copyWith(durationMin: task.durationMin + AddFifteen.minutes),
        ],
      ),
    );
  }

  /// Applies [change] to the live task; null from [change] = already so.
  Future<ActionOutcome> _change(
    String userId,
    String id,
    Occurrence? Function(Occurrence) change,
  ) async {
    final task = await _live(userId, id);
    if (task == null) return _missing(userId, id);
    final changed = change(task);
    if (changed == null) return ActionOutcome.alreadyApplied;
    return _write(WriteBatch(userId: userId, occurrences: [changed]));
  }

  Future<ActionOutcome> _addTask(
    Profile profile,
    String id,
    AddTask action,
  ) async {
    final text = action.text;
    if (await _occurrences.findById(profile.id, id) != null ||
        await _series.findById(profile.id, id) != null) {
      return ActionOutcome.alreadyApplied;
    }
    if (await _isForeign(profile.id, id)) return ActionOutcome.foreign;
    final now = _clock.nowUtc();
    final parsed = const QuickAddParser().parse(
      text,
      QuickAddContext(
        nowUtc: now,
        tzId: profile.tzId,
        language:
            QuickAddLanguage.values.asNameMap()[profile.locale] ??
            QuickAddLanguage.en,
      ),
    );
    final QuickAddDraft draft;
    switch (parsed) {
      case Ok(:final value):
        // A share waits in the Inbox, its length kept (M12.4).
        draft = action.inbox
            ? QuickAddDraft(
                title: value.title,
                text: value.text,
                tokens: value.tokens,
                durationMin: value.durationMin,
                inbox: true,
              )
            : value;
      case Err():
        return ActionOutcome.droppedInvalid;
    }
    final rows = rowsFromDraft(
      draft,
      userId: profile.id,
      tzId: profile.tzId,
      nowUtc: now,
      defaultDurationMin: profile.settings.defaultDurationMin,
      untitled: _untitled(profile.locale),
      alerts: profile.settings.defaultAlerts,
      language: profile.locale,
      ids: _FixedId(id),
    );
    final task = rows.occurrence;
    return _write(
      WriteBatch(
        userId: profile.id,
        series: [?rows.series],
        occurrences: [if (task != null) task.copyWith(notes: action.note)],
      ),
    );
  }

  /// Gone for [userId]: dropped when nobody holds it (deleted, purged);
  /// when another owner does, the reference is invalid for [userId] for
  /// good. Either way nothing is written to anyone's task.
  Future<ActionOutcome> _missing(String userId, String id) async =>
      await _isForeign(userId, id)
      ? ActionOutcome.droppedForeign
      : ActionOutcome.droppedMissing;

  Future<bool> _isForeign(String userId, String id) async {
    final owner = await _ownerOf(id);
    return owner != null && owner != userId;
  }

  Future<Occurrence?> _live(String userId, String id) async {
    final task = await _occurrences.findById(userId, id);
    return task == null || task.deletedAt != null ? null : task;
  }

  // Only while the owner is shown, checked in the write's own transaction:
  // a change of owner between the check above and the commit fails the
  // write, and the action stays queued for its owner (CR-160 I7).
  Future<ActionOutcome> _write(WriteBatch batch) async =>
      switch (await _writes.apply(batch.whileShown())) {
        Ok() => ActionOutcome.applied,
        Err() => ActionOutcome.failed,
      };
}

/// The queued action's id as the new row's id (replay-safe AddTask).
final class _FixedId implements IdGenerator {
  const _FixedId(this.id);

  final String id;

  @override
  String newId() => id;
}
