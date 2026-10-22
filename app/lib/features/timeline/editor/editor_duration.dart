import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/time/duration_presets.dart';
import 'package:dottoday/shared/dot/round_more_button.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/duration/duration_preview.dart';
import 'package:dottoday/shared/duration/duration_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// E1's DURATION (`A-mac-editor`, restyled in M3c.3 as the Add flow's
/// pills): the user's presets, and ⋯ for the Duration sheet with its
/// live preview on the task's day.
class EditorDuration extends ConsumerWidget {
  const EditorDuration({
    required this.task,
    required this.onChanged,
    super.key,
  });

  final Occurrence task;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final settings = ref.watch(currentProfileProvider).value?.settings;
    final day = _localDay();
    // Warm for the sheet's preview; inbox tasks have no day.
    final room = day == null ? null : ref.watch(dayRoomProvider(day)).value;
    final presets = settings?.durationPresets ?? defaultDurationPresets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: DotSpace.l, bottom: DotSpace.s),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.editorDuration.toUpperCase(),
                    style: t.styles.caption,
                  ),
                ),
              ),
              RoundMoreButton(
                tooltip: l10n.addMoreDuration,
                onTap: () => unawaited(_sheet(context, ref, presets, room)),
              ),
            ],
          ),
        ),
        DurationRow(
          presets: presets,
          value: task.durationMin,
          onChanged: onChanged,
        ),
      ],
    );
  }

  DateTime? _localDay() {
    final start = task.startUtc;
    if (start == null) return null;
    final local = tz.TZDateTime.from(start, tz.getLocation(task.tzId));
    return DateTime(local.year, local.month, local.day);
  }

  Future<void> _sheet(
    BuildContext context,
    WidgetRef ref,
    List<int> presets,
    DayRoom? room,
  ) async {
    final container = ProviderScope.containerOf(context);
    final start = task.startUtc;
    final day = _localDay();
    final text = day == null
        ? null
        : DayTimeText(
            context,
            tz.getLocation(task.tzId),
            day,
            use24h: use24hFor(
              context,
              ref.read(currentProfileProvider).value?.settings.use24h,
            ),
          );
    final minutes = await showDurationSheet(
      context,
      initial: task.durationMin,
      color: TaskColor.fromKey(task.colorKey),
      icon: TaskIcon.fromKey(task.iconKey),
      presets: presets,
      onPresets: (p) => unawaited(
        updateSettings(container, (s) => s.copyWith(durationPresets: p)),
      ),
      preview: room == null || start == null || text == null
          ? null
          : (m) => durationPreview(
              context,
              room,
              start,
              m,
              text,
              ignoreId: task.id,
            ),
    );
    if (minutes != null) onChanged(minutes);
  }
}
