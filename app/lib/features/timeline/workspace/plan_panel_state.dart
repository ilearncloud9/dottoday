import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/plan_panel_prefs.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plan_panel_state.g.dart';

/// The Plan panel brought out over the grid while it is hidden (rules
/// §9.16): Esc, a click away or the pin end it. Not remembered.
@Riverpod(keepAlive: true)
class PlanPanelOut extends _$PlanPanelOut {
  @override
  bool build() => false;

  void set({required bool out}) => state = out;
}

/// Whether a [content]-wide Workspace keeps a 3-day week beside a
/// [panel]-wide Plan panel (ED-184: hidden on its own below that).
bool planPanelHasRoom(double content, double panel) =>
    content - panel - DotSpace.hairline >= DotSize.weekGridMin;

/// The Workspace's width beside its sidebar.
double workspaceContentWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width - DotSize.sidebar - DotSpace.hairline;

/// Whether the panel is docked: not hidden by the person, and with room.
bool planPanelDocked(BuildContext context, PlanPanelPrefs prefs) =>
    !prefs.hidden &&
    planPanelHasRoom(workspaceContentWidth(context), prefs.width);

/// ⌥⌘P and View › Show Plan Panel (ED-184): the person shows it if they
/// had hidden it, else hides it.
Future<void> togglePlanPanelHidden(WidgetRef ref) {
  final hidden = ref.read(planPanelProvider).value?.hidden ?? false;
  return ref.read(planPanelProvider.notifier).setHidden(hidden: !hidden);
}
