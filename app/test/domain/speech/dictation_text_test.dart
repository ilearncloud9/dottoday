import 'package:dottoday/domain/speech/dictation_text.dart';
import 'package:flutter_test/flutter_test.dart';

// Dictation into a field (docs/09 M14.4, D6): partial guesses merge at the
// cursor without repeating words; in Brain dump a pause or the command
// word starts a new line ("next week" doesn't); Notes only insert.

final t0 = DateTime.utc(2026, 10, 29, 9);
DateTime at(int ms) => t0.add(Duration(milliseconds: ms));

Dictation dump({String text = '', int? cursor, String command = 'next'}) =>
    Dictation.start(
      text: text,
      cursor: cursor ?? text.length,
      mode: DictationMode.brainDump,
      command: command,
      now: t0,
    );

Dictation plain({String text = '', int? cursor}) => Dictation.start(
  text: text,
  cursor: cursor ?? text.length,
  mode: DictationMode.plain,
  now: t0,
);

/// Feeds growing guesses of one utterance, [gapMs] apart.
Dictation say(
  Dictation d,
  List<String> guesses, {
  int from = 0,
  int gapMs = 200,
}) {
  for (final (i, g) in guesses.indexed) {
    d = d.partial(g, at(from + i * gapMs)).tick(at(from + i * gapMs));
  }
  return d;
}

void main() {
  group('merge', () {
    test('partials replace each other; nothing is written twice', () {
      var d = say(dump(), ['call', 'call the', 'call the dentist']);
      expect(d.text, 'Call the dentist');
      expect(d.cursor, d.text.length);
      d = d.partial('call the dentist', at(900));
      expect(d.text, 'Call the dentist');
    });

    test('a revised guess replaces the live words', () {
      final d = say(dump(), ['buy mill', 'buy milk']);
      expect(d.text, 'Buy milk');
    });

    test('a final settles the utterance; the next one appends', () {
      var d = plain().partial('hello there', at(0));
      d = d.finalResult('Hello there.', at(100));
      d = d.partial('general', at(300)).finalResult('General.', at(400));
      expect(d.text, 'Hello there. General.');
    });

    test('the cursor in the middle: text around it is kept', () {
      var d = plain(text: 'Bring the form', cursor: 'Bring'.length);
      d = d.partial('and sign', at(0));
      expect(d.text, 'Bring and sign the form');
      expect(d.cursor, 'Bring and sign'.length);
    });

    test('nothing heard: the field is unchanged', () {
      final d = dump(text: 'Email Sam').tick(at(5000));
      expect(d.text, 'Email Sam');
      expect(d.isEmpty, isTrue);
    });

    test('emoji and right-to-left text pass through whole', () {
      var d = plain(text: 'שלום').partial('🎉 עולם', at(0));
      expect(d.text, 'שלום 🎉 עולם');
      d = dump().partial('🎉 party', at(0));
      expect(d.text, '🎉 party', reason: 'no capital to make');
    });
  });

  group('Brain dump: pause', () {
    test('a ${kDictationPause.inMilliseconds} ms pause starts a new line', () {
      var d = say(dump(), ['call the dentist']);
      d = d.tick(at(kDictationPause.inMilliseconds - 1));
      expect(d.text, 'Call the dentist');
      d = d.tick(at(kDictationPause.inMilliseconds));
      expect(d.text, 'Call the dentist\n');
      // The same utterance goes on: only the new words land.
      d = d.partial('call the dentist buy milk', at(2000));
      expect(d.text, 'Call the dentist\nBuy milk');
    });

    test('after a typed line, dictation starts its own line', () {
      final d = dump(text: 'Email Sam').partial('taxes', at(0));
      expect(d.text, 'Email Sam\nTaxes');
    });

    test('the end of an utterance is a pause', () {
      final d = dump()
          .partial('email sam', at(0))
          .finalResult('Email Sam', at(1));
      expect(d.text, 'Email Sam\n');
    });
  });

  group('Brain dump: the command word', () {
    test('"Call the dentist … next … buy milk" → two lines', () {
      var d = say(dump(), ['call the dentist', 'call the dentist next']);
      d = d.tick(at(200 + kCommandSettle.inMilliseconds));
      expect(d.text, 'Call the dentist\n');
      d = d.partial('call the dentist next buy milk', at(1400));
      expect(d.text, 'Call the dentist\nBuy milk');
    });

    test('"next week" is not a command', () {
      var d = say(dump(), ['see you', 'see you next', 'see you next week']);
      d = d.tick(at(400 + kCommandSettle.inMilliseconds));
      expect(d.text, 'See you next week');
    });

    test('"next" mid-guess but not yet settled: no split', () {
      final d = say(dump(), ['call next']).tick(at(500));
      expect(d.text, 'Call next');
    });

    test('"next" alone after a break adds no empty line', () {
      var d = say(dump(), [
        'email Sam',
      ]).tick(at(kDictationPause.inMilliseconds));
      d = d.partial('email Sam next', at(2000)).tick(at(3000));
      expect(d.text, 'Email Sam\n');
    });

    test('any case and punctuation; a final ending on it', () {
      final d = dump()
          .partial('buy milk Next.', at(0))
          .finalResult('Buy milk. Next.', at(10));
      expect(d.text, 'Buy milk.\n');
    });

    for (final (lang, word, said) in [
      ('en', 'next', 'call mum next'),
      ('de', 'weiter', 'mama anrufen weiter'),
      ('fr', 'suivant', 'appeler maman suivant'),
      ('es', 'siguiente', 'llamar a mamá siguiente'),
    ]) {
      test('$lang: "$word"', () {
        var d = dump(command: word).partial(said, at(0));
        d = d.tick(at(kCommandSettle.inMilliseconds));
        expect(d.text.endsWith('\n'), isTrue, reason: d.text);
        expect(d.text.toLowerCase(), isNot(contains(word)));
      });
    }
  });

  group('Notes (plain)', () {
    test('no pause lines, no command', () {
      var d = plain(text: 'Ask about').partial('the next step', at(0));
      d = d.tick(at(10000));
      expect(d.text, 'Ask about the next step');
    });

    test('punctuation as the recognizer gives it; no capitals added', () {
      final d = plain().partial('bring the forms.', at(0));
      expect(d.text, 'bring the forms.');
    });

    test('a space only where one is missing', () {
      expect(plain(text: 'Hi ').partial('there', at(0)).text, 'Hi there');
      expect(plain(text: 'Hi\n').partial('there', at(0)).text, 'Hi\nthere');
    });
  });
}
