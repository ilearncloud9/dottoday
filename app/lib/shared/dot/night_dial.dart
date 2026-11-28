import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/night_dial_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Which handle of the dial.
enum DialEnd { windDown, wake }

/// The night dial (E-Phones Edit Weekdays, ED-083 layout rule, ED-084):
/// midnight at the top, the night from the moon (Wind Down) to the sun
/// (Wake Up) on a band, the four labels outside it and the night's length
/// in the middle, or below when it doesn't fit (34 → 30 → 28 → 26, always
/// below at 135 % text or under 240). Drag a handle, or focus it and use
/// the arrow keys (5 min, Shift 30). 240–360 across; never stretched.
class NightDial extends StatelessWidget {
  const NightDial({
    required this.windDown,
    required this.wake,
    required this.selected,
    required this.onChanged,
    required this.onSelect,
    required this.labels,
    required this.length,
    required this.lengthCaption,
    required this.handleLabel,
    required this.handleValue,
    this.onKeyboardFocus,
    super.key,
  });

  /// Minutes after midnight.
  final int windDown;
  final int wake;

  /// The handle the time fields below show as selected.
  final DialEnd selected;
  final void Function(DialEnd end, int minute) onChanged;
  final ValueChanged<DialEnd> onSelect;

  /// 12 AM, 6 AM, 12 PM, 6 PM, as each locale writes them.
  final ({String top, String right, String bottom, String left}) labels;

  /// "7 h 30" and "of night".
  final String length;
  final String lengthCaption;

  /// "Wind Down" / "Wake Up", and a time in words, for screen readers.
  final String Function(DialEnd end) handleLabel;
  final String Function(int minute) handleValue;

  /// The handle that has keyboard focus, or null when none does (the
  /// sheet then says "Focused: Wake Up — arrow keys move it 5 min.").
  final ValueChanged<DialEnd?>? onKeyboardFocus;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final size = math.min(box.maxWidth, DotDial.max);
        final g = NightDialGeometry(size);
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final fit = size < DotDial.min || scale >= DotDial.belowFromScale
            ? null
            : _fitSize(context, g);
        final dial = SizedBox.square(
          dimension: size,
          child: GestureDetector(
            onPanStart: (d) => onSelect(_nearest(g, d.localPosition)),
            onPanUpdate: (d) =>
                onChanged(selected, g.minuteAt(d.localPosition)),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: NightDialPainter(_scene(t))),
                ),
                ..._labels(t, g),
                if (fit != null)
                  Positioned.fill(child: Center(child: _length(t, fit))),
                for (final end in DialEnd.values) _handle(context, g, end),
              ],
            ),
          ),
        );
        return Column(
          children: [
            dial,
            if (fit == null) _length(t, DotDial.durationSizes.first),
          ],
        );
      },
    );
  }

  NightDialScene _scene(DotTheme t) => NightDialScene(
    windDown: windDown,
    wake: wake,
    track: t.colors.chip,
    nightBand: t.tasks[TaskColor.violet].tint,
    nightLine: t.tasks[TaskColor.violet].color,
    ticks: t.colors.hairline,
    dots: t.colors.secondary,
  );

  /// The largest size whose length fits the centre disc, or null.
  double? _fitSize(BuildContext context, NightDialGeometry g) {
    final t = DotTheme.of(context);
    for (final s in DotDial.durationSizes) {
      final p = TextPainter(
        text: TextSpan(text: length, style: _lengthStyle(t, s)),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final fits = p.width <= g.disc * 2 - DotSpace.l;
      p.dispose();
      if (fits) return s;
    }
    return null;
  }

  TextStyle _lengthStyle(DotTheme t, double size) => t.styles.promptTitle
      .copyWith(fontSize: size, height: 1, fontWeight: FontWeight.w800);

  Widget _length(DotTheme t, double size) => ExcludeSemantics(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(length, style: _lengthStyle(t, size)),
        Text(
          lengthCaption,
          style: t.styles.rowMeta.copyWith(
            color: t.colors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  List<Widget> _labels(DotTheme t, NightDialGeometry g) {
    final style = t.styles.rowMeta.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.1,
    );
    final outer = g.radius + g.band / 2 + DotDial.labelRoom / 2;
    Widget at(int minute, String text) {
      final p = g.at(minute, outer);
      return Positioned(
        left: p.dx - DotDial.labelRoom * 1.5,
        top: p.dy - DotDial.labelRoom / 2,
        width: DotDial.labelRoom * 3,
        height: DotDial.labelRoom,
        child: ExcludeSemantics(
          child: Center(
            child: Text(text, style: style, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    // The side labels stack ("6" over "PM") so they stay outside the band.
    String stacked(String s) =>
        s.replaceFirst(' ', '\n'); // l10n-ignore: layout
    return [
      at(0, labels.top),
      at(6 * 60, stacked(labels.right)),
      at(12 * 60, labels.bottom),
      at(18 * 60, stacked(labels.left)),
    ];
  }

  DialEnd _nearest(NightDialGeometry g, Offset p) {
    final m = g.minuteAt(p, snap: 1);
    int gap(int a) {
      final d = (a - m).abs();
      return math.min(d, Duration.minutesPerDay - d);
    }

    return gap(windDown) <= gap(wake) ? DialEnd.windDown : DialEnd.wake;
  }

  Widget _handle(BuildContext context, NightDialGeometry g, DialEnd end) {
    final minute = end == DialEnd.windDown ? windDown : wake;
    final p = g.at(minute);
    return Positioned(
      left: p.dx - DotDial.handle / 2,
      top: p.dy - DotDial.handle / 2,
      child: _Handle(
        end: end,
        selected: selected == end,
        label: handleLabel(end),
        value: handleValue(minute),
        increased: handleValue(minute + DotDial.step),
        decreased: handleValue(minute - DotDial.step),
        onFocus: (on) {
          if (on) onSelect(end);
          onKeyboardFocus?.call(on ? end : null);
        },
        onStep: (by) => onChanged(end, (minute + by) % Duration.minutesPerDay),
      ),
    );
  }
}

/// A moon or sun handle: a tinted circle, outlined when selected; a
/// slider for screen readers and the keyboard.
class _Handle extends StatelessWidget {
  const _Handle({
    required this.end,
    required this.selected,
    required this.label,
    required this.value,
    required this.increased,
    required this.decreased,
    required this.onFocus,
    required this.onStep,
  });

  final DialEnd end;
  final bool selected;
  final String label;
  final String value;
  final String increased;
  final String decreased;
  final ValueChanged<bool> onFocus;
  final ValueChanged<int> onStep;

  KeyEventResult _key(FocusNode _, KeyEvent e) {
    if (e is KeyUpEvent) return KeyEventResult.ignored;
    final big = HardwareKeyboard.instance.isShiftPressed;
    final by = big ? DotDial.bigStep : DotDial.step;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowRight || k == LogicalKeyboardKey.arrowUp) {
      onStep(by);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowLeft ||
        k == LogicalKeyboardKey.arrowDown) {
      onStep(-by);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c =
        t.tasks[end == DialEnd.windDown ? TaskColor.violet : TaskColor.amber];
    return Semantics(
      slider: true,
      label: label,
      value: value,
      increasedValue: increased,
      decreasedValue: decreased,
      onIncrease: () => onStep(DotDial.step),
      onDecrease: () => onStep(-DotDial.step),
      child: Focus(
        onFocusChange: onFocus,
        onKeyEvent: _key,
        child: Builder(
          builder: (context) {
            final focused = Focus.of(context).hasFocus;
            return Container(
              width: DotDial.handle,
              height: DotDial.handle,
              decoration: BoxDecoration(
                color: c.tint,
                shape: BoxShape.circle,
                border: Border.all(
                  color: focused || selected
                      ? t.colors.accentText
                      : t.colors.card,
                  width: DotSize.smallDotOutline,
                ),
              ),
              child: Center(
                child: DotIcon(
                  end == DialEnd.windDown ? DotGlyphs.moon : DotGlyphs.sun,
                  color: c.ink,
                  size: DotSize.rowIcon,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
