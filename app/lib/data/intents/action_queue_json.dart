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

/// [raw]'s array without the entries [ids] names (and, when [unreadable],
/// without entries that have no string id), re-encoded.
String withoutEntries(
  String? raw,
  Set<String> ids, {
  required bool unreadable,
}) {
  final kept = [
    for (final entry in decodeQueueArray(raw))
      if (!_drop(entry, ids, unreadable: unreadable)) entry,
  ];
  return jsonEncode(kept);
}

bool _drop(Object? entry, Set<String> ids, {required bool unreadable}) {
  final id = entry is Map<String, Object?> ? entry['id'] : null;
  if (id is! String) return unreadable;
  return ids.contains(id);
}
