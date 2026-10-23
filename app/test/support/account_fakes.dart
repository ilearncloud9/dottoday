import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/auth/account.dart';

/// Accounts on (docs/09 M3f.7, M4.5, M4.7): answers [result] to every
/// action, signed in as [account], and records what was asked. Push
/// restore progress through [restore].
final class FakeAccountService implements AccountService {
  FakeAccountService({
    this.result = const Ok(null),
    this.account = const LocalOnly(),
  });

  Result<void, AppFailure> result;
  final Account account;
  final calls = <String>[];
  // Closed by the tests that push progress (addTearDown).
  // ignore: close_sinks
  final restore = StreamController<RestoreProgress?>.broadcast();

  @override
  bool get available => true;

  /// Push a later account (a sign-in finishing in the browser).
  // Closed by the tests that push accounts (addTearDown).
  // ignore: close_sinks
  final accounts = StreamController<Account>.broadcast();

  @override
  Stream<Account> watch() async* {
    yield account;
    yield* accounts.stream;
  }

  @override
  Future<Result<void, AppFailure>> signIn(SignInMethod method) async {
    calls.add('signIn:${method.name}');
    return result;
  }

  @override
  Future<Result<void, AppFailure>> sendMagicLink(String email) async {
    calls.add('link:$email');
    return result;
  }

  @override
  Stream<RestoreProgress?> watchRestore() => restore.stream;

  @override
  Future<Result<void, AppFailure>> signOut({bool everywhere = false}) async {
    calls.add(everywhere ? 'signOutEverywhere' : 'signOut');
    return result;
  }

  @override
  Future<Result<void, AppFailure>> deleteAccount() async {
    calls.add('delete');
    return result;
  }
}
