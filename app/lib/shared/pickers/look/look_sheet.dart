import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/pickers/look/look_host.dart';
import 'package:dottoday/shared/pickers/look/look_popover.dart';
import 'package:dottoday/shared/pickers/task_icon_picker.dart';
import 'package:dottoday/shared/sheets/anchored_popover.dart';
import 'package:flutter/material.dart';

export 'package:dottoday/shared/pickers/look/look_host.dart';

/// A task's colour and icon (M19.4 part 4c): Colour and icon on phones
/// (E-Phones, ED-086; E-Phones-3, ED-161), the popover on the Mac and the
/// web (E-G3-9b, ED-156), and the phone pages boxed on wide tablets
/// (E-R2-15, ED-298). Each pick is [onChanged] at once, so the task
/// behind recolours live. A popover points at [anchor], or at [context]'s
/// widget.
Future<void> showTaskLook(
  BuildContext context, {
  required TaskColor colour,
  required TaskIcon icon,
  required String title,
  required ValueChanged<TaskLook> onChanged,
  Rect? anchor,
}) => _open<void>(
  context,
  anchor: anchor,
  host: (maxHeight) => LookHost(
    colour: colour,
    icon: icon,
    title: title,
    start: LookPage.compact,
    onChanged: onChanged,
    maxHeight: maxHeight,
  ),
  popover: () => LookPopover(
    colour: colour,
    icon: icon,
    title: title,
    onChanged: onChanged,
  ),
);

/// The colour alone, for several tasks at once (the select bar's Colour;
/// owner, 4c-2): All colours with Done, or the popover where a pick
/// closes it. The colour, or null.
Future<TaskColor?> showColourOnly(
  BuildContext context, {
  TaskColor colour = TaskColor.fallback,
  Rect? anchor,
}) => _open<TaskColor>(
  context,
  anchor: anchor,
  host: (maxHeight) => LookHost(
    colour: colour,
    icon: TaskIcon.fallback,
    title: '',
    start: LookPage.colours,
    onChanged: null,
    maxHeight: maxHeight,
  ),
  popover: () => LookPopover(
    colour: colour,
    icon: TaskIcon.fallback,
    title: '',
    onChanged: null,
  ),
);

/// Where the picker opens: by width class, then the platform's container
/// (docs/10 §4: containers differ by platform, layout never does).
enum _LookHost { sheet, popover, ipad, dialog }

_LookHost _hostOf(BuildContext context) {
  final width = AppLayout.classOf(context);
  if (width == WidthClass.compact) return _LookHost.sheet;
  if (webChrome(context)) return _LookHost.popover;
  // Tablets keep the phone sheet until expanded (ED-298).
  final expanded = width == WidthClass.expanded;
  return switch (Theme.of(context).platform) {
    TargetPlatform.iOS => expanded ? _LookHost.ipad : _LookHost.sheet,
    TargetPlatform.android => expanded ? _LookHost.dialog : _LookHost.sheet,
    _ => _LookHost.popover,
  };
}

Future<T?> _open<T>(
  BuildContext context, {
  required Rect? anchor,
  required Widget Function(double? maxHeight) host,
  required Widget Function() popover,
}) {
  final at = _pointAt(context, anchor ?? globalRectOf(context));
  return switch (_hostOf(context)) {
    _LookHost.sheet => _sheet<T>(context, host(null)),
    _LookHost.popover => showAnchoredPopover<T>(
      context: context,
      anchor: at,
      width: DotLook.popover,
      builder: (_) => popover(),
    ),
    _LookHost.ipad => showAnchoredPopover<T>(
      context: context,
      anchor: at,
      width: DotLook.boxWidth,
      radius: DotRadii.tabletPopover,
      builder: (_) => host(DotLook.boxHeight),
    ),
    // Android has no popover: a centred M3 dialog (ED-298).
    _LookHost.dialog => showDialog<T>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: DotLook.boxWidth,
          child: Padding(
            padding: const EdgeInsets.only(top: DotSpace.l),
            child: host(DotLook.boxHeight),
          ),
        ),
      ),
    ),
  };
}

/// A popover points at [at] unless it is most of the window (a screen's
/// context rather than a dot's): then at the window's top end.
Rect? _pointAt(BuildContext context, Rect? at) {
  final window = MediaQuery.sizeOf(context);
  if (at == null || at.height > window.height / 2) return null;
  return at;
}

Future<T?> _sheet<T>(BuildContext context, Widget host) =>
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
