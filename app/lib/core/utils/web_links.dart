/// The most links a task shows (a pasted agenda can hold dozens).
const maxWebLinks = 5;

/// The longest link kept; anything longer is not a link a person tapped.
const _maxLinkLength = 2048;

final _candidate = RegExp(r'https?://[^\s<>"]+', caseSensitive: false);

/// Punctuation that ends a sentence rather than a link.
final _trailing = RegExp(r'''[.,;:!?'")\]}]+$''');

/// The web links in [text], in order, without repeats, at most
/// [maxWebLinks] (docs/02 F5 "links in event descriptions open in the
/// browser", R-02). Only http(s) with a host: a tap can only open a
/// browser, never another app's scheme (06 §7).
///
/// ```dart
/// webLinks('Join: https://meet.example.com/abc. Agenda attached.');
/// // [https://meet.example.com/abc]
/// ```
List<Uri> webLinks(String? text) {
  if (text == null || text.isEmpty) return const [];
  final out = <Uri>[];
  for (final m in _candidate.allMatches(text)) {
    final uri = webLinkOf(m.group(0)!);
    if (uri == null || out.contains(uri)) continue;
    out.add(uri);
    if (out.length == maxWebLinks) break;
  }
  return out;
}

/// [raw] as a web link a tap may open, or null: trailing sentence
/// punctuation dropped, http(s) only, with a host, at most 2048 chars
/// (06 §7). Shared by [webLinks] and the notes renderer, so a link reads
/// the same in both.
///
/// ```dart
/// webLinkOf('https://example.com/a).'); // https://example.com/a
/// webLinkOf('mailto:x@example.com'); // null
/// ```
Uri? webLinkOf(String raw) {
  final trimmed = trimLinkEnd(raw);
  if (trimmed.length > _maxLinkLength) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.host.isEmpty) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  return uri;
}

/// [raw] without the sentence punctuation that ended it ("x.io/a)." →
/// "x.io/a").
String trimLinkEnd(String raw) => raw.replaceFirst(_trailing, '');
