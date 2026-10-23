import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Opens the provider's sign-in page; true when it opened. An extension
/// method in supabase_flutter, so tests pass their own.
typedef OpenOAuth =
    Future<bool> Function(OAuthProvider provider, String redirectTo);

/// [AccountService] over Supabase Auth (docs/09 M6.1, 02 F7, 06 §2): PKCE
/// for every method; Apple and Google through the provider's page, email
/// as a one-time link. Nothing here is needed to use the app: a failure
/// only means it stays on this device.
final class SupabaseAccountService implements AccountService {
  SupabaseAccountService(
    this._auth, {
    required this.redirectTo,
    required Stream<Uri> callbacks,
    required Logger logger,
    Stream<RestoreProgress> Function()? restore,
    OpenOAuth? openOAuth,
  }) : _logger = logger,
       _restore = restore,
       _openOAuth =
           openOAuth ??
           ((provider, redirect) =>
               _auth.signInWithOAuth(provider, redirectTo: redirect)) {
    _callbacks = callbacks.listen((uri) => unawaited(_exchange(uri)));
  }

  final GoTrueClient _auth;
  final Logger _logger;
  final OpenOAuth _openOAuth;
  final Stream<RestoreProgress> Function()? _restore;
  late final StreamSubscription<Uri> _callbacks;

  /// Where the sign-in page sends the code: `dottoday://auth-callback` in
  /// the apps, the page itself on the web.
  final String redirectTo;

  @override
  bool get available => true;

  @override
  Stream<Account> watch() async* {
    yield _accountOf(_auth.currentSession);
    yield* _auth.onAuthStateChange.map((s) => _accountOf(s.session));
  }

  @override
  Future<Result<void, AppFailure>> signIn(SignInMethod method) async {
    final provider = switch (method) {
      SignInMethod.apple => OAuthProvider.apple,
      SignInMethod.google => OAuthProvider.google,
      // Email has its own step: the address, then the link.
      SignInMethod.email => null,
    };
    if (provider == null) return const Err(AuthFailure());
    return _guard(_Step.oauth, () async {
      final opened = await _openOAuth(provider, redirectTo);
      if (!opened) throw const AuthException('sign-in page did not open');
    });
  }

  @override
  Future<Result<void, AppFailure>> sendMagicLink(String email) =>
      _guard(_Step.magicLink, () async {
        await _auth.signInWithOtp(email: email, emailRedirectTo: redirectTo);
      });

  /// The first sync bringing the account's tasks down (M6.4).
  @override
  Stream<RestoreProgress?> watchRestore() =>
      _restore?.call() ?? Stream.value(null);

  @override
  Future<Result<void, AppFailure>> signOut({bool everywhere = false}) =>
      _guard(_Step.signOut, () async {
        await _auth.signOut(
          scope: everywhere ? SignOutScope.global : SignOutScope.local,
        );
      });

  /// The server side arrives with M6.5 (Edge Function + email).
  @override
  Future<Result<void, AppFailure>> deleteAccount() async =>
      const Err(AuthFailure());

  /// Stops listening for callbacks (the provider's dispose).
  Future<void> dispose() => _callbacks.cancel();

  Future<void> _exchange(Uri uri) async {
    try {
      await _auth.getSessionFromUrl(uri);
    } on Object catch (e, s) {
      // The page stays on "check your mail" / Account; trying again works.
      _logger.warn('auth.callback_failed', error: e, stackTrace: s);
    }
  }

  Future<Result<void, AppFailure>> _guard(
    _Step step,
    Future<void> Function() run,
  ) async {
    try {
      await run();
      return const Ok(null);
    } on AuthRetryableFetchException catch (e, s) {
      // gotrue's wrapper for "couldn't reach the server".
      _log(step, e, s);
      return const Err(NetworkFailure(NetworkFailureKind.offline));
    } on AuthException catch (e, s) {
      _log(step, e, s);
      return const Err(AuthFailure());
    }
  }

  /// Literal events only (the PII policy): never the address or the error's
  /// text in the event itself.
  void _log(_Step step, Object e, StackTrace s) => switch (step) {
    _Step.oauth => _logger.warn('auth.oauth_failed', error: e, stackTrace: s),
    _Step.magicLink => _logger.warn(
      'auth.magic_link_failed',
      error: e,
      stackTrace: s,
    ),
    _Step.signOut => _logger.warn(
      'auth.sign_out_failed',
      error: e,
      stackTrace: s,
    ),
  };

  static Account _accountOf(Session? session) {
    final user = session?.user;
    if (user == null) return const LocalOnly();
    return SignedIn(
      email: user.email ?? '',
      method: switch (user.appMetadata['provider']) {
        'apple' => SignInMethod.apple,
        'google' => SignInMethod.google,
        _ => SignInMethod.email,
      },
    );
  }
}

enum _Step { oauth, magicLink, signOut }
