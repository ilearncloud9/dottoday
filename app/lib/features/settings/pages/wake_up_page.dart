import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/notifications/test_alarm.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/widgets/mission_group.dart';
import 'package:dottoday/features/settings/widgets/wake_up_alarm_row.dart';
import 'package:dottoday/features/settings/widgets/wake_up_card_group.dart';
import 'package:dottoday/features/settings/widgets/wake_up_check_group.dart';
import 'package:dottoday/features/settings/widgets/wake_up_option_groups.dart';
import 'package:dottoday/shared/learning/wake_up_explain_sheet.dart';
import 'package:dottoday/shared/notifications/test_alarm_card.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings › Day shape › Wake Up options (docs/15 §9, M17.2–M17.3;
/// derived from `SettingsGroup` rows): the alarm switch with this device's
/// tier and fix, sound, snooze, the check and missions (15 §8) while it is
/// on, the Morning card, a real test alarm and Notification health. Minimal
/// mode shows the two switches and the sound, with the rest behind More
/// options (15 §10). The header links How it works; on a Mac or the web it
/// says the switches ring on the phone and sync (15 §11).
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
    final caps = ref.watch(alarmCapabilitiesNowProvider).value;
    final desktop = caps?.blockers.contains(AlarmBlocker.notAPhone) ?? false;
    return SettingsPageFrame(
      title: l10n.settingsWakeUpOptions,
      children: [
        if (desktop) PageText(l10n.wakeUpDesktopNote),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: () => unawaited(showWakeUpExplainSheet(context)),
            child: Text(l10n.wakeUpHowItWorks),
          ),
        ),
        SettingsGroup(
          caption: l10n.wakeUpAlarmCaption,
          children: [WakeUpAlarmRow(on: settings.wakeUpAlarm)],
        ),
        if (settings.wakeUpAlarm) ...[
          WakeUpSoundGroup(settings: settings, full: full),
          if (full) WakeUpSnoozeGroup(settings: settings),
          if (full) WakeUpCheckGroup(settings: settings),
          MissionGroup(settings: settings, full: full),
        ],
        WakeUpCardGroup(settings: settings, full: full),
        if (!full)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => setState(() => _more = true),
              child: Text(l10n.wakeUpMoreOptions),
            ),
          ),
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
