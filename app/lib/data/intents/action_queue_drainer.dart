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
  }) : _store = store,
       _intents = intents,
       _logger = logger;

  final ActionQueueStore _store;
  final DotIntents _intents;
  final Logger _logger;
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
