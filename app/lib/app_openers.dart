import 'dart:async';

import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_sheet.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/layout/layout_switch.dart' as layout;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The commands of the keyboard scheme (ED-095) that open a feature's
/// sheet or change a setting, on the root overlay, so the app root wires
/// them without the features importing each other.
final class AppOpeners {
  AppOpeners(this.router);

  final GoRouter router;

  BuildContext? get _context =>
      router.routerDelegate.navigatorKey.currentState?.overlay?.context;

  /// ⇧⌘N: New Brain Dump… for today.
  void brainDump() {
    final context = _context;
    if (context == null) return;
    final container = ProviderScope.containerOf(context);
    unawaited(() async {
      final today = await container.read(todayDateProvider.future);
      if (!context.mounted) return;
      await showBrainDump(context, today);
    }());
  }

  /// ⇧⌘V: Paste as Tasks, Add opened with the clipboard's text; a list
  /// shows Add's "Add N tasks" choice (R-07).
  void pasteAsTasks() {
    unawaited(() async {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final context = _context;
      if (context == null || !context.mounted) return;
      await showAddFlow(context, text: data?.text?.trim() ?? '');
    }());
  }

  /// ⌘T: back to the current day or period where the screen has one
  /// (Today to today, Week to this week, Month to this month: built
  /// behaviour, ED-095 "nothing built is reassigned"); anywhere else, to
  /// Today, which opens on today.
  void today(VoidCallback goToday) {
    const intent = ShowTodayIntent();
    final focus = primaryFocus?.context;
    final action = focus == null
        ? null
        : Actions.maybeFind<ShowTodayIntent>(focus, intent: intent);
    if (focus != null && action != null && action.isEnabled(intent)) {
      Actions.invoke(focus, intent);
      return;
    }
    goToday();
  }

  /// ⇧⌘L: Show Less / Show Everything (docs/14 §5).
  void toggleLayout() {
    final context = _context;
    if (context != null) layout.toggleLayout(context);
  }
}
