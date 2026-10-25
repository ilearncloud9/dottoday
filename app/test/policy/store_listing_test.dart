import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Store listing copy (docs/store/listing/*.md, docs/09 M8.6): every
// language has every field, within the consoles' limits. The no-shame
// words are checked in no_shame_copy_test.dart.

/// Field → character limit (App Store Connect and Play Console; "What's
/// new" uses Play's 500, the stricter of the two).
const storeFields = {
  'App name': 30,
  'Subtitle': 30,
  'Promotional text': 170,
  'Keywords': 100,
  'Short description': 80,
  'Description': 4000,
  "What's new": 500,
};

const storeLocales = ['en', 'de', 'fr', 'es'];

/// The fields of one listing file: each `### Field` heading's text.
Map<String, String> readListing(String locale) {
  final text = File('../docs/store/listing/$locale.md').readAsStringSync();
  final fields = <String, String>{};
  for (final part in text.split('\n### ').skip(1)) {
    final newline = part.indexOf('\n');
    fields[part.substring(0, newline).trim()] = part
        .substring(newline + 1)
        .trim();
  }
  return fields;
}

void main() {
  for (final locale in storeLocales) {
    test('$locale listing has every field within its limit', () {
      final fields = readListing(locale);
      expect(fields.keys.toSet(), storeFields.keys.toSet());
      for (final MapEntry(key: name, value: limit) in storeFields.entries) {
        final value = fields[name]!;
        expect(value, isNotEmpty, reason: name);
        expect(value.runes.length, lessThanOrEqualTo(limit), reason: name);
      }
      // Apple: keywords are comma-separated with no spaces after commas.
      expect(fields['Keywords'], isNot(contains(', ')));
      // The age gate is said in the listing too (docs/06 §6).
      expect(fields['Description'], contains('13'));
    });
  }
}
