import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "Notifications are off" (docs/03 §3.8 permission-denied: explain + a
/// way to system settings; docs/09 M3f.8, R-10). [onOpenSettings] returns
/// false where the app can't open them, and the notice then says where
/// to go instead.
class PermissionNotice extends StatelessWidget {
  const PermissionNotice({required this.onOpenSettings, super.key});

  final Future<bool> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.raised,
          borderRadius: BorderRadius.circular(DotRadii.card),
          border: Border.all(color: t.colors.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DotSpace.xs,
            children: [
              _Heading(text: l10n.notifDeniedTitle),
              Text(l10n.notifDeniedBody, style: t.styles.body),
              TextButton(
                onPressed: () => unawaited(_open(context)),
                child: Text(l10n.notifOpenSettings),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final path = context.l10n.notifSettingsPath;
    if (await onOpenSettings()) return;
    messenger.showSnackBar(SnackBar(content: Text(path)));
  }
}

/// 🔔 and "Notifications are off".
class _Heading extends StatelessWidget {
  const _Heading({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      spacing: DotSpace.s,
      children: [
        DotIcon(DotGlyphs.bell, color: t.colors.muted),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(text, style: t.styles.rowTitle),
          ),
        ),
      ],
    );
  }
}
