import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/running_late_sheet.dart';
import 'package:dottoday/features/timeline/widgets/today_header.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
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
          ..._end(isToday),
        ],
      ),
    );
  }

  /// Running late and the day dot on today, else the Today pill; the ⋯.
  List<Widget> _end(bool isToday) => [
    if (isToday) ...[
      _LateButton(today: today),
      TodayDot(today: today),
    ] else
      TodayPill(onTap: onToday),
    TodayMenu(date: date, today: today, withLate: false),
  ];

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

/// "Running late" (`A-mac-today-alt1-spread`): the Running late sheet.
class _LateButton extends StatelessWidget {
  const _LateButton({required this.today});

  final DateTime today;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () => unawaited(showRunningLateSheet(context, today)),
    icon: DotIcon(
      DotGlyphs.clock,
      color: DotTheme.of(context).colors.text,
      size: DotSize.rowIcon,
    ),
    label: Text(context.l10n.runningLate),
  );
}
