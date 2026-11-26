import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/onboarding/first_today_store.dart';
import 'package:dottoday/features/timeline/first_today/first_today_rise.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Sign in to sync" at the foot of the first Today (the prototype's
/// `.sync`, ED-490): the cloud, "Use Dottoday on all your devices with a
/// copy kept safe.", Sign in (Settings › Account) and ✕. It rises in at
/// 1.6 s; ✕ or Sign in lets it go for good (10 down, 300 ms).
class FirstSyncCard extends ConsumerStatefulWidget {
  const FirstSyncCard({super.key});

  @override
  ConsumerState<FirstSyncCard> createState() => _FirstSyncCardState();
}

/// A leaf: only whether it is leaving.
class _FirstSyncCardState extends ConsumerState<FirstSyncCard> {
  var _gone = false;

  void _leave({bool signIn = false}) {
    if (_gone) return;
    final router = GoRouter.of(context);
    setState(() => _gone = true);
    Future<void>.delayed(OnbMotion.syncLeave, () {
      unawaited(ref.read(firstTodayProvider.notifier).syncDone());
    }).ignore();
    if (signIn) {
      unawaited(router.push(AppRoutes.settingsPage(SettingsPage.account)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final line = OnbSky.of(c.isDark ? Brightness.dark : Brightness.light).line;
    return Padding(
      // Today's page margin at the sides, as its other foot prompts.
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        OnbSize.syncTop,
        DotSpace.page,
        OnbSize.syncBottom,
      ),
      child: AnimatedOpacity(
        opacity: _gone ? 0 : 1,
        duration: OnbMotion.syncLeave,
        child: AnimatedSlide(
          offset: _gone ? const Offset(0, 0.1) : Offset.zero,
          duration: OnbMotion.syncLeave,
          child: FirstTodayRise(
            delay: OnbMotion.syncStart,
            child: Container(
              padding: const EdgeInsetsDirectional.fromSTEB(
                OnbSize.syncPadStart,
                OnbSize.syncPadV,
                OnbSize.syncPadEnd,
                OnbSize.syncPadV,
              ),
              decoration: ShapeDecoration(
                color: c.raised,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(OnbSize.syncRadius),
                  side: BorderSide(color: line),
                ),
              ),
              child: _body(context, t),
            ),
          ),
        ),
      ),
    );
  }

  /// The cloud, the words, Sign in and ✕ in one row; at large text Sign
  /// in goes on its own line under the words, so nothing breaks.
  Widget _body(BuildContext context, DotTheme t) {
    final c = t.colors;
    final l10n = context.l10n;
    final large =
        MediaQuery.textScalerOf(context).scale(1) > OnbSize.syncLargeText;
    final words = Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.firstSyncTitle, style: t.styles.onbSyncTitle),
          Text(l10n.firstSyncBody, style: t.styles.onbSyncBody),
        ],
      ),
    );
    final cloud = DotIcon(
      DotGlyphs.onbCloud,
      color: c.accentInk,
      size: OnbSize.syncIcon,
    );
    final signIn = FilledButton.tonal(
      onPressed: () => _leave(signIn: true),
      style: FilledButton.styleFrom(
        backgroundColor: c.accentTint,
        foregroundColor: c.accentInk,
        textStyle: t.styles.onbSyncButton,
        minimumSize: const Size(0, OnbSize.syncButton),
        padding: const EdgeInsets.symmetric(horizontal: OnbSize.syncButtonPad),
        shape: const StadiumBorder(),
      ),
      child: Text(l10n.firstSyncSignIn),
    );
    final close = IconButton(
      onPressed: _leave,
      tooltip: l10n.firstSyncDismiss,
      constraints: const BoxConstraints.tightFor(
        width: OnbSize.syncClose,
        height: OnbSize.syncClose,
      ),
      icon: DotIcon(
        DotGlyphs.close,
        color: c.muted,
        size: OnbSize.syncCloseIcon,
      ),
    );
    if (!large) {
      return Row(
        spacing: OnbSize.syncGap,
        children: [cloud, words, signIn, close],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: OnbSize.syncGap,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: OnbSize.syncGap,
          children: [cloud, words, close],
        ),
        signIn,
      ],
    );
  }
}
