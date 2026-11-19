import 'package:dottoday/core/editing/inspected_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The toolbar's last button (E-FullA-v2), the same as ⌥⌘I and View ›
/// Show Inspector (ED-218): pressed while the inspector is on, so a
/// picked task shows in it; off, picks wait until it is on again.
class InspectorToggle extends ConsumerWidget {
  const InspectorToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final on = !ref.watch(inspectorHiddenProvider);
    final h = watchTouchContent(context, ref)
        ? DotTouch.android
        : DotSize.workspaceControl;
    void tap() => ref.read(inspectorHiddenProvider.notifier).toggle();
    final label = on ? l10n.inspectorHide : l10n.inspectorShow;
    return Semantics(
      button: true,
      toggled: on,
      label: label,
      excludeSemantics: true,
      onTap: tap,
      child: Tooltip(
        message: label,
        child: Material(
          color: on ? t.colors.accentTint : Colors.transparent,
          shape: const StadiumBorder(),
          child: InkWell(
            onTap: tap,
            customBorder: const StadiumBorder(),
            child: SizedBox(
              width: h + DotSpace.xs,
              height: h,
              child: Center(
                child: DotIcon(
                  DotGlyphs.inspector,
                  color: on ? t.colors.accentText : t.colors.ink2,
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
