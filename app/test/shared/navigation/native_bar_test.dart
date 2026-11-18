import 'dart:async';

import 'package:dottoday/app_shell.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/native_bar.dart';
import 'package:dottoday/shared/navigation/pill_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

/// The native row as the shell sees it, recording what it was told.
final class _FakeBar implements NativeBar {
  final configured = <ShellBar>[];
  final visible = <bool>[];
  var removed = false;
  final _events = StreamController<NativeBarEvent>.broadcast();

  void tap(NativeBarEvent event) => _events.add(event);

  @override
  Future<void> configure(ShellBar bar) async => configured.add(bar);

  @override
  Future<void> setVisible({required bool visible}) async =>
      this.visible.add(visible);

  @override
  Future<void> remove() async => removed = true;

  @override
  Stream<NativeBarEvent> get events => _events.stream;
}

Widget _shell(
  NativeBar? native, {
  ValueChanged<int>? onSelect,
  VoidCallback? onAdd,
}) => testApp(
  Builder(
    builder: (context) => DotShell(
      destinations: shellDestinations(context.l10n, inbox: 2),
      selected: 0,
      onSelect: onSelect ?? (_) {},
      onAdd: onAdd ?? () {},
      addLabel: context.l10n.quickAddTooltip,
      native: native,
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => unawaited(
              showDialog<void>(
                context: context,
                builder: (_) => const AlertDialog(),
              ),
            ),
            child: const Text('dialog'), // l10n-ignore: test fixture
          ),
        ),
      ),
    ),
  ),
);

Future<void> _phone(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(402, 874)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('iPhone with the native row: it shows the places, the '
      'selection, the badge and the + name (ED-128 N3)', (tester) async {
    await _phone(tester);
    final bar = _FakeBar();
    await tester.pumpWidget(_shell(bar));
    await tester.pump();
    expect(find.byType(NativeBarShell), findsOneWidget);
    expect(find.byType(PillTabShell), findsNothing);
    final shown = bar.configured.last;
    expect(
      [for (final d in shown.items) d.label],
      ['Today', 'Inbox', 'Search', 'Settings'],
    );
    expect(shown.selected, 0);
    expect(shown.items[1].badge, 2);
    expect(shown.addLabel, 'Add a task');
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('taps on the native row reach the shell', (tester) async {
    await _phone(tester);
    final bar = _FakeBar();
    final picked = <int>[];
    var adds = 0;
    await tester.pumpWidget(
      _shell(bar, onSelect: picked.add, onAdd: () => adds++),
    );
    bar
      ..tap(const NativeBarSelect(1))
      ..tap(const NativeBarAdd());
    await tester.pump();
    expect(picked, [1]);
    expect(adds, 1);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('the row hides while a dialog is open, and comes back', (
    tester,
  ) async {
    await _phone(tester);
    final bar = _FakeBar();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [NativeBarObserver()],
        home: Builder(
          builder: (context) => DotShell(
            destinations: shellDestinations(context.l10n, inbox: 0),
            selected: 0,
            onSelect: (_) {},
            onAdd: () {},
            addLabel: context.l10n.quickAddTooltip,
            native: bar,
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => unawaited(
                  showDialog<void>(
                    context: context,
                    builder: (_) => const AlertDialog(),
                  ),
                ),
                child: const Text('dialog'), // l10n-ignore: test fixture
              ),
            ),
          ),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.tap(find.text('dialog'));
    await tester.pumpAndSettle();
    expect(bar.visible.last, isFalse);
    Navigator.of(tester.element(find.byType(AlertDialog))).pop();
    await tester.pumpAndSettle();
    expect(bar.visible.last, isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('without the native row the iPhone keeps the Flutter bar', (
    tester,
  ) async {
    await _phone(tester);
    await tester.pumpWidget(_shell(null));
    expect(find.byType(PillTabShell), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
