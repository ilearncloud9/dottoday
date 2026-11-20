import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/core/editing/inspected_task.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_actions.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_details.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_more.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_rows.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The Workspace inspector for task [id] (E-FullA-v2, ED-170 C1, rules
/// §627): its ring, title and state; Need more time? while it runs; Done,
/// Focus, Shift rest; Date, Time, Repeat, Alerts; Subtasks; the overlap;
/// Notes; then Energy, Sound, Travel time, Pinned and Delete (R2-40). Every change is written as it is made (ED-086). A task that
/// goes away (deleted, another owner) takes the inspector with it.
class WorkspaceInspector extends ConsumerWidget {
  const WorkspaceInspector({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(taskViewProvider(id));
    return switch (view) {
      AsyncValue(hasValue: true, value: final TaskView task) => _Body(
        task: task,
      ),
      AsyncData(value: null) ||
      AsyncError(error: NotFoundFailure()) => _Gone(id: id),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.task});

  final TaskView task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = task.occurrence;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final live = dotStateOf(o, now) == DotState.live;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: context.l10n.inspectorRegion(o.title),
      child: ListView(
        padding: const EdgeInsets.all(DotSize.inspectorPad),
        children: [
          for (final w in [
            _Header(task: o, now: now),
            if (live) InspectorExtend(task: o),
            InspectorButtons(task: o),
            InspectorRows(task: task),
            const _Rule(),
            if (task.subtasks.isNotEmpty) ...[
              InspectorSubtasks(task: task),
              const _Rule(),
            ],
            InspectorOverlap(task: o),
            InspectorNotes(key: ValueKey(o.id), task: o),
            const _Rule(),
            InspectorMore(task: task),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: DotSpace.m),
              child: w,
            ),
        ],
      ),
    );
  }
}

/// The 38 ring, the title 18/23 and "Now, 18 min left" (or the time).
class _Header extends ConsumerWidget {
  const _Header({required this.task, required this.now});

  final Occurrence task;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final o = task;
    final state = dotStateOf(o, now);
    final live = state == DotState.live;
    final left = live
        ? (o.endUtc!.difference(now).inSeconds / 60).ceil()
        : null;
    final progress = live
        ? now.difference(o.startUtc!).inSeconds /
              o.endUtc!.difference(o.startUtc!).inSeconds
        : 0.0;
    return Row(
      spacing: DotSpace.s + DotSpace.xxs,
      children: [
        TaskDot(
          color: TaskColor.fromKey(o.colorKey),
          icon: TaskIcon.fromKey(o.iconKey),
          state: state,
          progress: progress,
          size: DotSize.inspectorRing,
          label: taskDotLabel(
            l10n,
            title: o.title,
            state: state,
            minutesLeft: left,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(o.title, style: t.styles.inspectorTitle),
              ),
              if (_status(context, ref, left) case final s?)
                Text(
                  s,
                  style: t.styles.inspectorStatus.copyWith(
                    color: live ? c.accent : null,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String? _status(BuildContext context, WidgetRef ref, int? left) {
    if (left != null) return context.l10n.liveNowLeft(left);
    final start = task.startUtc;
    if (start == null) return null;
    final zone = tz.getLocation(task.tzId);
    final use24h = use24hFor(
      context,
      ref.watch(currentProfileProvider).value?.settings.use24h,
    );
    String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    return context.l10n.blockTimeRange(time(start), time(task.endUtc!));
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) => Divider(
    height: DotSpace.hairline,
    thickness: DotSpace.hairline,
    color: DotTheme.of(context).colors.hairline,
  );
}

/// The task is gone: put the inspector away (and `?task=` with it).
class _Gone extends ConsumerStatefulWidget {
  const _Gone({required this.id});

  final String id;

  @override
  ConsumerState<_Gone> createState() => _GoneState();
}

class _GoneState extends ConsumerState<_Gone> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(inspectedTaskProvider) != widget.id) return;
      ref.read(inspectedTaskProvider.notifier).close();
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
