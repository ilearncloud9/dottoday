import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/features/timeline/layout/day_layout.dart';
import 'package:dottoday/features/timeline/layout/drag_math.dart';
import 'package:dottoday/features/timeline/layout/timeline_geometry.dart';
import 'package:dottoday/features/timeline/state/timeline_interaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Turns pointer positions into a [DragSession] (docs/03 §3.2, R-05):
/// global y → canvas y → elapsed minute via the one `TimeScale`, snapped to
/// the user's grid. Scrolls the day when the pointer nears an edge. The
/// drop itself is committed by [onDrop].
final class DragCoordinator {
  DragCoordinator({
    required this.ref,
    required this.scroll,
    required this.canvasKey,
    required this.viewportKey,
    required this.vsync,
    required this.onDrop,
    required this.onPinned,
  });

  final WidgetRef ref;
  final ScrollController scroll;

  /// The full-height day canvas (pointer → canvas y).
  final GlobalKey canvasKey;

  /// The scroll viewport (auto-scroll edge zones).
  final GlobalKey viewportKey;
  final TickerProvider vsync;
  final void Function(DragSession session) onDrop;

  /// Long-press on a pinned block: explain instead of moving (R-17).
  final VoidCallback onPinned;

  late TimelineGeometry geometry;
  late int snap;

  Offset? _pointer;
  Ticker? _ticker;

  TimelineInteraction get _state =>
      ref.read(timelineInteractionProvider.notifier);

  DragSession? get _session => ref.read(timelineInteractionProvider).drag;

  double? _minuteAt(Offset global) {
    final box = canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    return geometry.scale.minuteAt(box.globalToLocal(global).dy);
  }

  /// Picks up [p] for [mode]. Returns false when nothing started.
  bool start(BlockPlacement p, Offset global, DragMode mode) {
    final o = p.block;
    if (mode == DragMode.move && o.pinned) {
      unawaited(HapticFeedback.heavyImpact());
      onPinned();
      return false;
    }
    final pointer = _minuteAt(global);
    if (pointer == null) return false;
    final start = geometry.day.minuteOf(o.startUtc!).round();
    final slot = (start: start, duration: o.durationMin);
    _pointer = global;
    _state.begin(
      DragSession(
        block: o,
        mode: mode,
        original: slot,
        proposed: slot,
        grabOffsetMin: pointer - start,
      ),
    );
    // Light tap on pick-up (03 §1 "Haptics").
    unawaited(HapticFeedback.lightImpact());
    return true;
  }

  /// Follows the pointer; a selection tick on every snap step.
  void update(Offset global) {
    _pointer = global;
    _propose();
    _autoScroll();
  }

  void _propose() {
    final s = _session;
    final global = _pointer;
    if (s == null || global == null) return;
    final m = _minuteAt(global);
    if (m == null) return;
    final slot = switch (s.mode) {
      DragMode.move => moveSlot(
        pointerMin: m,
        grabOffsetMin: s.grabOffsetMin,
        duration: s.original.duration,
        snap: snap,
        dayMinutes: geometry.day.minutes,
      ),
      DragMode.resizeStart => resizeStartSlot(
        pointerMin: m,
        original: s.original,
        snap: snap,
      ),
      DragMode.resizeEnd => resizeEndSlot(
        pointerMin: m,
        original: s.original,
        snap: snap,
      ),
    };
    if (_state.propose(slot)) unawaited(HapticFeedback.selectionClick());
  }

  void _autoScroll() {
    final speed = _edgeSpeed();
    if (speed == 0) {
      _ticker?.stop();
      return;
    }
    _ticker ??= vsync.createTicker((_) => _scrollStep());
    if (!_ticker!.isActive) unawaited(_ticker!.start());
  }

  /// Signed px per frame: negative near the top, positive near the bottom.
  double _edgeSpeed() {
    final global = _pointer;
    final box = viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (global == null || box == null || !box.attached) return 0;
    final y = box.globalToLocal(global).dy;
    final up = autoScrollSpeed(y);
    if (up > 0) return -up;
    return autoScrollSpeed(box.size.height - y);
  }

  void _scrollStep() {
    final speed = _edgeSpeed();
    if (speed == 0 || !scroll.hasClients || _session == null) {
      _ticker?.stop();
      return;
    }
    final pos = scroll.position;
    final next = (pos.pixels + speed).clamp(0.0, pos.maxScrollExtent);
    if (next == pos.pixels) return;
    scroll.jumpTo(next);
    _propose();
  }

  /// Drops the block where it is proposed.
  void end() {
    _ticker?.stop();
    final s = _session;
    _state.end();
    _pointer = null;
    if (s != null && s.proposed != s.original) onDrop(s);
  }

  /// Abandons the drag without writing.
  void cancel() {
    _ticker?.stop();
    _state.end();
    _pointer = null;
  }

  void dispose() => _ticker?.dispose();
}

/// Makes the [DragCoordinator] reachable from tiles and handles.
class DragScope extends InheritedWidget {
  const DragScope({required this.coordinator, required super.child, super.key});

  final DragCoordinator coordinator;

  static DragCoordinator? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DragScope>()?.coordinator;

  @override
  bool updateShouldNotify(DragScope old) => old.coordinator != coordinator;
}

/// The "pinned blocks stay put" hint.
void showPinnedHint(BuildContext context) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(context.l10n.dragPinned)));
}
