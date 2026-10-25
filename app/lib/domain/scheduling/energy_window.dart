import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:timezone/timezone.dart' as tz;

/// Finished high-energy tasks needed before energy suggestions start
/// (11 C4: "default Off until 20 completions exist").
const energyMinCompletions = 20;

/// Hours in the suggested window.
const energyWindowHours = 2;

/// When the user finishes high-energy work best (11 C4, docs/09 M11.5).
final class EnergyWindow {
  const EnergyWindow({
    required this.startHour,
    required this.completions,
    required this.highEnergyTitles,
  });

  /// Local hour the [energyWindowHours]-hour window starts at (0–23).
  final int startHour;

  /// Finished high-energy tasks with real times it was read from.
  final int completions;

  /// Normalised titles of those tasks, so Add knows a "deep work" one.
  final Set<String> highEnergyTitles;

  int get endHour => (startHour + energyWindowHours) % 24;

  /// Whether a task called [title] is one of the user's high-energy ones.
  bool knows(String title) => highEnergyTitles.contains(normaliseTitle(title));
}

/// Finished high-energy tasks in [history] with a real start and end (B1).
List<Occurrence> highEnergyRuns(Iterable<Occurrence> history) => [
  for (final o in history)
    if (o.deletedAt == null &&
        o.status == OccurrenceStatus.done &&
        o.energy == Energy.high &&
        o.actualStartUtc != null &&
        o.actualEndUtc != null &&
        o.actualEndUtc!.isAfter(o.actualStartUtc!))
      o,
];

/// The [energyWindowHours]-hour stretch of the day in which the most of
/// [history]'s finished high-energy tasks really started, in [zone]; a tie
/// goes to the window starting at the busier hour, then the earliest. Null under [energyMinCompletions] (11 C4).
///
/// ```dart
/// bestEnergyWindow(history, berlin)?.startHour; // 9 → "9–11"
/// ```
EnergyWindow? bestEnergyWindow(Iterable<Occurrence> history, tz.Location zone) {
  final runs = highEnergyRuns(history);
  if (runs.length < energyMinCompletions) return null;
  final perHour = List.filled(24, 0);
  for (final o in runs) {
    perHour[tz.TZDateTime.from(o.actualStartUtc!, zone).hour]++;
  }
  var best = 0;
  var bestCount = -1;
  for (var h = 0; h < 24; h++) {
    var count = 0;
    for (var i = 0; i < energyWindowHours; i++) {
      count += perHour[(h + i) % 24];
    }
    // A tie goes to the window starting at the busier hour (7–9 over 6–8
    // when everything is at 7), then the earliest.
    if (count > bestCount ||
        (count == bestCount && perHour[h] > perHour[best])) {
      best = h;
      bestCount = count;
    }
  }
  return EnergyWindow(
    startHour: best,
    completions: runs.length,
    highEnergyTitles: {for (final o in runs) normaliseTitle(o.title)},
  );
}

/// Whether Add suggests the energy window: never before
/// [energyMinCompletions], then the user's choice (Settings › Planning),
/// on by default.
bool energySuggestionsOn(Settings settings, {required int completions}) =>
    completions >= energyMinCompletions && (settings.energySuggestions ?? true);
