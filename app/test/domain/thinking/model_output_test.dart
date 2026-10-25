import 'package:dottoday/domain/thinking/model_output.dart';
import 'package:flutter_test/flutter_test.dart';

// A model's text is untrusted input (06 §7, docs/09 M10.1).

void main() {
  test('steps: fenced JSON, control characters, clamps and the cap', () {
    final steps = ModelOutput.breakdown(
      '```json\n{"steps":['
      '{"title":"  A\\u0000b ","minutes":0},'
      '{"title":"Long","minutes":99999},'
      '{"title":"${'x' * 300}","minutes":12.6},'
      '{"title":42},'
      '{"title":"Four","minutes":"5"}'
      ']}\n```',
      3,
    )!;
    expect(steps.map((s) => s.title.length), [3, 4, 200]);
    expect(steps.first.title, 'A b');
    expect(steps.map((s) => s.durationMin), [null, 1440, 13]);
  });

  test('dots: HH:MM only, minutes 5–1440, at most 50', () {
    final dots = ModelOutput.dots(
      '{"dots":['
      '{"title":"a","start":"7:05","minutes":2},'
      '{"title":"b","start":"25:00"},'
      '{"title":"c","start":"","minutes":5000}'
      ']}',
    )!;
    expect(dots.map((d) => d.minuteOfDay), [425, null, null]);
    expect(dots.map((d) => d.durationMin), [5, null, 1440]);
    final many = List.filled(80, '{"title":"x"}').join(',');
    expect(ModelOutput.dots('{"dots":[$many]}')!.length, 50);
  });

  test('minutes: a number in range or nothing', () {
    expect(ModelOutput.minutes('{"minutes":3}'), 5);
    expect(ModelOutput.minutes('{"minutes":-1}'), isNull);
    expect(ModelOutput.minutes('{"minutes":"40"}'), isNull);
    expect(ModelOutput.minutes('oops'), isNull);
    expect(ModelOutput.minutes(null), isNull);
  });
}
