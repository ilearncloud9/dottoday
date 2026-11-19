import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "Subtasks · 1 of 3" and "+ Add".
class SubtasksHeader extends StatelessWidget {
  const SubtasksHeader({
    required this.done,
    required this.total,
    required this.onAdd,
    required this.onBreakDown,
    super.key,
  });

  final int done;
  final int total;
  final VoidCallback onAdd;
  final VoidCallback? onBreakDown;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              total == 0
                  ? l10n.sheetSubtasksNone
                  : l10n.sheetSubtasks(done, total),
              style: t.styles.rowTitle.copyWith(color: t.colors.muted),
            ),
          ),
        ),
        if (onBreakDown case final breakDown?)
          TextButton(
            onPressed: breakDown,
            child: Text(
              l10n.breakdownAction,
              style: t.styles.button.copyWith(color: t.colors.accentInk),
            ),
          ),
        TextButton(
          onPressed: onAdd,
          child: Text(
            l10n.sheetAddSubtask,
            style: t.styles.button.copyWith(color: t.colors.accentInk),
          ),
        ),
      ],
    );
  }
}
