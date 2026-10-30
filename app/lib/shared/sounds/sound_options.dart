import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';

/// One row of a sound picker: [key] is what gets stored (a sound id,
/// `none`, `system`, or null for a task's Default); [detail] a caption.
final class SoundOption {
  const SoundOption({required this.key, required this.label, this.detail});

  final String? key;
  final String label;
  final String? detail;
}

/// A captioned group of [options] ("Quiet", "Clear", …).
final class SoundSection {
  const SoundSection(this.caption, this.options);

  final String caption;
  final List<SoundOption> options;
}

/// The sound pickers' list (docs/12 §6): each section a group of rows, the
/// chosen one checked. A tap calls [onPick], which picks and previews.
class SoundOptionList extends StatelessWidget {
  const SoundOptionList({
    required this.sections,
    required this.selected,
    required this.onPick,
    super.key,
  });

  final List<SoundSection> sections;

  /// The stored key now (null = Default on a task).
  final String? selected;
  final ValueChanged<String?> onPick;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: DotSpace.m,
    children: [
      for (final section in sections)
        SettingsGroup(
          caption: section.caption,
          children: [
            for (final option in section.options)
              _OptionRow(
                option: option,
                selected: option.key == selected,
                onTap: () => onPick(option.key),
              ),
          ],
        ),
    ],
  );
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final SoundOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final detail = option.detail;
    return Semantics(
      selected: selected,
      button: true,
      child: ListTile(
        minTileHeight: DotTouch.android,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: DotSpace.m,
        ),
        title: Text(option.label, style: t.styles.rowTitle),
        subtitle: detail == null ? null : Text(detail, style: t.styles.rowMeta),
        trailing: selected
            ? DotIcon(DotGlyphs.check, color: t.colors.accentInk)
            : null,
        onTap: onTap,
      ),
    );
  }
}

/// "Your device is muted — you may still get vibration" (docs/12 §6),
/// above a picker while the ringer is silent, so a quiet preview isn't
/// mistaken for a broken sound.
class SoundMutedBanner extends StatelessWidget {
  const SoundMutedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.raised,
          borderRadius: BorderRadius.circular(DotRadii.card),
          border: Border.all(color: t.colors.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.m),
          child: Row(
            spacing: DotSpace.s,
            children: [
              DotIcon(DotGlyphs.sound, color: t.colors.muted),
              Expanded(
                child: Text(context.l10n.soundsMuted, style: t.styles.body),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
