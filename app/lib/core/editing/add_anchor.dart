import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Marks an add button (the toolbar +, the web Add, the rail's +) as where
/// Add's popover points (E-R2-36, ED-342: "under the toolbar +", however
/// Add was opened). The one painted last wins: the Workspace toolbar
/// lays out a copy of its + per width but paints only the one shown.
class AddAnchor extends _PaintedAnchor {
  const AddAnchor({required super.child, super.key}) : super(_Slot.add);

  /// The painted add button's rectangle in global coordinates, or null
  /// when none is on screen (a phone, or a screen with no +).
  static Rect? current() => _RenderAnchor.rectOf(_Slot.add);
}

/// Marks the toolbar's date button as where Go to date points (E-R2-36,
/// M19.5 part 5c), however it was opened (⇧⌘T, the menus, web g).
class DateAnchor extends _PaintedAnchor {
  const DateAnchor({required this.onOpen, required super.child, super.key})
    : super(_Slot.date);

  /// Opens Go to date from this button, for the view it belongs to.
  final VoidCallback onOpen;

  /// The painted date button's rectangle, or null when none is on screen.
  static Rect? current() => _RenderAnchor.rectOf(_Slot.date);

  /// Opens Go to date from the painted date button; false when none is on
  /// screen (a phone, which has its own month).
  static bool open() {
    final box = _RenderAnchor._last[_Slot.date];
    if (box == null || !box.attached) return false;
    box.onOpen?.call();
    return true;
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) =>
      (renderObject as _RenderAnchor).onOpen = onOpen;
}

enum _Slot { add, date }

abstract class _PaintedAnchor extends SingleChildRenderObjectWidget {
  const _PaintedAnchor(this.slot, {required super.child, super.key});

  final _Slot slot;

  @override
  _RenderAnchor createRenderObject(BuildContext context) =>
      _RenderAnchor(slot)
        ..onOpen = this is DateAnchor ? (this as DateAnchor).onOpen : null;
}

class _RenderAnchor extends RenderProxyBox {
  _RenderAnchor(this.slot);

  final _Slot slot;

  /// What opening this anchor does (the date button's Go to date).
  VoidCallback? onOpen;

  // One of each is painted at a time; detach clears it.
  static final _last = <_Slot, _RenderAnchor>{};

  static Rect? rectOf(_Slot slot) {
    final box = _last[slot];
    if (box == null || !box.attached || !box.hasSize) return null;
    return MatrixUtils.transformRect(
      box.getTransformTo(null),
      Offset.zero & box.size,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _last[slot] = this;
    super.paint(context, offset);
  }

  @override
  void detach() {
    if (identical(_last[slot], this)) _last.remove(slot);
    super.detach();
  }
}
