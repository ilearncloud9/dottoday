import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_lexicon.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:flutter/foundation.dart';
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
  const AddRequest({required this.languageCode, this.text = ''});

  /// The UI language, which Quick Add parses in (as the Inbox field does).
  final String languageCode;

  /// Text the title starts with.
  final String text;

  @override
  bool operator ==(Object other) =>
      other is AddRequest &&
      other.languageCode == languageCode &&
      other.text == text;

  @override
  int get hashCode => Object.hash(languageCode, text);
}

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
  });

  final AddDraft draft;

  /// The title field as typed.
  final String text;
  final QuickAddLanguage language;
  final AddStep step;

  AddFlowState copyWith({AddDraft? draft, String? text, AddStep? step}) =>
      AddFlowState(
        draft: draft ?? this.draft,
        text: text ?? this.text,
        language: language,
        step: step ?? this.step,
      );
}

/// The Add sheet's draft (M3c). One per open sheet; disposed with it.
@riverpod
class AddFlow extends _$AddFlow {
  @override
  Future<AddFlowState> build(AddRequest request) async {
    final now = ref.read(clockProvider).nowUtc();
    final profile = await ref.read(currentProfileProvider.future);
    final local = tz.TZDateTime.from(now, tz.getLocation(profile.tzId));
    final language =
        QuickAddLanguage.values.asNameMap()[request.languageCode] ??
        QuickAddLanguage.en;
    // Keep habits live for the sheet's life, and re-match the title when
    // they arrive or change (the first emission races the draft).
    ref.listen(habitsProvider, (_, next) {
      if (next.hasValue) _rematch();
    });
    await ref.read(habitsProvider.future);
    final initial = AddFlowState(
      draft: AddDraft(
        today: DateTime(local.year, local.month, local.day),
        tzId: profile.tzId,
        defaultDurationMin: profile.settings.defaultDurationMin,
      ),
      text: '',
      language: language,
    );
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
    return s.copyWith(
      text: text,
      draft: s.draft.withTyped(typed).withHabit(habit),
    );
  }
}

/// Recognised tokens of [draft] with their text, for the removable chips.
List<({QuickAddToken token, String text})> tokenTexts(QuickAddDraft draft) => [
  for (final t in draft.tokens)
    (token: t, text: draft.text.substring(t.start, t.end)),
];
