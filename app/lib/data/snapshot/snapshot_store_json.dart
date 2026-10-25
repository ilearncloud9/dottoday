import 'dart:ui' show Locale;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/task_palette.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/snapshot/day_snapshot_codec.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// The day snapshot (B5) as it is stored for the native surfaces: JSON v1
/// from [encodeDaySnapshot] plus display fields — every string already
/// formatted and localised, every colour resolved — so Swift, Kotlin and
/// the service worker only lay out (no time zones, plurals or palette).
///
/// Times are on the profile's clock; [use24h] null follows the OS (docs/05).
Map<String, Object?> snapshotStoreJson(
  DaySnapshot snapshot, {
  required Profile profile,
  required bool use24h,
}) {
  final l10n = lookupAppLocalizations(_locale(profile.locale));
  final zone = tz.getLocation(profile.tzId);
  final clock = DateFormat(use24h ? 'HH:mm' : 'h:mm a', profile.locale);
  String time(DateTime utc) => clock.format(tz.TZDateTime.from(utc, zone));
  final json = encodeDaySnapshot(snapshot);
  final blocks = (json['blocks']! as List).cast<Map<String, Object?>>();
  for (final (i, dot) in snapshot.dots.indexed) {
    blocks[i]
      ..['time'] = time(dot.startUtc)
      ..['until'] = l10n.widgetUntil(time(dot.endUtc))
      ..['color'] = _hex(TaskColor.fromKey(dot.colorKey).color.toARGB32());
  }
  return json
    ..['labels'] = {
      'next_up': l10n.widgetNextUp,
      'now': l10n.widgetNow,
      'nothing_next': l10n.widgetNothingNext,
      'today': l10n.widgetToday,
      'inbox': l10n.widgetInboxCount(snapshot.inboxCount),
      // The Next up widget's Done button (M9.5).
      'done': l10n.notifActionDone,
    }
    // How to write a time again after an optimistic +15 in Swift or Kotlin
    // (M9.2): the zone, the language, the clock and the "until" pattern.
    ..['format'] = {
      'tz': profile.tzId,
      'locale': _locale(profile.locale).languageCode,
      'hour24': use24h,
      'until': l10n.widgetUntil(timePlaceholder),
    };
}

/// Where the time goes in `format.until` (`until {time}`).
const timePlaceholder = '{time}';

Locale _locale(String code) {
  final wanted = Locale(code);
  final known = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == wanted.languageCode,
  );
  return known ? wanted : const Locale('en');
}

String _hex(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
