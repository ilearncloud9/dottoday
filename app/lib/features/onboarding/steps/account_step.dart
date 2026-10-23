import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/features/onboarding/steps/step_frame.dart';
import 'package:dottoday/shared/account/sign_in_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where O5 is (docs/09 M4.7).
enum _Phase { choose, email, checkMail, restoring }

/// O5 Account (docs/10 §5.1, docs/09 M4.5 / M4.7): Apple / Google /
/// email, or "Continue without an account" — the main button, because
/// the app is whole without one (02 F7). By email: the address, then
/// "Check your mail". A failure shows why with Try again. After signing
/// in, a returning user's tasks come down ("Bringing your tasks… 120 of
/// 300") before moving on. [returning] (O1's "I already have an
/// account") says "Welcome back". Built on `AccountService`; without a
/// server the sign-in buttons are off and say so. It moves on when the
/// account is signed in, not when a sign-in page opens: closing Apple's
/// or Google's page, or a link opened later, mustn't skip ahead (M6.1).
class AccountStep extends ConsumerStatefulWidget {
  const AccountStep({required this.onNext, this.returning = false, super.key});

  final VoidCallback onNext;
  final bool returning;

  @override
  ConsumerState<AccountStep> createState() => _AccountStepState();
}

/// A leaf: the phase, the request in flight, the last error and retry.
class _AccountStepState extends ConsumerState<AccountStep> {
  // Already signed in (back to O5 after signing in, or a restart mid-way):
  // straight to bringing the tasks down, then on (M6.6).
  late var _phase = ref.read(accountProvider).value is SignedIn
      ? _Phase.restoring
      : _Phase.choose;
  var _busy = false;
  String? _error;
  String _email = '';
  Future<void> Function()? _retry;

  AccountService get _service => ref.read(accountServiceProvider);

  /// Runs [op]; Ok → [then], Err → the error with Try again.
  Future<void> _run(
    Future<Result<void, AppFailure>> Function() op,
    VoidCallback then,
  ) async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
      _retry = () => _run(op, then);
    });
    final result = await op();
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok():
        then();
      case Err(:final failure):
        setState(() => _error = failureMessage(l10n, failure));
    }
  }

  void _signedIn() => setState(() {
    _phase = _Phase.restoring;
    _error = null;
  });

  void _send(String email) {
    final trimmed = email.trim();
    if (checkEmail(trimmed) != null) {
      setState(() => _error = context.l10n.accountEmailInvalid);
      return;
    }
    _email = trimmed;
    unawaited(
      _run(
        () => _service.sendMagicLink(trimmed),
        () => setState(() => _phase = _Phase.checkMail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.listen(accountProvider, (_, next) {
      if (next.value is SignedIn && _phase != _Phase.restoring) _signedIn();
    });
    return StepFrame(
      title: widget.returning
          ? l10n.onboardingWelcomeBackTitle
          : l10n.onboardingAccountTitle,
      body: widget.returning
          ? l10n.onboardingWelcomeBackBody
          : l10n.onboardingAccountBody,
      primary: l10n.onboardingWithoutAccount,
      onPrimary: _busy || _phase == _Phase.restoring ? null : widget.onNext,
      children: [
        ..._content(),
        if (_error case final error?)
          AccountError(
            message: error,
            onRetry: _busy || _retry == null
                ? null
                : () => unawaited(_retry!()),
          ),
      ],
    );
  }

  List<Widget> _content() => switch (_phase) {
    _Phase.choose => [
      SignInChoices(
        enabled: _service.available && !_busy,
        available: _service.available,
        onPick: (m) => m == SignInMethod.email
            ? setState(() {
                _phase = _Phase.email;
                _error = null;
              })
            // The page opened; the account stream says when it's done.
            : unawaited(_run(() => _service.signIn(m), () {})),
      ),
    ],
    _Phase.email => [
      EmailForm(
        initial: _email,
        busy: _busy,
        onSend: _send,
        onBack: () => setState(() {
          _phase = _Phase.choose;
          _error = null;
        }),
      ),
    ],
    _Phase.checkMail => [
      CheckMail(
        email: _email,
        onResend: _busy ? null : () => _send(_email),
        onOtherEmail: () => setState(() => _phase = _Phase.email),
      ),
    ],
    _Phase.restoring => [
      Restoring(stream: _service.watchRestore(), onDone: widget.onNext),
    ],
  };
}
