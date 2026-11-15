import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:flutter_test/flutter_test.dart';

Result<int, ValidationFailure> _parse(String s) {
  final n = int.tryParse(s);
  return n == null
      ? const Err(
          ValidationFailure(
            ValidationField.duration,
            ValidationRule.invalidFormat,
          ),
        )
      : Ok(n);
}

void main() {
  test('when dispatches to the right branch', () {
    expect(_parse('5').when(ok: (n) => n * 2, err: (_) => -1), 10);
    expect(_parse('x').when(ok: (n) => n, err: (f) => f.rule.index), 3);
  });

  test('map transforms Ok and passes Err through', () {
    expect(
      _parse('5').map((n) => '$n min'),
      const Ok<String, ValidationFailure>('5 min'),
    );
    final err = _parse('x').map((n) => n + 1);
    expect(err, isA<Err<int, ValidationFailure>>());
    expect((err as Err).failure.code, 'validation.duration.invalidFormat');
  });

  test('exhaustive switch without default', () {
    final label = switch (_parse('7')) {
      Ok(:final value) => 'ok $value',
      Err(:final failure) => failure.code,
    };
    expect(label, 'ok 7');
  });

  test('value equality and toString shows code only', () {
    expect(const Ok<int, AuthFailure>(1), const Ok<int, AuthFailure>(1));
    expect(const Err<int, AuthFailure>(AuthFailure()).toString(), 'Err(auth)');
  });
}
