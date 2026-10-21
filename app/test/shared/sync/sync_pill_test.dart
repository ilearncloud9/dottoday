import 'package:dottoday/shared/sync/sync_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

Widget _pill(SyncPillState s, {VoidCallback? onTap, ThemeMode? mode}) =>
    testApp(
      Scaffold(
        body: Center(
          child: SyncPill(state: s, onTap: onTap),
        ),
      ),
      themeMode: mode ?? ThemeMode.light,
    );

void main() {
  const labels = {
    SyncPillState.localOnly: 'On this device',
    SyncPillState.synced: 'Synced',
    SyncPillState.syncing: 'Syncing',
    SyncPillState.offline: 'Offline',
    SyncPillState.error: 'Sync problem',
  };

  for (final MapEntry(key: state, value: label) in labels.entries) {
    testWidgets('$state reads "$label" with its own icon', (tester) async {
      await tester.pumpWidget(_pill(state));
      expect(find.text(label), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
    });
  }

  testWidgets('icons differ per state (colour is not the only signal)', (
    tester,
  ) async {
    final icons = <IconData?>{};
    for (final s in SyncPillState.values) {
      await tester.pumpWidget(_pill(s));
      icons.add(tester.widget<Icon>(find.byType(Icon)).icon);
    }
    expect(icons, hasLength(SyncPillState.values.length));
  });

  testWidgets('tappable when onTap is given', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_pill(SyncPillState.error, onTap: () => taps++));
    await tester.tap(find.byType(SyncPill));
    expect(taps, 1);
    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Sync problem')),
      isSemantics(isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines ($mode)', (tester) async {
      for (final s in SyncPillState.values) {
        await tester.pumpWidget(_pill(s, onTap: () {}, mode: mode));
        await expectA11yGuidelines(tester);
      }
    });
  }
}
