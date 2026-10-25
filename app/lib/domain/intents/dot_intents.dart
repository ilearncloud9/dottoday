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
}

/// The five B6 intents (docs/11 §0, docs/09 M9.2), defined once. Widgets,
/// controls, the Live Activity, the menu bar, the service worker and Siri
/// all end up here — directly in process, or through the action queue —
/// and every change goes through the single write path, so the day
/// snapshot and notifications follow.
///
/// Ids come from the surface and are only trusted for the current profile
/// (06 §7): a lookup under another account finds nothing.
final class DotIntents {
  DotIntents({
    required Clock clock,
    required WriteUseCase writes,
    required OccurrenceRepository occurrences,
    required SeriesRepository series,
    required Future<Profile> Function() profile,
    required Future<DaySnapshot> Function() snapshot,
    required String Function(String languageCode) untitled,
    IdGenerator ids = const UuidV7Generator(),
  }) : _clock = clock,
       _writes = writes,
       _occurrences = occurrences,
       _series = series,
       _profile = profile,
       _snapshot = snapshot,
       _untitled = untitled,
       _ids = ids;

  final Clock _clock;
  final WriteUseCase _writes;
  final OccurrenceRepository _occurrences;
  final SeriesRepository _series;
  final Future<Profile> Function() _profile;
  final Future<DaySnapshot> Function() _snapshot;
  final String Function(String languageCode) _untitled;
  final IdGenerator _ids;

  /// `WhatsNext`: the day snapshot, rewritten now, so every surface agrees
  /// with the answer ([DaySnapshot.current], [DaySnapshot.next]).
  Future<DaySnapshot> whatsNext() => _snapshot();

  /// Runs [action] now, as a fresh queue entry (in-process callers: the
  /// Mac menu bar, the app's own intent handlers).
  Future<ActionOutcome> run(DotAction action) => apply(
    QueuedAction(
      id: _ids.newId(),
      createdAtUtc: _clock.nowUtc(),
      action: action,
    ),
  );

  /// Applies [queued]; safe to call again with the same entry.
  Future<ActionOutcome> apply(QueuedAction queued) async {
    final profile = await _profile();
    return switch (queued.action) {
      AddTask(:final text) => _addTask(profile, queued.id, text),
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
    if (task == null) return ActionOutcome.droppedMissing;
    final end = task.endUtc;
    const extra = Duration(minutes: AddFifteen.minutes);
    if (end == a.plannedEndUtc.add(extra)) return ActionOutcome.alreadyApplied;
    if (end != a.plannedEndUtc) return ActionOutcome.droppedStale;
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
    if (task == null) return ActionOutcome.droppedMissing;
    final changed = change(task);
    if (changed == null) return ActionOutcome.alreadyApplied;
    return _write(WriteBatch(userId: userId, occurrences: [changed]));
  }

  Future<ActionOutcome> _addTask(
    Profile profile,
    String id,
    String text,
  ) async {
    if (await _occurrences.findById(profile.id, id) != null ||
        await _series.findById(profile.id, id) != null) {
      return ActionOutcome.alreadyApplied;
    }
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
        draft = value;
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
      ids: _FixedId(id),
    );
    return _write(
      WriteBatch(
        userId: profile.id,
        series: [?rows.series],
        occurrences: [?rows.occurrence],
      ),
    );
  }

  Future<Occurrence?> _live(String userId, String id) async {
    final task = await _occurrences.findById(userId, id);
    return task == null || task.deletedAt != null ? null : task;
  }

  Future<ActionOutcome> _write(WriteBatch batch) async =>
      switch (await _writes.apply(batch)) {
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
