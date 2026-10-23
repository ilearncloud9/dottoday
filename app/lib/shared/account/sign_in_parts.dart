import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:flutter/material.dart';

// The sign-in pieces of O5 Account (docs/09 M4.5 / M4.7) and Settings ›
// Account (M6.1): UI with callbacks, no state of their own beyond a field.

/// Apple / Google / email; off (with why) until accounts are available.
class SignInChoices extends StatelessWidget {
  const SignInChoices({
    required this.enabled,
    required this.available,
    required this.onPick,
    super.key,
  });

  final bool enabled;
  final bool available;
  final ValueChanged<SignInMethod> onPick;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    VoidCallback? pick(SignInMethod m) => enabled ? () => onPick(m) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        OutlinedButton(
          onPressed: pick(SignInMethod.apple),
          child: Text(l10n.accountApple),
        ),
        OutlinedButton(
          onPressed: pick(SignInMethod.google),
          child: Text(l10n.accountGoogle),
        ),
        OutlinedButton(
          onPressed: pick(SignInMethod.email),
          child: Text(l10n.accountEmail),
        ),
        if (!available)
          Text(
            l10n.accountComingSoon,
            style: t.styles.body.copyWith(color: t.colors.muted),
          ),
      ],
    );
  }
}

/// The address and "Send me a link".
class EmailForm extends StatefulWidget {
  const EmailForm({
    required this.initial,
    required this.busy,
    required this.onSend,
    required this.onBack,
    super.key,
  });

  final String initial;
  final bool busy;
  final ValueChanged<String> onSend;
  final VoidCallback onBack;

  @override
  State<EmailForm> createState() => _EmailFormState();
}

/// A leaf: owns the field's controller.
class _EmailFormState extends State<EmailForm> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        TextField(
          controller: _text,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          autocorrect: false,
          textInputAction: TextInputAction.send,
          decoration: InputDecoration(labelText: l10n.accountEmailLabel),
          onSubmitted: widget.onSend,
        ),
        OutlinedButton(
          onPressed: widget.busy ? null : () => widget.onSend(_text.text),
          child: Text(l10n.accountSendLink),
        ),
        TextButton(
          onPressed: widget.onBack,
          child: Text(l10n.accountOtherWays),
        ),
      ],
    );
  }
}

/// "Check your mail": where it went, send again, another address.
class CheckMail extends StatelessWidget {
  const CheckMail({
    required this.email,
    required this.onResend,
    required this.onOtherEmail,
    super.key,
  });

  final String email;
  final VoidCallback? onResend;
  final VoidCallback onOtherEmail;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(l10n.accountCheckMailTitle, style: t.styles.cardTitle),
        ),
        Text(l10n.accountCheckMailBody(email), style: t.styles.body),
        OutlinedButton(onPressed: onResend, child: Text(l10n.accountResend)),
        TextButton(
          onPressed: onOtherEmail,
          child: Text(l10n.accountOtherEmail),
        ),
      ],
    );
  }
}

/// "Couldn't sign in", why, and Try again.
class AccountError extends StatelessWidget {
  const AccountError({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.xs,
        children: [
          Text(l10n.accountErrorTitle, style: t.styles.rowTitle),
          Text(message, style: t.styles.body),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text(l10n.stateRetry)),
        ],
      ),
    );
  }
}

/// "Bringing your tasks to this device… 120 of 300"; [onDone] once it is
/// finished, or if there was nothing to bring.
class Restoring extends StatefulWidget {
  const Restoring({required this.stream, required this.onDone, super.key});

  final Stream<RestoreProgress?> stream;
  final VoidCallback onDone;

  @override
  State<Restoring> createState() => _RestoringState();
}

/// A leaf: the subscription and the latest count.
class _RestoringState extends State<Restoring> {
  StreamSubscription<RestoreProgress?>? _sub;
  RestoreProgress? _now;
  var _done = false;

  @override
  void initState() {
    super.initState();
    _sub = widget.stream.listen(_update);
  }

  void _update(RestoreProgress? p) {
    if (_done || !mounted) return;
    if (p == null || p.finished) {
      _done = true;
      widget.onDone();
      return;
    }
    setState(() => _now = p);
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final p = _now;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.s,
        children: [
          Text(l10n.accountRestoring, style: t.styles.body),
          // A bar that fills, never an endless spinner (§5.4).
          LinearProgressIndicator(
            value: p == null || p.total == 0 ? 0 : p.done / p.total,
          ),
          if (p != null)
            Text(
              l10n.accountRestoreCount(p.done, p.total),
              style: t.styles.rowMeta,
            ),
        ],
      ),
    );
  }
}
