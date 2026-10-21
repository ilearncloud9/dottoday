import 'dart:math' as math;

import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/layout/time_scale.dart';
import 'package:dottoday/features/timeline/layout/timeline_day.dart';

/// Where one block sits: vertical extent in pixels and its overlap column.
final class BlockPlacement {
  const BlockPlacement({
    required this.block,
    required this.top,
    required this.height,
    required this.column,
    required this.columns,
    required this.startsBefore,
    required this.endsAfter,
  });

  final Occurrence block;
  final double top;
  final double height;

  /// 0-based column within [columns] side-by-side columns.
  final int column;
  final int columns;

  /// Whether the block began on the previous day / runs into the next one.
  final bool startsBefore;
  final bool endsAfter;

  double get bottom => top + height;
}

/// "+n" marker for blocks that didn't fit in the column limit.
final class OverflowMarker {
  const OverflowMarker({required this.top, required this.hidden});

  final double top;
  final List<Occurrence> hidden;
}

/// The positioned blocks of a day (docs/02 F1 "overlapping blocks render
/// side-by-side, max 3 columns, then +n").
final class DayLayout {
  const DayLayout({required this.placements, required this.overflow});

  /// Ordered by top, then longest first.
  final List<BlockPlacement> placements;
  final List<OverflowMarker> overflow;

  /// Placements intersecting the pixel range `[from, to)`.
  Iterable<BlockPlacement> visibleIn(double from, double to) =>
      placements.where((p) => p.top < to && p.bottom > from);
}

/// Lays out [blocks] on [scale]. Heights never go below [minHeight] so
/// short blocks stay tappable and readable; overlap is computed on these
/// drawn extents, so blocks never paint over each other.
DayLayout layoutDay({
  required List<Occurrence> blocks,
  required TimelineDay day,
  required TimeScale scale,
  required double minHeight,
  int maxColumns = 3,
}) {
  final items = [
    for (final o in blocks)
      if (o.startUtc != null) _measure(o, day, scale, minHeight),
  ]..sort(_byTopThenLongest);
  final placements = <BlockPlacement>[];
  final overflow = <OverflowMarker>[];
  var cluster = <_Item>[];
  var clusterBottom = double.negativeInfinity;
  void flush() {
    _placeCluster(cluster, maxColumns, placements, overflow, minHeight);
    cluster = [];
  }

  for (final item in items) {
    if (item.top >= clusterBottom) flush();
    cluster.add(item);
    clusterBottom = math.max(clusterBottom, item.bottom);
  }
  flush();
  return DayLayout(placements: placements, overflow: overflow);
}

final class _Item {
  _Item(this.block, this.top, this.bottom, this.before, this.after);

  final Occurrence block;
  final double top;
  final double bottom;
  final bool before;
  final bool after;
  int column = 0;
}

_Item _measure(Occurrence o, TimelineDay day, TimeScale scale, double min) {
  final start = day.minuteOf(o.startUtc!);
  final end = day.minuteOf(o.endUtc!);
  final top = scale.yOf(start);
  final bottom = math.max(scale.yOf(end), top + min);
  return _Item(o, top, bottom, start < 0, end > day.minutes);
}

int _byTopThenLongest(_Item a, _Item b) {
  final byTop = a.top.compareTo(b.top);
  if (byTop != 0) return byTop;
  final byLength = b.bottom.compareTo(a.bottom);
  return byLength != 0 ? byLength : a.block.id.compareTo(b.block.id);
}

/// Greedy first-free-column assignment for one overlap cluster.
void _placeCluster(
  List<_Item> cluster,
  int maxColumns,
  List<BlockPlacement> out,
  List<OverflowMarker> overflow,
  double markerHeight,
) {
  if (cluster.isEmpty) return;
  final columnBottoms = <double>[];
  for (final item in cluster) {
    var col = columnBottoms.indexWhere((b) => b <= item.top);
    if (col < 0) {
      col = columnBottoms.length;
      columnBottoms.add(item.bottom);
    } else {
      columnBottoms[col] = item.bottom;
    }
    item.column = col;
  }
  final columns = math.min(columnBottoms.length, maxColumns);
  for (final item in cluster) {
    if (item.column >= maxColumns) {
      _addHidden(overflow, item, markerHeight);
      continue;
    }
    out.add(
      BlockPlacement(
        block: item.block,
        top: item.top,
        height: item.bottom - item.top,
        column: item.column,
        columns: columns,
        startsBefore: item.before,
        endsAfter: item.after,
      ),
    );
  }
}

/// Hidden blocks starting within one marker height share a marker.
void _addHidden(List<OverflowMarker> overflow, _Item item, double height) {
  final last = overflow.lastOrNull;
  if (last != null && item.top < last.top + height) {
    overflow[overflow.length - 1] = OverflowMarker(
      top: last.top,
      hidden: [...last.hidden, item.block],
    );
    return;
  }
  overflow.add(OverflowMarker(top: item.top, hidden: [item.block]));
}
