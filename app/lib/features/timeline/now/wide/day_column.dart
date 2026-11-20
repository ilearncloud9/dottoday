import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/day_column_prefs.dart';
import 'package:dottoday/features/timeline/widgets/day_page.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:dottoday/features/timeline/workspace/workspace_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal's Day column beside Now on the Mac and the web (E-Minimal,
/// ED-068, ED-232: 290 wide): "Day", Day ▾ (the Day menu) and ✕ (Hide
/// the Day column, ⌥⌘I), then today's thread with its Earlier fold. A
/// task opens as it does on Today until 6d opens it in this column
/// (ED-089).
class DayColumn extends ConsumerWidget {
  const DayColumn({required this.today, super.key});

  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Container(
      width: DotSize.dayColumn,
      decoration: BoxDecoration(
        color: t.colors.surface,
        border: BorderDirectional(start: BorderSide(color: t.colors.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              DotSpace.l,
              DotSpace.m,
              DotSpace.s,
              DotSpace.s,
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
                  tooltip: l10n.dayColumnHide,
                  onPressed: () => unawaited(
                    ref
                        .read(dayColumnHiddenProvider.notifier)
                        .set(hidden: true),
                  ),
                  icon: DotIcon(DotGlyphs.close, color: t.colors.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: DayPage(date: today, today: today, page: true),
          ),
        ],
      ),
    );
  }
}
