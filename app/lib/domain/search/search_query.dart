/// Longest query honoured; the rest is ignored (06 §7 input bounds).
const maxSearchQueryLength = 200;

/// Most terms honoured, so a pasted paragraph can't build a huge query.
const maxSearchTerms = 8;

/// An FTS5 `MATCH` expression for what the user typed, or null if there is
/// nothing to search for.
///
/// Every term is quoted (FTS5 operators like `OR`, `NEAR`, `-`, `:` and
/// `*` become plain text) and prefix-matched, and all terms must match.
/// Embedded `"` are doubled, per FTS5 string syntax.
///
/// ```dart
/// ftsQuery('dent appt'); // '"dent"* "appt"*'
/// ftsQuery('a OR b');   // '"a"* "OR"* "b"*'
/// ```
String? ftsQuery(String input) {
  final bounded = input.length > maxSearchQueryLength
      ? input.substring(0, maxSearchQueryLength)
      : input;
  final terms = bounded
      .split(RegExp(r'\s+'))
      .map((t) => t.replaceAll(RegExp(r'[\x00-\x1F]'), ''))
      .where((t) => t.isNotEmpty)
      .take(maxSearchTerms)
      .map((t) => '"${t.replaceAll('"', '""')}"*');
  final query = terms.join(' ');
  return query.isEmpty ? null : query;
}
