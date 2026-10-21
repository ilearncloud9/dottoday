import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/timeline_header.dart';
import 'package:dottoday/features/timeline/widgets/timeline_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The home screen: one day's timeline (docs/03 §3.1, docs/02 F1). [date]
/// null shows today and follows midnight; `/day/:date` passes a date.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({this.date, super.key});

  final DateTime? date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayDateProvider).value;
    final shown = date ?? today;
    return Scaffold(
      key: ValueKey(
        date == null ? 'route:today' : 'route:day:${date!.toIso8601String()}',
      ),
      appBar: shown == null
          ? null
          : TimelineHeader(date: shown, textScale: timelineTextScale(context)),
      body: shown == null
          ? const SizedBox.shrink()
          : _Body(date: shown, isToday: shown == today),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.date, required this.isToday});

  final DateTime date;
  final bool isToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(timelineDataProvider(date));
    // Designed loading/error/empty states are M3.11; until then: blank
    // while loading (DB opens in well under 300 ms) and the failure text.
    return switch (data) {
      AsyncData(:final value) => TimelineView(data: value, isToday: isToday),
      AsyncError(:final error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Text(
            error is AppFailure
                ? failureMessage(context.l10n, error)
                : context.l10n.failureUnexpected,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
