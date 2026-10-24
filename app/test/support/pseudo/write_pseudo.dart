import 'dart:io';

import 'pseudo_source.dart';

/// Rewrites the pseudo localizations after an ARB change; the freshness
/// test in `test/core/l10n/pseudo_l10n_test.dart` says when.
void main() {
  final source = File(abstractL10nPath).readAsStringSync();
  File(pseudoOutputPath).writeAsStringSync(pseudoLocalizationsSource(source));
  // Same layout as the rest of test/, so `dart format` in CI stays clean.
  Process.runSync('dart', ['format', pseudoOutputPath]);
  stdout.writeln('wrote $pseudoOutputPath');
}
