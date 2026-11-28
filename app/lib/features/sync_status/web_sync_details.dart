import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/pwa/browser_storage.dart';
import 'package:dottoday/domain/storage/browser_storage.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Web Sync details, signed in (E-G4-7 Q2a–Q2d; M20.10 part 6, ED-484):
/// where sync stands, the caution card only while changes wait, then
/// what this browser keeps. [last] is "Last synced 10:42". Sync now or
/// Sign in… is the panel's pinned foot ([WebSyncAction]).
class WebSyncDetails extends ConsumerWidget {
  const WebSyncDetails({
    required this.status,
    required this.last,
    required this.stateGlyph,
    required this.stateLine,
    super.key,
  });

  final SyncStatus status;
  final String last;

  /// The state's icon and words when it is neither synced nor waiting.
  final DotGlyph stateGlyph;
  final String stateLine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final waiting = status.pending > 0;
    final synced = status.state == SyncState.synced;
    final storage = ref.watch(browserStorageProvider).value;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        if (waiting)
          WebLine(
            glyph: DotGlyphs.cloudUp,
            title: l10n.syncPending(status.pending),
            text: l10n.webSavedWaiting(last),
            strong: true,
          )
        else if (synced)
          WebLine(
            glyph: DotGlyphs.cloudDone,
            title: l10n.webAllSynced,
            text: l10n.webOnAccount(last),
            strong: true,
          )
        else
          WebLine(
            glyph: stateGlyph,
            title: stateLine,
            text: last,
            strong: true,
          ),
        if (waiting)
          WebCaution(
            title: l10n.syncPending(status.pending),
            lines: [l10n.webCautionSaved, l10n.webCautionClear],
          ),
        _InBrowser(
          storage: storage,
          storageText: (state) => switch (state) {
            BrowserStorageState.kept when waiting => l10n.webStorageKeptShort,
            BrowserStorageState.kept => l10n.webStorageKeptBody,
            BrowserStorageState.notKept => l10n.webStorageNotKeptBody,
            BrowserStorageState.unsupported => l10n.webStorageUnsupportedBody,
          },
        ),
      ],
    );
  }
}

/// Web Sync details, not signed in (E-G4-7 Q2e, Q2f; ED-192): shown once
/// something is saved in this browser; the tasks are only here, and Sign
/// in is the pinned main action.
class WebGuestDetails extends ConsumerWidget {
  const WebGuestDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final storage = ref.watch(browserStorageProvider).value;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        WebLine(
          glyph: DotGlyphs.device,
          title: l10n.webGuestTitle,
          text: l10n.webGuestSaved,
          strong: true,
        ),
        WebCaution(title: l10n.webGuestCard, lines: [l10n.webGuestCardBody]),
        _InBrowser(
          storage: storage,
          intro: false,
          storageText: (state) => switch (state) {
            BrowserStorageState.kept => l10n.webGuestKeptBody,
            BrowserStorageState.notKept => l10n.webGuestNotKeptBody,
            BrowserStorageState.unsupported => l10n.webGuestUnsupportedBody,
          },
        ),
      ],
    );
  }
}

/// "In this browser": what Dottoday saves here, then the storage line
/// (kept, isn't kept, can't be asked; never "guaranteed", never red).
class _InBrowser extends StatelessWidget {
  const _InBrowser({
    required this.storage,
    required this.storageText,
    this.intro = true,
  });

  final BrowserStorageState? storage;
  final String Function(BrowserStorageState) storageText;
  final bool intro;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final state = storage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Divider(height: 1, thickness: 1, color: t.colors.hairline),
        Semantics(
          header: true,
          child: Text(l10n.webInBrowser, style: t.styles.rowMeta),
        ),
        if (intro)
          WebLine(glyph: DotGlyphs.browser, text: l10n.webInBrowserBody),
        if (state != null)
          WebLine(
            glyph: DotGlyphs.shield,
            title: switch (state) {
              BrowserStorageState.kept => l10n.webStorageKept,
              BrowserStorageState.notKept => l10n.webStorageNotKept,
              BrowserStorageState.unsupported => l10n.webStorageUnsupported,
            },
            text: storageText(state),
          ),
      ],
    );
  }
}

/// An icon, an optional title and its words; [strong] for the state line.
class WebLine extends StatelessWidget {
  const WebLine({
    required this.glyph,
    required this.text,
    this.title,
    this.strong = false,
    super.key,
  });

  final DotGlyph glyph;
  final String? title;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final heading = title;
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.s,
        children: [
          DotIcon(glyph, color: t.colors.ink, size: DotSize.rowIcon),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (heading != null)
                  Text(
                    heading,
                    style: strong ? t.styles.rowTitle : t.styles.cardTitle,
                  ),
                Text(
                  text,
                  // A line with no title reads in the text colour (Q2a).
                  style: heading == null
                      ? t.styles.rowMeta.copyWith(color: t.colors.ink)
                      : t.styles.rowMeta,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The caution note (Q2b, Q2e): info icon, an amber rule on the leading
/// edge, its heading then its sentences; amber says "look here" without
/// red (no-shame rule). Screen readers hear the heading first.
class WebCaution extends StatelessWidget {
  const WebCaution({required this.title, required this.lines, super.key});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final amber = t.tasks[TaskColor.amber];
    return Semantics(
      container: true,
      // A one-sided border can't take a radius; the clip rounds it.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DotRadii.field),
        child: DecoratedBox(
          decoration: BoxDecoration(
            // A breath of amber over the panel (Q2b light and dark).
            color: Color.alphaBlend(
              amber.color.withValues(alpha: DotOpacity.cautionWash),
              t.colors.card,
            ),
            border: BorderDirectional(
              start: BorderSide(color: amber.color, width: DotSize.cautionRule),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.m),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DotSpace.s,
              children: [
                DotIcon(
                  DotGlyphs.info,
                  color: t.colors.ink,
                  size: DotSize.rowIcon,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: DotSpace.xs,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(title, style: t.styles.cardTitle),
                      ),
                      for (final line in lines)
                        Text(line, style: t.styles.rowMeta),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
