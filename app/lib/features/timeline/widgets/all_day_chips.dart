import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All-day items of [date] as tinted chips above the pager (`Main`:
/// "Anniversary", "Stay hydrated"). Nothing when the day has none.
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
              ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.title, required this.swatch, required this.icon});

  final String title;
  final TaskSwatch swatch;
  final TaskIcon icon;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: DotTouch.min),
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
      decoration: ShapeDecoration(
        color: swatch.tint,
        shape: dotChipShape(context),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.s,
        children: [
          if (icon.glyph case final glyph?)
            DotIcon(glyph, color: swatch.ink, size: DotSize.rowIcon),
          Text(title, style: t.styles.rowTitle.copyWith(color: swatch.ink)),
        ],
      ),
    );
  }
}
