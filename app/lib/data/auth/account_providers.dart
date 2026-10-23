import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/core/router/auth_callback.dart';
import 'package:dottoday/data/auth/supabase_account_service.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'account_providers.g.dart';

/// No Supabase client (tests, or it couldn't start): every action reports
/// [AuthFailure] and the UI shows sign-in as unavailable.
final class LocalOnlyAccountService implements AccountService {
  const LocalOnlyAccountService();

  @override
  bool get available => false;

  @override
  Stream<Account> watch() => Stream.value(const LocalOnly());

  @override
  Future<Result<void, AppFailure>> signIn(SignInMethod method) async =>
      const Err(AuthFailure());

  @override
  Future<Result<void, AppFailure>> sendMagicLink(String email) async =>
      const Err(AuthFailure());

  @override
  Stream<RestoreProgress?> watchRestore() => Stream.value(null);

  @override
  Future<Result<void, AppFailure>> signOut({bool everywhere = false}) async =>
      const Err(AuthFailure());

  @override
  Future<Result<void, AppFailure>> deleteAccount() async =>
      const Err(AuthFailure());
}

/// The Supabase client, when bootstrap could start one (M6.1); null in
/// tests and when it couldn't, and the app then stays on this device.
@Riverpod(keepAlive: true)
SupabaseClient? supabaseClient(Ref ref) => null;

/// Sign-in callbacks from the router (bootstrap overrides it with the
/// inbox the router delivers to).
@Riverpod(keepAlive: true)
AuthCallbackInbox authCallbackInbox(Ref ref) => AuthCallbackInbox();

@Riverpod(keepAlive: true)
AccountService accountService(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const LocalOnlyAccountService();
  final service = SupabaseAccountService(
    client.auth,
    // The web comes back to the page itself (Supabase reads the code there).
    redirectTo: kIsWeb
        ? '${Uri.base.origin}${Uri.base.path}'
        : authCallbackLink,
    callbacks: ref.watch(authCallbackInboxProvider).take(),
    logger: ref.watch(loggerProvider),
  );
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
}

/// The current account, live.
@Riverpod(keepAlive: true)
Stream<Account> account(Ref ref) => ref.watch(accountServiceProvider).watch();
