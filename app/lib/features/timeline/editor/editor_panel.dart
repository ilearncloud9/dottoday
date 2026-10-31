import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/timeline/editor/task_editor.dart';
import 'package:dottoday/features/timeline/widgets/task_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [child] with the task editor as a right-hand panel while a task is
/// open (docs/10 §4 "editing in a right-hand TaskEditor panel, no
/// sheets", `A-mac-editor`, M3e.5). Expanded width only, and not while a
/// proposal holds the panel (M10.2); the panel is
/// keyed by the task, so switching tasks saves the one before.
class EditorPanelFrame extends ConsumerWidget {
  const EditorPanelFrame({required this.child, super.key});

  final Widget child;

  /// `A-mac-editor`: 640 of 2000 px at 1280.
  static const double width = DotSize.sidePanel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(editingTaskProvider);
    // A proposal takes the panel while it is open (M10.2); the task comes
    // back after Accept or Discard.
    final proposing = ref.watch(activeProposalProvider) != null;
    // The window's class, as `openTask` decides: a task opened here
    // always shows.
    final expanded =
        WidthClass.of(MediaQuery.sizeOf(context).width) == WidthClass.expanded;
    if (id == null || !expanded || proposing) return child;
    final c = DotTheme.of(context).colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: child),
        VerticalDivider(width: DotSpace.hairline, color: c.outline),
        SizedBox(
          width: width,
          child: TaskEditorPanel(key: ValueKey(id), id: id),
        ),
      ],
    );
  }
}

/// The panel: "EDIT TASK", esc and ×, then the editor (title, colour and
/// icon, When / Start, duration, Repeat, Alerts, subtasks, notes, Delete ·
/// Move to inbox · Save). Esc closes, ⌘S saves, ⌘D marks done; Tab stays
/// inside the panel while it is open.
///
/// Minimal (docs/14 §3 "Mac/web spread … panel"): the panel first shows
/// the minimal sheet (Done · Tomorrow · Later · Delete); More opens the
/// editor in it.
class TaskEditorPanel extends ConsumerStatefulWidget {
  const TaskEditorPanel({required this.id, super.key});

  final String id;

  @override
  ConsumerState<TaskEditorPanel> createState() => _TaskEditorPanelState();
}

/// A leaf: only whether minimal's More was tapped.
class _TaskEditorPanelState extends ConsumerState<TaskEditorPanel> {
  bool _more = false;

  @override
  Widget build(BuildContext context) {
    final id = widget.id;
    final minimal = watchSimplified(ref, FeatureId.taskSheet) && !_more;
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    void close() => ref.read(editingTaskProvider.notifier).close();
    return Material(
      color: t.colors.raised,
      child: CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): close},
        // A scope keeps Tab inside the panel (the focus trap).
        child: FocusScope(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  DotSpace.page,
                  DotSpace.l,
                  DotSpace.s,
                  0,
                ),
                child: Row(
                  spacing: DotSpace.s,
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          l10n.editorCaption.toUpperCase(),
                          style: t.styles.caption,
                        ),
                      ),
                    ),
                    ExcludeSemantics(
                      child: Text(l10n.editorEscKey, style: t.styles.rowMeta),
                    ),
                    IconButton(
                      tooltip: l10n.editorClose,
                      onPressed: close,
                      icon: DotIcon(DotGlyphs.close, color: t.colors.text),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: minimal
                    ? TaskSheetBody(
                        id: id,
                        onMore: () => setState(() => _more = true),
                        onClose: close,
                      )
                    : TaskEditor(
                        id: id,
                        onClose: close,
                        caption: false,
                        autofocus: true,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
