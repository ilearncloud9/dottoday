import 'package:dottoday/app_shortcut_groups.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/sheets/shortcut_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// ⌘/ (docs/09 M3e.6): the binding, the sheet, and that the sheet names
// every app-wide command.
void main() {
  test('⌘/ (Ctrl+/ elsewhere) shows the shortcuts', () {
    expect(
      AppShortcuts.table[AppCommand.showShortcuts]!.key,
      LogicalKeyboardKey.slash,
    );
    final mac = AppShortcuts.bindings(TargetPlatform.macOS);
    final slash = mac.entries.singleWhere(
      (e) => (e.key as SingleActivator).trigger == LogicalKeyboardKey.slash,
    );
    expect((slash.key as SingleActivator).meta, isTrue);
    expect((slash.value as AppCommandIntent).command, AppCommand.showShortcuts);
  });

  testWidgets('the sheet lists every app-wide binding and the screens\'', (
    tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    final groups = appShortcutGroups(ctx.l10n);
    final rows = groups.expand((g) => g.rows).length;
    expect(rows, greaterThanOrEqualTo(AppShortcuts.table.length + 10));
    final sheet = showShortcutSheet(ctx, groups);
    await tester.pumpAndSettle();
    expect(find.text('Keyboard shortcuts'), findsOneWidget);
    expect(find.text('Add a task'), findsOneWidget);
    expect(find.text('Ctrl+N'), findsOneWidget);
    expect(find.text('Auto-plan the week'), findsOneWidget);
    expect(find.text('Ctrl+Shift+P'), findsOneWidget);
    Navigator.of(ctx).pop();
    await sheet;
  });
}
