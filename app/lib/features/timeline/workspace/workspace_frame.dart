import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_frame.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_toggle.dart';
import 'package:dottoday/features/timeline/workspace/plan_panel_button.dart';
import 'package:dottoday/features/timeline/workspace/workspace_scope.dart';
import 'package:dottoday/features/timeline/workspace/workspace_toolbar.dart';
import 'package:dottoday/features/timeline/workspace/workspace_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Workspace around Today, Week and Month at the expanded width in
/// Full (E-FullA-v2, ED-073): its toolbar over the view. Narrower windows
/// and Minimal (M19.6) show the screen as before.
class WorkspaceFrame extends ConsumerWidget {
  const WorkspaceFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = AppLayout.classOf(context) == WidthClass.expanded;
    final full = !watchSimplified(ref, FeatureId.spread);
    final today = ref.watch(todayDateProvider).value;
    if (!wide || !full || today == null) return child;
    final router = GoRouter.of(context);
    final path = router.routerDelegate.currentConfiguration.uri.path;
    final view = workspaceViewOf(path) ?? WorkspaceView.day;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WorkspaceToolbar(
          view: view,
          shown: workspaceShownDate(path) ?? today,
          today: today,
          firstDayOfWeek: settings?.firstDayOfWeek ?? 1,
          leading: const PlanPanelButton(),
          trailing: workspaceInspects(path) ? const InspectorToggle() : null,
        ),
        Expanded(
          child: WorkspaceScope(
            child: InspectorFrame(
              inspects: workspaceInspects(path),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
