import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/error_handlers.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/feedback/permission_notice.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Calendars (docs/02 F5, docs/09 M7.1, R-02): connect the
/// device calendars (explain, then the OS prompt; denied → explain + a
/// way to Settings), one switch per calendar in its inherited colour, and
/// whether shifting the day moves calendar events too.
class CalendarsPage extends ConsumerWidget {
  const CalendarsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    return SettingsPageFrame(
      title: l10n.settingsCalendars,
      children: [
        PageText(l10n.calendarsIntro),
        ..._source(context, ref),
        if (settings != null)
          SettingsGroup(
            caption: l10n.calendarsShifting,
            children: [
              SettingsRow(
                glyph: DotGlyphs.rollForward,
                tint: t.tasks[TaskColor.teal].ink,
                title: l10n.calendarsMoveEvents,
                subtitle: l10n.calendarsMoveEventsDetail,
                toggle: settings.includeCalendarInShift,
                onToggle: (v) => changeSettings(
                  context,
                  (s) => s.copyWith(includeCalendarInShift: v),
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// What this device can do about its calendars right now.
  List<Widget> _source(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final gateway = ref.watch(deviceCalendarGatewayProvider);
    if (!gateway.available) {
      return [
        const _NoneConnected(),
        const OutlinedButton(onPressed: null, child: _ConnectLabel()),
        PageText(l10n.calendarsComingSoon),
      ];
    }
    final connect = ref.read(calendarActionsProvider).connect;
    return switch (ref.watch(calendarPermissionStateProvider).value) {
      null => const [],
      PermissionState.notAsked => [
        const _NoneConnected(),
        PageText(l10n.calendarsAsk),
        OutlinedButton(
          onPressed: () => unawaited(connect()),
          child: const _ConnectLabel(),
        ),
      ],
      PermissionState.denied => [
        PermissionNotice(
          permission: AppPermission.calendar,
          onOpenSettings: gateway.openSettings,
        ),
      ],
      PermissionState.granted => const [_CalendarList()],
    };
  }
}

/// The device's calendars, grouped by account, each with its switch.
class _CalendarList extends ConsumerWidget {
  const _CalendarList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final choices = ref.watch(calendarChoiceListProvider);
    if (choices.hasError) {
      return ErrorState(
        error: unwrapProviderException(choices.error!, null).$1,
        onRetry: () => ref.invalidate(deviceCalendarsProvider),
      );
    }
    final list = choices.value;
    if (list == null) return const SizedBox.shrink();
    if (list.isEmpty) {
      return SettingsGroup(
        caption: l10n.calendarsConnected,
        children: [_EmptyRow(title: l10n.calendarsNoneOnDevice)],
      );
    }
    final groups = <String, List<CalendarChoice>>{};
    for (final c in list) {
      final account = c.calendar.accountName ?? l10n.calendarsOnDevice;
      (groups[account] ??= []).add(c);
    }
    final actions = ref.read(calendarActionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.l,
      children: [
        for (final MapEntry(key: account, value: rows) in groups.entries)
          SettingsGroup(
            caption: account,
            children: [
              for (final c in rows)
                _CalendarRow(
                  choice: c,
                  onToggle: (on) => _toggle(context, actions, c, on),
                ),
            ],
          ),
      ],
    );
  }
}

/// Stores the switch at once; a failed write says so.
void _toggle(
  BuildContext context,
  CalendarActions actions,
  CalendarChoice choice,
  bool on,
) {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  unawaited(
    actions.setEnabled(choice.calendar, on: on).then((result) {
      if (result case Err(:final failure)) {
        messenger.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
      }
    }),
  );
}

/// One calendar: its name in its inherited colour, and the switch.
class _CalendarRow extends StatelessWidget {
  const _CalendarRow({required this.choice, required this.onToggle});

  final CalendarChoice choice;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final calendar = choice.calendar;
    return SettingsRow(
      glyph: DotGlyphs.calendar,
      tint: t.tasks[TaskColor.fromKey(choice.colorKey)].ink,
      title: calendar.name,
      subtitle: calendar.readOnly ? context.l10n.calendarsReadOnly : null,
      toggle: choice.enabled,
      onToggle: onToggle,
    );
  }
}

/// "Connected": nothing yet.
class _NoneConnected extends StatelessWidget {
  const _NoneConnected();

  @override
  Widget build(BuildContext context) => SettingsGroup(
    caption: context.l10n.calendarsConnected,
    children: [_EmptyRow(title: context.l10n.calendarsNone)],
  );
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => SettingsRow(
    glyph: DotGlyphs.calendar,
    tint: DotTheme.of(context).colors.muted,
    title: title,
  );
}

class _ConnectLabel extends StatelessWidget {
  const _ConnectLabel();

  @override
  Widget build(BuildContext context) => Text(context.l10n.calendarsConnect);
}
