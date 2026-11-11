@Tags(['golden'])
library;

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/features/settings/pages/delete_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/account_screen_fakes.dart';
import '../../support/dot_golden.dart';

// CR-160 B7c, Delete account with a set (derived from `DeleteNative` and
// `DeleteWeb`): the uncertain status with "Check my files…", and the
// set's "Delete without a confirmed copy?". Copy approved 2026-11-11.

FakeAccountActions _uncertain() => FakeAccountActions()
  ..exportOutcome = OwnerExportOutcome.uncertain
  ..fileCount = 7
  ..deleteResult = const Err(ExportNotSavedFailure(retryable: true));

void main() {
  setUpAll(loadAppFonts);

  Future<void> export(WidgetTester t) async {
    await t.tap(find.text('Export my data first'));
  }

  for (final (name, wide, widths) in [
    ('account_delete_set_native', false, const {'compact'}),
    ('account_delete_set_web', true, const {'expanded'}),
  ]) {
    goldenMatrix(
      name,
      height: 900,
      widths: widths,
      a11yVariants: !wide,
      overrides: accountScreenOverrides(_uncertain(), browser: wide),
      build: (_) => Scaffold(
        body: DeleteAccountView(owner: 'a', wide: wide),
      ),
      act: export,
    );
  }

  goldenMatrix(
    'account_delete_set_without_copy',
    height: 844,
    widths: const {'compact'},
    overrides: accountScreenOverrides(_uncertain()),
    build: (_) =>
        const Scaffold(body: DeleteAccountView(owner: 'a', wide: false)),
    act: (t) async {
      await export(t);
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField), 'DELETE');
      await t.pump();
      final delete = find.widgetWithText(FilledButton, 'Delete account');
      await t.ensureVisible(delete);
      await t.pumpAndSettle();
      await t.tap(delete);
    },
  );
}
