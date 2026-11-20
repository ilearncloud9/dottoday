import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

Widget _host(void Function(BuildContext) onPressed, {ThemeMode? mode}) =>
    testApp(
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => onPressed(context),
              child: const Text('go'), // l10n-ignore: test fixture
            ),
          ),
        ),
      ),
      themeMode: mode ?? ThemeMode.light,
    );

void main() {
  testWidgets('shows message and Undo for the 30 s undo window', (
    tester,
  ) async {
    var undone = 0;
    await tester.pumpWidget(
      _host(
        (c) => showUndoSnackbar(c, message: 'Moved', onUndo: () => undone++),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    // The toast runs the window itself (ED-281: it waits while held), so
    // the messenger never times it out on its own.
    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.persist, isTrue);
    await tester.pump(UndoService.window ~/ 2);
    expect(find.text('Moved'), findsOneWidget);
    expect(find.text('Moved'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    expect(undone, 1);
  });

  testWidgets('a new action replaces the previous snackbar', (tester) async {
    var n = 0;
    await tester.pumpWidget(
      _host((c) => showUndoSnackbar(c, message: 'm${n++}', onUndo: () {})),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('m0'), findsNothing);
    expect(find.text('m1'), findsOneWidget);
  });

  testWidgets('Reduce Motion: it shows at once, without sliding (ED-281)', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      _host((c) => showUndoSnackbar(c, message: 'Moved', onUndo: () {})),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump();
    // No entrance: where it ends up from its first frame.
    final first = tester.getRect(find.text('Moved'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Moved')), first);
  });

  testWidgets('⌘Z\'s undo closes the toast that offered it', (tester) async {
    await tester.pumpWidget(
      _host((c) => showUndoSnackbar(c, message: 'Moved', onUndo: () {})),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    UndoToasts.hide();
    await tester.pumpAndSettle();
    expect(find.text('Moved'), findsNothing);
  });

  testWidgets("an Android tablet: at the content's start (E-R2-7)", (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host((c) => showUndoSnackbar(c, message: 'Moved', onUndo: () {})),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    final bar = tester.getRect(
      find
          .descendant(
            of: find.byType(SnackBar),
            matching: find.byType(Material),
          )
          .first,
    );
    // After the sidebar, one gutter in, not centred.
    expect(bar.left, DotSize.sidebar + DotSpace.l);
    expect(bar.width, DotSize.toastWideMaterial);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('the iPad centres it under the content', (tester) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host((c) => showUndoSnackbar(c, message: 'Moved', onUndo: () {})),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    final bar = tester.getRect(
      find
          .descendant(
            of: find.byType(SnackBar),
            matching: find.byType(Material),
          )
          .first,
    );
    final content = 1280 - DotSize.sidebar;
    expect(bar.center.dx, closeTo(DotSize.sidebar + content / 2, 1));
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines ($mode)', (tester) async {
      await tester.pumpWidget(
        _host(
          (c) => showUndoSnackbar(c, message: 'Moved', onUndo: () {}),
          mode: mode,
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await expectA11yGuidelines(tester);
    });
  }
}
