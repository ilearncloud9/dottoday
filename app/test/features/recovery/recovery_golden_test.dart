// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/db/database_health.dart';
import 'package:dottoday/data/db/database_unavailable.dart';
import 'package:dottoday/features/recovery/database_recovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

// The recovery screens (derived, docs/09 M3f.9; 10 §5.4).

final class _Fixed extends DatabaseStatus {
  _Fixed(this.health);

  final DatabaseHealth health;

  @override
  Future<DatabaseHealth> build() async => health;
}

void main() {
  setUpAll(loadAppFonts);
  for (final (name, health) in [
    (
      'recovery_locked',
      const DatabaseBlocked(DatabaseUnavailableReason.keyRejected),
    ),
    (
      'recovery_other_tab',
      const DatabaseBlocked(DatabaseUnavailableReason.openInAnotherTab),
    ),
    ('recovery_handed_off', const DatabaseHandedOff()),
  ]) {
    goldenMatrix(
      name,
      height: 700,
      widths: const {'compact', 'expanded'},
      overrides: [databaseStatusProvider.overrideWith(() => _Fixed(health))],
      build: (_) => const DatabaseGate(child: SizedBox.shrink()),
    );
  }
}
