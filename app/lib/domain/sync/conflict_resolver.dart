import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/domain/sync/hlc.dart';

/// One field's value as written by one device (docs/04 §4 `change_log`).
///
/// [value] is the JSON value of the column (null, bool, num, String, List,
/// Map) — never logged, it may be task content.
final class FieldChange {
  const FieldChange({
    required this.entity,
    required this.entityId,
    required this.field,
    required this.value,
    required this.hlc,
  });

  final EntityKind entity;
  final String entityId;
  final String field;
  final Object? value;
  final Hlc hlc;

  @override
  String toString() => 'FieldChange(${entity.name}/$entityId.$field @ $hlc)';
}

/// How one field resolves when local and remote both changed it.
sealed class FieldResolution {
  const FieldResolution();
}

/// Local is newer and wins; keep it and push it.
final class KeepLocal extends FieldResolution {
  const KeepLocal(this.local);

  final FieldChange local;
}

/// Remote is newer (or identical); apply it locally.
final class TakeRemote extends FieldResolution {
  const TakeRemote(this.remote);

  final FieldChange remote;
}

/// Same field changed to different values on two devices within
/// [ConflictResolver.window]: the server value is applied (the default) and
/// a `conflicts` row lets the user pick "keep mine" (R-08).
final class Conflict extends FieldResolution {
  const Conflict({required this.mine, required this.theirs});

  final FieldChange mine;
  final FieldChange theirs;

  /// The value applied until the user decides.
  FieldChange get applied => theirs;
}

/// Per-field last-writer-wins over HLCs, with near-simultaneous edits
/// surfaced as conflicts instead of silently dropped (ADR-0002, R-08).
final class ConflictResolver {
  const ConflictResolver();

  /// Edits of one field closer than this are "simultaneous" (docs/04 §4).
  static const window = Duration(seconds: 60);

  /// Resolves [local] (unpushed) against [remote] (pulled) for one field.
  ///
  /// ```dart
  /// resolver.resolve(mine, theirs); // KeepLocal | TakeRemote | Conflict
  /// ```
  FieldResolution resolve(FieldChange local, FieldChange remote) {
    if (local.entity != remote.entity ||
        local.entityId != remote.entityId ||
        local.field != remote.field) {
      throw ArgumentError('resolve() needs two changes of the same field');
    }
    if (jsonEquals(local.value, remote.value)) return TakeRemote(remote);
    final gap = (local.hlc.ms - remote.hlc.ms).abs();
    if (gap < window.inMilliseconds) {
      return Conflict(mine: local, theirs: remote);
    }
    return local.hlc > remote.hlc ? KeepLocal(local) : TakeRemote(remote);
  }

  /// Resolves every field of one row present on both sides; fields changed
  /// on one side only are not in the result (they simply apply).
  Map<String, FieldResolution> resolveRow(
    Map<String, FieldChange> local,
    Map<String, FieldChange> remote,
  ) =>
      {
        for (final field in local.keys)
          if (remote[field] case final theirs?)
            field: resolve(local[field]!, theirs),
      };
}

/// Structural equality of decoded JSON values (lists in order, maps by key).
bool jsonEquals(Object? a, Object? b) {
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!jsonEquals(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    return a.keys.every((k) => b.containsKey(k) && jsonEquals(a[k], b[k]));
  }
  return a == b;
}
