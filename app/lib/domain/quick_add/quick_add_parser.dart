import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_lexicon.dart';
import 'package:dottoday/domain/quick_add/quick_add_patterns.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:timezone/timezone.dart' as tz;

/// Where and when the user is typing: resolves "tomorrow" and "3pm".
final class QuickAddContext {
  const QuickAddContext({
    required this.nowUtc,
    required this.tzId,
    required this.language,
  });

  final DateTime nowUtc;
  final String tzId;
  final QuickAddLanguage language;
}

/// Natural-language Quick Add (docs/02 F2, R-06, R-07, R-20).
///
/// Recognises at most one time, date, duration, recurrence and `@inbox`
/// per line; everything else stays in the title, so unparseable input is
/// never lost. `HH:MM` and `7pm` both work whatever the 12/24-h setting:
/// the setting only changes how chips are displayed.
///
/// ```dart
/// parser.parse('Gym 7am 45m', ctx); // title Gym, 07:00 today, 45 min
/// ```
final class QuickAddParser {
  const QuickAddParser();

  /// Longest text accepted in one paste (06 §7).
  static const maxInputLength = 10000;

  // Bullets and checkboxes from pasted lists: "- ", "* ", "• ", "1. ", "[ ] ".
  static final _bullet = RegExp(r'^\s*(?:[-*•·]|\d{1,3}[.)]|\[[ xX]?\])\s+');
  static final _control = RegExp(r'[\u0000-\u001F\u007F]');
  static final _spaces = RegExp(r'\s+');
  static final _edgePunctuation = RegExp(r'^[\s,;:\-–—]+|[\s,;:\-–—]+$');

  /// Parses one line. Tokens in [ignored] (chips the user removed) are kept
  /// as title text.
  Result<QuickAddDraft, ValidationFailure> parse(
    String text,
    QuickAddContext context, {
    List<QuickAddToken> ignored = const [],
  }) {
    if (text.length > maxInputLength) return _tooLong();
    return Ok(_parseLine(text, context, ignored));
  }

  /// Parses a multi-line paste into one draft per non-empty line, list
  /// bullets removed (R-07).
  Result<List<QuickAddDraft>, ValidationFailure> parseMany(
    String text,
    QuickAddContext context,
  ) {
    if (text.length > maxInputLength) return _tooLong();
    return Ok([
      for (final line in text.split(RegExp(r'\r\n|\r|\n')))
        if (line.replaceFirst(_bullet, '').trim() case final clean
            when clean.isNotEmpty)
          _parseLine(clean, context, const []),
    ]);
  }

  static Err<T, ValidationFailure> _tooLong<T>() => const Err(
    ValidationFailure(ValidationField.quickAddText, ValidationRule.tooLong),
  );

  QuickAddDraft _parseLine(
    String raw,
    QuickAddContext context,
    List<QuickAddToken> ignored,
  ) {
    // Control characters become spaces so token offsets match the field.
    final text = raw.replaceAll(_control, ' ');
    final scan = _Scan(text, ignored);
    final p = QuickAddPatterns.of(context.language);
    final inbox = scan.claim(QuickAddTokenKind.inbox, [
      QuickAddRule<bool>(p.inbox, (_) => true),
    ]);
    final rrule = scan.claim(QuickAddTokenKind.recurrence, p.recurrence);
    final duration = scan.claim(QuickAddTokenKind.duration, p.duration);
    final dateSpec = scan.claim(QuickAddTokenKind.date, p.date);
    final minute = scan.claim(QuickAddTokenKind.time, p.time);

    final location = tz.getLocation(context.tzId);
    final now = utcToWallClock(location, context.nowUtc);
    final today = DateTime.utc(now.year, now.month, now.day);
    final date = dateSpec == null ? null : _resolve(dateSpec, today);
    final isInbox = inbox ?? false;
    return QuickAddDraft(
      title: scan.title().replaceAll(_edgePunctuation, ''),
      tokens: scan.tokens..sort((a, b) => a.start.compareTo(b.start)),
      date: date,
      minuteOfDay: minute,
      durationMin: duration,
      rrule: rrule,
      inbox: isInbox,
      startUtc: isInbox || minute == null
          ? null
          : wallClockToUtc(
              location,
              (date ?? today).add(Duration(minutes: minute)),
            ),
    );
  }

  /// "friday" is the next Friday on or after today; "next friday" the next
  /// one strictly after today.
  static DateTime _resolve(DateSpec spec, DateTime today) {
    final weekday = spec.weekday;
    var days = spec.daysAhead ?? 0;
    if (weekday != null) {
      days = (weekday - (today.weekday - 1)) % 7;
      if (days == 0 && spec.next) days = 7;
    }
    return DateTime.utc(today.year, today.month, today.day + days);
  }
}

/// Mutable scanning state for one line: claims spans in priority order and
/// masks them so later kinds cannot reuse the same words.
final class _Scan {
  _Scan(this.text, List<QuickAddToken> ignored) : _working = text {
    for (final t in ignored) {
      if (t.start >= 0 && t.end <= text.length && t.start < t.end) _mask(t);
    }
  }

  final String text;
  String _working;
  final tokens = <QuickAddToken>[];

  /// Claims the earliest valid match of any rule (longest on ties).
  T? claim<T>(QuickAddTokenKind kind, List<QuickAddRule<T>> rules) {
    (RegExpMatch, T)? best;
    for (final rule in rules) {
      for (final m in rule.pattern.allMatches(_working)) {
        final value = rule.read(m);
        if (value == null) continue;
        final b = best?.$1;
        if (b == null ||
            m.start < b.start ||
            (m.start == b.start && m.end > b.end)) {
          best = (m, value);
        }
        break;
      }
    }
    if (best == null) return null;
    final token = QuickAddToken(kind, best.$1.start, best.$1.end);
    tokens.add(token);
    _mask(token);
    return best.$2;
  }

  void _mask(QuickAddToken t) {
    _working = _working.replaceRange(t.start, t.end, ' ' * (t.end - t.start));
  }

  /// [text] without claimed spans, whitespace collapsed.
  String title() {
    final buffer = StringBuffer();
    var at = 0;
    for (final t in [...tokens]..sort((a, b) => a.start.compareTo(b.start))) {
      buffer
        ..write(text.substring(at, t.start))
        ..write(' ');
      at = t.end;
    }
    buffer.write(text.substring(at));
    return buffer.toString().replaceAll(QuickAddParser._spaces, ' ').trim();
  }
}
