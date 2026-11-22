import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/workspace_routes.dart';
import 'package:dottoday/core/theme/dot_metrics.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:dottoday/features/timeline/review/review_panel.dart';
import 'package:dottoday/features/timeline/review/review_state.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Opens the one review (ED-099 Q1, ED-297) for [day] where this layout
/// keeps it; [page] = week opens Week in review straight away. Every
/// entry calls this: Day ▾ › Review the day / Week in review, the menu
/// bar, ⌘K, the Wind Down prompt and notification, and the week's hint.
///
/// - Minimal, expanded: the Day column on Now (no Week in review there).
/// - Full, expanded, touch (iPad, Android tablet) beside a day: a pane.
/// - Full, expanded otherwise: the Workspace's Review place.
/// - Compact and medium: the sheet (a dialog from medium), Week in
///   review pushed inside it.
Future<void> openReview(
  BuildContext context, {
  required DateTime day,
  ReviewPage page = ReviewPage.day,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  if (AppLayout.classOf(context) != WidthClass.expanded) {
    return showReviewSheet(context, day: day, page: page);
  }
  final policy = container.read(layoutPolicyProvider);
  final beside = container.read(reviewBesideProvider.notifier);
  final router = GoRouter.of(context);
  // The address, not what is mounted: the shell keeps other tabs alive.
  final path = router.routerDelegate.currentConfiguration.uri.path;
  if (policy.visibility(FeatureId.spread) == FeatureVisibility.simplified) {
    beside.show(ReviewOpen(day, ReviewPage.day));
    if (path != AppRoutes.now) router.go(AppRoutes.now);
    return;
  }
  if (readTouchContent(context, container) && workspaceInspects(path)) {
    beside.show(ReviewOpen(day, page));
    return;
  }
  container.read(reviewPlaceDayProvider.notifier).show(day);
  router.go(AppRoutes.review);
}

/// The review as a sheet on phones and a dialog from medium width
/// (E-Phones-2, E-R2-14 medium): Day review, with Week in review pushed
/// in the same sheet.
Future<void> showReviewSheet(
  BuildContext context, {
  required DateTime day,
  ReviewPage page = ReviewPage.day,
}) => showAppSheet<void>(
  context: context,
  scrolls: false,
  builder: (sheet) => ReviewPanel(
    day: day,
    page: page,
    onClose: () => Navigator.of(sheet).pop(),
  ),
);
