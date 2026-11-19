import 'package:dottoday/domain/icon_guess/icon_guess.dart';
import 'package:dottoday/domain/look/recent_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pushRecent moves to the front, drops repeats, caps', () {
    expect(pushRecent(['a', 'b', 'c'], 'c', max: 3), ['c', 'a', 'b']);
    expect(pushRecent(['a', 'b', 'c'], 'd', max: 3), ['d', 'a', 'b']);
    expect(pushRecent(<String>[], 'a', max: 2), ['a']);
  });

  test('guessIconKeys: the whole title first, then each word, distinct', () {
    final keys = guessIconKeys('Gym then groceries', language: 'en');
    expect(keys.length, 2);
    expect(keys.toSet().length, 2);
    expect(guessIconKeys('zzqx', language: 'en'), isEmpty);
    expect(guessIconKeys('Go for a run', language: 'en', limit: 1).length, 1);
  });
}
