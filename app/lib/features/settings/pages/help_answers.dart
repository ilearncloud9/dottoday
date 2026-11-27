import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Help's questions in one card (E-R2-24 §4, ED-497): each a row that opens
/// to its answer, hairlines between them.
class HelpAnswers extends StatelessWidget {
  const HelpAnswers({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.raised,
        borderRadius: BorderRadius.circular(HelpSize.cardRadius),
        border: Border.all(color: c.outline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HelpSize.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, child) in children.indexed) ...[
              if (i > 0) Divider(height: 0.5, thickness: 0.5, color: c.outline),
              child,
            ],
          ],
        ),
      ),
    );
  }
}

/// A question (600 16) that opens to its answer (15/21 ink 2), the chevron
/// pointing down or up; [child] in place of the answer's text.
class HelpAnswer extends StatefulWidget {
  const HelpAnswer(this.question, this.answer, {this.child, super.key});

  final String question;
  final String answer;
  final Widget? child;

  @override
  State<HelpAnswer> createState() => _HelpAnswerState();
}

/// A leaf: open or not.
class _HelpAnswerState extends State<HelpAnswer> {
  var _open = false;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final question = t.styles.caption.copyWith(
      fontSize: 16,
      height: 21 / 16,
      color: c.text,
    );
    final answer = t.styles.body.copyWith(
      fontSize: 15,
      height: 21 / 15,
      color: c.ink2,
    );
    return Semantics(
      button: true,
      expanded: _open,
      child: InkWell(
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: HelpSize.rowPad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                spacing: DotSpace.s,
                children: [
                  Expanded(child: Text(widget.question, style: question)),
                  DotIcon(
                    _open ? DotGlyphs.chevronUp : DotGlyphs.chevronDown,
                    color: c.muted,
                    size: HelpSize.chevron,
                  ),
                ],
              ),
              if (_open)
                Padding(
                  padding: const EdgeInsets.only(top: HelpSize.answerTop),
                  child: DefaultTextStyle.merge(
                    style: answer,
                    child: widget.child ?? Text(widget.answer, style: answer),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
