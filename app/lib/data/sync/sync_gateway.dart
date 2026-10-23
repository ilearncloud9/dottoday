/// One entity version going up: every field the device changed under one
/// HLC (docs/04 §4). Values are already in the server's form.
final class PushChange {
  const PushChange({
    required this.entity,
    required this.id,
    required this.hlc,
    required this.fields,
  });

  final String entity;
  final String id;
  final String hlc;
  final Map<String, Object?> fields;

  Map<String, Object?> toJson() => {
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

/// The server side of sync (docs/04 §4, ADR-0002): a port, Supabase in the
/// app and a fake in tests. Every call runs as the signed-in user (RLS).
abstract interface class SyncGateway {
  /// Applies [changes] with per-field last-writer-wins (`sync_push`).
  /// Throws [SyncGatewayException].
  Future<void> push(List<PushChange> changes);

  /// Rows of [entity] updated at or after [sinceUtc], oldest first, at
  /// most [limit]; values in the server's form. Throws
  /// [SyncGatewayException].
  Future<List<Map<String, Object?>>> pull(
    String entity,
    DateTime sinceUtc, {
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

  /// A nudge whenever the server reports a change to the user's rows
  /// (Realtime); the engine then pulls.
  Stream<void> changes();
}
