import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dottoday/app_plan_panel.dart';
import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/inbox/inbox_screen.dart';
import 'package:dottoday/features/timeline/editor/editor_panel.dart';
import 'package:dottoday/features/timeline/month_screen.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/week_screen.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'support/dot_golden.dart';
import 'support/sample_inbox.dart';
import 'support/timeline_fakes.dart';

// Web parity (docs/09 M3e.8, docs/10 §4 "Mac and web are the same layout
// at the same width"): each Mac/web screen at 1280 renders the same pixels
// on Windows and Linux, the other hosts of the web build, and the Mac lays
// it out the same: every task dot in the same place. The Mac's controls
// are its own (CLAUDE.md §11 on this branch; owner, native pass), so its
// pixels may differ. (kIsWeb itself is pinned by `no_platform_layout_test`.)

final _screens = <String, Widget Function()>{
  'today spread': () => const PlanPanelFrame(child: TodayScreen()),
  'week': () => const PlanPanelFrame(child: WeekScreen()),
  'month': () => const MonthScreen(),
  'inbox': () => const InboxScreen(),
  'editor panel': () => const EditorPanelFrame(child: TodayScreen()),
};

/// The screen's pixels, and where each task dot sits (its layout).
Future<(Uint8List, List<Rect>)> _render(
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
  final dots = [
    for (final e in find.byType(TaskDot).evaluate())
      tester.getRect(find.byWidget(e.widget)),
  ];
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data!.buffer.asUint8List();
  });
  return (bytes!, dots);
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
    testWidgets('$name: the web hosts render the same; the Mac lays it '
        'out the same', (tester) async {
      tester.view
        ..physicalSize = const Size(1280, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final (windows, layout) = await _render(
        tester,
        screen,
        TargetPlatform.windows,
      );
      final (linux, _) = await _render(tester, screen, TargetPlatform.linux);
      expect(linux, equals(windows), reason: '$name on Linux');
      final (_, mac) = await _render(tester, screen, TargetPlatform.macOS);
      expect(mac, equals(layout), reason: '$name: the Mac places it alike');
    });
  }
}
