import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/speech/dictation_controller.dart';
import 'package:dottoday/data/tips/seen_tips.dart';
import 'package:dottoday/domain/speech/dictation_text.dart';
import 'package:dottoday/features/timeline/widgets/dictation_mic.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Brain dump's text box (docs/09 M14.5, 11 §B7): the multi-line field
/// with the mic in its bottom-end corner where on-device speech exists
/// (D2), the first-use tip on how dictation makes lines, and the caption
/// while listening. Typing works as before; the mic adds to it. The box
/// is filled, as Add's title box (E-Phones-2, E-R2-37).
class BrainDumpField extends ConsumerStatefulWidget {
  const BrainDumpField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  ConsumerState<BrainDumpField> createState() => _BrainDumpFieldState();
}

class _BrainDumpFieldState extends ConsumerState<BrainDumpField> {
  // Leaf view state (CLAUDE.md §4): the field's focus and whether the
  // one-time tip shows in this sheet.
  final _focus = FocusNode();
  bool _tip = false;
  bool _tipAsked = false;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  /// The first time the mic listens, the tip shows (and is put away for
  /// good on this device: shown once).
  Future<void> _maybeTip() async {
    _tipAsked = true;
    final seen = await ref.read(seenTipsProvider.future);
    if (!mounted || seen.contains(Tip.dictationLines)) return;
    setState(() => _tip = true);
    await ref.read(seenTipsProvider.notifier).putAway(Tip.dictationLines);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mic = micAvailable(ref, context) ?? false;
    ref.listen(dictationControllerProvider, (_, next) {
      if (!_tipAsked && next.listeningFor(widget.controller)) {
        unawaited(_maybeTip());
      }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_tip) ...[
          _DictationTip(onClose: () => setState(() => _tip = false)),
          const SizedBox(height: DotSpace.s),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: DotTheme.of(context).colors.sunk,
            borderRadius: BorderRadius.circular(DotRadii.tile),
          ),
          child: Stack(
            children: [
              TextField(
                contextMenuBuilder: systemTextMenu,
                controller: widget.controller,
                focusNode: _focus,
                autofocus: true,
                minLines: 5,
                maxLines: 12,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: mic ? l10n.dumpHintMic : l10n.dumpHint,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  // Room for the mic so text never runs under it.
                  contentPadding: EdgeInsetsDirectional.fromSTEB(
                    DotSpace.m,
                    DotSpace.m,
                    mic ? DotTouch.android : DotSpace.m,
                    DotSpace.m,
                  ),
                ),
              ),
              if (mic)
                PositionedDirectional(
                  end: DotSpace.xxs,
                  bottom: DotSpace.xxs,
                  child: DictationMic(
                    field: widget.controller,
                    focus: _focus,
                    mode: DictationMode.brainDump,
                  ),
                ),
            ],
          ),
        ),
        DictationNotice(
          field: widget.controller,
          listeningCaption: l10n.dumpListening,
        ),
      ],
    );
  }
}

/// "Speak your list": the two ways to start a new line, with an example.
class _DictationTip extends StatelessWidget {
  const _DictationTip({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.tonal,
        borderRadius: BorderRadius.circular(DotRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          DotSpace.m,
          DotSpace.s,
          0,
          DotSpace.m,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Semantics(
                container: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: DotSpace.xs,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.dumpMicTipTitle,
                        style: t.styles.rowTitle,
                      ),
                    ),
                    Text(l10n.dumpMicTipBody, style: t.styles.rowMeta),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: onClose,
              tooltip: l10n.tipDismiss,
              constraints: const BoxConstraints.tightFor(
                width: DotTouch.android,
                height: DotTouch.android,
              ),
              icon: DotIcon(
                DotGlyphs.close,
                color: t.colors.secondary,
                size: DotSize.rowIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
