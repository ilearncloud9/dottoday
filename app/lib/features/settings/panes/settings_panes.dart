import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/layout/routines_place.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/settings/pages/everything_page.dart';
import 'package:dottoday/features/settings/panes/settings_pane_scope.dart';
import 'package:dottoday/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings in two panes on wide windows (M20.7 part 5a; E-R2-11, ED-291;
/// E-R2-18, ED-311; E-FullA-v2 "Web · Settings, two panes"): the root on
/// the left, the open page on the right, where its sub-pages push. Below
/// the expanded width, or when the detail would be narrower than a phone,
/// Settings is the phone stack ([navigator] alone).
///
/// Minimal (owner, part 5a): its short list on the left; Everything else…
/// swaps the left pane to the full root until its ‹ Settings.
class SettingsPanes extends ConsumerStatefulWidget {
  const SettingsPanes({required this.navigator, super.key});

  /// The Settings tab's navigator: the detail pane, or all of Settings.
  final Widget navigator;

  @override
  ConsumerState<SettingsPanes> createState() => _SettingsPanesState();
}

/// A leaf: the open page and whether Minimal's list shows the full root.
class _SettingsPanesState extends ConsumerState<SettingsPanes> {
  GoRouter? _router;
  SettingsPage? _page;
  bool _everything = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.maybeOf(context);
    if (router == _router) return;
    _router?.routerDelegate.removeListener(_onRoute);
    _router = router?..routerDelegate.addListener(_onRoute);
    _read();
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_onRoute);
    super.dispose();
  }

  void _onRoute() => setState(_read);

  /// The open page from the address; other tabs leave it as it was.
  void _read() {
    final router = _router;
    if (router == null) return;
    final path = router.routerDelegate.currentConfiguration.uri.path;
    final segments = Uri.parse(path).pathSegments;
    final settings = Uri.parse(AppRoutes.settings).pathSegments;
    if (segments.isEmpty || segments.first != settings.first) {
      return;
    }
    _page = segments.length > 1 ? SettingsPage.byName(segments[1]) : null;
    if (_page == null) _everything = false;
    if (_page == SettingsPage.everything) _everything = true;
  }

  @override
  Widget build(BuildContext context) {
    final minimal = watchSimplified(ref, FeatureId.notifications);
    // Routines is the sidebar's own place on the Mac and the web in Full
    // (E-R2-30, ED-451, ED-500): the page alone, no Settings list.
    if (_page == SettingsPage.routines && watchRoutinesAlone(context, ref)) {
      return widget.navigator;
    }
    final listWidth = _listWidth(context);
    return LayoutBuilder(
      builder: (context, box) {
        final two =
            AppLayout.classOf(context) == WidthClass.expanded &&
            box.maxWidth - listWidth >= DotSize.settingsDetailMin;
        if (!two) return widget.navigator;
        final t = DotTheme.of(context);
        final fullRoot = minimal && _everything;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: listWidth,
              decoration: BoxDecoration(
                border: BorderDirectional(
                  end: BorderSide(color: t.colors.hairline),
                ),
              ),
              child: SettingsPaneScope(
                pane: SettingsPane.list,
                selected: _selected(context, minimal: minimal),
                // Each list keeps its own scroll place (M16 sweep).
                child: fullRoot
                    ? const EverythingPage()
                    : const SettingsScreen(),
              ),
            ),
            Expanded(
              child: SettingsPaneScope(
                pane: SettingsPane.detail,
                child: widget.navigator,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 380 on iPad, 412 on Android tablets, 360 on the Mac and the web.
  double _listWidth(BuildContext context) {
    if (!touchApp(context)) return DotSize.settingsListWide;
    return DotIdiom.of(context) == DotIdiom.cupertino
        ? DotSize.settingsListIos
        : DotSize.settingsListAndroid;
  }

  /// The tinted row (owner, part 5a): Full opens on Your day, Minimal on
  /// Account and sync; a sub-page tints the group it sits under.
  SettingsPage? _selected(BuildContext context, {required bool minimal}) {
    final page = _page;
    if (minimal && !_everything) {
      return switch (page) {
        null => SettingsPage.account,
        final p when _minimalRows.contains(p) => p,
        _ => null,
      };
    }
    if (page == null || page == SettingsPage.everything) {
      return SettingsPage.yourDay;
    }
    return settingsTop(context.l10n, page);
  }

  /// The pages Minimal's short list opens (docs/14 §4).
  static const _minimalRows = {
    SettingsPage.wakeUp,
    SettingsPage.calendars,
    SettingsPage.account,
  };
}
