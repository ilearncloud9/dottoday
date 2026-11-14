import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/intents/dot_intents.dart';

/// Applies what surfaces queued while the app wasn't running (docs/09
/// M9.2): on launch, on resume and in the background job. In queue order;
/// a failed write stops the drain so later actions never overtake it.
/// Logs ids and outcomes only (CLAUDE.md §4).
///
/// Only the shown owner's entries are applied (CR-160 I7). Another owner's
/// wait in the queue, unread, until that owner is shown again; entries with
/// no owner (queued during a change of owner, or by an older version) and
/// entries that can't be read are kept and never applied. Nothing is
/// removed before its own owner applied it or it reached a terminal state.
final class ActionQueueDrainer {
  ActionQueueDrainer({
    required ActionQueueStore store,
    required DotIntents intents,
    required Logger logger,
    required Future<String?> Function() shownOwner,
    Future<void> Function(QueuedAction queued)? prepare,
    Future<void> Function(QueuedAction queued, ActionOutcome outcome)?
    recordTerminal,
    DateTime Function()? now,
    void Function(String occurrenceId)? onFocus,
  }) : _store = store,
       _intents = intents,
       _logger = logger,
       _shownOwner = shownOwner,
       _prepare = prepare,
       _recordTerminal = recordTerminal,
       _now = now,
       _onFocus = onFocus;

  final ActionQueueStore _store;
  final DotIntents _intents;
  final Logger _logger;

  /// The owner the database shows now (not a cached provider).
  final Future<String?> Function() _shownOwner;

  /// Runs before an entry is applied: a guest share from an earlier guest
  /// session keeps that session (policy §3).
  final Future<void> Function(QueuedAction queued)? _prepare;

  /// Makes an ownership outcome durable (ids and reason only) before the
  /// entry leaves the queue (CR-160 I7).
  final Future<void> Function(QueuedAction queued, ActionOutcome outcome)?
  _recordTerminal;

  /// Owners whose entries wait even while shown ([hold]).
  final _held = <String>{};

  /// Keeps [owner]'s entries queued, unapplied, while its deletion is
  /// reviewed (CR-160 policy §4): what arrives after the review stays
  /// visible to the check before deleting. [drain] with `force` still
  /// applies them (the export step).
  void hold(String owner) => _held.add(owner);

  /// Ends [hold].
  void release(String owner) => _held.remove(owner);
  final DateTime Function()? _now;

  /// A Start focus just tapped on a surface (M10.5): the app opens Focus.
  final void Function(String occurrenceId)? _onFocus;

  /// How recent a queued Start focus must be to open Focus: it opened the
  /// app just now (`openAppWhenRun`), not hours ago.
  static const focusFresh = Duration(minutes: 2);
  Future<int> _tail = Future.value(0);

  /// Drains the queue, after any drain already running; completes with
  /// how many entries were applied. [force] applies that owner's entries
  /// even while held.
  Future<int> drain({String? force}) =>
      _tail = _tail.then((_) => _drain(force), onError: (_) => _drain(force));

  Future<int> _drain(String? force) async {
    final entries = await _store.read();
    if (entries.isEmpty) return 0;
    final shown = await _shownOwner();
    final settled = <String>{};
    var applied = 0;
    for (final raw in entries) {
      final queued = _mine(raw, shown);
      if (queued == null) continue;
      if (_held.contains(queued.owner) && queued.owner != force) continue;
      await _prepare?.call(queued);
      final outcome = await _intents.apply(queued);
      if (outcome == ActionOutcome.failed) {
        _logger.warn(
          'intent.apply_failed',
          fields: {'action': LogId(queued.id)},
        );
        break;
      }
      if (_kept(outcome)) {
        _logger.warn(
          'intent.kept',
          fields: {'action': LogId(queued.id), 'reason': outcome},
        );
        continue;
      }
      if (outcome == ActionOutcome.droppedForeign) {
        // Durable before the entry goes: a crash in between replays it and
        // records the same outcome again.
        await _recordTerminal?.call(queued, outcome);
      }
      settled.add(queued.id);
      if (outcome == ActionOutcome.applied) applied++;
      _maybeFocus(queued, outcome);
      if (_dropped(outcome)) {
        _logger.info(
          'intent.dropped',
          fields: {
            'action': LogId(queued.id),
            'reason': outcome,
            'occurrence': ?_occurrenceOf(queued.action),
          },
        );
      }
    }
    await _store.remove(settled);
    return applied;
  }

  /// [raw] when it is [shown]'s to apply now; null (kept) otherwise.
  QueuedAction? _mine(Object? raw, String? shown) {
    final queued = decodeQueuedAction(raw);
    if (queued == null) {
      _logger.warn('intent.queue_unreadable');
      return null;
    }
    if (queued.owner == null) {
      _logger.warn('intent.unattributed', fields: {'action': LogId(queued.id)});
      return null;
    }
    if (shown == null || queued.owner != shown) return null;
    return queued;
  }

  static bool _kept(ActionOutcome o) =>
      o == ActionOutcome.notOwner || o == ActionOutcome.foreign;

  void _maybeFocus(QueuedAction queued, ActionOutcome outcome) {
    final now = _now?.call();
    final focus = _onFocus;
    if (focus == null || now == null || _dropped(outcome)) return;
    if (now.difference(queued.createdAtUtc) > focusFresh) return;
    if (queued.action case StartFocus(:final occurrenceId)) focus(occurrenceId);
  }

  static bool _dropped(ActionOutcome o) =>
      o == ActionOutcome.droppedMissing ||
      o == ActionOutcome.droppedForeign ||
      o == ActionOutcome.droppedStale ||
      o == ActionOutcome.droppedInvalid;

  static LogId? _occurrenceOf(DotAction a) => switch (a) {
    AddTask() => null,
    MarkDone(:final occurrenceId) => LogId(occurrenceId),
    AddFifteen(:final occurrenceId) => LogId(occurrenceId),
    StartFocus(:final occurrenceId) => LogId(occurrenceId),
  };
}
