import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/recurrence/series_actions.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/calendar/calendar_series_sender.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/domain/recurrence/series_edit.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/timeline/editor/calendar_delete_sheet.dart';
import 'package:dottoday/features/timeline/editor/editor_scope.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/pickers/alerts/alerts_editor.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_editor.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_text.dart';
import 'package:dottoday/shared/pickers/repeat/scope_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

// The editor's repeat and scope steps (docs/09 M3f.1, R-01): pick a rule,
// then write it; on Save or Delete of a repeating task, ask which ones.

/// The rule [task]'s series follows, with its end; null when one-off.
RepeatRule? currentRule(TaskView task) {
  final s = task.series;
  if (s == null) return null;
  final end = s.count != null
      ? EndsAfter(s.count!)
      : s.untilUtc != null
      ? EndsOn(_localDay(tz.getLocation(s.tzId), s.untilUtc!))
      : const EndsNever();
  return RepeatRule.parse(s.rrule, end: end);
}

/// The Repeat row: the editor, then start, stop or change the repeat.
Future<void> pickRepeat(
  BuildContext context, {
  required TaskView task,
  required Occurrence draft,
}) async {
  final start = draft.startUtc;
  if (start == null) return;
  final container = ProviderScope.containerOf(context);
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final messenger = ScaffoldMessenger.of(context);
  final day = _localDay(tz.getLocation(draft.tzId), start);
  final today = container.read(todayDateProvider).value ?? day;
  final first = container.read(currentProfileProvider).value?.settings;
  final initial = currentRule(task);
  final picked = await showRepeatEditor(
    context,
    initial: initial,
    start: day,
    today: today,
    firstDayOfWeek: first?.firstDayOfWeek ?? 1,
  );
  if (picked == null || picked.rule == initial || !context.mounted) return;
  final rule = picked.rule;
  final series = task.series;
  final Future<Result<UndoToken, AppFailure>>? write = switch ((series, rule)) {
    (null, final r?) => startRepeating(container, o: draft, rule: r),
    (final s?, null) => stopRepeating(container, series: s, target: draft),
    (final s?, final r?) => switch (await showScopeSheet(
      context,
      delete: false,
      scopes: const [EditScope.following, EditScope.all],
    )) {
      final scope? => editSeries(
        container,
        series: s,
        target: draft,
        change: SeriesChange(rule: r),
        scope: scope,
      ),
      null => null,
    },
    (null, null) => null,
  };
  if (write == null) return;
  _report(
    messenger,
    l10n,
    container.read(undoServiceProvider),
    await write,
    rule == null
        ? l10n.snackRepeatStopped(draft.title)
        : l10n.snackRepeatSet(
            draft.title,
            repeatRuleText(l10n, locale, rule, day).toLowerCase(),
          ),
  );
}

/// Opens [pickAlerts] for the editor's [draft]; [edit] keeps "this one".
VoidCallback alertsRowTap(
  BuildContext context,
  TaskView task,
  Occurrence draft,
  void Function(Occurrence Function(Occurrence)) edit,
) =>
    () => unawaited(
      pickAlerts(
        context,
        task: task,
        draft: draft,
        onOwn: (a) => edit((o) => o.copyWith(alerts: a)),
      ),
    );

/// The Alerts row (M3f.2, R-10): the editor, then the alerts on this row
/// ([onOwn], saved with the other edits) or, for a repeating task, on the
/// instances the user picks. The Wind Down switch writes Settings at once.
Future<void> pickAlerts(
  BuildContext context, {
  required TaskView task,
  required Occurrence draft,
  required ValueChanged<List<Alert>> onOwn,
}) async {
  final container = ProviderScope.containerOf(context);
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final settings = container.read(currentProfileProvider).value?.settings;
  final permission = container.read(notificationPermissionProvider);
  final denied = await permission.status() == PermissionState.denied;
  if (!context.mounted) return;
  final picked = await showAlertsEditor(
    context,
    initial: task.alerts,
    deniedOpenSettings: denied ? permission.openSettings : null,
    windDown: settings?.windDownReminder ?? false,
    onWindDown: (on) => unawaited(
      updateSettings(container, (s) => s.copyWith(windDownReminder: on)),
    ),
  );
  if (picked == null || _same(picked, task.alerts) || !context.mounted) return;
  if (!task.repeats) return onOwn(picked);
  final scope = await showScopeSheet(
    context,
    delete: false,
    scopes: scopesFor(task),
  );
  if (scope == null) return;
  if (scope == EditScope.thisOne) return onOwn(picked);
  final write = writeScoped(
    container,
    task: task,
    target: draft,
    change: SeriesChange(alerts: picked),
    scope: scope,
  );
  if (write == null) return;
  _report(
    messenger,
    l10n,
    container.read(undoServiceProvider),
    (await write).result,
    l10n.snackAlertsSaved(draft.title),
  );
}

bool _same(List<Alert> a, List<Alert> b) =>
    a.length == b.length && a.indexed.every((e) => b[e.$1] == e.$2);

/// Save on a repeating task whose shared fields changed: which ones it
/// applies to. True when written (or nothing to ask), false if cancelled.
/// [opened] is the instance as the editor opened it (the live view has
/// the autosaved row by now). The row itself is already saved, so "This
/// one" is done.
Future<bool> saveScoped(
  BuildContext context, {
  required TaskView task,
  required Occurrence opened,
  required Occurrence draft,
}) async {
  if (!task.repeats) return true;
  final change = SeriesChange.between(
    opened,
    draft,
    tz.getLocation(draft.tzId),
  );
  if (change.isEmpty) return true;
  final container = ProviderScope.containerOf(context);
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final scope = await showScopeSheet(
    context,
    delete: false,
    scopes: scopesFor(task),
  );
  if (scope == null) return false;
  if (scope == EditScope.thisOne) return true;
  final write = writeScoped(
    container,
    task: task,
    target: draft,
    change: change,
    scope: scope,
  );
  if (write == null) return true;
  final (:result, :calendar) = await write;
  final name = calendar == SeriesSend.failed
      ? await _calendarName(container, draft)
      : null;
  _report(
    messenger,
    l10n,
    container.read(undoServiceProvider),
    result,
    name != null
        ? l10n.snackSeriesNotSent(name)
        : l10n.snackSeriesChanged(draft.title),
  );
  return true;
}

/// Delete of a repeating task beyond this one: which ones. Null = this
/// one only (the caller's own path) or cancelled ([cancelled] is set).
Future<({bool cancelled, bool done})> deleteScoped(
  BuildContext context, {
  required TaskView task,
  required Occurrence target,
}) async {
  if (!task.repeats) return (cancelled: false, done: false);
  final container = ProviderScope.containerOf(context);
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final scope = await showScopeSheet(
    context,
    delete: true,
    scopes: scopesFor(task),
  );
  if (scope == null) return (cancelled: true, done: false);
  if (scope == EditScope.thisOne) return (cancelled: false, done: false);
  if (!context.mounted) return (cancelled: true, done: false);
  final calendar = task.imported == null
      ? ''
      : await askDeleteFromCalendar(context, container, target);
  if (calendar == null) return (cancelled: true, done: false);
  final write = deleteScopedWrite(
    container,
    task: task,
    target: target,
    scope: scope,
  );
  if (write == null) return (cancelled: false, done: false);
  final result = await write;
  _report(
    messenger,
    l10n,
    container.read(undoServiceProvider),
    result,
    result is Ok && calendar.isNotEmpty
        ? await deleteFromCalendar(l10n, container, target, calendar)
        : l10n.snackSeriesDeleted(target.title),
  );
  return (cancelled: false, done: true);
}

/// The name of [o]'s calendar, or null for a task made here.
Future<String?> _calendarName(ProviderContainer ref, Occurrence o) async {
  final linkId = o.calendarLinkId;
  if (linkId == null) return null;
  return (await ref.read(calendarWriteStatusProvider(linkId).future))?.calendar;
}

void _report(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  UndoService undo,
  Result<UndoToken, AppFailure> result,
  String message,
) => reportUndoable(
  messenger,
  l10n,
  undo,
  result,
  message: (_) => message,
  tokenOf: (t) => t,
);

DateTime _localDay(tz.Location zone, DateTime utc) {
  final w = utcToWallClock(zone, utc);
  return DateTime(w.year, w.month, w.day);
}
