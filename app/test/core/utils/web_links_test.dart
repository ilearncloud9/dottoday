import 'package:dottoday/core/utils/web_links.dart';
import 'package:flutter_test/flutter_test.dart';

// Tappable links in notes (docs/02 F5, R-02; 06 §7: http(s) only).

void main() {
  test('finds web links in order, without trailing punctuation', () {
    final links = webLinks(
      'Join https://meet.example.com/abc. Docs (https://docs.example.com/x), '
      'again https://meet.example.com/abc',
    );
    expect(links.map((u) => u.toString()), [
      'https://meet.example.com/abc',
      'https://docs.example.com/x',
    ]);
  });

  test('only http(s) with a host', () {
    expect(
      webLinks('javascript:alert(1) file:///etc/passwd tel:123 https:// x'),
      isEmpty,
    );
    expect(webLinks('HTTP://Example.com/a').single.host, 'example.com');
  });

  test('none in empty notes; at most five', () {
    expect(webLinks(null), isEmpty);
    expect(webLinks(''), isEmpty);
    final many = [for (var i = 0; i < 8; i++) 'https://e$i.example.com'];
    expect(webLinks(many.join(' ')), hasLength(maxWebLinks));
  });
}
