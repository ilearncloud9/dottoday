import 'package:intl/intl.dart';

/// [day]'s narrow weekday in [locale] ("W" for Wednesday; CLDR's one-letter
/// form): what a week strip shows when the short name no longer fits its
/// column (large text on a phone). intl has no named constructor for it.
///
/// ```dart
/// narrowWeekday('en', DateTime(2026, 10, 21)); // 'W'
/// ```
String narrowWeekday(String locale, DateTime day) =>
    DateFormat('EEEEE', locale).format(day);
