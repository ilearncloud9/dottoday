import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/scheduling/learning_providers.dart';
import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_lexicon.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'add_flow.g.dart';

/// How far back Suggestions look for habits.
const habitHistoryDays = 60;

/// The user's habits from the last [habitHistoryDays] days (docs/10 §6
/// "Suggestions come from the user's own history"), live.
@riverpod
Stream<List<HabitSuggestion>> habits(Ref ref) {
  final profile = ref.watch(currentProfileProvider.future);
  final repo = ref.watch(occurrenceRepositoryProvider);
  final now = ref.watch(clockProvider).nowUtc();
  return Stream.fromFuture(profile).asyncExpand((p) {
    final zone = tz.getLocation(p.tzId);
    return repo
        .watchRange(
          p.id,
          now.subtract(const Duration(days: habitHistoryDays)),
          now.add(const Duration(days: 1)),
        )
        .map((rows) => const SuggestionService().fromHistory(rows, zone));
  });
}

/// Where Add opens: blank (the add button, ⌘N) or prefilled.
@immutable
final class AddRequest {
  const AddRequest({
    required this.languageCode,
    this.text = '',
    this.startUtc,
    this.day,
    this.resume,
  });

  /// The UI language, which Quick Add parses in (as the Inbox field does).
  final String languageCode;

  /// Text the title starts with.
  final String text;

  /// A start to begin from (an "add here" gap, R-17).
  final DateTime? startUtc;

  /// A local date to begin on ("Add to this day").
  final DateTime? day;

  /// A sheet to reopen as it was: its save failed after it closed
  /// (M8.5b, R-08 "never lose typed input"). Compared by identity.
  final AddFlowState? resume;

  @override
  bool operator ==(Object other) =>
      other is AddRequest &&
      other.languageCode == languageCode &&
      other.text == text &&
      other.startUtc == startUtc &&
      other.day == day &&
      identical(other.resume, resume);

  @override
  int get hashCode =>
      Object.hash(languageCode, text, startUtc, day, identityHashCode(resume));
}

/// Which save a failed one was, so Try again repeats it.
enum AddRetry { save, inbox, another, many }

/// A save that didn't land, shown on the sheet with Try again (M8.5b).
typedef AddSaveFailure = ({AppFailure failure, AddRetry retry});

/// The two steps (docs/10 §3 `AddFlow`): What, then When.
enum AddStep { what, when }

/// Everything the Add sheet shows.
@immutable
final class AddFlowState {
  const AddFlowState({
    required this.draft,
    required this.text,
    required this.language,
    this.step = AddStep.what,
    this.saveFailure,
  });

  final AddDraft draft;

  /// The title field as typed.
  final String text;
  final QuickAddLanguage language;
  final AddStep step;

  /// The last save, when it failed; the draft above is what it tried.
  final AddSaveFailure? saveFailure;

  AddFlowState copyWith({AddDraft? draft, String? text, AddStep? step}) =>
      AddFlowState(
        draft: draft ?? this.draft,
        text: text ?? this.text,
        language: language,
        step: step ?? this.step,
        saveFailure: saveFailure,
      );

  /// This state with [failure] showing (null clears it).
  AddFlowState withFailure(AddSaveFailure? failure) => AddFlowState(
    draft: draft,
    text: text,
    language: language,
    step: step,
    saveFailure: failure,
  );
}

/// The Add sheet's draft (M3c). One per open sheet; disposed with it.
@riverpod
class AddFlow extends _$AddFlow {
  @override
  Future<AddFlowState> build(AddRequest request) async {
    // Listen before any await: a provider that is only read can be dropped
    // before its first value (Riverpod 3). Habits re-match the title when
    // they arrive or change (the first emission races the draft).
    ref
      ..listen(currentProfileProvider, (_, _) {})
      ..listen(habitsProvider, (_, next) {
        if (next.hasValue) _rematch();
      })
      ..listen(learningIndexProvider, (_, next) {
        if (next.hasValue) _rematch();
      });
    if (request.resume case final resumed?) return resumed;
    final now = ref.read(clockProvider).nowUtc();
    final profile = await ref.read(currentProfileProvider.future);
    final local = tz.TZDateTime.from(now, tz.getLocation(profile.tzId));
    final language =
        QuickAddLanguage.values.asNameMap()[request.languageCode] ??
        QuickAddLanguage.en;
    await ref.read(habitsProvider.future);
    var draft = AddDraft(
      today: DateTime(local.year, local.month, local.day),
      tzId: profile.tzId,
      defaultDurationMin: profile.settings.defaultDurationMin,
    );
    if (request.day case final day?) draft = draft.openedOn(day);
    if (request.startUtc case final start?) {
      draft = draft.openedAt(start, snap: profile.settings.snapMinutes);
    }
    final initial = AddFlowState(draft: draft, text: '', language: language);
    return _typed(initial, request.text);
  }

  AddFlowState? get _now => state.value;

  /// The title field changed: re-parse it (live fill, R-06) and pick the
  /// habit it names exactly.
  void type(String text) {
    final s = _now;
    if (s == null || s.text == text) return;
    state = AsyncData(_typed(s, text));
  }

  /// Takes [habit]'s title, time, length, colour and icon.
  void pickHabit(HabitSuggestion habit) => type(habit.title);

  void edit(AddDraft Function(AddDraft draft) change) {
    final s = _now;
    if (s == null) return;
    state = AsyncData(s.copyWith(draft: change(s.draft)));
  }

  /// After "Add another": a blank step 1 on the same day, starting where
  /// [saved] ends (R-07 "Add another keeps the sheet open").
  void another(AddDraft saved) {
    final s = _now;
    if (s == null) return;
    final end = saved.startMinute == null
        ? null
        : saved.startMinute! + saved.length;
    state = AsyncData(
      AddFlowState(
        draft: AddDraft(
          today: saved.today,
          tzId: saved.tzId,
          defaultDurationMin: saved.defaultDurationMin,
          date: saved.day,
          minuteOfDay: end != null && end < Duration.minutesPerDay ? end : null,
        ),
        text: '',
        language: s.language,
      ),
    );
  }

  /// A save failed with the sheet still open (or about to reopen).
  void failed(AddSaveFailure? failure) {
    final s = _now;
    if (s == null) return;
    state = AsyncData(s.withFailure(failure));
  }

  void goTo(AddStep step) {
    final s = _now;
    if (s == null || s.step == step) return;
    state = AsyncData(s.copyWith(step: step));
  }

  void _rematch() {
    final s = _now;
    if (s == null) return;
    state = AsyncData(_typed(s, s.text));
  }

  AddFlowState _typed(AddFlowState s, String text) {
    final parsed = const QuickAddParser().parse(
      text,
      QuickAddContext(
        nowUtc: ref.read(clockProvider).nowUtc(),
        tzId: s.draft.tzId,
        language: s.language,
      ),
    );
    // Over-long input (06 §7) keeps the last good parse; the field's
    // maxLength stops it before that.
    final typed = switch (parsed) {
      Ok(:final value) => value,
      Err() => s.draft.typed,
    };
    final habits = ref.read(habitsProvider).value ?? const [];
    final habit = const SuggestionService().exact(typed.title, habits);
    final learned =
        ref.read(learningIndexProvider).value?.forTask(title: typed.title) ??
        Learned.none;
    return s.copyWith(
      text: text,
      draft: s.draft.withTyped(typed).withHabit(habit).withLearned(learned),
    );
  }
}

/// Recognised tokens of [draft] with their text, for the removable chips.
List<({QuickAddToken token, String text})> tokenTexts(QuickAddDraft draft) => [
  for (final t in draft.tokens)
    (token: t, text: draft.text.substring(t.start, t.end)),
];

/// The draft as it is now: Enter can arrive before the frame that rebuilt
/// the callbacks with the last keystroke.
AddDraft currentDraft(WidgetRef ref, AddRequest request, AddFlowState shown) =>
    ref.read(addFlowProvider(request)).value?.draft ?? shown.draft;
