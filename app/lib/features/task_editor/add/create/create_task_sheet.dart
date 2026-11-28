import 'dart:async';

import 'package:dottoday/core/editing/add_modes.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/task_editor/add/add_submit.dart';
import 'package:dottoday/features/task_editor/add/create/add_mode_tabs.dart';
import 'package:dottoday/features/task_editor/add/create/create_task_form.dart';
import 'package:dottoday/features/task_editor/add/create/create_task_more.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Create task, the phones' Add (ED-139 to ED-142, ED-152): Task · Brain
/// dump · Routine, each keeping its draft while another is shown. Only the
/// Task tab has Create task (and ⋯); Brain dump and Routine bring their own
/// actions (Plan it, a routine's tap), and nothing is written by switching.
/// iPhone: Cancel · ⋯ · Create task over a native segmented control.
/// Android: × and the mode's title, then Create, over M3 segmented buttons.
class CreateTaskSheet extends ConsumerStatefulWidget {
  const CreateTaskSheet({
    required this.request,
    this.mode = AddMode.task,
    super.key,
  });

  final AddRequest request;

  /// The tab it opens on (the tablets' + menus, E-R2-3).
  final AddMode mode;

  @override
  ConsumerState<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends ConsumerState<CreateTaskSheet> {
  // Leaf view state (CLAUDE.md §4): the tab shown, and those opened so
  // far; a tab is built on its first visit and kept after.
  late AddMode _mode = widget.mode;
  late final _seen = <AddMode>{AddMode.task, widget.mode};

  AddRequest get _request => widget.request;

  void _close() => unawaited(Navigator.of(context).maybePop());

  Future<void> _create() => submitAdd(context, ref, _request);

  Future<void> _addMany() => submitMany(context, ref, _request);

  Future<void> _retry(AddRetry retry) =>
      retryAdd(context, ref, _request, retry);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addFlowProvider(_request)).value;
    if (state == null) return const SizedBox.shrink();
    final modes = AddModesScope.maybeOf(context);
    final args = (
      day: state.draft.day,
      today: state.draft.today,
      done: _close,
      embedded: false,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          mode: _mode,
          request: _request,
          onCancel: _close,
          onCreate: () => unawaited(_create()),
        ),
        if (modes != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DotSpace.page,
              0,
              DotSpace.page,
              DotSpace.m,
            ),
            child: AddModeTabs(
              mode: _mode,
              onMode: (m) => setState(() {
                _mode = m;
                _seen.add(m);
              }),
            ),
          ),
        if (state.saveFailure case final failed?)
          SaveFailureBanner(
            failure: failed.failure,
            onRetry: () => unawaited(_retry(failed.retry)),
          ),
        Expanded(
          // Each tab stays built, so its draft survives a switch (rule 5).
          child: IndexedStack(
            index: _mode.index,
            children: [
              CreateTaskForm(
                request: _request,
                onSubmit: () => unawaited(_create()),
                onAddMany: () => unawaited(_addMany()),
              ),
              if (modes != null) ...[
                if (_seen.contains(AddMode.brainDump))
                  _Mode(child: modes.brainDump(context, args))
                else
                  const SizedBox.shrink(),
                if (_seen.contains(AddMode.routine))
                  modes.routine(context, args)
                else
                  const SizedBox.shrink(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Brain dump's body scrolls inside the sheet, with the page's margins.
class _Mode extends StatelessWidget {
  const _Mode({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: const EdgeInsets.all(DotSpace.page),
    child: child,
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.mode,
    required this.request,
    required this.onCancel,
    required this.onCreate,
  });

  final AddMode mode;
  final AddRequest request;
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final task = mode == AddMode.task;
    final android = DotIdiom.of(context) == DotIdiom.material;
    final create = FilledButton(
      onPressed: onCreate,
      child: Text(android ? l10n.createTaskShort : l10n.createTask),
    );
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.s,
        DotSpace.s,
        DotSpace.page,
        DotSpace.s,
      ),
      child: Row(
        spacing: DotSpace.s,
        children: [
          if (android) ...[
            IconButton(
              tooltip: l10n.editorCancel,
              onPressed: onCancel,
              icon: DotIcon(DotGlyphs.close, color: t.colors.ink),
            ),
            // Android titles the mode; the iPhone's tabs name it (ED-153).
            Expanded(
              child: Text(switch (mode) {
                AddMode.task => l10n.createNewTask,
                AddMode.brainDump => l10n.dumpTitle,
                AddMode.routine => l10n.routineDropTitle,
              }, style: t.styles.topBarTitle),
            ),
          ] else
            // Large text wraps the labels rather than clip them (§12.1).
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: onCancel,
                  child: Text(l10n.editorCancel),
                ),
              ),
            ),
          if (task) ...[
            CreateTaskMore(request: request),
            Flexible(child: create),
          ],
        ],
      ),
    );
  }
}
