import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';
import 'settings_harness.dart';

/// Trash's permanent delete (docs/02 F7.6, ED-336/ED-337): Delete now and
/// Empty Trash each confirm once, with an ink action, before anything goes.
Occurrence _gone(int n, String title) => Occurrence(
  id: '0199f0c0-0000-7000-8000-00000000000$n',
  userId: testUserId,
  title: title,
  tzId: 'Europe/Berlin',
  durationMin: 30,
  createdAt: DateTime.utc(2026, 10),
  updatedAt: DateTime.utc(2026, 10),
  deletedAt: DateTime.utc(2026, 10, 20, n),
);

final _rows = [_gone(1, 'Old plan'), _gone(2, 'Call Sam')];

Future<SettingsHarness> _openTrash(
  WidgetTester tester, {
  Size size = const Size(390, 4200),
  ThemeMode mode = ThemeMode.light,
}) async {
  final h = await pumpSettings(tester, rows: _rows, size: size, mode: mode);
  if (find.text('Trash').evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      find.text('Trash'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(find.text('Trash').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Trash').first);
  await tester.pumpAndSettle();
  return h;
}

Finder _dialogButton(String label) => find.ancestor(
  of: find.descendant(of: find.byType(AlertDialog), matching: find.text(label)),
  matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
);

/// The action is ink (the accent's filled button), never the error red.
void _expectInkAction(WidgetTester tester, String label) {
  final button = _dialogButton(label);
  expect(button, findsOneWidget);
  expect(tester.widget(button), isA<FilledButton>());
  final context = tester.element(button);
  final scheme = Theme.of(context).colorScheme;
  final fill = tester
      .widget<Material>(
        find.descendant(of: button, matching: find.byType(Material)).first,
      )
      .color;
  expect(fill, DotTheme.of(context).colors.accentFill);
  expect(fill, isNot(scheme.error));
}

void _expectTarget(WidgetTester tester, Finder f) {
  final size = tester.getSize(f);
  expect(size.height, greaterThanOrEqualTo(44));
  expect(size.width, greaterThanOrEqualTo(44));
}

void main() {
  group('Delete now', () {
    testWidgets('asks once; Cancel keeps the task', (tester) async {
      final h = await _openTrash(tester);
      await tester.tap(find.text('Delete now').first);
      await tester.pumpAndSettle();
      expect(find.text('Delete “Old plan” now?'), findsOneWidget);
      expect(find.text("It can't be restored after this."), findsOneWidget);
      expect(h.occurrences.rows, hasLength(2), reason: 'nothing before OK');
      _expectInkAction(tester, 'Delete');
      await tester.tap(_dialogButton('Cancel'));
      await tester.pumpAndSettle();
      expect(h.occurrences.rows, hasLength(2));
      expect(find.text('Old plan'), findsOneWidget);
    });

    testWidgets('Delete removes only that task', (tester) async {
      final h = await _openTrash(tester);
      await tester.tap(find.text('Delete now').first);
      await tester.pumpAndSettle();
      await tester.tap(_dialogButton('Delete'));
      await tester.pumpAndSettle();
      expect(h.occurrences.rows.map((o) => o.title), ['Call Sam']);
      expect(find.text('Old plan'), findsNothing);
      expect(find.text('Call Sam'), findsOneWidget);
    });

    testWidgets('confirm: labelled, 44 pt targets', (tester) async {
      await _openTrash(tester);
      final semantics = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.text('Delete now').first),
        matchesSemantics(
          label: 'Delete now',
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
        ),
      );
      await tester.tap(find.text('Delete now').first);
      await tester.pumpAndSettle();
      _expectTarget(tester, _dialogButton('Cancel'));
      _expectTarget(tester, _dialogButton('Delete'));
      semantics.dispose();
      await expectA11yGuidelines(tester);
    });
  });

  group('Empty Trash', () {
    testWidgets('asks with the count; Cancel keeps everything', (tester) async {
      final h = await _openTrash(tester);
      await tester.tap(find.text('Empty Trash'));
      await tester.pumpAndSettle();
      expect(find.text('Empty Trash?'), findsOneWidget);
      expect(
        find.text(
          "2 tasks will be deleted. They can't be restored after this.",
        ),
        findsOneWidget,
      );
      _expectInkAction(tester, 'Empty Trash');
      await tester.tap(_dialogButton('Cancel'));
      await tester.pumpAndSettle();
      expect(h.occurrences.rows, hasLength(2));
    });

    testWidgets('empties, shows the empty state and a toast without Undo', (
      tester,
    ) async {
      final h = await _openTrash(tester);
      await tester.tap(find.text('Empty Trash'));
      await tester.pumpAndSettle();
      await tester.tap(_dialogButton('Empty Trash'));
      await tester.pumpAndSettle();
      expect(h.occurrences.rows, isEmpty);
      expect(find.text('Trash is empty'), findsOneWidget);
      expect(find.text('Trash emptied'), findsOneWidget);
      expect(find.text('Undo'), findsNothing);
    });

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('confirm a11y ${mode.name}', (tester) async {
        await _openTrash(tester, mode: mode);
        await expectA11yGuidelines(tester);
        await tester.tap(find.text('Empty Trash'));
        await tester.pumpAndSettle();
        _expectTarget(tester, _dialogButton('Cancel'));
        _expectTarget(tester, _dialogButton('Empty Trash'));
        await expectA11yGuidelines(tester);
      });
    }
  });
}
