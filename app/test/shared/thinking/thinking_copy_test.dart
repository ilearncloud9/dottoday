import 'package:dottoday/core/l10n/generated/app_localizations.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_status.dart';
import 'package:dottoday/shared/thinking/thinking_copy.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/09 M14.2: every status × vendor has its words, and the next step
// names the right setting (iPhone Settings vs System Settings).

typedef A = ThinkingAvailability;
typedef V = ThinkingVendor;

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  ThinkingStatus s(A a, V v) => ThinkingStatus(availability: a, vendor: v);

  const rules = 'On this device now: your history and simple rules.';
  const ready = 'On this device now: the built-in model.';
  const notEligible =
      "This device can't run the built-in model. Dottoday uses your history "
      'and simple rules.';
  final lines = <(A, V), String>{
    (A.available, V.appleIos): ready,
    (A.available, V.google): ready,
    (A.notEnabled, V.appleIos):
        'Turn on Apple Intelligence in iPhone Settings › Apple Intelligence '
        '& Siri. Dottoday will use it automatically.',
    (A.notEnabled, V.appleMac):
        'Turn on Apple Intelligence in System Settings › Apple Intelligence '
        '& Siri. Dottoday will use it automatically.',
    (A.notEnabled, V.google): rules,
    (A.downloading, V.appleIos):
        'Apple Intelligence is getting ready on this device. It can take a '
        'while.',
    (A.downloading, V.appleMac):
        'Apple Intelligence is getting ready on this device. It can take a '
        'while.',
    (A.downloadable, V.google):
        'Gemini Nano can be downloaded on this phone; it downloads in the '
        'background.',
    (A.downloading, V.google):
        'Gemini Nano is downloading on this phone. Dottoday will use it once '
        "it's ready.",
    (A.downloadable, V.chrome):
        'This browser can download its built-in AI model. Dottoday will use '
        "it once it's there.",
    (A.downloading, V.chrome):
        'This browser is downloading its built-in AI model. Dottoday will use '
        "it once it's ready.",
    (A.downloading, V.none): rules,
    (A.notEligible, V.appleIos): notEligible,
    (A.notEligible, V.google): notEligible,
    (A.notEligible, V.chrome): notEligible,
    (A.unknown, V.appleMac): rules,
  };
  for (final MapEntry(key: (a, v), value: text) in lines.entries) {
    test('status line ${v.name} × ${a.name}', () {
      expect(l10n.thinkingStatusLine(s(a, v)), text);
    });
  }

  final hints = <(A, V), String?>{
    (A.notEnabled, V.appleIos): 'Turn on Apple Intelligence for smarter plans',
    (A.notEnabled, V.appleMac): 'Turn on Apple Intelligence for smarter plans',
    (A.downloading, V.appleIos):
        'Apple Intelligence is getting ready for smarter plans',
    (A.downloadable, V.google):
        "Gemini Nano makes smarter plans once it's on this phone",
    (A.downloading, V.chrome):
        "Your browser's built-in AI makes smarter plans once it's ready",
    (A.notEligible, V.appleIos): null,
    (A.unknown, V.appleIos): null,
    (A.available, V.appleIos): null,
    (A.notEnabled, V.none): null,
  };
  for (final MapEntry(key: (a, v), value: text) in hints.entries) {
    test('hint ${v.name} × ${a.name}', () {
      expect(l10n.thinkingHintAction(s(a, v)), text);
    });
  }

  test('Brain dump names the path that will answer', () {
    expect(
      l10n.plansWith(s(A.available, V.appleMac)),
      'Plans with Apple Intelligence on this device',
    );
    expect(
      l10n.plansWith(s(A.available, V.google)),
      'Plans with Gemini Nano on this phone',
    );
    expect(
      l10n.plansWith(s(A.available, V.chrome)),
      "Plans with your browser's built-in AI, on this device",
    );
    for (final a in A.values.where((a) => a != A.available)) {
      expect(l10n.plansWith(s(a, V.appleIos)), 'Plans with simple rules');
    }
  });

  test('Open Settings only for Apple with Apple Intelligence off', () {
    for (final v in V.values) {
      for (final a in A.values) {
        expect(
          s(a, v).opensSettings,
          a == A.notEnabled && (v == V.appleIos || v == V.appleMac),
          reason: '${v.name} × ${a.name}',
        );
      }
    }
  });
}
