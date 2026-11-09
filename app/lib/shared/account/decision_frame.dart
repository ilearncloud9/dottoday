import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A full-screen decision (CR-160 boards A3, B1, G1, G1b, D1 on phones):
/// [title] and [body] at the top, then [content], then [actions] pinned
/// to the bottom while they fit and scrolled into view when they don't
/// (200 % text, small phones). Wider windows keep one readable column,
/// centred. No business logic: callbacks only.
class DecisionFrame extends StatelessWidget {
  const DecisionFrame({
    required this.title,
    required this.actions,
    this.body,
    this.leading,
    this.content = const [],
    this.centred = false,
    super.key,
  });

  final String title;
  final String? body;

  /// Above the title: an illustration (A3).
  final Widget? leading;

  /// Between the body and the actions: options, cards, notes.
  final List<Widget> content;

  /// Buttons and their notes, at the bottom.
  final List<Widget> actions;

  /// Title and body in the middle of the free space (A3), not at the top.
  final bool centred;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final head = [
      ?leading,
      Semantics(
        header: true,
        child: Text(
          title,
          style: centred ? t.styles.dayTitle : t.styles.promptTitle,
        ),
      ),
      if (body case final text?)
        Text(text, style: t.styles.body.copyWith(color: t.colors.muted)),
    ];
    return Material(
      color: t.colors.surface,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    DotSpace.page,
                    DotSpace.xxl,
                    DotSpace.page,
                    DotSpace.xl,
                  ),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (centred) const Spacer(),
                        _Gap(children: [...head, ...content]),
                        const Spacer(),
                        const SizedBox(height: DotSpace.xl),
                        _Gap(gap: DotSpace.m, children: actions),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A column of [children] [gap] apart.
class _Gap extends StatelessWidget {
  const _Gap({required this.children, this.gap = DotSpace.l});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: gap,
    children: children,
  );
}

/// A short muted note under a button or a group (13/18 in the boards).
class DecisionNote extends StatelessWidget {
  const DecisionNote(this.text, {this.centred = false, super.key});

  final String text;
  final bool centred;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Text(
      text,
      textAlign: centred ? TextAlign.center : TextAlign.start,
      style: t.styles.stripWeekday,
    );
  }
}
