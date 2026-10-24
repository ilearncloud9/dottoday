import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/utils/web_links.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/features/timeline/editor/editor_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// LINKS: the web links in a task's notes, each opening in the browser
/// (docs/02 F5, R-02 "links in event descriptions are plain text"). An
/// imported event's description and link arrive as notes (M7.2); links
/// a person types work the same. Nothing when there are none.
class NoteLinks extends ConsumerWidget {
  const NoteLinks({required this.notes, super.key});

  final String? notes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = webLinks(notes);
    if (links.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorCaption(context.l10n.taskLinks),
        for (final uri in links)
          _LinkRow(uri: uri, onOpen: () => unawaited(_open(context, ref, uri))),
      ],
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref, Uri uri) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final failed = context.l10n.taskLinkFailed;
    final opened = await ref.read(linkLauncherProvider).open(uri);
    if (!opened) messenger?.showSnackBar(SnackBar(content: Text(failed)));
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.uri, required this.onOpen});

  final Uri uri;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    // Its own node (not merged into the caption above): a link, read as
    // its address, with where it goes as the hint.
    return Semantics(
      container: true,
      link: true,
      hint: context.l10n.taskLinkOpen(uri.host),
      child: ListTile(
        onTap: onOpen,
        contentPadding: EdgeInsets.zero,
        minTileHeight: DotTouch.android + DotSpace.s,
        leading: ExcludeSemantics(
          child: DotIcon(DotGlyphs.link, color: t.colors.muted),
        ),
        title: Text(
          uri.toString(),
          style: t.styles.body.copyWith(
            color: t.colors.accentInk,
            decoration: TextDecoration.underline,
            decorationColor: t.colors.accentInk,
          ),
        ),
      ),
    );
  }
}
