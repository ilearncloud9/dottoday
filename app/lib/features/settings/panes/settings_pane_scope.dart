import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/settings/settings_places.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Which pane a Settings widget is in when Settings shows two (M20.7 part
/// 5a, E-R2-11): the list on the left or the detail on the right.
enum SettingsPane { list, detail }

/// Settings in two panes (E-R2-11, ED-291): set by `SettingsPanes` around
/// each pane. Absent, Settings is one stack, as on phones.
class SettingsPaneScope extends InheritedWidget {
  const SettingsPaneScope({
    required this.pane,
    required super.child,
    this.selected,
    super.key,
  });

  final SettingsPane pane;

  /// The list pane's tinted row: the open page's place in the list.
  final SettingsPage? selected;

  /// The pane at [context], or null when Settings is one stack.
  static SettingsPane? paneAt(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsPaneScope>()?.pane;

  /// Whether the row for [page] at [context] is the list pane's tinted one.
  static bool selectedAt(BuildContext context, SettingsPage page) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<SettingsPaneScope>();
    return scope?.pane == SettingsPane.list && scope?.selected == page;
  }

  @override
  bool updateShouldNotify(SettingsPaneScope old) =>
      old.pane != pane || old.selected != selected;
}

/// Opens [page] from a row: from the list pane it replaces the detail
/// (the list stays, E-R2-11); elsewhere it is pushed over the page.
void openSettingsPage(BuildContext context, SettingsPage page) {
  final to = AppRoutes.settingsPage(page);
  if (SettingsPaneScope.paneAt(context) == SettingsPane.list) {
    return context.go(to);
  }
  unawaited(context.push(to));
}

/// Whether a page in the detail pane shows no back control: a group the
/// list opened (E-R2-11: "the group page drops its ‹ Settings / ←"), and
/// every page on Android tablets, whose M3 list-detail draws none
/// (E-R2-11 Android frames). iPad sub-pages keep ‹ Parent (E-R2-18).
bool settingsDetailWithoutBack(BuildContext context, SettingsPage? page) {
  if (SettingsPaneScope.paneAt(context) != SettingsPane.detail) return false;
  if (page == null) return true;
  if (settingsPlace(context.l10n, page).parent == null) return true;
  return touchApp(context) && DotIdiom.of(context) == DotIdiom.material;
}

/// [page]'s top-level place: itself, or the root page it sits under
/// (Wake Up and Wind Down → Your day).
SettingsPage settingsTop(AppLocalizations l10n, SettingsPage page) {
  var at = page;
  for (var up = settingsPlace(l10n, at).parent; up != null;) {
    at = up;
    up = settingsPlace(l10n, at).parent;
  }
  return at;
}

/// Whether [page] swaps the detail in place rather than being pushed: a
/// top-level page while Settings shows two panes (E-R2-11). [context] is
/// the Settings navigator's, inside the detail pane.
bool settingsInPlace(BuildContext context, SettingsPage page) =>
    SettingsPaneScope.paneAt(context) == SettingsPane.detail &&
    settingsPlace(context.l10n, page).parent == null;
