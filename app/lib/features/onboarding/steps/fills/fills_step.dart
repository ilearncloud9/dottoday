import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/onboarding/later_cards_store.dart';
import 'package:dottoday/data/onboarding/onboarding_actions.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/onboarding/day_fills.dart';
import 'package:dottoday/features/onboarding/flow/onb_buttons.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_add.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_chips.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_day_thread.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_draft.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_flight.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_look.dart';
import 'package:dottoday/shared/haptics/app_haptics.dart';
import 'package:dottoday/shared/text/balanced_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What fills your days? (prototype `vRhythm`, `mountRhythm`; ED-305,
/// ED-485, ED-488): your day as a thread from Wake Up to Wind Down with
/// NOW; four chips and "Add your own"; each pick flies onto the thread at
/// a time that fits. "That's my day" saves the picks as tasks that repeat
/// every day; with none it reads "Skip for now".
class FillsStep extends ConsumerStatefulWidget {
  const FillsStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  ConsumerState<FillsStep> createState() => _FillsStepState();
}

class _FillsStepState extends ConsumerState<FillsStep>
    with TickerProviderStateMixin {
  final _text = TextEditingController();
  final _focus = FocusNode();
  final _stack = GlobalKey();
  final _addDot = GlobalKey();
  final _chipDots = <String, GlobalKey>{};
  final _rowDots = <String, GlobalKey>{};
  late final _fly = AnimationController(vsync: this, duration: OnbMotion.fly);
  late final _land = AnimationController(vsync: this, duration: OnbMotion.land);
  Flight? _flight;
  String? _landing;
  var _saving = false;

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    _fly.dispose();
    _land.dispose();
    super.dispose();
  }

  GlobalKey _key(Map<String, GlobalKey> keys, String id) =>
      keys.putIfAbsent(id, GlobalKey.new);

  /// The chip's dot (or the add field's, [from]) flies onto [id]'s row;
  /// with Reduce Motion the row fades in.
  void _arrive(String id, Color color, {GlobalKey? from}) {
    if (DotTheme.of(context).motion.isReduced) {
      _land.duration = OnbMotion.fade;
      setState(() => _landing = id);
      unawaited(_land.forward(from: 0));
      return;
    }
    _land.duration = OnbMotion.land;
    setState(() => _flight = Flight(id: id, color: color));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _flight?.id != id) return;
      final route = flightRoute(
        _stack,
        from ?? _key(_chipDots, id),
        _key(_rowDots, id),
      );
      if (route == null) return setState(() => _flight = null);
      setState(() => _flight = _flight!.along(route));
      unawaited(
        _fly.forward(from: 0).whenComplete(() {
          if (!mounted || _flight?.id != id) return;
          setState(() {
            _flight = null;
            _landing = id;
          });
          unawaited(_land.forward(from: 0));
        }),
      );
    });
  }

  void _tap(DayFill fill, Color color) {
    AppHaptics.play(context, HapticTick.selection);
    final draft = ref.read(fillsDraftProvider);
    final on = draft.picked.contains(fill.id);
    ref.read(fillsDraftProvider.notifier).toggle(fill.id);
    if (on) {
      if (_flight?.id == fill.id) setState(() => _flight = null);
      return;
    }
    _arrive(fill.id, color);
  }

  void _add(Profile profile, FillsDay day, List<DayFill> picked) {
    final fill = typedFill(
      context,
      _text.text,
      profile: profile,
      nowUtc: ref.read(clockProvider).nowUtc(),
      wake: day.wake,
      wind: day.wind,
      taken: [for (final f in picked) f.minuteOn(day.wake, day.wind)],
      used: [for (final f in _chips(context)) f.colorKey],
    );
    if (fill == null) return;
    ref.read(fillsDraftProvider.notifier).add(fill);
    _text.clear();
    final color = DotTheme.of(
      context,
    ).tasks[TaskColor.fromKey(fill.colorKey)].ring;
    _arrive(fill.id, color, from: _addDot);
    if (!ref.read(fillsDraftProvider).full) _focus.requestFocus();
  }

  Future<void> _done(List<DayFill> picked) async {
    if (_saving) return;
    final draft = ref.read(fillsDraftProvider);
    final all = _chips(context);
    final gone = [
      for (final f in all)
        if (draft.planted.contains(f.id) && !draft.picked.contains(f.id)) f,
    ];
    if (picked.isEmpty && gone.isEmpty) return widget.onNext();
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    _saving = true;
    final result = await plantFills(
      ProviderScope.containerOf(context, listen: false),
      picked,
      gone: gone,
    );
    _saving = false;
    if (!mounted) return;
    if (result case Err(:final failure)) {
      // Stay on the step: nothing was written.
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
      return;
    }
    ref.read(fillsDraftProvider.notifier).saved(picked.map((f) => f.id));
    unawaited(
      ref.read(laterCardsProvider.notifier).addHabits(picked.map((f) => f.id)),
    );
    widget.onNext();
  }

  /// The four, then what was typed.
  List<DayFill> _chips(BuildContext context) =>
      draftChips(context.l10n, ref.read(fillsDraftProvider));

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final profile = ref.watch(currentProfileProvider).value;
    final draft = ref.watch(fillsDraftProvider);
    if (profile == null) return const SizedBox.shrink();
    final day = FillsDay.of(profile, ref.watch(clockProvider).nowUtc());
    final chips = _chips(context);
    final picked = [
      for (final f in chips)
        if (draft.picked.contains(f.id)) f,
    ];
    Color color(DayFill f) => t.tasks[TaskColor.fromKey(f.colorKey)].ring;
    final look = fieldLook(
      context,
      _text.text,
      profile,
      ref.watch(clockProvider).nowUtc(),
    );
    return LayoutBuilder(
      builder: (context, box) => Stack(
        key: _stack,
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: OnbSize.titleTop),
                    Semantics(
                      header: true,
                      child: BalancedText(
                        l10n.onboardingHabitsTitle,
                        style: t.styles.onbTitle,
                        textAlign: TextAlign.start,
                        maxWidth: box.maxWidth,
                      ),
                    ),
                    const SizedBox(height: OnbSize.subTop),
                    Text(l10n.onboardingHabitsBody, style: t.styles.onbSub),
                    const SizedBox(height: OnbSize.fillsTop),
                    Expanded(
                      child: FillsDayThread(
                        day: day,
                        picked: picked,
                        color: color,
                        width: box.maxWidth,
                        dotKey: (id) => _key(_rowDots, id),
                        land: _land,
                        flying: _flight?.id,
                        landing: _landing,
                      ),
                    ),
                    const SizedBox(height: OnbSize.chipsTop),
                    FillsChips(
                      full: draft.full,
                      dotKeys: {
                        for (final f in chips) f.id: _key(_chipDots, f.id),
                      },
                      chips: [
                        for (final f in chips)
                          (
                            id: f.id,
                            title: f.title,
                            color: color(f),
                            glyph: TaskIcon.fromKey(f.iconKey).glyph,
                            picked: draft.picked.contains(f.id),
                          ),
                      ],
                      onTap: (id) {
                        final f = chips.firstWhere((c) => c.id == id);
                        _tap(f, color(f));
                      },
                    ),
                    const SizedBox(height: OnbSize.chipsBottom),
                    FillsAdd(
                      controller: _text,
                      focus: _focus,
                      dotKey: _addDot,
                      color: t.tasks[TaskColor.fromKey(look.colorKey)].ring,
                      glyph: TaskIcon.fromKey(look.iconKey).glyph,
                      count: draft.picked.length,
                      full: draft.full,
                      onAdd: () => _add(profile, day, picked),
                    ),
                    const SizedBox(height: OnbSize.addBottom),
                    OnbPrimary(
                      label: draft.picked.isEmpty
                          ? l10n.onboardingSkipForNow
                          : l10n.onboardingFillsDone,
                      onPressed: () => unawaited(_done(picked)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: FlightLayer(flight: _flight, progress: _fly),
            ),
          ),
        ],
      ),
    );
  }
}
