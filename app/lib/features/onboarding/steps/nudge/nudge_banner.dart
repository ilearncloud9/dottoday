import 'dart:ui' as ui;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/onboarding/flow/css_saturate.dart';
import 'package:dottoday/shared/dot/solid_chrome.dart';
import 'package:flutter/material.dart';

/// The reminder preview (`.banner`): the app's mark, "Read in 10 minutes",
/// its times and when it would arrive, on glass, tagged PREVIEW. Read as
/// "Reminder preview".
class NudgeBanner extends StatelessWidget {
  const NudgeBanner({
    required this.title,
    required this.span,
    required this.when,
    required this.android,
    super.key,
  });

  final String title;

  /// "9:30 PM – 10:00 PM", or the time alone for Wind Down.
  final String span;

  /// "9:20 PM": ten minutes before.
  final String when;
  final bool android;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final radius = BorderRadius.circular(
      android ? OnbSize.bannerRadiusAndroid : OnbSize.bannerRadius,
    );
    final glass = c.raised.withValues(
      alpha: c.isDark ? OnbSize.glassAlphaDark : OnbSize.glassAlphaLight,
    );
    final solid = solidChrome(context);
    final body = ColoredBox(
      color: solid ? c.raised : glass,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: OnbSize.bannerPadV,
          horizontal: OnbSize.bannerPadH,
        ),
        child: _content(t),
      ),
    );
    return Semantics(
      container: true,
      label: l10n.onboardingNudgePreviewLabel,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [_softShadow(c)],
            ),
            // Solid with its outline under Reduce Transparency or
            // Increase Contrast (ED-248 C).
            position: DecorationPosition.background,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: radius,
                border: solidOutline(context),
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: solid ? body : _frost(body),
              ),
            ),
          ),
          PositionedDirectional(
            start: OnbSize.previewStart,
            top: -OnbSize.previewTop,
            child: _Tag(text: l10n.onboardingNudgePreview),
          ),
        ],
      ),
    );
  }

  /// The preview's frosted look, as the system draws a notification.
  Widget _frost(Widget child) => BackdropFilter(
    filter: ui.ImageFilter.compose(
      outer: ui.ImageFilter.blur(
        sigmaX: OnbSize.bannerBlur / 2,
        sigmaY: OnbSize.bannerBlur / 2,
      ),
      inner: ColorFilter.matrix(cssSaturate(OnbSize.bannerSaturation)),
    ),
    child: child,
  );

  Widget _content(DotTheme t) => Row(
    spacing: OnbSize.bannerGap,
    children: [
      const AppMark(),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: t.styles.onbBannerTitle),
            Text(span, style: t.styles.onbBannerLine),
          ],
        ),
      ),
      Align(
        alignment: AlignmentDirectional.topEnd,
        child: Text(when, style: t.styles.onbBannerWhen),
      ),
    ],
  );

  static BoxShadow _softShadow(DotColors c) => BoxShadow(
    color: c.shadow.withValues(
      alpha: c.isDark ? OnbSize.shadowAlphaDark : OnbSize.shadowAlphaLight,
    ),
    offset: const Offset(0, OnbSize.shadowY),
    blurRadius: OnbSize.shadowBlur,
    spreadRadius: OnbSize.shadowSpread,
  );
}

/// The app's mark as a notification shows it (`.appic`): the accent
/// square with a ringed dot.
class AppMark extends StatelessWidget {
  const AppMark({super.key});

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return ExcludeSemantics(
      child: Container(
        width: OnbSize.appIcon,
        height: OnbSize.appIcon,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(OnbSize.appIconRadius),
        ),
        child: Container(
          width: OnbSize.appIconDot,
          height: OnbSize.appIconDot,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.onAccent,
            boxShadow: [
              BoxShadow(color: c.onAccent, spreadRadius: OnbSize.appIconRing),
              BoxShadow(color: c.accent, spreadRadius: OnbSize.appIconGap),
            ],
          ),
        ),
      ),
    );
  }
}

/// "PREVIEW" (`.pv`): the toast colours, 18 high.
class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ExcludeSemantics(
      child: Container(
        height: OnbSize.previewHeight,
        padding: const EdgeInsets.symmetric(horizontal: OnbSize.previewPad),
        decoration: BoxDecoration(
          color: t.colors.toast,
          borderRadius: BorderRadius.circular(OnbSize.previewHeight / 2),
        ),
        child: Text(
          text,
          style: t.styles.onbPreviewTag.copyWith(color: t.colors.onToast),
        ),
      ),
    );
  }
}
