import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/parity/parity_model.dart';
import '../../tool/parity/parity_render.dart';
import '../../tool/parity/parity_rows.dart';

// The parity checklist is a release gate (R-13, docs/08 §6.2, M8.4): every
// PRD feature ID has a row with a status and evidence on all four targets,
// and docs/parity-checklist.md is what the generator writes.
void main() {
  final (features, prdProblems) = parsePrd(File(prdPath).readAsStringSync());

  test('every PRD feature bullet carries a unique ID', () {
    expect(prdProblems, isEmpty);
    expect(features, isNotEmpty);
  });

  test('every PRD ID has a row with evidence on all four targets', () {
    final problems = validate(
      features: features,
      rows: parityRows,
      plan: File(planPath).readAsStringSync(),
      exists: evidenceExists,
    );
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('docs/parity-checklist.md is fresh '
      '(dart run tool/parity_checklist.dart)', () {
    expect(
      File(checklistPath).readAsStringSync(),
      renderChecklist(features, parityRows, parityRuns),
    );
  });

  test('the validator catches a missing row and a gap without a task', () {
    const f = [
      PrdFeature('F1.1', 'F1. T', 'x'),
      PrdFeature('F1.2', 'F1. T', 'y'),
    ];
    final problems = validate(
      features: f,
      rows: const {'F1.1': ParityRow(tests: [], all: Cell(Status.gap, 'soon'))},
      plan: '- [ ] M1.1 thing',
      exists: (_) => true,
    );
    expect(problems, contains('PRD F1.2 has no parity row'));
    expect(problems.any((p) => p.contains('must name a plan task')), isTrue);
  });

  test('an untagged PRD bullet is reported', () {
    final (_, problems) = parsePrd('## F1. T\n- [F1.1] a\n- new thing\n');
    expect(problems.single, startsWith('untagged PRD bullet in F1'));
  });
}
