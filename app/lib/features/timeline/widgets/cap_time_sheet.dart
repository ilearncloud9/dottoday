import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/shared/controls/dot_segmented.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// A tap on the thread's Wake Up or Wind Down cap ([windDown]) on [date]:
/// its time, for every day or only this weekday (R-17). It starts on the
/// scope the day has now: a day with its own window edits just that day.
/// The change applies on Done, like Settings › DAY SHAPE.
Future<void> showCapTimeSheet(
  BuildContext context, {
  required DateTime date,
  required bool windDown,
  required Settings settings,
}) async {
  final l10n = context.l10n;
  final container = ProviderScope.containerOf(context);
  final messenger = ScaffoldMessenger.of(context);
  final day = Weekday.values[date.weekday - 1];
  final window = settings.boundaryFor(day);
  final picked = await showAppSheet<_CapPick>(
    context: context,
    title: windDown ? l10n.settingsWindDown : l10n.settingsWakeUp,
    builder: (_) => _CapSheet(
      initial: ClockTime.fromMinutes(
        windowMinutes(windDown ? window.end : window.start),
      ),
      everyDay: window == commonWindow(settings),
      weekday: DateFormat.EEEE(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(date),
      use24h: settings.use24h,
      // A Wind Down at or before Wake Up falls after midnight (Q8).
      nextDayUpTo: windDown ? windowMinutes(window.start) : null,
    ),
  );
  if (picked == null) return;
  final result = await updateSettings(
    container,
    (s) => withCapAt(
      s,
      day,
      windDown: windDown,
      minute: picked.time.minutesOfDay,
      everyDay: picked.everyDay,
    ),
  );
  if (result case Err(:final failure)) {
    messenger.showSnackBar(
      SnackBar(content: Text(failureMessage(l10n, failure))),
    );
  }
}

typedef _CapPick = ({ClockTime time, bool everyDay});

class _CapSheet extends StatefulWidget {
  const _CapSheet({
    required this.initial,
    required this.everyDay,
    required this.weekday,
    required this.use24h,
    this.nextDayUpTo,
  });

  final ClockTime initial;

  /// Wake Up's minute when this is Wind Down: a time at or before it is
  /// labelled "next day".
  final int? nextDayUpTo;
  final bool everyDay;

  /// "Saturday".
  final String weekday;
  final bool? use24h;

  @override
  State<_CapSheet> createState() => _CapSheetState();
}

/// A leaf: the time and scope being chosen.
class _CapSheetState extends State<_CapSheet> {
  late ClockTime _time = widget.initial;
  late bool _everyDay = widget.everyDay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.l,
      children: [
        TimeInput(
          value: _time,
          use24h: widget.use24h,
          onChanged: (t) => setState(() => _time = t),
        ),
        // Midnight itself (00:00) reads as the day's own end, unlabelled.
        if (widget.nextDayUpTo case final wake?
            when _time.minutesOfDay > 0 && _time.minutesOfDay <= wake)
          Text(
            l10n.timeNextDay(
              formatClockTime(context, _time, use24h: widget.use24h),
            ),
            textAlign: TextAlign.center,
            style: DotTheme.of(context).styles.rowMeta,
          ),
        DotSegmented<bool>(
          segments: [
            (true, l10n.capEveryDay),
            (false, l10n.capEveryWeekday(widget.weekday)),
          ],
          selected: _everyDay,
          onChanged: (v) => setState(() => _everyDay = v),
        ),
        FilledButton(
          onPressed: () => Navigator.of(
            context,
          ).pop<_CapPick>((time: _time, everyDay: _everyDay)),
          child: Text(l10n.timeInputDone),
        ),
      ],
    );
  }
}
