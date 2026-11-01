import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Today's Wind Down review on its own page (docs/15 W6, owner
/// 2026-10-31): where the Wind Down notification's tap lands. It holds the
/// same `DayReviewBody` as the card on Today.
class DayReviewScreen extends ConsumerWidget {
  const DayReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final today = ref.watch(todayDateProvider).value;
    void close() =>
        context.canPop() ? context.pop() : context.go(AppRoutes.today);
    return Scaffold(
      backgroundColor: t.colors.surface,
      appBar: AppBar(
        title: Text(context.l10n.reviewTitle),
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: close,
          icon: DotIcon(DotGlyphs.close, color: t.colors.text),
        ),
      ),
      body: today == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DotSpace.l),
              child: DayReviewBody(day: today, onDone: close),
            ),
    );
  }
}
