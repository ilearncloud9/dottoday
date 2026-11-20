import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/timeline/editor/task_editor.dart';
import 'package:dottoday/features/timeline/task_d/task_d_sheet.dart';
import 'package:dottoday/features/timeline/widgets/task_sheet.dart';
import 'package:dottoday/shared/layout/side_panel_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final width = AppLayout.classOf(context);
    // Tablets edit in the panel from medium width too (ED-274).
    final shows =
        width == WidthClass.expanded ||
        (width == WidthClass.medium && tabletPanel(context, ref));
    if (id == null || !shows || proposing) return child;
    // Minimal's Now opens it in its Day column instead (ED-089, 6d).
    if (width == WidthClass.expanded && minimalNowColumn(context, ref)) {
      return child;
    }
    // Docked from 1160 when Today keeps its minimum, else floating over
    // it; a resize keeps the open editor as it is (ED-167, ED-168).
    return SidePanelFrame(
      panel: TaskEditorPanel(key: ValueKey(id), id: id),
      float: _floatOf(context),
      onDismiss: () => ref.read(editingTaskProvider.notifier).close(),
      child: child,
    );
  }

  /// The Mac and web card; the iPad's card over a dim; Android's modal
  /// side sheet (E-R2-4, ED-274).
  static SidePanelFloat _floatOf(BuildContext context) {
    if (!touchApp(context)) return SidePanelFloat.card;
    return Theme.of(context).platform == TargetPlatform.android
        ? SidePanelFloat.edgeSheet
        : SidePanelFloat.dimmedCard;
  }
}

/// Whether this is Minimal's Now at a width with the Day column, where a
/// task opens in the column, like the Day (ED-089, M19.6 part 6d).
bool minimalNowColumn(BuildContext context, WidgetRef ref) {
  if (!watchSimplified(ref, FeatureId.taskSheet)) return false;
  final router = GoRouter.maybeOf(context);
  return router?.routerDelegate.currentConfiguration.uri.path == AppRoutes.now;
}

/// Whether a tablet edits in the side panel: option D's editor in Full
/// (ED-273); Minimal keeps its own sheet below expanded (docs/14).
bool tabletPanel(BuildContext context, WidgetRef ref) =>
    touchApp(context) && !watchSimplified(ref, FeatureId.taskSheet);

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
    // Tablets: option D's editor, all of it, closing the panel (ED-273).
    if (!minimal && touchApp(context)) {
      return Material(
        color: t.colors.raised,
        child: CallbackShortcuts(
          bindings: {const SingleActivator(LogicalKeyboardKey.escape): close},
          child: FocusScope(
            child: SafeArea(
              left: false,
              right: false,
              child: Padding(
                padding: const EdgeInsets.only(top: DotSpace.s),
                child: TaskDBody(id: id, onClose: close),
              ),
            ),
          ),
        ),
      );
    }
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
