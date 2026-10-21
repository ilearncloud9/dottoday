import 'package:flutter_test/flutter_test.dart';

import 'import_boundaries.dart';
import 'source_scan.dart';

void main() {
  group('importViolations', () {
    test('feature → other feature (package and relative)', () {
      const src = '''
import 'package:dottoday/features/inbox/inbox_screen.dart';
import '../../inbox/widgets/row.dart';
import 'package:dottoday/features/timeline/model.dart';
import 'block.dart';
''';
      expect(
        importViolations('features/timeline/widgets/x.dart', src),
        hasLength(2),
      );
    });

    test('domain → flutter', () {
      const src = '''
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:dottoday/core/clock/clock.dart';
''';
      expect(
        importViolations('domain/entities/series.dart', src),
        hasLength(2),
      );
    });

    test('shared and core → features; exports count too', () {
      const imp = "import 'package:dottoday/features/inbox/a.dart';";
      const exp = "export '../features/inbox/a.dart';";
      expect(importViolations('shared/app_sheet.dart', imp), hasLength(1));
      expect(importViolations('core/x.dart', exp), hasLength(1));
    });

    test('drift/sqlite3 outside data', () {
      const src = '''
import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';
''';
      expect(importViolations('domain/x.dart', src), hasLength(2));
      expect(importViolations('features/inbox/x.dart', src), hasLength(2));
      expect(importViolations('data/db/x.dart', src), isEmpty);
    });

    test('allowed edges', () {
      const src = '''
import 'package:dottoday/domain/repos.dart';
import 'package:dottoday/data/db.dart';
import 'package:dottoday/shared/app_sheet.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
''';
      expect(
        importViolations('features/inbox/inbox_screen.dart', src),
        isEmpty,
      );
    });
  });

  test('lib/** respects layer boundaries (CLAUDE.md §3)', () {
    final violations = [
      for (final MapEntry(key: path, value: src) in readLibSources(
        'lib',
      ).entries)
        ...importViolations(path, src),
    ];
    expect(violations, isEmpty);
  });
}
