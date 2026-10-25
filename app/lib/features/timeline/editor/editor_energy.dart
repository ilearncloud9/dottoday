import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/editor/editor_fields.dart';
import 'package:flutter/material.dart';

/// ENERGY: the optional low / medium / high level (docs/02 F2.9). Tapping
/// the picked chip again clears it — "optional" means none is a choice,
/// and the editor has no room for a fourth "None" chip at 200 % text.
class EditorEnergy extends StatelessWidget {
  const EditorEnergy({
    required this.energy,
    required this.onChanged,
    super.key,
  });

  final Energy? energy;

  /// The new level, null when cleared.
  final ValueChanged<Energy?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorCaption(l10n.editorEnergy),
        Wrap(
          spacing: DotSpace.s,
          runSpacing: DotSpace.s,
          children: [
            for (final e in Energy.values)
              ChoiceChip(
                label: Text(energyLabel(l10n, e)),
                selected: energy == e,
                shape: dotChipShape(context),
                onSelected: (on) => onChanged(on ? e : null),
              ),
          ],
        ),
      ],
    );
  }
}

/// "Low", "Medium", "High".
String energyLabel(AppLocalizations l10n, Energy e) => switch (e) {
  Energy.low => l10n.energyLow,
  Energy.medium => l10n.energyMedium,
  Energy.high => l10n.energyHigh,
};
