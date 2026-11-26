import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A quick open shows no loading dots (E-G4-7 A1, ED-482): only after
// reading has taken over 300 ms; a screen reader hears "Loading" at once.
void main() {
  testWidgets('the dots wait 300 ms', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: LoadingThread()),
      ),
    );
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    await tester.pump(DotTouch.loadingWait);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
