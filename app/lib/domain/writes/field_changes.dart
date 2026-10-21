import 'package:dottoday/domain/sync/conflict_resolver.dart';

/// Columns never carried in `change_log`: identity, and `updated_at`, which
/// the server assigns (docs/04 §4).
const _notLogged = {'id', 'user_id', 'updated_at'};

/// Names of the fields of entity JSON [next] that differ from [previous]
/// (every loggable field when [previous] is null, i.e. an insert), in key
/// order. These become `change_log` rows for `sync_push`.
///
/// ```dart
/// changedFields({'title': 'a', 'notes': null}, {'title': 'b', 'notes': null})
/// // ['title']
/// ```
List<String> changedFields(
  Map<String, Object?>? previous,
  Map<String, Object?> next,
) => [
  for (final MapEntry(:key, :value) in next.entries)
    if (!_notLogged.contains(key) &&
        (previous == null ||
            !previous.containsKey(key) ||
            !jsonEquals(previous[key], value)))
      key,
];
