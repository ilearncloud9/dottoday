import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/onboarding/day_fills.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_chips.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
import 'package:flutter/material.dart';

/// "Add your own" (`.addown`): the dot its words suggest, the field, "2
/// of 5" and +. Return or + adds; once five are picked the field is off
/// and reads "Five is plenty to start with.".
class FillsAdd extends StatefulWidget {
  const FillsAdd({
    required this.controller,
    required this.focus,
    required this.dotKey,
    required this.color,
    required this.glyph,
    required this.count,
    required this.full,
    required this.onAdd,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final GlobalKey dotKey;
  final Color color;
  final DotGlyph? glyph;
  final int count;
  final bool full;
  final VoidCallback onAdd;

  @override
  State<FillsAdd> createState() => _FillsAddState();
}

/// A leaf: only whether the field has focus, for its ring.
class _FillsAddState extends State<FillsAdd> {
  @override
  void initState() {
    super.initState();
    widget.focus.addListener(_changed);
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.focus.removeListener(_changed);
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final line = OnbSky.of(c.isDark ? Brightness.dark : Brightness.light).line;
    final typing = widget.focus.hasFocus;
    final can = !widget.full && widget.controller.text.trim().isNotEmpty;
    return Container(
      height: OnbSize.addField,
      padding: const EdgeInsetsDirectional.only(
        start: OnbSize.addStart,
        end: OnbSize.addEnd,
      ),
      decoration: ShapeDecoration(
        color: c.card,
        shape: StadiumBorder(
          side: BorderSide(
            color: typing ? c.accent : line,
            width: typing ? OnbSize.chipPickedRing : 1,
          ),
        ),
      ),
      child: Row(
        spacing: OnbSize.chipGap,
        children: [
          ExcludeSemantics(
            child: FillsChipDot(
              key: widget.dotKey,
              color: widget.color,
              glyph: widget.glyph,
            ),
          ),
          Expanded(
            child: Semantics(
              label: l10n.onboardingFillsFieldLabel,
              child: TextField(
                contextMenuBuilder: systemTextMenu,
                controller: widget.controller,
                focusNode: widget.focus,
                enabled: !widget.full,
                style: t.styles.onbChip,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (can) widget.onAdd();
                },
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: OnbSize.addWordsPad,
                  ),
                  border: InputBorder.none,
                  hintText: widget.full
                      ? l10n.onboardingHabitsMax
                      : l10n.onboardingFillsHint,
                  hintStyle: t.styles.onbFieldHint,
                  hintMaxLines: 1,
                ),
              ),
            ),
          ),
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.onboardingFillsCount(widget.count, maxFills),
              style: t.styles.onbCount,
            ),
          ),
          IconButton.filled(
            onPressed: can ? widget.onAdd : null,
            tooltip: l10n.onboardingFillsAdd,
            constraints: const BoxConstraints.tightFor(
              width: OnbSize.addButton,
              height: OnbSize.addButton,
            ),
            style: IconButton.styleFrom(
              backgroundColor: c.accent,
              foregroundColor: c.onAccent,
              disabledBackgroundColor: c.accent.withValues(
                alpha: OnbMotion.offOpacity,
              ),
            ),
            icon: DotIcon(
              DotGlyphs.add,
              color: can
                  ? c.onAccent
                  : c.onAccent.withValues(alpha: OnbMotion.offOpacity),
              size: OnbSize.addIcon,
              bold: true,
            ),
          ),
        ],
      ),
    );
  }
}
