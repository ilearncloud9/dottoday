import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'focus_task.g.dart';

/// The task in Focus on Mac/web: a centred view in the content area with
/// the rail kept (docs/09 M10.5, docs/10 §4); null = none. Phones push
/// `/focus/:id` full screen instead. Held in core, like `EditingTask`, so
/// any screen can open Focus without importing it.
@Riverpod(keepAlive: true)
class FocusTask extends _$FocusTask {
  @override
  String? build() => null;

  void open(String id) => state = id;

  void close() => state = null;
}

/// A surface asked for Focus on a dot (Start focus from a control, a
/// tile or Siri, docs/09 M10.5); the app root opens it. Each request is
/// new, even for the same dot.
@Riverpod(keepAlive: true)
class FocusRequest extends _$FocusRequest {
  @override
  ({String id, int seq})? build() => null;

  void request(String id) => state = (id: id, seq: (state?.seq ?? 0) + 1);
}

/// Opens Focus for task [id] where this width shows it (11 A3): the
/// content area at the expanded width, else the full-screen route.
///
/// ```dart
/// openFocus(context, liveTask.id); // one tap on the live dot
/// ```
void openFocus(BuildContext context, String id) {
  final width = MediaQuery.sizeOf(context).width;
  if (WidthClass.of(width) == WidthClass.expanded) {
    ProviderScope.containerOf(
      context,
    ).read(focusTaskProvider.notifier).open(id);
    return;
  }
  final router = GoRouter.of(context);
  // Already there (a tile's link and its queued Start focus): once.
  if (router.state.uri.path == AppRoutes.focus(id)) return;
  unawaited(router.push(AppRoutes.focus(id)));
}
