import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/in_app_alerts.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/shared/feedback/banner_strip.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A reminder shown inside the app (docs/07 Web "in-app banners while
/// open", docs/09 M5.3): the newest one — a task's with Done and Snooze
/// 10 min (docs/02 F6.4, M8.4d: the web's way to snooze, since Chrome
/// keeps two system actions, Done and Open), Bedtime's and the day-start
/// summary's with Open and Later. Nothing when there is none.
class InAppAlertBanner extends ConsumerWidget {
  const InAppAlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(inAppAlertsProvider);
    if (alerts.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final n = alerts.last;
    // Null is "Later": dismiss only, not a snooze.
    void act(NotificationAction? action) {
      ref.read(inAppAlertsProvider.notifier).dismiss(n.id);
      if (action == null) return;
      unawaited(
        ref
            .read(notificationResponderProvider)
            .handle(
              NotificationTap(
                id: n.id,
                actionId: action.name,
                payload: n.payload,
              ),
            ),
      );
    }

    // The test alarm has nothing to open or do later: one OK (M6.5.9).
    final testAlarm =
        decodeNotificationPayload(n.id, n.payload)?.purpose ==
        NotificationPurpose.testAlarm;
    if (testAlarm) {
      return BannerStrip(
        glyph: DotGlyphs.bell,
        emphasis: true,
        text: l10n.inAppAlertText(n.title, n.body),
        actions: [(l10n.inAppAlertOk, () => act(null))],
      );
    }
    return BannerStrip(
      glyph: DotGlyphs.bell,
      emphasis: true,
      text: l10n.inAppAlertText(n.title, n.body),
      actions: n.withActions
          ? [
              (l10n.notifActionDone, () => act(NotificationAction.done)),
              (l10n.notifActionSnooze, () => act(NotificationAction.snooze)),
            ]
          : [
              (l10n.notifActionOpen, () => act(NotificationAction.open)),
              (l10n.inAppAlertLater, () => act(null)),
            ],
    );
  }
}
