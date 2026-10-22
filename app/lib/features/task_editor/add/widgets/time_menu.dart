import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/round_more_button.dart';
import 'package:flutter/material.dart';

/// Width of the menu (`A-ios-add-time-menu`): its end lines up with the
/// ⋯'s end, inside the page margin.
const double _menuWidth = 300;

/// The ⋯ on TIME (docs/10 §3 `TimeMenu`, `A-ios-add-time-menu`): Change
/// day · Pick from the week | Make it all-day · Send to Inbox | Time zone ·
/// Type a time. A popover on iPhone, the M3 menu elsewhere (the plan's
/// idiom for A4); both keyboard-operable.
class TimeMenu extends StatefulWidget {
  const TimeMenu({
    required this.dayText,
    required this.zoneText,
    required this.allDay,
    required this.onChangeDay,
    required this.onPickWeek,
    required this.onAllDay,
    required this.onInbox,
    required this.onZone,
    required this.onTypeTime,
    super.key,
  });

  /// "Today", and "Berlin": the current values shown at the end.
  final String dayText;
  final String zoneText;

  /// Whether the task is all-day (the item then reads "Give it a time").
  final bool allDay;
  final VoidCallback onChangeDay;
  final VoidCallback onPickWeek;
  final VoidCallback onAllDay;
  final VoidCallback onInbox;
  final VoidCallback onZone;
  final VoidCallback onTypeTime;

  @override
  State<TimeMenu> createState() => _TimeMenuState();
}

/// A leaf: owns the anchor's focus node.
class _TimeMenuState extends State<TimeMenu> {
  final _anchor = FocusNode();

  /// Focused when the menu opens, so arrow keys and Enter work at once.
  final _first = FocusNode();

  @override
  void dispose() {
    _anchor.dispose();
    _first.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final radius = DotIdiom.of(context) == DotIdiom.cupertino
        ? DotRadii.sheet
        : DotRadii.card;
    final w = widget;
    return MenuAnchor(
      childFocusNode: _anchor,
      onOpen: () => WidgetsBinding.instance.addPostFrameCallback(
        (_) => _first.requestFocus(),
      ),
      // Top-start sits under the button's start: shift back by the width
      // difference so the ends line up (mirrored by Directional in RTL).
      alignmentOffset: const Offset(
        -(_menuWidth - DotTouch.android),
        DotSpace.xs,
      ),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(t.colors.raised),
        // The outline carries the edge; a raised M3 shadow read as a grey
        // band against the sheet (§2.3 hairline outline instead).
        elevation: const WidgetStatePropertyAll(0),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: WidgetStatePropertyAll(DotElevation.floating.first.color),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: t.colors.outline),
          ),
        ),
      ),
      menuChildren: [
        _item(
          t,
          DotGlyphs.calendar,
          l10n.timeMenuChangeDay,
          w.onChangeDay,
          value: w.dayText,
          focusNode: _first,
        ),
        _item(t, DotGlyphs.dottedRow, l10n.timeMenuPickWeek, w.onPickWeek),
        const Divider(height: 1),
        _item(
          t,
          DotGlyphs.sunrise,
          w.allDay ? l10n.timeMenuTimed : l10n.timeMenuAllDay,
          w.onAllDay,
        ),
        _item(t, DotGlyphs.inbox, l10n.timeMenuInbox, w.onInbox),
        const Divider(height: 1),
        _item(
          t,
          DotGlyphs.globe,
          l10n.timeMenuZone,
          w.onZone,
          value: w.zoneText,
        ),
        _item(
          t,
          DotGlyphs.keyboard,
          l10n.timeMenuType,
          w.onTypeTime,
          trailing: DotIcon(
            DotGlyphs.chevronRight,
            color: t.colors.muted,
            size: DotSize.rowIcon,
          ),
        ),
      ],
      builder: (context, controller, _) => RoundMoreButton(
        focusNode: _anchor,
        tooltip: l10n.addMoreTime,
        open: controller.isOpen,
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }

  Widget _item(
    DotTheme t,
    DotGlyph glyph,
    String label,
    VoidCallback onTap, {
    String? value,
    Widget? trailing,
    FocusNode? focusNode,
  }) => MenuItemButton(
    focusNode: focusNode,
    onPressed: onTap,
    style: MenuItemButton.styleFrom(
      minimumSize: const Size(_menuWidth, DotTouch.android + DotSpace.s),
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
    ),
    leadingIcon: Container(
      width: DotSize.macRowDot + DotSpace.xs,
      height: DotSize.macRowDot + DotSpace.xs,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.colors.accentTint,
      ),
      child: Center(
        child: DotIcon(glyph, color: t.colors.accentInk, size: DotSize.rowIcon),
      ),
    ),
    trailingIcon:
        trailing ??
        (value == null
            ? null
            : Text(
                value,
                style: t.styles.body.copyWith(color: t.colors.muted),
              )),
    child: Padding(
      padding: const EdgeInsetsDirectional.only(end: DotSpace.xl),
      child: Text(label, style: t.styles.rowTitle),
    ),
  );
}
