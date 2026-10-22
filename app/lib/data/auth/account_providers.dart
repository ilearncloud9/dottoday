import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_providers.g.dart';

/// Before M6.1: no accounts, so every action reports [AuthFailure] and the
/// UI shows sign-in as coming with sync.
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
  Future<Result<void, AppFailure>> signOut() async => const Err(AuthFailure());

  @override
  Future<Result<void, AppFailure>> deleteAccount() async =>
      const Err(AuthFailure());
}

@Riverpod(keepAlive: true)
AccountService accountService(Ref ref) => const LocalOnlyAccountService();

/// The current account, live.
@Riverpod(keepAlive: true)
Stream<Account> account(Ref ref) => ref.watch(accountServiceProvider).watch();
