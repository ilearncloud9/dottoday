import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/search/recent_searches.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "RECENT" with the last searches: a list on phones (E-R2-13), chips
/// from medium width (E-R2-30).
class RecentSearchesRow extends ConsumerWidget {
  const RecentSearchesRow({required this.onPick, super.key});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final recent = ref.watch(recentSearchesProvider).value ?? const [];
    if (recent.isEmpty) return const SizedBox.shrink();
    final list = AppLayout.classOf(context) == WidthClass.compact;
    return Padding(
      padding: const EdgeInsets.only(top: DotSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.s,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.searchRecent.toUpperCase(),
              style: t.styles.caption,
            ),
          ),
          if (list)
            for (final (i, q) in recent.indexed) ...[
              if (i > 0) Divider(height: 1, color: t.colors.threadAhead),
              _RecentRow(query: q, onTap: () => onPick(q)),
            ]
          else
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
                        color: t.colors.secondary,
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

/// A recent search as a row: the magnifier and what was typed.
class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.query, required this.onTap});

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      button: true,
      label: context.l10n.searchRecentLabel(query),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Row(
            spacing: DotSpace.m,
            children: [
              DotIcon(
                DotGlyphs.search,
                color: t.colors.secondary,
                size: DotSize.rowIcon,
              ),
              Expanded(child: Text(query, style: t.styles.body)),
            ],
          ),
        ),
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
        style: t.styles.body.copyWith(color: t.colors.secondary),
      ),
    );
  }
}

/// No matches (E-R2-30): "No matches for “…”", the hint, and Show all
/// when a chip narrowed them.
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
          spacing: DotSpace.xs,
          children: [
            Text(
              l10n.searchNoResults(query),
              style: t.styles.rowTitle,
              textAlign: TextAlign.center,
            ),
            Text(
              l10n.searchNoResultsHint,
              style: t.styles.body.copyWith(color: t.colors.secondary),
              textAlign: TextAlign.center,
            ),
            if (filtered) ...[
              const SizedBox(height: DotSpace.s),
              OutlinedButton(
                onPressed: onShowAll,
                style: OutlinedButton.styleFrom(foregroundColor: t.colors.ink),
                child: Text(l10n.searchShowAll),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
