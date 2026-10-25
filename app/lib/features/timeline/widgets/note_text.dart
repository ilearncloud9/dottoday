import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/utils/markdown_lite.dart';
import 'package:dottoday/core/utils/web_links.dart';
import 'package:dottoday/features/timeline/editor/editor_fields.dart';
import 'package:flutter/material.dart';

/// NOTES: a task's notes as markdown-lite (docs/02 F2.9) — bold, italic,
/// bullet and numbered lists, links drawn as links. The LINKS rows below
/// ([NoteLinks]) are what a tap opens: full-width 44 pt targets a screen
/// reader lists, rather than words inside a paragraph (R-12); a line
/// that is only such a link is left to its row, not shown twice. Nothing
/// when there are no notes.
class NoteText extends StatelessWidget {
  const NoteText({required this.notes, super.key});

  final String? notes;

  @override
  Widget build(BuildContext context) {
    final lines = _shown(parseNotes(notes), webLinks(notes).toSet());
    if (lines.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorCaption(context.l10n.editorNotes),
        for (final line in lines) _Line(line: line),
      ],
    );
  }
}

/// [lines] without those that are only a link [listed] under LINKS, and
/// without a gap at either end.
List<NoteLine> _shown(List<NoteLine> lines, Set<Uri> listed) {
  bool onlyListed(NoteLine l) =>
      l.spans.length == 1 && listed.contains(l.spans.single.link);
  final kept = [
    for (final l in lines)
      if (!onlyListed(l)) l,
  ];
  while (kept.isNotEmpty && kept.first.kind == NoteLineKind.gap) {
    kept.removeAt(0);
  }
  while (kept.isNotEmpty && kept.last.kind == NoteLineKind.gap) {
    kept.removeLast();
  }
  return kept;
}

class _Line extends StatelessWidget {
  const _Line({required this.line});

  final NoteLine line;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final marker = switch (line.kind) {
      NoteLineKind.gap => null,
      NoteLineKind.text => null,
      NoteLineKind.bullet => '•', // l10n-ignore: a list bullet
      NoteLineKind.numbered => '${line.marker}.', // l10n-ignore: list number
    };
    if (line.kind == NoteLineKind.gap) {
      return const SizedBox(height: DotSpace.s);
    }
    final text = Text.rich(_spans(t, line.spans), style: t.styles.body);
    if (marker == null) return text;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: DotSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.s,
        children: [
          Text(marker, style: t.styles.body.copyWith(color: t.colors.muted)),
          Expanded(child: text),
        ],
      ),
    );
  }

  TextSpan _spans(DotTheme t, List<NoteSpan> spans) => TextSpan(
    children: [
      for (final s in spans)
        TextSpan(
          text: s.text,
          style: DotType.emphasis(
            s.link == null
                ? t.styles.body
                : t.styles.body.copyWith(
                    color: t.colors.accentInk,
                    decoration: TextDecoration.underline,
                    decorationColor: t.colors.accentInk,
                  ),
            bold: s.bold,
            italic: s.italic,
          ),
        ),
    ],
  );
}
