import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/search/search_results.dart';
import 'package:dottoday/shared/dot/colour_icon_block.dart';
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:dottoday/shared/pickers/task_icon_picker.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';

/// All · Today · This week · Inbox · Done · Colour ⌄ · Icon ⌄ (E-R2-13,
/// E-R2-30), wrapping onto a second line where they need it; Colour and
/// Icon open their pickers. Chip corners are the §4 idiom.
class SearchFilters extends StatelessWidget {
  const SearchFilters({required this.picked, required this.onPick, super.key});

  final SearchFilter picked;
  final ValueChanged<SearchFilter> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plain = <SearchFilter, String>{
      const AnyResult(): l10n.searchFilterAll,
      const TodayResults(): l10n.searchFilterToday,
      const WeekResults(): l10n.searchFilterWeek,
      const InboxResults(): l10n.searchFilterInbox,
      const DoneResults(): l10n.searchFilterDone,
    };
    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.s,
      children: [
        for (final MapEntry(key: f, value: label) in plain.entries)
          FilterChip(
            label: Text(label),
            selected: picked.runtimeType == f.runtimeType,
            shape: dotChipShape(context),
            onSelected: (_) => onPick(f),
          ),
        _colourChip(context),
        _iconChip(context),
      ],
    );
  }

  Widget _colourChip(BuildContext context) {
    final t = DotTheme.of(context);
    final current = switch (picked) {
      ColourResults(:final colorKey) => TaskColor.fromKey(colorKey),
      _ => null,
    };
    return FilterChip(
      avatar: current == null
          ? null
          : CircleAvatar(backgroundColor: t.tasks[current].color),
      label: current == null
          ? _Menu(context.l10n.searchFilterColour)
          : Text(taskColorName(context.l10n, current)),
      selected: current != null,
      shape: dotChipShape(context),
      onSelected: (_) => current != null
          ? onPick(const AnyResult())
          : unawaited(_pickColour(context)),
    );
  }

  Widget _iconChip(BuildContext context) {
    final t = DotTheme.of(context);
    final current = switch (picked) {
      IconResults(:final iconKey) => TaskIcon.fromKey(iconKey),
      _ => null,
    };
    return FilterChip(
      avatar: current?.glyph == null
          ? null
          : DotIcon(
              current!.glyph!,
              color: t.colors.text,
              size: DotSize.rowIcon,
            ),
      label: current == null
          ? _Menu(context.l10n.searchFilterIcon)
          : Text(taskIconName(context.l10n, current)),
      selected: current != null,
      shape: dotChipShape(context),
      onSelected: (_) => current != null
          ? onPick(const AnyResult())
          : unawaited(_pickIcon(context)),
    );
  }

  Future<void> _pickColour(BuildContext context) async {
    final colour = await showAppSheet<TaskColor>(
      context: context,
      title: context.l10n.searchPickColour,
      builder: (sheet) => Wrap(
        children: [
          for (final c in TaskColor.values)
            ColourDot(
              colour: c,
              selected: false,
              onTap: () => Navigator.of(sheet).pop(c),
            ),
        ],
      ),
    );
    if (colour != null) onPick(ColourResults(colour.key));
  }

  Future<void> _pickIcon(BuildContext context) async {
    final icon = await showTaskIconPicker(
      context: context,
      title: context.l10n.searchPickIcon,
    );
    if (icon != null) onPick(IconResults(icon.key));
  }
}

/// "Colour ⌄": a chip that opens a picker.
class _Menu extends StatelessWidget {
  const _Menu(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final ink = DefaultTextStyle.of(context).style.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.xxs,
      children: [
        Text(label),
        DotIcon(
          DotGlyphs.chevronDown,
          color: ink ?? DotTheme.of(context).colors.text,
          size: DotSize.rowIcon - DotSpace.xs,
        ),
      ],
    );
  }
}
