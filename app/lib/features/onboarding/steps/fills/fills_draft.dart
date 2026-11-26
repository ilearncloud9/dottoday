import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/onboarding/day_fills.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fills_draft.g.dart';

/// What is picked on "What fills your days?": kept while you go Back and
/// forth, as the prototype keeps it (`st.routines`, `st.custom`). Typed
/// ones stay as chips when unpicked. Every chip has its series id from
/// the start, so saving twice updates the same tasks.
@Riverpod(keepAlive: true)
class FillsDraft extends _$FillsDraft {
  @override
  FillsDraftState build() => FillsDraftState(
    presetIds: {
      for (final p in FillPreset.values) p: const UuidV7Generator().newId(),
    },
  );

  /// Picks or unpicks the chip [id]; a sixth pick is refused.
  void toggle(String id) {
    final on = state.picked.contains(id);
    if (!on && state.full) return;
    state = state.copy(
      picked: on ? (state.picked.toSet()..remove(id)) : {...state.picked, id},
    );
  }

  /// Adds a typed [fill], picked.
  void add(DayFill fill) {
    if (state.full) return;
    state = state.copy(
      typed: [...state.typed, fill],
      picked: {...state.picked, fill.id},
    );
  }

  /// Notes what [saved] wrote, so a later save can take back what was
  /// unpicked since.
  void saved(Iterable<String> ids) => state = state.copy(planted: {...ids});
}

/// The typed chips, which chips are picked, and what was last saved.
final class FillsDraftState {
  const FillsDraftState({
    required this.presetIds,
    this.typed = const [],
    this.picked = const {},
    this.planted = const {},
  });

  final Map<FillPreset, String> presetIds;
  final List<DayFill> typed;
  final Set<String> picked;
  final Set<String> planted;

  /// Whether five are picked.
  bool get full => picked.length >= maxFills;

  FillsDraftState copy({
    List<DayFill>? typed,
    Set<String>? picked,
    Set<String>? planted,
  }) => FillsDraftState(
    presetIds: presetIds,
    typed: typed ?? this.typed,
    picked: picked ?? this.picked,
    planted: planted ?? this.planted,
  );
}
