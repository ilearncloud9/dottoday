import 'dart:io';

import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/14 §3 and §6, M16 policy test: every FeatureId has a row, and the
// Dart table is the doc's table, row for row, so neither can drift.

/// docs/14 §3 as {Feature cell: In minimal mode cell}, in the doc's order.
List<(String, String)> _docRows() {
  final doc = File('../docs/14-minimal-mode.md').readAsLinesSync();
  final start = doc.indexWhere((l) => l.startsWith('## 3. Feature matrix'));
  final end = doc.indexWhere((l) => l.startsWith('## 4.'), start);
  return [
    for (final line in doc.sublist(start, end))
      if (line.startsWith('| ') &&
          !line.startsWith('| Feature |') &&
          !line.startsWith('| ---'))
        if (line.split(' | ') case [final f, _, final v, ...])
          (f.substring(2), v),
  ];
}

void main() {
  test('every FeatureId has a row in the minimal table', () {
    final missing = [
      for (final id in FeatureId.values)
        if (!LayoutPolicy.minimalTable.containsKey(id)) id,
    ];
    expect(missing, isEmpty, reason: 'add the §3 row and its policy entry');
  });

  test('the table is docs/14 §3, row for row', () {
    final code = [
      for (final id in FeatureId.values)
        (id.docRow, _cell(LayoutPolicy.minimalTable[id]!)),
    ];
    expect(code, _docRows());
  });

  test('full shows everything; minimal follows the table', () {
    const full = LayoutPolicy(UiLayout.full);
    const minimal = LayoutPolicy(UiLayout.minimal);
    for (final id in FeatureId.values) {
      expect(full.visibility(id), FeatureVisibility.shown, reason: '$id');
      expect(minimal.visibility(id), LayoutPolicy.minimalTable[id]);
    }
    expect(minimal.visibility(FeatureId.search).onScreen, isFalse);
    expect(minimal.visibility(FeatureId.weekStrip).onScreen, isTrue);
  });
}

String _cell(FeatureVisibility v) => switch (v) {
  FeatureVisibility.shown => 'Shown',
  FeatureVisibility.simplified => 'Simplified',
  FeatureVisibility.hidden => 'Hidden',
  FeatureVisibility.off => 'Off',
};
