import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/task_sheet.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
import 'package:dottoday/shared/dot/thread_drag.dart';
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
              _draggable(
                o,
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
              ),
          ],
        ),
      ),
    );
  }
}

/// Held and dragged down onto the thread, an all-day item gets a time
/// (Structured's reverse of the all-day drop zone, ADR-0015). Pinned ones
/// stay put.
Widget _draggable(Occurrence o, Widget chip) {
  if (o.pinned) return chip;
  return HoldOrMouseDraggable<String>(
    data: o.id,
    feedback: LiftedDot(
      color: TaskColor.fromKey(o.colorKey),
      icon: TaskIcon.fromKey(o.iconKey),
      hint: TaskDragging.hint,
    ),
    childWhenDragging: Opacity(opacity: TaskAlpha.done, child: chip),
    callbacks: DragCallbacks(
      onDragStarted: () => TaskDragging.current.value = o.id,
      onDragUpdate: (_) {},
      onDragEnd: (_) => TaskDragging.hint.value = null,
      onFinished: () => TaskDragging.current.value = null,
    ),
    child: chip,
  );
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
