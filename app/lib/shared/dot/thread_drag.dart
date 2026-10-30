import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

export 'thread_drop_target.dart';

/// The drag id of the add button dragged onto the thread: a new task at
/// the time it is let go (Structured's drag-the-+, ADR-0015).
const newTaskDragId = 'dottoday:new-task'; // l10n-ignore: drag id

/// Which task is being dragged right now, anywhere in the app (null when
/// none): the shell shows its Trash and Inbox drop targets while set.
abstract final class TaskDragging {
  static final current = ValueNotifier<String?>(null);

  /// The time a dragged task (or the add button) would land at, shown
  /// beside the lifted dot: one label wherever the drag started.
  static final hint = ValueNotifier<String?>(null);
}

/// What a thread does with drags (docs/10 §6: long-press = drag to another
/// time or day, R-05). A task lands anywhere on the day: in free time or
/// on another task's row, overlapping it (ADR-0015). The feature turns
/// positions into times; the thread only reports them.
@immutable
final class ThreadDrag {
  const ThreadDrag({
    required this.onDrop,
    required this.hintFor,
    this.shiftByDefault,
    this.calendarByDefault,
    this.onAllDay,
  });

  /// Task [id] dropped at the top of the thread: all day (Structured's
  /// drop zone, ADR-0015); null = no such zone.
  final void Function(String id)? onAllDay;

  /// Task [id] dropped on [span], [fraction] (0–1) down its row; [shift]
  /// says what the chips said at the drop.
  final void Function(
    String id,
    DropSpan span,
    double fraction,
    DropShift shift,
  )
  onDrop;

  /// The floating label while task [id] hovers [span] at [fraction]
  /// ("11:30"), or null off any row.
  final String? Function(String id, DropSpan? span, double fraction) hintFor;

  /// Where the "Shift later tasks" chip starts each drag (Settings ›
  /// Shift later tasks); null hides the chip (R-04).
  final bool? shiftByDefault;

  /// Where the "Calendar events too" chip starts each drag (Settings ›
  /// Calendars › Move calendar events too); null hides it, for a day
  /// without calendar events a shift could carry (docs/09 M7.6).
  final bool? calendarByDefault;
}

/// Long-press to lift a task row (250 ms, 03 §3.2; a mouse lifts at once):
/// its dot follows the finger with the snapped drop time, the thread
/// previews where it lands, and the list scrolls near its edges.
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
    final id = widget.task.id;
    return HoldOrMouseDraggable<String>(
      data: id,
      feedback: LiftedDot(
        color: widget.task.color,
        icon: widget.task.icon,
        hint: widget.hint,
      ),
      childWhenDragging: Opacity(opacity: TaskAlpha.done, child: widget.child),
      callbacks: DragCallbacks(
        onDragStarted: () {
          _travel = 0;
          TaskDragging.current.value = id;
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
        onFinished: () => TaskDragging.current.value = null,
      ),
      child: widget.child,
    );
  }
}

/// What follows the finger (ADR-0015, after Structured): the task's own
/// dot, lifted, with the time it would land at beside it. Where it lands
/// shows on the thread itself ([SpanDropTarget]'s preview).
class LiftedDot extends StatelessWidget {
  const LiftedDot({
    required this.color,
    required this.icon,
    required this.hint,
    super.key,
  });

  final TaskColor color;
  final TaskIcon icon;
  final ValueListenable<String?> hint;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.s,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: DotElevation.floating,
          ),
          child: TaskDot(
            color: color,
            icon: icon,
            state: DotState.upcoming,
            label: '',
            size: DotSize.threadDot,
          ),
        ),
        ValueListenableBuilder<String?>(
          valueListenable: hint,
          builder: (context, text, _) => text == null
              ? const SizedBox.shrink()
              : Material(
                  color: t.colors.text,
                  shape: const StadiumBorder(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DotSpace.m,
                      vertical: DotSpace.xs,
                    ),
                    child: Text(
                      text,
                      style: t.styles.button.copyWith(color: t.colors.raised),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
