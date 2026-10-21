import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/duration_text.dart';
import 'package:flutter/material.dart';

/// "45 min", "1 h", "1 h 30 min" (docs/03 §3.1 shows end time separately).
String formatDuration(AppLocalizations l10n, int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return l10n.durationMinutes(m);
  if (m == 0) return l10n.durationHours(h);
  return l10n.durationHoursMinutes(h, m);
}

/// Concept A's compact form: "45 min", "1 h", "5 h 45" (`Main`, docs/10 §7.5).
String formatDurationShort(AppLocalizations l10n, int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return l10n.durationMinutes(m);
  if (m == 0) return l10n.durationHours(h);
  return l10n.durationHoursMinutesShort(h, m);
}

/// Preset duration chips 15/30/45/60/90 plus "Custom", which reveals a typed
/// field (5 min – 24 h) (docs/02 F2, R-16).
///
/// A [value] that isn't a preset selects "Custom" and shows its length.
class DurationChips extends StatefulWidget {
  const DurationChips({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Minutes.
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<DurationChips> createState() => _DurationChipsState();
}

class _DurationChipsState extends State<DurationChips> {
  late bool _customOpen = !durationPresetsMin.contains(widget.value);
  bool _invalid = false;

  void _pick(int minutes) {
    setState(() {
      _customOpen = false;
      _invalid = false;
    });
    if (minutes != widget.value) widget.onChanged(minutes);
  }

  void _submitCustom(String text) {
    final minutes = parseDurationText(text);
    setState(() => _invalid = minutes == null);
    if (minutes != null && minutes != widget.value) widget.onChanged(minutes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPreset = durationPresetsMin.contains(widget.value);
    final customSelected = _customOpen || !isPreset;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: DotSpace.s,
          runSpacing: DotSpace.s,
          children: [
            for (final m in durationPresetsMin)
              ChoiceChip(
                label: Text(formatDuration(l10n, m)),
                selected: !customSelected && widget.value == m,
                onSelected: (_) => _pick(m),
              ),
            ChoiceChip(
              label: Text(
                isPreset
                    ? l10n.durationCustom
                    : formatDuration(l10n, widget.value),
              ),
              selected: customSelected,
              onSelected: (_) => setState(() => _customOpen = true),
            ),
          ],
        ),
        if (_customOpen)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: DotSpace.m),
            child: TextField(
              autofocus: true,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              onSubmitted: _submitCustom,
              decoration: InputDecoration(
                labelText: l10n.durationLabel,
                hintText: l10n.durationCustomHint,
                errorText: _invalid ? l10n.durationCustomInvalid : null,
              ),
            ),
          ),
      ],
    );
  }
}
