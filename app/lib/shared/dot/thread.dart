import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/bead_hop.dart';
import 'package:dottoday/shared/dot/fold_row.dart';
import 'package:dottoday/shared/dot/live_row.dart';
import 'package:dottoday/shared/dot/shift_chip.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread_drag.dart';
import 'package:dottoday/shared/dot/thread_hours.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:dottoday/shared/dot/thread_outside.dart';
import 'package:dottoday/shared/dot/thread_overlap.dart';
import 'package:dottoday/shared/dot/thread_pieces.dart';
import 'package:dottoday/shared/dot/thread_scale.dart';
import 'package:dottoday/shared/dot/thread_select.dart';
import 'package:flutter/material.dart';

export 'thread_drag.dart' show ThreadDrag;
export 'thread_fold.dart' show foldEarlier;
export 'thread_hours.dart'
    show ThreadHours, ThreadHourSpan, ThreadHourMark, hourGutter;
export 'thread_models.dart';
export 'thread_pieces.dart' show DashedPillPainter;

/// Callbacks a [Thread] reports with the task's id.
@immutable
final class ThreadActions {
  const ThreadActions({
    this.onToggleDone,
    this.onOpen,
    this.onFocus,
    this.onUnstick,
    this.onRunningLate,
    this.onAddHere,
    this.onCap,
    this.onEarlier,
    this.drag,
    this.selectedIds = const {},
    this.onSelect,
    this.emptyDay,
    this.pickedId,
  });

  final ValueChanged<String>? onToggleDone;
  final ValueChanged<String>? onOpen;

  /// One tap on the live dot opens Focus (M10.5).
  final ValueChanged<String>? onFocus;

  /// The Unstick answer for a task (11 B3, M10.7): its first step.
  final void Function(String id, String answer)? onUnstick;

  /// Running late on the now card (minimal layout, docs/14 §4); null: Full
  /// Today's now card has no buttons (E-Phones Today, M18.3).
  final ValueChanged<String>? onRunningLate;

  /// A future gap was tapped; reports the gap.
  final ValueChanged<ThreadGap>? onAddHere;

  /// A cap was tapped: true for Wind Down, false for Wake Up (R-17).
  final ValueChanged<bool>? onCap;

  /// The Earlier row was shown (true) or hidden (ED-164); the caller keeps
  /// the choice and re-folds the entries.
  final ValueChanged<bool>? onEarlier;

  /// Long-press drag onto any time of the day (R-05, ADR-0015); null = no
  /// drag.
  final ThreadDrag? drag;

  /// Multi-select (R-05): non-empty puts every row in selection mode,
  /// where a tap toggles instead of opening.
  final Set<String> selectedIds;

  /// Adds or removes a task: long-press without moving, Shift/⌘-click, or
  /// the screen reader's "Select" action. Null = no multi-select.
  final ValueChanged<String>? onSelect;

  /// A day with no tasks (E-Phones' empty day): what fills its free time
  /// in place of "N h free · add here", in the last gap that can take a
  /// task, given that gap's minutes. The gap keeps its dotted line and
  /// stays a drop target.
  final Widget Function(int freeMinutes)? emptyDay;

  /// The task the Workspace inspector shows (ED-391); its row gets the
  /// grid's 2 px ink edge (owner, M19.2 part 3b).
  final String? pickedId;
}

/// The day as a vertical thread (docs/10 §1, §3 `Thread`): sun cap, task
/// rows, free gaps, moon cap. A `Column`, so callers put it in a scroll
/// view or a sliver; it never scrolls itself.
class Thread extends StatefulWidget {
  const Thread({
    required this.entries,
    this.actions = const ThreadActions(),
    this.anchorIndex,
    this.anchorKey,
    this.hours,
    super.key,
  }) : sliver = false;

  /// The same thread as a sliver that builds only the rows on screen, for
  /// long days in a `CustomScrollView` (R-15: 200 tasks at 60 fps).
  const Thread.sliver({
    required this.entries,
    this.actions = const ThreadActions(),
    this.anchorIndex,
    this.anchorKey,
    this.hours,
    super.key,
  }) : sliver = true;

  /// Whether this builds a sliver rather than a `Column`.
  final bool sliver;

  final List<ThreadEntry> entries;
  final ThreadActions actions;

  /// The entry that carries [anchorKey], so a scroll view can find its
  /// row (today's card opens at now, ED-336).
  final int? anchorIndex;
  final GlobalKey? anchorKey;

  /// The Day view's hour scale (E-FullA-v2 web Day): rows as tall as their
  /// time with the hours in a gutter; null, rows keep their own heights.
  final ThreadHours? hours;

  @override
  State<Thread> createState() => _ThreadState();
}

class _ThreadState extends State<Thread> {
  /// The lifted dot's drop time while a task is dragged (app-wide, so the
  /// dragged add button shows it too).
  ValueNotifier<String?> get _hint => TaskDragging.hint;

  /// "Shift later tasks" for the current drag, shown in the overlay.
  final _shift = ValueNotifier<bool>(false);

  /// "Calendar events too" for the current drag (docs/09 M7.6).
  final _calendar = ValueNotifier<bool>(false);

  /// The chip while it shows. An entry rather than an `OverlayPortal`: a
  /// portal is laid out with its slot, and a lazy list may not lay that
  /// slot out once the drag scrolls it away.
  OverlayEntry? _chip;

  /// The moving now (ED-246, ED-364).
  final _hops = BeadHops();

  @override
  void didUpdateWidget(Thread old) {
    super.didUpdateWidget(old);
    _hops.update(context, old.entries, widget.entries);
  }

  @override
  void dispose() {
    _settle();
    _shift.dispose();
    _calendar.dispose();
    super.dispose();
  }

  void _lift() {
    final drag = widget.actions.drag;
    final start = drag?.shiftByDefault;
    if (drag == null || start == null) return;
    final calendar = drag.calendarByDefault;
    _shift.value = start;
    _calendar.value = calendar ?? false;
    _settle();
    final chip = OverlayEntry(
      builder: (_) =>
          ShiftChip(on: _shift, calendar: calendar == null ? null : _calendar),
    );
    Overlay.of(context).insert(chip);
    _chip = chip;
  }

  void _settle() {
    _chip?.remove();
    _chip?.dispose();
    _chip = null;
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    final solid = threadSolid(entries);
    final empty =
        widget.actions.emptyDay != null &&
            !entries.any((e) => e is ThreadTaskEntry)
        ? entries.lastIndexWhere((e) => e is ThreadGap && e.addable)
        : -1;
    _hops.built();
    final closing = _hops.closingAt;
    Widget row(int n) {
      if (n == closing) {
        return _hops.departing(() => setState(() => _hops.closingAt = null));
      }
      final i = closing != null && n > closing ? n - 1 : n;
      final entry = _entry(entries[i], solid[i], empty: i == empty);
      return _keyed(i, _onHours(i, entry));
    }

    final count = entries.length + (closing == null ? 0 : 1);
    final scale = _scale;
    if (widget.sliver) {
      return ThreadScope(
        scale: scale,
        child: SliverList.builder(
          itemCount: count,
          itemBuilder: (_, n) => row(n),
        ),
      );
    }
    return ThreadScope(
      scale: scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (var n = 0; n < count; n++) row(n)],
      ),
    );
  }

  /// [row] on the hour scale, when the thread has one.
  Widget _onHours(int i, Widget row) {
    final h = widget.hours;
    if (h == null) return row;
    final now = h.nowIn;
    if (now != null && i == now.nowRow) return const SizedBox.shrink();
    return ThreadHourRow(
      span: i < h.spans.length ? h.spans[i] : null,
      pxPerMinute: h.pxPerMinute,
      now: now != null && i == now.row ? (at: now.at, time: now.time) : null,
      child: row,
    );
  }

  Widget _keyed(int i, Widget row) => switch (widget.anchorKey) {
    final key? when i == widget.anchorIndex => KeyedSubtree(
      key: key,
      child: row,
    ),
    _ => row,
  };

  /// The row for [e]; [solid] is its colour from [threadSolid].
  Widget _entry(ThreadEntry e, TaskColor? solid, {bool empty = false}) {
    final a = widget.actions;
    final drag = a.drag;
    return switch (e) {
      ThreadCap(windDown: false) when drag?.onAllDay != null =>
        AllDayDropTarget(
          onAllDay: drag!.onAllDay!,
          label: context.l10n.timelineAllDay,
          child: _cap(e, solid),
        ),
      ThreadCap() => _cap(e, solid),
      ThreadGap(:final span?) when drag != null => _droppable(
        span,
        drag,
        _gap(e, solid, empty: empty),
      ),
      ThreadGap() => _gap(e, solid, empty: empty),
      ThreadNow() => _hops.arriving(NowRow(now: e, solid: solid)),
      ThreadTaskEntry(:final task) => _task(task, solid: solid),
      ThreadOverlap() => OverlapRow(overlap: e),
      ThreadEarlier() => EarlierRow(earlier: e, onToggle: a.onEarlier),
      ThreadOutside(:final tasks) => OutsideRow(
        zone: e,
        taskRow: _task,
        reveal: tasks.any((t) => a.selectedIds.contains(t.id)),
      ),
    };
  }

  Widget _cap(ThreadCap cap, TaskColor? solid) {
    final onCap = widget.actions.onCap;
    return CapRow(
      cap: cap,
      solid: solid,
      size: _scale.cap,
      onTap: onCap == null ? null : () => onCap(cap.windDown),
    );
  }

  /// [child] as a drop target standing for [span] (ADR-0015).
  Widget _droppable(
    DropSpan span,
    ThreadDrag drag,
    Widget child, {
    String? ownId,
  }) => SpanDropTarget(
    span: span,
    drag: drag,
    hint: _hint,
    shift: _shift,
    calendar: _calendar,
    ownId: ownId,
    taskOf: _taskOf,
    child: child,
  );

  /// A task of this thread by id, for the landing preview.
  ThreadTask? _taskOf(String id) =>
      threadTasks(widget.entries).where((t) => t.id == id).firstOrNull;

  Widget _gap(ThreadGap gap, TaskColor? solid, {bool empty = false}) => GapRow(
    gap: gap,
    solid: solid,
    body: empty ? widget.actions.emptyDay?.call(gap.minutes) : null,
    onAdd: widget.actions.onAddHere,
  );

  /// A task row with selection and drag around it, as far as enabled;
  /// [solid] is the colour the thread arrives in behind now.
  Widget _task(ThreadTask task, {TaskColor? solid}) {
    final a = widget.actions;
    final drag = a.drag;
    final onSelect = a.onSelect;
    // While selecting a tap picks, so the pick ring takes the done
    // circle's place (E-R2-6).
    final onDone = a.selectedIds.isEmpty ? a.onToggleDone : null;
    Widget row = task.state == DotState.live
        ? LiveRow(
            task: task,
            onToggleDone: _bind(onDone, task),
            onOpen: _open(task),
            onFocus: _bind(a.onFocus, task),
            onUnstick: _answer(a.onUnstick, task),
            onRunningLate: _bind(a.onRunningLate, task),
            solid: solid,
          )
        : TaskRow(
            task: task,
            solid: solid,
            dotSize: _scale.dot,
            onToggleDone: _bind(onDone, task),
            onOpen: _open(task),
            // Smallest step's Start opens Focus, which records the start.
            onStart: _bind(a.onFocus, task),
            onUnstick: _answer(a.onUnstick, task),
          );
    // Rows by length on phones (ED-419), else fixed by state (E rules
    // §5.2); the live row sets its own.
    if (task.state != DotState.live) {
      row = ConstrainedBox(
        constraints: BoxConstraints(minHeight: _scale.rowHeight(task)),
        child: row,
      );
    }
    // Always wrapped, so a pick never rebuilds the row (and its focus).
    row = PickedRowEdge(picked: a.pickedId == task.id, child: row);
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
    if (task.span case final span?) {
      row = _droppable(span, drag, row, ownId: task.id);
    }
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

  /// This thread's sizes for its width (ED-419); the hour scale sizes
  /// rows by the clock, so Concept E's there.
  ThreadScale get _scale =>
      widget.hours == null ? ThreadScale.forWidth(context) : ThreadScale.wide;

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

  /// The Unstick answer for [task], while its row shows the question.
  static ValueChanged<String>? _answer(
    void Function(String id, String answer)? onUnstick,
    ThreadTask task,
  ) => onUnstick == null || !task.unstick
      ? null
      : (answer) => onUnstick(task.id, answer);

  static VoidCallback? _bind(ValueChanged<String>? f, ThreadTask task) =>
      f == null ? null : () => f(task.id);
}
