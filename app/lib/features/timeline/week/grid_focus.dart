import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Arrow keys between the hour grid's blocks (handoff "Week", owner M19.2
/// part 3b): ↑ ↓ the block before or after on the same day, ← → the block
/// nearest in time on the closest day either side that has one. Alt with
/// the arrows still moves the task (ED-390); Return opens it.
///
/// [GridFocus] holds the blocks on screen; each [GridFocusTarget]
/// registers its block's focus node with its day and start.
class GridFocus extends StatefulWidget {
  const GridFocus({required this.child, super.key});

  final Widget child;

  @override
  State<GridFocus> createState() => _GridFocusState();
}

class _GridFocusState extends State<GridFocus> {
  final _map = GridFocusMap();

  @override
  Widget build(BuildContext context) =>
      _GridFocusScope(map: _map, child: widget.child);
}

class _GridFocusScope extends InheritedWidget {
  const _GridFocusScope({required this.map, required super.child});

  final GridFocusMap map;

  @override
  bool updateShouldNotify(_GridFocusScope old) => old.map != map;
}

/// Where a block sits: its day and its start, in minutes from the axis.
typedef GridSlot = ({DateTime day, int minute});

/// The registered blocks and the step between them. Keyed by each
/// block's focus node: a task across midnight shows on two days, with one
/// id.
class GridFocusMap {
  final _entries = <FocusNode, ({String id, GridSlot slot})>{};

  void _add(FocusNode node, String id, GridSlot slot) =>
      _entries[node] = (id: id, slot: slot);

  void _remove(FocusNode node) => _entries.remove(node);

  /// The block a press of [key] reaches from [from], or null at an edge.
  FocusNode? next(FocusNode from, LogicalKeyboardKey key) {
    final at = _entries[from]?.slot;
    if (at == null) return null;
    final days = {for (final e in _entries.values) e.slot.day}.toList()..sort();
    List<FocusNode> on(DateTime day) =>
        [
          for (final MapEntry(:key, :value) in _entries.entries)
            if (value.slot.day == day) key,
        ]..sort((a, b) {
          final x = _entries[a]!;
          final y = _entries[b]!;
          final c = x.slot.minute.compareTo(y.slot.minute);
          return c != 0 ? c : x.id.compareTo(y.id);
        });
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown) {
      final column = on(at.day);
      final j =
          column.indexOf(from) + (key == LogicalKeyboardKey.arrowUp ? -1 : 1);
      return j < 0 || j >= column.length ? null : column[j];
    }
    final d =
        days.indexOf(at.day) + (key == LogicalKeyboardKey.arrowLeft ? -1 : 1);
    if (d < 0 || d >= days.length) return null;
    int gap(FocusNode n) => (_entries[n]!.slot.minute - at.minute).abs();
    return on(days[d]).reduce((a, b) => gap(b) < gap(a) ? b : a);
  }

  /// Moves focus from [from] by [key]; true when it moved.
  bool step(FocusNode from, LogicalKeyboardKey key) {
    final node = next(from, key);
    if (node == null) return false;
    node.requestFocus();
    if (node.context case final c?) {
      unawaited(Scrollable.ensureVisible(c, alignment: 0.5));
    }
    return true;
  }
}

/// One block's focus, registered with the nearest [GridFocus]; [builder]
/// hands the node to the block's own tap target. Outside a [GridFocus]
/// (the lifted copy, the phone) it is a plain node with no arrows.
class GridFocusTarget extends StatefulWidget {
  const GridFocusTarget({
    required this.id,
    required this.slot,
    required this.builder,
    super.key,
  });

  final String id;
  final GridSlot? slot;
  final Widget Function(FocusNode node) builder;

  @override
  State<GridFocusTarget> createState() => _GridFocusTargetState();
}

class _GridFocusTargetState extends State<GridFocusTarget> {
  final _node = FocusNode();
  GridFocusMap? _map;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _register();
  }

  @override
  void didUpdateWidget(GridFocusTarget old) {
    super.didUpdateWidget(old);
    _register();
  }

  void _register() {
    final map = context
        .dependOnInheritedWidgetOfExactType<_GridFocusScope>()
        ?.map;
    if (map != _map) _map?._remove(_node);
    _map = map;
    switch (widget.slot) {
      case final slot?:
        map?._add(_node, widget.id, slot);
      case null:
        map?._remove(_node);
    }
  }

  @override
  void dispose() {
    _map?._remove(_node);
    _node.dispose();
    super.dispose();
  }

  KeyEventResult _key(FocusNode _, KeyEvent event) {
    final map = _map;
    if (map == null || event is KeyUpEvent) return KeyEventResult.ignored;
    final keys = HardwareKeyboard.instance;
    if (keys.isAltPressed ||
        keys.isMetaPressed ||
        keys.isControlPressed ||
        keys.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    final arrows = {
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
    };
    var key = event.logicalKey;
    if (!arrows.contains(key)) return KeyEventResult.ignored;
    // Right to left, the days run the other way.
    if (Directionality.of(context) == TextDirection.rtl) {
      key = switch (key) {
        LogicalKeyboardKey.arrowLeft => LogicalKeyboardKey.arrowRight,
        LogicalKeyboardKey.arrowRight => LogicalKeyboardKey.arrowLeft,
        _ => key,
      };
    }
    // At an edge the key stays here, so it never scrolls the grid away.
    map.step(_node, key);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    skipTraversal: true,
    includeSemantics: false,
    onKeyEvent: _key,
    child: widget.builder(_node),
  );
}
