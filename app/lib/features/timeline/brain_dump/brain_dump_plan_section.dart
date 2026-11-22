import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/speech/dictation_controller.dart';
import 'package:dottoday/domain/speech/dictation_text.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_sheet.dart';
import 'package:dottoday/features/timeline/widgets/dictation_mic.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Plan panel's Brain dump (E-FullA-v2, ED-184): everything on your
/// mind, one per line, then Plan it, which opens Brain dump with the lines
/// to pick the day and see the plan. Nothing is added until you accept
/// (the proposal rule, ADR-0009 §3). Where this language has on-device
/// speech the mic (Dictate) leads the row and the caption, a refused
/// microphone or a stop shows under the field (E-R2-37 §3).
class BrainDumpPlanSection extends ConsumerStatefulWidget {
  const BrainDumpPlanSection({required this.today, super.key});

  final DateTime today;

  @override
  ConsumerState<BrainDumpPlanSection> createState() =>
      _BrainDumpPlanSectionState();
}

class _BrainDumpPlanSectionState extends ConsumerState<BrainDumpPlanSection> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _plan() async {
    // Plan it while listening: stop first, keep what was said (M14.5).
    await ref.read(dictationControllerProvider.notifier).stopFor(_text);
    if (!mounted) return;
    final lines = _text.text;
    _text.clear();
    unawaited(showBrainDump(context, widget.today, text: lines));
  }

  /// Whether the note goes above the row: large text, or a panel too
  /// narrow for the mic, the note and Plan it side by side.
  static bool _stacks(double scale, double width, {required bool mic}) {
    if (scale > DotSize.stackAbove) return true;
    return mic && width / scale < DotSize.dumpRowMin;
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final mic = micAvailable(ref, context) ?? false;
    final plan = FilledButton(
      onPressed: () => unawaited(_plan()),
      child: Text(l10n.dumpPlan),
    );
    final micButton = mic
        ? DictationMic(
            field: _text,
            focus: _focus,
            mode: DictationMode.brainDump,
          )
        : null;
    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.s,
          children: [
            TextField(
              contextMenuBuilder: systemTextMenu,
              controller: _text,
              focusNode: _focus,
              minLines: 3,
              maxLines: 6,
              style: t.styles.sidebarItem,
              decoration: InputDecoration(
                hintText: mic ? l10n.dumpHintMic : l10n.dumpHint,
                filled: true,
                fillColor: t.colors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DotRadii.card),
                  borderSide: BorderSide(color: t.colors.hairline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DotRadii.card),
                  borderSide: BorderSide(color: t.colors.hairline),
                ),
              ),
            ),
            if (mic)
              DictationNotice(
                field: _text,
                listeningCaption: l10n.dumpListening,
              ),
            // Large text, or the mic in a narrow panel: the note above, the mic
            // and Plan it under it (M19.7, 200 %).
            if (_stacks(
              MediaQuery.textScalerOf(context).scale(1),
              width,
              mic: mic,
            )) ...[
              Text(l10n.planPanelDumpNote, style: t.styles.rowMeta),
              // Wraps when even the two don't fit side by side (200 %).
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: DotSpace.xs,
                children: [micButton ?? const SizedBox.shrink(), plan],
              ),
            ] else
              Row(
                spacing: DotSpace.s,
                children: [
                  ?micButton,
                  Expanded(
                    child: Text(
                      l10n.planPanelDumpNote,
                      style: t.styles.rowMeta,
                    ),
                  ),
                  plan,
                ],
              ),
          ],
        );
      },
    );
  }
}
