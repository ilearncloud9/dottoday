import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/today_selection.dart';
import 'package:dottoday/features/timeline/widgets/debug_menu.dart';
import 'package:dottoday/shared/dot/day_dot.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Today's header (`Main`): "WEDNESDAY 21 OCT ⌄" (tap: month), the
/// greeting (or the weekday away from today), and the day dot.
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
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final caption = DateFormat.MMMEd(locale).format(date).toUpperCase();
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.page,
        DotSpace.l,
        DotSpace.s,
        DotSpace.s,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  button: true,
                  expanded: monthOpen,
                  label: monthOpen
                      ? l10n.weekStripHideMonth
                      : l10n.weekStripShowMonth,
                  child: InkWell(
                    onTap: ref
                        .read(todaySelectionProvider.notifier)
                        .toggleMonth,
                    borderRadius: BorderRadius.circular(DotRadii.card),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: DotTouch.android,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: DotSpace.xs,
                        children: [
                          ExcludeSemantics(
                            child: Text(caption, style: t.styles.caption),
                          ),
                          DotIcon(
                            monthOpen
                                ? DotGlyphs.chevronUp
                                : DotGlyphs.chevronDown,
                            color: t.colors.muted,
                            size: DotSize.weekDot * 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Semantics(
                  header: true,
                  child: Text(
                    _title(context, ref, locale),
                    style: t.styles.pageTitle,
                  ),
                ),
              ],
            ),
          ),
          if (date == today)
            TodayDot(today: today)
          else
            TodayPill(onTap: onToday),
          if (kDebugMode)
            PopupMenuButton<void>(
              tooltip: l10n.timelineMenu,
              icon: DotIcon(DotGlyphs.more, color: t.colors.text),
              itemBuilder: debugMenuItems,
            ),
        ],
      ),
    );
  }

  String _title(BuildContext context, WidgetRef ref, String locale) {
    final otherMonth = month.year != today.year || month.month != today.month;
    if (monthOpen && otherMonth) return DateFormat.yMMMM(locale).format(month);
    return dayTitle(context, ref, date: date, today: today);
  }
}

/// "Good morning, Kody" on today, else the weekday (Today headers on every
/// width).
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

/// The day dot: how far today is through Wake Up → Bedtime.
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
      child: DayDot(progress: progress),
    );
  }
}

/// ICU select key of the greeting for a local [hour]: before noon,
/// before 17:00, or later.
String dayPart(int hour) => hour < 12
    ? 'morning' // l10n-ignore: ICU select key
    : hour < 17
    ? 'afternoon' // l10n-ignore: ICU select key
    : 'evening'; // l10n-ignore: ICU select key

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
