import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/widgets.dart';

/// "4 steps · 1 h 15 · starts at Wake Up" (`B-ios-routines`).
String routineSummary(BuildContext context, Routine r, {bool? use24h}) {
  final l10n = context.l10n;
  final anchor = switch (r.anchor) {
    RoutineAnchor.wake => l10n.routineStartsWake,
    RoutineAnchor.bed => l10n.routineEndsBed,
    RoutineAnchor.time => l10n.routineStartsAt(
      formatClockTime(
        context,
        ClockTime.fromMinutes(r.anchorMinute ?? 0),
        use24h: use24h,
      ),
    ),
  };
  return l10n.routineSummary(
    l10n.routineSteps(r.items.length),
    formatDurationShort(l10n, r.spanMinutes),
    anchor,
  );
}
