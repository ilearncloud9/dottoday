import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/features/onboarding/onboarding_flow.dart';
import 'package:dottoday/features/onboarding/steps/nudge/nudge_banner.dart';
import 'package:dottoday/features/onboarding/steps/nudge/nudge_scene.dart';
import 'package:dottoday/features/onboarding/steps/nudge/nudge_sheet.dart';
import 'package:dottoday/shared/haptics/app_haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A nudge, in context (prototype `vNudge`; ED-305, ED-489): the next
/// thing on your thread drops onto its time, a preview of its reminder
/// slides down, and only then the ask rises: "Want this before Read?",
/// Allow nudges or Not now. Allow nudges shows the system prompt; once
/// allowed, "Two more, if you like" offers the Wake Up alarm (on a phone
/// or tablet) and the Wind Down reminder, both off unless turned on, and
/// Done. Not now, or a no, goes to Today with both off.
class NudgeStep extends ConsumerStatefulWidget {
  const NudgeStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  ConsumerState<NudgeStep> createState() => _NudgeStepState();
}

class _NudgeStepState extends ConsumerState<NudgeStep>
    with SingleTickerProviderStateMixin {
  late final _in = AnimationController(vsync: this, duration: OnbMotion.nudge);
  final _allow = FocusNode();
  Timer? _focus;
  var _more = false;
  var _asking = false;
  var _landed = false;
  var _wake = false;
  var _wind = false;

  @override
  void initState() {
    super.initState();
    _in.addListener(_tap);
    _focus = Timer(OnbMotion.askFocus, () {
      if (mounted && !_more) _allow.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_in.isAnimating || _in.isCompleted) return;
    if (DotTheme.of(context).motion.isReduced) {
      // All three fade in at once (`.rm` … `animation: fade .2s`).
      _in.duration = OnbMotion.fade;
    }
    unawaited(_in.forward());
  }

  @override
  void dispose() {
    _focus?.cancel();
    _in.dispose();
    _allow.dispose();
    super.dispose();
  }

  /// A light tap as the subject lands (`CONFIRM` on Android).
  void _tap() {
    if (_landed || DotTheme.of(context).motion.isReduced) return;
    final at = OnbMotion.drop.inMilliseconds * OnbMotion.dropLand;
    if (_in.value * OnbMotion.nudge.inMilliseconds < at) return;
    _landed = true;
    AppHaptics.play(context, HapticTick.light);
  }

  Future<void> _ask() async {
    if (_asking) return;
    setState(() => _asking = true);
    final answer = await ref.read(notificationPermissionProvider).request();
    ref
      ..invalidate(notificationPermissionStateProvider)
      ..invalidate(alarmCapabilitiesNowProvider);
    if (!mounted) return;
    if (answer != PermissionState.granted) {
      return _finish(wake: false, wind: false);
    }
    setState(() {
      _asking = false;
      _more = true;
    });
  }

  /// Saves the Wake Up alarm and the Wind Down reminder as chosen (off
  /// unless turned on, ED-489), then Today. An alarm left on asks for
  /// alarms where the system needs it (iOS 26+, docs/15 §2).
  void _finish({required bool wake, required bool wind}) {
    final container = ProviderScope.containerOf(context, listen: false);
    unawaited(
      updateSettings(
        container,
        (s) => s.copyWith(wakeUpAlarm: wake, windDownReminder: wind),
      ),
    );
    if (wake) {
      unawaited(container.read(alarmGatewayProvider).requestAuthorization());
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();
    final scene = NudgeScene.of(
      context,
      ref,
      profile,
      ref.watch(clockProvider).nowUtc(),
    );
    final caps = ref.watch(alarmCapabilitiesNowProvider).value;
    final rings =
        caps != null && !caps.blockers.contains(AlarmBlocker.notAPhone);
    final card = onboardingInCard(MediaQuery.sizeOf(context));
    final android = scene.android;
    final bottomPad = card
        ? OnbSize.cardBottom
        : MediaQuery.viewPaddingOf(context).bottom.clamp(OnbSize.bottom, 1e9);
    final inset = card ? OnbSize.sheetInsetCard : OnbSize.sheetInset;
    final pad = card ? OnbSize.cardSide : OnbSize.side;
    final side = pad - inset;
    final banner = (card ? OnbSize.bannerSideCard : OnbSize.bannerSide) - pad;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          top: OnbSize.nudgeThreadTop,
          bottom: OnbSize.nudgeThreadBottom,
          child: scene.thread(_in),
        ),
        PositionedDirectional(
          start: banner,
          end: banner,
          top: card ? OnbSize.bannerOverlap : _phoneBannerTop(context),
          child: _Slide(
            play: _in,
            start: OnbMotion.bannerStart,
            length: OnbMotion.bannerIn,
            from: -OnbMotion.bannerFrom,
            hidden: _more,
            child: NudgeBanner(
              title: scene.bannerTitle,
              span: scene.span,
              when: scene.when,
              android: android,
            ),
          ),
        ),
        PositionedDirectional(
          start: -side,
          end: -side,
          bottom: inset - bottomPad,
          child: _Slide(
            play: _in,
            start: OnbMotion.sheetStart,
            length: OnbMotion.sheetIn,
            from: OnbMotion.sheetFrom,
            child: NudgeSheet(
              subject: scene.subjectTitle,
              more: _more,
              allowFocus: _allow,
              radius: card
                  ? OnbSize.sheetRadiusCard
                  : android
                  ? OnbSize.sheetRadiusAndroid
                  : OnbSize.sheetRadius,
              onAllow: _asking ? null : () => unawaited(_ask()),
              onNotNow: _asking
                  ? null
                  : () => _finish(wake: false, wind: false),
              onDone: () => _finish(wake: rings && _wake, wind: _wind),
              options: [
                if (rings)
                  (
                    glyph: DotGlyphs.onbSun,
                    glyphSize: OnbSize.sunGlyph - 4,
                    color: t.tasks[TaskColor.amber].ring,
                    title: l10n.settingsWakeUpAlarm,
                    line: l10n.onboardingRingsAt(scene.wakeTime),
                    on: _wake,
                    onChanged: (v) => setState(() => _wake = v),
                  ),
                (
                  glyph: DotGlyphs.onbMoon,
                  glyphSize: OnbSize.moonGlyph - 4,
                  color: t.tasks[TaskColor.indigo].ring,
                  title: l10n.settingsWindDownReminder,
                  line: l10n.onboardingNudgeAt(scene.windTime),
                  on: _wind,
                  onChanged: (v) => setState(() => _wind = v),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Slides [child] in from [from] of its height (negative: above) over
/// [length] from [start] in [play], emphasized decelerate, fading in; with
/// Reduce Motion it only fades (with [play], 200 ms). [hidden] fades it out.
class _Slide extends StatelessWidget {
  const _Slide({
    required this.play,
    required this.start,
    required this.length,
    required this.from,
    required this.child,
    this.hidden = false,
  });

  final Animation<double> play;
  final Duration start;
  final Duration length;
  final double from;
  final bool hidden;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduced = DotTheme.of(context).motion.isReduced;
    final body = AnimatedOpacity(
      opacity: hidden ? 0 : 1,
      duration: OnbMotion.fade,
      child: IgnorePointer(ignoring: hidden, child: child),
    );
    if (reduced) return FadeTransition(opacity: play, child: body);
    final total = OnbMotion.nudge.inMilliseconds;
    final a = start.inMilliseconds / total;
    final eased = CurvedAnimation(
      parent: play,
      curve: Interval(
        a,
        a + length.inMilliseconds / total,
        curve: OnbMotion.decelerate,
      ),
    );
    return AnimatedBuilder(
      animation: eased,
      builder: (_, child) => FractionalTranslation(
        translation: Offset(0, from * (1 - eased.value)),
        child: Opacity(
          // The banner fades in as it slides (`bannerIn` opacity 0); the
          // sheet only slides.
          opacity: from < 0 ? eased.value.clamp(0, 1) : 1,
          child: child,
        ),
      ),
      child: body,
    );
  }
}

/// On a phone the preview sits 4 over the top row, as drawn; with no
/// status bar above (a window, a test) it comes down just enough to keep
/// its PREVIEW tag on screen.
double _phoneBannerTop(BuildContext context) {
  final above =
      MediaQuery.viewPaddingOf(context).top + DotSpace.xs + OnbSize.nav;
  final drawn = -OnbSize.nav - OnbSize.bannerOverlap;
  final onScreen = OnbSize.previewTop - above;
  return drawn > onScreen ? drawn : onScreen;
}
