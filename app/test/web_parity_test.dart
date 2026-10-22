import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/inbox/inbox_screen.dart';
import 'package:dottoday/features/inbox/inbox_sidebar.dart';
import 'package:dottoday/features/timeline/editor/editor_panel.dart';
import 'package:dottoday/features/timeline/month_screen.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/week_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'support/dot_golden.dart';
import 'support/sample_inbox.dart';
import 'support/timeline_fakes.dart';

// Web parity (docs/09 M3e.8, docs/10 §4 "Mac and web are the same layout
// at the same width"): each Mac/web screen at 1280 renders the same
// pixels with the Mac theme platform as with Windows and Linux, the
// other hosts of the web build. Layout reads only the width class; the
// idiom is Material for all three. (kIsWeb itself is pinned by
// `no_platform_layout_test`.)

final _screens = <String, Widget Function()>{
  'today spread': () => const InboxSidebarFrame(child: TodayScreen()),
  'week': () => const InboxSidebarFrame(child: WeekScreen()),
  'month': () => const MonthScreen(),
  'inbox': () => const InboxScreen(),
  'editor panel': () => const EditorPanelFrame(child: TodayScreen()),
};

Future<Uint8List> _render(
  WidgetTester tester,
  Widget Function() screen,
  TargetPlatform platform,
) async {
  final rows = [...demoWeekRows(), ...sampleInbox()];
  await tester.pumpWidget(
    ProviderScope(
      key: ValueKey(platform),
      overrides: [
        ...timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 7, 22),
          occurrences: FakeOccurrenceRepository(rows),
          profile: testProfile(
            settings: const Settings(use24h: false, firstDayOfWeek: 7),
          ),
        ),
        editingTaskProvider.overrideWith(() => _Editing(rows.first.id)),
      ],
      child: goldenApp(screen(), platform: platform),
    ),
  );
  await tester.pumpAndSettle();
  // The caret is the host's own (rounded on Apple, square elsewhere; web
  // on a Mac draws the Mac one): text-input behaviour, not layout.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(GoldenFrame.boundaryKey),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data!.buffer.asUint8List();
  });
  return bytes!;
}

final class _Editing extends EditingTask {
  _Editing(this.id);

  final String id;

  @override
  String? build() => id;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final MapEntry(key: name, value: screen) in _screens.entries) {
    testWidgets('$name: Mac, Windows and Linux render the same', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1280, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final mac = await _render(tester, screen, TargetPlatform.macOS);
      for (final other in [TargetPlatform.windows, TargetPlatform.linux]) {
        final pixels = await _render(tester, screen, other);
        expect(pixels, equals(mac), reason: '$name on $other');
      }
    });
  }
}
