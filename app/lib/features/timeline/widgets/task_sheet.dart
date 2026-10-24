import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/editor/task_editor.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/note_links.dart';
import 'package:dottoday/features/timeline/widgets/sheet_actions.dart';
import 'package:dottoday/features/timeline/widgets/sheet_details.dart';
import 'package:dottoday/features/timeline/widgets/sheet_meta.dart';
import 'package:dottoday/features/timeline/widgets/sheet_subtasks.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the task sheet for [id] (docs/10 §5.2 T4, `A-ios-task-sheet`).
void showTaskSheet(BuildContext context, String id) => unawaited(
  showModalBottomSheet<void>(
    context: context,
    // Above the iPhone's floating tab bar (M4.9: it covered Save).
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      maxChildSize: 0.94,
      builder: (context, scroll) =>
          TaskSheetBody(id: id, scrollController: scroll),
    ),
  ),
);

/// Opens the phone editor for [id] (docs/10 §5.2 E1: "on phones the task
/// sheet's Edit opens the same fields as a full sheet").
void showTaskEditor(BuildContext context, String id) => unawaited(
  showModalBottomSheet<void>(
    context: context,
    // Above the iPhone's floating tab bar (M4.9: it covered Save).
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        FractionallySizedBox(heightFactor: 0.94, child: TaskEditor(id: id)),
  ),
);

/// What the sheet (and the `/task/:id` page) shows for task [id]: the
/// identity row, action tiles, subtasks and details, or "not here".
class TaskSheetBody extends ConsumerWidget {
  const TaskSheetBody({required this.id, this.scrollController, super.key});

  final String id;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(taskViewProvider(id));
    // A reload keeps the previous task, so the sheet doesn't jump (M5.5).
    return switch (view) {
      AsyncValue(hasValue: true, value: final TaskView task) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(
          DotSpace.page,
          0,
          DotSpace.page,
          DotSpace.xl,
        ),
        children: [
          _Identity(task: task),
          const SizedBox(height: DotSpace.l),
          SheetActions(task: task, onEdit: () => showTaskEditor(context, id)),
          const SizedBox(height: DotSpace.l),
          SheetSubtasks(task: task),
          NoteLinks(notes: task.occurrence.notes),
          const SizedBox(height: DotSpace.m),
          SheetDetails(task: task, onEdit: () => showTaskEditor(context, id)),
        ],
      ),
      AsyncData(value: null) ||
      AsyncError(error: NotFoundFailure()) => _NotFound(),
      // Loading or failed (docs/09 M3f.9b); an id that isn't here stays
      // "not here" above.
      _ =>
        screenState([
              view,
            ], onRetry: () => ref.invalidate(taskViewProvider(id))) ??
            const LoadingThread(),
    };
  }
}

class _Identity extends ConsumerWidget {
  const _Identity({required this.task});

  final TaskView task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final o = task.occurrence;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final state = dotStateOf(o, now);
    final live = state == DotState.live;
    final progress = live
        ? now.difference(o.startUtc!).inSeconds /
              o.endUtc!.difference(o.startUtc!).inSeconds
        : 0.0;
    final left = live
        ? (o.endUtc!.difference(now).inSeconds / 60).ceil()
        : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.l,
      children: [
        TaskDot(
          color: TaskColor.fromKey(o.colorKey),
          icon: TaskIcon.fromKey(o.iconKey),
          state: state,
          progress: progress,
          size: DotSize.liveDot + DotSpace.l,
          label: taskDotLabel(
            l10n,
            title: o.title,
            state: state,
            minutesLeft: left,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DotSpace.xxs,
            children: [
              Semantics(
                header: true,
                child: Text(o.title, style: t.styles.topBarTitle),
              ),
              SheetMeta(task: task, minutesLeft: left),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(DotSpace.xl),
      child: Text(
        context.l10n.sheetNotFound,
        textAlign: TextAlign.center,
        style: t.styles.body.copyWith(color: t.colors.muted),
      ),
    );
  }
}
