import 'dart:async';

import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/look/recent_icons.dart';
import 'package:dottoday/domain/icon_guess/icon_guess.dart';
import 'package:dottoday/shared/pickers/look/look_colours.dart';
import 'package:dottoday/shared/pickers/look/look_compact.dart';
import 'package:dottoday/shared/pickers/look/look_icons.dart';
import 'package:dottoday/shared/pickers/task_icon_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The picker's pages: Colour and icon, All icons, All colours.
enum LookPage { compact, icons, colours }

/// A task's colour and icon on phones (E-Phones, ED-086; E-Phones-3,
/// ED-161; M19.4 part 4c-2): the compact sheet, dragged up or "All icons"
/// for the library with its pinned palette, ⋯ for All colours. Each pick
/// is [onChanged] at once, so the task behind recolours live; Done (or a
/// swipe down) closes. From medium width the full picker opens instead
/// until 4c-3's popover, and its pick is [onChanged] once.
Future<void> showTaskLook(
  BuildContext context, {
  required TaskColor colour,
  required TaskIcon icon,
  required String title,
  required ValueChanged<TaskLook> onChanged,
}) async {
  if (AppLayout.classOf(context) != WidthClass.compact) {
    final picked = await showTaskLookPicker(
      context: context,
      colour: colour,
      icon: icon,
    );
    if (picked != null) onChanged(picked);
    return;
  }
  await _show<void>(
    context,
    LookHost(
      colour: colour,
      icon: icon,
      title: title,
      start: LookPage.compact,
      onChanged: onChanged,
    ),
  );
}

/// All colours alone, for several tasks at once (the select bar's Colour;
/// owner, 4c-2): the colour on Done, or null.
Future<TaskColor?> showColourOnly(
  BuildContext context, {
  TaskColor colour = TaskColor.fallback,
}) => _show<TaskColor>(
  context,
  LookHost(
    colour: colour,
    icon: TaskIcon.fallback,
    title: '',
    start: LookPage.colours,
    onChanged: null,
  ),
);

Future<T?> _show<T>(BuildContext context, Widget host) =>
    showModalBottomSheet<T>(
      context: context,
      // Above the iPhone's floating tab bar (M4.9).
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DotLook.sheetRadius),
        ),
      ),
      builder: (_) => host,
    );

/// The sheet's body: which page, and the colour and icon so far.
class LookHost extends ConsumerStatefulWidget {
  const LookHost({
    required this.colour,
    required this.icon,
    required this.title,
    required this.start,
    required this.onChanged,
    super.key,
  });

  final TaskColor colour;
  final TaskIcon icon;
  final String title;
  final LookPage start;

  /// Each pick, live; null when the caller takes the colour on Done.
  final ValueChanged<TaskLook>? onChanged;

  @override
  ConsumerState<LookHost> createState() => _LookHostState();
}

/// A leaf: the page and the look being picked.
class _LookHostState extends ConsumerState<LookHost> {
  late var _page = widget.start;
  late var _colour = widget.colour;
  late var _icon = widget.icon;

  void _set({TaskColor? colour, TaskIcon? icon}) {
    setState(() {
      _colour = colour ?? _colour;
      _icon = icon ?? _icon;
    });
    widget.onChanged?.call((color: _colour, icon: _icon));
    if (icon != null) {
      unawaited(ref.read(recentIconsProvider.notifier).use(icon.key));
    }
  }

  void _done() =>
      Navigator.of(context).pop(widget.onChanged == null ? _colour : null);

  void _go(LookPage p) => setState(() => _page = p);

  List<TaskIcon> _suggested(BuildContext context) => [
    for (final k in guessIconKeys(
      widget.title,
      language: Localizations.localeOf(context).languageCode,
    ))
      TaskIcon.fromKey(k),
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final recent = [
      for (final k in ref.watch(recentIconsProvider).value ?? const <String>[])
        TaskIcon.fromKey(k),
    ].where((i) => i.glyph != null).toList();
    final Widget page = switch (_page) {
      LookPage.compact => _drags(
        LookCompact(
          colour: _colour,
          icon: _icon,
          suggested: _suggested(context),
          recent: recent,
          onColour: (c) => _set(colour: c),
          onIcon: (i) => _set(icon: i),
          onAllColours: () => _go(LookPage.colours),
          onAllIcons: () => _go(LookPage.icons),
          onDone: _done,
        ),
      ),
      LookPage.icons => SizedBox(
        height: height - DotLook.iconsTop - MediaQuery.paddingOf(context).top,
        child: LookIcons(
          colour: _colour,
          icon: _icon,
          recent: recent,
          onColour: (c) => _set(colour: c),
          onIcon: (i) => _set(icon: i),
          onAllColours: () => _go(LookPage.colours),
          onDone: _done,
        ),
      ),
      LookPage.colours => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height * DotLook.coloursShare),
        child: SingleChildScrollView(
          padding: _pad(context),
          child: LookColours(
            colour: _colour,
            icon: _icon,
            onColour: (c) => _set(colour: c),
            onDone: _done,
          ),
        ),
      ),
    };
    return PopScope(
      // Back from a page opened in the sheet returns to Colour and icon.
      canPop: _page == widget.start,
      onPopInvokedWithResult: (popped, _) {
        if (!popped) _go(widget.start);
      },
      child: _page == LookPage.compact
          ? Padding(padding: _pad(context), child: page)
          : page,
    );
  }

  EdgeInsets _pad(BuildContext context) => EdgeInsets.fromLTRB(
    DotSpace.l,
    0,
    DotSpace.l,
    DotSpace.l + MediaQuery.paddingOf(context).bottom,
  );

  /// Drag up for All icons (ED-086); drag down closes.
  Widget _drags(Widget child) => GestureDetector(
    onVerticalDragEnd: (d) {
      final v = d.primaryVelocity ?? 0;
      if (v < 0) _go(LookPage.icons);
      if (v > 0) _done();
    },
    child: child,
  );
}
