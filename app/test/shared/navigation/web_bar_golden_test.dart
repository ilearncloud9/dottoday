// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/app_shell.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/web_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

/// The compact web shell (E-MobileWeb, ED-172), Today current, 3 in the
/// Inbox.
class _Web extends StatelessWidget {
  const _Web();

  @override
  Widget build(BuildContext context) => WebBarShell(
    bar: ShellBar(
      items: [
        for (final d in shellDestinations(context.l10n, inbox: 3))
          if (!d.expandedOnly) d,
      ],
      selected: 0,
      onSelect: (_) {},
      onAdd: () {},
      addLabel: context.l10n.quickAddTooltip,
    ),
    body: const SizedBox.expand(),
  );
}

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'shell_web',
    height: 844,
    widths: const {'compact'},
    platform: TargetPlatform.android,
    build: (_) => const _Web(),
  );
}
