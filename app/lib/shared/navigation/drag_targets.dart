import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
import 'package:dottoday/shared/dot/thread_drag.dart';
import 'package:dottoday/shared/haptics/app_haptics.dart';
import 'package:flutter/material.dart';

/// The add button as a drag source (Structured's drag-the-+, ADR-0015):
/// held and dragged onto the day thread, it starts a new task at that time.
/// A tap still adds as before.
class AddDraggable extends StatelessWidget {
  const AddDraggable({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return HoldOrMouseDraggable<String>(
      data: newTaskDragId,
      feedback: const _NewDot(),
      childWhenDragging: Opacity(opacity: TaskAlpha.done, child: child),
      callbacks: DragCallbacks(
        onDragStarted: () => TaskDragging.current.value = newTaskDragId,
        onDragUpdate: (_) {},
        onDragEnd: (_) => TaskDragging.hint.value = null,
        onFinished: () => TaskDragging.current.value = null,
      ),
      child: child,
    );
  }
}

/// A new task following the finger: the accent "+" dot and its time.
class _NewDot extends StatelessWidget {
  const _NewDot();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.s,
      children: [
        Container(
          width: DotSize.threadDot,
          height: DotSize.threadDot,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.accent,
            boxShadow: DotElevation.floating,
          ),
          child: Center(
            child: DotIcon(DotGlyphs.add, color: c.onAccent, bold: true),
          ),
        ),
        ValueListenableBuilder<String?>(
          valueListenable: TaskDragging.hint,
          builder: (context, text, _) => text == null
              ? const SizedBox.shrink()
              : Material(
                  color: c.text,
                  shape: const StadiumBorder(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DotSpace.m,
                      vertical: DotSpace.xs,
                    ),
                    child: Text(
                      text,
                      style: t.styles.button.copyWith(color: c.raised),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// A nav destination a dragged task can be let go on (the Inbox tab:
/// back to the Inbox, ADR-0015). It grows a little while one hovers.
class TaskDropTab extends StatelessWidget {
  const TaskDropTab({required this.onDropTask, required this.child, super.key});

  final ValueChanged<String> onDropTask;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final motion = DotTheme.of(context).motion;
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => d.data != newTaskDragId,
      onAcceptWithDetails: (d) {
        AppHaptics.play(context, HapticTick.medium);
        onDropTask(d.data);
      },
      builder: (context, candidates, _) => AnimatedScale(
        scale: candidates.isEmpty ? 1 : 1.3,
        duration: motion.fast,
        curve: motion.curve,
        child: child,
      ),
    );
  }
}

/// While a task is dragged, a Trash target above the add button (where
/// Structured puts its bin, ADR-0015). Dropping moves the task to Trash
/// with Undo; it is never deleted outright (R-08, R-11).
class TrashDropZone extends StatelessWidget {
  const TrashDropZone({required this.onTrash, required this.label, super.key});

  final ValueChanged<String> onTrash;

  /// "Move to Trash".
  final String label;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: TaskDragging.current,
      builder: (context, dragging, _) {
        if (dragging == null || dragging == newTaskDragId) {
          return const SizedBox.shrink();
        }
        return DragTarget<String>(
          onWillAcceptWithDetails: (d) => d.data != newTaskDragId,
          onAcceptWithDetails: (d) {
            AppHaptics.play(context, HapticTick.medium);
            onTrash(d.data);
          },
          builder: (context, candidates, _) =>
              _Bin(label: label, hovered: candidates.isNotEmpty),
        );
      },
    );
  }
}

class _Bin extends StatelessWidget {
  const _Bin({required this.label, required this.hovered});

  final String label;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    // The text colour, never red: putting a task away is not a failure
    // (11 §D no shame).
    final fill = hovered ? c.text : c.raised;
    final ink = hovered ? c.raised : c.text;
    return Semantics(
      label: label,
      child: AnimatedContainer(
        duration: t.motion.fast,
        curve: t.motion.curve,
        width: DotSize.threadDot + (hovered ? DotSpace.s : 0),
        height: DotSize.threadDot + (hovered ? DotSpace.s : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(color: c.outline, width: DotSpace.hairline),
          boxShadow: DotElevation.floating,
        ),
        child: Center(child: DotIcon(DotGlyphs.trash, color: ink, bold: true)),
      ),
    );
  }
}
