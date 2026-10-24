import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:flutter_test/flutter_test.dart';

// A new profile starts in the device's language when the app speaks it
// (docs/09 M8.3).
void main() {
  test('the first preferred language the app speaks', () {
    expect(supportedLanguage(['pt', 'fr', 'de']), 'fr');
    expect(supportedLanguage(['es']), 'es');
  });

  test('English when none is spoken', () {
    expect(supportedLanguage(['pt', 'ja']), 'en');
    expect(supportedLanguage(const []), 'en');
  });
}
