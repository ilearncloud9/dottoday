import 'dart:ui' show Locale;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/task_palette.dart';
import 'package:dottoday/data/widgets/app_colour_tones.dart';
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
      ..['color'] = _hex(TaskColor.fromKey(dot.colorKey).color.toARGB32())
      // Dark mode's lighter step of the same colour (E-R2-17-Dark).
      ..['color_dark'] = _hex(TaskColor.fromKey(dot.colorKey).dark.toARGB32())
      // Today's one thing (docs/15 §8): a ring and the label below.
      ..['one_thing'] = dot.id == snapshot.oneThingId;
  }
  return json
    ..['labels'] = {
      'next_up': l10n.widgetNextUp,
      'now': l10n.widgetNow,
      'nothing_next': l10n.widgetNothingNext,
      'today': l10n.widgetToday,
      'inbox': l10n.widgetInboxCount(snapshot.inboxCount),
      // Next up's Done button (M9.5) and the menu bar's Done / +15 (M9.6).
      'done': l10n.notifActionDone,
      'plus': l10n.liveExtend,
      'one_thing': l10n.oneThingMeta,
      // The Inbox widget's header (E-R2-17).
      'inbox_title': l10n.navInbox,
    }
    // The App colour (ED-221) in light and dark: the day dot and the now
    // ring's "Now" on every widget (M20.9 part 3, owner: follow it).
    ..['accent'] = appColourTones(profile)
    // The Mac Now mini window's words (E-Minimal, M20.9 part 7, ED-475):
    // `{n}` is a number of minutes, `{title}` the next task's.
    ..['now_window'] = _nowWindow(l10n, time(snapshot.bedUtc))
    // How to write a time again after an optimistic +15 in Swift or Kotlin
    // (M9.2): the zone, the language, the clock and the "until" pattern.
    ..['format'] = {
      'tz': profile.tzId,
      'locale': _locale(profile.locale).languageCode,
      'hour24': use24h,
      'until': l10n.widgetUntil(timePlaceholder),
      // Today's "3 of 10 done" (E-R2-17), counted where the dots are, so
      // a Done from the widget moves it at once.
      'done_of': l10n
          .monthDoneOf(_doneMark, _totalMark)
          .replaceAll('$_doneMark', donePlaceholder)
          .replaceAll('$_totalMark', totalPlaceholder),
    };
}

/// Where a number of minutes goes in `now_window` patterns.
const minutesPlaceholder = '{n}';
const titlePlaceholder = '{title}';
const _minutesMark = 735192846;

Map<String, String> _nowWindow(AppLocalizations l10n, String windDown) {
  String n(String s) => s.replaceAll('$_minutesMark', minutesPlaceholder);
  final minutes = l10n.durationMinutes(_minutesMark);
  return {
    'left': n(l10n.liveActivityLeft(minutes)),
    'starts_in': n(l10n.liveActivityStartsIn(minutes)),
    'ended': n(l10n.nowWindowEnded(_minutesMark)),
    'next': l10n.nowWindowNext(titlePlaceholder),
    'hours': n(l10n.durationChipHours('$_minutesMark')),
    'wind_down': l10n.nowWindDown(windDown),
    'need_more': l10n.lateNudgeTitle,
    'plus': n(l10n.inspectorExtendChip(_minutesMark)),
    'plus_label': n(l10n.inspectorExtendLabel(_minutesMark)),
  };
}

/// Where the counts go in `format.done_of` (`{done} of {total} done`).
const donePlaceholder = '{done}';
const totalPlaceholder = '{total}';
const _doneMark = 918273645;
const _totalMark = 546372819;

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
