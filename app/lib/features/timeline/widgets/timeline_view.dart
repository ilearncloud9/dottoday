import 'dart:math' as math;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/timeline/layout/timeline_geometry.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/all_day_strip.dart';
import 'package:dottoday/features/timeline/widgets/day_canvas.dart';
import 'package:dottoday/features/timeline/widgets/hidden_blocks_sheet.dart';
import 'package:dottoday/features/timeline/widgets/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Text scale applied to timeline density, capped at Dynamic Type 200 %.
double timelineTextScale(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(1).clamp(1, 2).toDouble();

/// Scrollable day: optional all-day strip, then the full 24 h canvas
/// (docs/03 §3.1). Opens scrolled to now (today) or the day start.
class TimelineView extends ConsumerStatefulWidget {
  const TimelineView({required this.data, required this.isToday, super.key});

  final TimelineData data;
  final bool isToday;

  @override
  ConsumerState<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends ConsumerState<TimelineView> {
  final _scroll = ScrollController();
  bool _scrolledInitially = false;

  /// The canvas built for the last lazy window. The sliver builder runs on
  /// every scroll frame; returning the identical widget skips the rebuild
  /// until the window or inputs change (R-15).
  Widget? _canvas;
  Object? _canvasInputs;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  TimelineGeometry _geometry(({bool before, bool after}) expanded) {
    final s = timelineTextScale(context);
    final data = widget.data;
    return TimelineGeometry.build(
      day: data.day,
      blocks: data.blocks,
      boundary: data.settings.boundaryFor(data.day.weekday),
      density: (
        pxPerMin: AppTimeline.pxPerMinute * s,
        collapsedPxPerMin: AppTimeline.collapsedPxPerMinute * s,
        minBlockHeight: AppTimeline.minBlockHeight * s,
      ),
      expanded: expanded,
    );
  }

  void _scrollToStart(TimelineGeometry g) {
    if (_scrolledInitially) return;
    _scrolledInitially = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final now = ref.read(minuteTickProvider).value;
      final nowMin = now == null ? null : g.day.minuteOf(now);
      final target = widget.isToday && nowMin != null
          ? g.scale.yOf(nowMin - 60)
          : g.scale.yOf(g.coreFrom);
      _scroll.jumpTo(
        math.min(math.max(0, target), _scroll.position.maxScrollExtent),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final expanded = ref.watch(outsideHoursProvider);
    final g = _geometry(expanded);
    final use24h = use24hFor(context, widget.data.settings.use24h);
    final gutter = AppTimeline.gutterWidth * timelineTextScale(context);
    _scrollToStart(g);
    _actionsNow = _actions(context, g, expanded, use24h);
    // The all-day strip stays put above the scrolling day, so all-day items
    // are visible wherever the day is scrolled to.
    final day = LayoutBuilder(
      builder: (context, box) => CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverLayoutBuilder(
            builder: (context, c) => SliverToBoxAdapter(
              child: _canvasFor(_window(c), g, box.maxWidth, gutter, use24h),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
          ),
        ],
      ),
    );
    if (widget.data.allDay.isEmpty) return day;
    return Column(
      children: [
        AllDayStrip(items: widget.data.allDay),
        Expanded(child: day),
      ],
    );
  }

  late DayCanvasActions _actionsNow;

  /// The canvas for the lazy window [w], reused while nothing changed.
  Widget _canvasFor(
    (double, double) w,
    TimelineGeometry g,
    double width,
    double gutter,
    bool use24h,
  ) {
    final inputs = (g, width, gutter, use24h, w);
    if (inputs == _canvasInputs) return _canvas!;
    _canvasInputs = inputs;
    return _canvas = DayCanvas(
      geometry: g,
      width: width,
      gutter: gutter,
      use24h: use24h,
      showNow: widget.isToday,
      from: w.$1,
      to: w.$2,
      actions: _actionsNow,
    );
  }

  /// The visible+cache range, widened to whole [AppTimeline.lazyBucket]s so
  /// the block set only changes when scrolling crosses a bucket edge.
  (double, double) _window(SliverConstraints c) {
    const b = AppTimeline.lazyBucket;
    final start = c.scrollOffset + c.cacheOrigin;
    final end = start + c.remainingCacheExtent;
    return ((start / b).floor() * b, ((end / b).ceil() + 1) * b);
  }

  DayCanvasActions _actions(
    BuildContext context,
    TimelineGeometry g,
    ({bool before, bool after}) expanded,
    bool use24h,
  ) {
    String at(double minute) => hourLabel(
      context,
      ClockTime.ofUtc(
        g.day.location,
        g.day.startUtc.add(Duration(minutes: minute.round())),
      ),
      use24h: use24h,
    );
    final notifier = ref.read(outsideHoursProvider.notifier);
    final l10n = context.l10n;
    return DayCanvasActions(
      beforeLabel: l10n.timelineBeforeHours(at(g.coreFrom)),
      afterLabel: l10n.timelineAfterHours(at(g.coreTo)),
      expanded: expanded,
      onToggleBefore: notifier.toggleBefore,
      onToggleAfter: notifier.toggleAfter,
      onShowHidden: (List<Occurrence> hidden) => showHiddenBlocks(
        context,
        hidden,
        location: g.day.location,
        use24h: use24h,
      ),
    );
  }
}
