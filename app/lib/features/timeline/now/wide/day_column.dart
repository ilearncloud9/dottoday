import 'dart:async';

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/day_column_prefs.dart';
import 'package:dottoday/features/timeline/editor/task_editor.dart';
import 'package:dottoday/features/timeline/task_m/task_m_screen.dart';
import 'package:dottoday/features/timeline/widgets/day_page.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:dottoday/features/timeline/workspace/workspace_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal's Day column beside Now on the Mac and the web (E-Minimal,
/// ED-068, ED-232: 290 wide): "Day", Day ▾ (the Day menu) and ✕ (Hide
/// the Day column, ⌥⌘I), then today's thread with its Earlier fold. A
/// task opens in the column like the Day (ED-089, M19.6 part 6d): the
/// minimal task screen, its More options the full editor; ✕ or Esc
/// brings the Day back, and the Now pane stays as it is.
class DayColumn extends ConsumerStatefulWidget {
  const DayColumn({required this.today, this.onClose, super.key});

  final DateTime today;

  /// The folded column's panel (ED-170): ✕ closes the panel instead of
  /// hiding the column.
  final VoidCallback? onClose;

  @override
  ConsumerState<DayColumn> createState() => _DayColumnState();
}

/// A leaf: only which task's More options is open.
class _DayColumnState extends ConsumerState<DayColumn> {
  String? _more;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final id = ref.watch(editingTaskProvider);
    void close() {
      setState(() => _more = null);
      ref.read(editingTaskProvider.notifier).close();
    }

    return Container(
      width: DotSize.dayColumn,
      decoration: BoxDecoration(
        color: t.colors.surface,
        border: BorderDirectional(start: BorderSide(color: t.colors.hairline)),
      ),
      child: id == null
          ? _Day(today: widget.today, onClose: widget.onClose)
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
                icon: DotIcon(DotGlyphs.close, color: t.colors.text),
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
        Expanded(
          child: DayPage(
            date: today,
            today: today,
            page: true,
            runningLate: false,
          ),
        ),
      ],
    );
  }
}
