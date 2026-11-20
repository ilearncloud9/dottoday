import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:dottoday/shared/pickers/look/look_library.dart';
import 'package:dottoday/shared/pickers/look/look_parts.dart';
import 'package:dottoday/shared/pickers/look/palette_row.dart';
import 'package:flutter/material.dart';

/// All icons, pinned palette (E-Phones, ED-086): "Run · Coral" with its
/// dot, ⋯ and Done; the glass palette, search and category chips stay
/// put while the library (Recently used, then every category) scrolls.
class LookIcons extends StatefulWidget {
  const LookIcons({
    required this.colour,
    required this.icon,
    required this.recent,
    required this.onColour,
    required this.onIcon,
    required this.onAllColours,
    required this.onDone,
    super.key,
  });

  final TaskColor colour;
  final TaskIcon icon;
  final List<TaskIcon> recent;
  final ValueChanged<TaskColor> onColour;
  final ValueChanged<TaskIcon> onIcon;
  final VoidCallback onAllColours;
  final VoidCallback onDone;

  @override
  State<LookIcons> createState() => _LookIconsState();
}

/// A leaf: the search text, the library's scroll and the chip in view.
class _LookIconsState extends State<LookIcons> {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  TaskIconCategory? _category;

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _jump(List<LibraryLine> lines, TaskIconCategory c) {
    final y = libraryOffsetOf(lines, taskIconCategoryName(context.l10n, c));
    setState(() => _category = c);
    if (y == null || !_scroll.hasClients) return;
    _scroll.jumpTo(y.clamp(0, _scroll.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lines = libraryLines(
      l10n,
      query: _search.text,
      recent: widget.recent,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DotSpace.m,
            children: [
              LookHeader(
                title: Row(
                  spacing: DotSpace.m,
                  children: [
                    LookIconCircle(
                      icon: widget.icon,
                      colour: widget.colour,
                      selected: true,
                      onTap: null,
                      size: DotLook.headerDot,
                    ),
                    Flexible(
                      child: Text(
                        l10n.lookTitleOf(
                          taskIconName(l10n, widget.icon),
                          taskColorName(l10n, widget.colour),
                        ),
                        style: lookTitleStyle(context),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
                trailing: [
                  LookGlassButton(
                    onTap: widget.onAllColours,
                    tooltip: l10n.lookAllColours,
                    glyph: DotGlyphs.more,
                  ),
                  LookGlassButton(
                    onTap: widget.onDone,
                    tooltip: l10n.colourIconDone,
                    label: l10n.colourIconDone,
                  ),
                ],
              ),
              PaletteRow(
                selected: widget.colour,
                onPick: widget.onColour,
                glass: true,
              ),
              LookSearchField(
                controller: _search,
                onChanged: (_) => setState(() => _category = null),
              ),
              _Chips(selected: _category, onTap: (c) => _jump(lines, c)),
            ],
          ),
        ),
        const SizedBox(height: DotSpace.xs),
        Expanded(
          child: LookLibrary(
            lines: lines,
            colour: widget.colour,
            icon: widget.icon,
            onIcon: widget.onIcon,
            controller: _scroll,
            query: _search.text,
          ),
        ),
      ],
    );
  }
}

/// "Search 525 icons" in a sunk field (also the popover's, ED-156).
class LookSearchField extends StatelessWidget {
  const LookSearchField({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: t.styles.body,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: context.l10n.lookSearch(TaskIcon.picker.length.toString()),
        isDense: true,
        filled: true,
        fillColor: t.colors.chip,
        constraints: const BoxConstraints(minHeight: DotTouch.android),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(DotSpace.m)),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: DotIcon(DotGlyphs.search, color: t.colors.muted),
        ),
      ),
    );
  }
}

/// The categories as chips; one jumps to its section.
class _Chips extends StatelessWidget {
  const _Chips({required this.selected, required this.onTap});

  final TaskIconCategory? selected;
  final ValueChanged<TaskIconCategory> onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: DotSpace.s,
        children: [
          for (final c in TaskIconCategory.values)
            ChoiceChip(
              label: Text(taskIconCategoryName(context.l10n, c)),
              showCheckmark: false,
              selected: c == selected,
              // The theme's chip colour wins over background/selected.
              color: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? t.colors.accent
                    : t.colors.chip,
              ),
              side: BorderSide.none,
              labelStyle: t.styles.rowMeta.copyWith(
                fontWeight: FontWeight.w600,
                color: c == selected ? t.colors.onAccent : t.colors.text,
              ),
              onSelected: (_) => onTap(c),
            ),
        ],
      ),
    );
  }
}
