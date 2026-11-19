import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/plan_panel_prefs.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/features/timeline/workspace/plan_panel_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The toolbar's first button (ED-184): pressed while the Plan panel
/// shows. Docked, it hides the panel; hidden, it brings it out over the
/// grid; out, it puts it away again.
class PlanPanelButton extends ConsumerWidget {
  const PlanPanelButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final prefs = ref.watch(planPanelProvider).value ?? const PlanPanelPrefs();
    final out = ref.watch(planPanelOutProvider);
    final touch = watchTouchContent(context, ref);
    final docked = planPanelDocked(context, prefs, touch: touch);
    final pressed = docked || out;
    final h = touch ? DotTouch.android : DotSize.workspaceControl;
    void tap() {
      if (docked) {
        unawaited(ref.read(planPanelProvider.notifier).setHidden(hidden: true));
      } else {
        ref.read(planPanelOutProvider.notifier).set(out: !out);
      }
    }

    final label = pressed ? l10n.planPanelHide : l10n.planPanelShow;
    return Semantics(
      button: true,
      toggled: pressed,
      label: label,
      excludeSemantics: true,
      onTap: tap,
      child: Tooltip(
        message: label,
        child: Material(
          color: pressed ? t.colors.accentTint : Colors.transparent,
          shape: const StadiumBorder(),
          child: InkWell(
            onTap: tap,
            customBorder: const StadiumBorder(),
            child: SizedBox(
              width: h + DotSpace.xs,
              height: h,
              child: Center(
                child: DotIcon(
                  DotGlyphs.sidebar,
                  color: pressed ? t.colors.accentText : t.colors.ink2,
                  size: DotSize.sidebarGlyph,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
