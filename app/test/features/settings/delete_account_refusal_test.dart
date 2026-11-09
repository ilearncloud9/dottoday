import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/reminder_refusal.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/features/notifications/reminder_refusal_snack.dart';
import 'package:dottoday/features/settings/pages/delete_account.dart';
import 'package:dottoday/shared/account/account_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/account_screen_fakes.dart';
import '../../support/test_l10n.dart';
import '../auth/auth_harness.dart';

// CR-160 §4: a reminder action refused while D1 is open. On wider windows
// D1 is a dialog: the refusal is said in its own error line (a SnackBar
// would be under the barrier, dimmed and never announced). On phones D1 is
// a page and the app's SnackBar shows on it. Deletion errors come first.

const _refused = "Couldn't save on this device. Try again."; // failureStorage
const _changed = 'Something new arrived for this account after you started';

/// [FakeAccountActions] whose deletion waits for [finish].
final class _SlowDelete extends FakeAccountActions {
  Completer<Result<void, AppFailure>>? finish;

  @override
  Future<Result<void, AppFailure>> deleteAccount() async {
    calls.add('delete');
    final f = finish;
    return f == null ? deleteResult : f.future;
  }
}

final _nav = GlobalKey<NavigatorState>();

void main() {
  late _SlowDelete actions;
  setUp(() => actions = _SlowDelete());

  /// The app as far as this needs: the root's refusal listener (the real
  /// [showReminderRefusal]) over a screen that opens D1.
  Future<void> host(
    WidgetTester t, {
    required Size size,
    TargetPlatform platform = TargetPlatform.iOS,
    bool browser = false,
    bool dark = false,
    double textScale = 1,
  }) async {
    t.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    t.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await t.pumpWidget(
      ProviderScope(
        overrides: accountScreenOverrides(actions, browser: browser),
        child: MaterialApp(
          navigatorKey: _nav,
          theme: (dark ? DotTheme.dark() : DotTheme.light()).copyWith(
            platform: platform,
          ),
          localizationsDelegates: testL10nDelegates,
          supportedLocales: testL10nLocales,
          locale: testL10nLocale,
          home: Consumer(
            builder: (context, ref, _) {
              ref.listen(reminderRefusalProvider, (_, r) {
                if (r == null) return;
                showReminderRefusal(
                  ref,
                  _nav.currentState?.overlay?.context,
                  r,
                );
              });
              return Scaffold(
                body: TextButton(
                  onPressed: () => deleteAccountFlow(context, 'a'),
                  child: const Text('go'), // l10n-ignore: test host
                ),
              );
            },
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> openD1(WidgetTester t) async {
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
  }

  ProviderContainer container(WidgetTester t) => ProviderScope.containerOf(
    t.element(find.text('go', skipOffstage: false)),
  );

  /// A refusal for a tap begun in owner session [epoch] (now: the current).
  Future<void> refuse(WidgetTester t, {int? epoch}) async {
    final c = container(t);
    c
        .read(reminderRefusalProvider.notifier)
        .report(
          const StorageFailure(),
          epoch: epoch ?? c.read(ownerEpochProvider),
        );
    await t.pumpAndSettle();
  }

  Future<void> confirm(WidgetTester t) async {
    await t.enterText(find.byType(TextField), 'DELETE');
    await t.pump();
    await tapIn(t, find.widgetWithText(FilledButton, 'Delete account'));
    await t.pump();
  }

  /// The refusal is said inside the visible dialog, on top, announced,
  /// exactly once, and D1 stays open with its hold.
  Future<void> expectInDialog(WidgetTester t) async {
    final semantics = t.ensureSemantics();
    final inside = find.descendant(
      of: find.byType(Dialog),
      matching: find.text(_refused),
    );
    expect(inside, findsOneWidget);
    expect(inside.hitTestable(), findsOneWidget, reason: 'on top, not dimmed');
    expect(find.text(_refused), findsOneWidget, reason: 'no second copy');
    expect(find.byType(SnackBar), findsNothing);
    expect(
      t.getSemantics(inside),
      isSemantics(label: _refused, isLiveRegion: true),
    );
    final line = t.widget<StatusLine>(
      find.ancestor(of: inside, matching: find.byType(StatusLine)),
    );
    expect(line.text, _refused, reason: 'no task or account detail');
    expect(find.byType(Dialog), findsOneWidget);
    expect(actions.calls, isNot(contains('endDeletion')));
    semantics.dispose();
  }

  final wide = {
    'tablet': (size: const Size(1024, 1366), p: TargetPlatform.iOS, web: false),
    'mac': (size: const Size(1440, 900), p: TargetPlatform.macOS, web: false),
    'web': (size: const Size(1280, 800), p: TargetPlatform.macOS, web: true),
  };

  for (final MapEntry(key: name, value: w) in wide.entries) {
    testWidgets('$name: a refusal is said inside the D1 dialog', (t) async {
      await host(t, size: w.size, platform: w.p, browser: w.web);
      await openD1(t);
      await refuse(t);
      await expectInDialog(t);
      await expectA11yGuidelines(t);
    });

    testWidgets('$name: during the deletion it shows, D1 stays', (t) async {
      await host(t, size: w.size, platform: w.p, browser: w.web);
      await openD1(t);
      actions.finish = Completer();
      await confirm(t);
      await refuse(t);
      await expectInDialog(t);
      actions.finish!.complete(const Err(ReviewChangedFailure()));
      await t.pumpAndSettle();
    });
  }

  testWidgets('phone: D1 is a page; the SnackBar shows on it, once', (t) async {
    await host(t, size: const Size(390, 844));
    await openD1(t);
    expect(find.byType(Dialog), findsNothing);
    await refuse(t);
    final snack = find.descendant(
      of: find.byType(SnackBar),
      matching: find.text(_refused),
    );
    expect(snack.hitTestable(), findsOneWidget);
    expect(find.text(_refused), findsOneWidget);
    expect(actions.calls, isNot(contains('endDeletion')));
  });

  testWidgets('D1 closed: the SnackBar, as before', (t) async {
    await host(t, size: const Size(1280, 800));
    await refuse(t);
    expect(find.text(_refused).hitTestable(), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('"something changed" wins over the refusal', (t) async {
    await host(t, size: const Size(1280, 800));
    await openD1(t);
    actions.finish = Completer();
    await confirm(t);
    await refuse(t);
    actions.finish!.complete(const Err(ReviewChangedFailure()));
    await t.pumpAndSettle();
    expect(find.textContaining(_changed), findsOneWidget);
    expect(find.text(_refused), findsNothing);
    expect(find.byType(Dialog), findsOneWidget);
    // The typed word is asked again: deleting needs it.
    final delete = find.widgetWithText(FilledButton, 'Delete account');
    expect(t.widget<FilledButton>(delete).onPressed, isNull);
  });

  testWidgets('a server error wins over the refusal', (t) async {
    await host(t, size: const Size(1280, 800));
    await openD1(t);
    actions.finish = Completer();
    await confirm(t);
    await refuse(t);
    actions.finish!.complete(
      const Err(NetworkFailure(NetworkFailureKind.offline)),
    );
    await t.pumpAndSettle();
    expect(find.textContaining('offline'), findsOneWidget);
    expect(find.text(_refused), findsNothing);
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('deleted while a refusal shows: the dialog closes and it is '
      'not said again; a fresh one afterwards shows as usual', (t) async {
    await host(t, size: const Size(1280, 800));
    await openD1(t);
    actions.finish = Completer();
    await confirm(t);
    await refuse(t);
    actions.finish!.complete(const Ok(null));
    await t.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.text(_refused), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    // Same session, D1 closed: the usual SnackBar.
    await refuse(t);
    expect(find.text(_refused).hitTestable(), findsOneWidget);
  });

  testWidgets('a refusal from an ended owner session is never shown: not '
      'in D1, not as a SnackBar', (t) async {
    await host(t, size: const Size(1280, 800));
    final start = container(t).read(ownerEpochProvider);
    container(t).read(ownerEpochProvider.notifier).next();
    await refuse(t, epoch: start);
    expect(find.text(_refused), findsNothing);
    await openD1(t);
    await refuse(t, epoch: start);
    expect(find.text(_refused), findsNothing);
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('a refusal waiting behind another SnackBar when the owner '
      'changes never appears to the next owner', (t) async {
    await host(t, size: const Size(390, 844));
    ScaffoldMessenger.of(
      t.element(find.text('go')),
    ).showSnackBar(const SnackBar(content: Text('earlier'))); // l10n-ignore
    await t.pump();
    await refuse(t);
    expect(find.text(_refused), findsNothing, reason: 'queued, not shown');
    container(t).read(ownerEpochProvider.notifier).next();
    await t.pumpAndSettle(const Duration(seconds: 1));
    for (var i = 0; i < 12; i++) {
      await t.pump(const Duration(seconds: 1));
      expect(find.text(_refused), findsNothing);
    }
    await t.pumpAndSettle();
    expect(find.text(_refused), findsNothing);
  });

  testWidgets('a refusal on screen when the owner changes goes at once', (
    t,
  ) async {
    await host(t, size: const Size(390, 844));
    await refuse(t);
    expect(find.text(_refused), findsOneWidget);
    container(t).read(ownerEpochProvider.notifier).next();
    await t.pumpAndSettle();
    expect(find.text(_refused), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  for (final dark in [false, true]) {
    for (final size in [const Size(1024, 1366), const Size(1280, 800)]) {
      testWidgets('fits at 200% text, ${dark ? 'dark' : 'light'}, '
          '${size.width.toInt()} wide', (t) async {
        await host(t, size: size, dark: dark, textScale: 2);
        await openD1(t);
        await refuse(t);
        expect(t.takeException(), isNull, reason: 'no overflow');
        final text = find.text(_refused);
        await t.ensureVisible(text);
        await t.pumpAndSettle();
        final dialog = t.getRect(find.byType(Dialog));
        final line = t.getRect(text);
        expect(dialog.contains(line.topLeft), isTrue);
        expect(dialog.contains(line.bottomRight), isTrue);
        expect(text.hitTestable(), findsOneWidget);
      });
    }
  }
}
