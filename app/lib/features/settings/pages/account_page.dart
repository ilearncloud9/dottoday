import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/features/settings/pages/account_dialogs.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/shared/account/sign_in_parts.dart';
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
    // Not known yet: neither state, so a signed-in page never flashes
    // "Sign in" while the session loads (M6.1). Unreadable: on this device.
    final account = switch (ref.watch(accountProvider)) {
      AsyncValue(:final value?) => value,
      AsyncError() => const LocalOnly(),
      _ => null,
    };
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
          null => const SizedBox.shrink(),
        },
      ],
    );
  }
}

/// "Everything is on this device" and the three ways in; email asks for
/// the address, then "Check your mail" (same pieces as O5, M6.1). The
/// page turns to "Signed in" when the account does.
class _SignedOut extends ConsumerStatefulWidget {
  const _SignedOut();

  @override
  ConsumerState<_SignedOut> createState() => _SignedOutState();
}

enum _Step { choose, email, checkMail }

/// A leaf: which step, the address, the request in flight, the error.
class _SignedOutState extends ConsumerState<_SignedOut> {
  var _step = _Step.choose;
  var _busy = false;
  var _email = '';
  String? _error;
  VoidCallback? _retry;

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

  void _send(AccountService service, String email) {
    final trimmed = email.trim();
    if (checkEmail(trimmed) != null) {
      setState(() => _error = context.l10n.accountEmailInvalid);
      return;
    }
    _email = trimmed;
    unawaited(
      _run(() => service.sendMagicLink(trimmed), then: _Step.checkMail),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = ref.watch(accountServiceProvider);
    VoidCallback? go(SignInMethod m) => service.available && !_busy
        ? () => unawaited(_run(() => service.signIn(m)))
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
        ...switch (_step) {
          _Step.choose => [
            FilledButton(
              onPressed: go(SignInMethod.apple),
              child: Text(l10n.accountApple),
            ),
            OutlinedButton(
              onPressed: go(SignInMethod.google),
              child: Text(l10n.accountGoogle),
            ),
            OutlinedButton(
              onPressed: service.available
                  ? () => setState(() {
                      _step = _Step.email;
                      _error = null;
                    })
                  : null,
              child: Text(l10n.accountEmail),
            ),
          ],
          _Step.email => [
            EmailForm(
              initial: _email,
              busy: _busy,
              onSend: (e) => _send(service, e),
              onBack: () => setState(() {
                _step = _Step.choose;
                _error = null;
              }),
            ),
          ],
          _Step.checkMail => [
            CheckMail(
              email: _email,
              onResend: _busy ? null : () => _send(service, _email),
              onOtherEmail: () => setState(() => _step = _Step.email),
            ),
          ],
        },
        if (_error case final error?)
          AccountError(message: error, onRetry: _busy ? null : _retry),
        if (!service.available) PageText(l10n.accountComingSoon),
      ],
    );
  }
}

/// "Signed in as …", Sign out, Sign out everywhere (06 §2), Delete
/// account.
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
          onPressed: () =>
              unawaited(_run(context, service.signOut(everywhere: true))),
          child: Text(l10n.accountSignOutEverywhere),
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
