import 'dart:async';
import 'dart:convert';

import 'package:dottoday/core/clock/clock.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// This device's clock against the server's (docs/09 M6.5.7), read from
/// the `iat` (issued-at, server time) of each access token the server
/// hands out — at sign-in and on every refresh, at least hourly. No extra
/// request and no new dependency (rejected: an `http` client wrapper
/// reading `Date` headers, or a `server_now()` RPC needing a migration).
///
/// A session restored from storage is old, so only fresh tokens count.
/// The offset includes the network latency of one response (seconds),
/// far inside the 5-minute bound it is compared with.
final class ServerClock {
  ServerClock(this._clock);

  final Clock _clock;
  Duration? _offset;
  StreamSubscription<AuthState>? _sub;

  /// Device minus server, from the last fresh token; null until one came.
  Duration? get offset => _offset;

  /// Listens to [auth] for fresh tokens until [dispose].
  void watch(GoTrueClient auth) {
    _sub ??= auth.onAuthStateChange.listen((state) {
      final fresh = {
        AuthChangeEvent.signedIn,
        AuthChangeEvent.tokenRefreshed,
      }.contains(state.event);
      final token = state.session?.accessToken;
      if (fresh && token != null) record(token);
    });
  }

  /// Takes the offset from a just-issued [accessToken]; ignores a token it
  /// can't read.
  void record(String accessToken) {
    final iat = _issuedAt(accessToken);
    if (iat == null) return;
    _offset = _clock.nowUtc().difference(iat);
  }

  Future<void> dispose() async => _sub?.cancel();

  static DateTime? _issuedAt(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) return null;
    try {
      final json = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final claims = jsonDecode(json);
      final iat = claims is Map<String, Object?> ? claims['iat'] : null;
      return iat is int
          ? DateTime.fromMillisecondsSinceEpoch(iat * 1000, isUtc: true)
          : null;
    } on FormatException {
      return null;
    }
  }
}
