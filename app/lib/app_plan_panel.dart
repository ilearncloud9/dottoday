import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/workspace_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/plan_panel_prefs.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/features/inbox/widgets/inbox_plan_section.dart';
import 'package:dottoday/features/routines/widgets/routines_plan_section.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_plan_section.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/workspace/plan_panel_state.dart';
import 'package:dottoday/features/timeline/workspace/workspace_scope.dart';
import 'package:dottoday/shared/dot/inbox_beside.dart';
import 'package:dottoday/shared/navigation/focus_return.dart';
import 'package:dottoday/shared/workspace/plan_panel_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Workspace's Plan panel beside Today, Week and Month (E-FullA-v2,
/// ED-184, rules §9.16): Capture, Inbox, Routines and Brain dump, docked
/// between the sidebar and the view while the week keeps 3 days, hidden
/// by the person or for room, and brought out over the view by the
/// toolbar's button. Outside the Workspace (narrower windows, phones,
/// Minimal) [child] shows alone. Composed at the app root, so no feature
/// imports another.
class PlanPanelFrame extends ConsumerWidget {
  const PlanPanelFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!WorkspaceScope.of(context)) return child;
    final prefs = ref.watch(planPanelProvider).value ?? const PlanPanelPrefs();
    final out = ref.watch(planPanelOutProvider);
    final view = InboxBeside(child: child);
    final touch = watchTouchContent(context, ref);
    return LayoutBuilder(
      builder: (context, box) {
        final docked =
            !prefs.hidden &&
            planPanelHasRoom(box.maxWidth, prefs.width, touch: touch);
        if (docked) {
          final c = DotTheme.of(context).colors;
          // Tab: the panel, then the view (E-G4-7-States D2, ED-248), by
          // order rather than by where a scrolled block sits.
          return FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FocusTraversalOrder(
                  order: const NumericFocusOrder(0),
                  child: FocusTraversalGroup(child: _Panel(prefs: prefs)),
                ),
                VerticalDivider(width: DotSpace.hairline, color: c.hairline),
                Expanded(
                  child: FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: FocusTraversalGroup(child: view),
                  ),
                ),
              ],
            ),
          );
        }
        if (!out) return view;
        void close() => ref.read(planPanelOutProvider.notifier).set(out: false);
        return Stack(
          children: [
            view,
            // Click away closes it; the view stays as it was.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: close,
              ),
            ),
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: _Out(
                onClose: close,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    boxShadow: DotElevation.floating,
                  ),
                  child: _Panel(
                    prefs: prefs,
                    pin: _Pin(
                      onTap: () {
                        close();
                        unawaited(
                          ref
                              .read(planPanelProvider.notifier)
                              .setHidden(hidden: false),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The panel's sections, from the Inbox, Routines and Brain dump.
class _Panel extends ConsumerWidget {
  const _Panel({required this.prefs, this.pin});

  final PlanPanelPrefs prefs;
  final Widget? pin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final today = ref.watch(todayDateProvider).value;
    if (today == null) return SizedBox(width: prefs.width);
    // The shown day, from the address (routines drop on it).
    final path = GoRouter.maybeOf(
      context,
    )?.routerDelegate.currentConfiguration.uri.path;
    final day = (path == null ? null : workspaceShownDate(path)) ?? today;
    final panel = ref.read(planPanelProvider.notifier);
    PlanPanelSection section(
      String id,
      String title,
      Widget child, {
      String? trailing,
    }) => PlanPanelSection(
      title: title,
      trailing: trailing,
      folded: prefs.folded.contains(id),
      onToggle: () => unawaited(panel.toggleFold(id)),
      child: child,
    );
    final inbox = openInboxCount(ref);
    final routines = routineCount(ref);
    return PlanPanelShell(
      width: prefs.width,
      minWidth: PlanPanelPrefs.minWidth,
      onResize: (w) => unawaited(panel.setWidth(w)),
      onHide: () => unawaited(panel.setHidden(hidden: true)),
      pin: pin,
      touch: watchTouchContent(context, ref),
      top: const InboxPlanSection(capture: true),
      sections: [
        section(
          'inbox', // l10n-ignore: a stored section id
          l10n.navInbox,
          const InboxPlanSection(rows: true),
          trailing: inbox == 0 ? null : '$inbox', // l10n-ignore: a count
        ),
        section(
          'routines', // l10n-ignore: a stored section id
          l10n.routinesTitle,
          RoutinesPlanSection(day: day, today: today),
          trailing: routines == 0 ? null : '$routines', // l10n-ignore: a count
        ),
        section(
          'dump', // l10n-ignore: a stored section id
          l10n.dumpTitle,
          BrainDumpPlanSection(today: today),
        ),
      ],
    );
  }
}

/// The panel brought out: it takes focus as it opens, so Esc closes it
/// (rules §9.16), and gives it back as it goes.
class _Out extends StatefulWidget {
  const _Out({required this.onClose, required this.child});

  final VoidCallback onClose;
  final Widget child;

  @override
  State<_Out> createState() => _OutState();
}

class _OutState extends State<_Out> {
  final _focus = FocusNode(debugLabel: 'plan panel'); // l10n-ignore: debug

  /// What had focus before, given back when the panel goes (ED-248).
  final _back = FocusReturn();

  @override
  void initState() {
    super.initState();
    _back.track(false, true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _back.track(true, false);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
    },
    child: Focus(focusNode: _focus, child: widget.child),
  );
}

/// "Keep the Plan panel open": docks the panel brought out.
class _Pin extends StatelessWidget {
  const _Pin({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return IconButton(
      onPressed: onTap,
      tooltip: context.l10n.planPanelPin,
      icon: DotIcon(DotGlyphs.sidebar, color: t.colors.accentText),
    );
  }
}
