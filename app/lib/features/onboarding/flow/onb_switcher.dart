import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Changing step (prototype `.view.enter` / `.exit`; motion table): the
/// new step rises 18 and fades in over 420 ms, emphasized decelerate,
/// while the old one leaves 12 up, emphasized accelerate, gone by 260 ms.
/// [back] reverses it: in from 14 above, out 14 down. Reduce Motion: a
/// 200 ms cross-fade.
class OnbSwitcher extends StatelessWidget {
  const OnbSwitcher({required this.child, required this.back, super.key});

  /// Keyed by its step, so a new key is a new step.
  final Widget child;
  final bool back;

  @override
  Widget build(BuildContext context) {
    final reduced = DotTheme.of(context).motion.isReduced;
    return AnimatedSwitcher(
      duration: reduced ? OnbMotion.fade : OnbMotion.stepIn,
      reverseDuration: reduced ? OnbMotion.fade : OnbMotion.stepOut,
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, ?current]),
      transitionBuilder: (step, animation) {
        if (reduced) return FadeTransition(opacity: animation, child: step);
        final incoming = step.key == child.key;
        final eased = CurvedAnimation(
          parent: animation,
          curve: OnbMotion.decelerate,
          reverseCurve: OnbMotion.accelerate.flipped,
        );
        // Incoming starts below (above on Back); outgoing ends above
        // (below on Back).
        final from = incoming
            ? (back ? -OnbMotion.riseBack : OnbMotion.rise)
            : (back ? OnbMotion.leaveBack : -OnbMotion.leave);
        return AnimatedBuilder(
          animation: eased,
          // Leaving steps take no taps (`.view.exit{pointer-events:none}`).
          builder: (_, child) => IgnorePointer(
            ignoring: !incoming,
            child: Opacity(
              opacity: eased.value.clamp(0, 1),
              child: Transform.translate(
                offset: Offset(0, (1 - eased.value) * from),
                child: child,
              ),
            ),
          ),
          child: step,
        );
      },
      child: child,
    );
  }
}
