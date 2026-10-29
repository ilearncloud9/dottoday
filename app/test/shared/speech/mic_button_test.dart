import 'package:dottoday/shared/speech/mic_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

// MicButton (docs/10 §3, docs/09 M14.5): a 48 px toggle button, keyboard
// operable, busy is not tappable, and the dot holds still under reduced
// motion (pumpAndSettle would hang on a breathing dot).

Future<List<int>> _pump(
  WidgetTester tester,
  MicState state, {
  bool reduced = true,
  ThemeMode mode = ThemeMode.light,
}) async {
  final taps = <int>[];
  await tester.pumpWidget(
    testApp(
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: Scaffold(
            body: Center(
              child: MicButton(state: state, onPressed: () => taps.add(1)),
            ),
          ),
        ),
      ),
      themeMode: mode,
    ),
  );
  await tester.pumpAndSettle();
  return taps;
}

void main() {
  testWidgets('idle: "Dictate", 48 px, taps', (tester) async {
    final taps = await _pump(tester, MicState.idle);
    expect(tester.getSize(find.byType(IconButton)), const Size(48, 48));
    await tester.tap(find.byTooltip('Dictate'));
    expect(taps, [1]);
  });

  testWidgets('listening: "Stop dictation", toggled', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, MicState.listening);
    expect(
      tester.getSemantics(find.byType(MicButton)),
      isSemantics(
        label: 'Stop dictation',
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('busy: not tappable', (tester) async {
    final taps = await _pump(tester, MicState.busy);
    await tester.tap(find.byType(IconButton));
    expect(taps, isEmpty);
  });

  testWidgets('keyboard: Tab then Space', (tester) async {
    final taps = await _pump(tester, MicState.idle);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(taps, [1]);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final state in MicState.values) {
      testWidgets('a11y ${mode.name} ${state.name}', (tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, state, mode: mode);
        await expectA11yGuidelines(tester);
        handle.dispose();
      });
    }
  }
}
