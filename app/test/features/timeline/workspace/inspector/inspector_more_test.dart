import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/editing/inspected_task.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_more.dart';
import 'package:dottoday/features/timeline/workspace/inspector/workspace_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../../support/a11y.dart';
import '../../../../support/alerts.dart';
import '../../../../support/test_app.dart';
import '../../../../support/timeline_fakes.dart';

/// The inspector's More rows (E-R2-40 "Mac · inspector", ED-346, M19.4
/// part 4d): Energy and Travel time as ticked pop-ups, Pinned, Delete
/// task; each written at once.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  const menu = MethodChannel('dottoday/context_menu');

  /// Opens Reply to email in the inspector; the menus are Flutter's (no
  /// system menu in a test).
  Future<FakeOccurrenceRepository> pump(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1280, 1100)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          menu,
          (_) async => throw MissingPluginException(),
        );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(menu, null),
    );
    final repo = FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21)));
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: [
          ...timelineOverrides(
            now: DateTime.utc(2026, 10, 21, 8),
            occurrences: repo,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    router.go('/week/2026-10-21');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply to email').first);
    await tester.pumpAndSettle();
    expect(find.byType(InspectorMore), findsOneWidget);
    return repo;
  }

  Finder inMore(Finder f) =>
      find.descendant(of: find.byType(InspectorMore), matching: f);

  Occurrence reply(FakeOccurrenceRepository r) =>
      r.rows.singleWhere((o) => o.title == 'Reply to email');

  void macTest(String name, WidgetTesterCallback body) => testWidgets(
    name,
    body,
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  macTest('Energy: a level is ticked; picking it again clears it', (
    tester,
  ) async {
    final repo = await pump(tester);
    await tester.tap(inMore(find.text('—')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();
    expect(reply(repo).energy, Energy.high);
    await tester.tap(inMore(find.text('High')));
    await tester.pumpAndSettle();
    final high = tester.widget<CheckedPopupMenuItem<Energy>>(
      find.widgetWithText(CheckedPopupMenuItem<Energy>, 'High'),
    );
    expect(high.checked, isTrue);
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();
    expect(reply(repo).energy, isNull, reason: 'the ticked one clears');
  });

  macTest('Travel time: a choice is written', (tester) async {
    final repo = await pump(tester);
    await tester.tap(inMore(find.text('None')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15 min before').last);
    await tester.pumpAndSettle();
    expect(reply(repo).travelBufferMin, 15);
  });

  macTest('Pinned: the switch writes it', (tester) async {
    final repo = await pump(tester);
    expect(reply(repo).pinned, isFalse);
    await tester.tap(inMore(find.byType(Switch)));
    await tester.pumpAndSettle();
    expect(reply(repo).pinned, isTrue);
  });

  macTest('Delete task: confirmed, to Trash, the inspector goes', (
    tester,
  ) async {
    final repo = await pump(tester);
    await tester.tap(inMore(find.text('Delete task')));
    await tester.pumpAndSettle();
    await tester.tap(alertButton('Delete task'));
    await tester.pumpAndSettle();
    expect(reply(repo).deletedAt, isNotNull);
    expect(find.byType(WorkspaceInspector), findsNothing);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(container.read(inspectedTaskProvider), isNull);
  });

  macTest('the rows meet a11y guidelines', (tester) async {
    await pump(tester);
    await expectA11yGuidelines(tester);
  });
}
