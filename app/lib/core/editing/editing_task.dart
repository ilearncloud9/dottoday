import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/deep_link_guard.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'editing_task.g.dart';

/// The task open in the Mac/web editor panel (docs/10 §4 "editing in a
/// right-hand TaskEditor panel, no sheets", M3e.5); null = closed. Held
/// in core so every screen can open a task without importing the editor.
@Riverpod(keepAlive: true)
class EditingTask extends _$EditingTask {
  // Closed at every change of owner (CR-160 I5): the panel never shows
  // the previous owner's task.
  @override
  String? build() {
    ref.watch(ownerEpochProvider);
    return null;
  }

  void open(String id) => state = id;

  void close() => state = null;
}

/// Opens task [id] over the place on screen, through the address
/// (ED-097): `?task=<id>` is added, one Back step, and the app's task link
/// host shows it where this width edits it (the panel at the expanded
/// width, the sheet elsewhere). From a page that can't carry a task (Focus,
/// the Wake Up card), the task opens over its own date (rule T).
///
/// ```dart
/// openTask(context, task.id);
/// ```
void openTask(BuildContext context, String id) {
  final router = GoRouter.of(context);
  final here = router.routerDelegate.currentConfiguration.uri;
  final over = AppRoutes.withTask(here.path, id);
  TaskLinks.openedHere = id;
  router.go(
    allowListedLocation(Uri.parse(over)) == over ? over : AppRoutes.task(id),
  );
}

/// What the task link host needs to know about how a task was opened.
abstract final class TaskLinks {
  /// The task last opened from inside the app: closing it is a Back step
  /// (a link that arrived with the task open is closed by a replace).
  static String? openedHere;
}
