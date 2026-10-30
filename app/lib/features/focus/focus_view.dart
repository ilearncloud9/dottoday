import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/focus/focus_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/scheduling/learning_meta.dart';
import 'package:dottoday/data/scheduling/learning_providers.dart';
import 'package:dottoday/data/tasks/task_view.dart';
import 'package:dottoday/domain/focus/focus_state.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/features/focus/focus_actions.dart';
import 'package:dottoday/features/focus/focus_deep_work.dart';
import 'package:dottoday/features/focus/focus_parts.dart';
import 'package:dottoday/shared/dot/focus_ring.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/sounds/sound_preview.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

/// Focus on one dot (11 A3, `B-ios-focus`, docs/09 M10.5): the 160 px
/// ring, "9:00 – 11:00 · 2 h", the title, "38 min left", the current step
/// with its own timer, the step thread, "Chime every 15 min" and "Deep
/// work", Done / +15 min / Next step, and the note that dot starts still
/// break through. Opening it marks the dot started (B1). [onLeave] goes
/// back (the route pops on phones; the content area closes on Mac/web).
class FocusView extends ConsumerStatefulWidget {
  const FocusView({required this.id, required this.onLeave, super.key});

  final String id;
  final VoidCallback onLeave;

  /// How often the chime sounds when it is on (11 A3 "every N min").
  static const chimeEvery = Duration(minutes: 15);

  @override
  ConsumerState<FocusView> createState() => _FocusViewState();
}

class _FocusViewState extends ConsumerState<FocusView> {
  late DateTime _now = ref.read(clockProvider).nowUtc();
  Timer? _tick;
  Timer? _chime;
  late final _resume = AppLifecycleListener(
    // Back from Settings: notification-policy access may have changed.
    onResume: () => ref.invalidate(deepWorkStatusProvider),
  );

  FocusActions get _actions => FocusActions(ref);

  @override
  void initState() {
    super.initState();
    _resume;
    // Step timers count seconds.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = ref.read(clockProvider).nowUtc());
    });
    unawaited(_actions.opened(widget.id));
  }

  @override
  void dispose() {
    _tick?.cancel();
    _chime?.cancel();
    _resume.dispose();
    super.dispose();
  }

  /// Starts or stops the interval chime to match the setting.
  void _syncChime(bool on) {
    if (on == (_chime != null)) return;
    _chime?.cancel();
    _chime = on
        ? Timer.periodic(
            FocusView.chimeEvery,
            // Sounds in app off: no tick (docs/12 §2.6).
            (_) => playAppSound(ref, resolveSound(focusTickSoundId)),
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    _syncChime(ref.watch(focusChimeProvider).value ?? false);
    final view = ref.watch(taskViewProvider(widget.id));
    return switch (view) {
      AsyncValue(hasValue: true, value: final TaskView task) => _content(
        context,
        task,
      ),
      AsyncData(value: null) ||
      AsyncError() => Center(child: Text(context.l10n.sheetNotFound)),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _content(BuildContext context, TaskView view) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final task = view.occurrence;
    final state = focusAt(
      task,
      view.subtasks,
      _now,
      learning: ref.watch(learningIndexProvider).value,
    );
    final step = state.step;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            DotSpace.page,
            DotSpace.s,
            DotSpace.page,
            DotSpace.xl,
          ),
          children: [
            _TopBar(id: widget.id, onLeave: widget.onLeave),
            const SizedBox(height: DotSpace.xl),
            Center(
              child: FocusRing(
                progress: state.progress,
                color: TaskColor.fromKey(task.colorKey),
                icon: TaskIcon.fromKey(task.iconKey),
              ),
            ),
            const SizedBox(height: DotSpace.xl),
            Text(
              _range(context, view),
              textAlign: TextAlign.center,
              style: t.styles.body.copyWith(color: t.colors.muted),
            ),
            Semantics(
              header: true,
              child: Text(
                task.title,
                textAlign: TextAlign.center,
                style: t.styles.pageTitle,
              ),
            ),
            Text(
              l10n.liveMinutesLeft(state.minutesLeft),
              textAlign: TextAlign.center,
              style: t.styles.topBarTitle.copyWith(color: t.colors.accentInk),
            ),
            const SizedBox(height: DotSpace.xl),
            if (state.steps.isNotEmpty) ...[
              FocusStepCard(
                state: state,
                taskTitle: task.title,
                onResetLearning: () => ref
                    .read(learningMetaProvider.notifier)
                    .resetUndoable(
                      task.title,
                      ref.read(clockProvider).nowUtc(),
                    ),
              ),
              const SizedBox(height: DotSpace.l),
              FocusStepThread(state: state),
              const SizedBox(height: DotSpace.l),
            ],
            _toggles(context, task.endUtc),
            const SizedBox(height: DotSpace.xl),
            FilledButton.icon(
              onPressed: () => unawaited(_done(context, view)),
              icon: DotIcon(DotGlyphs.check, color: t.colors.onAccent),
              label: Text(l10n.liveDone),
            ),
            const SizedBox(height: DotSpace.s),
            Row(
              spacing: DotSpace.s,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => unawaited(_actions.extend(context, task)),
                    child: Text(l10n.liveExtend),
                  ),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: step == null
                        ? null
                        : () => unawaited(_actions.nextStep(context, step)),
                    iconAlignment: IconAlignment.end,
                    icon: DotIcon(
                      DotGlyphs.chevronRight,
                      color: step == null ? t.colors.muted : t.colors.text,
                      size: DotSize.rowIcon,
                    ),
                    label: Text(l10n.focusNextStep),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DotSpace.l),
            Text(
              l10n.focusBreakThrough,
              textAlign: TextAlign.center,
              style: t.styles.caption.copyWith(color: t.colors.muted),
            ),
          ],
        ),
      ),
    );
  }

  /// The two toggles side by side (`B-ios-focus`); stacked at large text
  /// sizes, where side by side would squeeze them (§5.4).
  Widget _toggles(BuildContext context, DateTime? endUtc) {
    final l10n = context.l10n;
    final chime = ref.watch(focusChimeProvider).value ?? false;
    final toggles = [
      FocusToggle(
        glyph: DotGlyphs.bell,
        label: l10n.focusChime,
        value: chime,
        onChanged: (on) =>
            unawaited(ref.read(focusChimeProvider.notifier).set(on: on)),
      ),
      DeepWorkToggle(untilUtc: endUtc),
    ];
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) > _sideBySideMaxScale;
    if (stacked) {
      return Column(spacing: DotSpace.s, children: toggles);
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.s,
        children: [for (final t in toggles) Expanded(child: t)],
      ),
    );
  }

  /// Text scale from which the toggles stack (as the duration chips, M3c).
  static const double _sideBySideMaxScale = 1.3;

  Future<void> _done(BuildContext context, TaskView view) async {
    await _actions.done(context, view.occurrence);
    if (mounted) widget.onLeave();
  }

  /// "9:00 – 11:00 · 2 h".
  String _range(BuildContext context, TaskView view) {
    final o = view.occurrence;
    final start = o.startUtc;
    final end = o.endUtc;
    final length = formatDurationShort(context.l10n, o.durationMin);
    if (start == null || end == null) return length;
    final zone = tz.getLocation(o.tzId);
    final use24h = use24hFor(
      context,
      ref.watch(currentProfileProvider).value?.settings.use24h,
    );
    String at(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    return context.l10n.focusRange(
      context.l10n.threadTimeRange(at(start), at(end)),
      length,
    );
  }
}

/// "‹ Today", "FOCUS", and ⋯ with Task details.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.id, required this.onLeave});

  final String id;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Row(
      children: [
        TextButton.icon(
          onPressed: onLeave,
          icon: DotIcon(DotGlyphs.chevronLeft, color: t.colors.accentInk),
          label: Text(l10n.focusBack),
        ),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              l10n.focusTitle.toUpperCase(),
              textAlign: TextAlign.center,
              style: t.styles.caption,
            ),
          ),
        ),
        PopupMenuButton<void>(
          tooltip: l10n.focusMore,
          icon: DotIcon(DotGlyphs.more, color: t.colors.text),
          itemBuilder: (_) => [
            PopupMenuItem(
              onTap: () => openTask(
                context,
                id,
                otherwise: () =>
                    unawaited(GoRouter.of(context).push(AppRoutes.task(id))),
              ),
              child: Text(l10n.focusOpenTask),
            ),
          ],
        ),
      ],
    );
  }
}
