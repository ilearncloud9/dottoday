/// What a recognised piece of Quick Add text means (docs/02 F2).
enum QuickAddTokenKind { time, date, duration, recurrence, inbox }

/// A recognised span of the input, for highlighting as a removable chip.
///
/// [start]/[end] are UTF-16 offsets into the original text (end exclusive).
final class QuickAddToken {
  const QuickAddToken(this.kind, this.start, this.end);

  final QuickAddTokenKind kind;
  final int start;
  final int end;

  @override
  bool operator ==(Object other) =>
      other is QuickAddToken &&
      other.kind == kind &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(kind, start, end);

  @override
  String toString() => 'QuickAddToken(${kind.name}, $start, $end)';
}

/// The task a line of Quick Add text describes, before the user confirms it.
///
/// Nothing here is persisted; M4.1 turns a draft into an occurrence or
/// series. [title] is whatever text no token claimed (may be empty).
final class QuickAddDraft {
  const QuickAddDraft({
    required this.title,
    this.text = '',
    this.tokens = const [],
    this.date,
    this.minuteOfDay,
    this.durationMin,
    this.rrule,
    this.inbox = false,
    this.startUtc,
  });

  final String title;

  /// The whole line as typed, so nothing is lost when a token can't be
  /// used (e.g. "every Monday" with no time, see `rowsFromDraft`).
  final String text;

  /// Recognised spans in text order.
  final List<QuickAddToken> tokens;

  /// Local calendar date (fields only, UTC-flagged midnight), if one was
  /// named.
  final DateTime? date;

  /// Local time as minutes after midnight (0–1439), if one was named.
  final int? minuteOfDay;

  /// Duration in minutes (5–1440), if one was named.
  final int? durationMin;

  /// RFC 5545 rule body (no `RRULE:` prefix) prefilled from "every …".
  final String? rrule;

  /// Whether `@inbox` asked for no time even if one was typed.
  final bool inbox;

  /// Start instant: [date] (default today) at [minuteOfDay] in the user's
  /// zone. Null without a time, or for [inbox].
  final DateTime? startUtc;

  @override
  String toString() =>
      'QuickAddDraft(tokens: $tokens, date: $date, '
      'minuteOfDay: $minuteOfDay, durationMin: $durationMin, rrule: $rrule, '
      'inbox: $inbox)';
}

/// [draft]'s text without [token]'s span, spaces tidied: what the field
/// holds after the token's chip is removed (docs/02 F2 "removable with one
/// tap").
///
/// ```dart
/// textWithout(parse('Read 9pm 45m'), timeToken); // 'Read 45m'
/// ```
String textWithout(QuickAddDraft draft, QuickAddToken token) {
  final text = draft.text;
  if (token.start < 0 || token.end > text.length) return text;
  return (text.substring(0, token.start) + text.substring(token.end))
      .replaceAll(RegExp(' {2,}'), ' ')
      .trim();
}
