import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'travel_dismissed.g.dart';

/// Occurrence ids whose travel time suggestion was put away with "Not
/// now" (docs/09 M7.5), for this session only, as Today's prompts are: a
/// suggestion is not worth syncing, and it comes back on the next launch.
@Riverpod(keepAlive: true)
class DismissedTravel extends _$DismissedTravel {
  @override
  Set<String> build() => const {};

  void dismiss(String occurrenceId) => state = {...state, occurrenceId};
}
