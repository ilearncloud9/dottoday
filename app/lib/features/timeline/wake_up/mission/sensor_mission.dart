import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/wake_up/mission_progress.dart';
import 'package:dottoday/domain/wake_up/mission_sensors.dart';
import 'package:dottoday/shared/dot/focus_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

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
    super.key,
  });

  final MissionKind kind;

  /// Walk's target.
  final int steps;
  final MissionSensors sensors;
  final VoidCallback onDone;
  final VoidCallback onUnavailable;

  @override
  State<SensorMission> createState() => _SensorMissionState();
}

class _SensorMissionState extends State<SensorMission> {
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
    super.dispose();
  }

  void _add(SensorReading reading) {
    final before = _progress?.value ?? 0;
    final progress = _tracker.add(reading);
    setState(() => _progress = progress);
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
    final p = _progress;
    final share = p == null || p.target == 0 ? 0.0 : p.value / p.target;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FocusRing(
          progress: share,
          color: TaskColor.amber,
          icon: switch (widget.kind) {
            MissionKind.walk => TaskIcon.walking,
            MissionKind.light => TaskIcon.lightBulb,
            _ => TaskIcon.standUp,
          },
          size: DotSize.missionRing,
        ),
        const SizedBox(height: DotSpace.m),
        Semantics(
          liveRegion: widget.kind != MissionKind.walk,
          child: Text(
            _status(context.l10n),
            style: t.styles.rowTitle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
