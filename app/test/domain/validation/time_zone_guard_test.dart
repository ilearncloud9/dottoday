import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:flutter_test/flutter_test.dart';

// Separate file: test files run in their own isolate, so the time-zone
// database is guaranteed to be unloaded here.
void main() {
  test('tz validation fails loudly when the database was never loaded', () {
    expect(() => checkTimeZone('UTC'), throwsStateError);
  });
}
