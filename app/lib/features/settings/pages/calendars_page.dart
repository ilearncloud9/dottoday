import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/error_handlers.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/calendar/cloud_calendar_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/features/settings/widgets/calendar_rows.dart';
import 'package:dottoday/features/settings/widgets/cloud_calendars_group.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/features/settings/widgets/travel_time_group.dart';
import 'package:dottoday/shared/feedback/permission_notice.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Calendars (docs/02 F5, docs/09 M7.1, R-02): connect the
/// device calendars (explain, then the OS prompt; denied → explain + a
/// way to Settings), one switch per calendar in its inherited colour,
/// Google and Microsoft accounts (M7.4, every platform), which calendars
/// get changes sent back (M7.3), whether shifting the day moves
/// calendar events too, and travel time before events with a place (M7.5).
class CalendarsPage extends ConsumerWidget {
  const CalendarsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    return SettingsPageFrame(
      title: l10n.settingsCalendars,
      page: SettingsPage.calendars,
      children: [
        PageText(l10n.calendarsIntro),
        ..._source(context, ref),
        if (ref.watch(cloudCalendarsProvider).available)
          const CloudCalendarsGroup(),
        ..._writeBack(context, ref),
        // Shifting and travel time only mean something once a calendar is
        // in (E-R2-24 §2 draws them only then, ED-497).
        if (settings != null && _anyCalendar(ref))
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
        if (settings != null && _anyCalendar(ref))
          TravelTimeGroup(settings: settings),
      ],
    );
  }

  /// Whether any calendar, on this device or connected, is listed.
  bool _anyCalendar(WidgetRef ref) =>
      (ref.watch(calendarChoiceListProvider).value?.isNotEmpty ?? false) ||
      (ref.watch(cloudCalendarChoiceListProvider).value?.isNotEmpty ?? false);

  /// What this device can do about its calendars right now.
  List<Widget> _source(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final gateway = ref.watch(deviceCalendarGatewayProvider);
    if (!gateway.available) {
      // The web: Google and Microsoft only; say so when neither is here.
      final cloud = ref.watch(cloudCalendarsProvider).available;
      return [if (!cloud) const _NoneConnected()];
    }
    final connect = ref.read(calendarActionsProvider).connect;
    return switch (ref.watch(calendarPermissionStateProvider).value) {
      null => const [],
      PermissionState.notAsked => [
        const _NoneConnected(),
        PageText(l10n.calendarsAsk),
        _ConnectPill(onPressed: () => unawaited(connect())),
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

  /// "Send changes back": every switched-on writable calendar, device and
  /// connected alike, each off until chosen (M7.3, M7.4).
  List<Widget> _writeBack(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final actions = ref.read(calendarActionsProvider);
    final writable = [
      for (final c in [
        ...?ref.watch(calendarChoiceListProvider).value,
        ...?ref.watch(cloudCalendarChoiceListProvider).value,
      ])
        if (c.enabled && !c.calendar.readOnly) c,
    ];
    if (writable.isEmpty) return const [];
    return [
      SettingsGroup(
        caption: l10n.calendarsWriteBack,
        children: [
          for (final c in writable)
            CalendarChoiceRow(
              choice: c,
              toggle: c.writeBack,
              onToggle: (on) => saveCalendarChange(
                context,
                actions.setWriteBack(c.calendar, on: on),
              ),
            ),
        ],
      ),
      PageText(l10n.calendarsWriteBackDetail),
    ];
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
        children: [CalendarEmptyRow(title: l10n.calendarsNoneOnDevice)],
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
                CalendarChoiceRow(
                  choice: c,
                  onToggle: (on) => saveCalendarChange(
                    context,
                    actions.setEnabled(c.calendar, on: on),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// "Connected": nothing yet.
class _NoneConnected extends StatelessWidget {
  const _NoneConnected();

  @override
  Widget build(BuildContext context) => SettingsGroup(
    caption: context.l10n.calendarsConnected,
    children: [CalendarEmptyRow(title: context.l10n.calendarsNone)],
  );
}

/// "Connect a calendar": a 40 outlined pill at the start, its words in the
/// accent (E-R2-24 §2, ED-497).
class _ConnectPill extends StatelessWidget {
  const _ConnectPill({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, CalendarsSize.pill),
          padding: const EdgeInsets.symmetric(
            horizontal: CalendarsSize.pillPad,
          ),
          shape: const StadiumBorder(),
          side: BorderSide(
            color: c.controlOutline,
            width: CalendarsSize.pillOutline,
          ),
          foregroundColor: c.accentInk,
          textStyle: t.styles.button.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontVariations: const [FontVariation.weight(600)],
          ),
        ),
        onPressed: onPressed,
        child: Text(context.l10n.calendarsConnect),
      ),
    );
  }
}
