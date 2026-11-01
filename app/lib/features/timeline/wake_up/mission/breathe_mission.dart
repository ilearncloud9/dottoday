import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:dottoday/shared/dot/focus_ring.dart';
import 'package:flutter/material.dart';

/// Breathe (docs/15 §8): hold the ring while it fills over [breatheIn],
/// let go while it empties over [breatheOut], [breaths] times. There is
/// no way to fail: letting go early just empties the ring and it waits
/// for the next hold. "Hold" / "Let go" and the count say where you are,
/// so with reduced motion (the ring then jumps) or a screen reader it
/// still reads. The ring is the hold target; screen readers long-press it.
class BreatheMission extends StatefulWidget {
  const BreatheMission({required this.onDone, super.key});

  final VoidCallback onDone;

  @override
  State<BreatheMission> createState() => _BreatheMissionState();
}

class _BreatheMissionState extends State<BreatheMission>
    with SingleTickerProviderStateMixin {
  late final _ring = AnimationController(vsync: this)
    ..addStatusListener((_) => setState(() {}));
  var _done = 0;
  var _out = false;

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  void _hold() {
    if (_out || _done >= breaths) return;
    _ring.duration = breatheIn;
    unawaited(_ring.forward());
  }

  Future<void> _release() async {
    if (_out || _done >= breaths) return;
    final full = _ring.isCompleted;
    setState(() => _out = full);
    _ring.duration = full ? breatheOut : DotTheme.of(context).motion.base;
    await _ring.reverse().orCancel.catchError((Object _) {});
    if (!mounted || !full) return;
    setState(() {
      _out = false;
      _done++;
    });
    if (_done >= breaths) widget.onDone();
  }

  /// A screen reader's long press: one whole breath.
  Future<void> _breathe() async {
    _hold();
    await _ring.forward().orCancel.catchError((Object _) {});
    if (mounted) await _release();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final letGo = _out || _ring.isCompleted;
    final reduced = t.motion.isReduced;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: letGo ? l10n.missionBreatheLetGo : l10n.missionBreatheHold,
          onLongPress: () => unawaited(_breathe()),
          child: Listener(
            onPointerDown: (_) => _hold(),
            onPointerUp: (_) => unawaited(_release()),
            onPointerCancel: (_) => unawaited(_release()),
            child: AnimatedBuilder(
              animation: _ring,
              // Reduced motion: no growing ring; the words lead.
              builder: (context, _) => FocusRing(
                progress: reduced ? (letGo ? 1 : 0) : _ring.value,
                color: TaskColor.sky,
                icon: TaskIcon.lungs,
                size: DotSize.missionRing,
              ),
            ),
          ),
        ),
        const SizedBox(height: DotSpace.m),
        Semantics(
          liveRegion: true,
          child: Text(
            letGo ? l10n.missionBreatheLetGo : l10n.missionBreatheHold,
            style: t.styles.rowTitle,
          ),
        ),
        Text(
          l10n.missionBreathCount((_done + 1).clamp(1, breaths), breaths),
          style: t.styles.rowMeta,
        ),
      ],
    );
  }
}
