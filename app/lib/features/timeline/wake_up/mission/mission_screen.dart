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
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:dottoday/domain/wake_up/mission_sensors.dart';
import 'package:dottoday/features/timeline/wake_up/mission/breathe_mission.dart';
import 'package:dottoday/features/timeline/wake_up/mission/cant_right_now.dart';
import 'package:dottoday/features/timeline/wake_up/mission/catch_dot_mission.dart';
import 'package:dottoday/features/timeline/wake_up/mission/dawn_parts.dart';
import 'package:dottoday/features/timeline/wake_up/mission/dawn_sky_scope.dart';
import 'package:dottoday/features/timeline/wake_up/mission/dawn_walker.dart';
import 'package:dottoday/features/timeline/wake_up/mission/one_thing_mission.dart';
import 'package:dottoday/features/timeline/wake_up/mission/sensor_mission.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

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
  /// What runs here: on a tablet (a shortest side of 600 or more, the rule
  /// the device list uses) a movement mission falls back to Breathe
  /// (ED-336, ED-454).
  MissionKind get _kind => tabletMission(
    widget.kind,
    tablet: MediaQuery.sizeOf(context).shortestSide >= WidthClass.mediumFrom,
  );

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
    _caught.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final sensors = ref.read(missionSensorsProvider);
    final runs =
        !await sensors.driving() &&
        await sensors.support(_kind) == MissionSupport.ready;
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

  /// Catch the dot's catches, shared by its dots and its hint.
  final _caught = ValueNotifier(0);

  /// Walk is done: the walker stands with its check for a moment before
  /// the morning goes on (E-R2-19-B `wk-done`).
  var _walked = false;

  /// Light: the room is bright enough now (`ms-lit`).
  var _lit = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;
    final settings = profile?.settings;
    final steps = settings?.missionSteps ?? 20;
    // The sky is dark in either mode: the mission reads in the app's dark
    // theme, its App colour in its dark-surface shade (E-R2-19-B); dark
    // mode only deepens the dawn (E-R2-19-B-Dark, ED-459), so the app's
    // own brightness is read here, before that theme.
    final sky = DawnSky.of(Theme.of(context).brightness);
    final dark = DotTheme.forApp(
      Brightness.dark,
      accentKey: settings?.accent,
      accentHex: profile?.accentHex,
      platform: Theme.of(context).platform,
    );
    return DawnSkyScope(
      sky: sky,
      child: Theme(
        data: dark,
        child: Builder(
          builder: (context) => Scaffold(
            body: !_ready || profile == null
                ? DecoratedBox(
                    decoration: BoxDecoration(gradient: sky.gradient),
                    child: const SizedBox.expand(),
                  )
                : _dawn(context, profile, steps),
          ),
        ),
      ),
    );
  }

  Widget _dawn(BuildContext context, Profile profile, int steps) {
    void done() => unawaited(_end());
    final catching = _kind == MissionKind.catchDot;
    return DawnScaffold(
      time: timeOfUtc(
        context,
        tz.getLocation(profile.tzId),
        ref.read(clockProvider).nowUtc(),
        use24h: use24hFor(context, profile.settings.use24h),
      ),
      title: _line(context.l10n, steps),
      mission: catching
          ? CatchDotHint(caught: _caught, onDone: done)
          : _mission(steps),
      over: catching ? CatchDotField(caught: _caught, onDone: done) : null,
      ground: switch (_kind) {
        MissionKind.walk => DawnWalker(done: _walked),
        MissionKind.light => DawnRoomLight(level: _lit ? 1 : 0),
        _ => null,
      },
      cantRightNow: CantRightNow(onSkip: () => unawaited(_end(skipped: true))),
    );
  }

  /// Walk's last step: the walker stands with its check, then the morning
  /// goes on; with reduced motion it goes on at once.
  void _walkedIt() {
    setState(() => _walked = true);
    if (DotTheme.of(context).motion.isReduced) {
      unawaited(_end());
      return;
    }
    unawaited(Future<void>.delayed(DotDawnMotion.walkDone).then((_) => _end()));
  }

  String _line(AppLocalizations l10n, int steps) => switch (_kind) {
    MissionKind.standUp => l10n.missionLineStandUp,
    MissionKind.walk => l10n.missionLineWalk(steps),
    MissionKind.light => l10n.missionLineLight,
    MissionKind.breathe => l10n.missionLineBreathe,
    MissionKind.catchDot => l10n.missionLineCatchDot(catchTaps),
    MissionKind.oneThing => l10n.oneThingAsk,
  };

  Widget _mission(int steps) {
    void done() => unawaited(_end());
    return switch (_kind) {
      MissionKind.breathe => BreatheMission(onDone: done),
      MissionKind.oneThing => OneThingMission(onDone: done),
      _ => SensorMission(
        kind: _kind,
        steps: steps,
        sensors: ref.read(missionSensorsProvider),
        onDone: _kind == MissionKind.walk ? _walkedIt : done,
        onUnavailable: done,
        onLit: (lit) => setState(() => _lit = lit),
      ),
    };
  }
}
