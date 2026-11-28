import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A pushed screen's top bar in each platform's own form (owner, native
/// pass): iOS's navigation bar on iPhone, iPad and the Mac, with the title
/// centred; Material 3's top app bar on Android and the web.
PreferredSizeWidget dotPageBar(
  BuildContext context, {
  required String title,
  Widget? leading,
  List<Widget> actions = const [],
}) {
  final t = DotTheme.of(context);
  if (appleApp(context)) {
    // The app's own chevron: Cupertino's Back draws from an icon font the
    // app doesn't ship.
    final canPop = Navigator.of(context).canPop();
    return CupertinoNavigationBar(
      leading:
          leading ??
          (canPop
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size.square(DotTouch.min),
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Semantics(
                    label: MaterialLocalizations.of(context).backButtonTooltip,
                    button: true,
                    excludeSemantics: true,
                    child: DotIcon(
                      DotGlyphs.chevronLeft,
                      color: t.colors.accentText,
                    ),
                  ),
                )
              : null),
      middle: Text(title, style: t.styles.rowTitle),
      trailing: actions.isEmpty
          ? null
          : Row(mainAxisSize: MainAxisSize.min, children: actions),
      backgroundColor: t.colors.ground,
      border: Border(bottom: BorderSide(color: t.colors.hairline)),
      automaticallyImplyLeading: false,
    );
  }
  return AppBar(title: Text(title), leading: leading, actions: actions);
}
