import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/intents/dot_intents.dart';

/// Applies what surfaces queued while the app wasn't running (docs/09
/// M9.2): on launch, on resume and in the background job. In queue order;
/// a failed write stops the drain so later actions never overtake it.
/// Logs ids and outcomes only (CLAUDE.md §4).
final class ActionQueueDrainer {
  ActionQueueDrainer({
    required ActionQueueStore store,
    required DotIntents intents,
    required Logger logger,
    DateTime Function()? now,
    void Function(String occurrenceId)? onFocus,
  }) : _store = store,
       _intents = intents,
       _logger = logger,
       _now = now,
       _onFocus = onFocus;

  final ActionQueueStore _store;
  final DotIntents _intents;
  final Logger _logger;
  final DateTime Function()? _now;

  /// A Start focus just tapped on a surface (M10.5): the app opens Focus.
  final void Function(String occurrenceId)? _onFocus;

  /// How recent a queued Start focus must be to open Focus: it opened the
  /// app just now (`openAppWhenRun`), not hours ago.
  static const focusFresh = Duration(minutes: 2);
  Future<int> _tail = Future.value(0);

  /// Drains the queue, after any drain already running; completes with
  /// how many entries were applied.
  Future<int> drain() =>
      _tail = _tail.then((_) => _drain(), onError: (_) => _drain());

  Future<int> _drain() async {
    final entries = await _store.read();
    if (entries.isEmpty) return 0;
    final settled = <String>{};
    var unreadable = false;
    var applied = 0;
    for (final raw in entries) {
      final queued = decodeQueuedAction(raw);
      if (queued == null) {
        unreadable = true;
        _logger.warn('intent.queue_unreadable');
        continue;
      }
      final outcome = await _intents.apply(queued);
      if (outcome == ActionOutcome.failed) {
        _logger.warn(
          'intent.apply_failed',
          fields: {'action': LogId(queued.id)},
        );
        break;
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
    await _store.remove(settled, unreadable: unreadable);
    return applied;
  }

  void _maybeFocus(QueuedAction queued, ActionOutcome outcome) {
    final now = _now?.call();
    final focus = _onFocus;
    if (focus == null || now == null || _dropped(outcome)) return;
    if (now.difference(queued.createdAtUtc) > focusFresh) return;
    if (queued.action case StartFocus(:final occurrenceId)) focus(occurrenceId);
  }

  static bool _dropped(ActionOutcome o) =>
      o == ActionOutcome.droppedMissing ||
      o == ActionOutcome.droppedStale ||
      o == ActionOutcome.droppedInvalid;

  static LogId? _occurrenceOf(DotAction a) => switch (a) {
    AddTask() => null,
    MarkDone(:final occurrenceId) => LogId(occurrenceId),
    AddFifteen(:final occurrenceId) => LogId(occurrenceId),
    StartFocus(:final occurrenceId) => LogId(occurrenceId),
  };
}
