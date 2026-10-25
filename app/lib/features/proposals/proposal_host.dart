import 'dart:async';

import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/proposals/proposal_view.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the open proposal where this width shows proposals (docs/10 §4,
/// docs/09 M10.2): a full-height bottom sheet (popover from the medium
/// width) on phones and tablets, the right-hand panel at the expanded
/// width — never a sheet there. Any feature opens one through
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
      if (_expanded && !next.overSheet) return;
      unawaited(_showSheet());
    });
    final request = ref.watch(activeProposalProvider);
    if (request == null || !_expanded || request.overSheet) {
      return widget.child;
    }
    return _Panel(child: widget.child);
  }

  bool get _expanded =>
      WidthClass.of(MediaQuery.sizeOf(context).width) == WidthClass.expanded;

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
}

/// [child] with the proposal as a right-hand panel; Esc discards.
class _Panel extends ConsumerWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DotTheme.of(context).colors;
    void close() => ref.read(activeProposalProvider.notifier).close();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: child),
        VerticalDivider(width: DotSpace.hairline, color: c.outline),
        SizedBox(
          width: DotSize.sidePanel,
          child: Material(
            color: c.raised,
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape): close,
              },
              // Focus starts in the panel and Tab stays there.
              child: const FocusScope(
                autofocus: true,
                child: SafeArea(left: false, child: ProposalView()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
