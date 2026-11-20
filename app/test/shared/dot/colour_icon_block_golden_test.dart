// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/colour_icon_block.dart';
import 'package:dottoday/shared/pickers/task_icon_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'colour_icon_block',
    height: 120,
    build: (_) => Padding(
      padding: const EdgeInsets.all(DotSpace.page),
      child: ColourIconBlock(
        color: TaskColor.coral,
        icon: TaskIcon.bag,
        onColor: (_) {},
        onIcon: (_) {},
      ),
    ),
  );
  // The icon library alone (docs/10 §3 task icon library, ADR-0013;
  // derived), Search's "with icon" filter: search, then the categories
  // from Planning & rhythm down. Colours are Colour and icon's (4c-3).
  goldenMatrix(
    'task_icon_picker',
    height: 760,
    a11yVariants: true,
    build: (_) => Builder(
      builder: (context) => TextButton(
        onPressed: () => showTaskIconPicker(context: context, title: 'Icon'),
        child: const Text('open'),
      ),
    ),
    act: (tester) async {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    },
  );
}
