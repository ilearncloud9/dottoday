// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/app_shell.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

class _Shell extends StatelessWidget {
  const _Shell();

  @override
  Widget build(BuildContext context) => DotShell(
    destinations: shellDestinations(context.l10n),
    selected: 0,
    onSelect: (_) {},
    onAdd: () {},
    addLabel: context.l10n.quickAddTooltip,
    body: const SizedBox.expand(),
  );
}

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'shell_iphone',
    height: 844,
    widths: const {'compact'},
    build: (_) => const _Shell(),
  );
  goldenMatrix(
    'shell_android',
    height: 915,
    widths: const {'compact'},
    platform: TargetPlatform.android,
    build: (_) => const _Shell(),
  );
  goldenMatrix(
    'shell_rail',
    height: 800,
    widths: const {'medium', 'expanded'},
    platform: TargetPlatform.macOS,
    build: (_) => const _Shell(),
  );
}
