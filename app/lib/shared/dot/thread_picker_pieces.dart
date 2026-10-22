import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_axis.dart';
import 'package:flutter/material.dart';

/// Points per minute of the `ThreadPicker` slice (~42 pt per hour,
/// `A-ios-add-when`).
const double pickerScale = 0.7;

/// A neighbour on the `ThreadPicker`, in display values: minutes after the
/// day's local midnight (may run past either end).
@immutable
final class PickerBlock {
  const PickerBlock({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
    required this.startMinute,
    required this.endMinute,
  });

  final String id;
  final String title;
  final TaskColor color;
  final TaskIcon icon;
  final int startMinute;
  final int endMinute;
}

/// The whole day at picker scale: dotted thread, neighbours as 22 px dots
/// with their segments, hour labels and the Bedtime cap. Decorative: the
/// picker speaks for it.
class PickerDay extends StatelessWidget {
  const PickerDay({
    required this.blocks,
    required this.hourText,
    required this.bedMinute,
    required this.bedText,
    super.key,
  });

  final List<PickerBlock> blocks;
  final String Function(int minute) hourText;
  final int bedMinute;
  final String bedText;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final label = t.styles.rowMeta.copyWith(color: t.colors.muted);
    // Half a label line, so a label centres on its hour.
    final half = (label.fontSize ?? DotSpace.l) / 2 * (label.height ?? 1);
    return SizedBox(
      height: Duration.minutesPerDay * pickerScale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            right: null,
            child: SizedBox(width: threadAxisWidth, child: _axis(t)),
          ),
          ..._labels(t, label, half),
          for (final b in blocks) _block(b),
        ],
      ),
    );
  }

  /// Hour labels (none too close to Bedtime) and the Bedtime cap, each
  /// centred on its minute.
  List<Widget> _labels(DotTheme t, TextStyle label, double half) {
    Widget at(int minute, Widget child) => Positioned(
      top: minute * pickerScale - half,
      left: threadAxisWidth + DotSpace.s,
      child: child,
    );
    return [
      for (var h = 1; h < 24; h++)
        if ((h * 60 - bedMinute).abs() >= 30)
          at(h * 60, Text(hourText(h * 60), style: label)),
      at(
        bedMinute,
        Row(
          spacing: DotSpace.xs,
          children: [
            DotIcon(DotGlyphs.moon, color: t.colors.muted, size: half * 2),
            Text(bedText, style: label),
          ],
        ),
      ),
    ];
  }

  Widget _axis(DotTheme t) => CustomPaint(
    painter: ThreadAxisPainter(
      piece: const FreePiece(),
      hairline: t.colors.hairline,
      accent: t.colors.accent,
      accentTint: t.colors.accentTint,
    ),
  );

  Widget _block(PickerBlock b) {
    final height = (b.endMinute - b.startMinute) * pickerScale;
    return Positioned(
      top: b.startMinute * pickerScale,
      left: 0,
      width: threadAxisWidth,
      height: height < DotSize.pickerDot ? DotSize.pickerDot : height,
      child: Builder(
        builder: (context) {
          final t = DotTheme.of(context);
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: ThreadAxisPainter(
                    piece: SegmentPiece(
                      color: t.tasks[b.color].color,
                      state: DotState.upcoming,
                      dotSize: DotSize.pickerDot,
                    ),
                    hairline: t.colors.hairline,
                    accent: t.colors.accent,
                    accentTint: t.colors.accentTint,
                  ),
                ),
              ),
              TaskDot(
                color: b.color,
                icon: b.icon,
                state: DotState.upcoming,
                label: b.title,
                size: DotSize.pickerDot,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The fixed selection window: accent rules, the new task's dot and
/// segment in its colour, and the "5:00 – 6:00 PM" pill.
class PickerWindow extends StatelessWidget {
  const PickerWindow({
    required this.color,
    required this.icon,
    required this.segment,
    required this.label,
    super.key,
  });

  final TaskColor color;
  final TaskIcon icon;

  /// Length of the task at picker scale (the window may be taller).
  final double segment;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final swatch = t.tasks[color];
    final rule = BorderSide(color: t.colors.accent);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.accentTint,
        border: Border(top: rule, bottom: rule),
      ),
      child: Stack(
        // The pill may be taller than a short task's window.
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: (threadAxisWidth - DotSize.segment) / 2,
            top: DotSize.pickerDot / 2,
            width: DotSize.segment,
            height: segment > DotSize.pickerDot / 2
                ? segment - DotSize.pickerDot / 2
                : 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: swatch.color,
                borderRadius: BorderRadius.circular(DotRadii.pill),
              ),
            ),
          ),
          Positioned(
            left: (threadAxisWidth - DotSize.pickerDot) / 2 - DotSpace.xs,
            top: -DotSpace.xs,
            child: _dot(swatch),
          ),
          Center(child: _pill(t)),
        ],
      ),
    );
  }

  /// The new task's dot on a halo of its tint.
  Widget _dot(TaskSwatch swatch) => Container(
    padding: const EdgeInsets.all(DotSpace.xs),
    decoration: BoxDecoration(shape: BoxShape.circle, color: swatch.tint),
    child: TaskDot(
      color: color,
      icon: icon,
      state: DotState.upcoming,
      label: label,
      size: DotSize.pickerDot,
    ),
  );

  /// "5:00 – 6:00 PM" on the accent.
  Widget _pill(DotTheme t) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: DotSpace.l,
      vertical: DotSpace.xs,
    ),
    decoration: BoxDecoration(
      color: t.colors.accentFill,
      borderRadius: BorderRadius.circular(DotRadii.pill),
    ),
    child: Text(
      label,
      style: t.styles.button.copyWith(color: t.colors.onAccent),
    ),
  );
}
