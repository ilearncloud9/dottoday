import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/domain/sync/sign_out_check.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/shared/account/account_buttons.dart';
import 'package:dottoday/shared/account/account_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The ONE switch for A2's promise (CR-160 policy §2): while false, A2
/// says only "They stay on this device under this account."; true adds
/// "Until then, no one else who uses Dottoday on this device can see
/// them." It may be flipped only after every surface in
/// `docs/cr-160-verification.md` I1–I8 is fixed and tested.
const a2IsolationVerified = false;

/// What the sign-out prompt came back with; null (Esc, a tap outside)
/// starts nothing.
enum SignOutAnswer { signOut, stay }

/// "Sign out" on Settings › Account (CR-160 policy §2), with sync's
/// [status] as the page shows it: A1 when the server confirmed everything ([everythingSynced]), else A2 with the owner's
/// [pending] changes (null: not read yet, so not confirmed either). Signing out hides the account and shows A3; "Stay
/// signed in" syncs now; Esc starts nothing.
Future<void> signOutWithCheck(
  BuildContext context, {
  required String email,
  required SyncStatus? status,
  required int? pending,
  bool everywhere = false,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final answer = await showDialog<SignOutAnswer>(
    context: context,
    builder: (_) => SignOutPrompt(
      email: email,
      pending: pending != null && everythingSynced(status, pending)
          ? null
          : pending ?? 0,
    ),
  );
  final actions = container.read(accountActionsProvider);
  switch (answer) {
    case SignOutAnswer.signOut:
      final result = await actions.signOut(everywhere: everywhere);
      if (result case Err(:final failure)) {
        messenger.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
      }
    case SignOutAnswer.stay:
      if (await actions.syncNow() case Err(:final failure)) {
        messenger.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
      }
    case null:
      return;
  }
}

/// A1 ([pending] null) or A2 with [pending] changes not yet synced, as the
/// E-CR160 boards draw them (owner, M20.12 part 1: as drawn): iPhone and
/// iPad (`SignOutPlain`, `Main`, `A2Unconfirmed`, `Tablet…`), Android
/// phones and tablets (`AndroidA1`, `AndroidA2`, `AndroidTablet…`), and
/// the Mac and web (`DesktopA1`, `DesktopA2`). Dottoday's own dialog, not
/// the system alert: it holds A2's badge, the hint under Stay signed in and
/// the Esc note (a recorded departure from native first, ED-492).
class SignOutPrompt extends StatelessWidget {
  const SignOutPrompt({required this.email, required this.pending, super.key});

  final String email;
  final int? pending;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final look = accountDialogLook(context);
    final n = pending;
    final title = n == null
        ? l10n.accountSignOutTitle
        : l10n.accountSignOutPendingTitle(n);
    final body = n == null
        ? l10n.accountSignOutSyncedBody
        : l10n.accountTwoSentences(
            l10n.accountSignOutPendingBody(n, email),
            a2IsolationVerified
                ? l10n.accountSignOutIsolation
                : l10n.accountSignOutKeptHere,
          );
    final android = look == AccountDialogLook.android;
    return AccountDialog(
      look: look,
      plain: n == null,
      children: [
        if (n != null && look == AccountDialogLook.iphone)
          const TonalBadge(DotGlyphs.cloudSync),
        if (n != null && android)
          Center(
            child: DotIcon(
              DotGlyphs.cloudSync,
              color: t.colors.accentInk,
              size: AccountDialogSize.androidIcon,
            ),
          ),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: android && n != null
                ? TextAlign.center
                : TextAlign.start,
            style: AccountDialogType.title(t.styles, look),
          ),
        ),
        Text(body, style: AccountDialogType.body(t.styles, t.colors, look)),
        Padding(
          padding: EdgeInsets.only(top: _actionsTop(look)),
          child: n == null
              ? _PlainActions(look: look)
              : _PendingActions(look: look),
        ),
      ],
    );
  }
}

double _actionsTop(AccountDialogLook look) => switch (look) {
  AccountDialogLook.iphone => AccountDialogSize.actionsTopIphone,
  AccountDialogLook.android => AccountDialogSize.actionsTopAndroid,
  AccountDialogLook.desktop => AccountDialogSize.actionsTopDesktop,
};

/// A1's Cancel and Sign out: two pills side by side on iPhone, text
/// buttons at the end on Android, pills at the end on the Mac and web with
/// focus starting on Cancel (ED-174 ring).
class _PlainActions extends StatelessWidget {
  const _PlainActions({required this.look});

  final AccountDialogLook look;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void pop([SignOutAnswer? a]) => Navigator.of(context).pop(a);
    switch (look) {
      case AccountDialogLook.iphone:
        return Row(
          spacing: AccountDialogSize.buttonGap,
          children: [
            Expanded(
              child: AccountButton.outlined(
                look: look,
                label: l10n.editorCancel,
                onPressed: pop,
              ),
            ),
            Expanded(
              child: AccountButton.filled(
                look: look,
                label: l10n.accountSignOut,
                onPressed: () => pop(SignOutAnswer.signOut),
              ),
            ),
          ],
        );
      case AccountDialogLook.android:
        return _EndRow(
          gap: AccountDialogSize.buttonGapAndroid,
          children: [
            AccountButton.text(
              look: look,
              label: l10n.editorCancel,
              onPressed: pop,
            ),
            AccountButton.text(
              look: look,
              label: l10n.accountSignOut,
              onPressed: () => pop(SignOutAnswer.signOut),
            ),
          ],
        );
      case AccountDialogLook.desktop:
        return _EndRow(
          children: [
            AccountButton.outlined(
              look: look,
              label: l10n.editorCancel,
              onPressed: pop,
              autofocus: true,
            ),
            AccountButton.filled(
              look: look,
              label: l10n.accountSignOut,
              onPressed: () => pop(SignOutAnswer.signOut),
            ),
          ],
        );
    }
  }
}

/// A2's Stay signed in and "Sign out and keep them here": stacked with
/// the hint between on phones and tablets (Android: tonal Stay, text
/// Keep); at the end on the Mac and web, Stay rightmost, then Esc's note.
class _PendingActions extends StatelessWidget {
  const _PendingActions({required this.look});

  final AccountDialogLook look;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    void pop(SignOutAnswer a) => Navigator.of(context).pop(a);
    final note = AccountDialogType.note(t.styles, look);
    if (look == AccountDialogLook.desktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AccountDialogSize.gapDesktop,
        children: [
          _EndRow(
            children: [
              AccountButton.outlined(
                look: look,
                label: l10n.accountSignOutKeep,
                onPressed: () => pop(SignOutAnswer.signOut),
              ),
              AccountButton.filled(
                look: look,
                label: l10n.accountStaySignedIn,
                onPressed: () => pop(SignOutAnswer.stay),
              ),
            ],
          ),
          Text(
            l10n.accountSignOutEscHint,
            textAlign: TextAlign.end,
            style: note,
          ),
        ],
      );
    }
    final android = look == AccountDialogLook.android;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: android
          ? AccountDialogSize.buttonGapAndroid
          : AccountDialogSize.buttonGap,
      children: [
        android
            ? AccountButton.tonal(
                look: look,
                label: l10n.accountStaySignedIn,
                onPressed: () => pop(SignOutAnswer.stay),
              )
            : AccountButton.filled(
                look: look,
                label: l10n.accountStaySignedIn,
                onPressed: () => pop(SignOutAnswer.stay),
              ),
        Text(
          l10n.accountStaySignedInHint,
          textAlign: TextAlign.center,
          style: note,
        ),
        android
            ? AccountButton.text(
                look: look,
                label: l10n.accountSignOutKeep,
                onPressed: () => pop(SignOutAnswer.signOut),
              )
            : AccountButton.outlined(
                look: look,
                label: l10n.accountSignOutKeep,
                onPressed: () => pop(SignOutAnswer.signOut),
              ),
      ],
    );
  }
}

/// Buttons at the end, wrapping onto a new line when they don't fit
/// (200 % text): labels never truncate.
class _EndRow extends StatelessWidget {
  const _EndRow({
    required this.children,
    this.gap = AccountDialogSize.buttonGap,
  });

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.end,
    spacing: gap,
    runSpacing: gap,
    children: children,
  );
}
