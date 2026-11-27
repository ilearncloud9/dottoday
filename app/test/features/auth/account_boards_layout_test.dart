import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/features/auth/guest_work_screen.dart';
import 'package:dottoday/features/auth/removal_retry_screen.dart';
import 'package:dottoday/features/settings/pages/delete_account.dart';
import 'package:dottoday/shared/account/account_dialog.dart';
import 'package:dottoday/shared/account/choice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/account_screen_fakes.dart';
import 'auth_harness.dart';

// G1, G1b, D1 and the web's retry as the E-CR160 boards draw them
// (ED-495): `GuestWork`, `GuestWorkLocked` (elsewhere as B1),
// `DeleteNative`, `DeleteWeb`, `DeleteWebRetry`.

const _g1 = GuestWorkScreen(
  gate: GuestWorkGate(accountId: 'a', email: 'sam@example.com', eligible: 12),
);

void main() {
  // The real faces, so rows and buttons measure as they do there.
  setUpAll(loadAppFonts);
  late FakeAccountActions actions;
  setUp(() => actions = FakeAccountActions());

  Future<void> open(
    WidgetTester t,
    Widget home, {
    Size size = const Size(390, 844),
    TargetPlatform platform = TargetPlatform.iOS,
    bool browser = false,
  }) => pumpAccountScreen(
    t,
    home,
    actions: actions,
    size: size,
    platform: platform,
    browser: browser,
  );

  Rect button(WidgetTester t, String label) =>
      t.getRect(find.widgetWithText(AccountButton, label));
  List<Rect> cards(WidgetTester t) => [
    for (final e in find.byType(ChoiceCard).evaluate())
      t.getRect(find.byWidget(e.widget)),
  ];

  group('G1', () {
    testWidgets('iPhone: Continue 52 at the foot, cards 20 in', (t) async {
      await open(t, _g1);
      expect(cards(t).first.left, 20);
      final cont = button(t, 'Continue');
      expect(cont.height, 52);
      expect(cont.bottom, closeTo(844 - 36, 1));
    });

    testWidgets('iPad: a centred 680 column, Continue at the end', (t) async {
      await open(t, _g1, size: const Size(1180, 820));
      final [a, b] = cards(t);
      expect(a.width, 680);
      expect(b.top, greaterThan(a.bottom));
      final cont = button(t, 'Continue');
      expect(cont.right, a.right);
      expect(cont.height, 52);
    });

    testWidgets('Mac and web: a 580 column, Continue 40 at the end', (t) async {
      await open(
        t,
        _g1,
        size: const Size(1280, 800),
        platform: TargetPlatform.macOS,
      );
      final a = cards(t).first;
      expect(a.width, 580);
      final cont = button(t, 'Continue');
      expect(cont.height, 40);
      expect(cont.right, a.right);
    });

    testWidgets('G1b: the same frame, Continue 48 on Android', (t) async {
      await open(
        t,
        const GuestNoticeScreen(
          gate: GuestNoticeGate(accountId: 'a', count: 12),
        ),
        platform: TargetPlatform.android,
      );
      expect(button(t, 'Continue').height, 48);
    });
  });

  group('Delete account', () {
    testWidgets('phones: Cancel and Delete side by side, a 48 field', (
      t,
    ) async {
      await open(t, const DeleteAccountView(owner: 'a', wide: false));
      final cancel = button(t, 'Cancel');
      final delete = button(t, 'Delete account');
      expect(cancel.top, delete.top);
      expect(cancel.height, 52);
      expect(delete.left - cancel.right, 10);
      expect(t.getSize(find.byType(TextField)).height, closeTo(48, 0.5));
      expect(
        t
            .getSize(find.widgetWithText(AccountButton, 'Export my data first'))
            .height,
        48,
      );
    });

    testWidgets('Mac and web: a 480 dialog, 40 buttons at the end', (t) async {
      await open(
        t,
        const DeleteAccountView(owner: 'a', wide: true),
        size: const Size(1280, 800),
        platform: TargetPlatform.macOS,
        browser: true,
      );
      final sheet = t.getRect(
        find
            .descendant(
              of: find.byType(Dialog),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(sheet.width, 480);
      final delete = button(t, 'Delete account');
      expect(delete.height, 40);
      expect(delete.right, closeTo(sheet.right - 24, 0.5));
      expect(t.getSize(find.byType(TextField)).height, closeTo(40, 0.5));
      // The hint sits beside "Export my data first".
      final export = button(t, 'Export my data first');
      final hint = t.getRect(find.textContaining('While you’re signed in'));
      expect(hint.left, greaterThan(export.right));
    });
  });

  testWidgets('removal retry on the web: a 480 card, a 40 button', (t) async {
    await open(
      t,
      const RemovalRetryScreen(),
      size: const Size(1280, 800),
      platform: TargetPlatform.macOS,
      browser: true,
    );
    final finish = button(t, 'Finish removing');
    expect(finish.height, 40);
    final card = t.getRect(
      find
          .ancestor(
            of: find.text('Removal from this browser didn’t finish'),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(card.width, 480);
  });
}
