import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';

/// Where "Send me a test alarm" stands.
enum TestAlarmStep { idle, explain, waiting, ask, rang, notRang }

/// "Check it works › Send me a test alarm" (docs/09 M6.5.9, 11 A0;
/// E-R2-20, ED-317): [TestAlarmRow] in its own group, each step a card
/// under it (ED-470).
class TestAlarmCard extends StatelessWidget {
  const TestAlarmCard({
    required this.onSend,
    required this.onCancel,
    required this.now,
    required this.afterNo,
    this.initial = TestAlarmStep.idle,
    super.key,
  });

  final Future<DateTime> Function() onSend;
  final Future<void> Function() onCancel;
  final DateTime Function() now;
  final String afterNo;
  final TestAlarmStep initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TestAlarmRow(
      caption: l10n.testAlarmCaption,
      title: l10n.testAlarmRow,
      subtitle: l10n.testAlarmRowDetail,
      formLabel: l10n.testAlarmCaption,
      onSend: onSend,
      onCancel: onCancel,
      now: now,
      afterNo: afterNo,
      initial: initial,
    );
  }
}

/// The test alarm's row and its five steps (E-R2-20, ED-317): the row,
/// the owner's explanation with Send, a countdown while the alarm is on
/// its way, and "Did it ring?". Leaving before it rings calls [onCancel].
/// A leaf: the caller owns scheduling.
class TestAlarmRow extends StatefulWidget {
  const TestAlarmRow({
    required this.title,
    required this.onSend,
    required this.onCancel,
    required this.now,
    required this.afterNo,
    this.subtitle,
    this.action = false,
    this.initial = TestAlarmStep.idle,
    this.formLabel,
    this.caption,
    super.key,
  });

  /// Set: the row is its own group with this caption, and each step is a
  /// card under the group (E-R2-20 §4, ED-470). Null: a row in someone
  /// else's group (Wake Up), the steps under its title.
  final String? caption;

  /// Its label on a Mac/web form ("Check it works", ED-450).
  final String? formLabel;

  /// "Send me a test alarm", or Wake Up's "Send a test alarm" (E-Phones).
  final String title;
  final String? subtitle;

  /// Drawn as an action row (E-Phones): accent title, no chevron.
  final bool action;

  /// Schedules it; returns when it is due.
  final Future<DateTime> Function() onSend;

  /// Takes it back.
  final Future<void> Function() onCancel;

  /// The injected clock's now (CLAUDE.md §4).
  final DateTime Function() now;

  /// What to say after "No": where the checks are.
  final String afterNo;

  /// For goldens: start at a given step.
  final TestAlarmStep initial;

  @override
  State<TestAlarmRow> createState() => _TestAlarmRowState();
}

class _TestAlarmRowState extends State<TestAlarmRow> {
  late var _step = widget.initial;

  /// A preview of the waiting step (goldens) shows the full minute.
  late DateTime? _due = widget.initial == TestAlarmStep.waiting
      ? widget.now().add(const Duration(seconds: 60))
      : null;
  Timer? _tick;

  @override
  void dispose() {
    _tick?.cancel();
    // Left before it rang: nothing should go off later.
    if (_step == TestAlarmStep.waiting) unawaited(widget.onCancel());
    super.dispose();
  }

  Future<void> _send() async {
    final due = await widget.onSend();
    if (!mounted) return;
    setState(() {
      _due = due;
      _step = TestAlarmStep.waiting;
    });
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _onTick() {
    final due = _due;
    if (due == null || widget.now().isBefore(due)) return setState(() {});
    _tick?.cancel();
    setState(() => _step = TestAlarmStep.ask);
  }

  Future<void> _cancel() async {
    _tick?.cancel();
    await widget.onCancel();
    if (mounted) setState(() => _step = TestAlarmStep.idle);
  }

  int get _secondsLeft {
    final due = _due;
    if (due == null) return 0;
    final left = due.difference(widget.now()).inSeconds;
    return left < 0 ? 0 : left;
  }

  @override
  Widget build(BuildContext context) {
    final caption = widget.caption;
    final form = settingsFormAt(context);
    if (caption == null || form) {
      final row = _row(
        context,
        below: _step == TestAlarmStep.idle ? null : _steps(context),
      );
      if (caption == null) return row;
      return SettingsGroup(caption: caption, children: [row]);
    }
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s + DotSpace.xxs,
      children: [
        SettingsGroup(caption: caption, children: [_row(context)]),
        if (_step != TestAlarmStep.idle)
          DecoratedBox(
            decoration: BoxDecoration(
              color: t.colors.raised,
              borderRadius: BorderRadius.circular(DotRadii.card),
              border: Border.all(color: t.colors.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DotSpace.l),
              child: _steps(context),
            ),
          ),
      ],
    );
  }

  /// The row; tappable only before a test starts.
  Widget _row(BuildContext context, {Widget? below}) {
    final t = DotTheme.of(context);
    return SettingsRow(
      glyph: DotGlyphs.bell,
      tint: t.colors.accentInk,
      title: widget.title,
      subtitle: widget.subtitle,
      // A button on a Mac/web form (ED-450).
      action: widget.action || settingsFormAt(context),
      formLabel: widget.formLabel,
      onTap: _step == TestAlarmStep.idle
          ? () => setState(() => _step = TestAlarmStep.explain)
          : null,
      below: below == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: DotSpace.s),
              child: below,
            ),
    );
  }

  /// The step's words and its pills (E-R2-20 §4): Send and Yes filled,
  /// Cancel and No outlined.
  Widget _steps(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final body = t.styles.body;
    return switch (_step) {
      TestAlarmStep.idle => const SizedBox.shrink(),
      TestAlarmStep.explain =>
        _withButtons(Text(l10n.testAlarmExplain, style: body), [
          _pill(t, l10n.testAlarmSend, () => unawaited(_send()), filled: true),
          _pill(
            t,
            l10n.testAlarmCancel,
            () => setState(() => _step = TestAlarmStep.idle),
          ),
        ]),
      TestAlarmStep.waiting => _withButtons(
        Semantics(
          liveRegion: true,
          child: Text(l10n.testAlarmCountdown(_secondsLeft), style: body),
        ),
        [_pill(t, l10n.testAlarmCancel, () => unawaited(_cancel()))],
      ),
      TestAlarmStep.ask => _withButtons(Text(l10n.testAlarmAsk, style: body), [
        _pill(
          t,
          l10n.testAlarmYes,
          () => setState(() => _step = TestAlarmStep.rang),
          filled: true,
        ),
        _pill(
          t,
          l10n.testAlarmNo,
          () => setState(() => _step = TestAlarmStep.notRang),
          ink: true,
        ),
      ]),
      TestAlarmStep.rang => Text(l10n.testAlarmGood, style: body),
      TestAlarmStep.notRang => Text(widget.afterNo, style: body),
    };
  }

  /// A 44-high pill: filled in the accent, or outlined with the accent's
  /// words ([ink]: the text colour, as the board's No).
  Widget _pill(
    DotTheme t,
    String label,
    VoidCallback onPressed, {
    bool filled = false,
    bool ink = false,
  }) {
    const shape = StadiumBorder();
    const size = Size(0, DotTouch.min);
    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(shape: shape, minimumSize: size),
        child: Text(label),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: shape,
        minimumSize: size,
        foregroundColor: ink ? t.colors.text : t.colors.accentInk,
        side: BorderSide(color: t.colors.outline),
      ),
      child: Text(label),
    );
  }

  Widget _withButtons(Widget text, List<Widget> buttons) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: DotSpace.m,
    children: [
      text,
      Wrap(spacing: DotSpace.s, runSpacing: DotSpace.s, children: buttons),
    ],
  );
}
