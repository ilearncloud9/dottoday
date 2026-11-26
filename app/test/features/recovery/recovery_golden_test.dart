// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/db/database_health.dart';
import 'package:dottoday/data/db/database_unavailable.dart';
import 'package:dottoday/features/recovery/database_recovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

// The recovery screens as E-R2-21 §6 draws them (ED-319, ED-479): the key
// missing, Start fresh asked once more, where the old file is kept; web's
// other tab, the tab that handed over, and no answer in 5 s.

final class _Fixed extends DatabaseStatus {
  _Fixed(this.health);

  final DatabaseHealth health;

  @override
  Future<DatabaseHealth> build() async => health;

  @override
  Future<String?> startFresh() async =>
      'Dottoday › dottoday.db.unreadable-2026-11-13-0912';

  @override
  Future<bool> useHere() async => false;
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

  // The steps after a tap (E-R2-21 §6): asked once more, the kept file,
  // and the other tab not answering.
  Override locked() => databaseStatusProvider.overrideWith(
    () => _Fixed(const DatabaseBlocked(DatabaseUnavailableReason.keyRejected)),
  );
  goldenMatrix(
    'recovery_confirm',
    height: 700,
    widths: const {'compact'},
    overrides: [locked()],
    build: (_) => const DatabaseGate(child: SizedBox.shrink()),
    act: (tester) => tester.tap(find.byType(FilledButton)),
  );
  goldenMatrix(
    'recovery_kept',
    height: 700,
    widths: const {'compact'},
    overrides: [locked()],
    build: (_) => const DatabaseGate(child: SizedBox.shrink()),
    act: (tester) async {
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
    },
  );
  goldenMatrix(
    'recovery_no_answer',
    height: 700,
    widths: const {'expanded'},
    overrides: [
      databaseStatusProvider.overrideWith(
        () => _Fixed(
          const DatabaseBlocked(DatabaseUnavailableReason.openInAnotherTab),
        ),
      ),
    ],
    build: (_) => const DatabaseGate(child: SizedBox.shrink()),
    act: (tester) => tester.tap(find.byType(FilledButton)),
  );
}
