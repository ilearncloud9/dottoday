import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:dottoday/features/timeline/wake_up/mission/dawn_sky_scope.dart';
import 'package:flutter/material.dart';

/// "Can't right now" (docs/15 §8 rule 3): always on the mission screen;
/// held for [missionSkipHold] it skips the mission. A hold shows its
/// progress as a fill from the first touch; letting go early does
/// nothing. A screen reader's long-press action starts the same hold.
class CantRightNow extends StatefulWidget {
  const CantRightNow({required this.onSkip, super.key});

  final VoidCallback onSkip;

  @override
  State<CantRightNow> createState() => _CantRightNowState();
}

class _CantRightNowState extends State<CantRightNow>
    with SingleTickerProviderStateMixin {
  late final _hold = AnimationController(vsync: this, duration: missionSkipHold)
    ..addStatusListener(_done);

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  void _done(AnimationStatus status) {
    if (status == AnimationStatus.completed) widget.onSkip();
  }

  void _start() => unawaited(_hold.forward());

  void _stop() {
    if (_hold.isCompleted) return;
    _hold.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final foot = DawnSkyScope.of(context).foot;
    return Semantics(
      button: true,
      label: l10n.missionCantNow,
      hint: l10n.missionCantNowHint,
      excludeSemantics: true,
      // A screen reader's long press starts the same hold.
      onLongPress: _start,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => _start(),
        onPointerUp: (_) => _stop(),
        onPointerCancel: (_) => _stop(),
        // The dawn sky's outlined pill (E-R2-19-B); the hold fills it from
        // the start edge, and "Hold for 5 seconds" sits under it, in the
        // sky's foot ink (DawnSky.foot: dark on the light dawn, white on
        // the dark one).
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: DotSpace.xs,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: DotTouch.min),
              decoration: ShapeDecoration(
                shape: StadiumBorder(
                  side: BorderSide(
                    color: foot,
                    width: DotSpace.xxs - DotSpace.hairline / 2,
                  ),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: AnimatedBuilder(
                animation: _hold,
                builder: (context, child) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        DotDawn.track,
                        DotDawn.track,
                        Colors.transparent,
                      ],
                      stops: [0, _hold.value, _hold.value],
                    ),
                  ),
                  child: child,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DotSpace.l + DotSpace.xxs,
                    vertical: DotSpace.s,
                  ),
                  child: Text(
                    l10n.missionCantNow,
                    style: t.styles.chip.copyWith(color: foot),
                  ),
                ),
              ),
            ),
            Text(
              l10n.missionCantNowHint,
              style: t.styles.gridMeta.copyWith(color: foot),
            ),
          ],
        ),
      ),
    );
  }
}
