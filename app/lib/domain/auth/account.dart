import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';

/// Who the app syncs as (02 F7). Until accounts arrive (M6.1) everyone is
/// [LocalOnly]; the app is fully usable that way, always.
sealed class Account {
  const Account();
}

/// No account: everything stays on this device.
final class LocalOnly extends Account {
  const LocalOnly();
}

/// Signed in as [email] through [method].
final class SignedIn extends Account {
  const SignedIn({required this.email, required this.method});

  final String email;
  final SignInMethod method;
}

/// The sign-in methods of 02 F7 / docs/06 §2.
enum SignInMethod { apple, google, email }

/// Account actions behind Settings › Account and onboarding O5 (docs/09
/// M3f.7, M4.5); the real one talks to Supabase Auth in M6.1 / M6.5.
abstract interface class AccountService {
  /// Whether sign-in is offered at all in this build.
  bool get available;

  Stream<Account> watch();

  Future<Result<void, AppFailure>> signIn(SignInMethod method);

  /// Emails a sign-in link to [email] (already checked, `checkEmail`).
  Future<Result<void, AppFailure>> sendMagicLink(String email);

  /// While a signed-in device brings the account's tasks down (a
  /// returning user, docs/09 M4.7): how far it is; null when not.
  Stream<RestoreProgress?> watchRestore();

  Future<Result<void, AppFailure>> signOut();

  /// Deletes the account and its synced data (docs/06 §6); the device keeps
  /// its local copy.
  Future<Result<void, AppFailure>> deleteAccount();
}

/// "Bringing your tasks… 120 of 300".
final class RestoreProgress {
  const RestoreProgress({required this.done, required this.total});

  final int done;
  final int total;

  bool get finished => done >= total;
}
