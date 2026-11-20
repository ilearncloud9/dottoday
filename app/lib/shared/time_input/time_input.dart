import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/shared/feedback/field_error.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
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
    this.compact = false,
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

  /// The Workspace inspector's small box (E-FullA-v2: 26 tall, centred,
  /// 12.5): the label goes to screen readers only, there is no wheel, and
  /// text that isn't a time puts the last time back.
  final bool compact;

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
    if (parsed == null && widget.compact) return _showValue(_current);
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
    if (widget.compact) return _compact(context);
    final l10n = context.l10n;
    final t = DotTheme.of(context);
    return TextField(
      contextMenuBuilder: systemTextMenu,
      controller: _controller,
      focusNode: _focus,
      style: t.styles.body.copyWith(
        fontFeatures: t.styles.rowMeta.fontFeatures,
      ),
      keyboardType: TextInputType.datetime,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      enableSuggestions: false,
      onSubmitted: _commit,
      decoration: InputDecoration(
        labelText: widget.label ?? l10n.timeInputLabel,
        hintText: l10n.timeInputHint,
        error: _invalid ? FieldError(l10n.timeInputInvalid) : null,
        // The Mac types times, as macOS does: no picker button there.
        suffixIcon: widget.showWheel && !macApp(context)
            ? IconButton(
                onPressed: _openWheel,
                tooltip: l10n.timeInputPick,
                icon: DotIcon(
                  DotGlyphs.clock,
                  color: DotTheme.of(context).colors.muted,
                ),
              )
            : null,
      ),
    );
  }

  Widget _compact(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final edge = OutlineInputBorder(
      borderRadius: BorderRadius.circular(DotRadii.field),
      borderSide: BorderSide(color: c.hairlineStrong),
    );
    return Semantics(
      label: widget.label ?? context.l10n.timeInputLabel,
      child: TextField(
        contextMenuBuilder: systemTextMenu,
        controller: _controller,
        focusNode: _focus,
        textAlign: TextAlign.center,
        style: t.styles.inspectorValue.copyWith(
          fontFeatures: t.styles.rowMeta.fontFeatures,
        ),
        keyboardType: TextInputType.datetime,
        textInputAction: TextInputAction.done,
        autocorrect: false,
        enableSuggestions: false,
        onSubmitted: _commit,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: c.raised,
          contentPadding: const EdgeInsets.symmetric(vertical: DotSpace.xs),
          border: edge,
          enabledBorder: edge,
          focusedBorder: edge.copyWith(
            borderSide: BorderSide(color: c.focus, width: DotSpace.xxs),
          ),
        ),
      ),
    );
  }
}
