import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/owners/held_tasks.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/features/settings/pages/account_dialogs.dart';
import 'package:dottoday/features/settings/pages/delete_account.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/pages/sign_out_prompt.dart';
import 'package:dottoday/shared/account/sign_in_parts.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
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
    final form = settingsFormFits(context);
    return SettingsPageFrame(
      title: l10n.settingsAccount,
      page: SettingsPage.account,
      form: true,
      children: [
        if (form)
          FormLine(
            label: l10n.accountName,
            child: _NameField(name: name ?? ''),
          )
        else
          SettingsGroup(
            caption: l10n.accountProfile,
            children: [
              SettingsRow(
                glyph: DotGlyphs.person,
                tint: t.colors.accentInk,
                title: l10n.accountName,
                value: name == null || name.isEmpty
                    ? l10n.accountNameNone
                    : name,
                onTap: () => unawaited(renameProfile(context, name ?? '')),
              ),
            ],
          ),
        if (form && account != null) const FormBreak(),
        switch (account) {
          LocalOnly() when form => FormLine(
            label: l10n.accountSync,
            child: const _SignedOut(),
          ),
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
        if (!settingsFormAt(context))
          Text(l10n.accountSync, style: DotTheme.of(context).styles.caption),
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
/// account; and "Choose settings" while B1 waits ("Decide later", CR-160).
/// Signing out asks first (A1 / A2) and leaves A3; deleting is D1.
class _SignedIn extends ConsumerWidget {
  const _SignedIn({required this.email});

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final owner = ref.watch(currentProfileProvider).value?.id;
    final later = ref.watch(settingsChoiceLaterProvider).value ?? false;
    final status = ref.watch(syncStatusProvider).value;
    final pending = owner == null
        ? null
        : ref.watch(ownerPendingProvider(owner)).value;
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

    if (settingsFormAt(context)) {
      return _signedInForm(context, ref, signOut, owner: owner, later: later);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Text(l10n.accountSync, style: DotTheme.of(context).styles.caption),
        Text(l10n.accountSignedInAs(email), style: t.styles.body),
        // Held from an old build's switch of accounts (CR-160 blocker 8).
        if ((ref.watch(heldTasksProvider).value ?? 0) > 0)
          Text(l10n.accountHeldTasks, style: t.styles.rowMeta),
        if (later && owner != null)
          SettingsGroup(
            caption: '',
            children: [
              SettingsRow(
                glyph: DotGlyphs.settings,
                tint: t.colors.accentInk,
                title: l10n.accountChooseSettings,
                subtitle: l10n.accountChooseSettingsBody,
                onTap: () => unawaited(
                  ref
                      .read(accountActionsProvider)
                      .decideSettingsLater(owner, later: false),
                ),
              ),
            ],
          ),
        OutlinedButton(onPressed: signOut, child: Text(l10n.accountSignOut)),
        TextButton(
          onPressed: () => signOut(everywhere: true),
          child: Text(l10n.accountSignOutEverywhere),
        ),
        TextButton(
          onPressed: owner == null
              ? null
              : () => unawaited(deleteAccountFlow(context, owner)),
          child: Text(l10n.accountDelete),
        ),
      ],
    );
  }
}

extension on _SignedIn {
  /// Signed in on a Mac/web form (ED-450): Sync: who, then Sign out and
  /// Sign out everywhere side by side; Delete account… alone below a rule.
  Widget _signedInForm(
    BuildContext context,
    WidgetRef ref,
    void Function({bool everywhere}) signOut, {
    required String? owner,
    required bool later,
  }) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        FormLine(
          label: l10n.accountSync,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DotSpace.s,
            children: [
              Text(
                l10n.accountSignedInAs(email),
                style: t.styles.inspectorValue,
              ),
              if ((ref.watch(heldTasksProvider).value ?? 0) > 0)
                FormHelp(l10n.accountHeldTasks),
              if (later && owner != null)
                FormButton(
                  label: l10n.settingsFormOpen(l10n.accountChooseSettings),
                  onPressed: () => unawaited(
                    ref
                        .read(accountActionsProvider)
                        .decideSettingsLater(owner, later: false),
                  ),
                ),
              Wrap(
                spacing: DotSpace.s,
                runSpacing: DotSpace.xs,
                children: [
                  FormButton(label: l10n.accountSignOut, onPressed: signOut),
                  FormButton(
                    label: l10n.accountSignOutEverywhere,
                    onPressed: () => signOut(everywhere: true),
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
            onPressed: owner == null
                ? null
                : () => unawaited(deleteAccountFlow(context, owner)),
          ),
        ),
      ],
    );
  }
}

/// The name, edited in place on a Mac/web form (ED-450): saved on Return
/// or when the field loses focus.
class _NameField extends StatefulWidget {
  const _NameField({required this.name});

  final String name;

  @override
  State<_NameField> createState() => _NameFieldState();
}

/// A leaf: the field's text and focus.
class _NameFieldState extends State<_NameField> {
  late final _controller = TextEditingController(text: widget.name);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(_NameField old) {
    super.didUpdateWidget(old);
    // A name saved elsewhere shows here unless it is being typed.
    if (old.name != widget.name && !_focus.hasFocus) {
      _controller.text = widget.name;
    }
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (!_focus.hasFocus) _save();
  }

  void _save() =>
      unawaited(saveProfileName(context, widget.name, _controller.text));

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: DotSize.formNameField),
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        contextMenuBuilder: systemTextMenu,
        style: t.styles.inspectorValue,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          isDense: true,
          hintText: context.l10n.accountNameNone,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _save(),
      ),
    );
  }
}
