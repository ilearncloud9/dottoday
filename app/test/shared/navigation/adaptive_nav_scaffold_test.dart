import 'package:dottoday/shared/navigation/adaptive_nav_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

const _labels = ['Today', 'Inbox', 'Week', 'Search', 'Settings'];

Widget _scaffold({
  int selected = 0,
  ValueChanged<int>? onSelect,
  Widget? body,
  bool fab = true,
}) {
  return testApp(
    AdaptiveNavScaffold(
      destinations: [
        for (final l in _labels)
          NavDestination(
            icon: Icons.circle_outlined,
            selectedIcon: Icons.circle,
            label: l,
          ),
      ],
      selectedIndex: selected,
      onSelect: onSelect ?? (_) {},
      fab: fab
          ? FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add))
          : null,
      body: body ?? const SizedBox.expand(),
    ),
  );
}

Future<void> _size(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _longList() => ListView.builder(
  itemCount: 40,
  itemExtent: 48,
  itemBuilder: (_, i) => SizedBox(key: ValueKey('row$i')),
);

void main() {
  testWidgets('compact width uses a bottom NavigationBar', (tester) async {
    await _size(tester, const Size(400, 800));
    await tester.pumpWidget(_scaffold());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    for (final l in _labels) {
      expect(find.text(l), findsOneWidget);
    }
  });

  testWidgets('from 600 dp it uses a NavigationRail', (tester) async {
    await _size(tester, const Size(800, 600));
    await tester.pumpWidget(_scaffold());
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  for (final size in [const Size(400, 800), const Size(800, 600)]) {
    testWidgets('tap selects and selected state is exposed ($size)', (
      tester,
    ) async {
      await _size(tester, size);
      int? tapped;
      await tester.pumpWidget(
        _scaffold(selected: 1, onSelect: (i) => tapped = i),
      );
      await tester.tap(find.text('Week'));
      expect(tapped, 2);
      expect(
        tester.getSemantics(find.text('Inbox')),
        isSemantics(isSelected: true),
      );
    });

    testWidgets('no overflow at 200 % text ($size)', (tester) async {
      await _size(tester, size);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(_scaffold());
      expect(tester.takeException(), isNull);
    });

    testWidgets('FAB never covers the end of a scrolled list ($size)', (
      tester,
    ) async {
      await _size(tester, size);
      await tester.pumpWidget(_scaffold(body: _longList()));
      await tester.drag(find.byType(ListView), const Offset(0, -5000));
      await tester.pumpAndSettle();
      final lastBottom = tester
          .getRect(find.byKey(const ValueKey('row39')))
          .bottom;
      final fabTop = tester.getRect(find.byType(FloatingActionButton)).top;
      expect(lastBottom, lessThanOrEqualTo(fabTop));
    });
  }

  testWidgets('no FAB → no extra bottom padding', (tester) async {
    await _size(tester, const Size(400, 800));
    late EdgeInsets padding;
    await tester.pumpWidget(
      _scaffold(
        fab: false,
        body: Builder(
          builder: (context) {
            padding = MediaQuery.paddingOf(context);
            return const SizedBox.expand();
          },
        ),
      ),
    );
    expect(padding.bottom, 0);
  });
}
