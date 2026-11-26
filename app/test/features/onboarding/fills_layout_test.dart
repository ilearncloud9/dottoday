import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_layout.dart';
import 'package:flutter_test/flutter_test.dart';

// The thread's rows (prototype `threadHTML`; ED-488 keeps them inside).

const _wake = (kind: FillRowKind.wake, minute: 420);
const _wind = (kind: FillRowKind.wind, minute: 1380);
FillRowSpec _pick(int m) => (kind: FillRowKind.pick, minute: m);

void main() {
  test('rows sit at their times, 28 in from each end', () {
    final at = layoutFillThread(
      [_wake, _pick(900), _wind],
      wake: 420,
      wind: 1380,
      now: 581,
      height: 428,
    );
    expect(at.ys, [28, 214, 400]);
    expect(at.compact, isFalse);
    expect(at.now, closeTo(28 + 161 / 960 * 372, 0.01));
  });

  test('close rows keep their gaps; a full thread shrinks them', () {
    final roomy = layoutFillThread(
      [_wake, _pick(435), _wind],
      wake: 420,
      wind: 1380,
      now: 420,
      height: 428,
    );
    expect(roomy.ys[1] - roomy.ys[0], OnbSize.gapOne);
    final full = layoutFillThread(
      [
        _wake,
        _pick(435),
        _pick(540),
        _pick(1080),
        _pick(1260),
        _pick(1290),
        _wind,
      ],
      wake: 420,
      wind: 1380,
      now: 420,
      height: 220,
    );
    expect(full.compact, isTrue);
    for (var i = 1; i < full.ys.length; i++) {
      expect(full.ys[i], greaterThan(full.ys[i - 1]));
    }
  });

  test('every row stays inside the thread (ED-488)', () {
    final at = layoutFillThread(
      [_wake, _pick(1080), _pick(1260), _pick(1290), _pick(1350), _wind],
      wake: 420,
      wind: 1380,
      now: 420,
      height: 300,
    );
    expect(at.ys.first, greaterThanOrEqualTo(OnbSize.threadPad));
    expect(at.ys.last, lessThanOrEqualTo(300 - OnbSize.threadPad));
  });
}
