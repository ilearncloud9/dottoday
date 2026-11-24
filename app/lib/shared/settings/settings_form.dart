import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:flutter/material.dart';

/// Mac/web Settings pages as forms (M20.7 part 5b; E-FullA-v2 Appearance
/// and Wake Up and Wind Down; ED-450): a right-aligned "Label:" column,
/// the control beside it and grey help under it; switches as checkboxes,
/// short pick lists as pop-up menus, buttons that open more end in "…".
///
/// [SettingsFormScope] is set by the Settings page frame; rows and groups
/// read [settingsFormAt] and draw themselves as form lines under it.
class SettingsFormScope extends InheritedWidget {
  const SettingsFormScope({
    required this.form,
    required super.child,
    this.first = false,
    super.key,
  });

  /// Whether the page under it is drawn as a form.
  final bool form;

  /// The page's first group: no section break above it.
  final bool first;

  static SettingsFormScope? _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsFormScope>();

  @override
  bool updateShouldNotify(SettingsFormScope old) =>
      old.form != form || old.first != first;
}

/// Whether the Settings page at [context] is drawn as a form.
bool settingsFormAt(BuildContext context) =>
    SettingsFormScope._of(context)?.form ?? false;

/// Whether the group at [context] is its page's first.
bool settingsFormFirstAt(BuildContext context) =>
    SettingsFormScope._of(context)?.first ?? false;

/// Settings pages are forms on the Mac and the web from the medium width
/// (ED-450); phones, tablets and compact web keep the phone rows.
bool settingsFormFits(BuildContext context) =>
    !touchApp(context) && AppLayout.classOf(context) != WidthClass.compact;

/// One form line: "[label]:" right-aligned in its column, [child] beside
/// it. With no label the control lines up under the others. Where the
/// control would get less than [DotSize.formControlMin] (a narrow pane,
/// 200 % text) the label goes above it.
class FormLine extends StatelessWidget {
  const FormLine({required this.child, this.label, super.key});

  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final text = switch (label) {
      final l? when l.isNotEmpty => Text(
        context.l10n.settingsFormLabel(l),
        style: t.styles.inspectorValue.copyWith(
          color: t.colors.ink2,
          fontWeight: FontWeight.w400,
        ),
      ),
      _ => null,
    };
    return LayoutBuilder(
      builder: (context, box) {
        final control = Align(
          alignment: AlignmentDirectional.centerStart,
          child: child,
        );
        final room = box.maxWidth - DotSize.formLabel - DotSize.formGap;
        final scaled = MediaQuery.textScalerOf(context).scale(1) > 1.3;
        if (room < DotSize.formControlMin || scaled) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DotSpace.xs,
            children: [?text, control],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSize.formGap,
          children: [
            SizedBox(
              width: DotSize.formLabel,
              // Level with the first line of a 26-tall control.
              child: Padding(
                padding: const EdgeInsets.only(top: DotSpace.xs),
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: text,
                ),
              ),
            ),
            Expanded(child: control),
          ],
        );
      },
    );
  }
}

/// Grey help under a control.
class FormHelp extends StatelessWidget {
  const FormHelp(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: DotTheme.of(context).styles.inspectorLabel);
}

/// A section break: the hairline E-FullA-v2 draws between groups.
class FormBreak extends StatelessWidget {
  const FormBreak({super.key});

  @override
  Widget build(BuildContext context) => Divider(
    height: DotSpace.hairline,
    color: DotTheme.of(context).colors.outline,
  );
}

/// A checkbox with its title and a grey detail: a phone switch row on the
/// Mac and the web. The whole line toggles it; dimmed when [onChanged] is
/// null.
class FormCheck extends StatelessWidget {
  const FormCheck({
    required this.value,
    required this.title,
    required this.onChanged,
    this.detail,
    this.below,
    this.semanticLabel,
    super.key,
  });

  /// For screen readers when [title] is empty (a table cell's checkbox).
  final String? semanticLabel;

  final bool value;
  final String title;
  final String? detail;
  final ValueChanged<bool>? onChanged;

  /// Under the detail (Energy suggestions' progress).
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final on = onChanged != null;
    final box = Container(
      width: DotSize.formCheck,
      height: DotSize.formCheck,
      decoration: BoxDecoration(
        color: value ? c.accentFill : c.raised,
        borderRadius: BorderRadius.circular(DotRadii.field - DotSpace.xxs),
        border: value ? null : Border.all(color: c.hairlineStrong, width: 1.5),
      ),
      child: value
          ? DotIcon(
              DotGlyphs.check,
              color: c.onAccent,
              size: DotSize.formCheck - DotSpace.xs,
            )
          : null,
    );
    return MergeSemantics(
      child: Semantics(
        checked: value,
        enabled: on,
        label: semanticLabel,
        child: InkWell(
          onTap: on ? () => onChanged!(!value) : null,
          borderRadius: BorderRadius.circular(DotRadii.field),
          child: Opacity(
            opacity: on ? 1 : DotOpacity.disabled,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DotSpace.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DotSpace.s,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: DotSpace.xxs),
                    child: box,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: DotSpace.xxs,
                      children: [
                        if (title.isNotEmpty)
                          Text(
                            title,
                            style: t.styles.inspectorValue.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        if (detail case final d?) FormHelp(d),
                        ?below,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A radio choice with its title and a grey detail (Missions, Sounds).
class FormRadio extends StatelessWidget {
  const FormRadio({
    required this.selected,
    required this.title,
    required this.onTap,
    this.detail,
    this.trailing,
    super.key,
  });

  final bool selected;
  final String title;
  final String? detail;
  final VoidCallback? onTap;

  /// Just after the title (Sounds' ▶).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final on = onTap != null;
    final mark = FormRadioMark(selected: selected, enabled: on);
    return MergeSemantics(
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: selected,
        enabled: on,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DotRadii.field),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: DotSpace.xxs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DotSpace.s,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: DotSpace.xxs),
                  child: mark,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: DotSpace.xxs,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: DotSpace.s,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: t.styles.inspectorValue.copyWith(
                                fontWeight: FontWeight.w400,
                                color: on ? c.text : c.muted,
                              ),
                            ),
                          ),
                          ?trailing,
                        ],
                      ),
                      if (detail case final d?) FormHelp(d),
                    ],
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

/// A radio button's circle: filled ring when [selected], dimmed when it
/// can't be chosen.
class FormRadioMark extends StatelessWidget {
  const FormRadioMark({required this.selected, this.enabled = true, super.key});

  final bool selected;
  final bool enabled;

  /// The chosen ring's share of the circle.
  static const _ring = 0.3;

  /// The empty circle's line.
  static const _line = 1.5;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Opacity(
      opacity: enabled ? 1 : DotOpacity.disabled,
      child: Container(
        width: DotSize.formCheck,
        height: DotSize.formCheck,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.raised,
          border: Border.all(
            color: selected ? c.accentFill : c.hairlineStrong,
            width: selected ? DotSize.formCheck * _ring : _line,
          ),
        ),
      ),
    );
  }
}

/// A 26-tall bordered control: a button ("Change…", "Export…") or, with
/// [menu], the face of a pop-up menu ("30 min ⌃⌄").
class FormButton extends StatelessWidget {
  const FormButton({
    required this.label,
    required this.onPressed,
    this.menu = false,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool menu;

  /// What it is for screen readers when [label] alone says too little
  /// ("Wake Up, Monday" for a table's 6:30 AM); the label is its value.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final face = FormControlFace(label: label, menu: menu);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      excludeSemantics: true,
      label: semanticLabel ?? label,
      value: semanticLabel == null ? null : label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(DotRadii.field),
        child: Opacity(
          opacity: onPressed == null ? DotOpacity.disabled : 1,
          child: face,
        ),
      ),
    );
  }
}

/// How a form button or pop-up looks, without its tap.
class FormControlFace extends StatelessWidget {
  const FormControlFace({required this.label, this.menu = false, super.key});

  final String label;
  final bool menu;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: DotSize.formControl),
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.s + DotSpace.xxs,
      ),
      decoration: BoxDecoration(
        color: c.raised,
        borderRadius: BorderRadius.circular(DotRadii.field),
        border: Border.all(color: c.hairlineStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.s,
        children: [
          Flexible(child: Text(label, style: t.styles.inspectorValue)),
          if (menu)
            DotIcon(
              DotGlyphs.chevronDown,
              color: c.ink2,
              size: DotSize.inspectorChevron,
            ),
        ],
      ),
    );
  }
}

/// One choice in a [FormMenu].
typedef FormChoice = ({String label, bool selected, VoidCallback onSelect});

/// A pop-up menu: [value] on its face; the system's own menu on the Mac,
/// Flutter's on the web ([DotMenuButton]), the chosen item ticked.
class FormMenu extends StatelessWidget {
  const FormMenu({
    required this.title,
    required this.value,
    required this.choices,
    this.headers = const {},
    super.key,
  });

  /// Group titles, by the index of the choice that starts each group
  /// (Sound's Dottoday, Quiet, Clear, Playful).
  final Map<int, String> headers;

  /// What it sets, for its tooltip and screen readers ("Snap to").
  final String title;
  final String value;
  final List<FormChoice> choices;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: title,
    value: value,
    excludeSemantics: true,
    child: DotMenuButton<int>(
      tooltip: title,
      entries: () => [
        for (final (i, c) in choices.indexed)
          ContextMenuEntry(
            value: i,
            label: c.label,
            checked: c.selected,
            header: headers[i],
          ),
      ],
      onSelected: (i) => choices[i].onSelect(),
      child: FormControlFace(label: value, menu: true),
    ),
  );
}

/// A pop-up's choices from [values]: [label] names each, the one equal to
/// [selected] is ticked, and picking one calls [onPick] with it.
///
/// ```dart
/// formChoices(values: [5, 10, 15], selected: 10,
///     label: l10n.settingsSnapValue, onPick: save);
/// ```
List<FormChoice> formChoices<T>({
  required Iterable<T> values,
  required T selected,
  required String Function(T) label,
  required ValueChanged<T> onPick,
}) => [
  for (final v in values)
    (label: label(v), selected: v == selected, onSelect: () => onPick(v)),
];

/// A bordered list inside a form (Export's formats, Alarm sounds on's
/// devices, ED-450): [children] with hairlines between them.
class FormList extends StatelessWidget {
  const FormList({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Material(
      color: c.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DotRadii.monthCard),
        side: BorderSide(color: c.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) Divider(height: DotSpace.hairline, color: c.outline),
            child,
          ],
        ],
      ),
    );
  }
}

/// One row of a [FormList]: [leading], a title with its detail, then
/// [trailing] (a button, a chip).
class FormListRow extends StatelessWidget {
  const FormListRow({
    required this.title,
    this.leading,
    this.detail,
    this.trailing,
    this.onTap,
    this.dimmed = false,
    super.key,
  });

  final Widget? leading;
  final String title;
  final Widget? detail;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Can't be chosen here (the Mac and the web under Can't ring).
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.m,
          vertical: DotSpace.s + DotSpace.xxs,
        ),
        child: Row(
          spacing: DotSpace.s + DotSpace.xxs,
          children: [
            ?leading,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DotSpace.xxs,
                children: [
                  Text(
                    title,
                    style: t.styles.inspectorValue.copyWith(
                      fontWeight: FontWeight.w400,
                      color: dimmed ? t.colors.muted : t.colors.text,
                    ),
                  ),
                  ?detail,
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
