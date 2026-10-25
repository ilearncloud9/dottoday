import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/quick_add/shared_capture.dart';
import 'package:flutter_test/flutter_test.dart';

// Capture anywhere (docs/09 M12.4, 11 B6): what a share or a pasted link
// becomes — a title for the parser and the source kept as the note.

void main() {
  group('sharedCapture', () {
    test("the sharing app's subject is the title; the text is the note", () {
      final c = sharedCapture(
        'https://example.com/rust',
        subject: 'The Rust book',
      );
      expect(c.title, 'The Rust book');
      expect(c.note, 'https://example.com/rust');
    });

    test('else the first line without its link', () {
      final c = sharedCapture(
        'Read this later https://news.site/a/b?x=1\nfrom Sam',
      );
      expect(c.title, 'Read this later');
      expect(c.note, 'Read this later https://news.site/a/b?x=1\nfrom Sam');
    });

    test('a bare link is titled by its site; the link is the note', () {
      final c = sharedCapture('https://www.example.com/articles/42/');
      expect(c.title, 'example.com/articles/42');
      expect(c.note, 'https://www.example.com/articles/42/');
      expect(sharedCapture('http://example.com').title, 'example.com');
    });

    test('plain text: the title, and no note when it says it all', () {
      expect(sharedCapture('  Buy stamps ').title, 'Buy stamps');
      expect(sharedCapture('  Buy stamps ').note, isNull);
      final two = sharedCapture('Pack\n- passport\n- charger');
      expect((two.title, two.note), ('Pack', 'Pack\n- passport\n- charger'));
    });

    test("a sentence's closing punctuation is not part of the link", () {
      expect(sharedLinks('See https://ex.com/x).'), ['https://ex.com/x']);
    });

    test('long text is cut to the title and note limits', () {
      final c = sharedCapture('x' * 300);
      expect(c.title.length, 200);
      expect(sharedCapture('y\n${'z' * 20000}').note!.length, 10000);
    });
  });

  test('a pasted line with a link: titled like a share, the line kept', () {
    const line = 'Read https://ex.com/post';
    final (draft, note) = capturedDraft(
      const QuickAddDraft(title: line, text: line, durationMin: 20),
    );
    expect(draft.title, 'Read');
    expect(draft.durationMin, 20);
    expect(note, line);
    const plain = QuickAddDraft(title: 'Gym', text: 'Gym 7pm');
    expect(capturedDraft(plain), (plain, null));
  });
}
