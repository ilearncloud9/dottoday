import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/search/recent_searches.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/search/search_results.dart';
import 'package:dottoday/features/search/state/search_state.dart';
import 'package:dottoday/features/search/widgets/search_extras.dart';
import 'package:dottoday/features/search/widgets/search_field.dart';
import 'package:dottoday/features/search/widgets/search_filters.dart';
import 'package:dottoday/features/search/widgets/search_results.dart';
import 'package:dottoday/shared/dot/count_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Search S1 (docs/10 §5.2, `A-ios-search`, `A-android-search`): field,
/// filter chips, live results grouped by day with the match highlighted,
/// recent searches; done tasks included (R-11).
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  static const _key = ValueKey('route:search');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(searchInputStateProvider);
    final view = ref.watch(searchViewProvider);
    final query = input.text.trim();
    void remember() =>
        unawaited(ref.read(recentSearchesProvider.notifier).remember(query));
    return Scaffold(
      key: _key,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
            child: CustomScrollView(
              slivers: [
                _top(ref, input, view, remember),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    DotSpace.page,
                    0,
                    DotSpace.page,
                    DotSpace.fabClearance,
                  ),
                  sliver: SliverMainAxisGroup(
                    slivers: _results(context, ref, input, view, remember),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header, field and chips.
  Widget _top(
    WidgetRef ref,
    SearchInput input,
    SearchView? view,
    VoidCallback remember,
  ) {
    final notifier = ref.read(searchInputStateProvider.notifier);
    final query = input.text.trim();
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        DotSpace.l,
        DotSpace.page,
        0,
      ),
      sliver: SliverList.list(
        children: [
          _Header(count: query.isEmpty ? null : view?.count),
          const SizedBox(height: DotSpace.l),
          SearchField(
            text: input.text,
            onChanged: notifier.type,
            onSubmitted: (_) => remember(),
          ),
          const SizedBox(height: DotSpace.m),
          SearchFilters(picked: input.filter, onPick: notifier.pick),
        ],
      ),
    );
  }

  /// Results (or no results), then recent searches, then the empty hint.
  List<Widget> _results(
    BuildContext context,
    WidgetRef ref,
    SearchInput input,
    SearchView? view,
    VoidCallback remember,
  ) {
    final notifier = ref.read(searchInputStateProvider.notifier);
    final query = input.text.trim();
    return [
      if (query.isNotEmpty && view != null)
        if (view.count == 0)
          SliverToBoxAdapter(
            child: NoResults(
              query: query,
              filtered: input.filter is! AnyResult,
              onShowAll: () => notifier.pick(const AnyResult()),
            ),
          )
        else
          ...searchResultSlivers(
            context,
            view: view,
            query: query,
            onOpen: (o) => _open(context, o, remember),
            onSchedule: (o) => _schedule(context, o, remember),
          ),
      SliverToBoxAdapter(child: RecentSearchesRow(onPick: notifier.type)),
      if (query.isEmpty) const SliverToBoxAdapter(child: SearchEmpty()),
    ];
  }

  void _open(BuildContext context, Occurrence o, VoidCallback remember) {
    remember();
    unawaited(context.push(AppRoutes.task(o.id)));
  }

  void _schedule(BuildContext context, Occurrence o, VoidCallback remember) {
    remember();
    Actions.maybeInvoke(context, ScheduleTaskIntent(o.id));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  /// Results shown; null hides the ring (nothing searched yet).
  final int? count;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(l10n.navSearch, style: t.styles.pageTitle),
              ),
              Text(
                l10n.searchSubtitle,
                style: t.styles.body.copyWith(color: t.colors.muted),
              ),
            ],
          ),
        ),
        if (count case final n?)
          CountRing(count: n, label: l10n.searchRingLabel(n)),
      ],
    );
  }
}
