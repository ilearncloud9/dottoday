import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/export/picked_import.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Add the rest of this backup" (CR-160 B7b): while some files of a
/// multipart backup are missing, says how many are in and picks more.
/// Returns [draft] once every file is in and the set checked whole; null
/// when the sheet was closed first.
Future<SetDraft?> showImportSetSheet(BuildContext context, SetDraft draft) =>
    showAppSheet<SetDraft>(
      context: context,
      title: context.l10n.importAddTitle,
      builder: (_) => ImportSetSheet(draft: draft),
    );

/// The words for a refused pick.
String pickRefusalText(AppLocalizations l10n, PickRefusal reason) =>
    switch (reason) {
      PickRefusal.tooLarge => l10n.exportTooLarge,
      PickRefusal.notBackup => l10n.exportNotBackup,
      PickRefusal.foreign => l10n.importPartForeign,
    };

class ImportSetSheet extends ConsumerStatefulWidget {
  const ImportSetSheet({required this.draft, super.key});

  final SetDraft draft;

  @override
  ConsumerState<ImportSetSheet> createState() => _ImportSetSheetState();
}

// Leaf state: the last refusal and whether a pick is open.
class _ImportSetSheetState extends ConsumerState<ImportSetSheet> {
  PickRefusal? _refused;
  var _picking = false;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final d = widget.draft;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            l10n.importAddedCount(d.added, d.total ?? d.added + 1),
            style: t.styles.body,
          ),
        ),
        const SizedBox(height: DotSpace.s),
        ListTile(
          minTileHeight: DotTouch.android,
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.importAddFiles, style: t.styles.rowTitle),
          enabled: !_picking,
          onTap: () => unawaited(_add()),
        ),
        if (_refused case final r?)
          Semantics(
            liveRegion: true,
            child: Text(
              pickRefusalText(l10n, r),
              style: t.styles.body.copyWith(color: t.colors.muted),
            ),
          ),
      ],
    );
  }

  Future<void> _add() async {
    setState(() => _picking = true);
    final files = await ref.read(fileGatewayProvider).pickJsonFiles();
    if (!mounted) return;
    if (files.isEmpty) {
      setState(() => _picking = false);
      return;
    }
    final picked = await addPicked(widget.draft, files);
    if (!mounted) return;
    switch (picked) {
      case PickedSet(:final draft) when draft.complete:
        Navigator.of(context).pop(draft);
      case PickedSet():
        setState(() {
          _picking = false;
          _refused = null;
        });
      case PickRefused(:final reason):
        setState(() {
          _picking = false;
          _refused = reason;
        });
      case PickedSingle():
        // addPicked never gives one to a set being gathered.
        setState(() {
          _picking = false;
          _refused = PickRefusal.foreign;
        });
    }
  }
}
