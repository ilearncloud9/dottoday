import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// What a lifted task row hands its [Draggable]s.
@immutable
final class DragCallbacks {
  const DragCallbacks({
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    this.onFinished,
  });

  final VoidCallback onDragStarted;
  final DragUpdateCallback onDragUpdate;
  final DragEndCallback onDragEnd;

  /// The drag is over, accepted or not. Unlike [onDragEnd] it still runs
  /// when the row was unmounted mid-drag (the day changed under it).
  final VoidCallback? onFinished;
}

/// Lifts [data] on a [DotTouch.liftDelay] hold for touch and pen (so a
/// swipe still scrolls) and at once for a mouse, which has no scroll
/// gesture to protect (docs/09 M3e.1, from M3b.5's 250 ms hold).
///
/// Two draggables, one per device group, so each pointer meets exactly
/// one recognizer; a click without movement still reaches the row's tap.
class HoldOrMouseDraggable<T extends Object> extends StatelessWidget {
  const HoldOrMouseDraggable({
    required this.data,
    required this.feedback,
    required this.childWhenDragging,
    required this.callbacks,
    required this.child,
    super.key,
  });

  final T data;
  final Widget feedback;
  final Widget childWhenDragging;
  final DragCallbacks callbacks;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = callbacks;
    return _MouseDraggable<T>(
      data: data,
      feedback: feedback,
      childWhenDragging: childWhenDragging,
      onDragStarted: c.onDragStarted,
      onDragUpdate: c.onDragUpdate,
      onDragEnd: c.onDragEnd,
      onDragCompleted: c.onFinished,
      onDraggableCanceled: c.onFinished == null
          ? null
          : (_, _) => c.onFinished!(),
      child: _HoldDraggable<T>(
        data: data,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        onDragStarted: c.onDragStarted,
        onDragUpdate: c.onDragUpdate,
        onDragEnd: c.onDragEnd,
        onDragCompleted: c.onFinished,
        onDraggableCanceled: c.onFinished == null
            ? null
            : (_, _) => c.onFinished!(),
        child: child,
      ),
    );
  }
}

const _mouse = {PointerDeviceKind.mouse};

/// Everything but a mouse: touch, pens, trackpads and unknown devices.
final _held = PointerDeviceKind.values.toSet().difference(_mouse);

class _MouseDraggable<T extends Object> extends Draggable<T> {
  const _MouseDraggable({
    required super.data,
    required super.feedback,
    required super.childWhenDragging,
    required super.onDragStarted,
    required super.onDragUpdate,
    required super.onDragEnd,
    required super.child,
    super.onDragCompleted,
    super.onDraggableCanceled,
  });

  @override
  MultiDragGestureRecognizer createRecognizer(
    GestureMultiDragStartCallback onStart,
  ) =>
      ImmediateMultiDragGestureRecognizer(supportedDevices: _mouse)
        ..onStart = onStart;
}

class _HoldDraggable<T extends Object> extends Draggable<T> {
  const _HoldDraggable({
    required super.data,
    required super.feedback,
    required super.childWhenDragging,
    required super.onDragStarted,
    required super.onDragUpdate,
    required super.onDragEnd,
    required super.child,
    super.onDragCompleted,
    super.onDraggableCanceled,
  });

  @override
  MultiDragGestureRecognizer createRecognizer(
    GestureMultiDragStartCallback onStart,
  ) =>
      DelayedMultiDragGestureRecognizer(
          delay: DotTouch.liftDelay,
          supportedDevices: _held,
        )
        ..onStart = (position) {
          final drag = onStart(position);
          if (drag != null) _liftTick();
          return drag;
        };
}

/// The lift's haptic tick (LongPressDraggable's `hapticFeedbackOnStart`).
void _liftTick() {
  HapticFeedback.selectionClick().ignore();
}
