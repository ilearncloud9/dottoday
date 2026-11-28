import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A full-screen decision (CR-160 boards G1, G1b, D1 on phones; A3 and B1
/// have their own per-board layouts, ED-493, ED-494):
/// [title] and [body] at the top, then [content], then [actions] pinned
/// to the bottom while they fit and scrolled into view when they don't
/// (200 % text, small phones). Wider windows keep one readable column,
/// centred. No business logic: callbacks only.
class DecisionFrame extends StatelessWidget {
  const DecisionFrame({
    required this.title,
    required this.actions,
    this.body,
    this.content = const [],
    super.key,
  });

  final String title;
  final String? body;

  /// Between the body and the actions: options, cards, notes.
  final List<Widget> content;

  /// Buttons and their notes, at the bottom.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final head = [
      Semantics(header: true, child: Text(title, style: t.styles.promptTitle)),
      if (body case final text?)
        Text(text, style: t.styles.body.copyWith(color: t.colors.secondary)),
    ];
    return Material(
      color: t.colors.ground,
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
