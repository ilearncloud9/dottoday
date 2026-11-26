import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A chip's dot on its way to its row (`flyTo`): from [from] to [to] in
/// the step's box.
final class Flight {
  const Flight({required this.id, required this.color, this.from, this.to});

  final String id;
  final Color color;
  final Rect? from;
  final Rect? to;

  /// This flight along [route].
  Flight along((Rect, Rect) route) =>
      Flight(id: id, color: color, from: route.$1, to: route.$2);
}

/// Where [from] and [to] are inside [box], or null if either is not laid
/// out.
(Rect, Rect)? flightRoute(GlobalKey box, GlobalKey from, GlobalKey to) {
  final b = box.currentContext?.findRenderObject() as RenderBox?;
  Rect? at(GlobalKey k) {
    final r = k.currentContext?.findRenderObject() as RenderBox?;
    if (b == null || r == null || !r.hasSize) return null;
    return b.globalToLocal(r.localToGlobal(Offset.zero)) & r.size;
  }

  final a = at(from);
  final z = at(to);
  if (a == null || z == null) return null;
  return (a, z);
}

/// The flying dot (`.fly`): the source dot's size, filled in its colour.
/// Over 560 ms on the draw curve it arcs up 50 past the middle, growing
/// to 1.25, and lands on the row's dot at .94.
class FlightLayer extends StatelessWidget {
  const FlightLayer({required this.flight, required this.progress, super.key});

  final Flight? flight;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final f = flight;
    final from = f?.from;
    final to = f?.to;
    if (f == null || from == null || to == null) {
      return const SizedBox.shrink();
    }
    final d = to.center - from.center;
    final mid = Offset(
      d.dx * OnbSize.flyMidX,
      d.dy * OnbSize.flyMidY - OnbSize.flyRise,
    );
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final p = OnbMotion.draw.transform(progress.value);
        final first = p < 0.5;
        final q = first ? p / 0.5 : (p - 0.5) / 0.5;
        final at = first
            ? Offset.lerp(Offset.zero, mid, q)!
            : Offset.lerp(mid, d, q)!;
        final scale = first
            ? 1 + (OnbSize.flyMidScale - 1) * q
            : OnbSize.flyMidScale +
                  (OnbSize.flyEndScale - OnbSize.flyMidScale) * q;
        return Stack(
          children: [
            Positioned.fromRect(
              rect: from.shift(at),
              child: Transform.scale(scale: scale, child: child),
            ),
          ],
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: f.color,
          boxShadow: [
            BoxShadow(
              color: OnbSky.black.withValues(alpha: OnbSize.flyShadowAlpha),
              offset: const Offset(0, OnbSize.flyShadowY),
              blurRadius: OnbSize.flyShadowBlur,
              spreadRadius: OnbSize.flyShadowSpread,
            ),
          ],
        ),
      ),
    );
  }
}
