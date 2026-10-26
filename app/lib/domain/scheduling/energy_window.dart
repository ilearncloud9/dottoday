import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/scheduling/learning_thresholds.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:timezone/timezone.dart' as tz;

/// When the user finishes high-energy work best (11 C4, docs/09 M11.5).
final class EnergyWindow {
  const EnergyWindow({
    required this.startHour,
    required this.hours,
    required this.completions,
    required this.highEnergyTitles,
  });

  /// Local hour the window starts at (0–23).
  final int startHour;

  /// How long the window is ([LearningThresholds.energyWindowHours]).
  final int hours;

  /// Finished high-energy tasks with real times it was read from.
  final int completions;

  /// Normalised titles of those tasks, so Add knows a "deep work" one.
  final Set<String> highEnergyTitles;

  int get endHour => (startHour + hours) % 24;

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

/// The [LearningThresholds.energyWindowHours]-hour stretch of the day in
/// which the most of [history]'s finished high-energy tasks really
/// started, in [zone]; a tie goes to the window starting at the busier
/// hour, then the earliest. Null under
/// [LearningThresholds.energyMinCompletions] (11 C4).
///
/// ```dart
/// bestEnergyWindow(history, berlin)?.startHour; // 9 → "9–11"
/// ```
EnergyWindow? bestEnergyWindow(
  Iterable<Occurrence> history,
  tz.Location zone, {
  LearningThresholds thresholds = LearningThresholds.standard,
}) {
  final runs = highEnergyRuns(history);
  if (runs.length < thresholds.energyMinCompletions) return null;
  final hours = thresholds.energyWindowHours;
  final perHour = List.filled(24, 0);
  for (final o in runs) {
    perHour[tz.TZDateTime.from(o.actualStartUtc!, zone).hour]++;
  }
  var best = 0;
  var bestCount = -1;
  for (var h = 0; h < 24; h++) {
    var count = 0;
    for (var i = 0; i < hours; i++) {
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
    hours: hours,
    completions: runs.length,
    highEnergyTitles: {for (final o in runs) normaliseTitle(o.title)},
  );
}

/// Whether Add suggests the energy window: never before
/// [LearningThresholds.energyMinCompletions], then the user's choice
/// (Settings › Planning), on by default.
bool energySuggestionsOn(
  Settings settings, {
  required int completions,
  LearningThresholds thresholds = LearningThresholds.standard,
}) =>
    completions >= thresholds.energyMinCompletions &&
    (settings.energySuggestions ?? true);
