import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/sheets/anchored_popover.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
import 'package:flutter/material.dart';

/// The task form's head (option D, ED-086; Create task, ED-140): the
/// task's ring with a palette badge that opens Colour and icon, then the
/// summary line ("Today · 4:30–5:00 PM · 30 min") over the title. On a
/// band in the task's tint; [card] rounds it into a card (Android, E-Phones
/// "Android · Add: Create task").
class TaskFormHeader extends StatelessWidget {
  const TaskFormHeader({
    required this.color,
    required this.icon,
    required this.title,
    required this.onLook,
    this.summary,
    this.card = false,
    this.trailing,
    this.done = false,
    super.key,
  });

  final TaskColor color;
  final TaskIcon icon;

  /// The title field ([TaskFormTitleField]).
  final Widget title;

  /// Opens Colour and icon.
  /// The dot was tapped; it is at this rectangle (a popover's anchor).
  final ValueChanged<Rect?> onLook;
  final String? summary;
  final bool card;

  /// At the end: option D's done circle on a task that exists (ED-086).
  final Widget? trailing;

  /// A done task: the dot filled, as on the thread (E-R2-27 §2).
  final bool done;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final swatch = t.tasks[color];
    final l10n = context.l10n;
    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: DotSpace.m,
      children: [
        _Look(
          color: color,
          icon: icon,
          done: done,
          onTap: onLook,
          label: l10n.colourIconTitle,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (summary case final s?)
                Text(s, style: t.styles.rowMeta.copyWith(color: t.colors.ink)),
              title,
            ],
          ),
        ),
        ?trailing,
      ],
    );
    return Container(
      margin: card
          ? const EdgeInsets.symmetric(horizontal: DotSpace.page)
          : EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.page,
        vertical: DotSpace.m,
      ),
      decoration: BoxDecoration(
        color: swatch.tint,
        borderRadius: card
            ? BorderRadius.circular(DotRadii.cardLarge)
            : BorderRadius.zero,
      ),
      child: body,
    );
  }
}

/// The ring and its palette badge: one button, "Colour and icon".
class _Look extends StatelessWidget {
  const _Look({
    required this.color,
    required this.icon,
    required this.onTap,
    required this.label,
    this.done = false,
  });

  final TaskColor color;
  final TaskIcon icon;
  final bool done;
  final ValueChanged<Rect?> onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    const badge = DotSize.formBadge;
    void tap() => onTap(globalRectOf(context));
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: tap,
      child: GestureDetector(
        onTap: tap,
        child: SizedBox.square(
          dimension: DotSize.formRing + badge / 2,
          child: Stack(
            children: [
              TaskDot(
                color: color,
                icon: icon,
                state: done ? DotState.done : DotState.upcoming,
                label: label,
                size: DotSize.formRing,
              ),
              PositionedDirectional(
                end: 0,
                bottom: 0,
                child: Container(
                  width: badge,
                  height: badge,
                  decoration: BoxDecoration(
                    color: t.colors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: t.colors.hairline),
                  ),
                  alignment: Alignment.center,
                  child: DotIcon(
                    DotGlyphs.palette,
                    color: t.tasks[color].ring,
                    size: badge * 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The title: Manrope 700 24/30 (handoff "Create task title"), "What is
/// it?" as its hint. [action] is the keyboard's key: the neutral return on
/// iOS (ED-135, never "done"), the IME's check on Android.
class TaskFormTitleField extends StatelessWidget {
  const TaskFormTitleField({
    required this.controller,
    required this.hint,
    required this.onSubmitted,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.action = TextInputAction.unspecified,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextInputAction action;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final style = t.styles.sheetTitle.copyWith(fontWeight: FontWeight.w700);
    return TextField(
      contextMenuBuilder: systemTextMenu,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      textInputAction: action,
      textCapitalization: TextCapitalization.sentences,
      minLines: 1,
      maxLines: 3,
      style: style,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: style.copyWith(color: t.colors.placeholder),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: DotSpace.xs),
        // A full touch target, however short the title's line (§12).
        constraints: const BoxConstraints(minHeight: DotTouch.android),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: t.colors.hairline),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: t.colors.accent, width: DotSpace.xxs),
        ),
      ),
    );
  }
}
