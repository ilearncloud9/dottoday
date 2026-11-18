import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/shared/navigation/glass_capsule.dart';
import 'package:dottoday/shared/navigation/settings_button.dart';
import 'package:dottoday/shared/sync/sync_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The end of Today's top row (E-Phones, ED-034, ED-238): Sync and the
/// profile. On iPhone they share one glass capsule; Android's top app bar
/// shows them bare. [sync] is off in Minimal, which keeps the profile
/// alone until M19.6; at the medium width Settings is at the foot of the
/// rail, so Sync stands alone (ED-283).
class TodayTopActions extends ConsumerWidget {
  const TodayTopActions({required this.sync, super.key});

  final bool sync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phone = AppLayout.classOf(context) == WidthClass.compact;
    // Minimal's own top row comes with M19.6: its profile, as before.
    if (!sync) return phone ? const SettingsButton() : const SizedBox.shrink();
    final glass = DotIdiom.of(context) == DotIdiom.cupertino;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final children = [
      SyncButton(
        status: ref.watch(syncStatusProvider).value ?? SyncStatus.localOnly,
        now: now,
      ),
      if (phone) const SettingsButton(avatar: DotSize.capsuleAvatar),
    ];
    final row = Row(mainAxisSize: MainAxisSize.min, children: children);
    if (!glass) return row;
    return GlassCapsule(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DotSpace.xxs),
        child: row,
      ),
    );
  }
}

/// "‹ Today" (ED-034, `A-ios-future-month`): one tap back to the current
/// date from any other day, before the title. Its own glass capsule on
/// iPhone; a tonal pill on Android.
class TodayBack extends StatelessWidget {
  const TodayBack({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final glass = DotIdiom.of(context) == DotIdiom.cupertino;
    final label = context.l10n.todayPill;
    final content = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.s,
        0,
        DotSpace.m,
        0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.xxs,
        children: [
          DotIcon(
            DotGlyphs.chevronLeft,
            color: glass ? c.accentText : c.onTonalAndroid,
            size: DotSize.rowIcon,
            bold: true,
          ),
          Text(
            label,
            style: t.styles.button.copyWith(
              color: glass ? c.accentText : c.onTonalAndroid,
            ),
          ),
        ],
      ),
    );
    final button = Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: glass ? DotTouch.min : DotTouch.android,
          ),
          child: Center(widthFactor: 1, child: content),
        ),
      ),
    );
    if (glass) return GlassCapsule(child: button);
    return Material(
      color: c.tonalAndroid,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: button,
    );
  }
}
