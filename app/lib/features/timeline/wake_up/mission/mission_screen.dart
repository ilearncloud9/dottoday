import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:dottoday/domain/wake_up/mission_sensors.dart';
import 'package:dottoday/features/timeline/wake_up/mission/breathe_mission.dart';
import 'package:dottoday/features/timeline/wake_up/mission/cant_right_now.dart';
import 'package:dottoday/features/timeline/wake_up/mission/catch_dot_mission.dart';
import 'package:dottoday/features/timeline/wake_up/mission/one_thing_mission.dart';
import 'package:dottoday/features/timeline/wake_up/mission/sensor_mission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A morning's mission (docs/15 §8), opened by "I'm up" (or iOS's Stop)
/// on a mission morning while the alarm waits to re-ring. It shows the
/// mission as one line, the mission itself and "Can't right now", the
/// same in minimal mode. Exits: done, or the 5-second skip (recorded),
/// both stopping the alarm and opening the Wake Up card. It steps aside
/// at once, unrecorded, while driving or when the sensor can't run
/// (rule 3). While it is open it pushes the re-ring out, so only a phone
/// left alone rings again.
class MissionScreen extends ConsumerStatefulWidget {
  const MissionScreen({required this.date, required this.kind, super.key});

  /// `yyyy-MM-dd`: the alarm is `wakeup:<date>`.
  final String date;
  final MissionKind kind;

  @override
  ConsumerState<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends ConsumerState<MissionScreen> {
  Timer? _keep;
  var _ready = false;
  var _ended = false;

  String get _alarmId => 'wakeup:${widget.date}'; // l10n-ignore: alarm id

  @override
  void initState() {
    super.initState();
    unawaited(_check());
  }

  @override
  void dispose() {
    _keep?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    final sensors = ref.read(missionSensorsProvider);
    final runs =
        !await sensors.driving() &&
        await sensors.support(widget.kind) == MissionSupport.ready;
    if (!mounted) return;
    if (!runs) return _end();
    setState(() => _ready = true);
    final gateway = ref.read(alarmGatewayProvider);
    unawaited(gateway.keepMission(_alarmId));
    _keep = Timer.periodic(
      missionKeepEvery,
      (_) => unawaited(gateway.keepMission(_alarmId)),
    );
  }

  /// Stops the alarm and opens the Wake Up card; a skip is recorded first.
  Future<void> _end({bool skipped = false}) async {
    if (_ended) return;
    _ended = true;
    _keep?.cancel();
    if (skipped) {
      await ref
          .read(wakeUpDayRepositoryProvider)
          .markMissionSkipped(widget.date, ref.read(clockProvider).nowUtc());
    }
    await ref.read(alarmGatewayProvider).dismiss(_alarmId);
    if (mounted) context.go(AppRoutes.wakeUp);
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final steps =
        ref.watch(currentProfileProvider).value?.settings.missionSteps ?? 20;
    return Scaffold(
      backgroundColor: t.colors.surface,
      body: SafeArea(
        child: !_ready
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.all(DotSpace.l),
                children: [
                  const SizedBox(height: DotSpace.xl),
                  Text(
                    _line(context.l10n, steps),
                    style: t.styles.pageTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DotSpace.xl),
                  Center(child: _mission(steps)),
                  const SizedBox(height: DotSpace.xl),
                  CantRightNow(onSkip: () => unawaited(_end(skipped: true))),
                ],
              ),
      ),
    );
  }

  String _line(AppLocalizations l10n, int steps) => switch (widget.kind) {
    MissionKind.standUp => l10n.missionLineStandUp,
    MissionKind.walk => l10n.missionLineWalk(steps),
    MissionKind.light => l10n.missionLineLight,
    MissionKind.breathe => l10n.missionLineBreathe,
    MissionKind.catchDot => l10n.missionLineCatchDot(catchTaps),
    MissionKind.oneThing => l10n.oneThingAsk,
  };

  Widget _mission(int steps) {
    void done() => unawaited(_end());
    return switch (widget.kind) {
      MissionKind.breathe => BreatheMission(onDone: done),
      MissionKind.catchDot => CatchDotMission(onDone: done),
      MissionKind.oneThing => OneThingMission(onDone: done),
      _ => SensorMission(
        kind: widget.kind,
        steps: steps,
        sensors: ref.read(missionSensorsProvider),
        onDone: done,
        onUnavailable: done,
      ),
    };
  }
}
