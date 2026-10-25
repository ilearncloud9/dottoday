import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/routines/routine_providers.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/features/routines/routine_flows.dart';
import 'package:dottoday/features/routines/widgets/routine_card.dart';
import 'package:dottoday/features/routines/widgets/routine_day_strip.dart';
import 'package:dottoday/shared/dot/count_ring.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

/// Routines (`B-ios-routines`, 11 C2, docs/09 M11.4): reusable slices of
/// thread, each with Drop on today and Edit; "New routine · or save a
/// selection from any day"; routine-start dots ring loud. Settings ›
/// Routines (reached from Settings › Planning, Today ⋯ and Add): a pushed
/// page on phones, the content area on Mac/web.
class RoutinesPage extends ConsumerWidget {
  const RoutinesPage({this.dropOn, super.key});

  /// The day "Drop on …" starts on (Today ⋯ on another day, Add's day);
  /// null: today. The week strip changes it.
  final DateTime? dropOn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);
    final list = routines.value;
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
            child: list == null
                ? screenState([
                        routines,
                      ], onRetry: () => ref.invalidate(routinesProvider)) ??
                      const SizedBox.shrink()
                : _List(routines: list, dropOn: dropOn),
          ),
        ),
      ),
    );
  }
}

class _List extends ConsumerStatefulWidget {
  const _List({required this.routines, this.dropOn});

  final List<Routine> routines;
  final DateTime? dropOn;

  @override
  ConsumerState<_List> createState() => _ListState();
}

/// A leaf: only the day routines drop on.
class _ListState extends ConsumerState<_List> {
  late DateTime? _day = widget.dropOn;

  @override
  Widget build(BuildContext context) {
    final routines = widget.routines;
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final profile = ref.watch(currentProfileProvider).value;
    final use24h = profile?.settings.use24h;
    final today = profile == null
        ? null
        : _localDate(ref.watch(clockProvider).nowUtc(), profile.tzId);
    final day = _day ?? today;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        DotSpace.l,
        DotSpace.page,
        DotSpace.fabClearance,
      ),
      children: [
        _Header(count: routines.length),
        const SizedBox(height: DotSpace.l),
        if (today != null && routines.isNotEmpty) ...[
          Text(l10n.routineDropDay.toUpperCase(), style: t.styles.caption),
          const SizedBox(height: DotSpace.xs),
          RoutineDayStrip(
            today: today,
            selected: day ?? today,
            onSelect: (d) => setState(() => _day = d),
          ),
          const SizedBox(height: DotSpace.l),
        ],
        if (routines.isEmpty)
          Text(
            l10n.routinesEmpty,
            style: t.styles.body.copyWith(color: t.colors.muted),
          ),
        for (final r in routines) ...[
          RoutineCard(
            routine: r,
            use24h: use24h,
            dropLabel: day == null || day == today
                ? l10n.routineDropToday
                : l10n.routineDropOnDay(relativeDayName(context, day, today)),
            onDrop: day == null
                ? null
                : () => unawaited(
                    dropRoutine(
                      context,
                      r,
                      date: day,
                      today: today,
                      use24h: use24h,
                    ),
                  ),
            onEdit: () => unawaited(editRoutine(context, routine: r)),
          ),
          const SizedBox(height: DotSpace.m),
        ],
        _NewRoutine(onTap: () => unawaited(editRoutine(context))),
        const SizedBox(height: DotSpace.l),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: DotSpace.s,
          children: [
            DotIcon(
              DotGlyphs.freeRing,
              color: t.colors.muted,
              size: DotSize.rowIcon,
            ),
            Flexible(
              child: Text(
                l10n.routineAlarmNote,
                style: t.styles.rowMeta.copyWith(color: t.colors.muted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// [utc]'s local calendar date in [tzId].
DateTime _localDate(DateTime utc, String tzId) {
  final local = tz.TZDateTime.from(utc, tz.getLocation(tzId));
  return DateTime(local.year, local.month, local.day);
}

/// ‹, "Routines", "Reusable slices of thread" and the count ring.
class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          tooltip: l10n.settingsBack,
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.settings),
          icon: DotIcon(DotGlyphs.arrowLeft, color: t.colors.text),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(l10n.routinesTitle, style: t.styles.pageTitle),
              ),
              Text(
                l10n.routinesSubtitle,
                style: t.styles.body.copyWith(color: t.colors.muted),
              ),
            ],
          ),
        ),
        CountRing(count: count, label: l10n.routinesCount(count)),
      ],
    );
  }
}

/// "+ New routine · or save a selection from any day" in a dashed box.
class _NewRoutine extends StatelessWidget {
  const _NewRoutine({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: l10n.routineNew,
      hint: l10n.routineNewHint,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        child: CustomPaint(
          painter: DashedPillPainter(color: t.colors.outline),
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.l),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: DotSpace.s,
              children: [
                DotIcon(DotGlyphs.add, color: t.colors.text),
                Text(l10n.routineNew, style: t.styles.body),
                Text(
                  l10n.realityMetaJoin(l10n.routineNewHint),
                  style: t.styles.body.copyWith(color: t.colors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
