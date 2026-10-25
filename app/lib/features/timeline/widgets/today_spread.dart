import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_state.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_view.dart';
import 'package:dottoday/features/timeline/widgets/all_day_chips.dart';
import 'package:dottoday/features/timeline/widgets/day_page.dart';
import 'package:dottoday/features/timeline/widgets/spread_header.dart';
import 'package:dottoday/features/timeline/widgets/today_prompt.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mac/web Today (docs/10 §5.2 T5, `A-mac-today-alt1-spread`): the day
/// before, [shown] on its card and the day after, with ‹ › to step a day.
/// Tasks drag between the columns (M3e.1).
class TodaySpread extends ConsumerWidget {
  const TodaySpread({
    required this.shown,
    required this.today,
    required this.onSelect,
    super.key,
  });

  final DateTime shown;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  DateTime _plus(int days) =>
      DateTime(shown.year, shown.month, shown.day + days);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final low = shown == today && watchLowEnergy(ref);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SpreadHeader(date: shown, today: today, onToday: () => onSelect(today)),
        AllDayChips(date: shown),
        TodayPrompt(date: shown, today: today),
        Expanded(child: _columns(context, low: low)),
      ],
    );
  }

  /// ‹, the day before, [shown] on its card, the day after, ›. In
  /// low-energy mode (M12.2) the card holds today's next dot and the side
  /// days are dimmed.
  Widget _columns(BuildContext context, {required bool low}) {
    Widget side(Widget day) =>
        low ? Opacity(opacity: TaskAlpha.ghost, child: day) : day;
    final l10n = context.l10n;
    final before = _plus(-1);
    final after = _plus(1);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Step(
          glyph: DotGlyphs.chevronLeft,
          tooltip: l10n.spreadPreviousDay,
          onTap: () => onSelect(before),
        ),
        Expanded(
          flex: DotSize.spreadSideFlex,
          child: side(
            DayPage(
              key: ValueKey(before),
              date: before,
              today: today,
              side: _side(context, before),
            ),
          ),
        ),
        Expanded(
          flex: DotSize.spreadCardFlex,
          child: low
              ? LowEnergyView(today: today)
              : DayPage(key: ValueKey(shown), date: shown, today: today),
        ),
        Expanded(
          flex: DotSize.spreadSideFlex,
          child: side(
            DayPage(
              key: ValueKey(after),
              date: after,
              today: today,
              side: _side(context, after),
            ),
          ),
        ),
        _Step(
          glyph: DotGlyphs.chevronRight,
          tooltip: l10n.spreadNextDay,
          onTap: () => onSelect(after),
        ),
      ],
    );
  }

  /// Past days (and today, when it is a side day) count what was done;
  /// later ones what is planned. Next to today the title says which.
  SideDay _side(BuildContext context, DateTime d) {
    final l10n = context.l10n;
    final offset = DateTime.utc(
      d.year,
      d.month,
      d.day,
    ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
    return SideDay(
      past: offset <= 0,
      suffix: switch (offset) {
        -1 => l10n.dayCardYesterdaySuffix,
        0 => l10n.dayCardTodaySuffix,
        1 => l10n.dayCardTomorrowSuffix,
        _ => '', // l10n-ignore: no suffix away from today
      },
    );
  }
}

/// The round ‹ / › beside the columns, level with the first rows.
class _Step extends StatelessWidget {
  const _Step({
    required this.glyph,
    required this.tooltip,
    required this.onTap,
  });

  final DotGlyph glyph;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      // Level with the side days' first rows (render: ~112 px down).
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.s,
        DotSpace.pageExpanded + DotSpace.xxl + DotSpace.l,
        DotSpace.s,
        0,
      ),
      child: IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          side: BorderSide(color: t.colors.outline),
          backgroundColor: t.colors.raised,
        ),
        icon: DotIcon(glyph, color: t.colors.text, size: DotSize.rowIcon),
      ),
    );
  }
}
