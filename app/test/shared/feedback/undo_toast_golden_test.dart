// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

/// A page with the Undo toast up (E-R2-7), [reader] as with VoiceOver on.
class _Page extends StatelessWidget {
  const _Page({this.reader = false});

  final bool reader;

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(accessibleNavigation: reader),
    child: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => showUndoSnackbar(
              context,
              message: 'Marked done', // l10n-ignore: test fixture
              onUndo: () {},
            ),
            child: const Text('go'), // l10n-ignore: test fixture
          ),
        ),
      ),
    ),
  );
}

Future<void> _show(WidgetTester tester) async {
  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'undo_toast',
    height: 300,
    build: (_) => const _Page(),
    act: _show,
  );
  goldenMatrix(
    'undo_toast_android',
    height: 300,
    platform: TargetPlatform.android,
    widths: const {'compact', 'expanded'},
    build: (_) => const _Page(),
    act: _show,
  );
  goldenMatrix(
    'undo_toast_reader',
    height: 300,
    widths: const {'compact'},
    build: (_) => const _Page(reader: true),
    act: _show,
  );
}
