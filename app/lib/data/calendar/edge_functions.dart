import 'package:supabase_flutter/supabase_flutter.dart';

/// Calls one Supabase Edge Function with a JSON body, as the signed-in
/// user (docs/09 M7.4). A port, so tests never reach the network.
abstract interface class EdgeFunctions {
  /// The decoded JSON answer of [name]; throws [EdgeFunctionError] for a
  /// non-2xx answer, and whatever the HTTP client throws when offline.
  Future<Object?> call(String name, Map<String, Object?> body);
}

/// A function answered with [status]; [error] is its stable code
/// (`reconnect`, `provider`, `not_configured`), never content.
final class EdgeFunctionError implements Exception {
  const EdgeFunctionError(this.status, [this.error]);

  final int status;
  final String? error;

  @override
  String toString() => 'EdgeFunctionError($status, $error)';
}

/// [EdgeFunctions] over the Supabase client (it adds the session's JWT).
final class SupabaseEdgeFunctions implements EdgeFunctions {
  const SupabaseEdgeFunctions(this._client);

  final SupabaseClient _client;

  @override
  Future<Object?> call(String name, Map<String, Object?> body) async {
    try {
      final response = await _client.functions.invoke(name, body: body);
      return response.data;
    } on FunctionException catch (e) {
      final details = e.details;
      final code = details is Map ? details['error'] : null;
      throw EdgeFunctionError(e.status, code is String ? code : null);
    }
  }
}
