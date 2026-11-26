import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/sheets/sheet_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Widest an [AppSheet] popover gets on large screens.
const double appSheetMaxWidth = 560;

/// Tallest a full-height popover gets on large screens.
const double appSheetMaxHeight = 760;

/// Share of the screen a full-height sheet covers (the editor's 94 %).
const double _fullHeightShare = 0.94;

/// Shows [builder]'s content as a bottom sheet on compact widths and as a
/// centred popover from [WidthClass.mediumFrom] up (docs/03 §3.3,
/// §6). Layout follows the width; on an iPhone a full-height sheet is
/// iOS's own card sheet (native pass).
///
/// Both dismiss with a swipe/tap outside/Esc and return [T] when popped
/// with a value.
///
/// [fullHeight] hands [builder] the whole sheet (94 % of the screen, or a
/// tall popover) with no [AppSheet] frame, for flows that pin their own
/// buttons to the bottom (Add, M3c).
///
/// [maxWidth] caps the dialog from medium width (560 unless a board says
/// otherwise).
///
/// ```dart
/// final picked = await showAppSheet<int>(
///   context: context,
///   title: l10n.durationLabel,
///   builder: (context) => DurationChips(...),
/// );
/// ```
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  bool fullHeight = false,
  bool scrolls = true,
  bool done = false,
  double maxWidth = appSheetMaxWidth,
}) {
  final size = MediaQuery.sizeOf(context);
  final wide = size.width >= WidthClass.mediumFrom;
  // iOS's own card sheet for a full-height sheet on iPhone (owner, native
  // pass): the screen behind recedes and the card drags down to close.
  // Half-height sheets keep their medium detent below, which iOS's card
  // sheet in Flutter doesn't have.
  if (fullHeight && !wide && iosApp(context)) {
    return showCupertinoSheet<T>(
      context: context,
      scrollableBuilder: (sheet, _) => Material(
        color: DotTheme.of(sheet).colors.sheet,
        child: SafeArea(top: false, child: Builder(builder: builder)),
      ),
    );
  }
  final Widget sheet = switch ((fullHeight, wide)) {
    (false, _) => AppSheet(
      title: title,
      scrolls: scrolls,
      done: done,
      child: Builder(builder: builder),
    ),
    (true, false) => FractionallySizedBox(
      heightFactor: _fullHeightShare,
      child: Builder(builder: builder),
    ),
    (true, true) => SizedBox(
      height: math.min(appSheetMaxHeight, size.height * _fullHeightShare),
      child: Builder(builder: builder),
    ),
  };
  if (wide) {
    return showDialog<T>(
      context: context,
      builder: (dialog) => Dialog(
        // Its own width, not the theme's prompt cap (G2): 560, not 480.
        constraints: BoxConstraints(
          minWidth: DotSize.dialogMin,
          maxWidth: maxWidth,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(DotRadii.sheet)),
        ),
        // The dialog already sits above the keyboard: the sheet inside
        // must not make room for it again (M19.7: on an Android tablet in
        // landscape, Minimal Add's Add went under the keyboard).
        child: MediaQuery.removeViewInsets(
          context: dialog,
          removeBottom: true,
          child: sheet,
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    // Above the iPhone's floating tab bar, from any tab (found in the
    // M3f.10 sweep: Running late opened under it).
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(DotRadii.sheet)),
    ),
    builder: (_) => sheet,
  );
}

/// Content frame shared by the sheet and popover: optional title row with a
/// close button, always in view, over a padded scrollable body that stays
/// above the keyboard.
class AppSheet extends StatelessWidget {
  const AppSheet({
    required this.child,
    this.title,
    this.scrolls = true,
    this.done = false,
    super.key,
  });

  final String? title;

  /// "Done" instead of the cross in the title row ([SheetHeader.done]).
  final bool done;
  final Widget child;

  /// False for a body that scrolls itself and pins a foot under it
  /// (Minimal Add, M19.7): it gets the room left, not an endless column.
  final bool scrolls;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    final title = this.title;
    final pad = EdgeInsetsDirectional.fromSTEB(
      DotSpace.l,
      title == null ? DotSpace.s : 0,
      DotSpace.l,
      DotSpace.xl,
    );
    // The title row stays put and only the body scrolls: scrolled with it,
    // the close button slid under the drag handle, cut to 48×22 (CR-160
    // B7 gate, G1).
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: insets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                DotSpace.l,
                DotSpace.s,
                DotSpace.l,
                0,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(bottom: DotSpace.m),
                child: SheetHeader(
                  title: title,
                  done: done,
                  onClose: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          Flexible(
            child: scrolls
                ? SingleChildScrollView(padding: pad, child: child)
                : Padding(padding: pad, child: child),
          ),
        ],
      ),
    );
  }
}
