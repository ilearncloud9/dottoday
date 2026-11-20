import 'dart:async';

import 'package:dottoday/core/editing/pending_routine_drop.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/routines/routine_providers.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/icon_keys.dart';
import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/task_editor/add/create/create_task_pickers.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_learned_lines.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_routine_chips.dart';
import 'package:dottoday/features/task_editor/add/widgets/habit_list.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/feedback/paste_confirm.dart';
import 'package:dottoday/shared/pickers/alerts/alerts_editor.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_text.dart';
import 'package:dottoday/shared/task_form/task_form_header.dart';
import 'package:dottoday/shared/task_form/task_form_rows.dart';
import 'package:dottoday/shared/task_form/task_form_steps.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Create task's Task tab (ED-140, option D's form, ED-086): the title with
/// its parser hint, When (date, time and length, alerts), Repeat · Energy,
/// Steps and Notes; under them, while the title is empty, the habits and
/// routines to start from (owner, M19.3). Nothing is written here:
/// [onSubmit] (Return) and the header's Create task write it.
class CreateTaskForm extends ConsumerStatefulWidget {
  const CreateTaskForm({
    required this.request,
    required this.onSubmit,
    required this.onAddMany,
    super.key,
  });

  final AddRequest request;
  final VoidCallback onSubmit;

  /// A pasted list: the proposal plans each line (R-07, ED-150).
  final VoidCallback onAddMany;

  @override
  ConsumerState<CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends ConsumerState<CreateTaskForm> {
  // Leaf view state (CLAUDE.md §4): the title's text and selection.
  late final _title = TextEditingController(
    text: ref.read(addFlowProvider(widget.request)).value?.text ?? '',
  );

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  AddFlow get _flow => ref.read(addFlowProvider(widget.request).notifier);

  void _keepOne(String text) {
    final one = QuickAddParser.joinLines(text);
    _title.text = one;
    _flow.type(one);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addFlowProvider(widget.request)).value;
    final profile = ref.watch(currentProfileProvider).value;
    if (state == null || profile == null) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final draft = currentDraft(ref, widget.request, state);
    final room = ref.watch(dayRoomProvider(draft.day)).value;
    final start =
        draft.startUtc ?? (room == null ? null : firstFreeStart(room, draft));
    final use24h = use24hFor(context, profile.settings.use24h);
    final zone = tz.getLocation(profile.tzId);
    String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    final range = start == null
        ? null
        : l10n.threadTimeRange(
            time(start),
            time(start.add(Duration(minutes: draft.length))),
          );
    final dayName = relativeDayName(context, draft.day, draft.today);
    final length = formatDurationShort(l10n, draft.length);
    final pick = CreateTaskPickers(context, ref, widget.request);
    final lines = QuickAddParser.lines(state.text);
    final android = DotIdiom.of(context) == DotIdiom.material;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: DotSpace.xl),
      children: [
        TaskFormHeader(
          color: TaskColor.fromKey(draft.color),
          // A task with no icon yet shows the pencil, as drawn (ED-140).
          icon: draft.icon == defaultIconKey
              ? TaskIcon.pencil
              : TaskIcon.fromKey(draft.icon),
          card: android,
          onLook: (at) => unawaited(pick.look(anchor: at)),
          summary: range == null
              ? null
              : l10n.addWhenSummary(dayName, range, length),
          title: TaskFormTitleField(
            controller: _title,
            hint: l10n.editorTitleHint,
            autofocus: true,
            // ED-135: the neutral return on iOS, never "done"; Android
            // keeps the IME's check.
            action: android
                ? TextInputAction.done
                : TextInputAction.unspecified,
            onChanged: _flow.type,
            onSubmitted: (_) =>
                lines.length > 1 ? widget.onAddMany() : widget.onSubmit(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DotSpace.page,
            DotSpace.s,
            DotSpace.page,
            DotSpace.m,
          ),
          child: lines.length > 1
              ? PasteConfirm(
                  count: lines.length,
                  onAdd: widget.onAddMany,
                  onKeepOne: () => _keepOne(state.text),
                )
              : Text(l10n.addTypeTimeHint, style: t.styles.rowMeta),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DotSpace.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DotSpace.m,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TaskFormCard(
                    rows: [
                      TaskFormRow(
                        glyph: DotGlyphs.calendar,
                        value: DateFormat.MMMEd(
                          l10n.localeName,
                        ).format(draft.day),
                        trailing: dayName,
                        onTap: () => unawaited(pick.day()),
                      ),
                      TaskFormRow(
                        glyph: DotGlyphs.clock,
                        value: range ?? l10n.addTimeCaption,
                        trailing: length,
                        trailingLabel: l10n.listJoin(
                          l10n.addDurationCaption,
                          length,
                        ),
                        onTap: () => unawaited(
                          pick.time(
                            start == null
                                ? 9 * 60
                                : ClockTime.ofUtc(zone, start).minutesOfDay,
                          ),
                        ),
                        onTrailing: () => unawaited(pick.length()),
                      ),
                      _alertsRow(
                        l10n,
                        draft,
                        profile.settings.defaultAlerts,
                        pick,
                      ),
                    ],
                  ),
                  AddLearnedLines(request: widget.request),
                ],
              ),
              TaskFormPills(
                pills: [
                  TaskFormPill(
                    glyph: DotGlyphs.repeat,
                    caption: l10n.sheetRepeat,
                    value: _repeatText(l10n, draft),
                    onTap: () => unawaited(pick.repeat()),
                  ),
                  TaskFormPill(
                    glyph: DotGlyphs.bolt,
                    caption: l10n.editorEnergy,
                    value: switch (draft.details.energy) {
                      final e? => energyName(l10n, e),
                      null => l10n.formEnergyNone,
                    },
                    onTap: () => unawaited(pick.energy()),
                  ),
                ],
              ),
              TaskFormSteps(
                stepsCaption: l10n.formSteps,
                addStepHint: l10n.breakdownAddStep,
                notesCaption: l10n.editorNotes,
                notesHint: l10n.formNotesHint,
                steps: [for (final s in draft.steps) s.title],
                onAddStep: (s) => _flow.edit(
                  (d) => d.withSteps([...d.steps, ProposedStep(title: s)]),
                ),
                notes: draft.details.notes,
                onNotes: (n) => _flow.edit(
                  (d) => d.withDetails(d.details.copyWith(notes: n)),
                ),
              ),
              if (draft.title.isEmpty) ..._suggestions(state, use24h),
            ],
          ),
        ),
      ],
    );
  }

  TaskFormRow _alertsRow(
    AppLocalizations l10n,
    AddDraft draft,
    List<Alert> defaults,
    CreateTaskPickers pick,
  ) {
    final alerts = draft.details.alerts ?? defaults;
    return TaskFormRow(
      glyph: DotGlyphs.bell,
      value: alerts.isEmpty
          ? l10n.formNoAlerts
          : l10n.blockAlerts(alerts.length),
      detail: alerts.isEmpty
          ? null
          : [
              for (final a in alerts) alertLabel(l10n, a),
            ].reduce(l10n.alertJoin),
      onTap: () => unawaited(pick.alerts()),
    );
  }

  String _repeatText(AppLocalizations l10n, AddDraft draft) {
    final rrule = draft.rrule;
    if (rrule == null) return l10n.sheetNever;
    final rule = draft.details.repeat?.rule ?? RepeatRule.parse(rrule);
    if (rule == null) return l10n.repeatCustom;
    return repeatRuleText(l10n, l10n.localeName, rule, draft.day);
  }

  /// Habits and routines to start from (ED-091 kept them under Add).
  List<Widget> _suggestions(AddFlowState state, bool use24h) {
    final habits = ref.watch(habitsProvider).value ?? const [];
    final shown = const SuggestionService().match(state.draft.title, habits);
    final routines = ref.watch(routinesProvider).value ?? const [];
    return [
      if (shown.isNotEmpty)
        HabitList(
          habits: shown,
          selected: state.draft.habit,
          use24h: use24h,
          onPick: (h) {
            _title.text = h.title;
            _flow.pickHabit(h);
          },
        ),
      if (routines.isNotEmpty)
        AddRoutineChips(
          routines: routines,
          typed: state.draft.title,
          onPick: (r) {
            ref
                .read(pendingRoutineDropProvider.notifier)
                .request(
                  RoutineDropRequest(
                    routine: r,
                    date: state.draft.day,
                    today: state.draft.today,
                  ),
                );
            unawaited(Navigator.of(context).maybePop());
          },
        ),
    ];
  }
}
