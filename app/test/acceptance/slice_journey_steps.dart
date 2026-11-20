import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_idiom.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../domain/fixtures.dart';
import '../support/timeline_fakes.dart';
import 'slice_world.dart';

/// The first slice's journey, one step at a time (playbook step 11;
/// docs/09 M19.7): Today → Add → Edit/reschedule → Complete → Change
/// day → Reopen, each the way its platform does it.

/// A target the journey runs on: its platform, window and whether it is
/// the web's chrome (`debugWebChromeOverride`).
typedef SliceTarget = ({
  String name,
  TargetPlatform platform,
  Size size,
  bool web,
});

const sliceTargets = <SliceTarget>[
  (
    name: 'iPhone',
    platform: TargetPlatform.iOS,
    size: Size(390, 844),
    web: false,
  ),
  (
    name: 'Android phone',
    platform: TargetPlatform.android,
    size: Size(412, 915),
    web: false,
  ),
  (
    name: 'iPad landscape',
    platform: TargetPlatform.iOS,
    size: Size(1180, 820),
    web: false,
  ),
  (
    name: 'iPad portrait',
    platform: TargetPlatform.iOS,
    size: Size(820, 1180),
    web: false,
  ),
  (
    name: 'Android tablet landscape',
    platform: TargetPlatform.android,
    size: Size(1280, 800),
    web: false,
  ),
  (
    name: 'Android tablet portrait',
    platform: TargetPlatform.android,
    size: Size(800, 1280),
    web: false,
  ),
  (
    name: 'Mac',
    platform: TargetPlatform.macOS,
    size: Size(1280, 800),
    web: false,
  ),
  (
    name: 'desktop web',
    platform: TargetPlatform.linux,
    size: Size(1280, 800),
    web: true,
  ),
  (
    name: 'mobile web',
    platform: TargetPlatform.android,
    size: Size(390, 844),
    web: true,
  ),
]; // l10n-ignore: test target names

/// The live task, 10:00–12:00 in Berlin; now is 10:42.
const sliceDeepId = '019a4b00-0000-7000-8000-00000000d001';

/// The day the journey starts on (Berlin): Deep work under way, Lunch.
FakeOccurrenceRepository sliceRepo() => FakeOccurrenceRepository([
  occurrenceFixture().copyWith(
    id: sliceDeepId,
    title: 'Deep work: roadmap', // l10n-ignore: test data
    colorKey: 'indigo',
    iconKey: 'focus_block',
    startUtc: sliceAt(9),
    tzId: 'Europe/Berlin',
    durationMin: 120,
    status: OccurrenceStatus.planned,
  ),
  occurrenceFixture().copyWith(
    id: '019a4b00-0000-7000-8000-00000000d002',
    title: 'Lunch', // l10n-ignore: test data
    colorKey: 'rose',
    iconKey: 'meal',
    startUtc: sliceAt(11, 30),
    tzId: 'Europe/Berlin',
    durationMin: 45,
    status: OccurrenceStatus.planned,
  ),
]);

/// [f] inside the topmost route or overlay entry that has one.
Finder top(Finder f) => f.hitTestable().last;

bool get _meta => AppShortcuts.usesMeta(defaultTargetPlatform);

/// ⌘ (Apple) or Ctrl with Shift and [key]: the keyboard path on wide
/// screens (ED-095).
Future<void> chord(WidgetTester tester, LogicalKeyboardKey key) async {
  final mod = _meta
      ? LogicalKeyboardKey.metaLeft
      : LogicalKeyboardKey.controlLeft;
  await tester.sendKeyDownEvent(mod);
  await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(mod);
  await tester.pumpAndSettle();
}

/// A command by its key: ⇧⌘[key] (Ctrl elsewhere) in the apps; on the
/// web its single key, [web] or [key] alone (ED-095: m, g).
Future<void> command(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  LogicalKeyboardKey? web,
}) async {
  if (!(debugWebChromeOverride ?? kIsWeb)) return chord(tester, key);
  await tester.sendKeyEvent(web ?? key);
  await tester.pumpAndSettle();
}

/// Opens the task [id] by its link (`?task=`, ED-097), as a tap on its
/// row, a notification or a widget does.
Future<void> openTask(WidgetTester tester, GoRouter router, String id) async {
  final here = router.routerDelegate.currentConfiguration.uri.path;
  router.go(AppRoutes.withTask(here, id));
  await tester.pumpAndSettle();
}

/// The row [title] in [repo].
Occurrence row(FakeOccurrenceRepository repo, String title) =>
    repo.rows.singleWhere((o) => o.title == title);

/// Shows the toast [text] (`findRichText` for the bold title).
void expectToast(String text) =>
    expect(find.textContaining(text, findRichText: true), findsWidgets);
