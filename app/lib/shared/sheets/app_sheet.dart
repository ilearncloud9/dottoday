import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Widest an [AppSheet] popover gets on large screens.
const double appSheetMaxWidth = 560;

/// Tallest a full-height popover gets on large screens.
const double appSheetMaxHeight = 760;

/// Share of the screen a full-height sheet covers (the editor's 94 %).
const double _fullHeightShare = 0.94;

/// Shows [builder]'s content as a bottom sheet on compact widths and as a
/// centred popover from [WidthClass.mediumFrom] up (docs/03 §3.3,
/// §6). Chosen by available width, never by platform.
///
/// Both dismiss with a swipe/tap outside/Esc and return [T] when popped
/// with a value.
///
/// [fullHeight] hands [builder] the whole sheet (94 % of the screen, or a
/// tall popover) with no [AppSheet] frame, for flows that pin their own
/// buttons to the bottom (Add, M3c).
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
}) {
  final size = MediaQuery.sizeOf(context);
  final wide = size.width >= WidthClass.mediumFrom;
  final Widget sheet = switch ((fullHeight, wide)) {
    (false, _) => AppSheet(
      title: title,
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
      builder: (_) => Dialog(
        // Its own width, not the theme's prompt cap (G2): 560, not 480.
        constraints: const BoxConstraints(
          minWidth: DotSize.dialogMin,
          maxWidth: appSheetMaxWidth,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(DotRadii.sheet)),
        ),
        child: sheet,
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
  const AppSheet({required this.child, this.title, super.key});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    final title = this.title;
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
              child: _TitleRow(title: title, style: t),
            ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.fromSTEB(
                DotSpace.l,
                title == null ? DotSpace.s : 0,
                DotSpace.l,
                DotSpace.xl,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title, required this.style});

  final String title;
  final DotTheme style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: DotSpace.m),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: style.styles.cardTitle),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: context.l10n.sheetClose,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
