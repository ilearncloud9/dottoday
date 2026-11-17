import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The Undo toast's body (E-R2-7, ED-280/281): the words and one action,
/// on the toast surface from the theme. It runs its own [window], with no
/// visible countdown:
///
/// - the window waits while the pointer rests on it or focus is inside;
/// - with a screen reader on it stays until dismissed, and shows Close;
/// - Escape closes it;
/// - if the window ends while it is held, it says [expired] ("too late")
///   with Close only, never a dead action.
///
/// [onClose] hides it; the caller's messenger owns the snackbar.
class UndoToast extends StatefulWidget {
  const UndoToast({
    required this.message,
    required this.action,
    required this.onAction,
    required this.onClose,
    required this.window,
    this.expired,
    super.key,
  });

  final String message;
  final String action;
  final VoidCallback onAction;
  final VoidCallback onClose;
  final Duration window;

  /// What it says once [window] ended while held; null closes instead.
  final String? expired;

  @override
  State<UndoToast> createState() => _UndoToastState();
}

class _UndoToastState extends State<UndoToast> {
  Timer? _timer;
  var _hovered = false;
  var _focused = false;
  var _expired = false;

  bool get _reader => MediaQuery.accessibleNavigationOf(context);
  bool get _held => _hovered || _focused || _reader;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.window, _timeUp);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _timeUp() {
    if (!mounted) return;
    if (!_held) return widget.onClose();
    if (widget.expired == null) return;
    setState(() => _expired = true);
  }

  /// Let go after the window ended: it closes now.
  void _release() {
    if (!_held && (_expired || !(_timer?.isActive ?? false))) {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final text = _expired ? widget.expired! : widget.message;
    final close = _reader || _expired;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
      },
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (f) {
          _focused = f;
          _release();
        },
        child: MouseRegion(
          onEnter: (_) => _hovered = true,
          onExit: (_) {
            _hovered = false;
            _release();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: DotSize.toast - DotSpace.s,
            ),
            child: Row(
              spacing: DotSpace.s,
              children: [
                Expanded(child: Text(text)),
                if (!_expired)
                  TextButton(
                    onPressed: () {
                      widget.onAction();
                      widget.onClose();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: c.toastAction,
                      minimumSize: const Size(DotTouch.min, DotTouch.min),
                      textStyle: DotType.emphasis(
                        t.styles.toast,
                        bold: true,
                        italic: false,
                      ),
                    ),
                    child: Text(widget.action),
                  ),
                if (close)
                  IconButton(
                    onPressed: widget.onClose,
                    tooltip: context.l10n.sheetClose,
                    icon: DotIcon(DotGlyphs.close, color: c.onToast),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
