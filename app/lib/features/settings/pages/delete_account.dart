import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/picked_set_check.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/data/notifications/reminder_refusal.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/owners/account_meta.dart';
import 'package:dottoday/features/settings/pages/delete_account_parts.dart';
import 'package:dottoday/features/settings/pages/delete_without_copy.dart';
import 'package:dottoday/features/settings/widgets/set_file_rows.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Delete account" (CR-160 policy §4, interim, every platform): a full
/// screen on phones (board `DeleteNative`), a dialog on wider windows
/// (`DeleteWeb`). Deleting removes the account and its copy here; the
/// only way to keep anything is "Export my data first", while signed in.
/// There is no "keep on this device" choice.
Future<void> deleteAccountFlow(BuildContext context, String owner) async {
  final wide =
      WidthClass.of(MediaQuery.sizeOf(context).width) != WidthClass.compact;
  if (wide) {
    await showDialog<void>(
      context: context,
      builder: (_) => DeleteAccountView(owner: owner, wide: true),
    );
    return;
  }
  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => DeleteAccountView(owner: owner, wide: false),
    ),
  );
}

/// D1 for [owner], as a page or ([wide]) a dialog.
class DeleteAccountView extends ConsumerStatefulWidget {
  const DeleteAccountView({required this.owner, required this.wide, super.key});

  final String owner;
  final bool wide;

  @override
  ConsumerState<DeleteAccountView> createState() => _DeleteAccountViewState();
}

/// A leaf: the summary, the typed word, the export's and deletion's state.
class _DeleteAccountViewState extends ConsumerState<DeleteAccountView> {
  late final AccountActions _actions;
  late final Future<OwnerSummary> _summary;
  late final _typed = TextEditingController()..addListener(_changed);
  var _busy = false;
  OwnerExportOutcome? _exported;

  /// Where the last export's share popover pointed, for "Try export again".
  Rect? _exportOrigin;
  String? _error;

  /// A reminder action refused while this dialog is open (CR-160 §4):
  /// said in the error line, below any deletion error ([_error] wins).
  AppFailure? _refusal;
  RefusalDialogs? _dialogs;

  void _changed() => setState(() {});

  @override
  void initState() {
    super.initState();
    _actions = ref.read(accountActionsProvider);
    _summary = _actions.summary(widget.owner);
    // Only the dialog: on phones D1 is a page and the SnackBar shows on it.
    if (widget.wide) {
      final dialogs = ref.read(refusalDialogsProvider)..opened();
      _dialogs = dialogs;
    }
  }

  @override
  void dispose() {
    // Actions queued for the account meanwhile apply again (CR-160 I7).
    _actions.endDeletion(widget.owner);
    _dialogs?.closed();
    _typed.dispose();
    super.dispose();
  }

  bool get _confirmed =>
      _typed.text.trim() == context.l10n.accountDeleteWord && !_busy;

  Future<void> _export(Rect? origin) async {
    _exportOrigin = origin;
    setState(() {
      _busy = true;
      _exported = null;
      _error = null;
      _refusal = null;
    });
    final outcome = await _actions.exportFirst(
      widget.owner,
      origin: origin,
      handOver: ref.read(inBrowserProvider) ? _downloads : null,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _exported = outcome;
    });
  }

  /// Web: a set's files, one Download each; handed over only once every
  /// file was asked for (CR-160 B7c, owner decision 2).
  Future<DeliveryOutcome> _downloads(List<PreparedFile> files) async {
    final asked = <String>{};
    if (!mounted) return DeliveryOutcome.cancelled;
    await showAppSheet<void>(
      context: context,
      title: context.l10n.exportDownloadTitle(files.length),
      builder: (_) => DownloadList(files: files, asked: asked),
    );
    return asked.length == files.length
        ? DeliveryOutcome.delivered
        : DeliveryOutcome.cancelled;
  }

  /// "Check my files…" while a set export is uncertain: a complete set
  /// makes it done.
  Widget? _exportCheck() {
    if (_exported != OwnerExportOutcome.uncertain) return null;
    return CheckFilesRow(
      count: _actions.exportFileCount(widget.owner) ?? 0,
      check: (picked) => _actions.checkExport(widget.owner, picked),
      onChecked: (answer) {
        if (answer is PickedSetComplete) {
          setState(() => _exported = OwnerExportOutcome.done);
        }
      },
    );
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _error = null;
      _refusal = null;
    });
    final result = await _actions.deleteAccount();
    if (!mounted) return;
    switch (result) {
      case Ok():
        // A refusal said here stays with this session: never said again
        // once the account is gone (CR-160 §4).
        navigator.pop();
      case Err(failure: final ReviewChangedFailure failure):
        // Something new arrived: the export no longer covers everything and
        // the typed word is asked again (CR-160 I7).
        _typed.clear();
        setState(() {
          _busy = false;
          _exported = null;
          _error = failureMessage(l10n, failure);
        });
      case Err(failure: ExportNotSavedFailure(:final retryable)):
        // The export left no saved copy: never consent by itself. Asked
        // separately; the choice holds for this review only.
        setState(() => _busy = false);
        await _withoutCopy(retry: retryable);
      case Err(:final failure):
        setState(() {
          _busy = false;
          _error = failureMessage(l10n, failure);
        });
    }
  }

  Future<void> _withoutCopy({required bool retry}) async {
    final choice = await confirmDeleteWithoutCopy(
      context,
      retry: retry,
      setFiles: _exported == OwnerExportOutcome.uncertain
          ? _actions.exportFileCount(widget.owner)
          : null,
    );
    if (!mounted) return;
    switch (choice) {
      case WithoutCopyChoice.delete:
        if (_actions.waiveExport(widget.owner)) await _delete();
      case WithoutCopyChoice.retry:
        await _export(_exportOrigin);
      case null:
    }
  }

  String? _refusalText(BuildContext context) => switch (_refusal) {
    final f? => failureMessage(context.l10n, f),
    null => null,
  };

  String? _exportStatus(BuildContext context) {
    final l10n = context.l10n;
    return switch (_exported) {
      null => null,
      OwnerExportOutcome.done => l10n.accountDeleteExported,
      OwnerExportOutcome.uncertain => l10n.accountDeleteExportUncertain(
        _actions.exportFileCount(widget.owner) ?? 0,
      ),
      OwnerExportOutcome.cancelled => l10n.accountDeleteExportClosed,
      OwnerExportOutcome.failed => l10n.accountDeleteExportBroken,
      OwnerExportOutcome.tooLarge => l10n.accountDeleteExportTooLarge,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wide) {
      ref.listen(reminderRefusalProvider, (_, r) {
        final refusals = ref.read(reminderRefusalProvider.notifier);
        if (r != null && refusals.current(r)) {
          setState(() => _refusal = r.failure);
        }
      });
    }
    final browser = ref.watch(inBrowserProvider);
    final parts = DeleteParts(
      browser: browser,
      wide: widget.wide,
      summary: _summary,
      typed: _typed,
      busy: _busy,
      exportStatus: _exportStatus(context),
      exportCheck: _exportCheck(),
      error: _error ?? _refusalText(context),
      onExport: (origin) => unawaited(_export(origin)),
      onCancel: () => Navigator.of(context).pop(),
      onDelete: _confirmed ? () => unawaited(_delete()) : null,
    );
    return widget.wide ? DeleteDialogLayout(parts) : DeletePageLayout(parts);
  }
}
