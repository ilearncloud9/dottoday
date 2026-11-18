import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/features/timeline/workspace/workspace_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The Workspace toolbar's controls (E-FullA-v2): 30-tall pills with a
// pointer, the touch height on tablets and touch-first web (ED-261).

/// A control's height and target: 30 with a pointer, 48 on touch (both
/// floors, 44 pt and 48 dp).
double _height(BuildContext context, WidgetRef ref) =>
    watchTouchContent(context, ref)
    ? DotTouch.android
    : DotSize.workspaceControl;

/// A card-coloured pill with a hairline: the date, Day ▾, the search.
BoxDecoration _pill(DotColors c) => BoxDecoration(
  color: c.card,
  borderRadius: BorderRadius.circular(DotRadii.pill),
  border: Border.all(color: c.hairline),
);

/// ‹ Today › in one pill (ED-095: ⌘[ ⌘] and T step and return too).
class StepGroup extends ConsumerWidget {
  const StepGroup({
    required this.backLabel,
    required this.aheadLabel,
    required this.todayLabel,
    required this.onBack,
    required this.onToday,
    required this.onAhead,
    super.key,
  });

  final String backLabel;
  final String aheadLabel;
  final String todayLabel;
  final VoidCallback onBack;
  final VoidCallback onToday;
  final VoidCallback onAhead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final h = _height(context, ref);
    Widget step(DotGlyph g, String label, VoidCallback onTap) => Tooltip(
      message: label,
      child: InkResponse(
        onTap: onTap,
        radius: h / 2,
        child: SizedBox.square(
          dimension: h,
          child: Center(
            child: DotIcon(g, color: t.colors.ink2, size: DotSize.rowIcon),
          ),
        ),
      ),
    );
    // The outline is drawn over the pill, not inside it: the steps keep
    // the full height as their target.
    return DecoratedBox(
      decoration: _pill(t.colors),
      child: SizedBox(
        height: h,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            step(DotGlyphs.chevronLeft, backLabel, onBack),
            InkWell(
              onTap: onToday,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: h),
                child: Center(
                  child: Text(
                    todayLabel,
                    style: t.styles.sidebarItem.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            step(DotGlyphs.chevronRight, aheadLabel, onAhead),
          ],
        ),
      ),
    );
  }
}

/// The shown date or range with ▾: a month to pick another day.
class DatePill extends ConsumerWidget {
  const DatePill({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Container(
            height: _height(context, ref),
            padding: const EdgeInsets.symmetric(horizontal: DotSpace.m),
            decoration: _pill(t.colors),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: DotSpace.s,
              children: [
                Text(label, style: t.styles.cardTitle),
                DotIcon(
                  DotGlyphs.chevronDown,
                  color: t.colors.accent,
                  size: DotSize.sidebarGlyph * 2 / 3,
                  bold: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Day · 3 days · Week · Month: one segmented control, the shown view
/// raised on a card.
class ViewTabs extends ConsumerWidget {
  const ViewTabs({
    required this.selected,
    required this.labels,
    required this.onSelect,
    super.key,
  });

  final WorkspaceView selected;
  final Map<WorkspaceView, String> labels;
  final ValueChanged<WorkspaceView> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final h = _height(context, ref);
    // Each tab keeps the full target; the track is that plus its inset.
    return Container(
      height: h + 2 * DotSpace.xxs,
      padding: const EdgeInsets.all(DotSpace.xxs),
      decoration: BoxDecoration(
        color: c.ink.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(DotRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final v in WorkspaceView.values)
            Semantics(
              button: true,
              selected: v == selected,
              label: labels[v],
              excludeSemantics: true,
              onTap: () => onSelect(v),
              child: InkWell(
                onTap: () => onSelect(v),
                customBorder: const StadiumBorder(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: DotSpace.m),
                  alignment: Alignment.center,
                  decoration: v == selected
                      ? BoxDecoration(
                          color: c.card,
                          borderRadius: BorderRadius.circular(DotRadii.pill),
                          boxShadow: DotElevation.segment(c),
                        )
                      : null,
                  child: Text(
                    labels[v]!,
                    style: t.styles.viewTab.copyWith(
                      color: v == selected ? c.ink : c.ink2,
                      fontWeight: v == selected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A card pill with a label and an optional ▾ (Day ▾, the Day menu).
class ToolbarPill extends ConsumerWidget {
  const ToolbarPill({required this.label, this.menu = false, super.key});

  final String label;
  final bool menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    return Container(
      height: _height(context, ref),
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.m),
      decoration: _pill(t.colors),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.xs,
        children: [
          Text(
            label,
            style: t.styles.sidebarItem.copyWith(fontWeight: FontWeight.w500),
          ),
          if (menu)
            DotIcon(
              DotGlyphs.chevronDown,
              color: t.colors.ink,
              size: DotSize.sidebarGlyph * 2 / 3,
            ),
        ],
      ),
    );
  }
}

/// The teal + (⌘N): Add.
class ToolbarAdd extends ConsumerWidget {
  const ToolbarAdd({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DotTheme.of(context).colors;
    final h = _height(context, ref);
    return Tooltip(
      message: label,
      child: Material(
        color: c.accent,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: SizedBox(
            width: h + DotSpace.xs,
            height: h,
            child: Center(
              child: DotIcon(
                DotGlyphs.add,
                color: c.onAccent,
                size: DotSize.sidebarGlyph,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Search or run ⌘K": opens Search until the palette exists (M19.2).
class SearchField extends ConsumerWidget {
  const SearchField({
    required this.label,
    required this.onTap,
    this.hint,
    this.compact = false,
    super.key,
  });

  final String label;
  final String? hint;
  final VoidCallback onTap;

  /// Its icon alone, named for a screen reader (a narrow toolbar).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final h = _height(context, ref);
    if (compact) {
      return Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Container(
              width: h + DotSpace.xs,
              height: h,
              decoration: _pill(t.colors),
              child: Center(
                child: DotIcon(
                  DotGlyphs.search,
                  color: t.colors.ink2,
                  size: DotSize.sidebarGlyph * 5 / 6,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Container(
            height: h,
            constraints: const BoxConstraints(
              minWidth: DotSize.workspaceSearch,
            ),
            padding: const EdgeInsets.symmetric(horizontal: DotSpace.m),
            decoration: _pill(t.colors),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: DotSpace.s,
              children: [
                DotIcon(
                  DotGlyphs.search,
                  color: t.colors.ink2,
                  size: DotSize.sidebarGlyph * 5 / 6,
                ),
                Text(
                  label,
                  style: t.styles.sidebarItem.copyWith(color: t.colors.ink2),
                ),
                if (hint case final h?) Text(h, style: t.styles.sidebarHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
