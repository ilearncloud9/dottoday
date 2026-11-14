import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/features/auth/sign_in_panel.dart';
import 'package:dottoday/shared/account/decision_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A3 "You're signed out" (CR-160 policy §2, board `SignedOut`): shown
/// instead of any planner after a sign-out, with nothing of the account
/// that left (no tasks, email, settings or counts). "Sign in" opens the
/// usual sign-in choices here; "Use without an account" opens the device's
/// guest plan.
class SignedOutScreen extends ConsumerStatefulWidget {
  const SignedOutScreen({super.key});

  @override
  ConsumerState<SignedOutScreen> createState() => _SignedOutScreenState();
}

/// A leaf: the sign-in choices open or not, and the guest plan opening.
class _SignedOutScreenState extends ConsumerState<SignedOutScreen> {
  var _signingIn = false;
  var _busy = false;

  Future<void> _useWithout() async {
    setState(() => _busy = true);
    try {
      await ref.read(accountActionsProvider).useWithoutAccount();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_signingIn) {
      return SignInPanel(onBack: () => setState(() => _signingIn = false));
    }
    return DecisionFrame(
      centred: true,
      leading: const _EmptyDayArt(),
      title: l10n.signedOutTitle,
      body: l10n.signedOutBody,
      actions: [
        FilledButton(
          onPressed: _busy ? null : () => setState(() => _signingIn = true),
          child: Text(l10n.signedOutSignIn),
        ),
        OutlinedButton(
          onPressed: _busy ? null : () => unawaited(_useWithout()),
          child: Text(l10n.signedOutUseWithout),
        ),
        DecisionNote(l10n.signedOutUseWithoutHint, centred: true),
      ],
    );
  }
}

/// The board's empty ring with a lock: a day with nothing shown.
/// Decorative (board E-CR160, ED-223): screen readers skip it.
class _EmptyDayArt extends StatelessWidget {
  const _EmptyDayArt();

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ExcludeSemantics(
        child: Container(
          width: DotSize.wakeUpDayDot,
          height: DotSize.wakeUpDayDot,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.raised,
            border: Border.all(color: c.outline, width: DotSpace.s),
          ),
          child: DotIcon(DotGlyphs.lock, color: c.muted),
        ),
      ),
    );
  }
}
