// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/l10n/generated/app_localizations_en.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// The whole task icon library by category (docs/10 §3, ADR-0012): the
/// review sheet for every drawing, at the picker's 24 px and stroke 2.
class _Library extends StatelessWidget {
  const _Library();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final en = AppLocalizationsEn();
    return ColoredBox(
      color: t.colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final c in TaskIconCategory.values) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: DotSpace.m,
                  bottom: DotSpace.s,
                ),
                child: Text(
                  taskIconCategoryName(en, c).toUpperCase(),
                  style: t.styles.caption,
                ),
              ),
              Wrap(
                spacing: DotSpace.l,
                runSpacing: DotSpace.l,
                children: [
                  for (final i in TaskIcon.picker)
                    if (i.category == c)
                      DotIcon(i.glyph!, color: t.colors.text),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void main() {
  setUpAll(loadAppFonts);

  for (final (name, theme) in [
    ('light', DotTheme.light()),
    ('dark', DotTheme.dark()),
  ]) {
    testWidgets('task icon library $name', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 1500));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const Scaffold(body: _Library()),
        ),
      );
      await expectLater(
        find.byType(_Library),
        matchesGoldenFile('goldens/task_icon_library_$name.png'),
      );
    });
  }
}
