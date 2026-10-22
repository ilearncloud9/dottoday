import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shortest day the slider allows (Wake Up to Bedtime).
const int minAwakeMinutes = 60;

/// DAY SHAPE (`A-ios-settings`, `A-android-settings`; also O2): a sun →
/// moon track with a Wake Up and a Bedtime handle, the times under the
/// handles and "15 h awake" between. Each handle is its own slider for
/// keyboards (arrows ±[step], Page ±1 h) and screen readers.
///
/// Minutes are after local midnight; Bedtime stops one [step] before
/// midnight (`HH:mm` windows end by 23:59, docs/05). A drag moves locally
/// and calls [onChanged] once on release, so a drag is one settings write.
class DayShapeSlider extends StatefulWidget {
  const DayShapeSlider({
    required this.wakeMinute,
    required this.bedMinute,
    required this.timeText,
    required this.awakeText,
    required this.wakeLabel,
    required this.bedLabel,
    required this.onChanged,
    this.step = 15,
    super.key,
  });

  final int wakeMinute;
  final int bedMinute;

  /// "7:00" for a minute of the day.
  final String Function(int minute) timeText;

  /// "15 h awake" for a length in minutes.
  final String Function(int minutes) awakeText;

  /// "Wake Up", "Bedtime": the handles' names, read out.
  final String wakeLabel;
  final String bedLabel;
  final void Function(int wake, int bed) onChanged;
  final int step;

  static const double _handle = DotSize.rowIcon + DotSpace.xs;

  @override
  State<DayShapeSlider> createState() => _DayShapeSliderState();
}

/// A leaf: the handles' positions while a drag is in progress.
class _DayShapeSliderState extends State<DayShapeSlider> {
  late int _wake = widget.wakeMinute;
  late int _bed = widget.bedMinute;
  var _dragging = false;

  static const double _handle = DayShapeSlider._handle;

  int get step => widget.step;
  int get wakeMinute => _wake;
  int get bedMinute => _bed;

  @override
  void didUpdateWidget(DayShapeSlider old) {
    super.didUpdateWidget(old);
    if (_dragging) return;
    _wake = widget.wakeMinute;
    _bed = widget.bedMinute;
  }

  void _commit() => widget.onChanged(_wake, _bed);

  void _setWake(int m, {bool commit = true}) {
    final v = (m / step).round() * step;
    setState(() => _wake = v.clamp(0, _bed - minAwakeMinutes));
    if (commit) _commit();
  }

  void _setBed(int m, {bool commit = true}) {
    final v = (m / step).round() * step;
    setState(
      () => _bed = v.clamp(
        _wake + minAwakeMinutes,
        Duration.minutesPerDay - step,
      ),
    );
    if (commit) _commit();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(DotSpace.l),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.s,
        children: [
          DotIcon(DotGlyphs.sunrise, color: t.tasks[TaskColor.amber].color),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) => _track(context, t, box.maxWidth),
            ),
          ),
          DotIcon(DotGlyphs.moon, color: t.tasks[TaskColor.violet].color),
        ],
      ),
    );
  }

  Widget _track(BuildContext context, DotTheme t, double width) {
    final span = width - _handle;
    double x(int minute) => span * minute / Duration.minutesPerDay;
    int minuteAt(double dx) =>
        ((dx - _handle / 2) / span * Duration.minutesPerDay).round();
    final wakeX = x(wakeMinute);
    final bedX = x(bedMinute);
    final label = t.styles.rowMeta.copyWith(
      color: t.colors.text,
      fontWeight: FontWeight.w600,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => _dragging = true,
      onHorizontalDragUpdate: (d) {
        final m = minuteAt(d.localPosition.dx);
        (m - wakeMinute).abs() <= (m - bedMinute).abs()
            ? _setWake(m, commit: false)
            : _setBed(m, commit: false);
      },
      onHorizontalDragEnd: (_) {
        _dragging = false;
        _commit();
      },
      child: SizedBox(
        height: DotTouch.android + DotSpace.xl * 2,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: _handle / 2,
              right: _handle / 2,
              top: DotTouch.android / 2 - DotSize.segment / 2,
              height: DotSize.segment,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: t.colors.outline,
                  borderRadius: BorderRadius.circular(DotRadii.pill),
                ),
              ),
            ),
            Positioned(
              left: wakeX + _handle / 2,
              width: bedX - wakeX,
              top: DotTouch.android / 2 - DotSize.segment / 2,
              height: DotSize.segment,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: t.colors.accent,
                  borderRadius: BorderRadius.circular(DotRadii.pill),
                ),
              ),
            ),
            _handleAt(context, wakeX, wakeMinute, widget.wakeLabel, _setWake),
            _handleAt(context, bedX, bedMinute, widget.bedLabel, _setBed),
            _below(wakeX, Text(widget.timeText(wakeMinute), style: label)),
            _below(bedX, Text(widget.timeText(bedMinute), style: label)),
            Positioned(
              left: 0,
              right: 0,
              // Its own line under the times, so it never meets them.
              top: DotTouch.android + DotSpace.xl - DotSpace.xxs,
              child: Text(
                widget.awakeText(bedMinute - wakeMinute),
                textAlign: TextAlign.center,
                style: t.styles.rowMeta.copyWith(color: t.colors.accentInk),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _below(double at, Widget child) => Positioned(
    left: at - DotSpace.xl,
    width: _handle + DotSpace.xl * 2,
    top: DotTouch.android - DotSpace.xxs,
    child: Center(child: child),
  );

  Widget _handleAt(
    BuildContext context,
    double at,
    int minute,
    String name,
    ValueChanged<int> set,
  ) => Positioned(
    left: at + _handle / 2 - DotTouch.android / 2,
    top: 0,
    width: DotTouch.android,
    height: DotTouch.android,
    child: _Handle(
      name: name,
      value: widget.timeText(minute),
      increased: widget.timeText(
        (minute + step).clamp(0, Duration.minutesPerDay),
      ),
      decreased: widget.timeText(
        (minute - step).clamp(0, Duration.minutesPerDay),
      ),
      onStep: (steps) => set(minute + steps * step),
    ),
  );
}

/// One handle: a focusable slider (arrows, Page Up/Down, screen reader).
class _Handle extends StatelessWidget {
  const _Handle({
    required this.name,
    required this.value,
    required this.increased,
    required this.decreased,
    required this.onStep,
  });

  final String name;
  final String value;
  final String increased;
  final String decreased;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      slider: true,
      label: name,
      value: value,
      increasedValue: increased,
      decreasedValue: decreased,
      onIncrease: () => onStep(1),
      onDecrease: () => onStep(-1),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowRight): () => onStep(1),
          const SingleActivator(LogicalKeyboardKey.arrowUp): () => onStep(1),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => onStep(-1),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () => onStep(-1),
          const SingleActivator(LogicalKeyboardKey.pageUp): () => onStep(4),
          const SingleActivator(LogicalKeyboardKey.pageDown): () => onStep(-4),
        },
        child: Focus(
          child: Builder(
            builder: (context) {
              final focused = Focus.of(context).hasFocus;
              return Center(
                child: Container(
                  width: DayShapeSlider._handle,
                  height: DayShapeSlider._handle,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.colors.raised,
                    border: Border.all(
                      color: t.colors.accent,
                      width: focused
                          ? DotSize.dotOutline * 2
                          : DotSize.dotOutline,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
