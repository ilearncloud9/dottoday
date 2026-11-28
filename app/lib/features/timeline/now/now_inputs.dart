import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/now/now_view.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/now/now_body.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/dot/day_horizon.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// What Now draws from at this minute, the phones' tab and the Mac and
/// web pane alike: today, its timed tasks, the day's shape, a time
/// formatter and [view] (`nowViewOf`, ED-329).
final class NowInputs {
  const NowInputs._({
    required this.today,
    required this.timed,
    required this.nowUtc,
    required this.shape,
    required this.zone,
    required this.time,
    required this.view,
  });

  final DateTime today;

  /// Today's tasks with a time, in the order the horizon draws them.
  final List<Occurrence> timed;
  final DateTime nowUtc;
  final DayShape shape;
  final tz.Location zone;
  final NowTime time;
  final NowView view;

  /// What Now waits on (today, then its day), for [waitFor]: the
  /// skeleton while either loads, the inline error with Try again if one
  /// failed (docs/10 §5.4; found in M19.7: Now drew a blank screen).
  static List<AsyncValue<Object?>> states(WidgetRef ref) {
    final today = ref.watch(todayDateProvider);
    return [
      today,
      if (today.value case final d?) ref.watch(timelineDataProvider(d)),
    ];
  }

  /// Try again: reloads today and its day.
  static void retry(WidgetRef ref) {
    ref.invalidate(todayDateProvider);
    if (ref.read(todayDateProvider).value case final d?) {
      ref.invalidate(timelineDataProvider(d));
    }
  }

  /// Today's inputs, or null while the day loads.
  static NowInputs? watch(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayDateProvider).value;
    final data = today == null
        ? null
        : ref.watch(timelineDataProvider(today)).value;
    if (today == null || data == null) return null;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final shape = DayShape.on(
      data.day.location,
      data.day.date,
      data.settings.boundaryFor(data.day.weekday),
    );
    final use24h = use24hFor(
      context,
      ref.watch(currentProfileProvider).value?.settings.use24h,
    );
    return NowInputs._(
      today: today,
      timed: [
        for (final o in data.blocks)
          if (o.startUtc != null) o,
      ],
      nowUtc: now,
      shape: shape,
      zone: data.day.location,
      time: (utc) => timeOfUtc(context, data.day.location, utc, use24h: use24h),
      view: nowViewOf(
        blocks: data.blocks,
        nowUtc: now,
        windDownUtc: shape.bedUtc,
      ),
    );
  }

  /// The day horizon for these inputs (ED-241): wake, now, the middle
  /// hour and Wind Down under it. [onTap] with its [hint]; [onDotMenu]
  /// gets the task under a right-click; [onOpen] the task the keyboard
  /// or a screen reader opens (ED-248 A).
  Widget horizon(
    BuildContext context, {
    VoidCallback? onTap,
    String? hint,
    void Function(Occurrence task, Offset global)? onDotMenu,
    void Function(Occurrence task)? onOpen,
  }) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final wake = tz.TZDateTime.from(shape.wakeUtc, zone);
    final bed = tz.TZDateTime.from(shape.bedUtc, zone);
    // The whole hour halfway through the waking day ("3 PM").
    final mid = wake.add(bed.difference(wake) ~/ 2);
    final midHour = tz.TZDateTime(zone, mid.year, mid.month, mid.day, mid.hour);
    String hour(tz.TZDateTime t) => DateFormat.j(locale).format(t);
    return DayHorizon(
      dots: [
        for (final o in timed)
          HorizonDot(
            startUtc: o.startUtc!,
            endUtc: o.endUtc!,
            color: TaskColor.fromKey(o.colorKey),
            state: dotStateOf(o, nowUtc),
          ),
      ],
      wakeUtc: shape.wakeUtc,
      windDownUtc: shape.bedUtc,
      nowUtc: nowUtc,
      labels: (
        wake: hour(wake),
        now: time(nowUtc),
        mid: hour(midHour),
        midUtc: midHour.toUtc(),
        windDown: hour(bed),
      ),
      label: l10n.horizonLabel(
        time(shape.wakeUtc),
        time(shape.bedUtc),
        time(nowUtc),
      ),
      dotLabels: [
        for (final o in timed)
          l10n.rowLabel(
            o.title,
            l10n.threadTimeRange(time(o.startUtc!), time(o.endUtc!)),
          ),
      ],
      hint: hint,
      onTap: onTap,
      onDotMenu: onDotMenu == null ? null : (i, at) => onDotMenu(timed[i], at),
      onOpen: onOpen == null ? null : (i) => onOpen(timed[i]),
    );
  }
}
