import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/picked_set_check.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The rows Settings › Export and Delete account share for a set
/// (CR-160 B7a/B7c, docs/cr-160-multipart-export.md §10), drawn as
/// E-R2-21's sheet rows: the tinted icon, then a chevron or an action
/// (M20.10 part 1, ED-477).

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
          SettingsRow(
            flush: true,
            glyph: DotGlyphs.file,
            tint: t.tasks[TaskColor.violet].ink,
            title: f.name,
            trailing: widget.asked.contains(f.name)
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: DotSpace.xs,
                    children: [
                      DotIcon(
                        DotGlyphs.check,
                        color: t.colors.muted,
                        size: DotSize.rowIcon,
                      ),
                      Text(
                        l10n.exportDownloaded,
                        style: t.styles.body.copyWith(color: t.colors.muted),
                      ),
                    ],
                  )
                : TextButton(
                    onPressed: () => unawaited(_download(f)),
                    child: Text(l10n.exportDownload),
                  ),
          ),
        const SizedBox(height: DotSpace.xs),
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
        SettingsRow(
          flush: true,
          glyph: DotGlyphs.check,
          tint: t.colors.accentInk,
          title: l10n.exportCheckFiles,
          subtitle: l10n.exportCheckFilesDetail,
          onTap: _checking ? null : () => unawaited(_pick()),
        ),
        if (_answer case final a?)
          SetNote(
            kind: switch (a) {
              PickedSetComplete() => SetNoteKind.done,
              PickedSetMissing() => SetNoteKind.heedful,
              PickedSetWrong() => SetNoteKind.plain,
            },
            text: _text(l10n, a),
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

/// What a set check or a refused pick says, under its row: done with the
/// mint check (as Notification health), a heads-up with an amber ring
/// (never red), or plain muted words (ED-477).
enum SetNoteKind { done, heedful, plain }

class SetNote extends StatelessWidget {
  const SetNote({required this.kind, required this.text, super.key});

  final SetNoteKind kind;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final Widget? mark = switch (kind) {
      SetNoteKind.done => DotIcon(
        DotGlyphs.check,
        color: t.tasks[TaskColor.mint].ink,
        size: DotSize.rowIcon,
      ),
      SetNoteKind.heedful => Container(
        // The routine thread's small hollow ring (E-R2-22).
        width: DotSize.miniRing,
        height: DotSize.miniRing,
        margin: const EdgeInsets.all(DotSpace.xs),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: t.tasks[TaskColor.amber].ink,
            width: DotSize.miniRingStroke,
          ),
        ),
      ),
      SetNoteKind.plain => null,
    };
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(top: DotSpace.s),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.s,
          children: [
            ?mark,
            Expanded(
              child: Text(
                text,
                style: t.styles.body.copyWith(
                  color: kind == SetNoteKind.plain ? t.colors.muted : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
