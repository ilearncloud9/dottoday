import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/settings/settings_choice_mark.dart';
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
/// With [picked], several are chosen (Vary the sound) and the rows in
/// [disabled] can't change.
class SoundOptionList extends StatelessWidget {
  const SoundOptionList({
    required this.sections,
    required this.selected,
    required this.onPick,
    this.picked,
    this.disabled = const {},
    super.key,
  });

  /// The chosen keys of a list that takes several.
  final Set<String?>? picked;
  final Set<String?> disabled;

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
                selected:
                    picked?.contains(option.key) ?? option.key == selected,
                multiple: picked != null,
                onTap: disabled.contains(option.key)
                    ? null
                    : () => onPick(option.key),
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
    required this.multiple,
    required this.onTap,
  });

  final SoundOption option;
  final bool selected;
  final bool multiple;
  final VoidCallback? onTap;

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
        title: Text(option.label, style: t.styles.body),
        subtitle: detail == null ? null : Text(detail, style: t.styles.rowMeta),
        trailing: SettingsChoiceMark(selected: selected, multiple: multiple),
        enabled: onTap != null,
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
          color: t.colors.card,
          borderRadius: BorderRadius.circular(DotRadii.card),
          border: Border.all(color: t.colors.threadAhead),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.m),
          child: Row(
            spacing: DotSpace.s,
            children: [
              DotIcon(DotGlyphs.sound, color: t.colors.secondary),
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
