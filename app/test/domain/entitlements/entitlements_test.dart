import 'dart:io';

import 'package:dottoday/domain/entitlements/entitlements.dart';
import 'package:flutter_test/flutter_test.dart';

// The only pricing code until the owner signs off a split (docs/09
// M6.5.11, 11-standout-roadmap "Free / Pro split — DRAFT").
void main() {
  test('everyone has everything', () {
    expect(const Entitlements().isPro, isTrue);
  });

  test('no paywall, purchase flow or store SDK anywhere', () {
    final buy = RegExp(
      r'in_app_purchase|purchases_flutter|StoreKit|BillingClient|paywall',
      caseSensitive: false,
    );
    final hits = <String>[];
    for (final dir in [
      'lib',
      'ios/Runner',
      'android/app/src',
      'macos/Runner',
    ]) {
      for (final f in Directory(
        dir,
      ).listSync(recursive: true).whereType<File>()) {
        if (![
          '.dart',
          '.swift',
          '.kt',
          '.xml',
          '.plist',
        ].any(f.path.endsWith)) {
          continue;
        }
        // The service's own doc says what is not allowed.
        if (f.path.endsWith('entitlements/entitlements.dart')) continue;
        if (buy.hasMatch(f.readAsStringSync())) hits.add(f.path);
      }
    }
    expect(hits, isEmpty);
    expect(File('pubspec.yaml').readAsStringSync(), isNot(matches(buy)));
  });
}
