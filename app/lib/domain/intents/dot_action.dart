import 'package:dottoday/domain/quick_add/quick_add_parser.dart';

/// The four B6 intents that change data (docs/11 §0). `WhatsNext` only
/// reads the day snapshot, so it never enters the queue. Every action is
/// safe to replay: replaying one that was already applied changes nothing
/// (docs/09 M9.2 "idempotent replay").
sealed class DotAction {
  const DotAction();
}

/// Adds a task from one line of Quick Add text ("Gym 7am"); the queued
/// action's id becomes the new task's id, so a replay finds it and stops.
final class AddTask extends DotAction {
  const AddTask(this.text);

  final String text;
}

/// Ticks one occurrence; done twice is still done.
final class MarkDone extends DotAction {
  const MarkDone(this.occurrenceId);

  final String occurrenceId;
}

/// Gives a dot 15 more minutes. [plannedEndUtc] is the end the surface
/// showed when the user tapped: applied only while the task still ends
/// there, so a replay (or a change made since) never adds twice.
final class AddFifteen extends DotAction {
  const AddFifteen(this.occurrenceId, {required this.plannedEndUtc});

  static const minutes = 15;

  final String occurrenceId;
  final DateTime plannedEndUtc;
}

/// Starts a dot (B1 `actualStart`; Focus itself is M10.5). Only the first
/// start counts.
final class StartFocus extends DotAction {
  const StartFocus(this.occurrenceId);

  final String occurrenceId;
}

/// An action written by a surface while the app wasn't running, waiting
/// in the shared store for the app to apply it (ADR-0010: the watch will
/// use the same queue).
final class QueuedAction {
  const QueuedAction({
    required this.id,
    required this.createdAtUtc,
    required this.action,
  });

  /// UUID v7 made by the surface: the queue's key, and AddTask's task id.
  final String id;
  final DateTime createdAtUtc;
  final DotAction action;
}

/// JSON of one queue entry, as Swift, Kotlin and the service worker write
/// it: `{"id", "at_ms", "kind": "add_task"|"mark_done"|"add_fifteen"|
/// "start_focus", "occurrence_id", "planned_end_ms", "text"}`.
Map<String, Object?> encodeQueuedAction(QueuedAction a) => {
  'id': a.id,
  'at_ms': a.createdAtUtc.millisecondsSinceEpoch,
  ...switch (a.action) {
    AddTask(:final text) => {'kind': 'add_task', 'text': text},
    MarkDone(:final occurrenceId) => {
      'kind': 'mark_done',
      'occurrence_id': occurrenceId,
    },
    AddFifteen(:final occurrenceId, :final plannedEndUtc) => {
      'kind': 'add_fifteen',
      'occurrence_id': occurrenceId,
      'planned_end_ms': plannedEndUtc.millisecondsSinceEpoch,
    },
    StartFocus(:final occurrenceId) => {
      'kind': 'start_focus',
      'occurrence_id': occurrenceId,
    },
  },
};

/// The entry in [json], or null when it is malformed (unknown kind, an id
/// that isn't a UUID, missing or mistyped field, oversized text). Ids come
/// back lowercase (Swift writes them in capitals). Total: never throws.
QueuedAction? decodeQueuedAction(Object? json) {
  if (json is! Map<String, Object?>) return null;
  final id = _id(json['id']);
  final at = json['at_ms'];
  if (id == null || at is! int || at < 0) return null;
  final action = _action(json);
  if (action == null) return null;
  return QueuedAction(
    id: id,
    createdAtUtc: DateTime.fromMillisecondsSinceEpoch(at, isUtc: true),
    action: action,
  );
}

DotAction? _action(Map<String, Object?> json) {
  final occurrence = _id(json['occurrence_id']);
  switch (json['kind']) {
    case 'add_task':
      final text = json['text'];
      if (text is! String || text.trim().isEmpty) return null;
      if (text.length > QuickAddParser.maxInputLength) return null;
      return AddTask(text);
    case 'mark_done' when occurrence != null:
      return MarkDone(occurrence);
    case 'start_focus' when occurrence != null:
      return StartFocus(occurrence);
    case 'add_fifteen' when occurrence != null:
      final end = json['planned_end_ms'];
      if (end is! int || end < 0) return null;
      return AddFifteen(
        occurrence,
        plannedEndUtc: DateTime.fromMillisecondsSinceEpoch(end, isUtc: true),
      );
  }
  return null;
}

// Ids are UUIDs everywhere (CLAUDE.md §2); anything else may be content.
final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

String? _id(Object? value) =>
    value is String && _uuid.hasMatch(value) ? value.toLowerCase() : null;
