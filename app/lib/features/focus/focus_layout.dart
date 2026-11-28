import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:flutter/material.dart';

/// Where Focus's pieces sit (E-R2-9, ED-285): on phones, compact and
/// medium windows one readable column that scrolls; on expanded windows
/// the whole window in two, [hero] (ring, time, title, time left) on the
/// start side and [detail] (step, thread, toggles, actions, note) on the
/// end side, from one top, the pair centred. [top] spans the top.
class FocusLayout extends StatelessWidget {
  const FocusLayout({
    required this.top,
    required this.hero,
    required this.detail,
    super.key,
  });

  final Widget top;
  final List<Widget> hero;
  final List<Widget> detail;

  static const _pad = EdgeInsets.fromLTRB(
    DotSpace.page,
    DotSpace.s,
    DotSpace.page,
    DotSpace.xl,
  );

  @override
  Widget build(BuildContext context) =>
      AppLayout.classOf(context) == WidthClass.expanded
      ? _wide()
      : Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
            child: ListView(
              padding: _pad,
              children: [
                top,
                const SizedBox(height: DotSpace.xl),
                ...hero,
                const SizedBox(height: DotSpace.xl),
                ...detail,
              ],
            ),
          ),
        );

  Widget _wide() {
    Widget side(List<Widget> children) => Expanded(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DotSize.focusSide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
    // Both sides start at one top, the pair centred in the window
    // (E-R2-9 B); it scrolls as one at large text.
    return Padding(
      padding: _pad,
      child: Column(
        children: [
          top,
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: DotSpace.xl,
                      children: [side(hero), side(detail)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "‹ Today", "FOCUS", and ⋯ with Task details.
class FocusTopBar extends StatelessWidget {
  const FocusTopBar({required this.id, required this.onLeave, super.key});

  final String id;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Row(
      children: [
        TextButton.icon(
          onPressed: onLeave,
          icon: DotIcon(DotGlyphs.chevronLeft, color: t.colors.accentText),
          label: Text(l10n.focusBack),
        ),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              l10n.focusTitle.toUpperCase(),
              textAlign: TextAlign.center,
              style: t.styles.caption,
            ),
          ),
        ),
        DotMenuButton<VoidCallback>(
          tooltip: l10n.focusMore,
          icon: DotIcon(DotGlyphs.more, color: t.colors.ink),
          onSelected: (run) => run(),
          entries: () => [
            ContextMenuEntry(
              value: () => openTask(context, id),
              label: l10n.focusOpenTask,
            ),
          ],
        ),
      ],
    );
  }
}
