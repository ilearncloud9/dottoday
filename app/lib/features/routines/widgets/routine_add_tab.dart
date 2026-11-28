import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/routines/routine_providers.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/features/routines/routine_flows.dart';
import 'package:dottoday/features/routines/widgets/routine_text.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Add › Routine (G2-8, ED-149, E-Phones-2 "iPhone · Add › Routine"):
/// Drop on Today · Tomorrow · Other day…, the routines with their step
/// colours, the note that nothing is added before Accept, and Edit
/// routines…. A tap proposes the routine on the day (the one
/// ProposalSheet); Add closes first ([onPicked]) so the proposal opens
/// over the day.
class RoutineAddTab extends ConsumerStatefulWidget {
  const RoutineAddTab({
    required this.day,
    required this.today,
    required this.onPicked,
    this.embedded = false,
    super.key,
  });

  final DateTime day;
  final DateTime today;
  final VoidCallback onPicked;

  /// In the Mac and web popover: its own height, the popover scrolls.
  final bool embedded;

  @override
  ConsumerState<RoutineAddTab> createState() => _RoutineAddTabState();
}

class _RoutineAddTabState extends ConsumerState<RoutineAddTab> {
  // Leaf view state (CLAUDE.md §4): the day the routine drops on.
  late DateTime _day = widget.day;

  DateTime get _tomorrow =>
      DateTime(widget.today.year, widget.today.month, widget.today.day + 1);

  Future<void> _otherDay() async {
    final picked = await showMonthDayPicker(
      context,
      initial: _day,
      today: widget.today,
    );
    if (picked != null && mounted) setState(() => _day = picked);
  }

  void _drop(Routine r) {
    // The proposal opens over the day: Add steps aside first.
    final root = Navigator.of(context, rootNavigator: true).context;
    widget.onPicked();
    unawaited(dropRoutine(root, r, date: _day, today: widget.today));
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final routines = ref.watch(routinesProvider).value ?? const <Routine>[];
    final other = _day != widget.today && _day != _tomorrow;
    return ListView(
      shrinkWrap: widget.embedded,
      physics: widget.embedded ? const NeverScrollableScrollPhysics() : null,
      padding: widget.embedded
          ? EdgeInsets.zero
          : const EdgeInsets.all(DotSpace.page),
      children: [
        Wrap(
          spacing: DotSpace.s,
          runSpacing: DotSpace.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.routineDropOnLabel, style: t.styles.rowMeta),
            ChoiceChip(
              label: Text(l10n.sheetToday),
              selected: _day == widget.today,
              onSelected: (_) => setState(() => _day = widget.today),
            ),
            ChoiceChip(
              label: Text(l10n.sheetTomorrow),
              selected: _day == _tomorrow,
              onSelected: (_) => setState(() => _day = _tomorrow),
            ),
            ChoiceChip(
              label: Text(
                other
                    ? MaterialLocalizations.of(context).formatMediumDate(_day)
                    : l10n.routineOtherDay,
              ),
              selected: other,
              onSelected: (_) => unawaited(_otherDay()),
            ),
          ],
        ),
        const SizedBox(height: DotSpace.m),
        for (final r in routines) ...[
          _RoutineRow(routine: r, onTap: () => _drop(r)),
          const SizedBox(height: DotSpace.s),
        ],
        if (routines.isEmpty)
          Text(l10n.routinesEmpty, style: t.styles.body)
        else
          Text(
            l10n.routineTabHint,
            style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
          ),
        const SizedBox(height: DotSpace.s),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: () => unawaited(
              context.push(AppRoutes.settingsPage(SettingsPage.routines)),
            ),
            child: Text(l10n.routineEditAll),
          ),
        ),
      ],
    );
  }
}

/// One routine: its name, "5 steps · 55 min · starts at Wake Up", its
/// steps' colours as rings, and a chevron; the row is one button.
class _RoutineRow extends StatelessWidget {
  const _RoutineRow({required this.routine, required this.onTap});

  final Routine routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final summary = routineSummary(context, routine);
    return Semantics(
      button: true,
      label: context.l10n.listJoin(routine.title, summary),
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: t.colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.cardLarge),
          side: BorderSide(color: t.colors.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.m),
            child: Row(
              spacing: DotSpace.m,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: DotSpace.xs,
                    children: [
                      Text(routine.title, style: t.styles.choiceTitle),
                      Text(summary, style: t.styles.rowMeta),
                      Wrap(
                        spacing: DotSpace.xs,
                        children: [
                          for (final item in routine.items)
                            Container(
                              width: DotSpace.m,
                              height: DotSpace.m,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: t
                                      .tasks[TaskColor.fromKey(item.colorKey)]
                                      .ring,
                                  width: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                DotIcon(
                  DotGlyphs.chevronRight,
                  color: t.colors.secondary,
                  size: DotSize.sidebarGlyph,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
