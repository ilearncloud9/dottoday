import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/look/recent_icons.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/look/recent_list.dart';
import 'package:dottoday/shared/pickers/look/look_parts.dart';
import 'package:dottoday/shared/pickers/look/look_sheet.dart';
import 'package:dottoday/shared/pickers/task_icon_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/a11y.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// Recently used icons in memory (the store has its own test).
class _Recent extends RecentIcons {
  @override
  Future<List<String>> build() async => const [];

  @override
  Future<void> use(String iconKey) async =>
      state = AsyncData(pushRecent(state.value ?? [], iconKey, max: 8));
}

/// Colour and icon on phones (M19.4 part 4c-2; ED-086, ED-161, ED-221):
/// live picks, All icons with Recently used, All colours with a typed hex
/// and Your colours, and the select bar's colour alone.
late ProviderContainer _container;
final _picks = <TaskLook>[];
TaskColor? _only;

Future<void> _open(
  WidgetTester tester, {
  String title = 'Go for a run',
  bool only = false,
  ThemeMode theme = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _picks.clear();
  _only = null;
  _container = ProviderContainer(
    overrides: [
      ...timelineOverrides(now: DateTime.utc(2026, 11, 19, 9)),
      recentIconsProvider.overrideWith(_Recent.new),
    ],
  );
  addTearDown(_container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: _container,
      child: testApp(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  if (only) {
                    _only = await showColourOnly(context);
                    return;
                  }
                  await showTaskLook(
                    context,
                    colour: TaskColor.indigo,
                    icon: TaskIcon.fromKey('deep_work'),
                    title: title,
                    onChanged: _picks.add,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
        themeMode: theme,
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('compact: a colour lands at once; Done closes', (tester) async {
    await _open(tester);
    expect(find.text('Colour and icon'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Suggested'), findsOneWidget, reason: '"run" is a guess');
    await tester.ensureVisible(find.bySemanticsLabel('Brown'));
    await tester.tap(find.bySemanticsLabel('Brown'));
    await tester.pump();
    expect(_picks.single.color, TaskColor.brown, reason: 'live, before Done');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Colour and icon'), findsNothing);
  });

  testWidgets('All icons: search, pick, and it is Recent next time', (
    tester,
  ) async {
    await _open(tester);
    await tester.tap(find.textContaining('All icons ·'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Deep Work ·'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'bike');
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is LookIconCircle && w.icon.key == 'bike',
      ),
    );
    await tester.pumpAndSettle();
    final picked = _picks.last.icon;
    expect(picked.key, 'bike');
    expect(await _container.read(recentIconsProvider.future), [picked.key]);
    expect(find.text('Recently used'), findsNothing, reason: 'while searching');
  });

  testWidgets('drag up opens All icons; Back returns', (tester) async {
    await _open(tester);
    await tester.fling(find.text('Current'), const Offset(0, -300), 1000);
    await tester.pumpAndSettle();
    expect(find.textContaining('Search'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Colour and icon'), findsOneWidget);
  });

  testWidgets('All colours: a typed hex is a custom colour, its ring derived', (
    tester,
  ) async {
    await _open(tester);
    await tester.tap(find.byTooltip('All colours'));
    await tester.pumpAndSettle();
    expect(find.text('DOTTODAY COLOURS'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '#F0A28E');
    await tester.pump();
    expect(_picks.last.color.key, '#F0A28E');
    expect(find.textContaining('Ring adjusted to'), findsOneWidget);
  });

  testWidgets('Your colours: + saves the colour; Edit removes it', (
    tester,
  ) async {
    await _open(tester);
    await tester.tap(find.byTooltip('All colours'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '#1A2B3C');
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Save to Your colours'));
    await tester.pumpAndSettle();
    final saved = await _container.read(currentProfileProvider.future);
    expect(saved.yourColours, ['#1A2B3C']);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Remove #1A2B3C'));
    await tester.pumpAndSettle();
    final after = await _container.read(currentProfileProvider.future);
    expect(after.yourColours, isEmpty);
  });

  testWidgets('the select bar gets a colour on Done, nothing live', (
    tester,
  ) async {
    await _open(tester, only: true);
    expect(find.text('All colours'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Plum'));
    await tester.pump();
    expect(_picks, isEmpty);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(_only, TaskColor.plum);
  });

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('a11y holds, ${platform.name} ${mode.name}', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          await _open(tester, theme: mode);
          await expectA11yGuidelines(tester);
          await tester.tap(find.byTooltip('All colours'));
          await tester.pumpAndSettle();
          await expectA11yGuidelines(tester);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }
  }
}
