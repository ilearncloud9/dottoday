import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/features/timeline/layout/day_layout.dart';
import 'package:dottoday/features/timeline/layout/drag_math.dart';
import 'package:dottoday/features/timeline/widgets/drag_coordinator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// How long a finger must rest before a block lifts (docs/03 §3.2 "long-
/// press 250 ms"). Shorter than the platform's 500 ms so it feels direct,
/// still long enough that a flick always scrolls (R-05).
const pickUpDelay = Duration(milliseconds: 250);

const _touchDevices = {
  PointerDeviceKind.touch,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown,
};

/// Pointer handling for one block (docs/03 §3.2):
///
/// - touch: long-press 250 ms picks the block up, then it follows the
///   finger; a vertical swipe without the pause scrolls the day instead,
///   because the scroll view wins the arena before the long-press fires;
/// - mouse: drag moves at once (wheel/trackpad scroll), and dragging the
///   top/bottom [edgeZone] resizes, with a matching cursor.
class BlockGestures extends StatefulWidget {
  const BlockGestures({
    required this.placement,
    required this.child,
    super.key,
  });

  final BlockPlacement placement;
  final Widget child;

  /// Height of the mouse resize zone at each end of a block.
  static const double edgeZone = AppSpacing.s;

  @override
  State<BlockGestures> createState() => _BlockGesturesState();
}

class _BlockGesturesState extends State<BlockGestures> {
  MouseCursor _cursor = SystemMouseCursors.grab;

  DragMode _modeAt(double localY) {
    final h = context.size?.height ?? 0;
    if (localY <= BlockGestures.edgeZone) return DragMode.resizeStart;
    if (localY >= h - BlockGestures.edgeZone) return DragMode.resizeEnd;
    return DragMode.move;
  }

  void _hover(PointerHoverEvent e) {
    final next = switch (_modeAt(e.localPosition.dy)) {
      DragMode.move => SystemMouseCursors.grab,
      _ => SystemMouseCursors.resizeRow,
    };
    if (next != _cursor) setState(() => _cursor = next);
  }

  @override
  Widget build(BuildContext context) {
    final drag = DragScope.maybeOf(context);
    if (drag == null) return widget.child;
    final p = widget.placement;
    return MouseRegion(
      cursor: _cursor,
      onHover: _hover,
      child: RawGestureDetector(
        // Screen readers move blocks through the editor / keyboard, not a
        // bare long-press action (03 §4 non-drag equivalents).
        excludeFromSemantics: true,
        gestures: {
          LongPressGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                () => LongPressGestureRecognizer(
                  duration: pickUpDelay,
                  supportedDevices: _touchDevices,
                ),
                (r) {
                  r.onLongPressStart = (d) {
                    drag.start(p, d.globalPosition, DragMode.move);
                  };
                  r.onLongPressMoveUpdate = (d) {
                    drag.update(d.globalPosition);
                  };
                  r.onLongPressEnd = (_) => drag.end();
                  r.onLongPressCancel = drag.cancel;
                },
              ),
          VerticalDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                VerticalDragGestureRecognizer
              >(
                () => VerticalDragGestureRecognizer(
                  supportedDevices: {PointerDeviceKind.mouse},
                  // Grab where the button went down, not where the slop
                  // was crossed, so the block doesn't jump.
                )..dragStartBehavior = DragStartBehavior.down,
                (r) {
                  r.onStart = (d) {
                    drag.start(
                      p,
                      d.globalPosition,
                      _modeAt(d.localPosition.dy),
                    );
                  };
                  r.onUpdate = (d) => drag.update(d.globalPosition);
                  r.onEnd = (_) => drag.end();
                  r.onCancel = drag.cancel;
                },
              ),
        },
        child: widget.child,
      ),
    );
  }
}
