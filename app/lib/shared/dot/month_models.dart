import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/foundation.dart';

/// A task inside an expanded month cell (`A-mac-month`).
@immutable
final class MonthItem {
  const MonthItem({
    required this.title,
    required this.color,
    this.done = false,
    this.missed = false,
    this.now = false,
  });

  final String title;
  final TaskColor color;

  /// Struck through.
  final bool done;

  /// Outline dot and "· missed".
  final bool missed;

  /// The live task: accent and "· now".
  final bool now;
}

/// One task's dot in a compact month cell (E-Phones Calendar, ED-075):
/// its colour, filled once done, a ring while not.
@immutable
final class MonthDot {
  const MonthDot(this.color, {this.filled = false});

  final TaskColor color;
  final bool filled;
}

/// One day of a [MonthGrid]; display values from the feature.
@immutable
final class MonthDay {
  const MonthDay({
    required this.date,
    required this.label,
    this.dots = const [],
    this.more = 0,
    this.items = const [],
    this.done = 0,
    this.total = 0,
    this.isPast = false,
    this.isToday = false,
    this.isLight = false,
    this.outside = false,
    this.tinted = false,
    this.ringed = false,
  });

  /// "21".
  final String date;

  /// Screen-reader label, e.g. "Monday 19 October, 4 of 4 done".
  final String label;

  /// Compact cells: the day's first three tasks as dots (E-Phones
  /// Calendar: "at most three, then +n").
  final List<MonthDot> dots;

  /// Compact cells: the tasks past [dots], drawn as "+n".
  final int more;

  /// Expanded cells: the day's tasks in order.
  final List<MonthItem> items;
  final int done;
  final int total;
  final bool isPast;
  final bool isToday;

  /// Nothing planned: "Light day" (E-R2-30).
  final bool isLight;

  /// A day of the month before or after, filling the first or last week
  /// (E-R2-30): its number only, faded, no card and no tap.
  final bool outside;

  /// Go to date (E-R2-36): a day of the week on show, tinted.
  final bool tinted;

  /// Go to date: today, ringed when it isn't the day on show.
  final bool ringed;
}
