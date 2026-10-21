import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/live_row.dart';
import 'package:dottoday/shared/dot/shift_chip.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_drag.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/dot/thread_pieces.dart';
import 'package:dottoday/shared/dot/thread_select.dart';
import 'package:flutter/material.dart';

export 'thread_drag.dart' show ThreadDrag;
export 'thread_models.dart';
export 'thread_pieces.dart' show DashedPillPainter;

/// Callbacks a [Thread] reports with the task's id.
@immutable
final class ThreadActions {
  const ThreadActions({
    this.onToggleDone,
    this.onOpen,
    this.onExtend,
    this.onShiftRest,
    this.onAddHere,
    this.drag,
    this.selectedIds = const {},
    this.onSelect,
  });

  final ValueChanged<String>? onToggleDone;
  final ValueChanged<String>? onOpen;
  final ValueChanged<String>? onExtend;
  final ValueChanged<String>? onShiftRest;

  /// A future gap was tapped; reports the gap.
  final ValueChanged<ThreadGap>? onAddHere;

  /// Long-press drag onto gaps and resize grips (R-05); null = no drag.
  final ThreadDrag? drag;

  /// Multi-select (R-05): non-empty puts every row in selection mode,
  /// where a tap toggles instead of opening.
  final Set<String> selectedIds;

  /// Adds or removes a task: long-press without moving, Shift/⌘-click, or
  /// the screen reader's "Select" action. Null = no multi-select.
  final ValueChanged<String>? onSelect;
}

/// The day as a vertical thread (docs/10 §1, §3 `Thread`): sun cap, task
/// rows, free gaps, moon cap. A `Column`, so callers put it in a scroll
/// view or a sliver; it never scrolls itself.
class Thread extends StatefulWidget {
  const Thread({
    required this.entries,
    this.actions = const ThreadActions(),
    this.dotSize = DotSize.rowDot,
    super.key,
  });

  final List<ThreadEntry> entries;
  final ThreadActions actions;

  /// [DotSize.rowDot], or [DotSize.macRowDot] in the Mac spread's side days.
  final double dotSize;

  @override
  State<Thread> createState() => _ThreadState();
}

class _ThreadState extends State<Thread> {
  /// The lifted chip's drop time while a task is dragged.
  final _hint = ValueNotifier<String?>(null);

  /// "Shift later tasks" for the current drag, shown in the overlay.
  final _shift = ValueNotifier<bool>(false);
  final _chip = OverlayPortalController();

  @override
  void dispose() {
    _hint.dispose();
    _shift.dispose();
    super.dispose();
  }

  void _lift() {
    final start = widget.actions.drag?.shiftByDefault;
    if (start == null) return;
    _shift.value = start;
    _chip.show();
  }

  void _settle() {
    if (_chip.isShowing) _chip.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final e in widget.entries) _entry(e),
        // A sibling, not a wrapper: wrapping the rows would merge their
        // semantics into one node (R-12).
        OverlayPortal(
          controller: _chip,
          overlayChildBuilder: (_) => ShiftChip(on: _shift),
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _entry(ThreadEntry e) {
    final a = widget.actions;
    final drag = a.drag;
    return switch (e) {
      ThreadCap() => CapRow(cap: e),
      ThreadGap() when drag != null => GapDropTarget(
        gap: e,
        drag: drag,
        hint: _hint,
        shift: _shift,
        child: GapRow(gap: e, onAdd: a.onAddHere),
      ),
      ThreadGap() => GapRow(gap: e, onAdd: a.onAddHere),
      ThreadTaskEntry(:final task) => _task(task),
    };
  }

  /// A task row with selection and drag around it, as far as enabled.
  Widget _task(ThreadTask task) {
    final a = widget.actions;
    final drag = a.drag;
    final onSelect = a.onSelect;
    Widget row = task.state == DotState.live
        ? LiveRow(
            task: task,
            onToggleDone: _bind(a.onToggleDone, task),
            onOpen: _open(task),
            onExtend: _bind(a.onExtend, task),
            onShiftRest: task.overrunMinutes > 0
                ? _bind(a.onShiftRest, task)
                : null,
            onResize: _resize(drag, task),
          )
        : TaskRow(
            task: task,
            dotSize: widget.dotSize,
            onToggleDone: _bind(a.onToggleDone, task),
            onOpen: _open(task),
            onResize: _resize(drag, task),
          );
    if (onSelect != null) {
      row = SelectableTaskRow(
        selecting: a.selectedIds.isNotEmpty,
        selected: a.selectedIds.contains(task.id),
        label: taskRowLabel(context.l10n, task),
        onSelect: () => onSelect(task.id),
        child: row,
      );
    }
    if (drag == null) return row;
    return DraggableTaskRow(
      task: task,
      drag: drag,
      hint: _hint,
      onLift: _lift,
      onSettle: _settle,
      onHold: onSelect == null ? null : () => onSelect(task.id),
      child: row,
    );
  }

  /// Opens the task, or on desktop adds it to the selection while Shift,
  /// ⌘ or Ctrl is held.
  VoidCallback? _open(ThreadTask task) {
    final a = widget.actions;
    final open = a.onOpen;
    final select = a.onSelect;
    if (open == null) return null;
    return () => select != null && selectModifierHeld()
        ? select(task.id)
        : open(task.id);
  }

  static ValueChanged<int>? _resize(ThreadDrag? drag, ThreadTask task) {
    final onResize = drag?.onResize;
    if (onResize == null || !task.movable) return null;
    return (steps) => onResize(task.id, steps);
  }

  static VoidCallback? _bind(ValueChanged<String>? f, ThreadTask task) =>
      f == null ? null : () => f(task.id);
}
