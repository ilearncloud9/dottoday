import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/look/recent_icons.dart';
import 'package:dottoday/shared/pickers/look/look_colours.dart';
import 'package:dottoday/shared/pickers/look/look_compact.dart';
import 'package:dottoday/shared/pickers/look/look_icons.dart';
import 'package:dottoday/shared/pickers/look/look_sources.dart';
import 'package:dottoday/shared/pickers/task_icon_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The picker's pages: Colour and icon, All icons, All colours.
enum LookPage { compact, icons, colours }

/// The sheet's body: which page, and the colour and icon so far.
class LookHost extends ConsumerStatefulWidget {
  const LookHost({
    required this.colour,
    required this.icon,
    required this.title,
    required this.start,
    required this.onChanged,
    this.maxHeight,
    super.key,
  });

  final TaskColor colour;
  final TaskIcon icon;
  final String title;
  final LookPage start;

  /// Each pick, live; null when the caller takes the colour on Done.
  final ValueChanged<TaskLook>? onChanged;

  /// Boxed in a tablet's popover or dialog (E-R2-15, ED-298): the pages
  /// fit this height and leave out the sheet's safe area; null in a sheet.
  final double? maxHeight;

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

  @override
  Widget build(BuildContext context) {
    final box = widget.maxHeight;
    final height = box ?? MediaQuery.sizeOf(context).height;
    final recent = recentIcons(ref);
    final Widget page = switch (_page) {
      LookPage.compact => _drags(
        LookCompact(
          colour: _colour,
          icon: _icon,
          suggested: suggestedIcons(context, widget.title),
          recent: recent,
          onColour: (c) => _set(colour: c),
          onIcon: (i) => _set(icon: i),
          onAllColours: () => _go(LookPage.colours),
          onAllIcons: () => _go(LookPage.icons),
          onDone: _done,
        ),
      ),
      LookPage.icons => SizedBox(
        height:
            box ??
            height - DotLook.iconsTop - MediaQuery.paddingOf(context).top,
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
        constraints: BoxConstraints(
          maxHeight: box ?? height * DotLook.coloursShare,
        ),
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
    DotSpace.l +
        (widget.maxHeight == null ? MediaQuery.paddingOf(context).bottom : 0),
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
