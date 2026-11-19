import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/editor/editor_draft.dart';
import 'package:dottoday/features/timeline/editor/editor_leave.dart';
import 'package:dottoday/features/timeline/editor/editor_series.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/task_d/task_d_actions.dart';
import 'package:dottoday/features/timeline/task_d/task_d_cards.dart';
import 'package:dottoday/features/timeline/task_d/task_d_head.dart';
import 'package:dottoday/features/timeline/task_d/task_d_top.dart';
import 'package:dottoday/features/timeline/task_d/task_d_when.dart';
import 'package:dottoday/features/timeline/widgets/calendar_write_line.dart';
import 'package:dottoday/features/timeline/widgets/sheet_actions.dart';
import 'package:dottoday/features/timeline/widgets/travel_suggestion.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How much of the screen option D's sheet shows at its medium detent:
/// the header, the tiles and Need more time? (E-Phones F3).
const double _medium = 0.62;

/// Option D's task sheet on phones (G2-5, ED-086; M19.4 part 4a): at its
/// medium detent the tinted header, the tiles and Need more time?; pulled
/// up, the full editor (When, Repeat and Energy, steps and notes, More),
/// all saved as you go with Saved · Undo. [routeName] lets the task link
/// host close it when the address loses `?task=` (ED-097).
Future<void> showTaskDSheet(
  BuildContext context,
  String id, {
  required String routeName,
}) => showModalBottomSheet<void>(
  context: context,
  routeSettings: RouteSettings(name: routeName),
  // Above the iPhone's floating tab bar (M4.9).
  useRootNavigator: true,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    // A short window has no room for a half sheet: full height (ED-347).
    initialChildSize: AppLayout.isShort(context) ? 0.94 : _medium,
    minChildSize: _medium / 2,
    maxChildSize: 0.94,
    snap: true,
    snapSizes: const [_medium],
    builder: (context, scroll) => TaskDBody(id: id, scroll: scroll),
  ),
);

/// Task [id] as option D shows it, or "not here".
class TaskDBody extends ConsumerWidget {
  const TaskDBody({required this.id, this.scroll, super.key});

  final String id;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(taskViewProvider(id));
    // A reload keeps the previous task, so the sheet doesn't jump (M5.5).
    return switch (view) {
      AsyncValue(hasValue: true, value: final TaskView task) => _Form(
        task: task,
        scroll: scroll,
      ),
      AsyncData(value: null) || AsyncError(error: NotFoundFailure()) => Center(
        child: Text(context.l10n.sheetNotFound),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.task, required this.scroll});

  final TaskView task;
  final ScrollController? scroll;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> with EditorDraft<_Form> {
  @override
  TaskView get task => widget.task;

  @override
  VoidCallback? get onClose => null;

  @override
  void didUpdateWidget(covariant _Form old) {
    super.didUpdateWidget(old);
    adoptLatest();
    followStepLengths();
  }

  EditorLeave _leave(NavigatorState navigator) => EditorLeave(
    task: draft,
    onLeft: () => navigator.pop(),
    beforeLeave: leaving,
    scopedDelete: !task.repeats
        ? null
        : () => deleteScoped(context, task: task, target: draft),
  );

  /// Break it down: saved, the sheet closes, the proposal opens over the
  /// day (M10.4).
  Future<void> _breakDown() async {
    if (!await flushNow() || !mounted) return;
    leaving();
    Actions.maybeInvoke(context, BreakDownIntent(draft.id));
    Navigator.of(context).pop();
  }

  /// The header's circle: as the Done tile, with its sound and Undo.
  Future<void> _done() async {
    if (!await flushNow() || !mounted) return;
    await markDone(context, ref, task.occurrence);
  }

  @override
  Widget build(BuildContext context) {
    final leave = _leave(Navigator.of(context));
    return SaveFailureFrame(
      failure: failure,
      onRetry: save,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              controller: widget.scroll,
              padding: const EdgeInsets.only(bottom: DotSpace.xl),
              children: [
                TaskDTopBar(
                  task: task,
                  leave: leave,
                  onDone: save,
                  onBreakDown: () => unawaited(_breakDown()),
                ),
                TaskDHead(
                  task: task,
                  draft: draft,
                  title: title,
                  onTitle: (v) => change(
                    (o) =>
                        look.retitle(o, v, language: context.l10n.localeName),
                  ),
                  onLook: (c, i) =>
                      change((o) => look.pickIcon(look.pickColor(o, c), i)),
                  onDone: () => unawaited(_done()),
                  onSubmitted: save,
                ),
                _padded(_upper(context)),
                _padded(_lower(leave)),
              ],
            ),
          ),
          TaskDSavedBar(savedAtUtc: savedAtUtc, onUndo: undoEdits),
        ],
      ),
    );
  }

  /// What the medium detent shows: the tiles, Need more time?, a travel
  /// suggestion, and the pull-up hint.
  List<Widget> _upper(BuildContext context) {
    final t = DotTheme.of(context);
    return [
      TaskDActions(task: task, draft: draft, beforeWrite: flushNow),
      TravelSuggestionCard(task: task),
      Text(
        context.l10n.taskPullUp,
        textAlign: TextAlign.center,
        style: t.styles.rowMeta.copyWith(color: t.colors.muted),
      ),
    ];
  }

  /// Pulled up: When, the pills, steps and notes, More.
  List<Widget> _lower(EditorLeave leave) => [
    TaskDWhen(task: task, draft: draft, change: change),
    TaskDPills(
      task: task,
      draft: draft,
      change: change,
      onRepeat: draft.startUtc == null ? null : () => unawaited(repeat()),
    ),
    TaskDStepsNotes(task: task, draft: draft, change: change),
    TaskDMore(
      task: task,
      draft: draft,
      change: change,
      leave: leave,
      onTravel: draft.startUtc == null ? null : () => unawaited(travel()),
    ),
    CalendarWriteLine(linkId: draft.calendarLinkId),
  ];

  Widget _padded(List<Widget> children) => Padding(
    padding: const EdgeInsets.fromLTRB(
      DotSpace.page,
      DotSpace.m,
      DotSpace.page,
      0,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: children,
    ),
  );
}
