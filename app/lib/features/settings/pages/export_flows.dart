import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/picked_import.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/features/settings/widgets/export_set_sheet.dart';
import 'package:dottoday/features/settings/widgets/import_set_sheet.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

// Settings › Export's three flows (docs/09 M8.1, R-11): export a format,
// import a JSON backup, go back to a backup on this device. Each one runs
// only on the person's tap, says what it is about to replace before it
// does, and offers Undo (the safety backup taken first) afterwards.

/// Builds [format]'s files and hands them to the share sheet / save dialog.
Future<void> exportAs(BuildContext context, ExportFormat format) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final origin = _originOf(context);
  final profile = await readProfile(container);
  // Over one part, JSON is a set (CR-160 B7, owner: automatic).
  if (format == ExportFormat.json) {
    final version = await container.read(appVersionProvider.future);
    final set = await container
        .read(exportServiceProvider)
        .prepareSet(profile.id, appVersion: version);
    switch (set) {
      case Ok(value: final PreparedSet value):
        if (context.mounted) await handOverSet(context, value, origin);
        return;
      case Ok(value: FitsOneFile()):
        break; // today's single file, below
      case Err(:final failure):
        _say(messenger, failureMessage(l10n, failure));
        return;
    }
  }
  final built = await container
      .read(exportServiceProvider)
      .build(profile.id, format);
  final List<ExportFile> files;
  switch (built) {
    case Ok(:final value):
      files = value;
    case Err(:final failure):
      _say(messenger, failureMessage(l10n, failure));
      return;
  }
  try {
    final outcome = await container
        .read(fileGatewayProvider)
        .deliver(files, origin: origin);
    if (outcome == DeliveryOutcome.delivered) _say(messenger, l10n.exportDone);
  } on Exception catch (e, st) {
    container
        .read(loggerProvider)
        .error(
          'export.hand_off_failed', // l10n-ignore: log event, never shown
          fields: {'format': format}, // l10n-ignore: log field key
          error: e,
          stackTrace: st,
        );
    _say(messenger, l10n.exportHandOffFailed);
  }
}

/// Picks a backup (one JSON v1 file, or the files of a set: CR-160 B7b),
/// shows what it holds and that it replaces what is here, then imports it
/// (after a pre-import backup, M2.4). A set missing files is gathered in
/// "Add the rest of this backup" first.
Future<void> importBackup(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final files = await container.read(fileGatewayProvider).pickJsonFiles();
  if (files.isEmpty) return;
  final picked = await addPicked(null, files);
  final DateTime exportedAt;
  final int tasks;
  final Future<Result<void, AppFailure>> Function(String owner) run;
  final backups = container.read(backupServiceProvider);
  switch (picked) {
    case PickRefused(:final reason):
      _say(messenger, pickRefusalText(l10n, reason));
      return;
    case PickedSingle(:final text, :final bundle):
      exportedAt = bundle.exportedAt;
      tasks = bundle.occurrences.where((o) => o.deletedAt == null).length;
      run = (owner) => backups.importJson(owner, text);
    case PickedSet(:final draft):
      if (!draft.complete) {
        if (!context.mounted) return;
        if (await showImportSetSheet(context, draft) == null) return;
      }
      exportedAt = DateTime.fromMillisecondsSinceEpoch(
        draft.manifest!.exportedAtMs,
        isUtc: true,
      );
      tasks = draft.liveTasks!;
      run = (owner) =>
          backups.importSet(owner, draft.manifestText!, draft.readers);
  }
  final profile = await readProfile(container);
  if (!context.mounted) return;
  final yes = await _confirm(
    context,
    title: l10n.exportImportTitle,
    body: l10n.exportImportBody(
      _date(exportedAt, profile.tzId, DateFormat.yMMMd(locale)),
      tasks,
    ),
    action: l10n.exportImportAction,
  );
  if (!yes) return;
  final result = await run(profile.id);
  container.invalidate(backupListProvider);
  _afterReplace(
    container,
    messenger,
    l10n,
    result,
    l10n.exportImported,
    BackupReason.preImport,
  );
}

/// Restores backup [info] from this device, after confirming.
Future<void> restoreBackup(BuildContext context, BackupInfo info) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final profile = await readProfile(container);
  if (!context.mounted) return;
  final yes = await _confirm(
    context,
    title: l10n.exportRestoreTitle,
    body: l10n.exportRestoreBody(
      backupLabel(info.createdAtUtc, profile.tzId, locale),
    ),
    action: l10n.exportRestoreAction,
  );
  if (!yes) return;
  final backups = container.read(backupServiceProvider);
  final result = await backups.restore(profile.id, info.id);
  container.invalidate(backupListProvider);
  _afterReplace(
    container,
    messenger,
    l10n,
    result,
    l10n.exportRestored,
    BackupReason.preRestore,
  );
}

/// "Oct 24, 2026, 9:12 AM" in the profile's zone.
String backupLabel(DateTime utc, String tzId, String locale) =>
    _date(utc, tzId, DateFormat.yMMMd(locale).add_jm());

/// Says how a replace went; on success Undo goes back to the safety
/// backup ([safety]) the replace just took.
void _afterReplace(
  ProviderContainer container,
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  Result<void, AppFailure> result,
  String done,
  BackupReason safety,
) {
  if (result case Err(:final failure)) {
    _say(messenger, failureMessage(l10n, failure));
    return;
  }
  showUndoSnackbarOn(
    messenger,
    l10n,
    message: done,
    onUndo: () => unawaited(_undo(container, messenger, l10n, safety)),
  );
}

Future<void> _undo(
  ProviderContainer container,
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  BackupReason safety,
) async {
  final backups = container.read(backupServiceProvider);
  final latest = (await backups.list())
      .where((b) => b.reason == safety)
      .firstOrNull;
  if (latest == null) return;
  final profile = await readProfile(container);
  final result = await backups.restore(profile.id, latest.id);
  container.invalidate(backupListProvider);
  if (result case Err(:final failure)) {
    _say(messenger, failureMessage(l10n, failure));
  }
}

String _date(DateTime utc, String tzId, DateFormat format) {
  final zone = tz.timeZoneDatabase.locations[tzId] ?? tz.UTC;
  return format.format(tz.TZDateTime.from(utc, zone));
}

/// Where the iPad / Mac share popover points: the page.
Rect? _originOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Replaces any snackbar showing, so the answer to this tap is seen now.
void _say(ScaffoldMessengerState messenger, String text) => messenger
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final l10n = context.l10n;
  final yes = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog, false),
          child: Text(l10n.exportCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialog, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return yes ?? false;
}
