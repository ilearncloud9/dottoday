import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/today_header.dart';
import 'package:dottoday/shared/menus/dot_menu_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The Mac/web Today header (`A-mac-today-alt1-spread`): "Good morning,
/// Kody", "Wednesday, 21 October · 2 of 7 done", Running late and the day
/// dot; away from today, the weekday and the Today pill.
class SpreadHeader extends ConsumerWidget {
  const SpreadHeader({
    required this.date,
    required this.today,
    required this.onToday,
    super.key,
  });

  final DateTime date;
  final DateTime today;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final isToday = date == today;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.xxl + DotSpace.s,
        DotSpace.xl,
        DotSpace.xl,
        DotSpace.l,
      ),
      child: Row(
        spacing: DotSpace.m,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  container: true,
                  header: true,
                  child: Text(
                    dayTitle(context, ref, date: date, today: today),
                    style: t.styles.pageTitle,
                  ),
                ),
                Text(
                  _subtitle(context, ref, DateFormat.MMMMEEEEd(locale)),
                  style: t.styles.body.copyWith(color: t.colors.muted),
                ),
              ],
            ),
          ),
          if (isToday) ...[
            _RunningLate(today: today),
            TodayDot(today: today),
          ] else
            TodayPill(onTap: onToday),
        ],
      ),
    );
  }

  /// "Wednesday, 21 October · 2 of 7 done".
  String _subtitle(BuildContext context, WidgetRef ref, DateFormat format) {
    final data = ref.watch(timelineDataProvider(date)).value;
    final text = format.format(date);
    if (data == null) return text;
    final shape = DayShape.on(
      data.day.location,
      date,
      data.settings.boundaryFor(data.day.weekday),
    );
    final s = daySummaryOf(data.blocks, shape);
    return context.l10n.spreadSubtitle(text, s.done, s.total);
  }
}

/// "Running late": push what is left of today +5 / +15 / +30 min (docs/02
/// F1, R-04), stopping at a pinned task; one Undo.
class _RunningLate extends ConsumerWidget {
  const _RunningLate({required this.today});

  final DateTime today;

  static const _choices = [5, 15, 30];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return MenuAnchor(
      style: dotMenuStyle(context),
      menuChildren: [
        for (final m in _choices)
          MenuItemButton(
            onPressed: () => unawaited(_push(context, ref, m)),
            child: Text(l10n.runningLateBy(m)),
          ),
      ],
      builder: (context, controller, _) => OutlinedButton.icon(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: DotIcon(
          DotGlyphs.clock,
          color: t.colors.text,
          size: DotSize.rowIcon,
        ),
        label: Text(l10n.runningLate),
      ),
    );
  }

  Future<void> _push(BuildContext context, WidgetRef ref, int minutes) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final data = ref.read(timelineDataProvider(today)).value;
    if (data == null) return;
    final run = runLate(
      ref,
      day: data.blocks,
      nowUtc: ref.read(clockProvider).nowUtc(),
      minutes: minutes,
      includeCalendar: data.settings.includeCalendarInShift,
    );
    if (run == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.snackRunningLate(0, minutes))),
      );
      return;
    }
    String title(String id) =>
        data.blocks.where((o) => o.id == id).firstOrNull?.title ?? '';
    reportUndoable(
      messenger,
      l10n,
      ref.read(undoServiceProvider),
      await run,
      message: (v) => switch (v.$2.blockedById) {
        final pin? => l10n.snackRunningLatePartial(
          v.$2.movedIds.length,
          minutes,
          title(pin),
        ),
        null => l10n.snackRunningLate(v.$2.movedIds.length, minutes),
      },
      tokenOf: (v) => v.$1,
    );
  }
}
