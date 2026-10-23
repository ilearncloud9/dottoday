import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Notification health (M6.5.8): "All good" or "2 things to fix".
class HealthSummaryRow extends ConsumerWidget {
  const HealthSummaryRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final checks = ref.watch(notificationHealthChecksProvider).value;
    // Nothing claimed until the OS has answered.
    final problems = checks == null ? null : healthProblems(checks);
    return SettingsRow(
      glyph: switch (problems) {
        null => DotGlyphs.bell,
        0 => DotGlyphs.check,
        _ => DotGlyphs.warning,
      },
      tint: switch (problems) {
        null => t.colors.muted,
        0 => t.colors.success,
        _ => t.colors.accentInk,
      },
      title: l10n.healthTitle,
      value: switch (problems) {
        null => null,
        0 => l10n.healthAllGood,
        final n => l10n.healthToFix(n),
      },
      onTap: () => unawaited(
        context.push(AppRoutes.settingsPage(SettingsPage.notifications)),
      ),
    );
  }
}
