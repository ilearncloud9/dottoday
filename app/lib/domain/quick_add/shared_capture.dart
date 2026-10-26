import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/validation/field_rules.dart';

// Capture anywhere (11 B6, docs/09 M12.4): text or a link shared from
// another app — or pasted on the web — becomes an Inbox task whose title
// is what the person would call it and whose note keeps the source. One
// rule for every platform; nothing here leaves the device. Pure.

/// What a share becomes: a one-line [title] for the parser, and the
/// [note] that keeps the source (null when the title already says it all).
final class SharedCapture {
  const SharedCapture({required this.title, this.note});

  final String title;
  final String? note;
}

final _url = RegExp(r'''https?://[^\s<>"']+''', caseSensitive: false);

/// Links in [text], in order.
Iterable<String> sharedLinks(String text) =>
    _url.allMatches(text).map((m) => _trimEnd(m[0]!));

/// [text] (and the sharing app's [subject], e.g. a page or mail title) as
/// a task: the subject if given, else the first line without its links,
/// else the first link's site. The whole text is the note unless it is
/// just the title.
///
/// ```dart
/// sharedCapture('https://example.com/a', subject: 'Read: Rust book')
///     .title; // 'Read: Rust book'
/// sharedCapture('Look at this https://ex.com/x').note; // the whole text
/// ```
SharedCapture sharedCapture(String text, {String? subject}) {
  final body = text.trim();
  final links = sharedLinks(body).toList();
  final firstLine = body
      .split('\n')
      .map((l) => l.replaceAll(_url, '').trim())
      .firstWhere((l) => l.isNotEmpty, orElse: () => '');
  final named = subject?.trim() ?? '';
  final title = _cap(
    named.isNotEmpty
        ? named.split('\n').first.trim()
        : firstLine.isNotEmpty
        ? firstLine
        : links.isEmpty
        ? body
        : _site(links.first),
    maxTitleLength,
  );
  final note = body == title || body.isEmpty
      ? null
      : _cap(body, maxNotesLength);
  return SharedCapture(title: title, note: note);
}

/// [draft] from a line with a link (the web's paste path): titled like a
/// share, with the line kept as its note; others come back unchanged.
(QuickAddDraft, String?) capturedDraft(QuickAddDraft draft) {
  if (sharedLinks(draft.text).isEmpty) return (draft, null);
  final c = sharedCapture(draft.title.isEmpty ? draft.text : draft.title);
  return (
    QuickAddDraft(
      title: c.title,
      text: draft.text,
      tokens: draft.tokens,
      date: draft.date,
      minuteOfDay: draft.minuteOfDay,
      durationMin: draft.durationMin,
      rrule: draft.rrule,
      inbox: draft.inbox,
      startUtc: draft.startUtc,
    ),
    _cap(draft.text.trim(), maxNotesLength),
  );
}

/// "example.com/path" without the scheme, "www." or a trailing slash.
String _site(String link) {
  final uri = Uri.tryParse(link);
  if (uri == null || uri.host.isEmpty) return link;
  final host = uri.host.startsWith('www.') ? uri.host.substring(4) : uri.host;
  final path = uri.path.length > 1 ? uri.path : '';
  final site = '$host$path';
  return site.endsWith('/') ? site.substring(0, site.length - 1) : site;
}

/// A link's closing punctuation belongs to the sentence ("…/x).").
String _trimEnd(String link) => link.replaceFirst(RegExp(r'[).,;:!?]+$'), '');

String _cap(String s, int max) => s.length <= max ? s : s.substring(0, max);
