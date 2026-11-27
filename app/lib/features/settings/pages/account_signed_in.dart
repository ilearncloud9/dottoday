import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/owners/held_tasks.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/features/settings/pages/account_sync_parts.dart';
import 'package:dottoday/features/settings/pages/delete_account.dart';
import 'package:dottoday/features/settings/pages/sign_out_prompt.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Account signed in (E-CR160 `AccountChoose` and kin, ED-494):
/// Sync — "Signed in as …" and how sync stands ("Synced", "3 changes
/// waiting to sync") — then "Choose settings" while B1 waits (after
/// Decide later), Sign out, Sign out everywhere (06 §2) and Delete
/// account. Signing out asks first (A1 / A2) and leaves A3; deleting is
/// D1.
class AccountSignedIn extends ConsumerWidget {
  const AccountSignedIn({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final look = accountPageLook(context);
    final owner = ref.watch(currentProfileProvider).value?.id;
    final later = ref.watch(settingsChoiceLaterProvider).value ?? false;
    final status = ref.watch(syncStatusProvider).value;
    final pending = owner == null
        ? null
        : ref.watch(ownerPendingProvider(owner)).value;
    final held = (ref.watch(heldTasksProvider).value ?? 0) > 0;
    void signOut({bool everywhere = false}) {
      if (owner == null) return;
      unawaited(
        signOutWithCheck(
          context,
          email: email,
          status: status,
          pending: pending,
          everywhere: everywhere,
        ),
      );
    }

    final who = Text(
      l10n.accountSignedInAs(email),
      style: look == AccountDialogLook.desktop
          ? t.styles.inspectorValue
          : AccountSyncType.who(t.styles, look),
    );
    final line = AccountSyncLine(status: status, pending: pending, look: look);
    final choose = later && owner != null
        ? ChooseSettingsRow(
            look: look,
            onTap: () => unawaited(
              ref
                  .read(accountActionsProvider)
                  .decideSettingsLater(owner, later: false),
            ),
          )
        : null;
    void delete() {
      if (owner == null) return;
      unawaited(deleteAccountFlow(context, owner));
    }

    if (look == AccountDialogLook.desktop) {
      return _Form(
        who: who,
        line: line,
        held: held,
        choose: choose,
        onSignOut: signOut,
        onEverywhere: () => signOut(everywhere: true),
        onDelete: owner == null ? null : delete,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.l,
      children: [
        AccountSyncBlock(
          look: look,
          children: [
            who,
            line,
            // Held from an old build's switch of accounts (CR-160 blocker 8).
            if (held) Text(l10n.accountHeldTasks, style: t.styles.rowMeta),
          ],
        ),
        ?choose,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.s,
          children: [
            OutlinedButton(
              onPressed: signOut,
              child: Text(l10n.accountSignOut),
            ),
            TextButton(
              onPressed: () => signOut(everywhere: true),
              child: Text(l10n.accountSignOutEverywhere),
            ),
            TextButton(
              onPressed: owner == null ? null : delete,
              child: Text(l10n.accountDelete),
            ),
          ],
        ),
      ],
    );
  }
}

/// Signed in on a Mac/web form (ED-450, `DesktopAccountChoose`): Sync:
/// who and how sync stands, Choose settings while B1 waits, then Sign out
/// and Sign out everywhere side by side; Delete account… alone below a
/// rule.
class _Form extends StatelessWidget {
  const _Form({
    required this.who,
    required this.line,
    required this.held,
    required this.choose,
    required this.onSignOut,
    required this.onEverywhere,
    required this.onDelete,
  });

  final Widget who;
  final Widget line;
  final bool held;
  final Widget? choose;
  final VoidCallback onSignOut;
  final VoidCallback onEverywhere;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        FormLine(
          label: l10n.accountSync,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DotSpace.s,
            children: [
              who,
              line,
              if (held) FormHelp(l10n.accountHeldTasks),
              if (choose case final row?)
                Padding(
                  padding: const EdgeInsets.only(top: DotSpace.xs),
                  child: row,
                ),
              Wrap(
                spacing: DotSpace.s,
                runSpacing: DotSpace.xs,
                children: [
                  FormButton(label: l10n.accountSignOut, onPressed: onSignOut),
                  FormButton(
                    label: l10n.accountSignOutEverywhere,
                    onPressed: onEverywhere,
                  ),
                ],
              ),
            ],
          ),
        ),
        const FormBreak(),
        FormLine(
          child: FormButton(
            label: l10n.accountDeleteFormButton,
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }
}
