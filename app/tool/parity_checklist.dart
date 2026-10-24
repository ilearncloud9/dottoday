// Generates docs/parity-checklist.md (R-13, docs/09 M8.4) from the PRD's
// feature IDs and the rows in tool/parity/parity_rows*.dart.
//
// Run from app/:  dart run tool/parity_checklist.dart
//                 dart run tool/parity_checklist.dart --check  (CI-style)
// test/policy/parity_checklist_test.dart fails when the file is stale or a
// PRD ID has no row.
import 'dart:io';

import 'parity/parity_model.dart';
import 'parity/parity_render.dart';
import 'parity/parity_rows.dart';

void main(List<String> args) {
  final (features, prdProblems) = parsePrd(File(prdPath).readAsStringSync());
  final problems = [
    ...prdProblems,
    ...validate(
      features: features,
      rows: parityRows,
      plan: File(planPath).readAsStringSync(),
      exists: evidenceExists,
    ),
  ];
  final doc = renderChecklist(features, parityRows, parityRuns);
  final file = File(checklistPath);
  final stale = !file.existsSync() || file.readAsStringSync() != doc;
  if (args.contains('--check')) {
    for (final p in problems) {
      stderr.writeln(p);
    }
    if (stale) stderr.writeln('$checklistPath is stale');
    exitCode = problems.isEmpty && !stale ? 0 : 1;
    return;
  }
  file.writeAsStringSync(doc);
  stdout.writeln('Wrote $checklistPath (${features.length} features)');
  for (final p in problems) {
    stderr.writeln(p);
  }
  if (problems.isNotEmpty) exitCode = 1;
}
