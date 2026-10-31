import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/notifications/test_alarm.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/widgets/wake_up_alarm_row.dart';
import 'package:dottoday/features/settings/widgets/wake_up_option_groups.dart';
import 'package:dottoday/shared/notifications/test_alarm_card.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings › Wake Up alarm (docs/15 §9, M17.2; derived from
/// `SettingsGroup` rows): the switch with this device's tier and fix, then
/// sound and snooze while it is on, a real test alarm and Notification
/// health. Minimal mode shows the switch and the sound, with the rest
/// behind More options (15 §10).
class WakeUpPage extends ConsumerStatefulWidget {
  const WakeUpPage({super.key});

  @override
  ConsumerState<WakeUpPage> createState() => _WakeUpPageState();
}

class _WakeUpPageState extends ConsumerState<WakeUpPage> {
  /// Minimal mode's "More options", open for this visit only.
  var _more = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null) return const SizedBox.shrink();
    final minimal = watchSimplified(ref, FeatureId.wakeUpAlarm);
    final full = !minimal || _more;
    final alarm = ref.read(testAlarmProvider.notifier);
    return SettingsPageFrame(
      title: l10n.settingsWakeUpAlarm,
      children: [
        SettingsGroup(
          caption: l10n.wakeUpAlarmCaption,
          children: [WakeUpAlarmRow(on: settings.wakeUpAlarm)],
        ),
        if (settings.wakeUpAlarm) ...[
          WakeUpSoundGroup(settings: settings, full: full),
          if (full) WakeUpSnoozeGroup(settings: settings),
          if (!full)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => setState(() => _more = true),
                child: Text(l10n.wakeUpMoreOptions),
              ),
            ),
        ],
        TestAlarmCard(
          onSend: alarm.sendWakeUp,
          // A test alarm is meant to ring after the phone is locked, so
          // leaving the page keeps it.
          onCancel: () async {},
          now: ref.read(clockProvider).nowUtc,
          afterNo: l10n.wakeUpTestLookHere,
        ),
        SettingsGroup(
          caption: l10n.healthCaption,
          children: const [_HealthLink()],
        ),
      ],
    );
  }
}

class _HealthLink extends StatelessWidget {
  const _HealthLink();

  @override
  Widget build(BuildContext context) => SettingsRow(
    glyph: DotGlyphs.warning,
    tint: DotTheme.of(context).colors.accentInk,
    title: context.l10n.healthTitle,
    onTap: () => unawaited(
      context.push(AppRoutes.settingsPage(SettingsPage.notifications)),
    ),
  );
}
