import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "Notifications are off" / "Calendar access is off" (docs/03 §3.8
/// permission-denied: explain + a way to system settings; docs/09 M3f.8
/// and M7.1, R-10, R-02), drawn as E-R2-20 §3's amber notice.
/// [onOpenSettings] returns false where the app can't open them, and the
/// notice then says where to go instead.
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
    final l10n = context.l10n;
    final calendar = permission == AppPermission.calendar;
    return SettingsNotice(
      glyph: calendar ? DotGlyphs.calendar : DotGlyphs.bell,
      title: calendar ? l10n.calendarDeniedTitle : l10n.notifDeniedTitle,
      text: calendar ? l10n.calendarDeniedBody : l10n.notifDeniedBody,
      action: l10n.notifOpenSettings,
      onAction: () => unawaited(_open(context)),
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

/// "Reminders may come a few minutes after their time" (docs/07 Android,
/// M5.6; E-R2-20 §3): exact alarms aren't allowed, so reminders fall back
/// to inexact timing. One pill opens the system screen; the caller
/// re-checks afterwards.
class ExactAlarmNotice extends StatelessWidget {
  const ExactAlarmNotice({required this.onAllow, super.key});

  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsNotice(
      glyph: DotGlyphs.bell,
      title: l10n.exactTitle,
      text: l10n.exactBody,
      action: l10n.exactAllow,
      onAction: onAllow,
    );
  }
}

/// E-R2-20 §3's notice: an amber card (the Wake Up amber) with its title,
/// a sentence and one pill. iPhone puts the bell before the words; the
/// Material card has none, a 16 radius and a 40 pill. Amber says "look
/// here" without red (no-shame rule).
class SettingsNotice extends StatelessWidget {
  const SettingsNotice({
    required this.glyph,
    required this.title,
    required this.text,
    required this.action,
    required this.onAction,
    super.key,
  });

  final DotGlyph glyph;
  final String title;
  final String text;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final ios = DotIdiom.of(context) == DotIdiom.cupertino;
    final ink = c.wakeIcon;
    final words = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.xxs,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: t.styles.noticeTitle.copyWith(color: ink)),
        ),
        Text(text, style: t.styles.noticeText.copyWith(color: ink)),
        const SizedBox(height: DotSpace.s),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            backgroundColor: c.card,
            foregroundColor: ink,
            textStyle: t.styles.noticeAction,
            minimumSize: Size(
              0,
              ios ? DotSize.noticeAction : DotSize.noticeActionMaterial,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ios ? DotSpace.m + DotSpace.xxs : DotSpace.l,
            ),
            shape: const StadiumBorder(),
          ),
          child: Text(action),
        ),
      ],
    );
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.wakeCap,
          borderRadius: BorderRadius.circular(
            ios ? DotRadii.notice : DotRadii.noticeMaterial,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DotSpace.l,
            vertical: DotSpace.m + DotSpace.xxs,
          ),
          child: ios
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: DotSpace.s + DotSpace.xxs,
                  children: [
                    DotIcon(glyph, color: ink),
                    Expanded(child: words),
                  ],
                )
              : words,
        ),
      ),
    );
  }
}
