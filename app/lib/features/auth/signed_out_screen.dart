import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/features/auth/sign_in_panel.dart';
import 'package:dottoday/features/auth/signed_out_art.dart';
import 'package:dottoday/shared/account/account_dialog.dart';
import 'package:dottoday/shared/account/account_page_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A3 "You're signed out" (CR-160 policy §2; ED-223, ED-493): shown
/// instead of any planner after a sign-out, with nothing of the account
/// that left (no tasks, email, settings or counts). "Sign in" opens the
/// usual sign-in choices here; "Use without an account" opens the device's
/// guest plan.
///
/// As the boards draw it: on phones (`SignedOut`, `AndroidA3`) the words
/// sit in the middle and the buttons at the foot; tablets (`TabletA3`,
/// `AndroidTabletA3`) centre one 440 column with the buttons under the
/// words; the Mac and web (`DesktopA3`) a 400 column with the buttons side
/// by side.
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
    if (_signingIn) {
      return SignInPanel(onBack: () => setState(() => _signingIn = false));
    }
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final look = accountDialogLook(context);
    final desktop = look == AccountDialogLook.desktop;
    final compact =
        WidthClass.of(MediaQuery.sizeOf(context).width) == WidthClass.compact;
    final head = [
      SignedOutArt(
        size: desktop ? SignedOutSize.artDesktop : SignedOutSize.art,
      ),
      Semantics(
        header: true,
        child: Text(
          l10n.signedOutTitle,
          style: SignedOutType.title(t.styles, look),
        ),
      ),
      Text(
        l10n.signedOutBody,
        style: SignedOutType.body(t.styles, t.colors, look),
      ),
    ];
    final buttons = [
      AccountButton.filled(
        look: look,
        label: l10n.signedOutSignIn,
        onPressed: _busy ? null : () => setState(() => _signingIn = true),
      ),
      AccountButton.outlined(
        look: look,
        label: l10n.signedOutUseWithout,
        onPressed: _busy ? null : () => unawaited(_useWithout()),
      ),
    ];
    final note = Text(
      l10n.signedOutUseWithoutHint,
      textAlign: desktop ? TextAlign.start : TextAlign.center,
      style: AccountDialogType.note(t.styles, look),
    );
    final Widget body;
    if (desktop) {
      body = AccountCentredColumn(
        width: SignedOutSize.desktopColumn,
        gap: SignedOutSize.gapDesktop,
        children: [
          ...head,
          Padding(
            padding: const EdgeInsets.only(top: SignedOutSize.actionsTop),
            child: Wrap(
              spacing: AccountDialogSize.buttonGap,
              runSpacing: AccountDialogSize.buttonGap,
              children: buttons,
            ),
          ),
          note,
        ],
      );
    } else {
      final actions = AccountButtonStack(
        look: look,
        children: [...buttons, note],
      );
      body = compact
          ? AccountPhoneFrame(
              padding: look == AccountDialogLook.android
                  ? SignedOutSize.padAndroid
                  : SignedOutSize.padIphone,
              gap: SignedOutSize.gap,
              centred: true,
              head: head,
              foot: actions,
            )
          : AccountCentredColumn(
              width: SignedOutSize.tabletColumn,
              gap: SignedOutSize.gap,
              children: [
                ...head,
                Padding(
                  padding: const EdgeInsets.only(top: SignedOutSize.actionsTop),
                  child: actions,
                ),
              ],
            );
    }
    return Material(
      color: t.colors.surface,
      child: SafeArea(child: body),
    );
  }
}
