import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:dottoday/shared/dot/thread_drag.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/haptics/app_haptics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A row that accepts a dragged task: a free gap or another task's row
/// (ADR-0015). While one hovers, the task's landing preview sits on the
/// thread where the finger is, with the time it would get, as the Mac week
/// board's hover card does; let go, it reports how far down it was.
class SpanDropTarget extends StatefulWidget {
  const SpanDropTarget({
    required this.span,
    required this.drag,
    required this.hint,
    required this.shift,
    required this.calendar,
    required this.child,
    this.ownId,
    this.taskOf,
    super.key,
  });

  final DropSpan span;

  /// The task this row shows: it never accepts itself, so a long-press
  /// let go in place still selects (docs/03 §3.2).
  final String? ownId;
  final ThreadDrag drag;
  final ValueNotifier<String?> hint;

  /// The chip's state for this drag.
  final ValueListenable<bool> shift;

  /// The "Calendar events too" chip's state for this drag.
  final ValueListenable<bool> calendar;

  /// The dragged task, for its preview's dot and title; null (a task from
  /// elsewhere, or the add button) previews the time alone.
  final ThreadTask? Function(String id)? taskOf;
  final Widget child;

  @override
  State<SpanDropTarget> createState() => _SpanDropTargetState();
}

class _SpanDropTargetState extends State<SpanDropTarget> {
  /// The finger's place down the row while a task hovers (0–1).
  double? _at;

  double _fractionOf(Offset global) {
    final box = context.findRenderObject()! as RenderBox;
    final local = box.globalToLocal(global);
    return (local.dy / box.size.height).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => d.data != w.ownId,
      onMove: (d) {
        if (d.data == w.ownId) return;
        final at = _fractionOf(d.offset);
        final text = w.drag.hintFor(d.data, w.span, at);
        if (w.hint.value != text) {
          w.hint.value = text;
          AppHaptics.play(context, HapticTick.selection);
        }
        if (at != _at) setState(() => _at = at);
      },
      onLeave: (_) {
        w.hint.value = null;
        setState(() => _at = null);
      },
      onAcceptWithDetails: (d) {
        w.hint.value = null;
        setState(() => _at = null);
        AppHaptics.play(context, HapticTick.medium);
        // Desktop: holding Alt inverts the chip (docs/03 §3.2).
        final invert = HardwareKeyboard.instance.isAltPressed;
        final followers = w.shift.value != invert;
        w.drag.onDrop(
          d.data,
          w.span,
          _fractionOf(d.offset),
          DropShift(followers: followers, calendar: w.calendar.value),
        );
      },
      builder: (context, candidates, _) {
        final at = _at;
        final id = candidates.firstOrNull;
        if (at == null || id == null) return w.child;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            w.child,
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, box) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    PositionedDirectional(
                      start: 0,
                      end: 0,
                      top: box.maxHeight * at - DotSize.threadDot / 2,
                      child: IgnorePointer(
                        child: LandingPreview(
                          task: w.taskOf?.call(id),
                          hint: w.hint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Where a dragged task would land (ADR-0015): its dot on the thread's
/// axis, and the title with the time it would get, on a tinted strip.
class LandingPreview extends StatelessWidget {
  const LandingPreview({required this.hint, this.task, super.key});

  final ThreadTask? task;
  final ValueListenable<String?> hint;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final task = this.task;
    final swatch = task == null ? null : t.tasks[task.color];
    return Container(
      height: DotSize.threadDot,
      decoration: BoxDecoration(
        color: Color.alphaBlend(c.accentTint, c.raised),
        borderRadius: BorderRadius.circular(DotRadii.pill),
        boxShadow: DotElevation.floating,
      ),
      child: Row(
        children: [
          SizedBox(
            width: threadAxisWidth,
            child: task == null
                ? null
                : TaskDot(
                    color: task.color,
                    icon: task.icon,
                    state: DotState.upcoming,
                    label: '',
                    size: DotSize.threadDot,
                  ),
          ),
          const SizedBox(width: threadTextGap),
          Expanded(
            child: ValueListenableBuilder<String?>(
              valueListenable: hint,
              builder: (context, time, _) => Row(
                spacing: DotSpace.s,
                children: [
                  // Both shrink in a narrow column (the Mac spread's side
                  // days); the time comes first.
                  if (time != null)
                    Flexible(
                      flex: 2,
                      child: Text(
                        time,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: t.styles.button.copyWith(
                          color: swatch?.ink ?? c.accentInk,
                        ),
                      ),
                    ),
                  if (task != null)
                    Flexible(
                      child: Text(
                        task.title,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: t.styles.button,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The top of the thread as a drop zone: let a task go here and it becomes
/// all day (Structured's drop zone, ADR-0015). It lights up while one
/// hovers, with "All day" as its preview.
class AllDayDropTarget extends StatelessWidget {
  const AllDayDropTarget({
    required this.onAllDay,
    required this.label,
    required this.child,
    super.key,
  });

  final void Function(String id) onAllDay;

  /// "All day".
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => d.data != newTaskDragId,
      onAcceptWithDetails: (d) {
        AppHaptics.play(context, HapticTick.medium);
        onAllDay(d.data);
      },
      builder: (context, candidates, _) => candidates.isEmpty
          ? child
          : Stack(
              children: [
                child,
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(c.accentTint, c.raised),
                        borderRadius: BorderRadius.circular(DotRadii.pill),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: t.styles.button.copyWith(color: c.accentInk),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
