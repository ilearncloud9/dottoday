import 'dart:convert';

/// Public client configuration, compiled in via `--dart-define-from-file`
/// (ADR-0005): `app/.env` for debug, `app/.env.prod` for release.
///
/// Only public values belong here (docs/06-security.md §1): the Supabase URL
/// and **anon** key, plus optional Sentry DSN and Web Push VAPID public key.
final class Env {
  const Env({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.sentryDsn,
    this.webPushVapidPublicKey,
  });

  /// Reads the compile-time defines and validates them via [Env.fromMap].
  ///
  /// Values are `const` (baked in at compile time), so changing `.env`
  /// needs a full restart, not hot reload.
  factory Env.fromEnvironment() => Env.fromMap(const {
    'SUPABASE_URL': String.fromEnvironment('SUPABASE_URL'),
    'SUPABASE_ANON_KEY': String.fromEnvironment('SUPABASE_ANON_KEY'),
    'SENTRY_DSN': String.fromEnvironment('SENTRY_DSN'),
    'WEB_PUSH_VAPID_PUBLIC_KEY': String.fromEnvironment(
      'WEB_PUSH_VAPID_PUBLIC_KEY',
    ),
  });

  /// Builds an [Env] from raw key/value pairs, failing fast on bad config.
  ///
  /// Throws [EnvConfigError] when `SUPABASE_URL` is missing or not an absolute
  /// https URL (http only for localhost), when `SUPABASE_ANON_KEY` is missing,
  /// or when the key is a service-role/secret key.
  ///
  /// ```dart
  /// Env.fromMap({'SUPABASE_URL': 'https://x.supabase.co', 'SUPABASE_ANON_KEY': 'k'});
  /// ```
  factory Env.fromMap(Map<String, String> raw) {
    final anonKey = _required(raw, 'SUPABASE_ANON_KEY');
    if (_isSecretKey(anonKey)) {
      throw EnvConfigError(
        'SUPABASE_ANON_KEY is a service-role/secret key. Only the anon '
        '(publishable) key may ship in the client (docs/06-security.md §1).',
      );
    }
    return Env(
      supabaseUrl: _parseSupabaseUrl(_required(raw, 'SUPABASE_URL')),
      supabaseAnonKey: anonKey,
      sentryDsn: _optional(raw, 'SENTRY_DSN'),
      webPushVapidPublicKey: _optional(raw, 'WEB_PUSH_VAPID_PUBLIC_KEY'),
    );
  }

  final Uri supabaseUrl;
  final String supabaseAnonKey;
  final String? sentryDsn;
  final String? webPushVapidPublicKey;
}

/// Startup configuration bug: the app cannot run, so this is an [Error], not
/// a recoverable failure.
///
/// Deliberate i18n exception: these messages are developer-facing (shown in
/// the console/crash log before l10n exists) and are therefore plain English,
/// not `AppLocalizations`. They never include config values.
final class EnvConfigError extends Error {
  EnvConfigError(this.message);

  final String message;

  @override
  String toString() => 'EnvConfigError: $message';
}

/// Exact fix, shown whenever a required define is missing (ADR-0005).
const _hint =
    'Run from app/: '
    'flutter run --dart-define-from-file=.env '
    '(copy .env.example to .env first). Release: '
    'flutter build <target> --dart-define-from-file=.env.prod. '
    'Changing values needs a full restart.';

String _required(Map<String, String> raw, String key) {
  final value = raw[key]?.trim() ?? '';
  if (value.isEmpty) throw EnvConfigError('$key is missing. $_hint');
  return value;
}

String? _optional(Map<String, String> raw, String key) {
  final value = raw[key]?.trim() ?? '';
  return value.isEmpty ? null : value;
}

Uri _parseSupabaseUrl(String value) {
  final uri = Uri.tryParse(value);
  final isLocal = uri?.host == 'localhost' || uri?.host == '127.0.0.1';
  final schemeOk = uri?.scheme == 'https' || (uri?.scheme == 'http' && isLocal);
  if (uri == null || !uri.hasAuthority || !schemeOk) {
    throw EnvConfigError(
      'SUPABASE_URL must be an absolute https URL '
      '(http allowed only for localhost). $_hint',
    );
  }
  return uri;
}

/// True for new-style secret keys and legacy JWTs with `role: service_role`.
bool _isSecretKey(String key) {
  if (key.startsWith('sb_secret_')) return true;
  final parts = key.split('.');
  if (parts.length != 3) return false;
  try {
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final claims = jsonDecode(payload);
    return claims is Map<String, Object?> && claims['role'] == 'service_role';
  } on FormatException {
    return false;
  }
}
