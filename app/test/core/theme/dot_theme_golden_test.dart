// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// Test-only specimen of every Concept A token; literals are fine here.
class _Specimen extends StatelessWidget {
  const _Specimen();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final s = t.styles;
    final roles = {
      'surface': c.surface,
      'raised': c.raised,
      'text': c.text,
      'muted': c.muted,
      'outline': c.outline,
      'hairline': c.hairline,
      'accent': c.accent,
      'accentInk': c.accentInk,
      'tint': Color.alphaBlend(c.accentTint, c.raised),
      'success': c.success,
    };
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(DotSpace.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.xs,
          children: [
            Text('Good morning, Kody', style: s.pageTitle),
            Text('WEDNESDAY 21 OCT', style: s.caption),
            Text('Wednesday · Today', style: s.cardTitle),
            Text('Reply to email', style: s.rowTitle),
            Text('Deep work: roadmap', style: s.liveRowTitle),
            Text('9:00 – 11:00 · 2 h', style: s.rowMeta),
            Text('Done', style: s.button),
            const SizedBox(height: DotSpace.s),
            _swatches(roles, s),
            const SizedBox(height: DotSpace.s),
            _tasks(t),
          ],
        ),
      ),
    );
  }

  Widget _swatches(Map<String, Color> roles, DotType s) => Wrap(
    spacing: DotSpace.s,
    runSpacing: DotSpace.s,
    children: [
      for (final MapEntry(:key, :value) in roles.entries)
        Column(
          children: [
            Container(
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                color: value,
                borderRadius: BorderRadius.circular(DotRadii.card),
                border: Border.all(color: roles['outline']!),
              ),
            ),
            Text(key, style: s.rowMeta),
          ],
        ),
    ],
  );

  Widget _tasks(DotTheme t) => Wrap(
    spacing: DotSpace.s,
    runSpacing: DotSpace.s,
    children: [
      for (final c in TaskColor.values)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DotSpace.m,
            vertical: DotSpace.s,
          ),
          decoration: BoxDecoration(
            color: t.tasks[c].tint,
            borderRadius: BorderRadius.circular(DotRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.xs,
            children: [
              Container(
                width: DotSize.weekDot * 2,
                height: DotSize.weekDot * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.tasks[c].color,
                ),
              ),
              Text(
                c.key,
                style: t.styles.rowMeta.copyWith(color: t.tasks[c].ink),
              ),
            ],
          ),
        ),
    ],
  );
}

void main() {
  setUpAll(loadAppFonts);

  for (final (name, theme) in [
    ('light', DotTheme.light()),
    ('dark', DotTheme.dark()),
    ('light_coral', DotTheme.light(DotAccent.coral)),
  ]) {
    testWidgets('Concept A token specimen $name', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 560));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const _Specimen(),
        ),
      );
      await expectLater(
        find.byType(_Specimen),
        matchesGoldenFile('goldens/dot_theme_specimen_$name.png'),
      );
    });
  }
}
