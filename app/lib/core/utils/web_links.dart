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
    final raw = m.group(0)!.replaceFirst(_trailing, '');
    if (raw.length > _maxLinkLength) continue;
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.host.isEmpty || out.contains(uri)) continue;
    out.add(uri);
    if (out.length == maxWebLinks) break;
  }
  return out;
}
