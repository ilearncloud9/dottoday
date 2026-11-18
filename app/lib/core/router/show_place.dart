import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Shows the day, week or month the user stepped to at [location], so the
/// address always shows what is on screen (ED-097 A′). The web adds a
/// history entry, one Back step per date; the apps change the address in
/// place, so Back keeps its meaning there (owner, M18.7 part 3). An open
/// task stays open: its `?task=` is kept.
///
/// ```dart
/// showPlace(GoRouter.of(context), AppRoutes.day(next)); // '/day/2026-11-19'
/// ```
void showPlace(GoRouter router, String location) {
  final here = router.routerDelegate.currentConfiguration.uri;
  final task = AppRoutes.taskOf(here);
  final target = task == null ? location : AppRoutes.withTask(location, task);
  if (target == here.toString()) return;
  // A page pushed over the tabs (Month) keeps what is under it.
  if (!kIsWeb && router.canPop()) {
    unawaited(router.replace<void>(target));
    return;
  }
  router.go(target);
}
