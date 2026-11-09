import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/domain/auth/account.dart';

/// The server's `delete-account` for [account], with hooks for what
/// happens while it runs ([during]) and right after the removal ([after]).
final class DeletingServer implements AccountService {
  DeletingServer(this.account);

  final String account;
  late OwnerSwitch owners;
  FutureOr<void> Function()? during;
  FutureOr<void> Function()? after;
  var fails = false;
  var deletes = 0;

  @override
  Future<Result<void, AppFailure>> deleteAccount() async {
    deletes++;
    await during?.call();
    if (fails) return const Err(NetworkFailure(NetworkFailureKind.server));
    await owners.accountDeleted(account);
    await after?.call();
    return const Ok(null);
  }

  @override
  bool get available => true;
  @override
  Stream<Account> watch() => const Stream.empty();
  @override
  Future<Result<void, AppFailure>> signIn(SignInMethod method) async =>
      const Ok(null);
  @override
  Future<Result<void, AppFailure>> sendMagicLink(String email) async =>
      const Ok(null);
  @override
  Stream<RestoreProgress?> watchRestore() => const Stream.empty();
  @override
  Future<Result<void, AppFailure>> signOut({bool everywhere = false}) async =>
      const Ok(null);
}
