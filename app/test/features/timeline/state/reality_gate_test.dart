import 'package:dottoday/features/timeline/state/reality_gate.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/13 §4.2–§4.3, §9: when Today offers or promises the reality thread.
void main() {
  test('the toggle: today, not a side day, once revealed', () {
    expect(offerReality(isToday: true, isSide: false, revealed: true), isTrue);
    expect(
      offerReality(isToday: true, isSide: false, revealed: false),
      isFalse,
    );
    expect(
      offerReality(isToday: false, isSide: false, revealed: true),
      isFalse,
    );
    expect(offerReality(isToday: true, isSide: true, revealed: true), isFalse);
  });

  test('minimal mode and low-energy mode hide Today prompts (§9)', () {
    expect(
      showLearningPromptsOnToday(lowEnergy: false, minimalMode: false),
      isTrue,
    );
    expect(
      showLearningPromptsOnToday(lowEnergy: false, minimalMode: true),
      isFalse,
    );
    expect(
      showLearningPromptsOnToday(lowEnergy: true, minimalMode: false),
      isFalse,
    );
  });

  group('the caption', () {
    final today = DateTime(2026, 10, 26);
    bool shows({
      bool isToday = true,
      bool revealed = false,
      bool prompts = true,
      DateTime? putAwayOn,
      DateTime? on,
    }) => showLearningCaption(
      isToday: isToday,
      revealed: revealed,
      promptsOnToday: prompts,
      today: on ?? today,
      putAwayOn: putAwayOn,
    );

    test('before the reveal, on today, with prompts allowed', () {
      expect(shows(), isTrue);
      expect(shows(revealed: true), isFalse);
      expect(shows(isToday: false), isFalse);
      expect(shows(prompts: false), isFalse);
    });

    test('put away: gone for that day, back the next', () {
      final evening = DateTime(2026, 10, 26, 23, 59);
      expect(shows(putAwayOn: evening), isFalse);
      expect(shows(putAwayOn: evening, on: DateTime(2026, 10, 27)), isTrue);
    });
  });
}
