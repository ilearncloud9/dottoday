import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/week/grid_focus.dart';
import 'package:dottoday/features/timeline/week/week_card.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';

/// A block on the hour grid that moves: held on touch or dragged with a
/// mouse (ED-116); its dragged copy is the block's own size, lifted above
/// every block it crosses. Calendar events and pinned tasks don't move.
class GridBlock extends StatelessWidget {
  const GridBlock({
    required this.task,
    required this.height,
    required this.narrow,
    required this.over,
    required this.picked,
    required this.onOpen,
    this.slot,
    this.onCue,
    this.onMove,
    super.key,
  });

  final ThreadTask task;
  final double height;
  final bool narrow;
  final bool over;
  final bool picked;
  final VoidCallback onOpen;
  final VoidCallback? onCue;
  final void Function({int steps, int days})? onMove;

  /// Its day and start, for the arrow keys between blocks ([GridFocus]).
  final GridSlot? slot;

  WeekCard _card({bool lifted = false, FocusNode? node}) => WeekCard(
    task: task,
    focusNode: node,
    height: height,
    narrow: narrow,
    lifted: lifted,
    over: over && !lifted,
    picked: !lifted && picked,
    onOpen: onOpen,
    onCue: onCue,
    onMove: onMove,
  );

  @override
  Widget build(BuildContext context) => GridFocusTarget(
    id: task.id,
    slot: slot,
    builder: (node) => _movable(node),
  );

  Widget _movable(FocusNode node) {
    if (!task.movable) return _card(node: node);
    // It appears at once, with no scale (owner, M19.2: the lift's motion
    // stays open, §7.5).
    return LayoutBuilder(
      builder: (context, box) => HoldOrMouseDraggable<String>(
        data: task.id,
        feedback: SizedBox(
          width: box.maxWidth,
          height: height,
          child: _card(lifted: true),
        ),
        childWhenDragging: Opacity(
          opacity: TaskAlpha.done,
          child: _card(node: node),
        ),
        callbacks: DragCallbacks(
          onDragStarted: () {},
          onDragUpdate: (_) {},
          onDragEnd: (_) {},
        ),
        child: _card(node: node),
      ),
    );
  }
}
