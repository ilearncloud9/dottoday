import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/features/auth/settings_choice_parts.dart';
import 'package:dottoday/shared/account/account_buttons.dart';
import 'package:dottoday/shared/account/account_dialog.dart';
import 'package:dottoday/shared/account/account_page_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// B1 (CR-160 criterion 7; ED-494): the account already had settings and
/// this device had different ones when it signed in. Shows only the rows
/// that differ; the account's stay unless the person picks the device's.
/// "Decide later" keeps the choice for Settings › Account.
///
/// As the boards draw it: on phones (`SettingsChoice`, `AndroidB1`) the
/// cards stack and the buttons sit at the foot; tablets (`TabletB1`,
/// `AndroidTabletB1`, 680) and the Mac and web (`DesktopB1`, 580) centre
/// one column with the cards side by side and the buttons at the end.
class SettingsChoiceScreen extends ConsumerStatefulWidget {
  const SettingsChoiceScreen({required this.gate, super.key});

  final SettingsChoiceGate gate;

  @override
  ConsumerState<SettingsChoiceScreen> createState() =>
      _SettingsChoiceScreenState();
}

/// A leaf: the choice, the request in flight and its error.
class _SettingsChoiceScreenState extends ConsumerState<SettingsChoiceScreen> {
  var _device = false;
  var _busy = false;
  String? _error;

  Future<void> _go(Future<void> Function(AccountActions a) op) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await op(ref.read(accountActionsProvider));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continue(AccountActions a) async {
    final account = widget.gate.account;
    if (!_device) return a.keepAccountSettings(account.id);
    final l10n = context.l10n;
    final result = await a.useDeviceSettings(account);
    if (result case Err(:final failure) when mounted) {
      setState(() => _error = failureMessage(l10n, failure));
    }
  }

  void _later() => unawaited(
    _go((a) => a.decideSettingsLater(widget.gate.account.id, later: true)),
  );

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final look = accountDialogLook(context);
    final phone =
        WidthClass.of(MediaQuery.sizeOf(context).width) == WidthClass.compact;
    final desktop = look == AccountDialogLook.desktop;
    final android = look == AccountDialogLook.android;
    final note = AccountDialogType.note(t.styles, look);
    // The words sit 8 further in than the cards on an Android phone.
    Widget words(Widget child) => phone && android
        ? Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SettingsChoiceSize.wordsInsetAndroid,
            ),
            child: child,
          )
        : child;
    final head = <Widget>[
      words(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SettingsChoiceSize.headGap,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.settingsChoiceTitle,
                style: SettingsChoiceType.title(t.styles, look),
              ),
            ),
            Text(
              l10n.settingsChoiceBody,
              style: SettingsChoiceType.body(t.styles, t.colors, look),
            ),
          ],
        ),
      ),
      Semantics(
        label: l10n.settingsChoiceLegend,
        explicitChildNodes: true,
        child: SettingsChoicePair(
          min: phone
              ? null
              : desktop
              ? SettingsChoiceSize.cardMinDesktop
              : SettingsChoiceSize.cardMinTablet,
          children: [
            for (final device in [false, true])
              SettingsChoiceCard(
                look: look,
                phone: phone,
                title: device
                    ? l10n.settingsChoiceDevice
                    : l10n.settingsChoiceAccount,
                profile: device ? widget.gate.device : widget.gate.account,
                fields: widget.gate.fields,
                selected: _device == device,
                onTap: () => setState(() => _device = device),
              ),
          ],
        ),
      ),
      words(Text(l10n.settingsChoiceOnlyDiffer, style: note)),
      if (_error case final error?) words(StatusLine(error)),
    ];
    final cont = _busy ? null : () => unawaited(_go(_continue));
    final later = _busy ? null : _later;
    final hint = l10n.settingsChoiceLaterHint;
    final Widget body;
    if (phone) {
      body = AccountPhoneFrame(
        padding: android
            ? SettingsChoiceSize.padAndroid
            : SettingsChoiceSize.padIphone,
        gap: android ? SettingsChoiceSize.gapCompact : SettingsChoiceSize.gap,
        head: head,
        foot: AccountButtonStack(
          look: look,
          children: [
            AccountButton.filled(
              look: look,
              label: l10n.accountContinue,
              onPressed: cont,
            ),
            AccountButton.text(
              look: look,
              label: l10n.settingsChoiceLater,
              onPressed: later,
            ),
            Text(hint, textAlign: TextAlign.center, style: note),
          ],
        ),
      );
    } else {
      body = AccountCentredColumn(
        width: desktop
            ? SettingsChoiceSize.desktopColumn
            : SettingsChoiceSize.tabletColumn,
        gap: desktop || android
            ? SettingsChoiceSize.gapCompact
            : SettingsChoiceSize.gap,
        children: [
          ...head,
          Padding(
            padding: const EdgeInsets.only(top: SettingsChoiceSize.actionsTop),
            child: _EndButtons(look: look, onLater: later, onContinue: cont),
          ),
          Text(hint, textAlign: TextAlign.end, style: note),
        ],
      );
    }
    return Material(
      color: t.colors.surface,
      child: SafeArea(child: body),
    );
  }
}

/// Decide later, then Continue, at the end (tablets, Mac/web).
class _EndButtons extends StatelessWidget {
  const _EndButtons({
    required this.look,
    required this.onLater,
    required this.onContinue,
  });

  final AccountDialogLook look;
  final VoidCallback? onLater;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (later, cont) = switch (look) {
      AccountDialogLook.iphone => (
        SettingsChoiceSize.laterPadIpad,
        SettingsChoiceSize.continuePadIpad,
      ),
      AccountDialogLook.android => (
        SettingsChoiceSize.laterPadAndroid,
        SettingsChoiceSize.continuePadAndroid,
      ),
      AccountDialogLook.desktop => (null, null),
    };
    final gap = look == AccountDialogLook.android
        ? AccountDialogSize.buttonGapAndroid
        : AccountDialogSize.buttonGap;
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: gap,
      runSpacing: gap,
      children: [
        AccountButton.text(
          look: look,
          label: l10n.settingsChoiceLater,
          onPressed: onLater,
          pad: later,
        ),
        AccountButton.filled(
          look: look,
          label: l10n.accountContinue,
          onPressed: onContinue,
          pad: cont,
        ),
      ],
    );
  }
}
