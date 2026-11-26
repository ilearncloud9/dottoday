import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/onboarding/flow/onb_buttons.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/text/balanced_text.dart';
import 'package:flutter/material.dart';

/// A switch on "Two more, if you like": its glyph and colour, words,
/// and whether it is on.
typedef NudgeOption = ({
  DotGlyph glyph,
  double glyphSize,
  Color color,
  String title,
  String line,
  bool on,
  ValueChanged<bool> onChanged,
});

/// The ask (`.sheet`): "Want this before Read?", the line, Allow nudges
/// and Not now. Once notifications are allowed it turns into "Two more,
/// if you like" with the Wake Up alarm and Wind Down reminder switches
/// and Done (ED-489, the owner's option C); the words cross-fade and the
/// sheet resizes.
class NudgeSheet extends StatelessWidget {
  const NudgeSheet({
    required this.subject,
    required this.more,
    required this.options,
    required this.onAllow,
    required this.onNotNow,
    required this.onDone,
    required this.allowFocus,
    required this.radius,
    super.key,
  });

  final String subject;

  /// Showing "Two more, if you like".
  final bool more;
  final List<NudgeOption> options;
  final VoidCallback? onAllow;
  final VoidCallback? onNotNow;
  final VoidCallback onDone;
  final FocusNode allowFocus;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Container(
        decoration: BoxDecoration(
          color: t.colors.raised,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: OnbSky.black.withValues(alpha: OnbSize.sheetShadowAlpha),
              offset: const Offset(0, OnbSize.sheetShadowY),
              blurRadius: OnbSize.sheetShadowBlur,
              spreadRadius: OnbSize.sheetShadowSpread,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            OnbSize.sheetPadSide,
            OnbSize.sheetPadTop,
            OnbSize.sheetPadSide,
            OnbSize.sheetPadBottom,
          ),
          child: AnimatedSize(
            duration: t.motion.isReduced ? Duration.zero : OnbMotion.stepIn,
            curve: OnbMotion.decelerate,
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: OnbMotion.fade,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.bottomCenter,
                children: [...previous, ?current],
              ),
              child: more ? _more(context, t) : _ask(context, t),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ask(BuildContext context, DotTheme t) {
    final l10n = context.l10n;
    return Column(
      key: const ValueKey('ask'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(t, l10n.onboardingNudgeAsk(subject)),
        const SizedBox(height: OnbSize.subTop),
        Text(l10n.onboardingNudgeBody, style: t.styles.onbSub),
        const SizedBox(height: OnbSize.sheetCtaTop),
        OnbPrimary(
          label: l10n.onboardingAllowNudges,
          onPressed: onAllow,
          focusNode: allowFocus,
        ),
        const SizedBox(height: OnbSize.ctaGap),
        OnbSecondary(label: l10n.onboardingNotNow, onPressed: onNotNow),
      ],
    );
  }

  Widget _more(BuildContext context, DotTheme t) {
    final l10n = context.l10n;
    final line = OnbSky.of(
      t.colors.isDark ? Brightness.dark : Brightness.light,
    ).line;
    return Column(
      key: const ValueKey('more'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(t, l10n.onboardingTwoMore),
        const SizedBox(height: OnbSize.subTop),
        Text(l10n.onboardingTwoMoreBody, style: t.styles.onbSub),
        const SizedBox(height: OnbSize.moreTop),
        ClipRRect(
          borderRadius: BorderRadius.circular(OnbSize.moreRadius),
          child: ColoredBox(
            color: t.colors.surface,
            child: Column(
              children: [
                for (final (i, o) in options.indexed) ...[
                  if (i > 0) Divider(height: 1, thickness: 1, color: line),
                  _Option(option: o),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: OnbSize.sheetCtaTop),
        OnbPrimary(label: l10n.sheetDone, onPressed: onDone),
      ],
    );
  }

  static Widget _title(DotTheme t, String text) => Semantics(
    header: true,
    child: LayoutBuilder(
      builder: (_, box) => BalancedText(
        text,
        style: t.styles.onbTitle,
        textAlign: TextAlign.start,
        maxWidth: box.maxWidth,
      ),
    ),
  );
}

/// One switch row: the dot in its colour, the words, the platform's
/// switch. The whole row toggles; read as a switch with its words.
class _Option extends StatelessWidget {
  const _Option({required this.option});

  final NudgeOption option;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final o = option;
    return MergeSemantics(
      child: InkWell(
        onTap: () => o.onChanged(!o.on),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: OnbSize.moreRow),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: OnbSize.moreRowPadV,
              horizontal: OnbSize.moreRowPadH,
            ),
            child: Row(
              spacing: OnbSize.moreGap,
              children: [
                Container(
                  width: OnbSize.anchorDot,
                  height: OnbSize.anchorDot,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.colors.raised,
                    border: Border.all(color: o.color, width: OnbSize.rowRing),
                  ),
                  child: DotIcon(o.glyph, color: o.color, size: o.glyphSize),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.title, style: t.styles.onbMoreTitle),
                      Text(o.line, style: t.styles.onbMoreLine),
                    ],
                  ),
                ),
                DotSwitch(value: o.on, onChanged: o.onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
