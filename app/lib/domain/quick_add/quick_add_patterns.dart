import 'package:dottoday/domain/quick_add/quick_add_lexicon.dart';

// Regexes compiled from a [QuickAddLexicon], one set per language.

/// A pattern plus how to read a value from its match; `null` rejects the
/// match (e.g. hour 25) so the text stays in the title.
final class QuickAddRule<T> {
  const QuickAddRule(this.pattern, this.read);

  final RegExp pattern;
  final T? Function(RegExpMatch match) read;
}

/// A named date: [daysAhead] from today, or the next [weekday] (0 = Monday),
/// strictly after today when [next].
typedef DateSpec = ({int? daysAhead, int? weekday, bool next});

// Unicode-aware word boundaries (`\b` is ASCII-only).
const _l = r'(?<![\p{L}\p{N}])';
const _r = r'(?![\p{L}\p{N}])';

RegExp _re(String source) =>
    RegExp(source, caseSensitive: false, unicode: true);

/// Alternation of [words], longest first so "tues" beats "tue".
String _alt(Iterable<String> words) {
  final sorted = words.toList()..sort((a, b) => b.length.compareTo(a.length));
  return sorted.map((w) => RegExp.escape(w).replaceAll(' ', r'\s+')).join('|');
}

/// Optional connector word(s) followed by whitespace, e.g. "at ".
String _connector(List<String> words) =>
    words.isEmpty ? '' : '(?:(?:${_alt(words)})\\s+)?';

int? _clock(int hour, int minute) =>
    hour <= 23 && minute <= 59 ? hour * 60 + minute : null;

int _int(String? digits) => digits == null ? 0 : int.parse(digits);

/// Compiled Quick Add patterns for one language.
final class QuickAddPatterns {
  QuickAddPatterns._(QuickAddLexicon lex)
    : weekdayIndex = {
        for (var i = 0; i < 7; i++)
          for (final alias in lex.weekdays[i]) alias: i,
      },
      _lex = lex;

  static final _cache = <QuickAddLanguage, QuickAddPatterns>{};

  static QuickAddPatterns of(QuickAddLanguage language) => _cache.putIfAbsent(
    language,
    () => QuickAddPatterns._(QuickAddLexicon.of(language)),
  );

  final QuickAddLexicon _lex;

  /// Lowercase weekday alias → 0 (Monday) … 6.
  final Map<String, int> weekdayIndex;

  late final String _weekdayAlt = _alt(weekdayIndex.keys);

  /// Finds weekday names inside a matched "every mon, wed" list.
  late final RegExp weekdayWord = _re(_weekdayAlt);

  late final RegExp inbox = _re('$_l@inbox$_r');

  /// Rules yielding minutes after midnight.
  late final List<QuickAddRule<int>> time = [
    QuickAddRule(
      _re(
        '$_l$_timeConn(?:(?<noon>${_alt(_lex.noon)})|'
        '(?<mid>${_alt(_lex.midnight)}))$_r',
      ),
      (m) => m.namedGroup('noon') != null ? 12 * 60 : 0,
    ),
    if (_lex.amPm)
      QuickAddRule(
        _re(
          '$_l$_timeConn(?<h>\\d{1,2})(?:[:.](?<m>\\d{2}))?\\s?'
          '(?<ap>[ap])\\.?m\\.?(?![\\p{L}\\p{N}])',
        ),
        _amPm,
      ),
    if (_lex.hourSuffix.isNotEmpty)
      QuickAddRule(
        _re(
          '$_l$_timeConn(?<h>\\d{1,2})(?:[:.](?<m>\\d{2}))?\\s?'
          '(?:${_alt(_lex.hourSuffix)})$_r',
        ),
        _twentyFourHour,
      ),
    if (_lex.hourLetterIsTime)
      QuickAddRule(
        _re('$_l$_timeConn(?<h>\\d{1,2})\\s?h(?:\\s?(?<m>\\d{2}))?$_r'),
        _twentyFourHour,
      ),
    QuickAddRule(
      _re('$_l$_timeConn(?<h>\\d{1,2}):(?<m>\\d{2})$_r'),
      _twentyFourHour,
    ),
  ];

  String get _timeConn => _connector(_lex.timeConnectors);

  static int? _twentyFourHour(RegExpMatch m) =>
      _clock(_int(m.namedGroup('h')), _int(m.namedGroup('m')));

  static int? _amPm(RegExpMatch m) {
    final hour = _int(m.namedGroup('h'));
    if (hour < 1 || hour > 12) return null;
    final pm = m.namedGroup('ap')!.toLowerCase() == 'p';
    return _clock(hour % 12 + (pm ? 12 : 0), _int(m.namedGroup('m')));
  }

  /// Rules yielding a [DateSpec].
  late final List<QuickAddRule<DateSpec>> date = [
    QuickAddRule(
      _re(
        '$_l$_dateConn(?:(?<d2>${_alt(_lex.dayAfterTomorrow)})|'
        '(?<d1>${_alt(_lex.tomorrow)})|(?<d0>${_alt(_lex.today)}))$_r',
      ),
      (m) => (
        daysAhead: m.namedGroup('d2') != null
            ? 2
            : (m.namedGroup('d1') != null ? 1 : 0),
        weekday: null,
        next: false,
      ),
    ),
    QuickAddRule(
      _re(
        '$_l$_dateConn'
        '${_lex.nextBefore.isEmpty ? '' : '(?:(?<nb>${_alt(_lex.nextBefore)})\\s+)?'}'
        '(?<wd>$_weekdayAlt)'
        '${_lex.nextAfter.isEmpty ? '' : '(?:\\s+(?<na>${_alt(_lex.nextAfter)}))?'}'
        '$_r',
      ),
      (m) => (
        daysAhead: null,
        weekday: weekdayIndex[m.namedGroup('wd')!.toLowerCase()],
        next: _hasGroup(m, 'nb') || _hasGroup(m, 'na'),
      ),
    ),
  ];

  String get _dateConn => _connector(_lex.dateConnectors);

  static bool _hasGroup(RegExpMatch m, String name) =>
      m.groupNames.contains(name) && m.namedGroup(name) != null;

  /// Rules yielding a duration in minutes (5–1440).
  late final List<QuickAddRule<int>> duration = [
    QuickAddRule(
      _re(
        '$_l$_durConn(?<h>\\d+(?:[.,]\\d+)?)\\s?(?:${_alt(_lex.hourUnits)})'
        '(?:(?<hm>\\d{2})|\\s?(?<hm2>\\d{1,2})\\s?(?:$_minAlt))?$_r',
      ),
      (m) => _minutes(
        double.parse(m.namedGroup('h')!.replaceAll(',', '.')) * 60 +
            _int(m.namedGroup('hm') ?? m.namedGroup('hm2')),
      ),
    ),
    QuickAddRule(
      _re('$_l$_durConn(?<m>\\d+)\\s?(?:$_minAlt)$_r'),
      (m) => _minutes(_int(m.namedGroup('m')).toDouble()),
    ),
  ];

  String get _durConn => _connector(_lex.durationConnectors);
  String get _minAlt => _alt(_lex.minuteUnits);

  static int? _minutes(double value) {
    final minutes = value.round();
    return minutes >= 5 && minutes <= 1440 ? minutes : null;
  }

  /// Rules yielding an RRULE body.
  late final List<QuickAddRule<String>> recurrence = [
    QuickAddRule(
      _re(
        '$_l(?:$_every)\\s+(?:(?<n>\\d{1,3})\\s+'
        '${_lex.other.isEmpty ? '' : '|(?<o>${_alt(_lex.other)})\\s+'})?'
        '(?:(?<d>${_alt(_lex.dayUnits)})|(?<w>${_alt(_lex.weekUnits)})|'
        '(?<mo>${_alt(_lex.monthUnits)})|(?<y>${_alt(_lex.yearUnits)}))$_r',
      ),
      _unitRule,
    ),
    QuickAddRule(
      _re(
        '$_l(?:$_every)\\s+(?<list>(?:$_weekdayAlt)s?'
        '(?:$_joiner(?:$_weekdayAlt)s?)*)$_r',
      ),
      _listRule,
    ),
    QuickAddRule(
      _re('$_l(?:(?:$_every)\\s+)?(?:${_alt(_lex.workdays)})$_r'),
      (_) => 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',
    ),
    QuickAddRule(
      _re(
        '$_l(?:(?<d>${_alt(_lex.daily)})|(?<w>${_alt(_lex.weekly)})|'
        '(?<mo>${_alt(_lex.monthly)})|(?<y>${_alt(_lex.yearly)}))$_r',
      ),
      (m) => 'FREQ=${_freq(m)}',
    ),
  ];

  String get _every => _alt(_lex.every);

  String get _joiner {
    final words = _lex.listJoiners.where((j) => j != ',' && j != '&');
    final spoken = words.isEmpty ? '' : '|\\s+(?:${_alt(words)})\\s+';
    return '(?:\\s*[,&]\\s*$spoken)';
  }

  static String _freq(RegExpMatch m) {
    if (m.namedGroup('d') != null) return 'DAILY';
    if (m.namedGroup('w') != null) return 'WEEKLY';
    if (m.namedGroup('mo') != null) return 'MONTHLY';
    return 'YEARLY';
  }

  String? _unitRule(RegExpMatch m) {
    final n = _hasGroup(m, 'o') ? 2 : _int(m.namedGroup('n'));
    if (m.namedGroup('n') != null && n < 1) return null;
    return 'FREQ=${_freq(m)}${n > 1 ? ';INTERVAL=$n' : ''}';
  }

  static const _byDay = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

  String? _listRule(RegExpMatch m) {
    final days = {
      for (final w in weekdayWord.allMatches(m.namedGroup('list')!))
        weekdayIndex[w.group(0)!.toLowerCase()]!,
    }.toList()..sort();
    return 'FREQ=WEEKLY;BYDAY=${days.map((d) => _byDay[d]).join(',')}';
  }
}
