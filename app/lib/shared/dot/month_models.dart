import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
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

/// One day of a [MonthGrid]; display values from the feature.
@immutable
final class MonthDay {
  const MonthDay({
    required this.date,
    required this.label,
    this.completion,
    this.planned = const [],
    this.repeatsOnly = false,
    this.items = const [],
    this.done = 0,
    this.total = 0,
    this.isPast = false,
    this.isToday = false,
    this.isLight = false,
  });

  /// "21".
  final String date;

  /// Screen-reader label, e.g. "Monday 19 October, 4 of 4 done".
  final String label;

  /// The completion dot (compact) or badge (expanded); `Completion.none()`
  /// draws an outline (days ahead in this month), null draws nothing.
  final Completion? completion;

  /// Future days: colours of what is planned, one dot each (max 3 drawn,
  /// `A-ios-future-month`).
  final List<TaskColor> planned;

  /// Only repeats fall on this future day: a small outline dot
  /// (`A-ios-future-month` legend "○ repeats").
  final bool repeatsOnly;

  /// Expanded cells: the day's tasks in order.
  final List<MonthItem> items;
  final int done;
  final int total;
  final bool isPast;
  final bool isToday;

  /// Few tasks: "Light day" (`A-mac-month`).
  final bool isLight;
}
