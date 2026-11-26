import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/onboarding/steps/day_dial_parts.dart';
import 'package:dottoday/features/onboarding/steps/day_dial_sky.dart';
import 'package:flutter/material.dart';

/// Your day's dial (prototype `.dial`, `mountDay`): the hours from 4:00
/// to 2:00 the next morning down a sky, the thread at 120 with its awake
/// part from the sun to the moon, and the sun and moon to drag. The sky
/// and the stars follow them. It bleeds [bleed] past its box at each side,
/// to the screen's or card's edges.
///
/// Minutes are from the day's midnight; [wind] can pass 1440 (00:30 is
/// 1470).
class DayDial extends StatefulWidget {
  const DayDial({
    required this.wake,
    required this.wind,
    required this.bleed,
    required this.time,
    required this.hour,
    required this.wakeLabel,
    required this.windLabel,
    required this.wakePops,
    required this.windPops,
    required this.onWake,
    required this.onWind,
    super.key,
  });

  final int wake;
  final int wind;
  final double bleed;

  /// "7:00 AM" for a minute of the day.
  final String Function(int minute) time;

  /// "5 AM" for an hour mark.
  final String Function(int minute) hour;
  final String wakeLabel;
  final String windLabel;

  /// Bumped each time the sun's or moon's time reaches an hour.
  final int wakePops;
  final int windPops;
  final ValueChanged<int> onWake;
  final ValueChanged<int> onWind;

  /// The dial's span, and where the sun and the moon may go
  /// (`MIN`, `MAX`, `bind`): Wake Up 4:00–12:00, Wind Down 18:00–2:00.
  static const first = 240;
  static const last = 1560;
  static const wakeFirst = 240;
  static const wakeLast = 720;
  static const windFirst = 1080;
  static const windLast = 1560;

  /// The hour marks (`ticks`): 5 AM, 8 AM, 11 AM, 2 PM, 5 PM, 8 PM, 11 PM
  /// and 1 AM.
  static const ticks = [300, 480, 660, 840, 1020, 1200, 1380, 1500];

  @override
  State<DayDial> createState() => _DayDialState();
}

class _DayDialState extends State<DayDial> {
  final _box = GlobalKey();

  /// The minute under the finger at global [dy], on 15-minute steps.
  int _minuteAt(double dy, int lo, int hi) {
    final box = _box.currentContext!.findRenderObject()! as RenderBox;
    final y = box.globalToLocal(Offset(0, dy)).dy;
    final span = box.size.height - 2 * OnbSize.dialPad;
    final m =
        DayDial.first +
        (y - OnbSize.dialPad) / span * (DayDial.last - DayDial.first);
    return ((m / 15).round() * 15).clamp(lo, hi);
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final w = widget;
    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth + 2 * w.bleed;
        final height = box.maxHeight;
        double y(int m) =>
            OnbSize.dialPad +
            (m - DayDial.first) /
                (DayDial.last - DayDial.first) *
                (height - 2 * OnbSize.dialPad);
        return OverflowBox(
          minWidth: width,
          maxWidth: width,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: _fade,
            child: Stack(
              key: _box,
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: DayDialSky(
                      sun: y(w.wake),
                      moon: y(w.wind),
                      ticks: [for (final m in DayDial.ticks) y(m)],
                      sky: OnbSky.of(
                        t.colors.isDark ? Brightness.dark : Brightness.light,
                      ),
                      ground: t.colors.surface,
                      accent: t.colors.accent,
                      rtl: Directionality.of(context) == TextDirection.rtl,
                    ),
                  ),
                ),
                for (final m in DayDial.ticks)
                  _at(
                    y(m),
                    end: width - OnbSize.tickEnd,
                    ExcludeSemantics(
                      child: Text(w.hour(m), style: t.styles.onbTick),
                    ),
                  ),
                _bubble(y(w.wake), w.wakeLabel, w.time(w.wake), w.wakePops),
                _bubble(y(w.wind), w.windLabel, w.time(w.wind), w.windPops),
                _handle(y(w.wake), sun: true),
                _handle(y(w.wind), sun: false),
              ],
            ),
          ),
        );
      },
    );
  }

  /// [child] centred on [y], from [start] or to [end].
  Widget _at(double y, Widget child, {double? start, double? end}) =>
      PositionedDirectional(
        top: y,
        start: start,
        end: end,
        child: FractionalTranslation(
          translation: const Offset(0, -0.5),
          child: child,
        ),
      );

  Widget _bubble(double y, String caption, String time, int pops) => _at(
    y,
    start: OnbSize.bubble,
    ExcludeSemantics(
      child: DayDialBubble(caption: caption, time: time, pops: pops),
    ),
  );

  Widget _handle(double y, {required bool sun}) {
    final t = DotTheme.of(context);
    final w = widget;
    final value = sun ? w.wake : w.wind;
    final lo = sun ? DayDial.wakeFirst : DayDial.windFirst;
    final hi = sun ? DayDial.wakeLast : DayDial.windLast;
    final set = sun ? w.onWake : w.onWind;
    void to(int m) {
      if (m != value) set(m);
    }

    return PositionedDirectional(
      start: OnbSize.rail - OnbSize.handle / 2,
      top: y - OnbSize.handle / 2,
      width: OnbSize.handle,
      height: OnbSize.handle,
      child: DayDialHandle(
        glyph: sun ? DotGlyphs.onbSun : DotGlyphs.onbMoon,
        glyphSize: sun ? OnbSize.sunGlyph : OnbSize.moonGlyph,
        color: t.tasks[sun ? TaskColor.amber : TaskColor.indigo].ring,
        label: sun ? w.wakeLabel : w.windLabel,
        value: w.time(value),
        increased: w.time((value + 15).clamp(lo, hi)),
        decreased: w.time((value - 15).clamp(lo, hi)),
        onDragTo: (dy) => to(_minuteAt(dy, lo, hi)),
        onStep: (by) => to((value + by).clamp(lo, hi)),
      ),
    );
  }

  /// In over the top 9 %, out over the bottom 9 % (`mask-image`).
  static Shader _fade(Rect r) => onbDialFade.createShader(r);
}
