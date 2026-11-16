import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:flutter_test/flutter_test.dart';

// The one size rule every JSON export and import shares (CR-160 Stage B0):
// a file is accepted up to and including 25 MB of UTF-8, never beyond.

void main() {
  String ascii(int bytes) => 'a' * bytes;

  test('just below and exactly at the limit: accepted', () {
    expect(exceedsImportLimit(ascii(maxImportBytes - 1)), isFalse);
    expect(exceedsImportLimit(ascii(maxImportBytes)), isFalse);
  });

  test('one byte over: refused', () {
    expect(exceedsImportLimit(ascii(maxImportBytes + 1)), isTrue);
  });

  test('counted in UTF-8 bytes, not characters', () {
    // 'é' is 2 bytes: half the characters, the same bytes.
    final half = 'é' * (maxImportBytes ~/ 2);
    expect(exceedsImportLimit(half), isFalse);
    expect(exceedsImportLimit('${half}a'), isTrue);
  });

  test('the import refuses exactly what the rule refuses', () {
    final over = decodeExportJson(ascii(maxImportBytes + 1));
    expect(
      over,
      isA<Err<ExportBundle, ValidationFailure>>().having(
        (e) => e.failure.rule,
        'rule',
        ValidationRule.tooLarge,
      ),
    );
  });
}
