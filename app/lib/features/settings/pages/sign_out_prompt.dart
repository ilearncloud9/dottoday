import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/domain/sync/sign_out_check.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/shared/account/account_buttons.dart';
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

/// A1 ([pending] null) or A2 with [pending] changes not yet synced, laid
/// out for the width (boards `SignOutPlain`, `Main`, `AndroidA2`,
/// `DesktopA2`): compact follows the platform's dialog idiom, wider windows
/// put the buttons at the end with Esc's note.
class SignOutPrompt extends StatelessWidget {
  const SignOutPrompt({required this.email, required this.pending, super.key});

  final String email;
  final int? pending;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final wide =
        WidthClass.of(MediaQuery.sizeOf(context).width) != WidthClass.compact;
    final android = !wide && DotIdiom.of(context) == DotIdiom.material;
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
    final actions = n == null
        ? _plainActions(context, wide: wide)
        : _pendingActions(context, wide: wide, android: android);
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: android ? DotSpace.xl : DotSpace.page,
        vertical: DotSpace.xl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          wide ? DotRadii.cardLarge : DotRadii.sheet,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DotSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.l,
          children: [
            if (n != null && !wide)
              android
                  ? DotIcon(DotGlyphs.cloudSync, color: t.colors.accentInk)
                  : const TonalBadge(DotGlyphs.cloudSync),
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: android ? TextAlign.center : TextAlign.start,
                style: t.styles.promptTitle,
              ),
            ),
            Text(body, style: t.styles.body.copyWith(color: t.colors.muted)),
            ...actions,
          ],
        ),
      ),
    );
  }

  List<Widget> _plainActions(BuildContext context, {required bool wide}) {
    final l10n = context.l10n;
    final cancel = OutlinedButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(l10n.editorCancel),
    );
    final signOut = FilledButton(
      onPressed: () => Navigator.of(context).pop(SignOutAnswer.signOut),
      child: Text(l10n.accountSignOut),
    );
    if (wide) {
      return [
        _EndRow(children: [cancel, signOut]),
      ];
    }
    return [
      Row(
        spacing: DotSpace.s,
        children: [
          Expanded(child: cancel),
          Expanded(child: signOut),
        ],
      ),
    ];
  }

  List<Widget> _pendingActions(
    BuildContext context, {
    required bool wide,
    required bool android,
  }) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    void pop(SignOutAnswer a) => Navigator.of(context).pop(a);
    final stayLabel = Text(l10n.accountStaySignedIn);
    final keepLabel = Text(l10n.accountSignOutKeep);
    if (wide) {
      return [
        _EndRow(
          children: [
            OutlinedButton(
              onPressed: () => pop(SignOutAnswer.signOut),
              child: keepLabel,
            ),
            FilledButton(
              onPressed: () => pop(SignOutAnswer.stay),
              child: stayLabel,
            ),
          ],
        ),
        Text(
          l10n.accountSignOutEscHint,
          textAlign: TextAlign.end,
          style: t.styles.rowMeta,
        ),
      ];
    }
    if (android) {
      return [
        FilledButton(
          style: tonalPillStyle(context),
          onPressed: () => pop(SignOutAnswer.stay),
          child: stayLabel,
        ),
        TextButton(
          onPressed: () => pop(SignOutAnswer.signOut),
          child: keepLabel,
        ),
      ];
    }
    return [
      FilledButton(onPressed: () => pop(SignOutAnswer.stay), child: stayLabel),
      Text(
        l10n.accountStaySignedInHint,
        textAlign: TextAlign.center,
        style: t.styles.stripWeekday,
      ),
      OutlinedButton(
        onPressed: () => pop(SignOutAnswer.signOut),
        child: keepLabel,
      ),
    ];
  }
}

/// Buttons at the end of a wide dialog, wrapping when they don't fit.
class _EndRow extends StatelessWidget {
  const _EndRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.end,
    spacing: DotSpace.s,
    runSpacing: DotSpace.s,
    children: children,
  );
}
