import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/navigation/dot_rail.dart';
import 'package:dottoday/shared/navigation/material_nav_bar.dart';
import 'package:dottoday/shared/navigation/pill_tab_bar.dart';
import 'package:flutter/material.dart';

/// One top-level destination (docs/10 §3: the nav set is fixed).
@immutable
final class ShellDestination {
  const ShellDestination({
    required this.glyph,
    required this.label,
    this.expandedOnly = false,
    this.badge,
    this.badgeLabel,
  });

  /// [DotGlyphs.today] is drawn as the Today dot (filled when selected).
  final DotGlyph glyph;

  /// Localised label; also the screen-reader name.
  final String label;

  /// Week: on the Mac/web rail only; phones use the strip + month (§4).
  final bool expandedOnly;

  /// A count on the icon (the Inbox, docs/02 F3.3); null or 0 shows none.
  final int? badge;

  /// What a screen reader says for the destination with its [badge]
  /// ("Inbox, 3 tasks"); null reads [label].
  final String? badgeLabel;

  /// The screen-reader name: [badgeLabel] while a badge shows.
  String get semanticLabel => (badge ?? 0) > 0 ? badgeLabel ?? label : label;
}

/// The app shell by width class (docs/10 §4), never by platform:
/// compact = tab bar + add button, medium = rail + add, expanded = the
/// Mac/web rail with every destination. Within compact, [DotIdiom] picks
/// the iPhone pill bar or the Material bar (§4 allowed idioms).
class DotShell extends StatelessWidget {
  const DotShell({
    required this.destinations,
    required this.selected,
    required this.onSelect,
    required this.body,
    required this.onAdd,
    required this.addLabel,
    super.key,
  });

  /// All destinations in nav order; each width shows the ones it may.
  final List<ShellDestination> destinations;

  /// Index into [destinations].
  final int selected;
  final ValueChanged<int> onSelect;
  final Widget body;
  final VoidCallback onAdd;

  /// "Add task".
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final width = WidthClass.of(box.maxWidth);
        final shown = [
          for (final (i, d) in destinations.indexed)
            if (width == WidthClass.expanded || !d.expandedOnly) i,
        ];
        final bar = ShellBar(
          items: [for (final i in shown) destinations[i]],
          // A hidden destination (Week at phone width) highlights nothing.
          selected: shown.indexOf(selected),
          onSelect: (k) => onSelect(shown[k]),
          // Mac/web add by ⌘N, the Inbox field and "add here" (§4 renders).
          onAdd: width == WidthClass.expanded ? null : onAdd,
          addLabel: addLabel,
        );
        return switch ((width, DotIdiom.of(context))) {
          (WidthClass.compact, DotIdiom.cupertino) => PillTabShell(
            bar: bar,
            body: body,
          ),
          (WidthClass.compact, DotIdiom.material) => MaterialBarShell(
            bar: bar,
            body: body,
          ),
          (_, _) => DotRailShell(bar: bar, body: body),
        };
      },
    );
  }
}

/// What every shell variant draws: the visible destinations and the add
/// action (null on the Mac/web rail).
@immutable
final class ShellBar {
  const ShellBar({
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.onAdd,
    required this.addLabel,
  });

  final List<ShellDestination> items;

  /// Index into [items], or -1 when the current page has no entry here.
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback? onAdd;
  final String addLabel;
}

/// Bottom inset so the end of a scrolled page clears floating chrome,
/// applied through `MediaQuery` padding, which scroll views honour.
class ChromeClearance extends StatelessWidget {
  const ChromeClearance({required this.bottom, required this.child, super.key});

  final double bottom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        padding: mq.padding.copyWith(bottom: mq.padding.bottom + bottom),
      ),
      child: child,
    );
  }
}

/// The nav icon for [destination]: the Today dot, or its glyph.
class ShellIcon extends StatelessWidget {
  const ShellIcon({
    required this.destination,
    required this.active,
    required this.color,
    super.key,
  });

  final ShellDestination destination;
  final bool active;
  final Color color;

  /// More than this reads "99+": a count, not an inventory.
  static const _maxBadge = 99;

  @override
  Widget build(BuildContext context) {
    final count = destination.badge ?? 0;
    final icon = _icon();
    if (count <= 0) return icon;
    final t = DotTheme.of(context);
    // Accent, never red: a count of loose tasks is not an alarm (§11
    // no-shame). The tab's own label carries it for screen readers.
    return Badge.count(
      count: count,
      maxCount: _maxBadge,
      backgroundColor: t.colors.accent,
      textColor: t.colors.onAccent,
      textStyle: t.styles.tabLabelActive,
      child: icon,
    );
  }

  Widget _icon() {
    if (destination.glyph != DotGlyphs.today) {
      return DotIcon(destination.glyph, color: color, active: active);
    }
    // §1: "the Today tab icon is a dot", filled 12 px when selected and a
    // 10 px ring otherwise (`Main`, `A-ios-inbox`).
    final size = active ? DotSize.tabDotActive : DotSize.tabDot;
    return SizedBox.square(
      dimension: DotSize.navIcon,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? color : null,
            border: active
                ? null
                : Border.all(color: color, width: DotSize.smallDotOutline),
          ),
        ),
      ),
    );
  }
}
