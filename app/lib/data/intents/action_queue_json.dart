import 'dart:convert';

/// The queue's wire form in every shared store: one JSON array of
/// `encodeQueuedAction` maps under the key [actionQueueKey].
const actionQueueKey = 'action_queue';

/// The entries in [raw]; a missing or broken array reads as empty.
List<Object?> decodeQueueArray(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  try {
    final json = jsonDecode(raw);
    return json is List<Object?> ? json : const [];
  } on FormatException {
    return const [];
  }
}

/// Whether [raw] is a queue that can be rewritten: none yet, or a JSON
/// array. An unreadable queue is never written over (CR-160 I7).
bool isRewritable(String? raw) {
  if (raw == null || raw.isEmpty) return true;
  try {
    return jsonDecode(raw) is List<Object?>;
  } on FormatException {
    return false;
  }
}

/// [raw]'s array without the entries [ids] names, re-encoded. Entries
/// without a string id are kept (CR-160 I7: never discarded unread).
String withoutEntries(String? raw, Set<String> ids) => jsonEncode([
  for (final entry in decodeQueueArray(raw))
    if (!_named(entry, ids)) entry,
]);

bool _named(Object? entry, Set<String> ids) {
  final id = entry is Map<String, Object?> ? entry['id'] : null;
  return id is String && ids.contains(id);
}
