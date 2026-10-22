import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/duration_presets.dart';
import 'package:dottoday/domain/time/duration_text.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/shared/duration/duration_preview.dart';
import 'package:dottoday/shared/duration/preset_chips.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

export 'package:dottoday/shared/duration/duration_preview.dart'
    show DurationPreview;

/// Height of the hours / minutes wheel (`A-ios-add-duration`).
const double _wheelHeight = 136;

/// The Duration sheet (docs/10 §3 `DurationSheet`, `A-ios-add-duration`):
/// an hours / minutes wheel or a typed length (R-16; the wheel isn't
/// keyboard-friendly), a live preview of where the task ends, and the
/// presets — tap to use, × to remove, "+ preset" to keep the current
/// length, Reset for the defaults. Each preset change is handed to
/// [onPresets] at once. Returns the picked length, or null.
Future<int?> showDurationSheet(
  BuildContext context, {
  required int initial,
  required TaskColor color,
  required TaskIcon icon,
  required List<int> presets,
  required ValueChanged<List<int>> onPresets,
  DurationPreview Function(int minutes)? preview,
}) => showAppSheet<int>(
  context: context,
  title: context.l10n.durationSheetTitle,
  builder: (_) => _DurationSheet(
    initial: initial,
    color: color,
    icon: icon,
    presets: presets,
    onPresets: onPresets,
    preview: preview,
  ),
);

class _DurationSheet extends StatefulWidget {
  const _DurationSheet({
    required this.initial,
    required this.color,
    required this.icon,
    required this.presets,
    required this.onPresets,
    required this.preview,
  });

  final int initial;
  final TaskColor color;
  final TaskIcon icon;
  final List<int> presets;
  final ValueChanged<List<int>> onPresets;
  final DurationPreview Function(int minutes)? preview;

  @override
  State<_DurationSheet> createState() => _DurationSheetState();
}

/// A leaf: the length being picked and the presets being edited.
class _DurationSheetState extends State<_DurationSheet> {
  late int _minutes = widget.initial;
  late List<int> _presets = widget.presets;

  /// Bumped when a preset or typed length moves the wheel, so it is
  /// rebuilt at the new value.
  var _wheel = 0;
  var _invalid = false;

  void _set(int minutes, {bool moveWheel = false}) => setState(() {
    _minutes = minutes.clamp(minDurationMin, maxDurationMin);
    _invalid = false;
    if (moveWheel) _wheel++;
  });

  void _editPresets(List<int> next) {
    if (identical(next, _presets)) return;
    setState(() => _presets = next);
    widget.onPresets(next);
  }

  void _typed(String text) {
    final minutes = parseDurationText(text);
    if (minutes == null) {
      setState(() => _invalid = true);
      return;
    }
    _set(minutes, moveWheel: true);
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final preview = widget.preview?.call(_minutes);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.l,
      children: [
        _wheelBox(t),
        _typedField(l10n),
        if (preview != null)
          DurationPreviewBar(
            preview: preview,
            color: widget.color,
            icon: widget.icon,
          ),
        PresetChips(
          presets: _presets,
          value: _minutes,
          onPick: (m) => _set(m, moveWheel: true),
          onRemove: (m) => _editPresets(withoutPreset(_presets, m)),
          onAdd: () => _editPresets(withPreset(_presets, _minutes)),
          onReset: () => _editPresets(defaultDurationPresets),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_minutes),
          child: Text(l10n.timeInputDone),
        ),
      ],
    );
  }

  Widget _wheelBox(DotTheme t) => Container(
    height: _wheelHeight,
    decoration: BoxDecoration(
      color: t.colors.surface,
      borderRadius: BorderRadius.circular(DotRadii.card),
      border: Border.all(color: t.colors.outline),
    ),
    // Inter, not the platform's SF default (not bundled; would fall back
    // on Android and web): one wheel on every platform (§4).
    child: CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Theme.of(context).brightness,
        textTheme: CupertinoTextThemeData(
          pickerTextStyle: t.styles.cardTitle.copyWith(
            color: t.colors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      child: CupertinoTimerPicker(
        key: ValueKey(_wheel),
        mode: CupertinoTimerPickerMode.hm,
        initialTimerDuration: Duration(minutes: _minutes),
        onTimerDurationChanged: (d) => _set(d.inMinutes),
      ),
    ),
  );

  Widget _typedField(AppLocalizations l10n) => TextField(
    key: ValueKey('typed-$_wheel'),
    keyboardType: TextInputType.text,
    textInputAction: TextInputAction.done,
    autocorrect: false,
    onSubmitted: _typed,
    decoration: InputDecoration(
      labelText: l10n.durationTypeLabel,
      hintText: l10n.durationCustomHint,
      errorText: _invalid ? l10n.durationCustomInvalid : null,
    ),
  );
}
