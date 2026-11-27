import 'package:dottoday/features/auth/signed_out_screen.dart';
import 'package:dottoday/shared/account/account_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/account_screen_fakes.dart';
import 'auth_harness.dart';

// A3 as the E-CR160 boards draw it (ED-493): `SignedOut`, `AndroidA3`,
// `TabletA3`, `AndroidTabletA3`, `DesktopA3`.

void main() {
  // The real faces, so the Mac's two buttons measure as they do there.
  setUpAll(loadAppFonts);
  late FakeAccountActions actions;
  setUp(() => actions = FakeAccountActions());

  Future<void> open(
    WidgetTester t, {
    Size size = const Size(390, 844),
    TargetPlatform platform = TargetPlatform.iOS,
  }) => pumpAccountScreen(
    t,
    const SignedOutScreen(),
    actions: actions,
    size: size,
    platform: platform,
  );

  Rect button(WidgetTester t, String label) =>
      t.getRect(find.widgetWithText(AccountButton, label));
  Rect text(WidgetTester t, String label) => t.getRect(find.text(label));
  const signIn = 'Sign in';
  const without = 'Use without an account';
  const title = 'You’re signed out';
  const note =
      'Opens this device’s plan without an account. Anyone who uses this '
      'device without an account can see it.';
  String body(WidgetTester t) => t
      .widgetList<Text>(find.byType(Text))
      .map((w) => w.data ?? '')
      .firstWhere((s) => s.startsWith('Your tasks stay'));

  testWidgets('iPhone: 52 pills at the foot, 28 from the sides', (t) async {
    await open(t);
    final a = button(t, signIn);
    expect(a.height, 52);
    expect(a.left, 28);
    expect(a.right, 390 - 28);
    expect(button(t, without).top - a.bottom, 10);
    expect(text(t, note).bottom, closeTo(844 - 44, 1));
    // The words sit in the middle of the space above the buttons.
    expect(text(t, title).left, 28);
  });

  testWidgets('Android: 48 buttons, 8 apart, 24 from the sides', (t) async {
    await open(t, platform: TargetPlatform.android);
    final a = button(t, signIn);
    expect(a.height, 48);
    expect(a.left, 24);
    expect(button(t, without).top - a.bottom, 8);
    expect(text(t, note).bottom, closeTo(844 - 40, 1));
  });

  testWidgets('iPad: a centred 440 column, buttons under the words', (t) async {
    await open(t, size: const Size(1180, 820));
    final a = button(t, signIn);
    expect(a.width, 440);
    expect(a.center.dx, 590);
    expect(a.height, 52);
    final words = t.getRect(find.text(body(t)));
    expect(a.top - words.bottom, 28);
  });

  testWidgets('Android tablet: 440 column, 48 buttons', (t) async {
    await open(
      t,
      size: const Size(1280, 800),
      platform: TargetPlatform.android,
    );
    final a = button(t, signIn);
    expect(a.width, 440);
    expect(a.center.dx, 640);
    expect(a.height, 48);
  });

  testWidgets('Mac and web: a 400 column, the buttons side by side', (t) async {
    await open(t, size: const Size(1280, 800), platform: TargetPlatform.macOS);
    final a = button(t, signIn);
    final b = button(t, without);
    expect(a.height, 40);
    expect(b.top, a.top);
    expect(b.left - a.right, 10);
    expect(a.left, (1280 - 400) / 2);
    expect(text(t, title).left, a.left);
    expect(text(t, note).top, greaterThan(a.bottom));
  });

  testWidgets('200 % text: it scrolls, nothing overflows', (t) async {
    t.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await open(t, size: const Size(320, 568));
    expect(t.takeException(), isNull);
    await t.drag(find.byType(Scrollable), const Offset(0, -3000));
    await t.pumpAndSettle();
    final rect = text(t, note);
    expect(rect.top, greaterThan(0));
    expect(rect.bottom, lessThanOrEqualTo(568));
    expect(button(t, without).top, greaterThan(text(t, body(t)).bottom));
  });
}
