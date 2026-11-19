import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:dottoday/shared/pickers/look/look_parts.dart';
import 'package:dottoday/shared/pickers/task_icon_grid.dart' show iconMatches;
import 'package:flutter/material.dart';

/// One line of the library: a section title, or up to five icons.
typedef LibraryLine = ({String? title, List<TaskIcon> icons});

/// Height of a section title line, and of a line of icons (56 + 12).
const double libraryTitleExtent = DotSpace.xxl + DotSpace.m;
const double libraryRowExtent = DotLook.icon + DotSpace.m;

/// The library as lines (E-Phones "All icons"): Recently used when there
/// is no [query], then each category's title and its icons in rows of
/// five. Fixed heights, so a category chip can jump to its section.
List<LibraryLine> libraryLines(
  AppLocalizations l10n, {
  required String query,
  required List<TaskIcon> recent,
}) {
  final lines = <LibraryLine>[];
  void section(String title, List<TaskIcon> icons) {
    if (icons.isEmpty) return;
    lines.add((title: title, icons: const []));
    for (var i = 0; i < icons.length; i += DotLook.columns) {
      final end = (i + DotLook.columns).clamp(0, icons.length);
      lines.add((title: null, icons: icons.sublist(i, end)));
    }
  }

  if (query.trim().isEmpty) section(l10n.lookRecentlyUsed, recent);
  for (final c in TaskIconCategory.values) {
    section(taskIconCategoryName(l10n, c), [
      for (final i in TaskIcon.picker)
        if (i.category == c && iconMatches(l10n, i, query)) i,
    ]);
  }
  return lines;
}

/// Where [title]'s section starts in [lines], or null.
double? libraryOffsetOf(List<LibraryLine> lines, String title) {
  var y = 0.0;
  for (final l in lines) {
    if (l.title == title) return y;
    y += l.title == null ? libraryRowExtent : libraryTitleExtent;
  }
  return null;
}

/// The scrolling library under the pinned palette.
class LookLibrary extends StatelessWidget {
  const LookLibrary({
    required this.lines,
    required this.colour,
    required this.icon,
    required this.onIcon,
    required this.controller,
    required this.query,
    super.key,
  });

  final List<LibraryLine> lines;
  final TaskColor colour;
  final TaskIcon icon;
  final ValueChanged<TaskIcon> onIcon;
  final ScrollController controller;
  final String query;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    if (lines.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(DotSpace.l),
        child: Text(
          context.l10n.iconSearchEmpty(query.trim()),
          textAlign: TextAlign.center,
          style: t.styles.body.copyWith(color: t.colors.muted),
        ),
      );
    }
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            DotSpace.l,
            0,
            DotSpace.l,
            DotSpace.l + MediaQuery.paddingOf(context).bottom,
          ),
          sliver: SliverVariedExtentList.builder(
            itemCount: lines.length,
            itemExtentBuilder: (i, _) => i >= lines.length
                ? null
                : lines[i].title == null
                ? libraryRowExtent
                : libraryTitleExtent,
            itemBuilder: (context, i) => _line(t, lines[i]),
          ),
        ),
      ],
    );
  }

  Widget _line(DotTheme t, LibraryLine line) {
    final title = line.title;
    if (title != null) {
      return Align(
        alignment: AlignmentDirectional.bottomStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: DotSpace.xs,
            bottom: DotSpace.s,
          ),
          child: Semantics(
            header: true,
            child: Text(title, style: t.styles.cardTitle),
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var k = 0; k < DotLook.columns; k++)
            if (k < line.icons.length)
              LookIconCircle(
                icon: line.icons[k],
                colour: colour,
                selected: line.icons[k] == icon,
                onTap: () => onIcon(line.icons[k]),
              )
            else
              const SizedBox.square(dimension: DotLook.icon),
        ],
      ),
    );
  }
}
