import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_actions.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_parts.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_state.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/today_selection.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:dottoday/shared/dot/day_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Today's header (ADR-0015, after Structured's): the date as the title,
/// "October 25, 2026 ⌄" (tap: month), with the day dot (or "● Today" away
/// from today) and ⋯ on the same line; the day's numbers under it.
class TodayHeader extends ConsumerWidget {
  const TodayHeader({
    required this.date,
    required this.today,
    required this.monthOpen,
    required this.month,
    required this.onToday,
    super.key,
  });

  final DateTime date;
  final DateTime today;
  final bool monthOpen;

  /// The month shown when [monthOpen].
  final DateTime month;

  /// Back to today (the pill shown away from it, `A-ios-future-month`).
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final low = date == today && watchLowEnergy(ref);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.page,
        DotSpace.s,
        DotSpace.s,
        DotSpace.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _TitleButton(
                  title: _title(context, ref, locale),
                  monthOpen: monthOpen,
                ),
              ),
              if (low)
                LowEnergySwitch(
                  onChanged: (on) => toggleLowEnergy(context, on: on),
                )
              else if (date == today)
                TodayDot(today: today)
              else
                TodayPill(onTap: onToday),
              TodayMenu(date: date, today: today),
            ],
          ),
          if (low)
            _Caption(
              l10n.lowEnergyCaption(DateFormat.MMMEd(locale).format(date)),
            )
          else if (!monthOpen)
            DayNumbers(date: date),
        ],
      ),
    );
  }

  String _title(BuildContext context, WidgetRef ref, String locale) {
    if (date == today && watchLowEnergy(ref)) {
      return lowEnergyTitle(context, ref);
    }
    final otherMonth = month.year != today.year || month.month != today.month;
    if (monthOpen && otherMonth) return DateFormat.yMMMM(locale).format(month);
    // The date, as Structured's header (ADR-0015); the spread keeps the
    // greeting (dayTitle).
    return DateFormat.yMMMMd(locale).format(date);
  }
}

/// "Good morning, Kody" on today, else the weekday: the Mac/web spread's
/// title (`A-mac-today-alt1-spread`). The phone header shows the date
/// instead (ADR-0015); the spread has the room for both.
String dayTitle(
  BuildContext context,
  WidgetRef ref, {
  required DateTime date,
  required DateTime today,
}) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  if (date != today) return DateFormat.EEEE(locale).format(date);
  final profile = ref.watch(currentProfileProvider).value;
  final now =
      ref.watch(minuteTickProvider).value ?? ref.watch(clockProvider).nowUtc();
  final zone = profile == null ? tz.UTC : tz.getLocation(profile.tzId);
  final part = dayPart(tz.TZDateTime.from(now, zone).hour);
  final name = profile?.displayName?.trim() ?? '';
  final l10n = context.l10n;
  return name.isEmpty
      ? l10n.todayGreeting(part)
      : l10n.todayGreetingName(part, name);
}

/// ICU select key of the greeting for a local [hour]: before noon,
/// before 17:00, or later.
String dayPart(int hour) => hour < 12
    ? 'morning' // l10n-ignore: ICU select key
    : hour < 17
    ? 'afternoon' // l10n-ignore: ICU select key
    : 'evening'; // l10n-ignore: ICU select key

/// "Take it easy, Kody" (low-energy mode, `B-ios-low-energy`).
String lowEnergyTitle(BuildContext context, WidgetRef ref) {
  final name = ref.watch(currentProfileProvider).value?.displayName?.trim();
  final l10n = context.l10n;
  return name == null || name.isEmpty
      ? l10n.lowEnergyGreeting
      : l10n.lowEnergyGreetingName(name);
}

/// The day dot: how far today is through Wake Up → Wind Down.
class TodayDot extends ConsumerWidget {
  const TodayDot({required this.today, super.key});

  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(timelineDataProvider(today)).value;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final progress = data == null
        ? 0.0
        : DayShape.on(
            data.day.location,
            today,
            data.settings.boundaryFor(data.day.weekday),
          ).progressAt(now);
    return Padding(
      padding: const EdgeInsets.all(DotSpace.xs),
      // The header's line also holds the date and ⋯ (ADR-0015).
      child: DayDot(progress: progress, size: DotSize.headerDayDot),
    );
  }
}

/// "● Today" (`A-ios-future-month`): one tap back to the current date
/// (03 §2).
class TodayPill extends StatelessWidget {
  const TodayPill({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Container(
        width: DotSize.tabDot,
        height: DotSize.tabDot,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c.accent),
      ),
      label: Text(
        context.l10n.todayPill,
        style: t.styles.button.copyWith(color: c.accentInk),
      ),
    );
  }
}

/// "0 of 15 · 22 h 55 planned" under Today's title (ADR-0015: moved up
/// from the day card's header row, so the sheet below is all thread).
class DayNumbers extends ConsumerWidget {
  const DayNumbers({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(timelineDataProvider(date)).value;
    if (data == null) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final s = daySummaryOf(
      data.blocks,
      DayShape.on(
        data.day.location,
        date,
        data.settings.boundaryFor(data.day.weekday),
      ),
    );
    return Text(
      s.total == 0
          ? l10n.dayCardNothing(formatDurationShort(l10n, s.freeMinutes))
          : l10n.dayCardSummary(
              s.done,
              s.total,
              formatDurationShort(l10n, s.plannedMinutes),
            ),
      style: t.styles.dayCaption.copyWith(letterSpacing: 0),
    );
  }
}

/// The title, which opens the month (the chevron says which way).
class _TitleButton extends ConsumerWidget {
  const _TitleButton({required this.title, required this.monthOpen});

  final String title;
  final bool monthOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final style = t.styles.dayTitle;
    return Semantics(
      button: true,
      header: true,
      expanded: monthOpen,
      label: title,
      hint: monthOpen ? l10n.weekStripHideMonth : l10n.weekStripShowMonth,
      excludeSemantics: true,
      child: InkWell(
        onTap: ref.read(todaySelectionProvider.notifier).toggleMonth,
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Text.rich(
            TextSpan(
              text: title,
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: DotSpace.xs,
                    ),
                    child: DotIcon(
                      monthOpen ? DotGlyphs.chevronUp : DotGlyphs.chevronDown,
                      color: t.colors.text,
                      size: DotSize.rowIcon,
                      bold: true,
                    ),
                  ),
                ),
              ],
            ),
            style: style,
          ),
        ),
      ),
    );
  }
}

/// A muted line under the title (low-energy mode's "Thursday · low energy").
class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Text(text, style: t.styles.dayCaption.copyWith(letterSpacing: 0));
  }
}
