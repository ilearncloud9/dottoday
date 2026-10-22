import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/dot/day_shape_slider.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Settings › Different days (PRD F1 "per-weekday start/end", R-17): each
/// weekday's Wake Up → Bedtime; a custom day has its own slider and "Same
/// as every day" to return.
Future<void> showWeekdaySheet(BuildContext context) => showAppSheet<void>(
  context: context,
  title: context.l10n.settingsPerWeekday,
  builder: (_) => const _Weekdays(),
);

class _Weekdays extends ConsumerWidget {
  const _Weekdays();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null) return const SizedBox.shrink();
    final first = settings.firstDayOfWeek;
    final days = [
      for (var i = 0; i < 7; i++) Weekday.values[(first - 1 + i) % 7],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final d in days) _Day(day: d, settings: settings)],
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({required this.day, required this.settings});

  final Weekday day;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final window = settings.boundaryFor(day);
    final custom = window != commonWindow(settings);
    final wake = windowMinutes(window.start);
    final bed = windowMinutes(window.end);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat.EEEE(
                  locale,
                ).format(DateTime(2024, 1, 1 + day.index)),
                style: t.styles.rowTitle.copyWith(
                  fontWeight: custom ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (custom)
              TextButton(
                onPressed: () =>
                    changeSettings(context, (s) => withDayWindow(s, day, null)),
                child: Text(l10n.settingsUseEveryday),
              ),
          ],
        ),
        DayShapeSlider(
          wakeMinute: wake,
          bedMinute: bed,
          timeText: (m) => clockText(context, m, settings.use24h),
          awakeText: (m) => l10n.settingsAwake(formatDurationShort(l10n, m)),
          wakeLabel: l10n.settingsWakeUp,
          bedLabel: l10n.settingsBedtime,
          onChanged: (w, b) => changeSettings(
            context,
            (s) => withDayWindow(
              s,
              day,
              TimeWindow(start: windowTime(w), end: windowTime(b)),
            ),
          ),
        ),
      ],
    );
  }
}
