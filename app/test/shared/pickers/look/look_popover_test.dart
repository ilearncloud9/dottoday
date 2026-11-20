import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/look/colour_sampler.dart';
import 'package:dottoday/data/look/recent_icons.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/look/recent_list.dart';
import 'package:dottoday/shared/pickers/look/look_custom.dart';
import 'package:dottoday/shared/pickers/look/look_parts.dart';
import 'package:dottoday/shared/pickers/look/look_popover.dart';
import 'package:dottoday/shared/pickers/look/look_sheet.dart';
import 'package:dottoday/shared/pickers/task_icon_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/a11y.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

class _Recent extends RecentIcons {
  @override
  Future<List<String>> build() async => const [];

  @override
  Future<void> use(String iconKey) async =>
      state = AsyncData(pushRecent(state.value ?? [], iconKey, max: 8));
}

/// The Mac's sampler without the Mac: a fixed sample, the panel's picks
/// sent by the test.
class FakeSampler implements ColourSampler {
  void Function(Color)? panel;
  var closed = false;

  @override
  bool get canSample => true;

  @override
  bool get hasPanel => true;

  @override
  Future<Color?> sample() async => const Color(0xFF2E4A6B);

  @override
  Future<void> openPanel(Color start, void Function(Color) onColour) async =>
      panel = onColour;

  @override
  Future<void> closePanel() async => closed = true;
}

/// The colour and icon picker beyond phones (M19.4 part 4c-3; ED-156,
/// ED-298; owner: icons in the popover, the eyedropper and Show Colours…
/// now): the Mac and web popover with Custom colour…, and the phone pages
/// boxed on wide tablets.
late ProviderContainer _container;
late FakeSampler _sampler;
final _picks = <TaskLook>[];
TaskColor? _only;

Future<void> _open(
  WidgetTester tester, {
  Size size = const Size(1280, 800),
  bool only = false,
  ThemeMode theme = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _picks.clear();
  _only = null;
  _sampler = FakeSampler();
  _container = ProviderContainer(
    overrides: [
      ...timelineOverrides(now: DateTime.utc(2026, 11, 20, 9)),
      recentIconsProvider.overrideWith(_Recent.new),
      colourSamplerProvider.overrideWithValue(_sampler),
    ],
  );
  addTearDown(_container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: _container,
      child: testApp(
        Scaffold(
          body: Align(
            alignment: AlignmentDirectional.topStart,
            // The button's own context: the popover points at it.
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  if (only) {
                    _only = await showColourOnly(context);
                    return;
                  }
                  await showTaskLook(
                    context,
                    colour: TaskColor.indigo,
                    icon: TaskIcon.fromKey('deep_work'),
                    title: 'Go for a run',
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

Future<void> _on(TargetPlatform p, Future<void> Function() body) async {
  debugDefaultTargetPlatformOverride = p;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Mac: picks land at once and it stays open; Esc closes', (
    tester,
  ) async {
    await _on(TargetPlatform.macOS, () async {
      await _open(tester);
      expect(find.byType(LookPopover), findsOneWidget);
      expect(find.text('Dottoday colours'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Plum'));
      await tester.pump();
      expect(_picks.single.color, TaskColor.plum);
      expect(find.byType(LookPopover), findsOneWidget, reason: 'stays open');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(LookPopover), findsNothing);
    });
  });

  testWidgets('Mac: the keys move between colours and ↵ picks', (tester) async {
    await _on(TargetPlatform.macOS, () async {
      await _open(tester);
      // Indigo has the keys; → is teal (ED-161's order).
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(_picks.single.color, TaskColor.teal);
    });
  });

  testWidgets('Mac: the title suggests an icon; All icons… searches', (
    tester,
  ) async {
    await _on(TargetPlatform.macOS, () async {
      await _open(tester);
      expect(find.text('Icon'), findsOneWidget);
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is LookIconCircle && w.icon.key == 'run',
        ),
      );
      await tester.pump();
      expect(_picks.last.icon.key, 'run');
      await tester.tap(find.text('All icons…'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'bike');
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is LookIconCircle && w.icon.key == 'bike',
        ),
      );
      await tester.pumpAndSettle();
      expect(_picks.last.icon.key, 'bike');
      expect(find.text('Dottoday colours'), findsOneWidget, reason: 'back');
      expect(await _container.read(recentIconsProvider.future), [
        'bike',
        'run',
      ]);
    });
  });

  testWidgets('Custom colour…: nothing lands until Use and save', (
    tester,
  ) async {
    await _on(TargetPlatform.macOS, () async {
      await _open(tester);
      await tester.tap(find.text('Custom colour…'));
      await tester.pumpAndSettle();
      expect(find.byType(LookCustom), findsOneWidget);
      await tester.enterText(find.byType(TextField), '#F0A28E');
      await tester.pump();
      expect(find.textContaining('Ring adjusted to'), findsOneWidget);
      expect(_picks, isEmpty, reason: 'only on Use and save');
      await tester.ensureVisible(find.text('Use and save'));
      await tester.tap(find.text('Use and save'));
      await tester.pumpAndSettle();
      expect(_picks.single.color.key, '#F0A28E');
      final profile = await _container.read(currentProfileProvider.future);
      expect(profile.yourColours, ['#F0A28E']);
      expect(find.byType(LookCustom), findsNothing);
    });
  });

  testWidgets('Custom colour…: Cancel leaves the task as it was', (
    tester,
  ) async {
    await _on(TargetPlatform.macOS, () async {
      await _open(tester);
      await tester.tap(find.text('Custom colour…'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Cancel'));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(_picks, isEmpty);
      expect(find.text('Custom colour…'), findsOneWidget);
    });
  });

  testWidgets('the eyedropper and Show Colours… set the colour', (
    tester,
  ) async {
    await _on(TargetPlatform.macOS, () async {
      await _open(tester);
      await tester.tap(find.text('Custom colour…'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byTooltip('Pick a colour from the screen'),
      );
      await tester.tap(find.byTooltip('Pick a colour from the screen'));
      await tester.pumpAndSettle();
      expect(find.text('#2E4A6B'), findsOneWidget);
      await tester.ensureVisible(find.text('Show Colours…'));
      await tester.tap(find.text('Show Colours…'));
      await tester.pumpAndSettle();
      _sampler.panel!(const Color(0xFF7A9E4A));
      await tester.pump();
      expect(find.text('#7A9E4A'), findsOneWidget);
      await tester.ensureVisible(find.text('Cancel'));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(_sampler.closed, isTrue, reason: 'closing Custom closes it');
    });
  });

  testWidgets('the select bar: a pick closes it with the colour', (
    tester,
  ) async {
    await _on(TargetPlatform.macOS, () async {
      await _open(tester, only: true);
      expect(find.text('Icon'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Olive'));
      await tester.pumpAndSettle();
      expect(_only, TaskColor.olive);
      expect(find.byType(LookPopover), findsNothing);
    });
  });

  testWidgets('a wide iPad: the phone pages in a popover', (tester) async {
    await _on(TargetPlatform.iOS, () async {
      await _open(tester, size: const Size(1366, 1024));
      expect(find.byType(LookHost), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(Dialog), findsNothing);
      await tester.tap(find.byTooltip('All colours'));
      await tester.pumpAndSettle();
      expect(find.text('DOTTODAY COLOURS'), findsOneWidget);
    });
  });

  testWidgets('a wide Android tablet: the phone pages in a dialog', (
    tester,
  ) async {
    await _on(TargetPlatform.android, () async {
      await _open(tester, size: const Size(1280, 800));
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(LookHost), findsOneWidget);
    });
  });

  testWidgets('a tablet below expanded: the phone sheet', (tester) async {
    await _on(TargetPlatform.iOS, () async {
      await _open(tester, size: const Size(744, 1133));
      expect(find.byType(BottomSheet), findsOneWidget);
    });
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('a11y holds, Mac ${mode.name}', (tester) async {
      await _on(TargetPlatform.macOS, () async {
        await _open(tester, theme: mode);
        await expectA11yGuidelines(tester);
        await tester.tap(find.text('Custom colour…'));
        await tester.pumpAndSettle();
        await expectA11yGuidelines(tester);
      });
    });
    for (final p in [TargetPlatform.iOS, TargetPlatform.android]) {
      testWidgets('a11y holds, wide ${p.name} ${mode.name}', (tester) async {
        await _on(p, () async {
          await _open(tester, size: const Size(1366, 1024), theme: mode);
          await expectA11yGuidelines(tester);
        });
      });
    }
  }
}
