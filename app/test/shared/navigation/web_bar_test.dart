import 'package:dottoday/app_shell.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/web_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

Widget webBar({int selected = 0, ValueChanged<int>? onSelect}) => testApp(
  Builder(
    builder: (context) {
      final items = [
        for (final d in shellDestinations(context.l10n, inbox: 3))
          if (!d.expandedOnly) d,
      ];
      return WebBarShell(
        bar: ShellBar(
          items: items,
          selected: selected,
          onSelect: onSelect ?? (_) {},
          onAdd: () {},
          addLabel: context.l10n.quickAddTooltip,
        ),
        body: const SizedBox.expand(),
      );
    },
  ),
);

void main() {
  testWidgets('compact web: labelled places in its own bar, "+ Add" above '
      'it, the current place said as selected (ED-172)', (tester) async {
    final handle = tester.ensureSemantics();
    var picked = -1;
    await tester.pumpWidget(webBar(onSelect: (i) => picked = i));
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Today')),
      matchesSemantics(
        label: 'Today',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.text('Search'));
    expect(picked, greaterThan(0));
    await expectA11yGuidelines(tester);
    handle.dispose();
  });
}
