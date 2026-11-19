import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Shows the first of [children] whose natural width fits, else the last
/// (rules §12.3: a toolbar collapses items into pop-ups when short of room
/// and never clips). Measured from the children's own intrinsic widths,
/// so larger text and longer translations collapse sooner on their own.
///
/// Only the shown child is painted, hit and read by a screen reader, and
/// only it takes keyboard focus; the others stay mounted (to be measured)
/// with focus shut out of them.
class FirstThatFits extends StatefulWidget {
  const FirstThatFits({required this.children, super.key})
    : assert(children.length > 0);

  final List<Widget> children;

  @override
  State<FirstThatFits> createState() => _FirstThatFitsState();
}

class _FirstThatFitsState extends State<FirstThatFits> {
  int _shown = 0;

  /// Layout picked [index]; focus follows a frame later (no setState in
  /// layout).
  void _picked(int index) {
    if (index == _shown) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && index != _shown) setState(() => _shown = index);
    });
  }

  @override
  Widget build(BuildContext context) => _Fit(
    onPick: _picked,
    children: [
      for (final (i, child) in widget.children.indexed)
        ExcludeFocus(excluding: i != _shown, child: child),
    ],
  );
}

class _Fit extends MultiChildRenderObjectWidget {
  const _Fit({required this.onPick, required super.children});

  final ValueChanged<int> onPick;

  @override
  RenderFirstThatFits createRenderObject(BuildContext context) =>
      RenderFirstThatFits(onPick: onPick);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFirstThatFits renderObject,
  ) => renderObject.onPick = onPick;
}

class _FitParentData extends ContainerBoxParentData<RenderBox> {}

/// The render object behind [FirstThatFits].
class RenderFirstThatFits extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FitParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _FitParentData> {
  RenderFirstThatFits({required this.onPick});

  /// Told which child (by index) each layout shows.
  ValueChanged<int> onPick;

  RenderBox? _shown;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _FitParentData) {
      child.parentData = _FitParentData();
    }
  }

  RenderBox _pick(double maxWidth, double height) {
    var child = firstChild!;
    for (var next = childAfter(child); next != null; next = childAfter(next)) {
      if (child.getMaxIntrinsicWidth(height) <= maxWidth) return child;
      child = next;
    }
    return child;
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      lastChild!.getMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      firstChild!.getMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) =>
      _pick(width, double.infinity).getMinIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _pick(width, double.infinity).getMaxIntrinsicHeight(width);

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(
    _pick(
      constraints.maxWidth,
      constraints.maxHeight,
    ).getDryLayout(constraints.loosen()),
  );

  @override
  void performLayout() {
    final height = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : double.infinity;
    final shown = _pick(constraints.maxWidth, height);
    // The others are laid out too (never painted, so a too-wide one never
    // draws its overflow), so tools that measure every box find a size.
    for (var c = firstChild; c != null; c = childAfter(c)) {
      c.layout(constraints.loosen(), parentUsesSize: c == shown);
    }
    _shown = shown;
    var index = 0;
    for (var c = firstChild; c != shown; c = childAfter(c!)) {
      index++;
    }
    onPick(index);
    size = constraints.constrain(
      Size(math.max(shown.size.width, constraints.minWidth), shown.size.height),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_shown case final s?) context.paintChild(s, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final s = _shown;
    if (s == null) return false;
    return result.addWithPaintOffset(
      offset: Offset.zero,
      position: position,
      hitTest: (result, transformed) =>
          s.hitTest(result, position: transformed),
    );
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (_shown case final s?) visitor(s);
  }
}
