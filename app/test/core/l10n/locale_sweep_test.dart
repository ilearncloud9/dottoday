import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/search/search_screen.dart';
import 'package:dottoday/features/timeline/month_screen.dart';
import 'package:dottoday/features/timeline/review/week_review_sheet.dart';
import 'package:dottoday/features/timeline/week_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../features/settings/settings_harness.dart';
import '../../support/inbox_harness.dart';
import '../../support/onboarding_harness.dart';
import '../../support/test_l10n.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';
import '../../support/week_review_fixtures.dart';

// Truncation sweep (docs/09 M8.3, docs/08 §2): every main screen at the
// three width classes in pseudo-English (about a third longer, accented,
// wrapped in ⟦ ⟧), and in de/fr/es at each screen's narrowest width,
// measured with the bundled Inter font.
// Fails on any overflow, and when a language cuts more text short than
// English does at the same size (user titles may ellipsize by design; the
// app's own copy may not). The Week board's cards ellipsize every line by
// design (a card's height is its time, `week_card.dart`), so it is checked
// for overflow only.

const _compact = 360.0;
const _medium = 700.0;
const _expandedMin = 840.0;
const _expanded = 1280.0;
const _all = [_compact, _medium, _expanded];
const _height = 2600.0;

typedef _Pump = Future<void> Function(WidgetTester tester, Size size);
typedef _Screen = ({_Pump pump, List<double> widths, bool checkCuts});

_Screen _screen(
  _Pump pump, [
  List<double> widths = _all,
  bool checkCuts = true,
]) => (pump: pump, widths: widths, checkCuts: checkCuts);

final _screens = <String, _Screen>{
  'Today': _screen((t, s) => pumpToday(t, size: s)),
  'Inbox': _screen((t, s) => pumpInbox(t, size: s)),
  'Search': _screen(
    (t, s) => pumpInbox(t, size: s, home: const SearchScreen()),
  ),
  // The Week board exists only in the expanded class (docs/10 §4).
  'Week': _screen((t, s) => _pumpBoard(t, s, const WeekScreen()), [
    _expandedMin,
    _expanded,
  ], false),
  'Month': _screen((t, s) => _pumpBoard(t, s, const MonthScreen())),
  'Settings': _screen((t, s) => pumpSettings(t, size: s)),
  // Low-energy mode (M12.2): Today with only the next dot.
  'Today · low-energy': _screen(
    (t, s) => pumpToday(
      t,
      size: s,
      settings: Settings(
        use24h: false,
        firstDayOfWeek: 7,
        lowEnergyUntil: DateTime.utc(2026, 10, 22, 5),
      ),
    ),
  ),
  // The weekly review (M12.1): a sheet on phones, a popover when wider.
  'This week': _screen(
    (t, s) => _pumpBoard(
      t,
      s,
      Scaffold(
        body: SingleChildScrollView(
          child: WeekReviewBody(today: DateTime(2026, 10, 25)),
        ),
      ),
      now: reviewNow,
      rows: weekReviewRows(),
    ),
  ),
  for (final page in SettingsPage.values)
    'Settings › ${page.name}': _screen(
      (t, s) =>
          pumpSettings(t, size: s, location: AppRoutes.settingsPage(page)),
    ),
  for (final step in OnboardingStep.values)
    'Onboarding › ${step.name}': _screen(
      (t, s) => pumpOnboarding(
        t,
        size: s,
        progress: OnboardingProgress(step: step),
      ),
    ),
};

Future<void> _pumpBoard(
  WidgetTester tester,
  Size size,
  Widget home, {
  DateTime? now,
  List<Occurrence>? rows,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: now ?? DateTime.utc(2026, 10, 21, 7, 22),
        occurrences: FakeOccurrenceRepository(rows ?? demoWeekRows()),
        profile: testProfile(
          settings: const Settings(use24h: false, firstDayOfWeek: 7),
        ),
      ),
      child: MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: testL10nDelegates,
        supportedLocales: testL10nLocales,
        locale: testL10nLocale,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Text of every paragraph that does not fit its line limit at its laid
/// out width. Measured afresh: `RenderParagraph.didExceedMaxLines` reports
/// the last layout, which may be an intrinsic pass at another width.
List<String> _cut(WidgetTester tester) => [
  for (final p in tester.allRenderObjects.whereType<RenderParagraph>())
    if (p.maxLines != null && _exceeds(p)) p.text.toPlainText(),
];

bool _exceeds(RenderParagraph p) {
  final painter = TextPainter(
    text: p.text,
    maxLines: p.maxLines,
    textDirection: p.textDirection,
    textScaler: p.textScaler,
    strutStyle: p.strutStyle,
    textWidthBasis: p.textWidthBasis,
    textHeightBehavior: p.textHeightBehavior,
    locale: p.locale,
  )..layout(maxWidth: p.constraints.maxWidth);
  final exceeds = painter.didExceedMaxLines;
  painter.dispose();
  return exceeds;
}

/// Pumps [screen] in English, counts what it cuts short, and clears the
/// tree so the next pump starts clean.
Future<int> _englishCuts(WidgetTester tester, _Screen screen, Size size) async {
  await screen.pump(tester, size);
  final cuts = _cut(tester).length;
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  return cuts;
}

/// Pumps [screen] in English, then in the language [useLocale] picks,
/// and checks the second against the first.
Future<void> _check(
  WidgetTester tester,
  _Screen screen,
  Size size,
  void Function() useLocale,
) async {
  final english = await _englishCuts(tester, screen, size);
  useLocale();
  await screen.pump(tester, size);
  expect(tester.takeException(), isNull);
  if (screen.checkCuts) {
    expect(_cut(tester), hasLength(lessThanOrEqualTo(english)));
  }
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    // Real Inter metrics: the test font draws every glyph 1 em wide.
    await loadAppFonts();
  });

  group('pseudo-locale', () {
    for (final MapEntry(key: name, value: screen) in _screens.entries) {
      for (final width in screen.widths) {
        testWidgets('$name · ${width.toInt()}', (tester) async {
          await _check(tester, screen, Size(width, _height), usePseudoLocale);
          // Proves the pseudo strings, not English, were on screen.
          expect(find.textContaining('⟦', findRichText: true), findsWidgets);
        });
      }
    }
  });

  for (final locale in ['de', 'fr', 'es']) {
    group(locale, () {
      for (final MapEntry(key: name, value: screen) in _screens.entries) {
        final size = Size(screen.widths.first, _height);
        testWidgets('$name · ${size.width.toInt()}', (tester) async {
          await _check(tester, screen, size, () => useTestLocale(locale));
        });
      }
    });
  }
}
