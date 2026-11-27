import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/brand/brand_row.dart';
import 'package:dottoday/shared/chips/key_cap.dart';
import 'package:dottoday/shared/navigation/add_menu.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// What the web's minimal sidebar adds to the list of places (E-R2-30,
/// ED-500): a row after the places (Search or run), a note above the foot
/// (the keyboard hint) and a line under it (sync). With them the sidebar
/// also wears "● Dottoday" and puts counts and keys at the rows' ends.
typedef SidebarExtras = ({
  Widget? afterPlaces,
  Widget? aboveFoot,
  Widget? belowFoot,
});

/// The list of places (E-R2-1, ED-267): the app's name with the sidebar
/// button, every place, and Settings at the foot, never a tab. Drawn in
/// the expanded sidebar, the Android drawer and the iPad's sidebar over
/// the content. [onPicked] runs after a place is chosen (a drawer closes).
class DotSidebar extends StatelessWidget {
  const DotSidebar({
    required this.bar,
    this.onToggle,
    this.onPicked,
    this.vibrant = false,
    this.extras,
    super.key,
  });

  final ShellBar bar;

  /// The web's minimal sidebar additions; null draws the plain list.
  final SidebarExtras? extras;

  /// Over the Mac's vibrant material: the warm tint instead of the solid
  /// sidebar colour (ED-130, ED-176).
  final bool vibrant;

  /// The sidebar button beside the name: hides the sidebar (expanded) or
  /// closes the drawer; null draws none.
  final VoidCallback? onToggle;
  final VoidCallback? onPicked;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final items = bar.items;
    final web = extras;
    Widget row(int i) => _SidebarRow(
      destination: items[i],
      ends: web != null,
      selected: i == bar.selected,
      onTap: () {
        bar.onSelect(i);
        onPicked?.call();
      },
    );
    // The web's minimal sidebar draws no fold button (E-R2-30, ED-500):
    // "● Dottoday" and the + share the line, wrapping at large text.
    final toggle = web == null ? onToggle : null;
    return ColoredBox(
      color: vibrant ? t.colors.sidebarTint : t.colors.canvas,
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DotSpace.s + DotSpace.xxs,
            vertical: DotSpace.s,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (web != null)
                _webHead(t)
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: DotTouch.min),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: DotSpace.s,
                          ),
                          child: Semantics(
                            header: true,
                            child: Text(
                              l10n.appTitle,
                              style: t.styles.cardTitle,
                            ),
                          ),
                        ),
                      ),
                      ?_add(t),
                      if (toggle != null)
                        IconButton(
                          onPressed: toggle,
                          tooltip: l10n.navHideSidebar,
                          icon: DotIcon(
                            DotGlyphs.sidebar,
                            color: t.colors.ink2,
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: DotSpace.s),
              for (final (i, d) in items.indexed)
                if (!d.foot) row(i),
              if (web?.afterPlaces case final w?) ...[
                const SizedBox(height: DotSpace.s),
                w,
              ],
              const Spacer(),
              if (web?.aboveFoot case final w?) ...[
                w,
                const SizedBox(height: DotSpace.s),
              ],
              for (final (i, d) in items.indexed)
                if (d.foot) row(i),
              ?web?.belowFoot,
            ],
          ),
        ),
      ),
    );
  }

  /// The + beside the name; null where the shell adds elsewhere.
  Widget? _add(DotTheme t) {
    final onAdd = bar.onAdd;
    if (onAdd == null) return null;
    return AddMenuButton(
      onAdd: onAdd,
      builder: (onPressed) => IconButton.filled(
        onPressed: onPressed,
        tooltip: bar.addLabel,
        style: IconButton.styleFrom(backgroundColor: t.colors.accent),
        icon: DotIcon(DotGlyphs.add, color: t.colors.onAccent, active: true),
      ),
    );
  }

  /// "● Dottoday" and the +: the web's minimal sidebar (E-R2-30), on one
  /// line while they fit, the + under the name at large text.
  Widget _webHead(DotTheme t) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: DotTouch.min),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: DotSpace.xs,
      children: [
        const Padding(
          padding: EdgeInsetsDirectional.only(start: DotSpace.s),
          child: BrandRow(),
        ),
        ?_add(t),
      ],
    ),
  );
}

/// One place: its icon and name, 44 pt / 48 dp high; the current one on the
/// accent's tint in bold (never colour alone).
class _SidebarRow extends StatelessWidget {
  const _SidebarRow({
    required this.destination,
    required this.selected,
    required this.onTap,
    this.ends = false,
  });

  /// The count and the key at the row's end, not on the icon (the web's
  /// minimal sidebar, E-R2-30).
  final bool ends;

  final ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    // The dark Mac sidebar's current place reads in the primary text over
    // its pill (ED-176); its icon keeps the accent text (I1, ED-178).
    final ink = macApp(context) && c.brightness == Brightness.dark
        ? c.text
        : c.accentInk;
    final label = selected
        ? DotType.emphasis(
            t.styles.body.copyWith(color: ink),
            bold: true,
            italic: false,
          )
        : t.styles.body;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? c.accentTint : Colors.transparent,
        borderRadius: BorderRadius.circular(DotRadii.railItem),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DotRadii.railItem),
          // 48 on touch, iPad included: the touch floor every screen test
          // checks (docs/08 §3; rules §6.4's 44 pt + 4, within ±4).
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: DotTouch.android),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
              child: Row(
                spacing: DotSpace.m,
                children: [
                  ShellIcon(
                    destination: destination,
                    active: selected,
                    color: selected ? c.accentInk : c.ink2,
                    badge: !ends,
                  ),
                  Expanded(child: Text(destination.label, style: label)),
                  if (ends) ..._ends(context, t),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The Inbox's count, then the place's key ("/"), as E-R2-30 draws them.
  List<Widget> _ends(BuildContext context, DotTheme t) => [
    if (destination.badge case final n? when n > 0)
      Text(
        NumberFormat.decimalPattern(
          Localizations.localeOf(context).toLanguageTag(),
        ).format(n),
        style: t.styles.rowMeta.copyWith(color: t.colors.muted),
      ),
    if (destination.keyCap case final k?) KeyCap(k),
  ];
}
