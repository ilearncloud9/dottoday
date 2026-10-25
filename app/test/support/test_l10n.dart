import 'package:dottoday/core/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pseudo/pseudo_localizations.g.dart';

// Which strings the test harnesses render (docs/09 M8.3). English unless a
// test opts into a translation or the pseudo locale; reset after each test.

Locale? _locale;
bool _pseudo = false;

/// Renders the harnesses in [code] (`de`, `fr`, `es`) for this test.
void useTestLocale(String code) {
  _locale = Locale(code);
  _pseudo = false;
  addTearDown(_reset);
}

/// Renders the harnesses in pseudo-English (longer, accented) for this test.
void usePseudoLocale() {
  _locale = const Locale('en');
  _pseudo = true;
  addTearDown(_reset);
}

void _reset() {
  _locale = null;
  _pseudo = false;
}

/// `localizationsDelegates` for a test app; the pseudo delegate goes first
/// because the first delegate of a type wins.
List<LocalizationsDelegate<Object?>> get testL10nDelegates => [
  if (_pseudo) const _PseudoDelegate(),
  ...AppLocalizations.localizationsDelegates,
];

/// `supportedLocales` for a test app.
List<Locale> get testL10nLocales => AppLocalizations.supportedLocales;

/// `locale` for a test app: null means the device locale (en in tests).
Locale? get testL10nLocale => _locale;

final class _PseudoDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _PseudoDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(PseudoAppLocalizations());

  @override
  bool shouldReload(_PseudoDelegate old) => false;
}
