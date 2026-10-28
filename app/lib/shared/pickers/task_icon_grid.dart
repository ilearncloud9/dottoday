import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/search/search_results.dart' show fold;
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:dottoday/shared/pickers/task_icon_choice.dart';
import 'package:flutter/material.dart';

/// Whether [icon] matches a picker search: its localized name, its
/// category's title or its key's words (English, so "gym" finds Dumbbell's
/// `gym` key in every language). Case- and accent-insensitive.
///
/// ```dart
/// iconMatches(l10n, TaskIcon.washingMachine, 'wash'); // true
/// ```
bool iconMatches(AppLocalizations l10n, TaskIcon icon, String query) {
  final q = fold(query.trim());
  if (q.isEmpty) return true;
  return fold(taskIconName(l10n, icon)).contains(q) ||
      fold(taskIconCategoryName(l10n, icon.category)).contains(q) ||
      icon.key.replaceAll('_', ' ').contains(q); // l10n-ignore: key words
}

/// The icon library in its categories (docs/10 §3 "full picker"): a section
/// title per category, then its icons; lazily built, so 600 icons cost one
/// screenful. Filters by [query]; says so when nothing matches.
class TaskIconGrid extends StatelessWidget {
  const TaskIconGrid({
    required this.query,
    required this.onPick,
    this.colour,
    this.selected,
    super.key,
  });

  final String query;
  final ValueChanged<TaskIcon> onPick;
  final TaskColor? colour;
  final TaskIcon? selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sections = [
      for (final c in TaskIconCategory.values)
        (
          c,
          [
            for (final i in TaskIcon.picker)
              if (i.category == c && iconMatches(l10n, i, query)) i,
          ],
        ),
    ].where((s) => s.$2.isNotEmpty).toList();
    if (sections.isEmpty) return _NoMatch(query: query.trim());
    return CustomScrollView(
      slivers: [
        for (final (category, icons) in sections) ...[
          SliverToBoxAdapter(child: _SectionTitle(category: category)),
          SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: DotTouch.android + DotSpace.s,
            ),
            itemCount: icons.length,
            itemBuilder: (_, n) => Center(
              child: TaskIconChoice(
                icon: icons[n],
                colour: colour,
                selected: icons[n] == selected,
                onTap: () => onPick(icons[n]),
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: DotSpace.xl)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.category});

  final TaskIconCategory category;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: DotSpace.l,
        bottom: DotSpace.xs,
      ),
      child: Semantics(
        header: true,
        child: Text(
          taskIconCategoryName(context.l10n, category).toUpperCase(),
          style: t.styles.caption,
        ),
      ),
    );
  }
}

class _NoMatch extends StatelessWidget {
  const _NoMatch({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(DotSpace.xl),
      child: Semantics(
        liveRegion: true,
        child: Text(
          context.l10n.iconSearchEmpty(query),
          textAlign: TextAlign.center,
          style: t.styles.rowMeta,
        ),
      ),
    );
  }
}
