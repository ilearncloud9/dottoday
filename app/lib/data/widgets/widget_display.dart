import 'dart:ui' show Locale;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/task_palette.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/widgets/widget_snapshot.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// The snapshot as the native widgets read it (docs/09 M5.4): every string
/// already formatted and localised, every colour resolved, so the Swift and
/// Kotlin widgets only lay out — no time zones, plurals or palette there.
///
/// Times are on the profile's clock; [use24h] null follows the OS (docs/05).
Map<String, Object?> widgetDisplayJson(
  WidgetSnapshot snapshot, {
  required Profile profile,
  required bool use24h,
}) {
  final l10n = lookupAppLocalizations(_locale(profile.locale));
  final zone = tz.getLocation(profile.tzId);
  final clock = DateFormat(use24h ? 'HH:mm' : 'h:mm a', profile.locale);
  String time(DateTime utc) => clock.format(tz.TZDateTime.from(utc, zone));
  return {
    'v': 1,
    'generated_ms': snapshot.generatedAtUtc.millisecondsSinceEpoch,
    'inbox_count': snapshot.inboxCount,
    'labels': {
      'next_up': l10n.widgetNextUp,
      'now': l10n.widgetNow,
      'nothing_next': l10n.widgetNothingNext,
      'today': l10n.widgetToday,
      'inbox': l10n.widgetInboxCount(snapshot.inboxCount),
    },
    'blocks': [
      for (final b in snapshot.blocks)
        {
          'id': b.id,
          'title': b.title,
          'start_ms': b.startUtc.millisecondsSinceEpoch,
          'end_ms': b.startUtc
              .add(Duration(minutes: b.durationMin))
              .millisecondsSinceEpoch,
          'time': time(b.startUtc),
          'until': l10n.widgetUntil(
            time(b.startUtc.add(Duration(minutes: b.durationMin))),
          ),
          'color': _hex(TaskColor.fromKey(b.colorKey).color.toARGB32()),
          'done': b.done,
        },
    ],
  };
}

Locale _locale(String code) {
  final wanted = Locale(code);
  final known = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == wanted.languageCode,
  );
  return known ? wanted : const Locale('en');
}

String _hex(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
