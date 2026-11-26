import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lays [child] out in the space it is given, but tells intrinsic layout
/// (a step's scrolling column) that it needs [height]. The dial measures
/// its box with a `LayoutBuilder`, which can't answer intrinsic questions.
class IntrinsicFloor extends SingleChildRenderObjectWidget {
  const IntrinsicFloor({required this.height, super.child, super.key});

  final double height;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderIntrinsicFloor(height);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderIntrinsicFloor renderObject,
  ) => renderObject.height = height;
}

/// [IntrinsicFloor]'s render box: answers its height to intrinsic
/// height questions.
class RenderIntrinsicFloor extends RenderProxyBox {
  RenderIntrinsicFloor(this._height);

  double _height;
  set height(double value) {
    if (value == _height) return;
    _height = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicHeight(double width) => _height;

  @override
  double computeMaxIntrinsicHeight(double width) => _height;

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;
}
