import 'package:dottoday/domain/tips/siri_tip.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/09 M14.3: Today's Siri card — iPhone, after onboarding, after the
// third added task, never again once put away.

void main() {
  bool shows({
    bool siri = true,
    bool onboarded = true,
    bool putAway = false,
    int added = 3,
  }) => showsSiriTip(
    siri: siri,
    onboarded: onboarded,
    putAway: putAway,
    added: added,
  );

  test('at the third task, not the second', () {
    expect(shows(added: siriTipAfterTasks - 1), isFalse);
    expect(shows(added: siriTipAfterTasks), isTrue);
    expect(shows(added: 40), isTrue);
  });

  test('never without Siri, during onboarding, or once put away', () {
    expect(shows(siri: false), isFalse);
    expect(shows(onboarded: false), isFalse);
    expect(shows(putAway: true), isFalse);
  });
}
