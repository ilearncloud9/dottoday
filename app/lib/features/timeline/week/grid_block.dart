import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/week/grid_focus.dart';
import 'package:dottoday/features/timeline/week/week_card.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A block on the hour grid that moves: held on touch or dragged with a
/// mouse (ED-116); its dragged copy is the block's own size, lifted above
/// every block it crosses. Calendar events and pinned tasks don't move.
/// A touch hold let go where it lifted picks it into multi-select
/// ([onHold]); a picked block has the accent edge and a check (E-R2-6).
class GridBlock extends StatefulWidget {
  const GridBlock({
    required this.task,
    required this.height,
    required this.narrow,
    required this.over,
    required this.picked,
    required this.onOpen,
    this.overlaps = const [],
    this.selected = false,
    this.onHold,
    this.slot,
    this.onCue,
    this.onMove,
    this.onDone,
    super.key,
  });

  final ThreadTask task;
  final double height;
  final bool narrow;
  final bool over;
  final bool picked;

  /// The tasks whose times cross this one's, said after it (ED-248 B).
  final List<String> overlaps;

  /// Picked in multi-select (E-R2-6).
  final bool selected;
  final VoidCallback onOpen;

  /// A touch hold that did not move: picks the block (E-R2-6).
  final VoidCallback? onHold;
  final VoidCallback? onCue;
  final void Function({int steps, int days})? onMove;

  /// Done or reopened by its circle, at touch sizes (ED-276).
  final VoidCallback? onDone;

  /// Its day and start, for the arrow keys between blocks ([GridFocus]).
  final GridSlot? slot;

  @override
  State<GridBlock> createState() => _GridBlockState();
}

/// A leaf: how far a held block has travelled, and with what.
class _GridBlockState extends State<GridBlock> {
  double _travel = 0;
  PointerDeviceKind? _kind;

  WeekCard _card({bool lifted = false, FocusNode? node}) {
    final w = widget;
    return WeekCard(
      task: w.task,
      focusNode: node,
      height: w.height,
      narrow: w.narrow,
      lifted: lifted,
      over: w.over && !lifted,
      picked: !lifted && w.picked,
      overlaps: w.overlaps,
      selected: !lifted && w.selected,
      onOpen: w.onOpen,
      onCue: w.onCue,
      onMove: w.onMove,
      onDone: w.onDone,
    );
  }

  @override
  Widget build(BuildContext context) => GridFocusTarget(
    id: widget.task.id,
    slot: widget.slot,
    builder: (node) =>
        Listener(onPointerDown: (e) => _kind = e.kind, child: _movable(node)),
  );

  Widget _movable(FocusNode node) {
    if (!widget.task.movable) return _card(node: node);
    // It appears at once, with no scale (owner, M19.2: the lift's motion
    // stays open, §7.5).
    return LayoutBuilder(
      builder: (context, box) => HoldOrMouseDraggable<String>(
        data: widget.task.id,
        feedback: SizedBox(
          width: box.maxWidth,
          height: widget.height,
          child: _card(lifted: true),
        ),
        childWhenDragging: Opacity(
          opacity: TaskAlpha.done,
          child: _card(node: node),
        ),
        callbacks: DragCallbacks(
          onDragStarted: () => _travel = 0,
          onDragUpdate: (d) => _travel += d.delta.distance,
          // Let go where it lifted: a hold, not a move; its own column
          // takes no drop there.
          onDragEnd: (_) {
            if (_travel >= kTouchSlop) return;
            if (_kind != PointerDeviceKind.mouse) widget.onHold?.call();
          },
        ),
        child: _card(node: node),
      ),
    );
  }
}
