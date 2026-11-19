import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/widgets.dart';

/// The hour grid's scale: the board's pointer sizes on a Mac or a
/// mouse-driven browser (E-FullA-v2 Week, 84 px an hour), the touch sizes
/// on tablets and touch-first web (E-R2-2, ED-269, 96 px an hour). Only
/// sizes change; the parts and their places stay the same.
///
/// ```dart
/// final scale = GridScale.of(context);
/// final top = minutes * scale.pxPerMinute;
/// ```
@immutable
final class GridScale {
  const GridScale._({
    required this.touch,
    required this.hour,
    required this.column,
    required this.header,
    required this.ring,
    required this.liveRing,
    required this.pillUnder,
  });

  /// The board's pointer sizes (E-FullA-v2).
  static const pointer = GridScale._(
    touch: false,
    hour: DotSize.gridHour,
    column: DotSize.gridColumn,
    header: DotSize.gridHeader,
    ring: DotSize.gridRing,
    liveRing: DotSize.gridRing,
    pillUnder: 30,
  );

  /// The touch sizes (E-R2-2, ED-269).
  static const touchSizes = GridScale._(
    touch: true,
    hour: DotSize.gridTouchHour,
    column: DotSize.gridTouchColumn,
    header: DotSize.gridTouchHeader,
    ring: DotSize.gridTouchRing,
    liveRing: DotSize.gridTouchLiveRing,
    pillUnder: 35,
  );

  /// The axis starts half an hour before its first whole hour, so that
  /// hour's label and line clear the day headers (E-FullA-v2: 7 AM 42
  /// below them).
  static const int leadMinutes = 30;

  final bool touch;

  /// Pixels an hour.
  final double hour;

  /// The narrowest day column.
  final double column;

  /// A day header's least height.
  final double header;

  /// A block's ring, and the live task's.
  final double ring;
  final double liveRing;

  /// Shorter than this a task is a one-line pill (pointer: a 30 min task
  /// is a 42 tall block, E-FullA-v2's Dentist; touch: under 35 minutes).
  final int pillUnder;

  double get pxPerMinute => hour / Duration.minutesPerHour;

  /// A block's padding around its ring (E-R2-2: the ring at 6, 6).
  double get blockPad =>
      touch ? DotSpace.xs + DotSpace.xxs : DotSpace.xs + DotSpace.hairline;

  /// The thread's left edge in its column, under the rings' centres
  /// (touch: 4 in, 6 padding, half the 36 ring, less half the thread).
  double get threadX => touch
      ? DotSize.gridInset + blockPad + ring / 2 - DotSize.gridThread / 2
      : DotSize.gridThreadX;

  /// The ring for a task, larger while it is live on touch.
  double ringFor({required bool live}) => live ? liveRing : ring;

  /// A block's ring centre below its top.
  double ringCentre({required bool live}) => blockPad + ringFor(live: live) / 2;

  /// The least height of a block: a pill's.
  double get minCard => touch ? DotSize.gridTouchPill : DotSize.gridPill;

  /// The narrowest grid that keeps 3 days beside its hour labels.
  double get gridMin => touch ? DotSize.weekGridTouchMin : DotSize.weekGridMin;

  /// A pill's dot at [height]: 17 with a pointer; on touch 28 from 44
  /// tall, 24 below (E-R2-2's call and standup).
  double pillDot(double height) => !touch
      ? DotSize.gridPillDot
      : height >= DotSize.gridTouchPillTall
      ? DotSize.gridTouchPillDotTall
      : DotSize.gridTouchPillDot;

  /// A pill's corner at [height]: fully round, at most 16 on touch.
  double pillRadius(double height) => !touch
      ? DotSize.gridPill / 2
      : (height / 2).clamp(0, DotSize.gridTouchPillRadius).toDouble();

  TextStyle title(DotType s) => touch ? s.gridTitleTouch : s.gridTitle;
  TextStyle meta(DotType s) => touch ? s.gridMetaTouch : s.gridMeta;
  TextStyle pill(DotType s) => touch ? s.gridPillTouch : s.gridPill;
  TextStyle hourLabel(DotType s) => touch ? s.gridHourTouch : s.gridHour;
  TextStyle dayMeta(DotType s) => touch ? s.gridDayMetaTouch : s.gridDayMeta;

  /// The scale around [context]; the pointer sizes when none is set.
  static GridScale of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GridScaleScope>()?.scale ??
      pointer;

  /// The scale around [context] without depending on it (for `initState`).
  static GridScale peek(BuildContext context) =>
      context.getInheritedWidgetOfExactType<GridScaleScope>()?.scale ?? pointer;
}

/// Hands a [GridScale] to the grid below it.
class GridScaleScope extends InheritedWidget {
  const GridScaleScope({required this.scale, required super.child, super.key});

  final GridScale scale;

  @override
  bool updateShouldNotify(GridScaleScope oldWidget) => scale != oldWidget.scale;
}
