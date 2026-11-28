import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/task_m/task_m_actions.dart';
import 'package:dottoday/features/timeline/task_m/task_m_head.dart';
import 'package:dottoday/features/timeline/task_m/task_m_when.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal's task screen (ED-089, ED-216; M19.6 part 6d): the header,
/// Starts and Duration, then Done, Tomorrow · Later, Need more time?
/// while it runs, More options and Delete task. The phones' sheet, or
/// the Mac and web Day column ([column]: "Task" and ✕ over it, Starts and
/// Duration as rows). [onClose] puts it away; [onMore] opens the full
/// editor.
class TaskMScreen extends ConsumerWidget {
  const TaskMScreen({
    required this.id,
    required this.onClose,
    required this.onMore,
    this.column = false,
    this.scrollController,
    super.key,
  });

  final String id;
  final VoidCallback onClose;
  final VoidCallback onMore;
  final bool column;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final view = ref.watch(taskViewProvider(id));
    final task = view.value;
    if (task == null) {
      if (view case AsyncData() || AsyncError(error: NotFoundFailure())) {
        return Padding(
          padding: const EdgeInsets.all(DotSpace.xl),
          child: Text(
            l10n.sheetNotFound,
            textAlign: TextAlign.center,
            style: t.styles.body.copyWith(color: t.colors.muted),
          ),
        );
      }
      return screenState([
            view,
          ], onRetry: () => ref.invalidate(taskViewProvider(id))) ??
          const SizedBox.shrink();
    }
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        column ? DotSpace.m : DotSpace.page,
        column ? 0 : DotSpace.xs,
        column ? DotSpace.m : DotSpace.page,
        DotSpace.xl,
      ),
      children: [
        if (column)
          Row(
            children: [
              Expanded(child: Text(l10n.taskMCaption, style: t.styles.caption)),
              IconButton(
                tooltip: l10n.editorClose,
                onPressed: onClose,
                icon: DotIcon(DotGlyphs.close, color: t.colors.text),
              ),
            ],
          ),
        TaskMHead(task: task, onClose: column ? null : onClose, land: column),
        const SizedBox(height: DotSpace.m),
        TaskMWhen(task: task.occurrence, column: column),
        const SizedBox(height: DotSpace.m),
        TaskMActions(
          task: task,
          onClose: onClose,
          onMore: onMore,
          column: column,
        ),
      ],
    );
  }
}
