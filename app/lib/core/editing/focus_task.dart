import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'focus_task.g.dart';

/// The task in Focus (docs/09 M10.5), set by the Focus screen while it is
/// up; null = none. Focus is the `/focus/:id` route at every width (the
/// whole window on expanded ones, ED-285). Held in core, like
/// `EditingTask`, so any screen can tell Focus is up without importing it;
/// an owner switch clears it, which closes the screen.
@Riverpod(keepAlive: true)
class FocusTask extends _$FocusTask {
  // Ends at every change of owner (CR-160 I5).
  @override
  String? build() {
    ref.watch(ownerEpochProvider);
    return null;
  }

  void open(String id) => state = id;

  void close() => state = null;
}

/// A surface asked for Focus on a dot (Start focus from a control, a
/// tile or Siri, docs/09 M10.5); the app root opens it. Each request is
/// new, even for the same dot.
@Riverpod(keepAlive: true)
class FocusRequest extends _$FocusRequest {
  // A request not yet opened is the previous owner's after a switch
  // (CR-160 I5): dropped.
  @override
  ({String id, int seq})? build() {
    ref.watch(ownerEpochProvider);
    return null;
  }

  void request(String id) => state = (id: id, seq: (state?.seq ?? 0) + 1);
}

/// Opens Focus for task [id]: the full-screen route at every width, over
/// the shell, whose tabs keep their state (11 A3, ED-285).
///
/// ```dart
/// openFocus(context, liveTask.id); // one tap on the live dot
/// ```
void openFocus(BuildContext context, String id) {
  final router = GoRouter.of(context);
  // Already there (a tile's link and its queued Start focus): once.
  if (router.state.uri.path == AppRoutes.focus(id)) return;
  unawaited(router.push(AppRoutes.focus(id)));
}
