import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/recurrence/series_actions.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/domain/recurrence/series_edit.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
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
  final series = task.series;
  if (series == null) return true;
  final change = SeriesChange.between(
    opened,
    draft,
    tz.getLocation(draft.tzId),
  );
  if (change.isEmpty) return true;
  final container = ProviderScope.containerOf(context);
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final scope = await showScopeSheet(context, delete: false);
  if (scope == null) return false;
  if (scope == EditScope.thisOne) return true;
  final result = await editSeries(
    container,
    series: series,
    target: draft,
    change: change,
    scope: scope,
  );
  _report(
    messenger,
    l10n,
    container.read(undoServiceProvider),
    result,
    l10n.snackSeriesChanged(draft.title),
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
  final series = task.series;
  if (series == null) return (cancelled: false, done: false);
  final container = ProviderScope.containerOf(context);
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final scope = await showScopeSheet(context, delete: true);
  if (scope == null) return (cancelled: true, done: false);
  if (scope == EditScope.thisOne) return (cancelled: false, done: false);
  final result = await deleteSeries(
    container,
    series: series,
    target: target,
    scope: scope,
  );
  _report(
    messenger,
    l10n,
    container.read(undoServiceProvider),
    result,
    l10n.snackSeriesDeleted(target.title),
  );
  return (cancelled: false, done: true);
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
