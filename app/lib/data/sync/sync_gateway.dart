/// One entity version going up: every field the device changed under one
/// HLC (docs/04 §4). Values are already in the server's form. [owner] is
/// the local owner the change belongs to; `sync_push` refuses it unless
/// it is the signed-in account (CR-160 criterion 12).
final class PushChange {
  const PushChange({
    required this.owner,
    required this.entity,
    required this.id,
    required this.hlc,
    required this.fields,
  });

  final String owner;
  final String entity;
  final String id;
  final String hlc;
  final Map<String, Object?> fields;

  Map<String, Object?> toJson() => {
    'owner': owner,
    'entity': entity,
    'id': id,
    'hlc': hlc,
    'fields': fields,
  };
}

/// Why a server round trip failed: the device is offline (try again
/// later), or the server said no (logged, shown as an error). Local data
/// is untouched either way (R-08).
enum SyncTrouble { offline, server }

/// A failed round trip.
final class SyncGatewayException implements Exception {
  const SyncGatewayException(this.trouble, this.cause);

  final SyncTrouble trouble;
  final Object cause;

  @override
  String toString() => 'SyncGatewayException(${trouble.name})';
}

/// Where a pull resumes, in the server's (`updated_at`, `id`) order: after
/// the row [id] stamped [updatedAt], or from [updatedAt] on (inclusive)
/// when [id] is null. [updatedAt] is the server's own text, so no
/// precision is lost on the way back.
typedef PullCursor = ({String updatedAt, String? id});

/// The server side of sync (docs/04 §4, ADR-0002): a port, Supabase in the
/// app and a fake in tests. Every call runs as the signed-in user (RLS).
abstract interface class SyncGateway {
  /// Applies [changes] with per-field last-writer-wins (`sync_push`).
  /// Throws [SyncGatewayException].
  Future<void> push(List<PushChange> changes);

  /// Rows of [entity] after [after] in (`updated_at`, `id`) order, at
  /// most [limit]; values in the server's form. Throws
  /// [SyncGatewayException].
  Future<List<Map<String, Object?>>> pull(
    String entity,
    PullCursor after, {
    required int limit,
  });

  /// How many rows of [entity] [pull] would bring from [sinceUtc] (for
  /// "Bringing your tasks… 120 of 300"). Throws [SyncGatewayException].
  Future<int> count(String entity, DateTime sinceUtc);

  /// The server's HLC per field of the rows [ids] of [entity]: the clock
  /// each field was last written with. Throws [SyncGatewayException].
  Future<Map<String, Map<String, String>>> fieldVersions(
    String entity,
    List<String> ids,
  );

  /// A nudge whenever the server reports a change to the user's rows, and
  /// each time the live feed (re)joins, since changes while it was down
  /// went unannounced (Realtime); the engine then pulls.
  Stream<void> changes();
}
