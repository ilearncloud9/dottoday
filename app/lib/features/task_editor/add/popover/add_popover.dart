import 'dart:async';

import 'package:dottoday/core/editing/add_modes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/features/task_editor/add/add_submit.dart';
import 'package:dottoday/features/task_editor/add/create/add_mode_tabs.dart';
import 'package:dottoday/features/task_editor/add/popover/add_popover_task.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Add from medium width up (E-R2-36, ED-342): a popover under the
/// toolbar's + with Task · Brain dump · Routine as on the phones (ED-152);
/// each tab keeps its draft while another is shown and switching writes
/// nothing. Return adds, Esc closes and keeps nothing.
class AddPopover extends ConsumerStatefulWidget {
  const AddPopover({
    required this.request,
    this.mode = AddMode.task,
    super.key,
  });

  final AddRequest request;

  /// The tab it opens on.
  final AddMode mode;

  @override
  ConsumerState<AddPopover> createState() => _AddPopoverState();
}

class _AddPopoverState extends ConsumerState<AddPopover> {
  // Leaf view state (CLAUDE.md §4): the tab shown and those opened so far;
  // a tab is built on its first visit and kept after.
  late AddMode _mode = widget.mode;
  late final _seen = <AddMode>{AddMode.task, widget.mode};

  AddRequest get _request => widget.request;

  void _close() => unawaited(Navigator.of(context).maybePop());

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addFlowProvider(_request)).value;
    if (state == null) return const SizedBox.shrink();
    final modes = AddModesScope.maybeOf(context);
    final args = (
      day: state.draft.day,
      today: state.draft.today,
      done: _close,
      embedded: true,
    );
    Widget tab(AddMode m, Widget Function() build) => Offstage(
      offstage: _mode != m,
      child: TickerMode(
        enabled: _mode == m,
        child: _seen.contains(m) ? build() : const SizedBox.shrink(),
      ),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        DotSpace.l,
        DotSpace.l,
        DotSpace.l,
        DotSpace.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.m,
        children: [
          if (modes != null)
            AddModeTabs(
              mode: _mode,
              popover: true,
              touch: watchTouchContent(context, ref),
              onMode: (m) => setState(() {
                _mode = m;
                _seen.add(m);
              }),
            ),
          if (state.saveFailure case final failed?)
            SaveFailureBanner(
              failure: failed.failure,
              onRetry: () =>
                  unawaited(retryAdd(context, ref, _request, failed.retry)),
            ),
          // Each tab stays built, so its draft survives a switch (rule 5).
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              tab(
                AddMode.task,
                () => AddPopoverTask(
                  request: _request,
                  onAdd: () => unawaited(submitAdd(context, ref, _request)),
                  onInbox: () => unawaited(submitInbox(context, ref, _request)),
                  onAddMany: () =>
                      unawaited(submitMany(context, ref, _request)),
                ),
              ),
              if (modes != null) ...[
                tab(AddMode.brainDump, () => modes.brainDump(context, args)),
                tab(AddMode.routine, () => modes.routine(context, args)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
