import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/auth/supabase_account_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../support/fake_clock.dart';
import '../../support/memory_log_sink.dart';

// CR-160 blocker 4: signing out offline. gotrue clears this device's
// session before it tells the server, so the sign-out has happened here
// even when the server can't be reached.

final class _Auth extends Mock implements GoTrueClient {}

Session _session() => Session(
  accessToken: 'a',
  tokenType: 'bearer',
  user: const User(
    id: 'u',
    appMetadata: {'provider': 'email'},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2026-10-23T00:00:00Z',
  ),
);

void main() {
  late _Auth auth;
  late SupabaseAccountService service;
  Session? session;

  setUpAll(() => registerFallbackValue(SignOutScope.local));

  setUp(() {
    auth = _Auth();
    session = _session();
    when(() => auth.currentSession).thenAnswer((_) => session);
    when(() => auth.onAuthStateChange).thenAnswer((_) => const Stream.empty());
    service = SupabaseAccountService(
      auth,
      redirectTo: 'dottoday://auth-callback',
      callbacks: const Stream.empty(),
      logger: Logger(MemoryLogSink(), FakeClock(DateTime.utc(2026, 11, 12))),
      openOAuth: (_, _) async => true,
    );
  });

  /// gotrue offline: the session goes, then the server call fails.
  void offline({bool clears = true}) =>
      when(() => auth.signOut(scope: any(named: 'scope'))).thenAnswer((
        _,
      ) async {
        if (clears) session = null;
        throw AuthRetryableFetchException();
      });

  test('this device, offline: signed out here, no error', () async {
    offline();
    expect(await service.signOut(), isA<Ok<void, AppFailure>>());
  });

  test(
    'everywhere, offline: signed out here, the others not, said so',
    () async {
      offline();
      final r = await service.signOut(everywhere: true);
      expect(
        (r as Err<void, AppFailure>).failure,
        isA<SignedOutHereOnlyFailure>(),
      );
    },
  );

  test('offline before the session went: still the network failure', () async {
    offline(clears: false);
    final r = await service.signOut();
    expect((r as Err<void, AppFailure>).failure, isA<NetworkFailure>());
  });
}
