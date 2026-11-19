import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Shows [builder]'s content in an M3 modal side sheet (E-R2-3, ED-271:
/// Android tablets' New task): [DotSize.sideSheet] wide at the window's
/// end, full height, 28 corners on its leading edge, over the scrim. Back,
/// Esc or a tap on the scrim closes it; it returns [T] when popped with
/// one. Reduced motion shows it without the slide.
///
/// ```dart
/// await showModalSideSheet<void>(
///   context: context,
///   builder: (_) => CreateTaskSheet(request: request),
/// );
/// ```
Future<T?> showModalSideSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final t = DotTheme.of(context);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.sheetClose,
    barrierColor: t.colors.scrim,
    transitionDuration: t.motion.base,
    pageBuilder: (context, _, _) => _SideSheet(builder: builder),
    transitionBuilder: (context, animation, _, child) {
      final rtl = Directionality.of(context) == TextDirection.rtl;
      return SlideTransition(
        position: Tween(
          begin: Offset(rtl ? -1 : 1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: t.motion.curve)),
        child: child,
      );
    },
  );
}

class _SideSheet extends StatelessWidget {
  const _SideSheet({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width < DotSize.sideSheet
        ? size.width
        : DotSize.sideSheet;
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: SizedBox(
        width: width,
        height: size.height,
        child: DecoratedBox(
          decoration: const BoxDecoration(boxShadow: DotElevation.floating),
          child: Material(
            color: t.colors.sheet,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.horizontal(
                start: Radius.circular(DotRadii.sheet),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              left: false,
              right: false,
              child: Semantics(
                scopesRoute: true,
                namesRoute: true,
                explicitChildNodes: true,
                child: Builder(builder: builder),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
