import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Room kept between a popover and the window's edges.
const double _edge = DotSpace.m;

/// Shows [builder]'s content in a popover pointing at [anchor] (global
/// coordinates), as the Mac and web Add popover (E-R2-36, ED-342): below
/// the button with its arrow on the button's centre, or above it when
/// there is more room there; the window's top end when [anchor] is null.
/// A click outside or Esc closes it; it returns [T] when popped with one.
///
/// ```dart
/// await showAnchoredPopover<void>(
///   context: context,
///   anchor: AddAnchor.current(),
///   width: DotSize.addPopover,
///   builder: (_) => const AddPopover(...),
/// );
/// ```
Future<T?> showAnchoredPopover<T>({
  required BuildContext context,
  required Rect? anchor,
  required double width,
  required WidgetBuilder builder,
}) => Navigator.of(context).push(
  _PopoverRoute<T>(
    anchor: anchor,
    width: width,
    builder: builder,
    barrierLabel: context.l10n.editorCancel,
    motion: DotTheme.of(context).motion,
  ),
);

class _PopoverRoute<T> extends PopupRoute<T> {
  _PopoverRoute({
    required this.anchor,
    required this.width,
    required this.builder,
    required this.barrierLabel,
    required this.motion,
  });

  final Rect? anchor;
  final double width;
  final WidgetBuilder builder;
  final DotMotion motion;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => motion.fast;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    // No + on screen: the window's top end, where the toolbar's + sits.
    final at =
        anchor ??
        Rect.fromLTWH(
          size.width - _edge - DotTouch.min,
          pad.top,
          DotTouch.min,
          DotTouch.min,
        );
    final place = PopoverPlace.of(at, size, pad, width);
    return CustomSingleChildLayout(
      delegate: _PopoverLayout(place),
      child: _Frame(
        place: place,
        child: Builder(builder: builder),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: motion.curve),
    child: child,
  );
}

/// Where a popover goes for an anchor in a window: its left edge and
/// width, the edge it hangs from (below the anchor, or above it), the
/// height it may use, and its arrow's offset from its left edge.
@visibleForTesting
final class PopoverPlace {
  const PopoverPlace({
    required this.left,
    required this.edge,
    required this.width,
    required this.maxHeight,
    required this.arrowX,
    required this.below,
  });

  /// As drawn (E-R2-36): the arrow [DotSize.popoverArrowInset] from the
  /// popover's end, on the anchor's centre, the popover kept in the
  /// window.
  factory PopoverPlace.of(Rect at, Size size, EdgeInsets pad, double wanted) {
    final width = math.max(0, math.min(wanted, size.width - 2 * _edge));
    final left = (at.center.dx - width + DotSize.popoverArrowInset)
        .clamp(_edge, math.max(_edge, size.width - width - _edge))
        .toDouble();
    final roomBelow = size.height - pad.bottom - at.bottom - _edge;
    final roomAbove = at.top - pad.top - _edge;
    final below = roomBelow >= roomAbove;
    // The arrow is part of the popover's own box (see [PopoverBorder]).
    const gap = DotSpace.xxs;
    const inset = DotRadii.popover + DotSize.popoverArrow;
    return PopoverPlace(
      left: left,
      edge: below ? at.bottom + gap : at.top - gap,
      width: width.toDouble(),
      maxHeight: math.max(0, (below ? roomBelow : roomAbove) - gap),
      arrowX: (at.center.dx - left)
          .clamp(inset, math.max(inset, width - inset))
          .toDouble(),
      below: below,
    );
  }

  final double left;

  /// The popover's top when [below], else its bottom.
  final double edge;
  final double width;
  final double maxHeight;
  final double arrowX;
  final bool below;
}

class _PopoverLayout extends SingleChildLayoutDelegate {
  const _PopoverLayout(this.place);

  final PopoverPlace place;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        minWidth: place.width,
        maxWidth: place.width,
        maxHeight: place.maxHeight,
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
    place.left,
    place.below ? place.edge : place.edge - childSize.height,
  );

  @override
  bool shouldRelayout(_PopoverLayout old) =>
      old.place.left != place.left ||
      old.place.edge != place.edge ||
      old.place.width != place.width ||
      old.place.maxHeight != place.maxHeight ||
      old.place.below != place.below;
}

/// The popover's surface: the sheet colour, a hairline, the floating
/// shadow and an arrow toward the anchor.
class _Frame extends StatelessWidget {
  const _Frame({required this.place, required this.child});

  final PopoverPlace place;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final shape = PopoverBorder(
      arrowX: place.arrowX,
      up: place.below,
      side: BorderSide(color: t.colors.hairline),
    );
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
          shadows: DotElevation.floating,
        ),
        child: Material(
          color: t.colors.sheet,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: place.below
                ? const EdgeInsets.only(top: DotSize.popoverArrow)
                : const EdgeInsets.only(bottom: DotSize.popoverArrow),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A rounded rectangle with an arrow on its top ([up]) or bottom edge,
/// centred [arrowX] from its left. The arrow lies inside the box (the
/// body is inset by [DotSize.popoverArrow] on that side), so nothing is
/// painted outside the popover's layout.
@visibleForTesting
class PopoverBorder extends ShapeBorder {
  const PopoverBorder({
    required this.arrowX,
    required this.up,
    this.side = BorderSide.none,
  });

  final double arrowX;
  final bool up;
  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    const a = DotSize.popoverArrow;
    final inner = up
        ? Rect.fromLTRB(rect.left, rect.top + a, rect.right, rect.bottom)
        : Rect.fromLTRB(rect.left, rect.top, rect.right, rect.bottom - a);
    final body = RRect.fromRectAndRadius(
      inner,
      const Radius.circular(DotRadii.popover),
    );
    final x = rect.left + arrowX;
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
  ShapeBorder scale(double t) =>
      PopoverBorder(arrowX: arrowX * t, up: up, side: side.scale(t));
}
