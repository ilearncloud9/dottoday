// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

final _interface = [
  DotGlyphs.today,
  DotGlyphs.inbox,
  DotGlyphs.week,
  DotGlyphs.search,
  DotGlyphs.settings,
  DotGlyphs.add,
  DotGlyphs.check,
  DotGlyphs.chevronDown,
  DotGlyphs.chevronLeft,
  DotGlyphs.chevronRight,
  DotGlyphs.arrowLeft,
  DotGlyphs.close,
  DotGlyphs.more,
  DotGlyphs.moreVertical,
  DotGlyphs.lock,
  DotGlyphs.repeat,
  DotGlyphs.sun,
  DotGlyphs.moon,
  DotGlyphs.sunrise,
  DotGlyphs.bell,
  DotGlyphs.clock,
  DotGlyphs.timer,
  DotGlyphs.calendar,
  DotGlyphs.globe,
  DotGlyphs.keyboard,
  DotGlyphs.trash,
  DotGlyphs.edit,
  DotGlyphs.move,
  DotGlyphs.bolt,
  DotGlyphs.rollForward,
  DotGlyphs.dottedLine,
  DotGlyphs.sort,
  DotGlyphs.undo,
];

/// Every glyph: interface set in text colour (normal and active stroke),
/// then Dottoday's own planning icons in the task colours (the whole
/// library has its own golden, task_icon_library_golden_test.dart).
class _Sheet extends StatelessWidget {
  const _Sheet();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final colors = TaskColor.values;
    return ColoredBox(
      color: t.colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.page),
        child: Wrap(
          spacing: DotSpace.l,
          runSpacing: DotSpace.l,
          children: [
            for (final g in _interface) DotIcon(g, color: t.colors.text),
            for (final g in _interface)
              DotIcon(g, color: t.colors.accent, active: true),
            for (final (i, icon) in _planning.indexed)
              DotIcon(icon.glyph!, color: colors[i % colors.length].color),
          ],
        ),
      ),
    );
  }
}

final _planning = TaskIcon.picker
    .where((i) => i.category == TaskIconCategory.planning)
    .toList();

void main() {
  setUpAll(loadAppFonts);

  for (final (name, theme) in [
    ('light', DotTheme.light()),
    ('dark', DotTheme.dark()),
  ]) {
    for (final (width, height) in [(390.0, 520.0), (1280.0, 280.0)]) {
      testWidgets('icon sheet $name ${width.toInt()}', (tester) async {
        await tester.binding.setSurfaceSize(Size(width, height));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const Scaffold(body: _Sheet()),
          ),
        );
        await expectLater(
          find.byType(_Sheet),
          matchesGoldenFile('goldens/dot_icons_${name}_${width.toInt()}.png'),
        );
      });
    }
  }
}
