import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/profile/settings_difference.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/features/auth/settings_choice_parts.dart';
import 'package:dottoday/features/auth/settings_choice_screen.dart';
import 'package:dottoday/shared/account/account_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../domain/fixtures.dart';
import '../../support/account_screen_fakes.dart';
import 'auth_harness.dart';

// B1 as the E-CR160 boards draw it (ED-494): `SettingsChoice`,
// `AndroidB1`, `TabletB1`, `AndroidTabletB1`, `DesktopB1`.

void main() {
  // The real faces, so side-by-side cards and buttons measure as there.
  setUpAll(loadAppFonts);
  late FakeAccountActions actions;
  setUp(() => actions = FakeAccountActions());

  final account = profileFixture().copyWith(
    tzId: 'Europe/Berlin',
    locale: 'de',
    settings: withCommonWindow(
      const Settings(),
      const TimeWindow(start: '07:00', end: '23:00'),
    ),
  );
  final device = profileFixture().copyWith(
    tzId: 'Asia/Tokyo',
    settings: withCommonWindow(
      const Settings(uiLayout: UiLayout.minimal, theme: ThemePreference.dark),
      const TimeWindow(start: '06:30', end: '22:30'),
    ),
  );
  final gate = SettingsChoiceGate(
    account: account,
    device: device,
    fields: settingsDifferences(account, device),
  );

  Future<void> open(
    WidgetTester t, {
    Size size = const Size(390, 844),
    TargetPlatform platform = TargetPlatform.iOS,
  }) => pumpAccountScreen(
    t,
    SettingsChoiceScreen(gate: gate),
    actions: actions,
    size: size,
    platform: platform,
  );

  Rect button(WidgetTester t, String label) =>
      t.getRect(find.widgetWithText(AccountButton, label));
  List<Rect> cards(WidgetTester t) => [
    for (final e in find.byType(SettingsChoiceCard).evaluate())
      t.getRect(find.byWidget(e.widget)),
  ];

  testWidgets('the four rows the boards draw; no Theme', (t) async {
    await open(t);
    for (final label in ['Time zone', 'Language', 'Your day', 'Layout']) {
      expect(find.text(label), findsNWidgets(2));
    }
    expect(find.text('Theme'), findsNothing);
  });

  testWidgets('iPhone: cards stacked, 52 Continue at the foot', (t) async {
    await open(t);
    final [a, b] = cards(t);
    expect(b.top, greaterThan(a.bottom));
    expect(a.left, 20);
    final cont = button(t, 'Continue');
    expect(cont.height, 52);
    expect(button(t, 'Decide later').top, greaterThan(cont.bottom));
  });

  testWidgets('Android: 48 buttons, 16 from the sides', (t) async {
    await open(t, platform: TargetPlatform.android);
    expect(cards(t).first.left, 16);
    expect(button(t, 'Continue').height, 48);
  });

  testWidgets('iPad: a 680 column, the cards side by side', (t) async {
    await open(t, size: const Size(1180, 820));
    final [a, b] = cards(t);
    expect(a.top, b.top);
    expect(b.left - a.right, 12);
    expect(b.right - a.left, 680);
    final later = button(t, 'Decide later');
    final cont = button(t, 'Continue');
    expect(cont.top, later.top);
    expect(cont.left, greaterThan(later.right));
    expect(cont.right, b.right);
    expect(cont.height, 52);
  });

  testWidgets('Android tablet: 680, side by side, 48 buttons', (t) async {
    await open(
      t,
      size: const Size(1280, 800),
      platform: TargetPlatform.android,
    );
    final [a, b] = cards(t);
    expect(a.top, b.top);
    expect(button(t, 'Continue').height, 48);
  });

  testWidgets('Mac and web: a 580 column, 40 buttons at the end', (t) async {
    await open(t, size: const Size(1280, 800), platform: TargetPlatform.macOS);
    final [a, b] = cards(t);
    expect(a.top, b.top);
    expect(b.right - a.left, 580);
    final cont = button(t, 'Continue');
    expect(cont.height, 40);
    expect(cont.right, b.right);
  });

  testWidgets('200 % text: cards stack and it all scrolls', (t) async {
    t.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await open(t, size: const Size(1280, 800), platform: TargetPlatform.macOS);
    expect(t.takeException(), isNull);
    final [a, b] = cards(t);
    expect(b.top, greaterThan(a.bottom));
  });
}
