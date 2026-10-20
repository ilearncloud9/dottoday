import 'package:dottoday/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// One top-level destination for [AdaptiveNavScaffold].
final class NavDestination {
  const NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;

  /// Localised label; also the screen-reader name.
  final String label;
}

/// Bottom [NavigationBar] below [AppBreakpoints.navigationRail], a
/// [NavigationRail] from there up (docs/03 §2). Chosen by available width,
/// never by platform.
///
/// When a [fab] is given, [body] gets [AppSpacing.fabClearance] of extra
/// bottom padding via `MediaQuery`, which scroll views apply automatically,
/// so the end of a list is never covered by the button.
class AdaptiveNavScaffold extends StatelessWidget {
  const AdaptiveNavScaffold({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    required this.body,
    this.fab,
    super.key,
  });

  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Widget body;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth >= AppBreakpoints.navigationRail
              ? _rail(context)
              : _bar(context),
    );
  }

  Widget _bar(BuildContext context) {
    return Scaffold(
      body: _content(context),
      floatingActionButton: fab,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelect,
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }

  Widget _rail(BuildContext context) {
    return Scaffold(
      floatingActionButton: fab,
      body: Row(
        children: [
          // SafeArea keeps the rail clear of notches / the macOS title bar
          // (verify on device in M5.5).
          SafeArea(
            right: false,
            child: NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelect,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
          ),
          const VerticalDivider(
            width: AppSpacing.hairline,
            thickness: AppSpacing.hairline,
          ),
          Expanded(child: _content(context)),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (fab == null) return body;
    // Builder: read the padding *inside* the Scaffold, after it has consumed
    // insets the bottom bar already handles, so they aren't added twice.
    return Builder(
      builder: (context) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            padding: mq.padding.copyWith(
              bottom: mq.padding.bottom + AppSpacing.fabClearance,
            ),
          ),
          child: body,
        );
      },
    );
  }
}
