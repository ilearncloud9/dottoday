import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/shared/account/account_decision.dart';
import 'package:dottoday/shared/account/account_dialog.dart';
import 'package:dottoday/shared/account/choice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// G1 (CR-160 policy §3, board `GuestWork`; elsewhere as B1, ED-495): an account signed in while
/// this device has tasks made without an account in the current guest
/// session. Keeping them separate is the default; "Bring them into your
/// account" needs "I made these N tasks myself" ticked. The tasks are
/// never listed here: they are reviewed without an account, before
/// signing in.
class GuestWorkScreen extends ConsumerStatefulWidget {
  const GuestWorkScreen({required this.gate, super.key});

  final GuestWorkGate gate;

  @override
  ConsumerState<GuestWorkScreen> createState() => _GuestWorkScreenState();
}

/// A leaf: the choice, the box and the request in flight.
class _GuestWorkScreenState extends ConsumerState<GuestWorkScreen> {
  var _choice = GuestChoice.keepSeparate;
  var _mine = false;
  var _busy = false;

  bool get _ready => !_busy && (_choice == GuestChoice.keepSeparate || _mine);

  void _pick(GuestChoice choice) => setState(() {
    _choice = choice;
    // The box is for this choice only: leaving it clears it.
    if (choice == GuestChoice.keepSeparate) _mine = false;
  });

  Future<void> _continue() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(accountActionsProvider)
          .chooseGuestWork(widget.gate.accountId, _choice);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final place = accountDecisionPlace(context);
    final look = place.look;
    final n = widget.gate.eligible;
    final bring = _choice == GuestChoice.bringIn;
    return AccountDecision(
      place: place,
      title: l10n.guestWorkTitle,
      body: l10n.guestWorkBody(n),
      content: [
        Semantics(
          label: l10n.guestWorkLegend,
          explicitChildNodes: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AccountDecisionSize.cardGap,
            children: [
              ChoiceCard(
                look: look,
                title: l10n.guestWorkKeep,
                selected: !bring,
                onTap: () => _pick(GuestChoice.keepSeparate),
                children: [ChoiceDetail(l10n.guestWorkKeepBody(n), look: look)],
              ),
              ChoiceCard(
                look: look,
                title: l10n.guestWorkBring,
                selected: bring,
                onTap: () => _pick(GuestChoice.bringIn),
                children: [
                  ChoiceDetail(
                    l10n.guestWorkBringBody(widget.gate.email),
                    look: look,
                  ),
                  _MineBox(
                    look: look,
                    label: l10n.guestWorkMine(n),
                    value: _mine,
                    onChanged: bring && !_busy
                        ? (v) => setState(() => _mine = v)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
        AccountDecision.words(
          place,
          Text(
            l10n.guestWorkNotSure,
            style: AccountDialogType.note(t.styles, look),
          ),
        ),
      ],
      buttons: [
        AccountButton.filled(
          look: look,
          label: l10n.accountContinue,
          onPressed: _ready ? () => unawaited(_continue()) : null,
          pad: accountDecisionPad(place, main: true),
        ),
      ],
    );
  }
}

/// "I made these N tasks myself": a 44 pt row, off until "Bring them in"
/// is chosen ([onChanged] null).
class _MineBox extends StatelessWidget {
  const _MineBox({
    required this.look,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final AccountDialogLook look;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final change = onChanged;
    return Padding(
      padding: const EdgeInsets.only(top: AccountDecisionSize.boxTop),
      child: MergeSemantics(
        child: InkWell(
          onTap: change == null ? null : () => change(!value),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AccountDecisionSize.boxRow,
            ),
            child: Row(
              spacing: AccountDecisionSize.boxGap,
              children: [
                // The box sits on the words' edge, as drawn; the row is
                // the 44 pt target.
                Checkbox(
                  value: value,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  onChanged: change == null ? null : (v) => change(v ?? false),
                ),
                Expanded(
                  child: Text(
                    label,
                    style: AccountDecisionType.row(
                      t.styles,
                      look,
                    ).copyWith(color: t.colors.secondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// G1b (board `GuestWorkLocked`), shown once: the guest's tasks were made
/// before the device's last change of owner, so none can move; they stay
/// on the device. Continue never shows it again.
class GuestNoticeScreen extends ConsumerStatefulWidget {
  const GuestNoticeScreen({required this.gate, super.key});

  final GuestNoticeGate gate;

  @override
  ConsumerState<GuestNoticeScreen> createState() => _GuestNoticeScreenState();
}

/// A leaf: the request in flight.
class _GuestNoticeScreenState extends ConsumerState<GuestNoticeScreen> {
  var _busy = false;

  Future<void> _continue() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(accountActionsProvider)
          .dismissGuestNotice(widget.gate.accountId);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final place = accountDecisionPlace(context);
    final look = place.look;
    final n = widget.gate.count;
    return AccountDecision(
      place: place,
      title: l10n.guestWorkTitle,
      body: l10n.guestNoticeBody(n),
      content: [
        ChoiceCardFrame(
          look: look,
          outline: t.colors.hairline,
          mark: DotIcon(
            DotGlyphs.checkCircle,
            color: t.colors.accentText,
            size: AccountDecisionSize.radio(look),
          ),
          title: l10n.guestNoticeCardTitle,
          children: [ChoiceDetail(l10n.guestNoticeCardBody(n), look: look)],
        ),
      ],
      buttons: [
        AccountButton.filled(
          look: look,
          label: l10n.accountContinue,
          onPressed: _busy ? null : () => unawaited(_continue()),
          pad: accountDecisionPad(place, main: true),
        ),
      ],
    );
  }
}
