import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inspected_task.g.dart';

/// The task picked on the Workspace's Day, 3 days or Week (ED-170 C1,
/// ED-391): the 248 inspector shows it; null = nothing picked, and the
/// inspector is away. The address carries it as `?task=` (E-FullA-v2),
/// so the task link host sets and clears it. Held in core so the grid,
/// the host and the inspector meet without importing each other.
@Riverpod(keepAlive: true)
class InspectedTask extends _$InspectedTask {
  // Cleared at every change of owner (CR-160 I5).
  @override
  String? build() {
    ref.watch(ownerEpochProvider);
    return null;
  }

  void show(String id) => state = id;

  void close() => state = null;
}

/// Whether an inspector frame is on screen (the Workspace's Day, 3 days
/// or Week): only then does `?task=` pick into it; elsewhere it opens the
/// editor as before. Counted by the frames themselves.
abstract final class InspectorFrames {
  static int _live = 0;

  /// Whether at least one frame is mounted.
  static bool get any => _live > 0;

  static void mounted() => _live++;

  static void unmounted() => _live--;
}

/// ⌥⌘I, View › Show Inspector and the toolbar's last button (ED-218):
/// whether the person put the inspector away. Kept for the app's life,
/// not saved.
@Riverpod(keepAlive: true)
class InspectorHidden extends _$InspectorHidden {
  @override
  bool build() => false;

  void toggle() => state = !state;
}
