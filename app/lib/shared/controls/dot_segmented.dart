import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// One choice of a few, in each platform's own segmented control (owner,
/// native pass): iOS's sliding segmented control on iPhone, iPad and the
/// Mac; Material 3's segmented button on Android and the web (with the
/// check-free selected look of E-G4-7-States D from the theme).
class DotSegmented<T extends Object> extends StatelessWidget {
  const DotSegmented({
    required this.segments,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// Each value and its label, in order.
  final List<(T, String)> segments;
  final T selected;

  /// Called with a newly picked value (not the one already picked).
  final ValueChanged<T> onChanged;

  void _pick(T? v) {
    if (v != null && v != selected) onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    if (appleApp(context)) {
      final t = DotTheme.of(context);
      return CupertinoSlidingSegmentedControl<T>(
        groupValue: selected,
        onValueChanged: _pick,
        children: {
          for (final (v, label) in segments)
            v: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DotSpace.s,
                vertical: DotSpace.xs,
              ),
              child: Text(label, style: t.styles.rowMeta),
            ),
        },
      );
    }
    return SegmentedButton<T>(
      segments: [
        for (final (v, label) in segments)
          ButtonSegment(value: v, label: Text(label)),
      ],
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (s) => _pick(s.single),
    );
  }
}
