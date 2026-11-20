import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_sheet.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
import 'package:flutter/material.dart';

/// The Plan panel's Brain dump (E-FullA-v2, ED-184): everything on your
/// mind, one per line, then Plan it, which opens Brain dump with the lines
/// to pick the day and see the plan. Nothing is added until you accept
/// (the proposal rule, ADR-0009 §3).
class BrainDumpPlanSection extends StatefulWidget {
  const BrainDumpPlanSection({required this.today, super.key});

  final DateTime today;

  @override
  State<BrainDumpPlanSection> createState() => _BrainDumpPlanSectionState();
}

class _BrainDumpPlanSectionState extends State<BrainDumpPlanSection> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _plan() {
    final lines = _text.text;
    _text.clear();
    unawaited(showBrainDump(context, widget.today, text: lines));
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        TextField(
          contextMenuBuilder: systemTextMenu,
          controller: _text,
          minLines: 3,
          maxLines: 6,
          style: t.styles.sidebarItem,
          decoration: InputDecoration(
            hintText: l10n.dumpHint,
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
        Row(
          spacing: DotSpace.s,
          children: [
            Expanded(
              child: Text(l10n.planPanelDumpNote, style: t.styles.rowMeta),
            ),
            FilledButton(onPressed: _plan, child: Text(l10n.dumpPlan)),
          ],
        ),
      ],
    );
  }
}
