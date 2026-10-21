import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// What a thread does with drags (docs/10 §6: long-press = drag to another
/// time or day, drops onto free gaps; R-05). The feature turns positions
/// into times; the thread only reports them.
@immutable
final class ThreadDrag {
  const ThreadDrag({
    required this.onDrop,
    required this.hintFor,
    this.onResize,
    this.shiftByDefault,
  });

  /// Task [id] dropped on [gap], [fraction] (0–1) down it; [shift] = the
  /// later tasks follow (the chip, inverted while Alt is held).
  final void Function(String id, ThreadGap gap, double fraction, bool shift)
  onDrop;

  /// The floating label while task [id] hovers [gap] at [fraction]
  /// ("11:30"), or null off any gap.
  final String? Function(String id, ThreadGap? gap, double fraction) hintFor;

  /// Task [id]'s end moved by [steps] grip steps (+ longer, − shorter).
  final void Function(String id, int steps)? onResize;

  /// Where the "Shift later tasks" chip starts each drag (Settings ›
  /// Shift later tasks); null hides the chip (R-04).
  final bool? shiftByDefault;
}

/// Long-press to lift a task row (250 ms, 03 §3.2): a lifted chip follows
/// the finger with the snapped drop time; the list scrolls near its edges.
class DraggableTaskRow extends StatefulWidget {
  const DraggableTaskRow({
    required this.task,
    required this.drag,
    required this.hint,
    required this.child,
    this.onLift,
    this.onSettle,
    super.key,
  });

  final ThreadTask task;
  final ThreadDrag drag;

  /// The task was picked up / let go (shows and hides the shift chip).
  final VoidCallback? onLift;
  final VoidCallback? onSettle;

  /// The live drop-time label (feedback is built in the overlay, outside
  /// this subtree, so it is passed rather than inherited).
  final ValueNotifier<String?> hint;
  final Widget child;

  @override
  State<DraggableTaskRow> createState() => _DraggableTaskRowState();
}

class _DraggableTaskRowState extends State<DraggableTaskRow> {
  EdgeDraggingAutoScroller? _scroller;

  @override
  Widget build(BuildContext context) {
    if (!widget.task.movable) return widget.child;
    return LongPressDraggable<String>(
      data: widget.task.id,
      delay: DotTouch.liftDelay,
      hapticFeedbackOnStart: true,
      feedback: _Lifted(task: widget.task, hint: widget.hint),
      childWhenDragging: Opacity(opacity: TaskAlpha.done, child: widget.child),
      onDragStarted: () {
        widget.onLift?.call();
        final scrollable = Scrollable.maybeOf(context);
        _scroller = scrollable == null
            ? null
            : EdgeDraggingAutoScroller(scrollable, velocityScalar: 20);
      },
      onDragUpdate: (d) => _scroller?.startAutoScrollIfNecessary(
        Rect.fromCenter(
          center: d.globalPosition,
          width: 1,
          height: DotTouch.android,
        ),
      ),
      onDragEnd: (_) {
        _scroller?.stopAutoScroll();
        widget.hint.value = null;
        widget.onSettle?.call();
      },
      child: widget.child,
    );
  }
}

/// The lifted chip: dot colour, title and the live drop time.
class _Lifted extends StatelessWidget {
  const _Lifted({required this.task, required this.hint});

  final ThreadTask task;
  final ValueNotifier<String?> hint;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Material(
      color: t.colors.raised,
      elevation: 0,
      shape: StadiumBorder(
        side: BorderSide(
          color: task.color.color,
          width: DotSize.smallDotOutline,
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(boxShadow: DotElevation.floating),
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.l,
          vertical: DotSpace.s,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: DotSpace.s,
          children: [
            Container(
              width: DotSize.weekDot * 2,
              height: DotSize.weekDot * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.color.color,
              ),
            ),
            Text(task.title, style: t.styles.rowTitle),
            ValueListenableBuilder<String?>(
              valueListenable: hint,
              builder: (context, text, _) => text == null
                  ? const SizedBox.shrink()
                  : Text(
                      text,
                      style: t.styles.button.copyWith(
                        color: t.colors.accentInk,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A free gap that accepts a dragged task; it lights up while one hovers
/// and reports where in the gap it was let go.
class GapDropTarget extends StatelessWidget {
  const GapDropTarget({
    required this.gap,
    required this.drag,
    required this.hint,
    required this.shift,
    required this.child,
    super.key,
  });

  final ThreadGap gap;
  final ThreadDrag drag;
  final ValueNotifier<String?> hint;

  /// The chip's state for this drag.
  final ValueListenable<bool> shift;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    double fractionOf(Offset global) {
      final box = context.findRenderObject()! as RenderBox;
      final local = box.globalToLocal(global);
      return (local.dy / box.size.height).clamp(0.0, 1.0);
    }

    return DragTarget<String>(
      onMove: (d) {
        final text = drag.hintFor(d.data, gap, fractionOf(d.offset));
        if (hint.value != text) {
          hint.value = text;
          unawaited(HapticFeedback.selectionClick());
        }
      },
      onLeave: (_) => hint.value = null,
      onAcceptWithDetails: (d) {
        hint.value = null;
        unawaited(HapticFeedback.mediumImpact());
        // Desktop: holding Alt inverts the chip (docs/03 §3.2).
        final invert = HardwareKeyboard.instance.isAltPressed;
        drag.onDrop(d.data, gap, fractionOf(d.offset), shift.value != invert);
      },
      builder: (context, candidates, _) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DotRadii.card),
          color: candidates.isEmpty ? null : c.accentTint,
        ),
        child: child,
      ),
    );
  }
}

/// The grip at the end of a task's segment: drag down for longer, up for
/// shorter, one [DotTouch.resizeStep] per snap step (R-05).
class ResizeGrip extends StatefulWidget {
  const ResizeGrip({required this.onSteps, required this.label, super.key});

  final ValueChanged<int> onSteps;

  /// Screen-reader name ("Change length").
  final String label;

  @override
  State<ResizeGrip> createState() => _ResizeGripState();
}

class _ResizeGripState extends State<ResizeGrip> {
  double _dy = 0;
  int _steps = 0;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    // Screen readers adjust the length with increase / decrease (R-12).
    return Semantics(
      label: widget.label,
      onIncrease: () => widget.onSteps(1),
      onDecrease: () => widget.onSteps(-1),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Count from touch-down, so the slop isn't lost from the length.
          dragStartBehavior: DragStartBehavior.down,
          onVerticalDragStart: (_) => setState(() => _dy = 0),
          onVerticalDragUpdate: (d) {
            _dy += d.delta.dy;
            final steps = (_dy / DotTouch.resizeStep).round();
            if (steps != _steps) {
              unawaited(HapticFeedback.selectionClick());
              setState(() => _steps = steps);
            }
          },
          onVerticalDragEnd: (_) {
            if (_steps != 0) widget.onSteps(_steps);
            setState(() => _steps = 0);
          },
          child: SizedBox(
            width: DotTouch.min,
            height: DotTouch.min / 2,
            child: Center(
              child: Container(
                width: DotSize.weekDot * 2,
                height: DotSize.freeLine * 2,
                decoration: BoxDecoration(
                  color: _steps == 0 ? c.hairline : c.accent,
                  borderRadius: BorderRadius.circular(DotRadii.pill),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
