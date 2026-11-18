import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/time/day_dot_geometry.dart';
import 'package:dottoday/domain/time/wind_down.dart';
import 'package:dottoday/features/timeline/state/day_ends.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/dot/day_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

// Day titles and the day dot shared by Week and the Mac/web spread
// (moved out of Today's header in M19.1, which no longer shows them).

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
    final ends = ref.watch(dayEndsProvider(today)).value;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final geometry = ends == null || data == null
        ? const DayDotGeometry.filled(0)
        : dayDotGeometry(
            wakeUtc: ends.shape.wakeUtc,
            windDownUtc: ends.shape.bedUtc,
            nextWakeUtc: ends.nextWakeUtc,
            nowUtc: now,
            night: data.settings.showNightArc,
          );
    final night = ends == null
        ? null
        : context.l10n.nightLabel(
            formatDurationShort(
              context.l10n,
              nightMinutes(ends.shape.bedUtc, ends.nextWakeUtc),
            ),
          );
    return Padding(
      padding: const EdgeInsets.all(DotSpace.xs),
      // The header's line also holds the date and ⋯ (ADR-0015).
      child: DayDot(
        geometry: geometry,
        nightLabel: geometry.hasNight ? night : null,
        size: DotSize.headerDayDot,
      ),
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
