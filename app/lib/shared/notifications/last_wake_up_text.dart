import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/widgets.dart';
import 'package:timezone/timezone.dart' as tz;

/// "Last wake-up: rang 06:30, up 06:41" (docs/15 §4), or the half this
/// device knows: AlarmKit doesn't tell the app when it rang. Null before
/// the first one.
String? lastWakeUpText(
  BuildContext context,
  WakeUpDay? day,
  tz.Location location, {
  bool? use24h,
}) {
  final l10n = context.l10n;
  String at(DateTime utc) =>
      timeOfUtc(context, location, utc, use24h: use24hFor(context, use24h));
  return switch ((day?.rangAtUtc, day?.stoppedAtUtc)) {
    (final rang?, final up?) => l10n.healthLastWakeUp(at(rang), at(up)),
    (null, final up?) => l10n.healthLastWakeUpUp(at(up)),
    (final rang?, null) => l10n.healthLastWakeUpRang(at(rang)),
    (null, null) => null,
  };
}
