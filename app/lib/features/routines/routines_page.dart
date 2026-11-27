import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/routines_place.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/routines/routine_providers.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/features/routines/routine_flows.dart';
import 'package:dottoday/features/routines/widgets/routine_card.dart';
import 'package:dottoday/features/routines/widgets/routine_day_strip.dart';
import 'package:dottoday/features/routines/widgets/routines_header.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final wide = AppLayout.classOf(context) != WidthClass.compact;
    // Its own place: one readable column, as E-R2-30 draws it (ED-500).
    final alone = watchRoutinesAlone(context, ref);
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: wide && !alone
                  ? DotSize.routinesWide
                  : DotSize.readableColumn,
            ),
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
    final alone = watchRoutinesAlone(context, ref);
    // Two to a row from medium width (E-R2-22); one column where Routines
    // is its own place (E-R2-30, ED-500).
    final wide = AppLayout.classOf(context) != WidthClass.compact && !alone;
    final cards = [
      for (final r in routines)
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
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        DotSpace.s,
        DotSpace.page,
        DotSpace.fabClearance,
      ),
      children: [
        RoutinesHeader(
          count: routines.length,
          wide: wide || alone,
          pill: alone,
        ),
        const SizedBox(height: DotSpace.m),
        if (today != null && routines.isNotEmpty) ...[
          Text(
            l10n.routineDropDay,
            style: t.styles.rowMeta.copyWith(color: t.colors.muted),
          ),
          const SizedBox(height: DotSpace.xs),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              width: wide ? DotSize.readableColumn : null,
              child: RoutineDayStrip(
                today: today,
                selected: day ?? today,
                onSelect: (d) => setState(() => _day = d),
              ),
            ),
          ),
          const SizedBox(height: DotSpace.m),
        ],
        if (routines.isEmpty) ...[
          _EmptyCard(text: l10n.routinesEmpty),
          const SizedBox(height: DotSpace.s),
        ],
        if (wide)
          LayoutBuilder(
            builder: (context, box) {
              final w = (box.maxWidth - DotSpace.s) / 2;
              return Wrap(
                spacing: DotSpace.s,
                runSpacing: DotSpace.s,
                children: [
                  for (final c in cards) SizedBox(width: w, child: c),
                  SizedBox(width: w, child: _newRoutine(context)),
                ],
              );
            },
          )
        else ...[
          for (final c in cards) ...[c, const SizedBox(height: DotSpace.s)],
          _newRoutine(context),
        ],
        const SizedBox(height: DotSpace.m),
        Row(
          spacing: DotSpace.xs,
          children: [
            DotIcon(
              DotGlyphs.bell,
              color: t.colors.muted,
              size: DotSize.miniRing + DotSpace.xxs,
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

Widget _newRoutine(BuildContext context) =>
    NewRoutineCard(onTap: () => unawaited(editRoutine(context)));

/// "No routines yet. …" on a card (E-R2-22 none yet).
class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(color: t.colors.outline, width: DotSpace.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.l),
        child: Text(text, style: t.styles.body),
      ),
    );
  }
}
