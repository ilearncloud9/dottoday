import 'dart:async';

import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/proposals/proposal_view.dart';
import 'package:dottoday/shared/layout/side_panel_frame.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the open proposal where this width shows proposals (docs/10 §4,
/// docs/09 M10.2): a full-height bottom sheet (popover from the medium
/// width) on phones and tablets, the right-hand panel at the expanded
/// width — never a sheet there — or a centred panel there when the
/// request asks (Rebalance, E-R2-35). Any feature opens one through
/// `activeProposalProvider`; this sits once in the app shell.
class ProposalHost extends ConsumerStatefulWidget {
  const ProposalHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ProposalHost> createState() => _ProposalHostState();
}

class _ProposalHostState extends ConsumerState<ProposalHost> {
  /// Whether a sheet route is up, so a proposal opens at most one.
  bool _sheetUp = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(activeProposalProvider, (previous, next) {
      if (previous != null || next == null || _sheetUp) return;
      if (_expanded && next.centred) return unawaited(_showCentred());
      if (_expanded && !next.overSheet) return;
      unawaited(_showSheet());
    });
    final request = ref.watch(activeProposalProvider);
    if (request == null || !_expanded || request.overSheet || request.centred) {
      return widget.child;
    }
    return _Panel(child: widget.child);
  }

  bool get _expanded => AppLayout.classOf(context) == WidthClass.expanded;

  Future<void> _showSheet() async {
    _sheetUp = true;
    await showAppSheet<void>(
      context: context,
      fullHeight: true,
      builder: (sheet) =>
          ProposalView(onClosed: () => Navigator.of(sheet).maybePop()),
    );
    _sheetUp = false;
    // A swipe down or a tap outside is a Discard.
    if (mounted) ref.read(activeProposalProvider.notifier).close();
  }

  /// The centred panel over the screen (E-R2-35): as tall as the plan,
  /// Esc or a click outside discards.
  Future<void> _showCentred() async {
    _sheetUp = true;
    await showDialog<void>(
      context: context,
      builder: (dialog) => Dialog(
        constraints: const BoxConstraints(
          minWidth: DotSize.dialogMin,
          maxWidth: DotSize.rebalancePanel,
          maxHeight: appSheetMaxHeight,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(DotRadii.sheet)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ProposalView(onClosed: () => Navigator.of(dialog).maybePop()),
      ),
    );
    _sheetUp = false;
    if (mounted) ref.read(activeProposalProvider.notifier).close();
  }
}

/// [child] with the proposal as a right-hand panel; Esc discards.
class _Panel extends ConsumerWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DotTheme.of(context).colors;
    void close() => ref.read(activeProposalProvider.notifier).close();
    // Docked from 1160 when Today keeps its minimum, else floating over
    // it (ED-167, ED-168).
    return SidePanelFrame(
      panel: Material(
        color: c.raised,
        child: CallbackShortcuts(
          bindings: {const SingleActivator(LogicalKeyboardKey.escape): close},
          // Focus starts in the panel and Tab stays there.
          child: const FocusScope(
            autofocus: true,
            child: SafeArea(left: false, child: ProposalView()),
          ),
        ),
      ),
      child: child,
    );
  }
}
