// Store screenshots (docs/09 M8.6, docs/store/README.md): the golden
// sweep's screens and demo day, framed in the app shell, rendered at the
// pixel sizes App Store Connect and Play Console ask for. Not a pass/fail
// test; it writes PNGs. Run from app/:
//   STORE_SCREENSHOTS=1 flutter test --tags store-screenshots
//   STORE_SCREENSHOTS=1 STORE_LOCALES=en,de,fr,es flutter test --tags store-screenshots
// Output: ../docs/store/screenshots/<locale>/<device>_<nn>_<screen>.png.
@Tags(['store-screenshots'])
library;

import 'dart:io';
import 'dart:ui' show ImageByteFormat;

import 'package:dottoday/app_shell.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/inbox/inbox_screen.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/timeline/month_screen.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/week_screen.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../support/sample_inbox.dart';
import '../support/test_l10n.dart';
import '../support/timeline_fakes.dart';

/// A store slot: logical size × ratio = the pixels the console wants.
typedef StoreDevice = ({
  String name,
  Size size,
  double ratio,
  TargetPlatform platform,
  ThemeMode mode,
});

/// iPhone 6.9" (1320 × 2868), iPad 13" (2064 × 2752), Android phone
/// 9:16 (1080 × 1920) and Mac 16:10 (2880 × 1800). The iPhone and Mac
/// sets are light and Android's dark, like the reference renders (docs/10
/// §2.1); every set is the same screens.
const storeDevices = <StoreDevice>[
  (
    name: 'iphone_6_9',
    size: Size(440, 956),
    ratio: 3,
    platform: TargetPlatform.iOS,
    mode: ThemeMode.light,
  ),
  (
    name: 'ipad_13',
    size: Size(1032, 1376),
    ratio: 2,
    platform: TargetPlatform.iOS,
    mode: ThemeMode.light,
  ),
  (
    name: 'android_phone',
    size: Size(432, 768),
    ratio: 2.5,
    platform: TargetPlatform.android,
    mode: ThemeMode.dark,
  ),
  (
    name: 'mac',
    size: Size(1440, 900),
    ratio: 2,
    platform: TargetPlatform.macOS,
    mode: ThemeMode.light,
  ),
];

final _date = DateTime(2026, 10, 21);

/// 09:22 in Berlin: Deep work is live (the Today goldens' moment).
final _now = DateTime.utc(2026, 10, 21, 7, 22);

const _out = '../docs/store/screenshots';
const _boundary = ValueKey('store-frame');

/// What a shot shows: the shell tab (null = no shell), the body, the rows.
typedef _Shot = ({int? tab, Widget body, List<Occurrence> rows});

List<Occurrence> _dayRows() => [...demoDayRows(_date), ...sampleInbox()];

Map<String, _Shot> _shots(StoreDevice d, String locale) {
  final wide = d.size.width >= WidthClass.expandedFrom;
  final deep = demoDayRows(
    _date,
  ).firstWhere((o) => o.title == 'Deep work: roadmap');
  return {
    'today': (tab: 0, body: TodayScreen(date: _date), rows: _dayRows()),
    'add': (tab: null, body: _AddOverToday(locale: locale), rows: _dayRows()),
    if (wide)
      'week': (tab: 2, body: const WeekScreen(), rows: demoWeekRows())
    else
      'task': (tab: null, body: TaskScreen(id: deep.id), rows: _dayRows()),
    'month': (tab: 0, body: const MonthScreen(), rows: demoWeekRows()),
    'inbox': (tab: 1, body: const InboxScreen(), rows: _dayRows()),
  };
}

void main() {
  final enabled = Platform.environment.containsKey('STORE_SCREENSHOTS');
  final locales = (Platform.environment['STORE_LOCALES'] ?? 'en').split(',');

  // The shot list reads the demo day, which needs the zones at load time.
  tz_data.initializeTimeZones();
  setUpAll(() async {
    await loadAppFonts();
    EditableText.debugDeterministicCursor = true;
  });

  for (final locale in locales) {
    for (final device in storeDevices) {
      for (final (i, MapEntry(key: name, value: shot)) in _shots(
        device,
        locale,
      ).entries.indexed) {
        final file = '${device.name}_${i + 1}_$name.png';
        testWidgets('$locale $file', (tester) async {
          if (locale != 'en') useTestLocale(locale);
          await _pump(tester, device, shot);
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(_boundary),
          );
          final image = await tester.runAsync(
            () => boundary.toImage(pixelRatio: device.ratio),
          );
          final png = await tester.runAsync(
            () => image!.toByteData(format: ImageByteFormat.png),
          );
          File('$_out/$locale/$file')
            ..parent.createSync(recursive: true)
            ..writeAsBytesSync(png!.buffer.asUint8List());
        }, skip: !enabled);
      }
    }
  }
}

Future<void> _pump(WidgetTester tester, StoreDevice d, _Shot shot) async {
  tester.view
    ..physicalSize = d.size * d.ratio
    ..devicePixelRatio = d.ratio;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: _now,
        occurrences: FakeOccurrenceRepository(shot.rows),
        subtasks: FakeSubtaskRepository(demoDaySubtasks(_date)),
        profile: testProfile(
          settings: const Settings(use24h: false, firstDayOfWeek: 1),
        ).copyWith(displayName: 'Kody'),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: DotTheme.light().copyWith(platform: d.platform),
        darkTheme: DotTheme.dark().copyWith(platform: d.platform),
        themeMode: d.mode,
        localizationsDelegates: testL10nDelegates,
        supportedLocales: testL10nLocales,
        locale: testL10nLocale,
        builder: (context, child) => RepaintBoundary(
          key: _boundary,
          child: Material(
            color: DotTheme.of(context).colors.surface,
            child: child,
          ),
        ),
        home: shot.tab == null
            ? shot.body
            : _Shell(tab: shot.tab!, body: shot.body),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (shot.body is _AddOverToday) {
    final l10n = AppLocalizations.of(tester.element(find.byType(AddFlowSheet)));
    await tester.tap(find.text(l10n.addContinue));
    await tester.pumpAndSettle();
  }
}

/// The app's shell around [body], [tab] selected.
class _Shell extends StatelessWidget {
  const _Shell({required this.tab, required this.body});

  final int tab;
  final Widget body;

  @override
  Widget build(BuildContext context) => DotShell(
    destinations: shellDestinations(context.l10n, inbox: sampleInbox().length),
    selected: tab,
    onSelect: (_) {},
    onAdd: () {},
    addLabel: context.l10n.quickAddTooltip,
    body: body,
  );
}

/// Today in its shell with Add's step 2 over it: a bottom sheet on phones, the centred
/// popover from medium width (`showAppSheet`), behind the theme's scrim.
class _AddOverToday extends StatelessWidget {
  const _AddOverToday({required this.locale});

  final String locale;

  /// A title with a time the Quick Add parser reads in each language.
  static const _text = {
    'en': 'Go shopping 5pm',
    'de': 'Einkaufen 17 Uhr',
    'fr': 'Courses 17h',
    'es': 'Ir de compras 17:00',
  };

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final compact = MediaQuery.sizeOf(context).width < WidthClass.mediumFrom;
    final sheet = Container(
      decoration: BoxDecoration(
        color: c.raised,
        borderRadius: compact
            ? const BorderRadius.vertical(top: Radius.circular(DotRadii.sheet))
            : BorderRadius.circular(DotRadii.sheet),
      ),
      padding: const EdgeInsets.only(top: DotSpace.l),
      child: AddFlowSheet(
        request: AddRequest(languageCode: locale, text: _text[locale] ?? ''),
      ),
    );
    return Stack(
      children: [
        _Shell(tab: 0, body: TodayScreen(date: DateTime(2026, 10, 21))),
        // showModalBottomSheet's default barrier.
        const Positioned.fill(child: ColoredBox(color: Colors.black54)),
        if (compact)
          Positioned.fill(top: 120, child: sheet)
        else
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: appSheetMaxWidth,
                maxHeight: appSheetMaxHeight,
              ),
              child: sheet,
            ),
          ),
      ],
    );
  }
}
