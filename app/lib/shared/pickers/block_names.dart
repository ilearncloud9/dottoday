import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';

export 'task_icon_names.gen.dart';

/// Localised name of a task colour, for screen readers and the picker.
String taskColorName(AppLocalizations l10n, TaskColor color) => switch (color) {
  TaskColor.coral => l10n.colorCoral,
  TaskColor.amber => l10n.colorAmber,
  TaskColor.mint => l10n.colorMint,
  TaskColor.teal => l10n.colorTeal,
  TaskColor.sky => l10n.colorSky,
  TaskColor.indigo => l10n.colorIndigo,
  TaskColor.violet => l10n.colorViolet,
  TaskColor.rose => l10n.colorRose,
  TaskColor.slate => l10n.colorSlate,
};
