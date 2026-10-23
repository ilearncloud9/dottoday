import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';

/// Where "Send me a test alarm" stands.
enum TestAlarmStep { idle, explain, waiting, ask, rang, notRang }

/// "Send me a test alarm" (docs/09 M6.5.9, 11 A0; derived from
/// `SettingsGroup`): the row, then the owner's explanation with Send, a
/// countdown while the alarm is on its way, and "Did it ring?". Leaving
/// before it rings cancels it. A leaf: the caller owns scheduling.
class TestAlarmCard extends StatefulWidget {
  const TestAlarmCard({
    required this.onSend,
    required this.onCancel,
    required this.now,
    required this.afterNo,
    this.initial = TestAlarmStep.idle,
    super.key,
  });

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
  State<TestAlarmCard> createState() => _TestAlarmCardState();
}

class _TestAlarmCardState extends State<TestAlarmCard> {
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
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SettingsGroup(
      caption: l10n.testAlarmCaption,
      children: [
        SettingsRow(
          glyph: DotGlyphs.bell,
          tint: t.colors.accentInk,
          title: l10n.testAlarmRow,
          subtitle: l10n.testAlarmRowDetail,
          onTap: _step == TestAlarmStep.idle
              ? () => setState(() => _step = TestAlarmStep.explain)
              : null,
          below: _step == TestAlarmStep.idle ? null : _below(t, l10n),
        ),
      ],
    );
  }

  Widget _below(DotTheme t, AppLocalizations l10n) {
    final body = t.styles.body;
    return Padding(
      padding: const EdgeInsets.only(top: DotSpace.s),
      child: switch (_step) {
        TestAlarmStep.idle => const SizedBox.shrink(),
        TestAlarmStep.explain =>
          _withButtons(Text(l10n.testAlarmExplain, style: body), [
            FilledButton(
              onPressed: () => unawaited(_send()),
              child: Text(l10n.testAlarmSend),
            ),
            TextButton(
              onPressed: () => setState(() => _step = TestAlarmStep.idle),
              child: Text(l10n.testAlarmCancel),
            ),
          ]),
        TestAlarmStep.waiting => _withButtons(
          Semantics(
            liveRegion: true,
            child: Text(l10n.testAlarmCountdown(_secondsLeft), style: body),
          ),
          [
            TextButton(
              onPressed: () => unawaited(_cancel()),
              child: Text(l10n.testAlarmCancel),
            ),
          ],
        ),
        TestAlarmStep.ask =>
          _withButtons(Text(l10n.testAlarmAsk, style: body), [
            FilledButton(
              onPressed: () => setState(() => _step = TestAlarmStep.rang),
              child: Text(l10n.testAlarmYes),
            ),
            OutlinedButton(
              onPressed: () => setState(() => _step = TestAlarmStep.notRang),
              child: Text(l10n.testAlarmNo),
            ),
          ]),
        TestAlarmStep.rang => Text(l10n.testAlarmGood, style: body),
        TestAlarmStep.notRang => Text(widget.afterNo, style: body),
      },
    );
  }

  Widget _withButtons(Widget text, List<Widget> buttons) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: DotSpace.s,
    children: [
      text,
      Wrap(spacing: DotSpace.s, runSpacing: DotSpace.s, children: buttons),
    ],
  );
}
