import 'dart:convert';

import 'package:dottoday/core/env/env.dart';
import 'package:flutter_test/flutter_test.dart';

String _jwt(Map<String, Object> claims) {
  String part(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.${part(claims)}.sig';
}

Map<String, String> _valid([Map<String, String> overrides = const {}]) => {
  'SUPABASE_URL': 'https://abc.supabase.co',
  'SUPABASE_ANON_KEY': _jwt({'role': 'anon'}),
  ...overrides,
};

Matcher _throwsEnv(String fragment) => throwsA(
  isA<EnvConfigError>().having((e) => e.message, 'message', contains(fragment)),
);

void main() {
  group('Env.fromMap', () {
    test('parses a valid config; empty optionals become null', () {
      final env = Env.fromMap(
        _valid({'SENTRY_DSN': '  ', 'WEB_PUSH_VAPID_PUBLIC_KEY': 'v'}),
      );

      expect(env.supabaseUrl, Uri.parse('https://abc.supabase.co'));
      expect(env.sentryDsn, isNull);
      expect(env.webPushVapidPublicKey, 'v');
    });

    test('allows http for local supabase', () {
      final env = Env.fromMap(
        _valid({'SUPABASE_URL': 'http://127.0.0.1:54321'}),
      );

      expect(env.supabaseUrl.port, 54321);
    });

    test('fails fast when SUPABASE_URL is missing or blank', () {
      expect(
        () => Env.fromMap(_valid()..remove('SUPABASE_URL')),
        _throwsEnv('SUPABASE_URL is missing'),
      );
      expect(
        () => Env.fromMap(_valid({'SUPABASE_URL': ' '})),
        _throwsEnv('SUPABASE_URL is missing'),
      );
    });

    test('rejects relative, non-https and remote-http URLs', () {
      for (final url in [
        'abc.supabase.co',
        'ftp://abc.supabase.co',
        'http://abc.supabase.co',
      ]) {
        expect(
          () => Env.fromMap(_valid({'SUPABASE_URL': url})),
          _throwsEnv('absolute https'),
          reason: url,
        );
      }
    });

    test('fails fast when SUPABASE_ANON_KEY is missing', () {
      expect(
        () => Env.fromMap(_valid()..remove('SUPABASE_ANON_KEY')),
        _throwsEnv('SUPABASE_ANON_KEY is missing'),
      );
    });

    test('rejects service-role and secret keys', () {
      for (final key in [
        _jwt({'role': 'service_role'}),
        'sb_secret_abc',
      ]) {
        expect(
          () => Env.fromMap(_valid({'SUPABASE_ANON_KEY': key})),
          _throwsEnv('service-role'),
        );
      }
    });

    test('accepts new-style publishable keys', () {
      expect(
        Env.fromMap(
          _valid({'SUPABASE_ANON_KEY': 'sb_publishable_abc'}),
        ).supabaseAnonKey,
        'sb_publishable_abc',
      );
    });

    test('missing define names the exact command to run', () {
      // No --dart-define-from-file in `flutter test`, so defines are empty.
      expect(
        Env.fromEnvironment,
        _throwsEnv('flutter run --dart-define-from-file=.env'),
      );
    });

    test('error messages never echo config values', () {
      try {
        Env.fromMap(_valid({'SUPABASE_URL': 'http://leak.example.com'}));
        fail('expected EnvConfigError');
      } on EnvConfigError catch (e) {
        expect(e.toString(), isNot(contains('leak')));
      }
    });
  });
}
