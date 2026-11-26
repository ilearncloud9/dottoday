import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/first_today/first_today_rise.dart';
import 'package:flutter/material.dart';

/// "Tap the circle when it's done" (the prototype's `.hint`, ED-490): a
/// dark pill just under the hinted task's done circle ([link]), its arrow
/// pointing up at the circle and the pill ending 20 past it, so the row's
/// words stay clear (the circle is at the row's end, where the prototype's
/// dot was at its start); it rises in at 1.1 s, is announced once, and
/// once [gone] leaves 6 up over 400 ms. Drawn in the overlay, above the
/// rows; it takes no taps.
class FirstTodayHint extends StatefulWidget {
  const FirstTodayHint({
    required this.link,
    required this.gone,
    required this.child,
    super.key,
  });

  final LayerLink link;
  final bool gone;

  /// What the hint floats over (the day).
  final Widget child;

  @override
  State<FirstTodayHint> createState() => _FirstTodayHintState();
}

/// A leaf: only the overlay's controller.
class _FirstTodayHintState extends State<FirstTodayHint> {
  final _portal = OverlayPortalController()..show();

  @override
  Widget build(BuildContext context) => OverlayPortal(
    controller: _portal,
    overlayChildBuilder: (_) => _pill(context),
    child: widget.child,
  );

  Widget _pill(BuildContext context) {
    final t = DotTheme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: widget.link,
        showWhenUnlinked: false,
        // Under the circle (28 in a 44 target), the arrow's tip 6 below
        // its ring and under its centre, the pill's corner past it.
        targetAnchor: Alignment.bottomCenter,
        followerAnchor: rtl ? Alignment.topLeft : Alignment.topRight,
        offset: Offset(
          (rtl ? -1 : 1) * (OnbSize.hint / 2),
          OnbSize.hintGap - (DotTouch.android - DotSize.doneCircle) / 2,
        ),
        child: IgnorePointer(
          child: AnimatedOpacity(
            opacity: widget.gone ? 0 : 1,
            duration: OnbMotion.hintLeave,
            child: AnimatedSlide(
              offset: widget.gone
                  ? const Offset(0, -OnbSize.hintLeave / OnbSize.hint)
                  : Offset.zero,
              duration: OnbMotion.hintLeave,
              child: FirstTodayRise(
                delay: OnbMotion.hintStart,
                child: Semantics(
                  liveRegion: true,
                  child: _Pill(
                    text: context.l10n.firstTodayHint,
                    colors: t.colors,
                    style: t.styles.onbHint,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The pill and its arrow, in the toast colours.
class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.colors, required this.style});

  final String text;
  final DotColors colors;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      // The arrow under the circle's centre: half a pill's height in.
      Padding(
        padding: const EdgeInsetsDirectional.only(
          end: OnbSize.hint / 2 - OnbSize.hintArrow,
        ),
        child: CustomPaint(
          size: const Size(OnbSize.hintArrow * 2, OnbSize.hintArrow),
          painter: _Arrow(colors.toast),
        ),
      ),
      Container(
        constraints: const BoxConstraints(minHeight: OnbSize.hint),
        padding: const EdgeInsets.symmetric(horizontal: OnbSize.hintPad),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.toast,
          borderRadius: BorderRadius.circular(OnbSize.hint / 2),
        ),
        child: Text(text, style: style.copyWith(color: colors.onToast)),
      ),
    ],
  );
}

/// The arrow up at the circle (`.hint::before`, turned to point at it).
class _Arrow extends CustomPainter {
  const _Arrow(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_Arrow old) => old.color != color;
}
