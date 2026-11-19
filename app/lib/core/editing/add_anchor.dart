import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Marks an add button (the toolbar +, the web Add, the rail's +) as where
/// Add's popover points (E-R2-36, ED-342: "under the toolbar +", however
/// Add was opened). The one painted last wins: the Workspace toolbar
/// lays out a copy of its + per width but paints only the one shown.
class AddAnchor extends SingleChildRenderObjectWidget {
  const AddAnchor({required super.child, super.key});

  /// The painted add button's rectangle in global coordinates, or null
  /// when none is on screen (a phone, or a screen with no +).
  static Rect? current() {
    final box = _RenderAddAnchor._last;
    if (box == null || !box.attached || !box.hasSize) return null;
    return MatrixUtils.transformRect(
      box.getTransformTo(null),
      Offset.zero & box.size,
    );
  }

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderAddAnchor();
}

class _RenderAddAnchor extends RenderProxyBox {
  // One add button is painted at a time; a weak hold is not needed since
  // detach clears it.
  static _RenderAddAnchor? _last;

  @override
  void paint(PaintingContext context, Offset offset) {
    _last = this;
    super.paint(context, offset);
  }

  @override
  void detach() {
    if (identical(_last, this)) _last = null;
    super.detach();
  }
}
