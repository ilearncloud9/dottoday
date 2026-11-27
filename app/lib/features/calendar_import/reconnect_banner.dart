import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/calendar/cloud_calendar_providers.dart';
import 'package:dottoday/domain/calendar/cloud_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/shared/feedback/banner_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Dottoday can't reach this account until you reconnect it" with
/// Reconnect, above every screen while a connected Google or Microsoft
/// account needs signing in again (E-R2-24 §2 "Strips above every
/// screen", ED-497). Its events stay meanwhile; Settings › Calendars says
/// the same on the account.
class ReconnectBanner extends ConsumerWidget {
  const ReconnectBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(cloudCalendarsProvider).available) {
      return const SizedBox.shrink();
    }
    final accounts = ref.watch(cloudAccountsProvider).value ?? const [];
    final stale = accounts
        .where((a) => a.status == CloudAccountStatus.reconnect)
        .firstOrNull;
    if (stale == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    return BannerStrip(
      card: true,
      text: l10n.calendarsReconnectDetail,
      actions: [
        (
          l10n.calendarsReconnect,
          () => unawaited(_reconnect(context, ref, stale.provider)),
        ),
      ],
    );
  }

  /// Opens the sign-in again; a failure says so (never swallowed).
  Future<void> _reconnect(
    BuildContext context,
    WidgetRef ref,
    CalendarProvider provider,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final result = await ref
        .read(cloudCalendarActionsProvider)
        .connect(provider);
    if (result case Err(:final failure)) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    }
  }
}
