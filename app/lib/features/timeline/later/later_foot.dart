import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/onboarding/first_today_store.dart';
import 'package:dottoday/data/onboarding/later_cards_store.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/timeline/first_today/foot_offer_card.dart';
import 'package:dottoday/features/timeline/later/habit_offer.dart';
import 'package:dottoday/features/timeline/later/habit_sheet.dart';
import 'package:dottoday/features/timeline/review/review_presenter.dart';
import 'package:dottoday/shared/layout/layout_switch.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

/// How long without an account before "Sign in to sync" comes once more.
const _syncAgainAfter = Duration(days: 7);

/// The one-time card at the foot of Today when nothing more pressing is
/// there, before Wind Down (ED-490, ED-491): the first Today's "Sign in to
/// sync", else "Make it a habit", "Want it simpler?" (from day 2), then
/// "Sign in to sync" once more a week on without an account. Not in Less.
Widget dayOffer(
  BuildContext context,
  WidgetRef ref, {
  required DateTime today,
  required DateTime now,
  required tz.Location zone,
}) {
  final first = ref.watch(firstTodayProvider).value;
  final guest =
      ref.watch(syncStatusProvider).value?.state == SyncState.localOnly;
  if (watchOnScreen(ref, FeatureId.firstToday) &&
      guest &&
      (first?.sync ?? false)) {
    return _sync(
      context,
      ref,
      key: 'first', // l10n-ignore: a widget key
      delay: OnbMotion.syncStart,
      done: () {
        unawaited(ref.read(firstTodayProvider.notifier).syncDone());
      },
    );
  }
  if (!watchOnScreen(ref, FeatureId.laterCards)) return const SizedBox.shrink();
  final later = ref.watch(laterCardsProvider).value;
  final since = later?.onboardedUtc;
  if (later == null || since == null) return const SizedBox.shrink();
  final store = ref.read(laterCardsProvider.notifier);
  final habit = ref.watch(habitOfferProvider(today)).value;
  if (habit != null) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return FootOfferCard(
      key: ValueKey('habit ${habit.series.id}'),
      glyph: DotGlyphs.repeat,
      title: l10n.laterHabitTitle,
      body: l10n.laterHabitBody(
        habit.series.title,
        weekdayList(l10n, locale, habit.days),
      ),
      action: l10n.laterHabitAction,
      onAction: () => unawaited(showHabitSheet(context, ref, habit)),
      onGone: () => unawaited(store.habitDone(habit.series.id)),
    );
  }
  final local = tz.TZDateTime.from(now, zone);
  final began = tz.TZDateTime.from(since, zone);
  final dayTwo = DateTime(
    local.year,
    local.month,
    local.day,
  ).isAfter(DateTime(began.year, began.month, began.day));
  if (!later.simpler && dayTwo) {
    final l10n = context.l10n;
    return FootOfferCard(
      key: const ValueKey('simpler'),
      glyph: DotGlyphs.onbLess,
      title: l10n.laterSimplerTitle,
      body: l10n.laterSimplerBody,
      action: l10n.laterSimplerAction,
      // The app's own switch (docs/14 §5): at once, nothing lost.
      onAction: () => setLayout(context, minimal: true),
      onGone: () => unawaited(store.simplerDone()),
    );
  }
  final week = !now.isBefore(since.add(_syncAgainAfter));
  if (!later.sync && guest && first?.sync == false && week) {
    return _sync(
      context,
      ref,
      key: 'again', // l10n-ignore: a widget key
      done: () {
        unawaited(store.syncDone());
      },
    );
  }
  return const SizedBox.shrink();
}

/// "Close the day" at the first Wind Down (ED-491): the review, kindly;
/// null once it has been, or in Less (then Today's own night prompt).
Widget? nightOffer(BuildContext context, WidgetRef ref, DateTime today) {
  if (!watchOnScreen(ref, FeatureId.laterCards)) return null;
  final later = ref.watch(laterCardsProvider).value;
  if (later == null || later.onboardedUtc == null || later.close) return null;
  final l10n = context.l10n;
  return FootOfferCard(
    key: const ValueKey('close'),
    glyph: DotGlyphs.onbMoon,
    title: l10n.laterCloseTitle,
    body: l10n.laterCloseBody,
    action: l10n.laterCloseTitle,
    onAction: () => unawaited(openReview(context, day: today)),
    onGone: () => unawaited(ref.read(laterCardsProvider.notifier).closeDone()),
  );
}

/// "Sign in to sync": Settings › Account.
Widget _sync(
  BuildContext context,
  WidgetRef ref, {
  required String key,
  required VoidCallback done,
  Duration delay = Duration.zero,
}) {
  final l10n = context.l10n;
  return FootOfferCard(
    key: ValueKey('sync $key'),
    delay: delay,
    glyph: DotGlyphs.onbCloud,
    title: l10n.firstSyncTitle,
    body: l10n.firstSyncBody,
    action: l10n.firstSyncSignIn,
    dismissLabel: l10n.firstSyncDismiss,
    // The router is looked up on the tap, where there is one.
    onAction: () => unawaited(
      GoRouter.of(context).push(AppRoutes.settingsPage(SettingsPage.account)),
    ),
    onGone: done,
  );
}
