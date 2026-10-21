import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/shared/time_input/time_wheel.dart';
import 'package:flutter/material.dart';

/// Formats [time] for display, 12 h or 24 h, in the current locale.
///
/// [use24h] null follows the OS setting (`settings.use24h` null, docs/05).
String formatClockTime(BuildContext context, ClockTime time, {bool? use24h}) {
  return MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay(hour: time.hour, minute: time.minute),
    alwaysUse24HourFormat:
        use24h ?? MediaQuery.alwaysUse24HourFormatOf(context),
  );
}

/// The one time-entry component (docs/02 F2, R-20): always typeable, with an
/// optional wheel. It only ever yields a [ClockTime] — never a date — so a
/// time edit cannot move a task to another day.
///
/// Typed text is parsed on submit and when focus leaves (see
/// [ClockTime.parse]); text that isn't a time shows an error and keeps the
/// previous [value].
class TimeInput extends StatefulWidget {
  const TimeInput({
    required this.value,
    required this.onChanged,
    this.use24h,
    this.showWheel = true,
    this.label,
    super.key,
  });

  final ClockTime value;
  final ValueChanged<ClockTime> onChanged;

  /// 24-h display; null follows the OS.
  final bool? use24h;

  /// Whether to offer the wheel picker button.
  final bool showWheel;

  /// Field label; defaults to "Time".
  final String? label;

  @override
  State<TimeInput> createState() => _TimeInputState();
}

class _TimeInputState extends State<TimeInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _invalid = false;

  /// Last value shown or emitted; submit and the focus loss that follows it
  /// must not emit the same change twice.
  late ClockTime _current = widget.value;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_focus.hasFocus) _showValue(widget.value);
  }

  @override
  void didUpdateWidget(TimeInput old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _current = widget.value;
    final changed = old.value != widget.value || old.use24h != widget.use24h;
    if (changed && !_focus.hasFocus) _showValue(_current);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showValue(ClockTime time) {
    _controller.text = formatClockTime(context, time, use24h: widget.use24h);
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) _commit(_controller.text);
  }

  void _commit(String text) {
    final parsed = ClockTime.parse(text);
    if (parsed == null) {
      setState(() => _invalid = true);
      return;
    }
    setState(() => _invalid = false);
    _emit(parsed);
  }

  void _emit(ClockTime time) {
    _showValue(time);
    if (time == _current) return;
    _current = time;
    widget.onChanged(time);
  }

  Future<void> _openWheel() async {
    final picked = await showTimeWheel(
      context: context,
      initial: _current,
      use24h: widget.use24h ?? MediaQuery.alwaysUse24HourFormatOf(context),
    );
    if (picked == null || !mounted) return;
    setState(() => _invalid = false);
    _emit(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = AppTheme.of(context);
    return TextField(
      controller: _controller,
      focusNode: _focus,
      style: t.typography.body.copyWith(
        fontFeatures: t.typography.mono.fontFeatures,
      ),
      keyboardType: TextInputType.datetime,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      enableSuggestions: false,
      onSubmitted: _commit,
      decoration: InputDecoration(
        labelText: widget.label ?? l10n.timeInputLabel,
        hintText: l10n.timeInputHint,
        errorText: _invalid ? l10n.timeInputInvalid : null,
        suffixIcon: widget.showWheel
            ? IconButton(
                onPressed: _openWheel,
                tooltip: l10n.timeInputWheel,
                icon: const Icon(Icons.schedule),
              )
            : null,
      ),
    );
  }
}
