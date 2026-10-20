// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// Test-only specimen; literals are fine here (not shipped UI).
class _Specimen extends StatelessWidget {
  const _Specimen();

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final c = t.colors;
    final swatches = {
      'surfaceRaised': c.surfaceRaised,
      'surfaceSunken': c.surfaceSunken,
      'onSurface': c.onSurface,
      'muted': c.onSurfaceMuted,
      'outline': c.outline,
      'accent': c.accent,
      'success': c.success,
      'warning': c.warning,
      'danger': c.danger,
    };
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Display 28', style: t.typography.display),
            Text('Title 20', style: t.typography.title),
            Text('Body 16 — the quick brown fox', style: t.typography.body),
            Text('Label 13', style: t.typography.label),
            Text('09:30 – 10:15', style: t.typography.mono),
            const SizedBox(height: AppSpacing.l),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final MapEntry(:key, :value) in swatches.entries)
                  Container(
                    width: 100,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: value,
                      borderRadius: BorderRadius.circular(AppRadii.block),
                      border: Border.all(color: c.outline),
                    ),
                    child: Text(key, style: t.typography.label),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              spacing: AppSpacing.s,
              children: [
                for (final r in [AppRadii.block, AppRadii.card, AppRadii.sheet])
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: c.surfaceRaised,
                      borderRadius: BorderRadius.circular(r),
                      border: Border.all(color: c.outline),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  setUpAll(loadAppFonts);

  for (final (name, theme) in [
    ('light', AppTheme.light()),
    ('dark', AppTheme.dark()),
  ]) {
    testWidgets('theme specimen $name', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 520));
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
        matchesGoldenFile('goldens/theme_specimen_$name.png'),
      );
    });
  }
}
