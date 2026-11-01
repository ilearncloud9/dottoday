import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.missionCantNow,
                style: t.styles.rowTitle.copyWith(color: t.colors.accentInk),
              ),
              Text(l10n.missionCantNowHint, style: t.styles.rowMeta),
              const SizedBox(height: DotSpace.xs),
              SizedBox(
                width: DotSize.missionRing,
                child: AnimatedBuilder(
                  animation: _hold,
                  builder: (context, _) => LinearProgressIndicator(
                    value: _hold.value,
                    color: t.colors.accentInk,
                    backgroundColor: t.colors.hairline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
