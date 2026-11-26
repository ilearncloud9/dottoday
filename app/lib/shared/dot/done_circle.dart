import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The round done circle at a row's end (ADR-0015, E rules §4.4): a 2.5 px
/// ring, grey ahead and in the task's [color] for the [live] task, that
/// fills with the task's colour and a white tick once [done]; tapping it
/// again undoes it. The row keeps its place either way. Marking done sends
/// a ring in the task's colour fading outward from it ([showDoneBurst],
/// ED-490); undoing never does.
class DoneCircle extends StatelessWidget {
  const DoneCircle({
    required this.color,
    required this.done,
    required this.title,
    this.live = false,
    this.onTap,
    this.link,
    super.key,
  });

  final TaskColor color;
  final bool done;

  /// The task under way: its ring is in the task's colour.
  final bool live;

  /// The task's title, for the screen reader ("Boom, checked").
  final String title;
  final VoidCallback? onTap;

  /// Ties a hint to this circle (the first Today's "Tap the circle when
  /// it's done", ED-490).
  final LayerLink? link;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final swatch = t.tasks[color];
    final l10n = context.l10n;
    const size = DotSize.doneCircle;
    final onTap = this.onTap == null
        ? null
        : () {
            if (!done) showDoneBurst(context, swatch.color);
            this.onTap!();
          };
    return Semantics(
      button: true,
      checked: done,
      label: title,
      onTapHint: done ? l10n.dotMarkNotDoneHint : l10n.dotMarkDoneHint,
      onTap: onTap,
      excludeSemantics: true,
      // Focusable: Tab and the arrows reach it, Space or Return toggles it
      // (E-Earlier frame 8, M19.5).
      child: InkResponse(
        onTap: onTap,
        radius: DotTouch.android / 2,
        customBorder: const CircleBorder(),
        child: SizedBox.square(
          dimension: DotTouch.android,
          child: _linked(
            Center(
              child: AnimatedContainer(
                duration: t.motion.base,
                curve: t.motion.curve,
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? swatch.color : null,
                  border: done
                      ? null
                      : Border.all(
                          color: live ? swatch.color : t.colors.ring,
                          width: DotSize.doneRing,
                        ),
                ),
                child: done
                    ? Center(
                        child: DotIcon(
                          DotGlyphs.check,
                          color: swatch.check,
                          // A 15 check in the 28 circle (E rules §6).
                          size: size * 15 / 28,
                          bold: true,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _linked(Widget child) {
    final link = this.link;
    return link == null
        ? child
        : CompositedTransformTarget(link: link, child: child);
  }
}

/// The ring that fades outward from a done circle as it is marked done
/// (the onboarding prototype's `.burst`, ED-490): 3 wide in [color], from
/// the circle to 2.1 times its size and transparent over 500 ms,
/// ease-out. Drawn in the overlay at the circle, so it outlives the row
/// (the task under way becomes a plain row once done). Not with Reduce
/// Motion.
void showDoneBurst(BuildContext context, Color color) {
  if (DotTheme.of(context).motion.isReduced) return;
  final overlay = Overlay.maybeOf(context);
  final box = context.findRenderObject() as RenderBox?;
  final over = overlay?.context.findRenderObject() as RenderBox?;
  if (overlay == null || box == null || over == null || !box.hasSize) return;
  final centre = box.localToGlobal(
    box.size.center(Offset.zero),
    ancestor: over,
  );
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) =>
        _Burst(centre: centre, color: color, onDone: () => entry.remove()),
  );
  overlay.insert(entry);
}

class _Burst extends StatefulWidget {
  const _Burst({
    required this.centre,
    required this.color,
    required this.onDone,
  });

  final Offset centre;
  final Color color;
  final VoidCallback onDone;

  @override
  State<_Burst> createState() => _BurstState();
}

/// A leaf: only its one run.
class _BurstState extends State<_Burst> with SingleTickerProviderStateMixin {
  late final _run = AnimationController(
    vsync: this,
    duration: DotMotion.doneBurst,
  );

  @override
  void initState() {
    super.initState();
    _run.forward().whenComplete(widget.onDone).ignore();
  }

  @override
  void dispose() {
    _run.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const d = DotSize.doneCircle;
    final eased = CurvedAnimation(
      parent: _run,
      curve: DotMotion.doneBurstCurve,
    );
    return Positioned(
      left: widget.centre.dx - d / 2,
      top: widget.centre.dy - d / 2,
      width: d,
      height: d,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: eased,
          builder: (_, _) => Transform.scale(
            scale: 1 + (DotSize.doneBurstScale - 1) * eased.value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withValues(alpha: 1 - eased.value),
                  width: DotSize.doneBurstRing,
                  // Outside the circle, as `box-shadow: 0 0 0 3px` draws it.
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
