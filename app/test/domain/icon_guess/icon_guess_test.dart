import 'package:dottoday/domain/icon_guess/icon_guess.dart';
import 'package:dottoday/domain/icon_guess/icon_guess_text.dart';
import 'package:flutter_test/flutter_test.dart';

String? _icon(String title, [String language = 'en']) =>
    guessIcon(title, language: language)?.iconKey;

void main() {
  group('guessWords', () {
    test('folds case and accents and splits on punctuation', () {
      expect(guessWords("Café with Zoë! L'eau"), [
        'cafe',
        'with',
        'zoe',
        'l',
        'eau',
      ]);
      expect(guessWords('Straße, Größe'), ['strasse', 'grosse']);
      expect(guessKey('  E-Mail  '), 'e mail');
    });
  });

  group('guessIcon', () {
    test('English task titles', () {
      expect(_icon('Buy groceries'), 'cart');
      expect(_icon('Morning run'), 'run');
      expect(_icon('Morning routine'), 'morning_routine');
      expect(_icon('Go for a run'), 'run');
      expect(_icon('Call mum'), 'call');
      expect(_icon('Dentist'), 'tooth');
      expect(_icon('Gym'), 'gym');
      expect(_icon('Walk the dog'), 'walking_dog');
      expect(_icon('Water the plants'), 'watering_can');
      expect(_icon('Drink water'), 'water');
      expect(_icon('Team meeting'), 'people');
      expect(_icon('Reply to emails'), 'email');
      expect(_icon('Pay rent'), 'pay_bills');
      expect(_icon('Do the dishes'), 'dishwasher');
      expect(_icon('Take out the trash'), 'trash');
      expect(_icon('Read a book'), 'book');
      expect(_icon('Doctor appointment'), 'doctor');
      expect(_icon('Evening walk'), 'walking');
      expect(_icon('Flight to Lisbon'), 'travel');
    });

    test('plurals fall back to the singular', () {
      expect(_icon('Vitamins'), 'meds');
      expect(_icon('Pizzas'), 'pizza');
    });

    test('a generic verb yields to a specific word', () {
      expect(_icon('Buy flowers'), 'flowers');
      expect(_icon('Buy milk'), 'cart');
      expect(_icon('Clean the car'), 'car');
      expect(_icon('Write report'), 'document');
      expect(_icon('Jugar al tenis', 'es'), 'tennis');
    });

    test('German, with compounds', () {
      expect(_icon('Einkaufen', 'de'), 'cart');
      expect(_icon('Zahnarzttermin', 'de'), 'tooth');
      expect(_icon('Mathehausaufgaben', 'de'), 'math');
      expect(_icon('Termin beim Zahnarzt', 'de'), 'tooth');
      expect(_icon('Wäsche waschen', 'de'), 'washing_machine');
      expect(_icon('Mit dem Hund Gassi gehen', 'de'), 'walking_dog');
      expect(_icon('Ein paar Sachen kaufen', 'de'), 'cart');
    });

    test('Spanish and French', () {
      expect(_icon('Hacer la compra', 'es'), 'cart');
      expect(_icon('Llamar a mamá', 'es'), 'call');
      expect(_icon('Lavar los platos', 'es'), 'dishwasher');
      expect(_icon('Faire les courses', 'fr'), 'cart');
      expect(_icon('Rendez-vous chez le dentiste', 'fr'), 'tooth');
      expect(_icon('Boire de l’eau', 'fr'), 'water');
    });

    test('falls back to English terms, and accepts locale names', () {
      expect(_icon('Gym', 'fr'), 'gym');
      expect(_icon('Groceries', 'de'), 'cart');
      expect(_icon('Zahnarzt', 'de_AT'), 'tooth');
      expect(_icon('Dentist', 'pt'), 'tooth');
    });

    test('nothing that matches leaves the default', () {
      expect(guessIcon('', language: 'en'), isNull);
      expect(guessIcon('   ', language: 'en'), isNull);
      expect(guessIcon('Xyzzy plugh', language: 'en'), isNull);
      // Everyday words that are also icon names don't hijack a title.
      expect(guessIcon('Recht haben', language: 'de'), isNull);
    });

    test("the colour is the icon's category's", () {
      expect(guessIcon('Dentist', language: 'en')?.colorKey, 'rose');
      expect(guessIcon('Gym', language: 'en')?.colorKey, 'coral');
      expect(guessIcon('Groceries', language: 'en')?.colorKey, 'amber');
      expect(guessIcon('Team meeting', language: 'en')?.colorKey, 'violet');
      // Symbols carry no colour suggestion.
      expect(guessIcon('Pomodoro', language: 'en'), (
        iconKey: 'timer',
        colorKey: null,
      ));
    });
  });
}
