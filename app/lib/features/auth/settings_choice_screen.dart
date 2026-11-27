import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/features/auth/settings_choice_parts.dart';
import 'package:dottoday/shared/account/account_buttons.dart';
import 'package:dottoday/shared/account/account_decision.dart';
import 'package:dottoday/shared/account/account_dialog.dart';
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
    final place = accountDecisionPlace(context);
    final look = place.look;
    final note = AccountDialogType.note(t.styles, look);
    return AccountDecision(
      place: place,
      title: l10n.settingsChoiceTitle,
      body: l10n.settingsChoiceBody,
      content: [
        Semantics(
          label: l10n.settingsChoiceLegend,
          explicitChildNodes: true,
          child: SettingsChoicePair(
            min: place.phone
                ? null
                : look == AccountDialogLook.desktop
                ? AccountDecisionSize.cardMinDesktop
                : AccountDecisionSize.cardMinTablet,
            children: [
              for (final device in [false, true])
                SettingsChoiceCard(
                  look: look,
                  phone: place.phone,
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
        AccountDecision.words(
          place,
          Text(l10n.settingsChoiceOnlyDiffer, style: note),
        ),
        if (_error case final error?)
          AccountDecision.words(place, StatusLine(error)),
      ],
      buttons: [
        AccountButton.text(
          look: look,
          label: l10n.settingsChoiceLater,
          onPressed: _busy ? null : _later,
          pad: accountDecisionPad(place, main: false),
        ),
        AccountButton.filled(
          look: look,
          label: l10n.accountContinue,
          onPressed: _busy ? null : () => unawaited(_go(_continue)),
          pad: accountDecisionPad(place, main: true),
        ),
      ],
      hint: l10n.settingsChoiceLaterHint,
    );
  }
}
