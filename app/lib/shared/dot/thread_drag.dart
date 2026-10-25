import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'resize_grip.dart';

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
    this.calendarByDefault,
  });

  /// Task [id] dropped on [gap], [fraction] (0–1) down it; [shift] says
  /// what the chips said at the drop.
  final void Function(
    String id,
    ThreadGap gap,
    double fraction,
    DropShift shift,
  )
  onDrop;

  /// The floating label while task [id] hovers [gap] at [fraction]
  /// ("11:30"), or null off any gap.
  final String? Function(String id, ThreadGap? gap, double fraction) hintFor;

  /// Task [id]'s end moved by [steps] grip steps (+ longer, − shorter).
  final void Function(String id, int steps)? onResize;

  /// Where the "Shift later tasks" chip starts each drag (Settings ›
  /// Shift later tasks); null hides the chip (R-04).
  final bool? shiftByDefault;

  /// Where the "Calendar events too" chip starts each drag (Settings ›
  /// Calendars › Move calendar events too); null hides it, for a day
  /// without calendar events a shift could carry (docs/09 M7.6).
  final bool? calendarByDefault;
}

/// Long-press to lift a task row (250 ms, 03 §3.2; a mouse lifts at once): a lifted chip follows
/// the finger with the snapped drop time; the list scrolls near its edges.
class DraggableTaskRow extends StatefulWidget {
  const DraggableTaskRow({
    required this.task,
    required this.drag,
    required this.hint,
    required this.child,
    this.onLift,
    this.onSettle,
    this.onHold,
    super.key,
  });

  final ThreadTask task;
  final ThreadDrag drag;

  /// The task was picked up / let go (shows and hides the shift chip).
  final VoidCallback? onLift;
  final VoidCallback? onSettle;

  /// Long-pressed and let go without moving: select it (docs/03 §3.2
  /// "long-press then tap others").
  final VoidCallback? onHold;

  /// The live drop-time label (feedback is built in the overlay, outside
  /// this subtree, so it is passed rather than inherited).
  final ValueNotifier<String?> hint;
  final Widget child;

  @override
  State<DraggableTaskRow> createState() => _DraggableTaskRowState();
}

class _DraggableTaskRowState extends State<DraggableTaskRow> {
  EdgeDraggingAutoScroller? _scroller;

  /// How far the finger has travelled since the lift.
  double _travel = 0;

  @override
  Widget build(BuildContext context) {
    if (!widget.task.movable) return widget.child;
    return HoldOrMouseDraggable<String>(
      data: widget.task.id,
      feedback: _Lifted(task: widget.task, hint: widget.hint),
      childWhenDragging: Opacity(opacity: TaskAlpha.done, child: widget.child),
      callbacks: DragCallbacks(
        onDragStarted: () {
          _travel = 0;
          widget.onLift?.call();
          final scrollable = Scrollable.maybeOf(context);
          _scroller = scrollable == null
              ? null
              : EdgeDraggingAutoScroller(scrollable, velocityScalar: 20);
        },
        onDragUpdate: (d) {
          _travel += d.delta.distance;
          _scroller?.startAutoScrollIfNecessary(
            Rect.fromCenter(
              center: d.globalPosition,
              width: 1,
              height: DotTouch.android,
            ),
          );
        },
        onDragEnd: (d) {
          _scroller?.stopAutoScroll();
          widget.hint.value = null;
          widget.onSettle?.call();
          if (!d.wasAccepted && _travel < kTouchSlop) widget.onHold?.call();
        },
      ),
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
    required this.calendar,
    required this.child,
    super.key,
  });

  final ThreadGap gap;
  final ThreadDrag drag;
  final ValueNotifier<String?> hint;

  /// The chip's state for this drag.
  final ValueListenable<bool> shift;

  /// The "Calendar events too" chip's state for this drag.
  final ValueListenable<bool> calendar;
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
        final followers = shift.value != invert;
        drag.onDrop(
          d.data,
          gap,
          fractionOf(d.offset),
          DropShift(followers: followers, calendar: calendar.value),
        );
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
