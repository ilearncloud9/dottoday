import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/shared/account/choice_card.dart';
import 'package:dottoday/shared/account/decision_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// G1 (CR-160 policy §3, board `GuestWork`): an account signed in while
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
    final l10n = context.l10n;
    final n = widget.gate.eligible;
    final bring = _choice == GuestChoice.bringIn;
    return DecisionFrame(
      title: l10n.guestWorkTitle,
      body: l10n.guestWorkBody(n),
      content: [
        Semantics(
          label: l10n.guestWorkLegend,
          explicitChildNodes: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DotSpace.m,
            children: [
              ChoiceCard(
                title: l10n.guestWorkKeep,
                selected: !bring,
                onTap: () => _pick(GuestChoice.keepSeparate),
                children: [ChoiceDetail(l10n.guestWorkKeepBody(n))],
              ),
              ChoiceCard(
                title: l10n.guestWorkBring,
                selected: bring,
                onTap: () => _pick(GuestChoice.bringIn),
                children: [
                  ChoiceDetail(l10n.guestWorkBringBody(widget.gate.email)),
                  _MineBox(
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
        DecisionNote(l10n.guestWorkNotSure),
      ],
      actions: [
        FilledButton(
          onPressed: _ready ? () => unawaited(_continue()) : null,
          child: Text(l10n.accountContinue),
        ),
      ],
    );
  }
}

/// "I made these N tasks myself": a 44 pt row, off until "Bring them in"
/// is chosen ([onChanged] null).
class _MineBox extends StatelessWidget {
  const _MineBox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final change = onChanged;
    return MergeSemantics(
      child: InkWell(
        onTap: change == null ? null : () => change(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.min),
          child: Row(
            spacing: DotSpace.s,
            children: [
              Checkbox(
                value: value,
                onChanged: change == null ? null : (v) => change(v ?? false),
              ),
              Expanded(
                child: Text(
                  label,
                  style: t.styles.body.copyWith(color: t.colors.muted),
                ),
              ),
            ],
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
    final n = widget.gate.count;
    return DecisionFrame(
      title: l10n.guestWorkTitle,
      body: l10n.guestNoticeBody(n),
      content: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: t.colors.raised,
            borderRadius: BorderRadius.circular(DotRadii.cardLarge),
            border: Border.all(
              color: t.colors.outline,
              width: DotSize.smallDotOutline,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.l),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DotSpace.m,
              children: [
                DotIcon(
                  DotGlyphs.checkCircle,
                  color: t.colors.accentInk,
                  size: DotSize.pickerDot,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: DotSpace.xs,
                    children: [
                      Text(
                        l10n.guestNoticeCardTitle,
                        style: t.styles.choiceTitle,
                      ),
                      ChoiceDetail(l10n.guestNoticeCardBody(n)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      actions: [
        FilledButton(
          onPressed: _busy ? null : () => unawaited(_continue()),
          child: Text(l10n.accountContinue),
        ),
      ],
    );
  }
}
