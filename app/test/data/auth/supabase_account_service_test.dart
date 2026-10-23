import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/auth/supabase_account_service.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../support/fake_clock.dart';
import '../../support/memory_log_sink.dart';

// Supabase Auth behind AccountService (docs/09 M6.1); the real flow runs
// against local Supabase in test/supabase/.

final class _Auth extends Mock implements GoTrueClient {}

const _redirect = 'dottoday://auth-callback';

Session _session(String provider) => Session(
  accessToken: 'a',
  tokenType: 'bearer',
  user: User(
    id: 'u',
    appMetadata: {'provider': provider},
    userMetadata: const {},
    aud: 'authenticated',
    email: 'kody@example.com',
    createdAt: '2026-10-23T00:00:00Z',
  ),
);

void main() {
  late _Auth auth;
  late StreamController<AuthState> states;
  late StreamController<Uri> callbacks;
  late MemoryLogSink logs;
  late SupabaseAccountService service;
  late List<(OAuthProvider, String)> opened;
  var opens = true;

  setUpAll(() {
    registerFallbackValue(OAuthProvider.apple);
    registerFallbackValue(Uri());
    registerFallbackValue(SignOutScope.local);
  });

  setUp(() {
    auth = _Auth();
    states = StreamController<AuthState>.broadcast();
    callbacks = StreamController<Uri>();
    logs = MemoryLogSink();
    opened = [];
    opens = true;
    when(() => auth.currentSession).thenReturn(null);
    when(() => auth.onAuthStateChange).thenAnswer((_) => states.stream);
    service = SupabaseAccountService(
      auth,
      redirectTo: _redirect,
      callbacks: callbacks.stream,
      logger: Logger(logs, FakeClock(DateTime.utc(2026, 10, 23))),
      openOAuth: (provider, redirect) async {
        opened.add((provider, redirect));
        return opens;
      },
    );
  });

  tearDown(() async {
    await service.dispose();
    await states.close();
    await callbacks.close();
  });

  test('watch: local until a session, then who and how', () async {
    final seen = <Account>[];
    final sub = service.watch().listen(seen.add);
    await pumpEventQueue();
    states.add(AuthState(AuthChangeEvent.signedIn, _session('google')));
    await pumpEventQueue();
    await sub.cancel();
    expect(seen.first, isA<LocalOnly>());
    final signedIn = seen.last as SignedIn;
    expect(signedIn.email, 'kody@example.com');
    expect(signedIn.method, SignInMethod.google);
  });

  test('Apple and Google open the provider with the app callback', () async {
    expect(
      await service.signIn(SignInMethod.apple),
      isA<Ok<void, AppFailure>>(),
    );
    await service.signIn(SignInMethod.google);
    expect(opened, [
      (OAuthProvider.apple, _redirect),
      (OAuthProvider.google, _redirect),
    ]);
    expect(
      await service.signIn(SignInMethod.email),
      isA<Err<void, AppFailure>>(),
    );
  });

  test('a page that did not open is an auth failure', () async {
    opens = false;
    final result = await service.signIn(SignInMethod.google);
    expect((result as Err).failure, isA<AuthFailure>());
  });

  test('magic link goes to the address with the callback', () async {
    when(
      () => auth.signInWithOtp(
        email: any(named: 'email'),
        emailRedirectTo: any(named: 'emailRedirectTo'),
      ),
    ).thenAnswer((_) async {});
    await service.sendMagicLink('kody@example.com');
    verify(
      () => auth.signInWithOtp(
        email: 'kody@example.com',
        emailRedirectTo: _redirect,
      ),
    ).called(1);
  });

  test('offline is a network failure, never a crash', () async {
    when(
      () => auth.signInWithOtp(
        email: any(named: 'email'),
        emailRedirectTo: any(named: 'emailRedirectTo'),
      ),
    ).thenThrow(AuthRetryableFetchException(message: 'no route'));
    final result = await service.sendMagicLink('kody@example.com');
    expect(
      (result as Err).failure,
      const NetworkFailure(NetworkFailureKind.offline),
    );
    expect(logs.records.single.event, 'auth.magic_link_failed');
  });

  test('sign out: this device, or everywhere', () async {
    when(
      () => auth.signOut(scope: any(named: 'scope')),
    ).thenAnswer((_) async {});
    await service.signOut();
    await service.signOut(everywhere: true);
    verifyInOrder([
      () => auth.signOut(scope: SignOutScope.local),
      () => auth.signOut(scope: SignOutScope.global),
    ]);
  });

  group('delete account (M6.5)', () {
    SupabaseAccountService withRemote(Future<void> Function() remote) =>
        SupabaseAccountService(
          auth,
          redirectTo: _redirect,
          callbacks: const Stream.empty(),
          logger: Logger(logs, FakeClock(DateTime.utc(2026, 10, 23))),
          deleteRemote: remote,
        );

    test('the function runs, then this device signs out', () async {
      when(
        () => auth.signOut(scope: any(named: 'scope')),
      ).thenAnswer((_) async {});
      var called = 0;
      final s = withRemote(() async => called++);
      expect(await s.deleteAccount(), isA<Ok<void, AppFailure>>());
      expect(called, 1);
      verify(() => auth.signOut(scope: SignOutScope.local)).called(1);
      await s.dispose();
    });

    test('the server refuses: an error, still signed in', () async {
      final s = withRemote(() => throw const FunctionException(status: 500));
      final r = await s.deleteAccount();
      expect(
        (r as Err).failure,
        const NetworkFailure(NetworkFailureKind.server),
      );
      verifyNever(() => auth.signOut(scope: any(named: 'scope')));
      await s.dispose();
    });

    test('without the function wired: refused', () async {
      expect(await service.deleteAccount(), isA<Err<void, AppFailure>>());
    });
  });

  test('a callback link is exchanged for the session', () async {
    when(() => auth.getSessionFromUrl(any())).thenAnswer(
      (_) async => AuthSessionUrlResponse(
        session: _session('email'),
        redirectType: null,
      ),
    );
    final link = Uri.parse('$_redirect?code=abc');
    callbacks.add(link);
    await pumpEventQueue();
    verify(() => auth.getSessionFromUrl(link)).called(1);
  });

  test('a failed exchange is logged, not thrown', () async {
    when(
      () => auth.getSessionFromUrl(any()),
    ).thenThrow(const AuthException('code expired'));
    callbacks.add(Uri.parse('$_redirect?code=old'));
    await pumpEventQueue();
    expect(logs.records.single.event, 'auth.callback_failed');
  });
}
