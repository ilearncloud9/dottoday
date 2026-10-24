import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "Notifications are off" / "Calendar access is off" (docs/03 §3.8
/// permission-denied: explain + a way to system settings; docs/09 M3f.8
/// and M7.1, R-10, R-02). [onOpenSettings] returns false where the app
/// can't open them, and the notice then says where to go instead.
class PermissionNotice extends StatelessWidget {
  const PermissionNotice({
    required this.onOpenSettings,
    this.permission = AppPermission.notifications,
    super.key,
  });

  final Future<bool> Function() onOpenSettings;
  final AppPermission permission;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final calendar = permission == AppPermission.calendar;
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
              _Heading(
                glyph: calendar ? DotGlyphs.calendar : DotGlyphs.bell,
                text: calendar
                    ? l10n.calendarDeniedTitle
                    : l10n.notifDeniedTitle,
              ),
              Text(
                calendar ? l10n.calendarDeniedBody : l10n.notifDeniedBody,
                style: t.styles.body,
              ),
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
    final path = permission == AppPermission.calendar
        ? context.l10n.calendarSettingsPath
        : context.l10n.notifSettingsPath;
    if (await onOpenSettings()) return;
    messenger.showSnackBar(SnackBar(content: Text(path)));
  }
}

/// "Reminders may come a few minutes late" (docs/07 Android, M5.6): exact
/// alarms aren't allowed, so reminders fall back to inexact timing. One
/// button opens the system screen; the caller re-checks afterwards.
class ExactAlarmNotice extends StatelessWidget {
  const ExactAlarmNotice({required this.onAllow, super.key});

  final VoidCallback onAllow;

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
              _Heading(glyph: DotGlyphs.bell, text: l10n.exactTitle),
              Text(l10n.exactBody, style: t.styles.body),
              TextButton(onPressed: onAllow, child: Text(l10n.exactAllow)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔔 and "Notifications are off".
class _Heading extends StatelessWidget {
  const _Heading({required this.glyph, required this.text});

  final DotGlyph glyph;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      spacing: DotSpace.s,
      children: [
        DotIcon(glyph, color: t.colors.muted),
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
