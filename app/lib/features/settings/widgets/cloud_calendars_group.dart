import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/error_handlers.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/calendar/cloud_calendar_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/calendar/cloud_calendar.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/widgets/calendar_rows.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings › Calendars › Google and Microsoft (docs/02 F5, docs/09 M7.4,
/// R-02, R-13): sign in first; then each connected account with its
/// calendars' switches and Disconnect (or Reconnect), and the two Connect
/// rows. The same on every platform, the web included.
class CloudCalendarsGroup extends ConsumerWidget {
  const CloudCalendarsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(cloudCalendarsProvider).available) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final signedIn = ref.watch(accountProvider).value is SignedIn;
    if (!signedIn) {
      return SettingsGroup(
        caption: l10n.calendarsOnline,
        children: [
          SettingsRow(
            glyph: DotGlyphs.person,
            tint: DotTheme.of(context).colors.accentInk,
            title: l10n.calendarsOnlineSignIn,
            onTap: () => unawaited(
              context.push(AppRoutes.settingsPage(SettingsPage.account)),
            ),
          ),
        ],
      );
    }
    final accounts = ref.watch(cloudAccountsProvider);
    if (accounts.hasError) {
      return ErrorState(
        error: unwrapProviderException(accounts.error!, null).$1,
        onRetry: () => ref.invalidate(cloudAccountsProvider),
      );
    }
    final choices = ref.watch(cloudCalendarChoiceListProvider).value ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.l,
      children: [
        for (final account in accounts.value ?? const <CloudAccount>[])
          _AccountGroup(
            account: account,
            choices: [
              for (final c in choices)
                if (account.calendars.contains(c.calendar)) c,
            ],
          ),
        const _ConnectGroup(),
        PageText(l10n.calendarsOnlineIntro),
      ],
    );
  }
}

/// One connected account: its calendars, then Reconnect or Disconnect.
class _AccountGroup extends ConsumerWidget {
  const _AccountGroup({required this.account, required this.choices});

  final CloudAccount account;
  final List<CalendarChoice> choices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final actions = ref.read(calendarActionsProvider);
    final cloud = ref.read(cloudCalendarActionsProvider);
    return SettingsGroup(
      caption: account.label,
      children: [
        for (final c in choices)
          CalendarChoiceRow(
            choice: c,
            onToggle: (on) => saveCalendarChange(
              context,
              actions.setEnabled(c.calendar, on: on),
            ),
          ),
        if (account.status == CloudAccountStatus.reconnect)
          SettingsRow(
            glyph: DotGlyphs.warning,
            tint: t.colors.accentInk,
            title: l10n.calendarsReconnect,
            subtitle: l10n.calendarsReconnectDetail,
            onTap: () =>
                saveCalendarChange(context, cloud.connect(account.provider)),
          ),
        if (account.status == CloudAccountStatus.failed)
          CalendarEmptyRow(title: l10n.calendarsUnreachable),
        SettingsRow(
          glyph: DotGlyphs.close,
          tint: t.colors.muted,
          title: l10n.calendarsDisconnect,
          onTap: () => unawaited(_disconnect(context, ref)),
        ),
      ],
    );
  }

  /// Confirmed first: its events leave every device (06 §9 "destructive
  /// actions are undoable or confirmed").
  Future<void> _disconnect(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final cloud = ref.read(cloudCalendarActionsProvider);
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.calendarsDisconnectTitle(account.label)),
        content: Text(l10n.calendarsDisconnectBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.editorCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.calendarsDisconnect),
          ),
        ],
      ),
    );
    if (sure != true || !context.mounted) return;
    saveCalendarChange(context, cloud.disconnect(account));
  }
}

/// "Connect Google Calendar", "Connect Microsoft Outlook".
class _ConnectGroup extends ConsumerWidget {
  const _ConnectGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tint = DotTheme.of(context).colors.accentInk;
    final l10n = context.l10n;
    final cloud = ref.read(cloudCalendarActionsProvider);
    SettingsRow row(String title, CalendarProvider provider) => SettingsRow(
      glyph: DotGlyphs.add,
      tint: tint,
      title: title,
      onTap: () => saveCalendarChange(context, cloud.connect(provider)),
    );
    return SettingsGroup(
      caption: l10n.calendarsOnline,
      children: [
        row(l10n.calendarsConnectGoogle, CalendarProvider.google),
        row(l10n.calendarsConnectMicrosoft, CalendarProvider.microsoft),
      ],
    );
  }
}
