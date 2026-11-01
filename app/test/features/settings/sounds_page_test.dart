import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/sound/sound_player.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'settings_harness.dart';

// Settings › Reminders › Sounds (docs/12 §6): pick and preview, Start and
// Done lists, Sounds in app, the muted banner and the credit link.

final class _Player implements SoundPlayer {
  final played = <String>[];
  bool muted = false;

  @override
  Future<void> play(CatalogueSound sound) async => played.add(sound.id);

  /// How many times [stop] was called.
  int stops = 0;

  @override
  Future<void> stop() async => stops++;

  @override
  Future<bool> deviceMuted() async => muted;
}

Future<(SettingsHarness, _Player)> _pump(
  WidgetTester tester, {
  Settings settings = const Settings(),
  bool muted = false,
}) async {
  final player = _Player()..muted = muted;
  final h = await pumpSettings(
    tester,
    settings: settings,
    location: AppRoutes.settingsPage(SettingsPage.sounds),
    overrides: [soundPlayerProvider.overrideWithValue(player)],
  );
  return (h, player);
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('unset is Dot; a tap picks and plays; None plays nothing', (
    tester,
  ) async {
    final (h, player) = await _pump(tester);
    Finder checkIn(String name) => find.descendant(
      of: find.widgetWithText(ListTile, name),
      matching: find.byType(DotIcon),
    );
    expect(checkIn('Dot'), findsOneWidget, reason: 'checked');
    expect(checkIn('Chime'), findsNothing);
    await _tap(tester, 'Rooster');
    expect((await storedSettings(h)).reminderSound, 'play.rooster');
    expect(player.played, ['play.rooster']);
    await _tap(tester, 'None');
    expect((await storedSettings(h)).reminderSound, soundNoneKey);
    expect(player.played, ['play.rooster'], reason: 'nothing to play');
  });

  testWidgets('Start sound: its own list, Insistent with its caption', (
    tester,
  ) async {
    final (h, player) = await _pump(tester);
    expect(find.text('Dot alarm'), findsOneWidget, reason: 'the default');
    await _tap(tester, 'Start sound');
    expect(
      find.text(
        'Loud and repeating. Use it if quieter sounds don\'t reach you.',
      ),
      findsOneWidget,
    );
    // Only Start sounds: no task sound to pick here (D2).
    expect(find.text('Rooster'), findsOneWidget, reason: 'page behind only');
    await _tap(tester, 'Insistent');
    expect((await storedSettings(h)).startSoundId, insistentStartSoundId);
    expect(player.played, [insistentStartSoundId]);
    expect(player.stops, 0, reason: 'still choosing');
    await _tap(tester, 'Done');
    expect(find.text('Insistent'), findsOneWidget, reason: 'the row value');
    expect(player.stops, 1, reason: 'Done ends the preview');
  });

  testWidgets('Done sound: its own list', (tester) async {
    final (h, player) = await _pump(tester);
    await _tap(tester, 'Done sound');
    await _tap(tester, 'Checked');
    expect((await storedSettings(h)).doneSoundId, 'done.checked');
    expect(player.played, ['done.checked']);
  });

  testWidgets('leaving the page stops the preview (docs/12 §6)', (
    tester,
  ) async {
    final (_, player) = await _pump(tester);
    await _tap(tester, 'Rooster');
    expect(player.stops, 0);
    // The page goes away, as on Back.
    await tester.pumpWidget(const SizedBox.shrink());
    expect(player.stops, 1);
  });

  testWidgets('Sounds in app switches off', (tester) async {
    final (h, _) = await _pump(tester);
    await _tap(tester, 'Sounds in app');
    expect((await storedSettings(h)).inAppSoundsEnabled, isFalse);
  });

  testWidgets('Sound effects: Haptics in app switches off, with the note '
      '(M15.7)', (tester) async {
    final (h, _) = await _pump(tester);
    expect(find.text('SOUND EFFECTS'), findsOneWidget);
    expect(
      find.text(
        "Sounds and haptics may not play, depending on your device's settings.",
      ),
      findsOneWidget,
    );
    await _tap(tester, 'Haptics in app');
    final s = await storedSettings(h);
    expect(s.inAppHapticsEnabled, isFalse);
    expect(s.inAppSoundsEnabled, isTrue, reason: 'its own switch');
  });

  const banner = 'Your device is muted — you may still get vibration';
  testWidgets('muted: the banner says so', (tester) async {
    await _pump(tester, muted: true);
    expect(find.text(banner), findsOneWidget);
  });

  testWidgets('not muted: no banner', (tester) async {
    await _pump(tester);
    expect(find.text(banner), findsNothing);
  });

  testWidgets('the credit line links to the source (docs/12 §1)', (
    tester,
  ) async {
    final (h, _) = await _pump(tester);
    await _tap(tester, 'Sounds from notificationsounds.com (CC BY 4.0).');
    expect(h.links.opened, [Uri.parse('https://notificationsounds.com')]);
  });
}
