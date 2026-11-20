import 'package:flutter/material.dart';

/// Each platform's own text-editing menu (owner, native pass): iOS's real
/// edit menu (Cut, Copy, Paste, Look Up…) where Flutter can show it, from
/// iOS 16; elsewhere Flutter's adaptive toolbar, which is Android's own on
/// Android and follows the desktop on the Mac and the web. Pass it as every
/// text field's `contextMenuBuilder`.
Widget systemTextMenu(BuildContext context, EditableTextState state) {
  if (SystemContextMenu.isSupported(context)) {
    return SystemContextMenu.editableText(editableTextState: state);
  }
  return AdaptiveTextSelectionToolbar.editableText(editableTextState: state);
}
