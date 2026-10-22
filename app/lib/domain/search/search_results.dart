import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:timezone/timezone.dart' as tz;

/// The Search filter chips (`A-ios-search`): All, Today, This week, Inbox,
/// Done, then one colour or icon.
sealed class SearchFilter {
  const SearchFilter();
}

/// Every match.
final class AnyResult extends SearchFilter {
  const AnyResult();
}

/// Matches on today's local date.
final class TodayResults extends SearchFilter {
  const TodayResults();
}

/// Matches in the week holding today (Settings › Week starts).
final class WeekResults extends SearchFilter {
  const WeekResults();
}

/// Matches with no start.
final class InboxResults extends SearchFilter {
  const InboxResults();
}

/// Done matches (R-11 "completed history").
final class DoneResults extends SearchFilter {
  const DoneResults();
}

/// Matches in one task colour.
final class ColourResults extends SearchFilter {
  const ColourResults(this.colorKey);

  final String colorKey;

  @override
  bool operator ==(Object other) =>
      other is ColourResults && other.colorKey == colorKey;

  @override
  int get hashCode => colorKey.hashCode;
}

/// Matches with one icon.
final class IconResults extends SearchFilter {
  const IconResults(this.iconKey);

  final String iconKey;

  @override
  bool operator ==(Object other) =>
      other is IconResults && other.iconKey == iconKey;

  @override
  int get hashCode => iconKey.hashCode;
}

/// A heading of the results list: a local date, or the Inbox.
sealed class ResultGroup {
  const ResultGroup();
}

/// Results on [date] (local, y/m/d).
final class DayGroup extends ResultGroup {
  const DayGroup(this.date);

  final DateTime date;

  @override
  bool operator ==(Object other) => other is DayGroup && other.date == date;

  @override
  int get hashCode => date.hashCode;
}

/// Results with no start.
final class InboxGroup extends ResultGroup {
  const InboxGroup();

  @override
  bool operator ==(Object other) => other is InboxGroup;

  @override
  int get hashCode => 0;
}

/// Local calendar date of [o]'s start in [location], or null (Inbox).
DateTime? localDateOf(Occurrence o, tz.Location location) {
  final start = o.startUtc;
  if (start == null) return null;
  final l = tz.TZDateTime.from(start, location);
  return DateTime(l.year, l.month, l.day);
}

/// Whether [o] passes [filter], seen from [today] in [location] with the
/// week starting on [firstDayOfWeek] (1 = Monday … 7 = Sunday).
bool passes(
  Occurrence o,
  SearchFilter filter, {
  required DateTime today,
  required tz.Location location,
  int firstDayOfWeek = 1,
}) {
  final day = localDateOf(o, location);
  return switch (filter) {
    AnyResult() => true,
    TodayResults() => day == today,
    WeekResults() => day != null && _sameWeek(day, today, firstDayOfWeek),
    InboxResults() => day == null,
    DoneResults() => o.status == OccurrenceStatus.done,
    ColourResults(:final colorKey) => o.colorKey == colorKey,
    IconResults(:final iconKey) => o.iconKey == iconKey,
  };
}

bool _sameWeek(DateTime day, DateTime today, int firstDayOfWeek) {
  DateTime start(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - firstDayOfWeek) % 7);
  return start(day) == start(today);
}

/// [results] (already filtered) under their headings, in display order:
/// Today first, then the other days in date order, then the Inbox
/// (`A-android-search`; the iPhone render puts the Inbox between days —
/// one order on both, §4). Within a group, results keep [results]' order
/// (best match first).
///
/// ```dart
/// groupResults(hits, berlin, today: wed).keys.first; // DayGroup(wed)
/// ```
Map<ResultGroup, List<Occurrence>> groupResults(
  Iterable<Occurrence> results,
  tz.Location location, {
  required DateTime today,
}) {
  final byGroup = <ResultGroup, List<Occurrence>>{};
  for (final o in results) {
    final day = localDateOf(o, location);
    final group = day == null ? const InboxGroup() : DayGroup(day);
    (byGroup[group] ??= []).add(o);
  }
  int rank(ResultGroup g) => switch (g) {
    DayGroup(:final date) when date == today => 0,
    DayGroup() => 1,
    InboxGroup() => 2,
  };
  final keys = byGroup.keys.toList()
    ..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      if (byRank != 0) return byRank;
      if (a is DayGroup && b is DayGroup) return a.date.compareTo(b.date);
      return 0;
    });
  return {for (final k in keys) k: byGroup[k]!};
}

/// Ranges of [text] that a term of [query] matches as a word prefix, as
/// the FTS index does (case- and accent-insensitive), merged and sorted.
/// For the highlight in a result title.
///
/// ```dart
/// matchSpans('Deep work: roadmap', 'road'); // [(11, 15)]
/// ```
List<(int, int)> matchSpans(String text, String query) {
  final terms = [
    for (final t in query.split(RegExp(r'\s+')))
      if (t.trim().isNotEmpty) fold(t.trim()),
  ];
  if (terms.isEmpty) return const [];
  final folded = fold(text);
  final spans = <(int, int)>[];
  for (final word in RegExp(
    r'[\p{L}\p{N}]+',
    unicode: true,
  ).allMatches(folded)) {
    for (final t in terms) {
      if (folded.startsWith(t, word.start)) {
        spans.add((word.start, word.start + t.length));
        break;
      }
    }
  }
  return spans;
}

/// [s] lower-cased with common Latin accents removed, keeping its length
/// so offsets map back to the original.
String fold(String s) {
  final buffer = StringBuffer();
  for (final rune in s.toLowerCase().runes) {
    final c = String.fromCharCode(rune);
    buffer.write(c.length == 1 ? (_accents[c] ?? c) : c);
  }
  return buffer.toString();
}

const _accents = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ä': 'a',
  'ã': 'a',
  'å': 'a',
  'ç': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ñ': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'ö': 'o',
  'õ': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ý': 'y',
  'ÿ': 'y',
};

/// Recent searches: [query] first, no duplicates (case-insensitive), at
/// most [limit].
List<String> withRecent(List<String> recent, String query, {int limit = 5}) {
  final q = query.trim();
  if (q.isEmpty) return recent;
  return [
    q,
    for (final r in recent)
      if (r.toLowerCase() != q.toLowerCase()) r,
  ].take(limit).toList();
}
