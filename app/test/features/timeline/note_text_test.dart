import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/widgets/note_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The task sheet's NOTES, markdown-lite (docs/02 F2.9, docs/09 M8.4c).

Future<void> _pump(WidgetTester tester, String? notes) => tester.pumpWidget(
  MaterialApp(
    theme: DotTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: NoteText(notes: notes)),
  ),
);

/// The span in the tree whose text is [text].
TextSpan _span(WidgetTester tester, String text) {
  for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
    TextSpan? hit;
    rich.text.visitChildren((s) {
      if (s is TextSpan && s.text == text) hit = s;
      return hit == null;
    });
    if (hit case final found?) return found;
  }
  throw StateError('no span "$text"');
}

void main() {
  testWidgets('bold, italic, bullets, numbers and links render', (
    tester,
  ) async {
    await _pump(
      tester,
      'Bring **the deck**\n- *slides* for [Ana](https://x.io/a)\n2. coffee',
    );
    expect(find.text('NOTES'), findsOneWidget);
    expect(find.textContaining('**'), findsNothing);
    expect(_span(tester, 'the deck').style?.fontWeight, FontWeight.w700);
    expect(_span(tester, 'slides').style?.fontStyle, FontStyle.italic);
    expect(_span(tester, 'Ana').style?.decoration, TextDecoration.underline);
    expect(find.text('•'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
  });

  testWidgets('nothing for no notes or a lone link (LINKS lists it)', (
    tester,
  ) async {
    await _pump(tester, null);
    expect(find.text('NOTES'), findsNothing);
    await _pump(tester, '\nhttps://meet.example.com/abc\n');
    expect(find.text('NOTES'), findsNothing);
  });
}
