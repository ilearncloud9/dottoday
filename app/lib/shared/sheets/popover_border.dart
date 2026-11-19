import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A rounded rectangle with an arrow on its top ([up]) or bottom edge,
/// centred [arrowX] from its left; no arrow when [arrowX] is null. The arrow lies inside the box (the
/// body is inset by [DotSize.popoverArrow] on that side), so nothing is
/// painted outside the popover's layout.
@visibleForTesting
class PopoverBorder extends ShapeBorder {
  const PopoverBorder({
    required this.arrowX,
    required this.up,
    this.radius = DotRadii.popover,
    this.side = BorderSide.none,
  });

  final double? arrowX;
  final bool up;
  final double radius;
  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final ax = arrowX;
    if (ax == null) {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    }
    const a = DotSize.popoverArrow;
    final inner = up
        ? Rect.fromLTRB(rect.left, rect.top + a, rect.right, rect.bottom)
        : Rect.fromLTRB(rect.left, rect.top, rect.right, rect.bottom - a);
    final body = RRect.fromRectAndRadius(inner, Radius.circular(radius));
    final x = rect.left + ax;
    final y = up ? inner.top : inner.bottom;
    final tip = up ? rect.top : rect.bottom;
    final arrow = Path()
      ..moveTo(x - a, y)
      ..lineTo(x, tip)
      ..lineTo(x + a, y)
      ..close();
    return Path.combine(PathOperation.union, Path()..addRRect(body), arrow);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(getOuterPath(rect), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) => PopoverBorder(
    arrowX: arrowX == null ? null : arrowX! * t,
    up: up,
    radius: radius * t,
    side: side.scale(t),
  );
}
