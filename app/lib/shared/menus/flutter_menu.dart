import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:flutter/material.dart';

/// The menu Flutter draws (Android, the web, a build without the native
/// bridge): Material's, with each [ContextMenuEntry.header] as a group
/// title. An entry with children opens them as a second menu on Android
/// and shows them as chips in its row on the web (E-FullA-v2's Need more
/// time +5 / +15 / +30); a ticked entry is a switch on the web (Low-energy
/// mode) and a check on Android.
Future<T?> showFlutterMenu<T>(
  BuildContext context, {
  required Offset at,
  required List<ContextMenuEntry<T>> entries,
  String? semanticLabel,
}) async {
  final web = webChrome(context);
  final position = RelativeRect.fromLTRB(at.dx, at.dy, at.dx, at.dy);
  // A submenu row closes the menu with no value and names itself here.
  ContextMenuEntry<T>? opened;
  final picked = await showMenu<T>(
    context: context,
    position: position,
    semanticLabel: semanticLabel,
    // The web's popover is wider than Material's menu, for its chips.
    constraints: web && entries.any((e) => e.children.isNotEmpty)
        ? const BoxConstraints(maxWidth: DotSize.webDayMenu)
        : null,
    items: [
      for (final e in entries) ...[
        if (e.divided && e.header == null) const PopupMenuDivider(),
        if (e.header case final h?) _Header<T>(h, first: e == entries.first),
        if (e.children.isNotEmpty && web)
          _ChipRow<T>(entry: e)
        else
          _item(context, e, web: web, onOpen: () => opened = e),
      ],
    ],
  );
  if (picked != null) return picked;
  final sub = opened;
  if (sub == null || !context.mounted) return null;
  return showFlutterMenu(
    context,
    at: at,
    entries: sub.children,
    semanticLabel: sub.label,
  );
}

PopupMenuEntry<T> _item<T>(
  BuildContext context,
  ContextMenuEntry<T> e, {
  required bool web,
  required VoidCallback onOpen,
}) {
  final t = DotTheme.of(context);
  final Widget label = switch (e.glyph) {
    final g? => Row(
      spacing: DotSpace.m,
      children: [
        DotIcon(g, color: t.colors.ink),
        Flexible(child: Text(e.label)),
      ],
    ),
    null => Text(e.label),
  };
  if (e.children.isNotEmpty) {
    return PopupMenuItem<T>(
      onTap: onOpen,
      enabled: e.enabled,
      child: Row(
        children: [
          Expanded(child: label),
          DotIcon(DotGlyphs.chevronRight, color: t.colors.secondary),
        ],
      ),
    );
  }
  final checked = e.checked;
  if (checked != null && web) {
    return PopupMenuItem(
      value: e.value,
      enabled: e.enabled,
      child: Row(
        children: [
          Expanded(child: label),
          ExcludeSemantics(child: Switch(value: checked, onChanged: null)),
        ],
      ),
    );
  }
  if (checked != null) {
    return CheckedPopupMenuItem(
      value: e.value,
      enabled: e.enabled,
      checked: checked,
      child: label,
    );
  }
  return PopupMenuItem(value: e.value, enabled: e.enabled, child: label);
}

/// A group's title (Time, Plan, Day, Layout), with a line above it after
/// the first group.
class _Header<T> extends PopupMenuEntry<T> {
  const _Header(this.title, {required this.first});

  final String title;
  final bool first;

  @override
  double get height => DotTouch.pointer + DotSpace.s;

  @override
  bool represents(T? value) => false;

  @override
  State<_Header<T>> createState() => _HeaderState<T>();
}

class _HeaderState<T> extends State<_Header<T>> {
  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.first) const Divider(height: DotSpace.s),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            DotSpace.m,
            DotSpace.xs,
            DotSpace.m,
            DotSpace.xxs,
          ),
          child: Semantics(
            header: true,
            child: Text(widget.title, style: t.styles.caption),
          ),
        ),
      ],
    );
  }
}

/// "Need more time  +5  +15  +30" on the web: the children as chips in
/// one row, each closing the menu with its value.
class _ChipRow<T> extends PopupMenuEntry<T> {
  const _ChipRow({required this.entry});

  final ContextMenuEntry<T> entry;

  @override
  double get height => kMinInteractiveDimension;

  @override
  bool represents(T? value) => false;

  @override
  State<_ChipRow<T>> createState() => _ChipRowState<T>();
}

class _ChipRowState<T> extends State<_ChipRow<T>> {
  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final e = widget.entry;
    final chips = Wrap(
      spacing: DotSpace.xs,
      children: [
        for (final c in e.children)
          ActionChip(
            label: Text(c.label),
            shape: dotChipShape(context),
            onPressed: e.enabled && c.enabled
                ? () => Navigator.of(context).pop(c.value)
                : null,
          ),
      ],
    );
    // The chips go under the label when the row can't hold both (large
    // text, a narrow window).
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.m,
        vertical: DotSpace.xxs,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: DotSpace.xxs,
        children: [
          Text(
            e.label,
            style: t.styles.body.copyWith(
              color: e.enabled ? t.colors.ink : t.colors.secondary,
            ),
          ),
          chips,
        ],
      ),
    );
  }
}
