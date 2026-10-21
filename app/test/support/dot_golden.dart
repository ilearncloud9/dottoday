import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// One cell of the design-review golden matrix (docs/10 §7, 08 §7).
typedef GoldenCell = ({String theme, double width, double ratio});

/// Representative widths of the three width classes (docs/10 §4): iPhone
/// (390), a narrow window (700) and the Mac/web renders (1280).
const goldenWidths = {'compact': 390.0, 'medium': 700.0, 'expanded': 1280.0};

/// Every component golden runs in light and dark × the three width classes
/// × 1× and 2× (docs/10 §7.1, §7.3). [build] gets the cell so it can lay
/// out per width; [height] is the logical canvas height. Components that
/// exist only from a width class up (§4: Mac/web Week, Month) pass
/// [widths].
///
/// ```dart
/// goldenMatrix('task_dot', height: 120, build: (_) => const _Specimen());
/// ```
void goldenMatrix(
  String name, {
  required double height,
  required Widget Function(GoldenCell cell) build,
  TargetPlatform platform = TargetPlatform.iOS,
  Set<String> widths = const {'compact', 'medium', 'expanded'},
}) {
  for (final theme in ['light', 'dark']) {
    for (final MapEntry(key: widthName, value: width) in goldenWidths.entries) {
      if (!widths.contains(widthName)) continue;
      for (final ratio in [1.0, 2.0]) {
        final cell = (theme: theme, width: width, ratio: ratio);
        final file = '${name}_${theme}_${widthName}_${ratio.toInt()}x.png';
        testWidgets('$name $theme $widthName ${ratio.toInt()}x', (
          tester,
        ) async {
          tester.view
            ..physicalSize = Size(width, height) * ratio
            ..devicePixelRatio = ratio;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            goldenApp(build(cell), theme: theme, platform: platform),
          );
          await tester.pumpAndSettle();
          // matchesGoldenFile on a finder always captures at ratio 1, so
          // render the frame's boundary at this cell's ratio ourselves.
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(GoldenFrame.boundaryKey),
          );
          final image = await tester.runAsync(
            () => boundary.toImage(pixelRatio: ratio),
          );
          await expectLater(image, matchesGoldenFile('goldens/$file'));
        });
      }
    }
  }
}

/// [MaterialApp] with the Concept A theme, l10n and [platform] idiom around
/// [child], framed in [GoldenFrame] for the golden finder.
Widget goldenApp(
  Widget child, {
  String theme = 'light',
  TargetPlatform platform = TargetPlatform.iOS,
}) {
  final data = theme == 'dark' ? DotTheme.dark() : DotTheme.light();
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: data.copyWith(platform: platform),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: GoldenFrame(child: child),
  );
}

/// The surface a golden captures: the page background behind [child].
class GoldenFrame extends StatelessWidget {
  const GoldenFrame({required this.child, super.key});

  final Widget child;

  /// The boundary the matrix captures.
  static const boundaryKey = ValueKey('golden-frame');

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    key: boundaryKey,
    child: Material(color: DotTheme.of(context).colors.surface, child: child),
  );
}
