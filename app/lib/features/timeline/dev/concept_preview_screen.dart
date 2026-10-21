import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/dev/preview_day_card.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/dot/day_dot.dart';
import 'package:dottoday/shared/dot/day_pager.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// DEBUG ONLY (M3a.10). The Concept A components on the real day, so the
// M3a build can be tried on a device before Today is rebuilt in M3b.1.
// Reached only from the kDebugMode header menu; release builds drop it.

/// Opens the preview over the current route. Called from a popup menu item,
/// which pops its menu right after `onTap`, so push after this frame;
/// pushing now would be the route that pop removes.
void openConceptPreview(BuildContext context) {
  final navigator = Navigator.of(context);
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => unawaited(
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const ConceptPreviewScreen()),
      ),
    ),
  );
}

/// Header, week strip and day pager of `Main`, fed by this week's data.
class ConceptPreviewScreen extends ConsumerStatefulWidget {
  const ConceptPreviewScreen({super.key});

  @override
  ConsumerState<ConceptPreviewScreen> createState() => _PreviewState();
}

class _PreviewState extends ConsumerState<ConceptPreviewScreen> {
  int? _page;
  bool _month = false;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayDateProvider).value;
    if (today == null) return const Scaffold();
    // The week this preview pages through starts on Sunday, like `Main`.
    final sunday = today.subtract(Duration(days: today.weekday % 7));
    final week = [for (var i = 0; i < 7; i++) sunday.add(Duration(days: i))];
    final page = _page ?? today.weekday % 7;
    return Scaffold(
      // SafeArea applies the shell's bottom clearance, so the page dots sit
      // above the floating tab bar as in `Main`.
      body: SafeArea(
        child: Column(
          children: [
            _Header(date: week[page], today: today),
            WeekStrip(
              days: [for (final d in week) _stripDay(context, d, today)],
              selected: page,
              monthOpen: _month,
              onSelect: (i) => setState(() => _page = i),
              onPull: () => setState(() => _month = !_month),
            ),
            if (_month) _Month(today: today),
            Expanded(
              child: DayPager(
                itemCount: 7,
                initialIndex: page,
                onChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) =>
                    PreviewDayCard(date: week[i], isToday: week[i] == today),
              ),
            ),
          ],
        ),
      ),
    );
  }

  StripDay _stripDay(BuildContext context, DateTime d, DateTime today) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return StripDay(
      weekday: DateFormat.E(locale).format(d),
      date: DateFormat.d(locale).format(d),
      label: DateFormat.MMMMEEEEd(locale).format(d),
      completion: const Completion.none(),
      isToday: d == today,
      isPast: d.isBefore(today),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.date, required this.today});

  final DateTime date;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
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
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        DotSpace.l,
        DotSpace.page,
        DotSpace.s,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.MMMMEEEEd(locale).format(date).toUpperCase(),
                  style: t.styles.caption,
                ),
                Text(
                  DateFormat.EEEE(locale).format(date),
                  style: t.styles.pageTitle,
                ),
              ],
            ),
          ),
          DayDot(progress: progress),
        ],
      ),
    );
  }
}

class _Month extends StatelessWidget {
  const _Month({required this.today});

  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final first = DateTime(today.year, today.month);
    final lead = first.weekday % 7;
    final days = DateTime(today.year, today.month + 1, 0).day;
    final sunday = first.subtract(Duration(days: lead));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.page),
      child: MonthGrid(
        weekdays: [
          for (var i = 0; i < 7; i++)
            DateFormat.E(locale).format(sunday.add(Duration(days: i))),
        ],
        selected: lead + today.day - 1,
        days: [
          for (var i = 0; i < lead; i++) null,
          for (var d = 1; d <= days; d++)
            MonthDay(
              date: DateFormat.d(
                locale,
              ).format(DateTime(today.year, today.month, d)),
              label: DateFormat.MMMMEEEEd(
                locale,
              ).format(DateTime(today.year, today.month, d)),
              isPast: d < today.day,
              completion: const Completion.none(),
            ),
        ],
      ),
    );
  }
}
