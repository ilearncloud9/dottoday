import 'package:dottoday/domain/validation/field_rules.dart';

/// The Add flow's duration chips until the user edits them
/// (`A-ios-add-when`: 15 30 45 1h 1.5h 2h; docs/02 F2, R-16).
const defaultDurationPresets = [15, 30, 45, 60, 90, 120];

/// Most presets kept: two rows of chips.
const maxDurationPresets = 12;

/// [presets] with [minutes] added, sorted, without duplicates. Unchanged
/// when [minutes] is out of range (5 min–24 h) or the list is full.
///
/// ```dart
/// withPreset([15, 60], 40); // [15, 40, 60]
/// ```
List<int> withPreset(List<int> presets, int minutes) {
  if (minutes < minDurationMin || minutes > maxDurationMin) return presets;
  if (presets.contains(minutes)) return presets;
  if (presets.length >= maxDurationPresets) return presets;
  return [...presets, minutes]..sort();
}

/// [presets] without [minutes]. The last preset stays: the chip row is
/// never empty.
List<int> withoutPreset(List<int> presets, int minutes) {
  if (presets.length <= 1) return presets;
  return [
    for (final p in presets)
      if (p != minutes) p,
  ];
}

/// Whether [presets] is a list Settings may hold: 1–[maxDurationPresets]
/// distinct lengths, each 5 min–24 h.
bool validPresets(List<int> presets) =>
    presets.isNotEmpty &&
    presets.length <= maxDurationPresets &&
    presets.toSet().length == presets.length &&
    presets.every((m) => m >= minDurationMin && m <= maxDurationMin);
