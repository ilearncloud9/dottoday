import 'package:dottoday/core/utils/web_links.dart';
import 'package:flutter/foundation.dart';

/// How a line of notes is laid out (docs/02 F2.9 "markdown-lite").
enum NoteLineKind {
  /// Plain text.
  text,

  /// `- item`, `* item` or `• item`.
  bullet,

  /// `1. item` or `1) item`; [NoteLine.marker] holds the number.
  numbered,

  /// An empty line: a gap between paragraphs.
  gap,
}

/// One run of text with its emphasis and, for a link, where it goes.
@immutable
final class NoteSpan {
  const NoteSpan(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.link,
  });

  final String text;
  final bool bold;
  final bool italic;

  /// A web link (http/https with a host); null for plain text.
  final Uri? link;

  @override
  bool operator ==(Object other) =>
      other is NoteSpan &&
      other.text == text &&
      other.bold == bold &&
      other.italic == italic &&
      other.link == link;

  @override
  int get hashCode => Object.hash(text, bold, italic, link);

  @override
  String toString() =>
      'NoteSpan($text${bold ? ', bold' : ''}${italic ? ', italic' : ''}'
      '${link == null ? '' : ', $link'})';
}

/// One line of notes: its kind, the list number, and its spans.
@immutable
final class NoteLine {
  const NoteLine(this.kind, this.spans, {this.marker});

  final NoteLineKind kind;
  final List<NoteSpan> spans;

  /// The number of a [NoteLineKind.numbered] line, as typed ("3").
  final String? marker;
}

final _bullet = RegExp(r'^\s*[-*•]\s+(.*)$');
final _numbered = RegExp(r'^\s*(\d{1,3})[.)]\s+(.*)$');

/// Bold, label-link, bare link, then italic: the first that matches at a
/// position wins, so `**` is never read as two italics.
final _inline = RegExp(
  r'\*\*(.+?)\*\*'
  r'|__(.+?)__'
  r'|\[([^\]\n]+)\]\((https?://[^\s)]+)\)'
  r'|(https?://[^\s<>"]+)'
  r'|\*(?=\S)(.+?)(?<=\S)\*'
  r'|(?<![\w])_(?=\S)(.+?)(?<=\S)_(?![\w])',
  caseSensitive: false,
);

/// Notes as markdown-lite lines (docs/02 F2.9): `**bold**`/`__bold__`,
/// `*italic*`/`_italic_`, `- ` / `* ` bullets, `1. ` numbered items,
/// `[label](https://…)` and bare web links. Everything else, headings and
/// code included, stays the text it was typed as. Total: any input gives
/// lines, never throws; a link that isn't a safe web link stays text
/// (06 §7).
///
/// ```dart
/// parseNotes('- **Bring** the [deck](https://x.io/d)');
/// // [NoteLine(bullet, [NoteSpan('Bring', bold), NoteSpan(' the '),
/// //   NoteSpan('deck', link: https://x.io/d)])]
/// ```
List<NoteLine> parseNotes(String? notes) {
  if (notes == null || notes.trim().isEmpty) return const [];
  final lines = <NoteLine>[];
  for (final raw in notes.trimRight().split('\n')) {
    final line = raw.trimRight();
    if (line.trim().isEmpty) {
      // One gap for any run of blank lines.
      if (lines.isNotEmpty && lines.last.kind != NoteLineKind.gap) {
        lines.add(const NoteLine(NoteLineKind.gap, []));
      }
      continue;
    }
    lines.add(_line(line));
  }
  return lines;
}

NoteLine _line(String line) {
  if (_numbered.firstMatch(line) case final m?) {
    return NoteLine(
      NoteLineKind.numbered,
      parseInline(m.group(2)!),
      marker: m.group(1),
    );
  }
  if (_bullet.firstMatch(line) case final m?) {
    return NoteLine(NoteLineKind.bullet, parseInline(m.group(1)!));
  }
  return NoteLine(NoteLineKind.text, parseInline(line));
}

/// The spans of one line of markdown-lite (see [parseNotes]); emphasis
/// nests one level (`**bold _and italic_**`).
List<NoteSpan> parseInline(
  String text, {
  bool bold = false,
  bool italic = false,
}) {
  final out = <NoteSpan>[];
  var at = 0;
  void plain(String s) {
    if (s.isNotEmpty) out.add(NoteSpan(s, bold: bold, italic: italic));
  }

  for (final m in _inline.allMatches(text)) {
    plain(text.substring(at, m.start));
    at = m.end;
    if (m.group(1) ?? m.group(2) case final inner?) {
      out.addAll(parseInline(inner, bold: true, italic: italic));
    } else if (m.group(3) case final label?) {
      final uri = webLinkOf(m.group(4)!);
      out.add(NoteSpan(label, bold: bold, italic: italic, link: uri));
    } else if (m.group(5) case final bare?) {
      at = _bareLink(out, bare, m.start, bold: bold, italic: italic);
    } else {
      final inner = m.group(6) ?? m.group(7)!;
      out.addAll(parseInline(inner, bold: bold, italic: true));
    }
  }
  plain(text.substring(at));
  return out;
}

/// Adds a bare link (without the sentence punctuation after it) and
/// returns where the text resumes, so "see https://x.io." keeps its dot.
int _bareLink(
  List<NoteSpan> out,
  String bare,
  int start, {
  required bool bold,
  required bool italic,
}) {
  final shown = trimLinkEnd(bare);
  final uri = webLinkOf(shown);
  // An unsafe or overlong "link" stays text, in full.
  final text = uri == null ? bare : shown;
  out.add(NoteSpan(text, bold: bold, italic: italic, link: uri));
  return start + text.length;
}
