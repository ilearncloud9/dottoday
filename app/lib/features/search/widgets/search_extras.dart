import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/search/recent_searches.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "RECENT" with the last searches as chips (`A-ios-search`).
class RecentSearchesRow extends ConsumerWidget {
  const RecentSearchesRow({required this.onPick, super.key});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final recent = ref.watch(recentSearchesProvider).value ?? const [];
    if (recent.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: DotSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.s,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.searchRecent.toUpperCase(),
              style: t.styles.caption,
            ),
          ),
          Wrap(
            spacing: DotSpace.s,
            runSpacing: DotSpace.s,
            children: [
              for (final q in recent)
                Semantics(
                  button: true,
                  label: l10n.searchRecentLabel(q),
                  excludeSemantics: true,
                  child: ActionChip(
                    avatar: DotIcon(
                      DotGlyphs.clock,
                      color: t.colors.muted,
                      size: DotSize.rowIcon,
                    ),
                    label: Text(q),
                    shape: dotChipShape(context),
                    onPressed: () => onPick(q),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Nothing typed (§5.3 "Search empty").
class SearchEmpty extends StatelessWidget {
  const SearchEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: DotSpace.xl),
      child: Text(
        context.l10n.searchEmpty,
        style: t.styles.body.copyWith(color: t.colors.muted),
      ),
    );
  }
}

/// No matches (§5.3 "no results"), with a way back to All when a chip
/// narrowed them.
class NoResults extends StatelessWidget {
  const NoResults({
    required this.query,
    required this.filtered,
    required this.onShowAll,
    super.key,
  });

  final String query;
  final bool filtered;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(top: DotSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.xs,
          children: [
            Text(l10n.searchNoResults(query), style: t.styles.rowTitle),
            Text(
              l10n.searchNoResultsHint,
              style: t.styles.body.copyWith(color: t.colors.muted),
            ),
            if (filtered)
              TextButton(onPressed: onShowAll, child: Text(l10n.searchShowAll)),
          ],
        ),
      ),
    );
  }
}
