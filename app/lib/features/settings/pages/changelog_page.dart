import 'dart:async';
import 'dart:convert';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/release/whats_new_seen.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/release/releases.dart';
import 'package:dottoday/features/settings/pages/page_frame.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › About › What's new (PRD F11, R-19): every release's notes,
/// newest first, on the device (works offline). Opening it counts as
/// having seen them, so the update banner goes.
class ChangelogPage extends ConsumerStatefulWidget {
  const ChangelogPage({super.key});

  @override
  ConsumerState<ChangelogPage> createState() => _ChangelogPageState();
}

/// A leaf: only marks the notes seen once the version is known.
class _ChangelogPageState extends ConsumerState<ChangelogPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = ref.watch(appVersionNameProvider).value;
    ref.listen(appVersionNameProvider, (_, next) => _markSeen(next.value));
    final releases = current == null
        ? const <Release>[]
        : releasesUpTo(current);
    return SettingsPageFrame(
      title: l10n.settingsWhatsNew,
      children: [
        PageText(l10n.changelogIntro),
        for (final r in releases)
          SettingsGroup(
            caption: r.version == current
                ? l10n.changelogInstalled(r.version)
                : l10n.changelogVersion(r.version),
            children: [
              for (final item in releaseNoteItems(l10n, r)) _Item(item),
            ],
          ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _markSeen(ref.read(appVersionNameProvider).value);
  }

  // In a microtask: a provider can't change while widgets build.
  void _markSeen(String? version) {
    if (version == null) return;
    unawaited(
      Future.microtask(() async {
        if (!mounted) return;
        await ref.read(whatsNewSeenProvider.notifier).markSeen(version);
      }),
    );
  }
}

/// A release's notes; one item per line (PRD F11). Exhaustive, so a new
/// [Release] can't ship without its notes.
String releaseNotes(AppLocalizations l10n, Release release) =>
    switch (release) {
      Release.v1_0_0 => l10n.releaseNotes100,
      Release.v0_1_0 => l10n.releaseNotes010,
    };

/// The release's notes, one item per non-empty line.
List<String> releaseNoteItems(AppLocalizations l10n, Release release) => [
  for (final line in LineSplitter.split(releaseNotes(l10n, release)))
    if (line.trim().isNotEmpty) line.trim(),
];

/// One note: a small accent dot, then the text.
class _Item extends StatelessWidget {
  const _Item(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(DotSpace.l),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.m,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: DotSpace.s),
            child: ExcludeSemantics(
              child: Container(
                width: DotSize.weekDot,
                height: DotSize.weekDot,
                decoration: BoxDecoration(
                  color: t.colors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Expanded(child: Text(text, style: t.styles.body)),
        ],
      ),
    );
  }
}
