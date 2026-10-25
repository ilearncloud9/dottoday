import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// "Drop a routine…" in the Inbox header (11 C2 "drop via the Inbox",
/// M11.4): Routines, dropping on today.
class InboxRoutinesButton extends StatelessWidget {
  const InboxRoutinesButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return TextButton.icon(
      onPressed: () => unawaited(
        context.push(AppRoutes.settingsPage(SettingsPage.routines)),
      ),
      icon: DotIcon(
        DotGlyphs.repeat,
        color: t.colors.accentInk,
        size: DotSize.rowIcon,
      ),
      label: Text(context.l10n.routineDropHere),
    );
  }
}
