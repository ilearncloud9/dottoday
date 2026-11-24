import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:dottoday/features/timeline/wake_up/mission/dawn_parts.dart';
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
    with TickerProviderStateMixin {
  late final _ring = AnimationController(vsync: this)
    ..addStatusListener((_) => setState(() {}));

  /// The press under the fingertip as a hold begins (`msPress`).
  late final _press = AnimationController(
    vsync: this,
    duration: DotDawnMotion.press,
  );
  var _done = 0;
  var _out = false;

  /// A finger is on the ring now: the fingertip rests on it.
  var _down = false;

  /// The ring's size breathed out and in (`msBreath` .62 → 1).
  static const _small = 0.62;

  @override
  void dispose() {
    _ring.dispose();
    _press.dispose();
    super.dispose();
  }

  void _hold() {
    if (_out || _done >= breaths) return;
    if (!DotTheme.of(context).motion.isReduced) {
      unawaited(_press.forward(from: 0));
    }
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
            onPointerDown: (_) {
              setState(() => _down = true);
              _hold();
            },
            onPointerUp: (_) {
              setState(() => _down = false);
              unawaited(_release());
            },
            onPointerCancel: (_) {
              setState(() => _down = false);
              unawaited(_release());
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([_ring, _press]),
              // The ring grows as you breathe in and shrinks as you breathe
              // out, glowing as it fills (E-R2-19-B `msBreath`); reduced
              // motion: it keeps its size, the words lead.
              builder: (context, _) => DawnRing(
                progress: reduced ? (letGo ? 1 : 0) : _ring.value,
                fill: true,
                scale: reduced ? 1 : _small + (1 - _small) * _ring.value,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -DotSpace.l),
                      child: Text(
                        letGo
                            ? l10n.missionBreatheLetGo
                            : l10n.missionBreatheHold,
                        style: t.styles.dawnTitle,
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, DotSpace.xxl),
                      child: _Fingertip(
                        down: _down || !letGo,
                        press: _press.value,
                        still: reduced,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: DotSpace.m),
        Semantics(
          liveRegion: true,
          label: letGo ? l10n.missionBreatheLetGo : l10n.missionBreatheHold,
          child: Text(
            l10n.missionBreathCount((_done + 1).clamp(1, breaths), breaths),
            style: t.styles.dawnStatus.copyWith(
              color: t.colors.text.withValues(alpha: _statusAlpha),
            ),
          ),
        ),
      ],
    );
  }

  /// "Breath 1 of 3", a little softer (E-R2-19-B, .85).
  static const _statusAlpha = 0.85;
}

/// The board's fingertip on Breathe's ring (`ms-finger`, `ms-press`): it
/// rests on the ring while you hold and lifts away, fading, while you let
/// go; a soft press spreads under it as a hold begins.
class _Fingertip extends StatelessWidget {
  const _Fingertip({
    required this.down,
    required this.press,
    required this.still,
  });

  final bool down;

  /// The press ripple, 0–1.
  final double press;
  final bool still;

  /// Lifted: away down-right, a little larger, faint (`msFinger`).
  static const _lift = Offset(16, 22);
  static const _liftScale = 1.15;
  static const _liftAlpha = 0.35;

  /// The press grows to 1.6 as it fades (`msPress`).
  static const _pressGrow = 0.6;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: TweenAnimationBuilder<double>(
      tween: Tween(end: down ? 0 : 1),
      duration: still ? Duration.zero : DotDawnMotion.finger,
      curve: DotDawnMotion.ease,
      builder: (context, lifted, _) => Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          if (press > 0 && press < 1)
            Transform.scale(
              scale: 1 + _pressGrow * press,
              child: Container(
                width: DotSize.missionPress,
                height: DotSize.missionPress,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DotDawn.press.withValues(
                    alpha: DotDawn.press.a * (1 - press),
                  ),
                ),
              ),
            ),
          Transform.translate(
            offset: _lift * lifted,
            child: Transform.scale(
              scale: 1 + (_liftScale - 1) * lifted,
              child: Opacity(
                opacity: 1 - (1 - _liftAlpha) * lifted,
                child: const CustomPaint(
                  size: Size(
                    DotSize.missionFingerWidth,
                    DotSize.missionFingerHeight,
                  ),
                  painter: _FingerPainter(),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _FingerPainter extends CustomPainter {
  const _FingerPainter();

  /// The board's 20 × 28 box.
  static const _boxWidth = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / _boxWidth)
      ..drawPath(DotGlyphs.fingertip.path, Paint()..color = DotDawn.ink)
      ..drawPath(
        DotGlyphs.fingertip.path,
        Paint()
          ..color = DotDawn.dotShadow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_FingerPainter old) => false;
}
