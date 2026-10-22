import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/features/settings/pages/account_dialogs.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Account (docs/09 M3f.7; wired in M6.1 / M6.5): the name,
/// then signed out — the sign-in choices, off until accounts arrive — or
/// signed in — Sign out and Delete account (typed confirm). The app works
/// fully without an account (02 F7).
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final name = ref.watch(currentProfileProvider).value?.displayName?.trim();
    final account = ref.watch(accountProvider).value ?? const LocalOnly();
    return SettingsPageFrame(
      title: l10n.settingsAccount,
      children: [
        SettingsGroup(
          caption: l10n.accountProfile,
          children: [
            SettingsRow(
              glyph: DotGlyphs.person,
              tint: t.colors.accentInk,
              title: l10n.accountName,
              value: name == null || name.isEmpty ? l10n.accountNameNone : name,
              onTap: () => unawaited(renameProfile(context, name ?? '')),
            ),
          ],
        ),
        switch (account) {
          LocalOnly() => const _SignedOut(),
          SignedIn(:final email) => _SignedIn(email: email),
        },
      ],
    );
  }
}

/// "Everything is on this device" and the three ways in.
class _SignedOut extends ConsumerWidget {
  const _SignedOut();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final service = ref.watch(accountServiceProvider);
    VoidCallback? go(SignInMethod m) => service.available
        ? () => unawaited(_run(context, service.signIn(m)))
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Text(
          l10n.accountSync.toUpperCase(),
          style: DotTheme.of(context).styles.caption,
        ),
        PageText(l10n.accountLocalBody),
        FilledButton(
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
        if (!service.available) PageText(l10n.accountComingSoon),
      ],
    );
  }
}

/// "Signed in as …", Sign out, Delete account.
class _SignedIn extends ConsumerWidget {
  const _SignedIn({required this.email});

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final service = ref.watch(accountServiceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Text(
          l10n.accountSync.toUpperCase(),
          style: DotTheme.of(context).styles.caption,
        ),
        Text(l10n.accountSignedInAs(email), style: t.styles.body),
        OutlinedButton(
          onPressed: () => unawaited(_run(context, service.signOut())),
          child: Text(l10n.accountSignOut),
        ),
        TextButton(
          onPressed: () => unawaited(_delete(context, service)),
          child: Text(l10n.accountDelete),
        ),
      ],
    );
  }

  Future<void> _delete(BuildContext context, AccountService service) async {
    if (!await confirmDeleteAccount(context) || !context.mounted) return;
    await _run(context, service.deleteAccount());
  }
}

/// Runs an account action; a failure is said in a snackbar.
Future<void> _run(
  BuildContext context,
  Future<Result<void, dynamic>> op,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  if (await op case Err(:final failure)) {
    messenger.showSnackBar(
      SnackBar(content: Text(failureMessage(l10n, failure))),
    );
  }
}
