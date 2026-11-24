import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/settings/settings_choice_mark.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/sheets/sheet_nav_bar.dart';
import 'package:flutter/material.dart';

/// One option of a [showChoiceSheet].
typedef Choice<T> = ({T value, String label, String? detail});

/// Pick one of [options] (Settings › Week starts, Shift later tasks,
/// Theme …): the options in a card, the current one marked — a check on
/// iPhone under "Cancel · title", a radio button elsewhere (E-R2-33). A
/// tap is the answer. Returns the pick, or null.
Future<T?> showChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required List<Choice<T>> options,
  required T selected,
}) {
  final ios = DotIdiom.of(context) == DotIdiom.cupertino;
  return showAppSheet<T>(
    context: context,
    title: ios ? null : title,
    builder: (sheet) {
      final card = SettingsGroup(
        caption: '',
        children: [
          for (final o in options)
            ChoiceRow(
              choice: o,
              selected: o.value == selected,
              onTap: () => Navigator.of(sheet).pop(o.value),
            ),
        ],
      );
      if (!ios) return card;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.m,
        children: [
          SheetNavBar(title: title, onCancel: () => Navigator.of(sheet).pop()),
          card,
        ],
      );
    },
  );
}

/// One pick-list row: the label and its detail, the mark when
/// [selected]. It may lead with its [leading] icon; [disabled] stays
/// listed, dimmed, with its detail saying why (the missions, E-R2-28).
class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({
    required this.choice,
    required this.selected,
    required this.onTap,
    this.disabled = false,
    this.leading,
    super.key,
  });

  final Choice<T> choice;
  final bool selected;
  final bool disabled;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final detail = choice.detail;
    final icon = leading;
    return Semantics(
      selected: selected,
      child: ListTile(
        minTileHeight: DotTouch.android,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: DotSpace.l,
        ),
        enabled: !disabled,
        leading: icon == null || !disabled
            ? icon
            : Opacity(opacity: TaskAlpha.done, child: icon),
        title: Text(
          choice.label,
          style: disabled
              ? t.styles.body.copyWith(color: t.colors.muted)
              : t.styles.body,
        ),
        subtitle: detail == null ? null : Text(detail, style: t.styles.rowMeta),
        trailing: SettingsChoiceMark(selected: selected),
        onTap: onTap,
      ),
    );
  }
}
