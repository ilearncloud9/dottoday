import 'dart:async';
import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/wake_up/mission_progress.dart';
import 'package:dottoday/domain/wake_up/mission_sensors.dart';
import 'package:dottoday/features/timeline/wake_up/mission/dawn_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';

/// Stand up, Walk and Light (docs/15 §8): the ring fills with the
/// tracker's progress from [sensors]' readings, with a text state below
/// it, so nothing relies on the ring alone. Walk's count is announced
/// every 5 steps. A sensor that fails mid-mission calls [onUnavailable].
class SensorMission extends StatefulWidget {
  const SensorMission({
    required this.kind,
    required this.steps,
    required this.sensors,
    required this.onDone,
    required this.onUnavailable,
    this.onLit,
    super.key,
  });

  /// Light: whether the room is bright enough now, for the sky's room
  /// light (E-R2-19-B `ms-lit`).
  final ValueChanged<bool>? onLit;

  final MissionKind kind;

  /// Walk's target.
  final int steps;
  final MissionSensors sensors;
  final VoidCallback onDone;
  final VoidCallback onUnavailable;

  @override
  State<SensorMission> createState() => _SensorMissionState();
}

class _SensorMissionState extends State<SensorMission>
    with SingleTickerProviderStateMixin {
  /// Walk's ring pulses on each step (E-R2-19-B `wkPulse`).
  late final _pulse = AnimationController(
    vsync: this,
    duration: DotDawnMotion.walkStep,
  );
  static final _pulseScale = TweenSequence([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: _pulsePeak,
      ).chain(CurveTween(curve: DotDawnMotion.easeOut)),
      weight: 30,
    ),
    TweenSequenceItem(tween: Tween(begin: _pulsePeak, end: 1.0), weight: 70),
  ]);

  /// The pulse's size at its peak (`wkPulse` 1.035).
  static const _pulsePeak = 1.035;

  late final MissionTracker _tracker = switch (widget.kind) {
    MissionKind.walk => WalkTracker(widget.steps),
    MissionKind.light => LightTracker(),
    _ => StandUpTracker(),
  };
  StreamSubscription<SensorReading>? _sub;
  MissionProgress? _progress;
  var _finished = false;

  @override
  void initState() {
    super.initState();
    _sub = widget.sensors
        .readings(widget.kind)
        .listen(_add, onError: (Object _) => _fail());
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    _pulse.dispose();
    super.dispose();
  }

  void _add(SensorReading reading) {
    final before = _progress?.value ?? 0;
    final wasLit = _tracker.holding;
    final progress = _tracker.add(reading);
    setState(() => _progress = progress);
    if (widget.kind == MissionKind.light && _tracker.holding != wasLit) {
      widget.onLit?.call(_tracker.holding);
    }
    if (widget.kind == MissionKind.walk &&
        progress.value > before &&
        !DotTheme.of(context).motion.isReduced) {
      unawaited(_pulse.forward(from: 0));
    }
    if (widget.kind == MissionKind.walk && progress.value ~/ 5 > before ~/ 5) {
      _announce(_status(context.l10n));
    }
    if (progress.done && !_finished) {
      _finished = true;
      widget.onDone();
    }
  }

  void _fail() {
    if (_finished) return;
    _finished = true;
    widget.onUnavailable();
  }

  void _announce(String text) => unawaited(
    SemanticsService.sendAnnouncement(
      View.of(context),
      text,
      Directionality.of(context),
    ),
  );

  String _status(AppLocalizations l10n) {
    final p = _progress;
    return switch (widget.kind) {
      MissionKind.walk => l10n.missionStepsProgress(
        p?.value ?? 0,
        widget.steps,
      ),
      MissionKind.light =>
        _tracker.holding ? l10n.missionLightBright : l10n.missionLightDark,
      _ when p == null || !_tracker.holding => l10n.missionUprightHint,
      _ => l10n.missionHoldProgress(p.value, p.target),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final p = _progress;
    final share = p == null || p.target == 0 ? 0.0 : p.value / p.target;
    final walk = widget.kind == MissionKind.walk;
    // In the ring (E-R2-19-B): Walk's count over "of 20 steps"; Stand up
    // the phone tilting upright, Light the bulb glowing, each over
    // "0 of 3 s". Under it, what to do.
    // The counts in the ring keep their display size, like the time (ED-459
    // option A): the ring doesn't grow, and the words under it do.
    final hold = Text(
      textScaler: TextScaler.noScaling,
      l10n.missionHoldProgress(
        p?.value ?? 0,
        p?.target ?? missionHold.inSeconds,
      ),
      style: t.styles.dawnCount,
    );
    final inside = walk
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                NumberFormat.decimalPattern(
                  Localizations.localeOf(context).toLanguageTag(),
                ).format(p?.value ?? 0),
                textScaler: TextScaler.noScaling,
                style: t.styles.dawnTime,
              ),
              Text(
                l10n.missionStepsOf(widget.steps),
                style: t.styles.smallChip,
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.s,
            children: [
              if (widget.kind == MissionKind.light)
                MissionBulb(lit: _tracker.holding)
              else
                MissionPhoneTilt(upright: _tracker.holding),
              hold,
            ],
          );
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.m,
      children: [
        Semantics(
          liveRegion: !walk,
          label: _status(l10n),
          excludeSemantics: true,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) => DawnRing(
              progress: share,
              scale: _pulse.isAnimating ? _pulseScale.evaluate(_pulse) : 1,
              child: child!,
            ),
            child: inside,
          ),
        ),
        if (!walk)
          ExcludeSemantics(
            child: Text(
              _status(l10n),
              style: t.styles.dawnStatus.copyWith(
                color: t.colors.ink.withValues(alpha: _statusAlpha),
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  /// What to do under the ring, a little softer (E-R2-19-B, .85).
  static const _statusAlpha = 0.85;
}

/// Stand up's phone (E-R2-19-B `ms-tilt`): an outlined phone that tilts
/// from flat to upright over and over, showing what to do, until it is
/// [upright]; then it stands. Reduced motion: it stands.
class MissionPhoneTilt extends StatefulWidget {
  const MissionPhoneTilt({required this.upright, super.key});

  final bool upright;

  @override
  State<MissionPhoneTilt> createState() => _MissionPhoneTiltState();
}

class _MissionPhoneTiltState extends State<MissionPhoneTilt>
    with SingleTickerProviderStateMixin {
  late final _tilt = AnimationController(
    vsync: this,
    duration: DotDawnMotion.settle,
  );

  /// Flat is -70° (`msTilt`).
  static const _flat = -70 * math.pi / 180;

  /// The board holds flat for the first fifth, then rises by 55 %.
  static const _rise = Interval(0.2, 0.55, curve: DotDawnMotion.ease);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(MissionPhoneTilt old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final show = !widget.upright && !DotTheme.of(context).motion.isReduced;
    if (show && !_tilt.isAnimating) _tilt.repeat();
    if (!show) _tilt.value = 1;
  }

  @override
  void dispose() {
    _tilt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedBuilder(
      animation: _tilt,
      builder: (context, child) => Transform.rotate(
        angle: _flat * (1 - _rise.transform(_tilt.value)),
        alignment: const Alignment(0, 0.8),
        child: child,
      ),
      child: Container(
        width: DotSize.missionPhoneWidth,
        height: DotSize.missionPhoneHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DotRadii.monthCard),
          border: Border.all(color: DotDawn.ink, width: DotSpace.xxs + 1),
        ),
      ),
    ),
  );
}

/// Light's bulb (E-R2-19-B `ms-glow`): its warm glow rises as the room
/// brightens and settles low while it is still too dark.
class MissionBulb extends StatelessWidget {
  const MissionBulb({required this.lit, super.key});

  final bool lit;

  /// The glow while dark, and lit (`msGlow` .15 → 1; drawn at .9).
  static const _dim = 0.15;
  static const _drawn = 0.9;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: TweenAnimationBuilder<double>(
      tween: Tween(end: lit ? 1 : _dim),
      duration: DotTheme.of(context).motion.isReduced
          ? Duration.zero
          : DotDawnMotion.glow,
      curve: DotDawnMotion.easeInOut,
      builder: (context, glow, _) => CustomPaint(
        size: const Size(DotSize.missionBulbWidth, DotSize.missionBulbHeight),
        painter: _BulbPainter(glow: glow * _drawn),
      ),
    ),
  );
}

class _BulbPainter extends CustomPainter {
  const _BulbPainter({required this.glow});

  final double glow;

  /// The board's 24 × 30 box.
  static const _boxWidth = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / _boxWidth;
    canvas
      ..save()
      ..scale(k)
      ..drawCircle(
        const Offset(12, 10),
        11,
        Paint()
          ..color = DotDawn.bulbGlow.withValues(alpha: glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )
      ..drawPath(
        DotGlyphs.bulb.path,
        Paint()
          ..color = DotDawn.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_BulbPainter old) => old.glow != glow;
}
