import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';

/// One option of a [showChoiceSheet].
typedef Choice<T> = ({T value, String label, String? detail});

/// Pick one of [options] (Settings › Week starts, Time format, Theme …):
/// a list with the current one ticked. Returns the pick, or null. An
/// option may lead with its [leading] icon; one in [disabled] stays
/// listed, dimmed, with its detail saying why (the missions, E-R2-28).
Future<T?> showChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required List<Choice<T>> options,
  required T selected,
  Map<T, Widget> leading = const {},
  Set<T> disabled = const {},
}) => showAppSheet<T>(
  context: context,
  title: title,
  builder: (sheet) {
    final t = DotTheme.of(sheet);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final o in options)
          Semantics(
            selected: o.value == selected,
            child: ListTile(
              minTileHeight: DotTouch.android,
              contentPadding: EdgeInsets.zero,
              enabled: !disabled.contains(o.value),
              leading: switch (leading[o.value]) {
                final icon? when disabled.contains(o.value) => Opacity(
                  opacity: TaskAlpha.done,
                  child: icon,
                ),
                final icon => icon,
              },
              title: Text(
                o.label,
                style: disabled.contains(o.value)
                    ? t.styles.rowTitle.copyWith(color: t.colors.muted)
                    : t.styles.rowTitle,
              ),
              subtitle: o.detail == null
                  ? null
                  : Text(o.detail!, style: t.styles.rowMeta),
              trailing: o.value == selected
                  ? DotIcon(DotGlyphs.check, color: t.colors.accentInk)
                  : null,
              onTap: () => Navigator.of(sheet).pop(o.value),
            ),
          ),
      ],
    );
  },
);
