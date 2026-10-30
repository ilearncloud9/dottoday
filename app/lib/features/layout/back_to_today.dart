import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Minimal phones have no tab bar (docs/14 §3 "Navigation bar / rail"):
/// a page reached from Today (the Later row's Inbox, Settings, Search)
/// gets "‹ Today" on top, and system Back goes there too. Off ([show]
/// false), the page is drawn as it is.
class BackToToday extends StatelessWidget {
  const BackToToday({
    required this.show,
    required this.onToday,
    required this.child,
    super.key,
  });

  final bool show;
  final VoidCallback onToday;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!show) return child;
    return LayoutBuilder(
      builder: (context, box) {
        if (WidthClass.of(box.maxWidth) != WidthClass.compact) return child;
        final t = DotTheme.of(context);
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (popped, _) {
            if (!popped) onToday();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: DotSpace.s),
                  child: TextButton.icon(
                    onPressed: onToday,
                    icon: DotIcon(
                      DotGlyphs.arrowLeft,
                      color: t.colors.accentInk,
                    ),
                    label: Text(context.l10n.navToday),
                  ),
                ),
              ),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
