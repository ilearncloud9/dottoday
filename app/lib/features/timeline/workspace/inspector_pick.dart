import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/editing/inspected_task.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opening a task in the Workspace's Day, 3 days or Week (ED-170 C1,
/// owner 2026-11-19): the first click picks it into the inspector at once;
/// opening the task already picked (the double-click's second click, ↩
/// again, a screen reader's second activation) opens the full editor.
/// Keyed on what is picked, not on timing, so the keyboard and screen
/// readers reach the editor the same way, and the first click never waits.
abstract final class InspectorPick {
  /// Picks [id], or opens it in the editor when it is already picked.
  static void click(BuildContext context, WidgetRef ref, String id) {
    if (ref.read(inspectedTaskProvider) == id) {
      return ref.read(editingTaskProvider.notifier).open(id);
    }
    openTask(context, id);
  }
}
