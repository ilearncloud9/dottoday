import 'dart:async';

import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_metrics.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/timeline/review/review_place.dart';
import 'package:dottoday/features/timeline/review/review_presenter.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// `/review`, where the Wind Down notification and sidebar Review land
/// (ED-099; the route itself unchanged, ED-097). In Full at the expanded
/// width it is the Review place. Elsewhere the review is not a page: the
/// address hands over to Today (Now in Minimal at the expanded width)
/// and the review opens there as that layout keeps it.
class ReviewRoute extends ConsumerWidget {
  const ReviewRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = AppLayout.classOf(context) == WidthClass.expanded;
    final minimal = watchSimplified(ref, FeatureId.spread);
    if (wide && !minimal) return const ReviewPlace();
    return _HandOver(home: wide ? AppRoutes.now : AppRoutes.today);
  }
}

/// Goes [home], then opens the review of the review's day over it.
class _HandOver extends ConsumerStatefulWidget {
  const _HandOver({required this.home});

  final String home;

  @override
  ConsumerState<_HandOver> createState() => _HandOverState();
}

class _HandOverState extends ConsumerState<_HandOver> {
  @override
  void initState() {
    super.initState();
    unawaited(_handOver());
  }

  Future<void> _handOver() async {
    final router = GoRouter.of(context);
    final day = await ref.read(reviewDateProvider.future);
    if (!mounted) return;
    router.go(widget.home);
    // The next frame has the home screen; the root navigator's context
    // outlives this page.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final root = router.routerDelegate.navigatorKey.currentContext;
      if (root == null || !root.mounted) return;
      unawaited(openReview(root, day: day));
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
