import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/entities/icon_keys.dart';
import 'package:dottoday/domain/entities/task_color_keys.gen.dart';
import 'package:dottoday/domain/quick_add/draft_rows.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:timezone/timezone.dart' as tz;

/// The task the Add flow is building (docs/10 §3 `AddFlow`, M3c).
///
/// Each value comes from the most deliberate source that set it: a choice
/// made on step 2 (or the colour row), then what was typed ("Go shopping
/// 5pm 1h", R-06), then the picked [habit], then the defaults. So typing
/// never overwrites a time the user picked, and clearing the typed time
/// falls back to the habit's usual one (docs/10 §6 "Add never asks for
/// what it can infer").
///
/// ```dart
/// final d = AddDraft(today: wed, tzId: 'Europe/Berlin', defaultDurationMin: 30)
///     .withTyped(parse('Go shopping 5pm 1h'));
/// d.startMinute; // 1020
/// ```
final class AddDraft {
  const AddDraft({
    required this.today,
    required this.tzId,
    required this.defaultDurationMin,
    this.typed = const QuickAddDraft(title: ''),
    this.habit,
    this.colorKey,
    this.iconKey,
    this.date,
    this.minuteOfDay,
    this.durationMin,
    this.allDay = false,
  });

  /// Local calendar date of today (y/m/d).
  final DateTime today;

  /// Zone the task is planned in (Time ⋯ › Time zone, M3c.4).
  final String tzId;
  final int defaultDurationMin;

  /// The parsed title field.
  final QuickAddDraft typed;

  /// The suggestion the user picked, or the one the title matches exactly.
  final HabitSuggestion? habit;

  /// Explicit choices; null falls through to [typed], [habit], defaults.
  final String? colorKey;
  final String? iconKey;
  final DateTime? date;
  final int? minuteOfDay;
  final int? durationMin;

  /// Time ⋯ › Make it all-day: local midnight for 24 h (M3c.4).
  final bool allDay;

  /// Title without the recognised tokens.
  String get title => typed.title.trim();

  String get color => colorKey ?? habit?.colorKey ?? defaultTaskColorKey;
  String get icon => iconKey ?? habit?.iconKey ?? defaultIconKey;

  /// The local day it lands on.
  DateTime get day => date ?? typed.date ?? today;

  /// Local start, minutes after midnight; null means no time yet.
  int? get startMinute =>
      allDay ? 0 : minuteOfDay ?? typed.minuteOfDay ?? habit?.minuteOfDay;

  int get length => allDay
      ? Duration.minutesPerDay
      : durationMin ??
            typed.durationMin ??
            habit?.durationMin ??
            defaultDurationMin;

  /// "every …" from the title (R-01 prefill).
  String? get rrule => typed.rrule;

  /// Whether `@inbox` was typed.
  bool get inbox => typed.inbox;

  /// Start instant in [tzId], or null without a time.
  DateTime? get startUtc {
    final minute = startMinute;
    if (minute == null) return null;
    return ClockTime.fromMinutes(minute).onDate(tz.getLocation(tzId), day);
  }

  AddDraft withTyped(QuickAddDraft value) => _copy(typed: value);

  AddDraft withHabit(HabitSuggestion? value) => _copy(habit: () => value);

  AddDraft withColor(String key) => _copy(colorKey: () => key);

  AddDraft withIcon(String key) => _copy(iconKey: () => key);

  AddDraft withDay(DateTime value) =>
      _copy(date: () => DateTime(value.year, value.month, value.day));

  AddDraft withStartMinute(int value) =>
      _copy(minuteOfDay: () => value, allDay: false);

  AddDraft withDuration(int minutes) =>
      _copy(durationMin: () => minutes, allDay: false);

  AddDraft withZone(String value) => _copy(tzId: value);

  AddDraft withAllDay({required bool value}) => _copy(allDay: value);

  /// Rows to write: a series for a timed "every …", else one occurrence;
  /// with no time (or [toInbox]) an inbox item (docs/02 F2). The colour
  /// and icon apply to either.
  DraftRows toRows({
    required String userId,
    required DateTime nowUtc,
    required String untitled,
    bool toInbox = false,
    IdGenerator ids = const UuidV7Generator(),
  }) {
    final start = toInbox || inbox ? null : startUtc;
    final rows = rowsFromDraft(
      QuickAddDraft(
        title: title,
        text: typed.text,
        rrule: allDay ? null : rrule,
        durationMin: length,
        startUtc: start,
        inbox: start == null,
      ),
      userId: userId,
      tzId: tzId,
      nowUtc: nowUtc,
      defaultDurationMin: defaultDurationMin,
      untitled: untitled,
      ids: ids,
    );
    return (
      series: rows.series?.copyWith(colorKey: color, iconKey: icon),
      occurrence: rows.occurrence?.copyWith(colorKey: color, iconKey: icon),
    );
  }

  AddDraft _copy({
    QuickAddDraft? typed,
    HabitSuggestion? Function()? habit,
    String? Function()? colorKey,
    String? Function()? iconKey,
    DateTime? Function()? date,
    int? Function()? minuteOfDay,
    int? Function()? durationMin,
    String? tzId,
    bool? allDay,
  }) => AddDraft(
    today: today,
    tzId: tzId ?? this.tzId,
    defaultDurationMin: defaultDurationMin,
    typed: typed ?? this.typed,
    habit: habit == null ? this.habit : habit(),
    colorKey: colorKey == null ? this.colorKey : colorKey(),
    iconKey: iconKey == null ? this.iconKey : iconKey(),
    date: date == null ? this.date : date(),
    minuteOfDay: minuteOfDay == null ? this.minuteOfDay : minuteOfDay(),
    durationMin: durationMin == null ? this.durationMin : durationMin(),
    allDay: allDay ?? this.allDay,
  );
}
