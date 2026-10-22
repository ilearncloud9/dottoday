import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/features/onboarding/steps/step_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// O5 Account (docs/10 §5.1, docs/09 M4.5): Apple / Google / email, or
/// "Continue without an account" — the main button, because the app is
/// whole without one (02 F7). Built on `AccountService`; until accounts
/// arrive (M6.1) the sign-in buttons are off and say so.
class AccountStep extends ConsumerStatefulWidget {
  const AccountStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  ConsumerState<AccountStep> createState() => _AccountStepState();
}

/// A leaf: the request in flight and its error.
class _AccountStepState extends ConsumerState<AccountStep> {
  var _busy = false;
  String? _error;

  Future<void> _signIn(SignInMethod method) async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(accountServiceProvider).signIn(method);
    if (!mounted) return;
    switch (result) {
      case Ok():
        widget.onNext();
      case Err(:final failure):
        setState(() {
          _busy = false;
          _error = failureMessage(l10n, failure);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final service = ref.watch(accountServiceProvider);
    VoidCallback? go(SignInMethod m) =>
        service.available && !_busy ? () => unawaited(_signIn(m)) : null;
    return StepFrame(
      title: l10n.onboardingAccountTitle,
      body: l10n.onboardingAccountBody,
      primary: l10n.onboardingWithoutAccount,
      onPrimary: _busy ? null : widget.onNext,
      children: [
        OutlinedButton(
          onPressed: go(SignInMethod.apple),
          child: Text(l10n.accountApple),
        ),
        OutlinedButton(
          onPressed: go(SignInMethod.google),
          child: Text(l10n.accountGoogle),
        ),
        OutlinedButton(
          onPressed: go(SignInMethod.email),
          child: Text(l10n.accountEmail),
        ),
        if (!service.available)
          Text(
            l10n.accountComingSoon,
            style: t.styles.body.copyWith(color: t.colors.muted),
          ),
        if (_error case final error?)
          Semantics(liveRegion: true, child: Text(error, style: t.styles.body)),
      ],
    );
  }
}
