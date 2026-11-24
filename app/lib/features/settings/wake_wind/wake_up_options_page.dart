import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/widgets/wake_up_card_group.dart';
import 'package:dottoday/features/settings/widgets/wake_up_check_group.dart';
import 'package:dottoday/shared/learning/wake_up_explain_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wake Up and Wind Down › Wake Up options (E-R2-32, ED-337; E-R2-38,
/// ED-344): How it works above the groups, then the Morning card (with
/// the built card rows, owner 2026-11-24) and Check I've started. Reached
/// from Reminders' Wake Up card and Check I've started rows, and from
/// minimal Settings (E-PhonesMinimal). Minimal mode shows the switches,
/// with the rest behind More options (docs/15 §10). On a Mac or the web
/// it says the switches ring on the phone and sync (15 §11).
class WakeUpOptionsPage extends ConsumerStatefulWidget {
  const WakeUpOptionsPage({super.key});

  @override
  ConsumerState<WakeUpOptionsPage> createState() => _WakeUpOptionsState();
}

class _WakeUpOptionsState extends ConsumerState<WakeUpOptionsPage> {
  /// Minimal mode's "More options", open for this visit only.
  var _more = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null) return const SizedBox.shrink();
    final minimal = watchSimplified(ref, FeatureId.wakeUpAlarm);
    final full = !minimal || _more;
    final caps = ref.watch(alarmCapabilitiesNowProvider).value;
    final desktop = caps?.blockers.contains(AlarmBlocker.notAPhone) ?? false;
    return SettingsPageFrame(
      title: l10n.settingsWakeUpOptions,
      page: SettingsPage.wakeUp,
      children: [
        if (desktop) PageText(l10n.wakeUpDesktopNote),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: () => unawaited(showWakeUpExplainSheet(context)),
            child: Text(l10n.wakeUpHowItWorks),
          ),
        ),
        WakeUpCardGroup(settings: settings, full: full),
        // The check runs only with the alarm (15 W3); while it is off the
        // group waits (owner 2026-11-24).
        if (full && settings.wakeUpAlarm) WakeUpCheckGroup(settings: settings),
        if (!full)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => setState(() => _more = true),
              child: Text(l10n.wakeUpMoreOptions),
            ),
          ),
      ],
    );
  }
}
