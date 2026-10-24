import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/task_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All-day items of [date] as tinted chips above the pager (`Main`:
/// "Anniversary", "Stay hydrated"). Nothing when the day has none. A tap
/// opens the item to edit, imported all-day events included (docs/02 F5
/// "editable", R-02).
class AllDayChips extends ConsumerWidget {
  const AllDayChips({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items =
        ref.watch(timelineDataProvider(date)).value?.allDay ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    return Semantics(
      label: context.l10n.todayAllDay,
      container: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DotSpace.page),
        child: Row(
          spacing: DotSpace.s,
          children: [
            for (final o in items)
              _Chip(
                title: o.title,
                swatch: t.tasks[TaskColor.fromKey(o.colorKey)],
                icon: TaskIcon.fromKey(o.iconKey),
                onTap: () => openTask(
                  context,
                  o.id,
                  otherwise: () => showTaskSheet(context, o.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.title,
    required this.swatch,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final TaskSwatch swatch;
  final TaskIcon icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      button: true,
      child: Material(
        color: swatch.tint,
        shape: dotChipShape(context),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: DotTouch.min),
            padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: DotSpace.s,
              children: [
                if (icon.glyph case final glyph?)
                  DotIcon(glyph, color: swatch.ink, size: DotSize.rowIcon),
                Text(
                  title,
                  style: t.styles.rowTitle.copyWith(color: swatch.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
