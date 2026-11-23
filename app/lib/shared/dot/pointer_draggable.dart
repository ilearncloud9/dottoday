import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/haptics/app_haptics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// The drags in flight and the Full ↔ Minimal switch (ED-100): a switch
/// mid-drag cancels the drag, so nothing is written and no Undo is made.
/// Flutter can't stop a pointer drag, so every drop target asks [live]
/// before it writes, and a drag begun before the last switch is refused.
abstract final class DragSession {
  static var _begun = 0;
  static var _current = 0;
  // Below every drag until the first switch: until then, every drop is
  // live.
  static var _voided = -1;

  /// A drag began (every [HoldOrMouseDraggable] calls it).
  static void began() => _current = ++_begun;

  /// The layout switched: every drag begun so far is void.
  static void voidAll() => _voided = _begun;

  /// Whether the drag being dropped may still be written.
  static bool get live => _current > _voided;
}

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
/// The lifted picture sits on the root overlay, over the page's own
/// floating chips ("Shift later tasks", E-R2-25 §1).
class HoldOrMouseDraggable<T extends Object> extends StatelessWidget {
  const HoldOrMouseDraggable({
    required this.data,
    required this.feedback,
    required this.childWhenDragging,
    required this.callbacks,
    required this.child,
    this.anchor = childDragAnchorStrategy,
    super.key,
  });

  final T data;

  /// Where the finger holds [feedback]; the row's own place by default.
  final DragAnchorStrategy anchor;
  final Widget feedback;
  final Widget childWhenDragging;
  final DragCallbacks callbacks;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = callbacks;
    void started() {
      DragSession.began();
      c.onDragStarted();
    }

    return _MouseDraggable<T>(
      anchor: anchor,
      data: data,
      feedback: feedback,
      childWhenDragging: childWhenDragging,
      onDragStarted: started,
      onDragUpdate: c.onDragUpdate,
      onDragEnd: c.onDragEnd,
      onDragCompleted: c.onFinished,
      onDraggableCanceled: c.onFinished == null
          ? null
          : (_, _) => c.onFinished!(),
      child: _HoldDraggable<T>(
        anchor: anchor,
        haptic: AppHaptics.enabledOf(context),
        data: data,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        onDragStarted: started,
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
    required DragAnchorStrategy anchor,
    required super.data,
    required super.feedback,
    required super.childWhenDragging,
    required super.onDragStarted,
    required super.onDragUpdate,
    required super.onDragEnd,
    required super.child,
    super.onDragCompleted,
    super.onDraggableCanceled,
  }) : super(dragAnchorStrategy: anchor, rootOverlay: true);

  @override
  MultiDragGestureRecognizer createRecognizer(
    GestureMultiDragStartCallback onStart,
  ) =>
      ImmediateMultiDragGestureRecognizer(supportedDevices: _mouse)
        ..onStart = onStart;
}

class _HoldDraggable<T extends Object> extends Draggable<T> {
  const _HoldDraggable({
    required DragAnchorStrategy anchor,
    required this.haptic,
    required super.data,
    required super.feedback,
    required super.childWhenDragging,
    required super.onDragStarted,
    required super.onDragUpdate,
    required super.onDragEnd,
    required super.child,
    super.onDragCompleted,
    super.onDraggableCanceled,
  }) : super(dragAnchorStrategy: anchor, rootOverlay: true);

  /// Whether the lift ticks (Settings › Sounds › Haptics in app): read in
  /// build, since the recognizer has no context.
  final bool haptic;

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
          // The lift's tick (LongPressDraggable's `hapticFeedbackOnStart`).
          if (drag != null && haptic) AppHaptics.fire(HapticTick.selection);
          return drag;
        };
}
