import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/shared/account/decision_frame.dart';
import 'package:dottoday/shared/account/sign_in_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _Step { choose, email, checkMail }

/// A3's "Sign in": the same choices as Settings › Account and O5 (Apple,
/// Google, email, then "Check your mail"), built from the shared sign-in
/// parts. The account gate moves on by itself once the account is signed
/// in; [onBack] returns to A3.
class SignInPanel extends ConsumerStatefulWidget {
  const SignInPanel({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  ConsumerState<SignInPanel> createState() => _SignInPanelState();
}

/// A leaf: the step, the address, the request in flight, the error.
class _SignInPanelState extends ConsumerState<SignInPanel> {
  var _step = _Step.choose;
  var _busy = false;
  var _email = '';
  String? _error;
  VoidCallback? _retry;

  AccountService get _service => ref.read(accountServiceProvider);

  Future<void> _run(
    Future<Result<void, AppFailure>> Function() op, {
    _Step? then,
  }) async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
      _retry = () => unawaited(_run(op, then: then));
    });
    final result = await op();
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case Ok():
          _step = then ?? _step;
        case Err(:final failure):
          _error = failureMessage(l10n, failure);
      }
    });
  }

  void _send(String email) {
    final trimmed = email.trim();
    if (checkEmail(trimmed) != null) {
      setState(() => _error = context.l10n.accountEmailInvalid);
      return;
    }
    _email = trimmed;
    unawaited(
      _run(() => _service.sendMagicLink(trimmed), then: _Step.checkMail),
    );
  }

  void _to(_Step step) => setState(() {
    _step = step;
    _error = null;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final available = _service.available;
    return DecisionFrame(
      title: l10n.signedOutSignIn,
      content: [
        ...switch (_step) {
          _Step.choose => [
            SignInChoices(
              enabled: available && !_busy,
              available: available,
              onPick: (m) => m == SignInMethod.email
                  ? _to(_Step.email)
                  : unawaited(_run(() => _service.signIn(m))),
            ),
          ],
          _Step.email => [
            EmailForm(
              initial: _email,
              busy: _busy,
              onSend: _send,
              onBack: () => _to(_Step.choose),
            ),
          ],
          _Step.checkMail => [
            CheckMail(
              email: _email,
              onResend: _busy ? null : () => _send(_email),
              onOtherEmail: () => _to(_Step.email),
            ),
          ],
        },
        if (_error case final error?)
          AccountError(message: error, onRetry: _busy ? null : _retry),
      ],
      actions: [
        TextButton(onPressed: widget.onBack, child: Text(l10n.onboardingBack)),
      ],
    );
  }
}
