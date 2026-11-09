import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/owners/account_meta.dart';
import 'package:dottoday/features/settings/pages/delete_account_parts.dart';
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
  late final Future<OwnerSummary> _summary = ref
      .read(accountActionsProvider)
      .summary(widget.owner);
  late final _typed = TextEditingController()..addListener(_changed);
  var _busy = false;
  OwnerExportOutcome? _exported;
  String? _error;

  void _changed() => setState(() {});

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  bool get _confirmed =>
      _typed.text.trim() == context.l10n.accountDeleteWord && !_busy;

  Future<void> _export(Rect? origin) async {
    setState(() {
      _busy = true;
      _exported = null;
      _error = null;
    });
    final outcome = await ref
        .read(accountActionsProvider)
        .exportFirst(widget.owner, origin: origin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _exported = outcome;
    });
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(accountActionsProvider).deleteAccount();
    if (!mounted) return;
    switch (result) {
      case Ok():
        navigator.pop();
      case Err(:final failure):
        setState(() {
          _busy = false;
          _error = failureMessage(l10n, failure);
        });
    }
  }

  String? _exportStatus(BuildContext context) {
    final l10n = context.l10n;
    return switch (_exported) {
      null => null,
      OwnerExportOutcome.done => l10n.accountDeleteExported,
      OwnerExportOutcome.cancelled => l10n.accountDeleteExportClosed,
      OwnerExportOutcome.failed => l10n.accountDeleteExportBroken,
    };
  }

  @override
  Widget build(BuildContext context) {
    final browser = ref.watch(inBrowserProvider);
    final parts = DeleteParts(
      browser: browser,
      wide: widget.wide,
      summary: _summary,
      typed: _typed,
      busy: _busy,
      exportStatus: _exportStatus(context),
      error: _error,
      onExport: (origin) => unawaited(_export(origin)),
      onCancel: () => Navigator.of(context).pop(),
      onDelete: _confirmed ? () => unawaited(_delete()) : null,
    );
    return widget.wide ? DeleteDialogLayout(parts) : DeletePageLayout(parts);
  }
}
