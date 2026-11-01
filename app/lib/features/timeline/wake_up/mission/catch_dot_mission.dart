import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:flutter/material.dart';

/// Catch the dot (docs/15 §8): one dot drifts slowly round a loop
/// ([catchLoop]); [catchTaps] taps on it finish. A miss doesn't count and
/// nothing says so (no-shame rule). With reduced motion the dot holds
/// still and hops to the next spot after each catch. Screen readers get
/// one "Tap the dot" button that counts a catch.
class CatchDotMission extends StatefulWidget {
  const CatchDotMission({required this.onDone, super.key});

  final VoidCallback onDone;

  @override
  State<CatchDotMission> createState() => _CatchDotMissionState();
}

class _CatchDotMissionState extends State<CatchDotMission>
    with SingleTickerProviderStateMixin {
  late final _drift = AnimationController(vsync: this, duration: catchLoop);
  var _caught = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (DotTheme.of(context).motion.isReduced) {
      _drift.stop();
    } else if (!_drift.isAnimating) {
      _drift.repeat();
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  void _catch() {
    if (_caught >= catchTaps) return;
    setState(() => _caught++);
    if (_caught >= catchTaps) {
      _drift.stop();
      widget.onDone();
    }
  }

  /// Where the dot is on a slow figure-eight, 0–1 in each axis; reduced
  /// motion steps along it a fifth per catch instead.
  Offset _spot(double turn) {
    final a = 2 * math.pi * turn;
    return Offset(0.5 + 0.38 * math.sin(a), 0.5 + 0.3 * math.sin(2 * a));
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    const box = DotSize.missionRing * 2;
    const dot = DotSize.focusRing / 2;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: box,
          child: AnimatedBuilder(
            animation: _drift,
            builder: (context, _) {
              final turn = t.motion.isReduced
                  ? _caught / catchTaps
                  : _drift.value;
              final at = _spot(turn) * (box - dot);
              return Stack(
                children: [
                  Positioned(
                    left: at.dx,
                    top: at.dy,
                    child: Semantics(
                      button: true,
                      label: l10n.missionCatchTap,
                      child: GestureDetector(
                        onTap: _catch,
                        child: Container(
                          width: dot,
                          height: dot,
                          decoration: BoxDecoration(
                            color: t.tasks[TaskColor.violet].color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: DotSpace.m),
        Semantics(
          liveRegion: true,
          child: Text(
            l10n.missionCatchCount(_caught, catchTaps),
            style: t.styles.rowTitle,
          ),
        ),
      ],
    );
  }
}
