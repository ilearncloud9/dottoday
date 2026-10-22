import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/db/database_health.dart';
import 'package:dottoday/data/db/database_unavailable.dart';
import 'package:dottoday/features/recovery/database_recovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';

// The recovery screen in front of an unreadable database (docs/09 M3f.9).

/// A status fixed at [health] that records the recovery steps.
final class _Status extends DatabaseStatus {
  _Status(this.health, {this.answers = true});

  final DatabaseHealth health;
  final bool answers;
  final calls = <String>[];

  @override
  Future<DatabaseHealth> build() async => health;

  @override
  Future<String?> startFresh() async {
    calls.add('fresh');
    return '/data/dottoday.db.unreadable-1';
  }

  @override
  Future<bool> useHere() async {
    calls.add('here');
    if (answers) state = const AsyncData(DatabaseReady());
    return answers;
  }
}

Future<_Status> _pump(WidgetTester tester, _Status status) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseStatusProvider.overrideWith(() => status)],
      child: MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (_, child) => DatabaseGate(child: child!),
        home: const Scaffold(
          body: Text('the app'), // l10n-ignore: test fixture
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return status;
}

void main() {
  testWidgets('ready: the app', (tester) async {
    await _pump(tester, _Status(const DatabaseReady()));
    expect(find.text('the app'), findsOneWidget);
  });

  testWidgets('locked: Start fresh asks once more, then opens the app', (
    tester,
  ) async {
    final status = await _pump(
      tester,
      _Status(const DatabaseBlocked(DatabaseUnavailableReason.keyRejected)),
    );
    expect(find.text("Dottoday can't open your tasks"), findsOneWidget);
    expect(find.textContaining('never deleted'), findsOneWidget);
    await tester.tap(find.text('Start fresh'));
    await tester.pumpAndSettle();
    expect(status.calls, isEmpty, reason: 'one tap only asks');
    await tester.tap(find.text('Yes, start fresh'));
    await tester.pumpAndSettle();
    expect(status.calls, ['fresh']);
    expect(
      find.text('Your old file is kept at /data/dottoday.db.unreadable-1'),
      findsOneWidget,
    );
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('another tab: Use it here, or say it did not answer', (
    tester,
  ) async {
    final status = await _pump(
      tester,
      _Status(
        const DatabaseBlocked(DatabaseUnavailableReason.openInAnotherTab),
        answers: false,
      ),
    );
    expect(find.text('Dottoday is open in another tab'), findsOneWidget);
    await tester.tap(find.text('Use it here'));
    await tester.pumpAndSettle();
    expect(status.calls, ['here']);
    expect(find.textContaining("didn't answer"), findsOneWidget);
  });

  testWidgets('handed off: says so, and can take it back', (tester) async {
    final status = await _pump(tester, _Status(const DatabaseHandedOff()));
    expect(find.text('Dottoday moved to another tab'), findsOneWidget);
    await tester.tap(find.text('Use it here'));
    await tester.pumpAndSettle();
    expect(status.calls, ['here']);
    expect(find.text('the app'), findsOneWidget);
  });

  testWidgets('recovery meets a11y guidelines (R-12)', (tester) async {
    await _pump(
      tester,
      _Status(const DatabaseBlocked(DatabaseUnavailableReason.keyMissing)),
    );
    await expectA11yGuidelines(tester);
  });
}
