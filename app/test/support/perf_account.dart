import 'package:dottoday/domain/export/export_bundle.dart';

import '../domain/fixtures.dart';

// CR-160 Stage B measurements: the reference account, apart from the
// native-only files of perf_world.dart so the web measurement (B8) can
// build it too.

const _notes = 9990;

/// [n] tasks of about 10 KB of JSON each, owned by [owner], exported [at].
ExportBundle perfAccountAt(int n, String owner, DateTime at) => ExportBundle(
  exportedAt: at,
  profile: profileFixture().copyWith(id: owner),
  occurrences: [
    for (var i = 0; i < n; i++)
      occurrenceFixture().copyWith(
        id: '01928c3e-0000-7000-8009-${i.toString().padLeft(12, '0')}',
        userId: owner,
        title: 'Row $i',
        notes: '${'n' * _notes} $i',
      ),
  ],
);
