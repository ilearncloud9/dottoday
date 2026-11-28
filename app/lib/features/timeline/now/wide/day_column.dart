import 'dart:async';

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/day_column_prefs.dart';
import 'package:dottoday/features/timeline/editor/task_editor.dart';
import 'package:dottoday/features/timeline/review/review_panel.dart';
import 'package:dottoday/features/timeline/review/review_state.dart';
import 'package:dottoday/features/timeline/task_m/task_m_screen.dart';
import 'package:dottoday/features/timeline/widgets/day_page.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:dottoday/features/timeline/workspace/workspace_controls.dart';
import 'package:dottoday/shared/navigation/focus_return.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal's Day column beside Now on the Mac and the web (E-Minimal,
/// ED-068, ED-232: 290 wide): "Day", Day ▾ (the Day menu) and ✕ (Hide
/// the Day column, ⌥⌘I), then today's thread with its Earlier fold. A
/// task opens in the column like the Day (ED-089, M19.6 part 6d): the
/// minimal task screen, its More options the full editor; ✕ or Esc
/// brings the Day back, and the Now pane stays as it is. The Day review
/// opens here the same way (ED-099, E-Minimal), without Week in review.
class DayColumn extends ConsumerStatefulWidget {
  const DayColumn({required this.today, this.onClose, super.key});

  final DateTime today;

  /// The folded column's panel (ED-170): ✕ closes the panel instead of
  /// hiding the column.
  final VoidCallback? onClose;

  @override
  ConsumerState<DayColumn> createState() => _DayColumnState();
}

/// A leaf: only which task's More options is open, and what opened the
/// task or review, for focus to go back to (ED-248 A).
class _DayColumnState extends ConsumerState<DayColumn> {
  String? _more;
  final _back = FocusReturn();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final id = ref.watch(editingTaskProvider);
    ref
      ..listen(editingTaskProvider, (a, b) => _back.track(a != null, b != null))
      ..listen(
        reviewBesideProvider,
        (a, b) => _back.track(a != null, b != null),
      );
    void close() {
      setState(() => _more = null);
      ref.read(editingTaskProvider.notifier).close();
    }

    return Container(
      width: DotSize.dayColumn,
      decoration: BoxDecoration(
        color: t.colors.ground,
        border: BorderDirectional(start: BorderSide(color: t.colors.hairline)),
      ),
      child: id == null
          ? _dayOrReview(context)
          : CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape): close,
              },
              // A scope keeps Tab inside the task while it is open.
              child: FocusScope(
                autofocus: true,
                child: _more == id
                    ? TaskEditor(
                        key: ValueKey(id),
                        id: id,
                        onClose: close,
                        caption: false,
                        autofocus: true,
                      )
                    : TaskMScreen(
                        key: ValueKey(id),
                        id: id,
                        column: true,
                        onClose: close,
                        onMore: () => setState(() => _more = id),
                      ),
              ),
            ),
    );
  }

  /// The Day, or the review while one is open here (Esc or ✕ closes it).
  Widget _dayOrReview(BuildContext context) {
    final review = ref.watch(reviewBesideProvider);
    if (review == null) {
      return _Day(today: widget.today, onClose: widget.onClose);
    }
    void close() => ref.read(reviewBesideProvider.notifier).close();
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): close},
      child: FocusScope(
        autofocus: true,
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.l),
          child: ReviewPanel(
            key: ValueKey(review),
            day: review.day,
            onClose: close,
            column: true,
          ),
        ),
      ),
    );
  }
}

/// The column's Day: its header, the hint and today's thread.
class _Day extends ConsumerWidget {
  const _Day({required this.today, this.onClose});

  final DateTime today;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            DotSpace.l,
            DotSpace.m,
            DotSpace.s,
            0,
          ),
          child: Row(
            spacing: DotSpace.xs,
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(l10n.workspaceDay, style: t.styles.cardTitle),
                ),
              ),
              TodayMenu(
                date: today,
                today: today,
                button: ToolbarPill(label: l10n.workspaceDay, menu: true),
              ),
              IconButton(
                tooltip: onClose == null
                    ? l10n.dayColumnHide
                    : MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed:
                    onClose ??
                    () => unawaited(
                      ref
                          .read(dayColumnHiddenProvider.notifier)
                          .set(hidden: true),
                    ),
                icon: DotIcon(DotGlyphs.close, color: t.colors.ink),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            DotSpace.l,
            0,
            DotSpace.l,
            DotSpace.s,
          ),
          child: Text(l10n.dayColumnHint, style: t.styles.rowMeta),
        ),
        // ↑/↓ move between the rows, the web too, where arrows would
        // scroll (ED-248 A).
        Expanded(
          child: Shortcuts(
            shortcuts: const {
              SingleActivator(LogicalKeyboardKey.arrowUp):
                  DirectionalFocusIntent(TraversalDirection.up),
              SingleActivator(LogicalKeyboardKey.arrowDown):
                  DirectionalFocusIntent(TraversalDirection.down),
            },
            child: DayPage(
              date: today,
              today: today,
              page: true,
              runningLate: false,
            ),
          ),
        ),
      ],
    );
  }
}
