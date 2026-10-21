import 'package:dottoday/domain/search/search_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('terms are quoted prefix matches, all required', () {
    expect(ftsQuery('dent appt'), '"dent"* "appt"*');
    expect(ftsQuery('  Zahn\tarzt \n'), '"Zahn"* "arzt"*');
  });

  test('blank input → null', () {
    expect(ftsQuery(''), isNull);
    expect(ftsQuery('   \n'), isNull);
    expect(ftsQuery('\u0000'), isNull);
  });

  test('FTS5 syntax is neutralised', () {
    expect(ftsQuery('a OR b'), '"a"* "OR"* "b"*');
    expect(ftsQuery('title:x -y NEAR(z)'), '"title:x"* "-y"* "NEAR(z)"*');
    expect(ftsQuery('say "hi"'), '"say"* """hi"""*');
  });

  test('bounded length and term count', () {
    expect(
      ftsQuery(List.filled(20, 'w').join(' '))!.split(' '),
      hasLength(maxSearchTerms),
    );
    expect(ftsQuery('x' * 1000)!.length, maxSearchQueryLength + 3);
  });
}
