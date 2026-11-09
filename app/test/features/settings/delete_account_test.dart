import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/features/settings/pages/delete_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/account_screen_fakes.dart';
import '../auth/auth_harness.dart';

// CR-160 D1 (policy §4, interim): export first, the summary, the typed
// word; deleting removes the copy here; the web never offers to keep it.

void main() {
  late FakeAccountActions actions;
  setUp(() => actions = FakeAccountActions());

  Future<void> page(WidgetTester t, {bool browser = false}) =>
      pumpAccountScreen(
        t,
        const DeleteAccountView(owner: 'a', wide: false),
        actions: actions,
        browser: browser,
      );

  Finder deleteButton() => find.widgetWithText(FilledButton, 'Delete account');

  testWidgets('phone: summary, typed word, then delete', (t) async {
    await page(t);
    expect(
      find.textContaining('removes your copy on this device'),
      findsOneWidget,
    );
    expect(find.text('REMOVED FROM THIS DEVICE'), findsOneWidget);
    expect(
      find.text(
        '42 tasks, your settings and 3 changes that haven’t synced. '
        'This can’t be undone.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('stay'), findsNothing);
    expect(t.widget<FilledButton>(deleteButton()).onPressed, isNull);
    await expectA11yGuidelines(t);
    await t.enterText(find.byType(TextField), 'delete');
    await t.pump();
    expect(t.widget<FilledButton>(deleteButton()).onPressed, isNull);
    await t.enterText(find.byType(TextField), 'DELETE');
    await t.pump();
    await tapIn(t, deleteButton());
    await t.pumpAndSettle();
    // Closing D1 releases the queue it held (CR-160 I7).
    expect(actions.calls, ['delete', 'endDeletion']);
  });

  testWidgets('no unsynced changes: just tasks and settings', (t) async {
    actions.summaryValue = (tasks: 1, pending: 0);
    await page(t);
    expect(
      find.text('1 task and your settings. This can’t be undone.'),
      findsOneWidget,
    );
  });

  testWidgets('export fails: said so, nothing deleted', (t) async {
    actions.exportOutcome = OwnerExportOutcome.failed;
    await page(t);
    await tapIn(t, find.text('Export my data first'));
    await t.pumpAndSettle();
    expect(
      find.text(
        'Couldn’t export all your data, so nothing was deleted. Try again.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Exported.'), findsNothing);
    expect(actions.calls, ['export']);
  });

  testWidgets('export closed: not a success', (t) async {
    actions.exportOutcome = OwnerExportOutcome.cancelled;
    await page(t);
    await tapIn(t, find.text('Export my data first'));
    await t.pumpAndSettle();
    expect(find.textContaining('Nothing was saved'), findsOneWidget);
  });

  testWidgets('the server refuses: said, the screen stays', (t) async {
    actions.deleteResult = const Err(
      NetworkFailure(NetworkFailureKind.offline),
    );
    await page(t);
    await t.enterText(find.byType(TextField), 'DELETE');
    await t.pump();
    await tapIn(t, deleteButton());
    await t.pumpAndSettle();
    expect(find.textContaining('offline'), findsOneWidget);
    expect(deleteButton(), findsOneWidget);
  });

  testWidgets('web, wide: a dialog about this browser; Esc closes', (t) async {
    await pumpAccountScreen(
      t,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => deleteAccountFlow(context, 'a'),
            child: const Text('go'), // l10n-ignore: test host
          ),
        ),
      ),
      actions: actions,
      browser: true,
      size: const Size(1280, 800),
    );
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.textContaining('from this browser'), findsWidgets);
    expect(find.textContaining('Removed from this browser:'), findsOneWidget);
    expect(
      find.text('While you’re signed in. Afterwards nothing can be exported.'),
      findsOneWidget,
    );
    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    // Nothing deleted or exported; the held queue is released.
    expect(actions.calls, ['endDeletion']);
  });
}
