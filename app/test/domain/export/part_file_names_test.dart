import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:flutter_test/flutter_test.dart';

// CR-160 B7 gate, G3: a set's file names come from its export id's random
// tail, so two exports made close together never share a name.
void main() {
  test('exports a minute apart get different file names', () {
    // UUID v7: the first 12 hex digits are the time in ms; 60 000 ms apart
    // leaves the first 8 the same.
    const first = '019a7b3c-1d2e-7f00-8abc-0123456789ab';
    const minuteLater = '019a7b3c-2bc6-7f00-9def-fedcba987654';
    final a = partFileStem('2026-11-12', first);
    final b = partFileStem('2026-11-12', minuteLater);
    expect(a, 'dottoday-backup-2026-11-12-456789ab');
    expect(b, isNot(a));
    expect(manifestFileName(a), isNot(manifestFileName(b)));
    expect(partFileName(a, 1, 6), isNot(partFileName(b, 1, 6)));
  });
}
