import 'dart:ui' show Locale;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/task_palette.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/live_activity/live_dot_plan.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// The Live Activity's content state (iOS, M9.3) and the Android ongoing
/// notification's text (M9.4) for [plan]: every word localised, every time
/// formatted on the profile's clock, every colour resolved, so the native
/// side only lays out. A live countdown sits between `*_before` and
/// `*_after` (word order differs by language: "38 min left", "noch 38 Min.").
Map<String, Object?> liveActivityContent(
  LiveDotPlan plan, {
  required Profile profile,
  required bool use24h,
}) {
  final l10n = lookupAppLocalizations(_locale(profile.locale));
  final zone = tz.getLocation(profile.tzId);
  final clock = DateFormat(use24h ? 'HH:mm' : 'h:mm a', profile.locale);
  String time(DateTime utc) => clock.format(tz.TZDateTime.from(utc, zone));
  final focus = plan.focus;
  final (leftBefore, leftAfter) = _around(l10n.liveActivityLeft);
  final (startsBefore, startsAfter) = _around(l10n.liveActivityStartsIn);
  return {
    'v': 1,
    'id': focus.id,
    'title': focus.title,
    'color': _hex(focus.colorKey),
    'icon': focus.iconKey,
    'start_ms': focus.startUtc.millisecondsSinceEpoch,
    'end_ms': focus.endUtc.millisecondsSinceEpoch,
    'ends_ms': plan.endsAtUtc.millisecondsSinceEpoch,
    'live': plan.isLive,
    'range': l10n.threadTimeRange(time(focus.startUtc), time(focus.endUtc)),
    // To re-render the range after +15 on the activity itself (Swift).
    'range_pattern': l10n.threadTimeRange('{start}', '{end}'),
    'format': {'tz': profile.tzId, 'locale': profile.locale, 'hour24': use24h},
    'left_before': leftBefore,
    'left_after': leftAfter,
    'starts_before': startsBefore,
    'starts_after': startsAfter,
    // Empty when today counts no dots (one before Wake Up, say): no "0 of 0".
    'count': plan.dayTotal == 0
        ? ''
        : l10n.liveActivityCount(plan.dayDone, plan.dayTotal),
    'count_label': plan.dayTotal == 0
        ? ''
        : l10n.liveActivityCountLabel(plan.dayDone, plan.dayTotal),
    'done_share': plan.dayTotal == 0 ? 0.0 : plan.dayDone / plan.dayTotal,
    'done_label': l10n.notifActionDone,
    'plus_label': l10n.liveExtend,
    'plus_short': '+${AddFifteen.minutes}',
    'next': [for (final d in plan.next) _next(d, time(d.startUtc))],
  };
}

Map<String, Object?> _next(SnapshotDot d, String time) => {
  'id': d.id,
  'title': d.title,
  'color': _hex(d.colorKey),
  'time': time,
};

/// The text before and after the `{time}` slot of [pattern].
(String, String) _around(String Function(String) pattern) {
  const slot = '\u0000';
  final parts = pattern(slot).split(slot);
  return (parts.first, parts.length > 1 ? parts[1] : '');
}

Locale _locale(String code) {
  final known = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == code,
  );
  return Locale(known ? code : 'en');
}

String _hex(String colorKey) {
  final argb = TaskColor.fromKey(colorKey).color.toARGB32();
  return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
