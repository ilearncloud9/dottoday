import 'dart:math' as math;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/scheduling/week_summary.dart';
import 'package:dottoday/features/timeline/week/grid_gutter.dart';
import 'package:dottoday/features/timeline/week/grid_headers.dart';
import 'package:dottoday/features/timeline/week/grid_scale.dart';
import 'package:dottoday/shared/dot/thread.dart' show hourGutter;
import 'package:flutter/material.dart';

/// The hour grid (E-FullA-v2 Week, M19.2 part 2) for Week and 3 days: a
/// header per day, the hour labels in a 44 gutter, and the day [columns]
/// at 84 px an hour. Columns share the width but never go under 144; when
/// the days don't fit they scroll sideways under their headers (owner,
/// M19.2: the days that fit, scroll for more). On today the now line runs
/// across the grid with its time in the gutter.
class WeekBoard extends StatefulWidget {
  const WeekBoard({
    required this.loads,
    required this.today,
    required this.hourLabels,
    required this.axisMinutes,
    required this.columns,
    this.nowY,
    this.nowText,
    this.long = false,
    super.key,
  });

  final List<DayLoad> loads;
  final DateTime today;

  /// "7 AM", "8 AM" … for every whole hour of the axis.
  final List<String> hourLabels;
  final int axisMinutes;
  final List<Widget> columns;

  /// Now, in px down the axis, and its time ("10:42"), when today shows.
  final double? nowY;
  final String? nowText;

  /// 3 days' headers (E-R2-30): "Monday 2 November · Yesterday" over
  /// "4 of 4 done".
  final bool long;

  @override
  State<WeekBoard> createState() => _WeekBoardState();
}

/// A leaf: the scroll positions only.
class _WeekBoardState extends State<WeekBoard> {
  late final ScrollController _down;
  final _across = ScrollController();
  final _heads = ScrollController();

  @override
  void initState() {
    super.initState();
    // Opens with now a little below the top (two hours above it).
    final now = widget.nowY;
    _down = ScrollController(
      initialScrollOffset: now == null
          ? 0
          : math.max(0, now - GridScale.peek(context).hour * 2),
    );
    _across.addListener(() {
      if (_heads.hasClients) _heads.jumpTo(_across.offset);
    });
  }

  @override
  void dispose() {
    _down.dispose();
    _across.dispose();
    _heads.dispose();
    super.dispose();
  }

  double get _height => widget.axisMinutes * GridScale.of(context).pxPerMinute;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final gutter = hourGutter(context);
      final room = box.maxWidth - gutter;
      final n = widget.columns.length;
      final width = math.max(GridScale.of(context).column, room / n);
      _showToday(width, room);
      return ColoredBox(
        color: DotTheme.of(context).colors.canvas,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: box.maxHeight.isFinite
                    ? box.maxHeight / 2
                    : double.infinity,
              ),
              child: _headers(context, width),
            ),
            Expanded(child: _grid(context, width)),
          ],
        ),
      );
    },
  );

  bool _placed = false;

  /// Opens with today in view when the days don't all fit, the day before
  /// it at the left (E-R2-2: Tue–Thu, today second; ED-169 on the Mac).
  void _showToday(double width, double room) {
    if (_placed) return;
    _placed = true;
    final i = widget.loads.indexWhere((d) => d.date == widget.today);
    if (i < 0 || (i + 1) * width <= room) return;
    final x = math.max(0, i - 1) * width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_across.hasClients) return;
      _across.jumpTo(math.min(x, _across.position.maxScrollExtent));
    });
  }

  /// The day headers over the columns, moving sideways with them; a
  /// hairline under them. At large text they grow and scroll themselves.
  Widget _headers(BuildContext context, double width) {
    final c = DotTheme.of(context).colors;
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.hairline)),
      ),
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: hourGutter(context)),
            Expanded(
              child: SingleChildScrollView(
                controller: _heads,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final d in widget.loads)
                        SizedBox(
                          width: width,
                          child: widget.long
                              ? GridLongHeader(load: d, today: widget.today)
                              : GridDayHeader(load: d, today: widget.today),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid(BuildContext context, double width) {
    final c = DotTheme.of(context).colors;
    final now = widget.nowY;
    return SingleChildScrollView(
      controller: _down,
      child: SizedBox(
        height: _height,
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: hourGutter(context),
                  child: GridHourLabels(labels: widget.hourLabels),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _across,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final col in widget.columns)
                          SizedBox(width: width, height: _height, child: col),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (now != null) ...[
              Positioned(
                left: hourGutter(context),
                right: 0,
                top: now,
                height: DotSpace.hairline,
                child: IgnorePointer(child: ColoredBox(color: c.nowLine)),
              ),
              if (widget.nowText case final text?)
                Positioned(
                  left: DotSpace.xxs + DotSpace.hairline,
                  top: now - DotSpace.s,
                  child: GridNowBead(text: text),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
