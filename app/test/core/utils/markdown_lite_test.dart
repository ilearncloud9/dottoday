import 'package:dottoday/core/utils/markdown_lite.dart';
import 'package:flutter_test/flutter_test.dart';

// Markdown-lite notes (docs/02 F2.9, docs/09 M8.4c).

void main() {
  group('parseInline', () {
    test('plain text is one span', () {
      expect(parseInline('Buy milk'), [const NoteSpan('Buy milk')]);
    });

    test('bold with ** and __', () {
      expect(parseInline('a **b** c __d__'), [
        const NoteSpan('a '),
        const NoteSpan('b', bold: true),
        const NoteSpan(' c '),
        const NoteSpan('d', bold: true),
      ]);
    });

    test('italic with * and _, not inside words', () {
      expect(parseInline('*a* and _b_ but snake_case_name'), [
        const NoteSpan('a', italic: true),
        const NoteSpan(' and '),
        const NoteSpan('b', italic: true),
        const NoteSpan(' but snake_case_name'),
      ]);
    });

    test('italic nests in bold', () {
      expect(parseInline('**big _deal_**'), [
        const NoteSpan('big ', bold: true),
        const NoteSpan('deal', bold: true, italic: true),
      ]);
    });

    test('a lone star or "2 * 3" stays text', () {
      expect(parseInline('2 * 3 = 6 *'), [const NoteSpan('2 * 3 = 6 *')]);
    });

    test('labelled link', () {
      expect(parseInline('see [the deck](https://x.io/d) now'), [
        const NoteSpan('see '),
        NoteSpan('the deck', link: Uri.parse('https://x.io/d')),
        const NoteSpan(' now'),
      ]);
    });

    test('bare link keeps the sentence dot as text', () {
      expect(parseInline('Join https://meet.example.com/abc.'), [
        const NoteSpan('Join '),
        NoteSpan(
          'https://meet.example.com/abc',
          link: Uri.parse('https://meet.example.com/abc'),
        ),
        const NoteSpan('.'),
      ]);
    });

    test('a non-web scheme is never a link (06 §7)', () {
      final spans = parseInline('[x](javascript:alert(1)) mailto:a@b.c');
      expect(spans.every((s) => s.link == null), isTrue);
      expect(spans.map((s) => s.text).join(), contains('javascript'));
    });
  });

  group('parseNotes', () {
    test('empty or blank notes give nothing', () {
      expect(parseNotes(null), isEmpty);
      expect(parseNotes('  \n \n'), isEmpty);
    });

    test('bullets, numbers, text and one gap per blank run', () {
      final lines = parseNotes(
        'Agenda\n\n\n- one\n* two\n• three\n2. four\n3) five',
      );
      expect(lines.map((l) => l.kind), [
        NoteLineKind.text,
        NoteLineKind.gap,
        NoteLineKind.bullet,
        NoteLineKind.bullet,
        NoteLineKind.bullet,
        NoteLineKind.numbered,
        NoteLineKind.numbered,
      ]);
      expect(lines[2].spans, [const NoteSpan('one')]);
      expect(lines[5].marker, '2');
      expect(lines[6].spans, [const NoteSpan('five')]);
    });

    test('a heading or code stays as typed', () {
      final lines = parseNotes('# Title\n`code`');
      expect(lines.map((l) => l.spans.single.text), ['# Title', '`code`']);
    });

    test('10 000 characters of stars parse without throwing', () {
      final hostile = '*_[(' * 2500;
      expect(() => parseNotes(hostile), returnsNormally);
      expect(
        parseNotes(hostile).expand((l) => l.spans).map((s) => s.text).join(),
        isNotEmpty,
      );
    });
  });
}
