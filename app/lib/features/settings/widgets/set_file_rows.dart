import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/picked_set_check.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The rows Settings › Export and Delete account share for a set
/// (CR-160 B7a/B7c, docs/cr-160-multipart-export.md §10).

/// Web: one Download per file (the browser may block a burst), each marked
/// "Downloaded" once asked; [asked] collects the names asked for, so the
/// caller can tell whether every file was.
class DownloadList extends ConsumerStatefulWidget {
  const DownloadList({required this.files, required this.asked, super.key});

  final List<PreparedFile> files;
  final Set<String> asked;

  @override
  ConsumerState<DownloadList> createState() => _DownloadListState();
}

class _DownloadListState extends ConsumerState<DownloadList> {
  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final f in widget.files)
          ListTile(
            minTileHeight: DotTouch.android,
            contentPadding: EdgeInsets.zero,
            title: Text(f.name, style: t.styles.rowTitle),
            trailing: widget.asked.contains(f.name)
                ? Text(
                    l10n.exportDownloaded,
                    style: t.styles.body.copyWith(color: t.colors.muted),
                  )
                : TextButton(
                    onPressed: () => unawaited(_download(f)),
                    child: Text(l10n.exportDownload),
                  ),
          ),
        Text(
          l10n.exportDownloadNote,
          style: t.styles.body.copyWith(color: t.colors.muted),
        ),
      ],
    );
  }

  Future<void> _download(PreparedFile f) async {
    await ref.read(fileGatewayProvider).downloadPrepared(f);
    if (!mounted) return;
    setState(() => widget.asked.add(f.name));
  }
}

/// "Check my files…": picks the files back and says what [check] found
/// for a set of [count] files; [onChecked] hears every answer.
class CheckFilesRow extends ConsumerStatefulWidget {
  const CheckFilesRow({
    required this.count,
    required this.check,
    this.onChecked,
    super.key,
  });

  final int count;
  final Future<PickedSetCheck?> Function(List<PickedFile> picked) check;
  final ValueChanged<PickedSetCheck>? onChecked;

  @override
  ConsumerState<CheckFilesRow> createState() => _CheckFilesRowState();
}

// Leaf state: whether a pick is open and the last answer.
class _CheckFilesRowState extends ConsumerState<CheckFilesRow> {
  PickedSetCheck? _answer;
  var _checking = false;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          minTileHeight: DotTouch.android,
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.exportCheckFiles, style: t.styles.rowTitle),
          subtitle: Text(l10n.exportCheckFilesDetail),
          enabled: !_checking,
          onTap: () => unawaited(_pick()),
        ),
        if (_answer case final a?)
          Semantics(
            liveRegion: true,
            child: Text(_text(l10n, a), style: t.styles.body),
          ),
      ],
    );
  }

  String _text(AppLocalizations l10n, PickedSetCheck a) => switch (a) {
    PickedSetComplete() => l10n.exportCheckAll(widget.count),
    PickedSetMissing(:final missing) => l10n.exportCheckMissing(
      missing,
      widget.count,
    ),
    PickedSetWrong() => l10n.exportCheckWrong,
  };

  Future<void> _pick() async {
    setState(() => _checking = true);
    final picked = await ref.read(fileGatewayProvider).pickJsonFiles();
    final answer = picked.isEmpty ? null : await widget.check(picked);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _answer = answer ?? _answer;
    });
    if (answer != null) widget.onChecked?.call(answer);
  }
}
