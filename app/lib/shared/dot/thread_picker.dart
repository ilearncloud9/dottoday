import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread_picker_pieces.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'package:dottoday/shared/dot/thread_picker_pieces.dart' show PickerBlock;

/// Height of the visible slice.
const double pickerHeight = 236;

/// Where the selection window's top sits in the slice (share of height).
const double _windowAt = 0.4;

/// `ThreadPicker` (docs/10 §3): a slice of the day's thread scrolling
/// under a fixed selection window. Neighbours stay visible; the new task's
/// segment is drawn in its colour inside the window, so a time is never
/// picked blind (§6).
///
/// Times are minutes after the day's local midnight. Scrolling, arrow keys
/// (±[snapMinutes], Page Up/Down ±1 h) and the screen reader's increase /
/// decrease all move the start in [snapMinutes] steps and call
/// [onChanged]. A leaf: its only state is the scroll position.
class ThreadPicker extends StatefulWidget {
  const ThreadPicker({
    required this.blocks,
    required this.startMinute,
    required this.durationMin,
    required this.color,
    required this.icon,
    required this.rangeText,
    required this.hourText,
    required this.bedMinute,
    required this.bedText,
    required this.onChanged,
    this.snapMinutes = 5,
    super.key,
  });

  /// The day's other tasks.
  final List<PickerBlock> blocks;
  final int startMinute;
  final int durationMin;
  final TaskColor color;
  final TaskIcon icon;

  /// "5:00 – 6:00 PM" for a start minute (the window's pill, the value
  /// read out).
  final String Function(int startMinute) rangeText;

  /// "4 PM" for an hour's minute.
  final String Function(int minute) hourText;

  /// Wind Down, and its cap "Wind Down · 22:00".
  final int bedMinute;
  final String bedText;
  final ValueChanged<int> onChanged;
  final int snapMinutes;

  @override
  State<ThreadPicker> createState() => _ThreadPickerState();
}

class _ThreadPickerState extends State<ThreadPicker> {
  late final _scroll = ScrollController(
    initialScrollOffset: widget.startMinute * pickerScale,
  );
  final _focus = FocusNode();
  var _userScrolling = false;
  late int _emitted = widget.startMinute;

  int get _maxStart => Duration.minutesPerDay - widget.snapMinutes;

  @override
  void didUpdateWidget(ThreadPicker old) {
    super.didUpdateWidget(old);
    if (_userScrolling || widget.startMinute == _emitted) return;
    _emitted = widget.startMinute;
    if (_scroll.hasClients) _scroll.jumpTo(widget.startMinute * pickerScale);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  int _snap(double offset) {
    final raw = offset / pickerScale;
    final step = widget.snapMinutes;
    return ((raw / step).round() * step).clamp(0, _maxStart);
  }

  void _emit(int minute) {
    if (minute == _emitted) return;
    _emitted = minute;
    widget.onChanged(minute);
  }

  bool _onScroll(ScrollNotification n) {
    if (n is ScrollStartNotification && n.dragDetails != null) {
      _userScrolling = true;
    }
    if (n is ScrollUpdateNotification && _userScrolling) {
      _emit(_snap(n.metrics.pixels));
    }
    if (n is ScrollEndNotification && _userScrolling) {
      _userScrolling = false;
      final minute = _snap(n.metrics.pixels);
      _emit(minute);
      // Settle on the snapped minute after the fling.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(minute * pickerScale);
      });
    }
    return false;
  }

  void _step(int minutes) {
    final next = (_emitted + minutes).clamp(0, _maxStart);
    _emit(next);
    if (_scroll.hasClients) _scroll.jumpTo(next * pickerScale);
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final snap = widget.snapMinutes;
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowUp): _StepIntent(-1),
        SingleActivator(LogicalKeyboardKey.arrowDown): _StepIntent(1),
        SingleActivator(LogicalKeyboardKey.pageUp): _StepIntent(-12),
        SingleActivator(LogicalKeyboardKey.pageDown): _StepIntent(12),
      },
      child: Actions(
        actions: {
          _StepIntent: CallbackAction<_StepIntent>(
            onInvoke: (i) => _step(i.steps * snap),
          ),
        },
        child: Focus(
          focusNode: _focus,
          child: ListenableBuilder(
            listenable: _focus,
            builder: (context, child) => _frame(t, child!),
            child: _semantics(context, t),
          ),
        ),
      ),
    );
  }

  Widget _frame(DotTheme t, Widget child) => DecoratedBox(
    position: DecorationPosition.foreground,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(DotRadii.card),
      border: Border.all(
        color: _focus.hasFocus ? t.colors.accent : t.colors.outline,
        width: _focus.hasFocus ? DotSize.freeLine : DotSpace.hairline,
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(DotRadii.card),
      child: child,
    ),
  );

  Widget _semantics(BuildContext context, DotTheme t) {
    final snap = widget.snapMinutes;
    final now = _emitted;
    return Semantics(
      slider: true,
      label: context.l10n.pickerLabel,
      value: widget.rangeText(now),
      increasedValue: widget.rangeText((now + snap).clamp(0, _maxStart)),
      decreasedValue: widget.rangeText((now - snap).clamp(0, _maxStart)),
      onIncrease: () => _step(snap),
      onDecrease: () => _step(-snap),
      child: GestureDetector(
        onTap: _focus.requestFocus,
        child: SizedBox(height: pickerHeight, child: _slice(t)),
      ),
    );
  }

  Widget _slice(DotTheme t) {
    const top = pickerHeight * _windowAt;
    final window = widget.durationMin * pickerScale;
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: ExcludeSemantics(
            child: SingleChildScrollView(
              controller: _scroll,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(
                top: top,
                bottom: pickerHeight - top,
              ),
              child: PickerDay(
                blocks: widget.blocks,
                hourText: widget.hourText,
                bedMinute: widget.bedMinute,
                bedText: widget.bedText,
              ),
            ),
          ),
        ),
        _window(top, window),
      ],
    );
  }

  Widget _window(double top, double window) => Positioned(
    top: top,
    left: 0,
    right: 0,
    // The task's own length, so neighbours right after it stay visible;
    // at least its dot. The whole slice is the touch target.
    height: window < DotSize.pickerDot ? DotSize.pickerDot : window,
    // The slider reads the range itself; the pill would repeat it.
    child: IgnorePointer(
      child: ExcludeSemantics(
        child: PickerWindow(
          color: widget.color,
          icon: widget.icon,
          segment: window,
          label: widget.rangeText(_emitted),
        ),
      ),
    ),
  );
}

final class _StepIntent extends Intent {
  const _StepIntent(this.steps);

  final int steps;
}
