import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:timezone/timezone.dart' as tz;

/// A task the user has planned before, as Add step 1 offers it ("Go
/// shopping · usually 5:00 – 6:00 PM · 1 h", docs/10 §6 "Suggestions come
/// from the user's own history").
final class HabitSuggestion {
  const HabitSuggestion({
    required this.title,
    required this.durationMin,
    required this.colorKey,
    required this.iconKey,
    required this.uses,
    required this.lastUsedUtc,
    this.minuteOfDay,
  });

  /// The title as last written.
  final String title;

  /// Local start of the last use, minutes after midnight; null if it was
  /// never on the timeline.
  final int? minuteOfDay;
  final int durationMin;
  final String colorKey;
  final String iconKey;

  /// How many times the title was planned in the history window.
  final int uses;
  final DateTime lastUsedUtc;

  @override
  String toString() => 'HabitSuggestion($uses× $minuteOfDay+$durationMin)';
}

/// Turns past tasks into [HabitSuggestion]s (docs/09 M3c.1, R-06).
///
/// Same title (case and spacing ignored) → one suggestion carrying the
/// time, length, colour and icon of its most recent use. Calendar imports
/// and deleted rows are not habits; inbox items count but carry no time.
///
/// ```dart
/// final habits = const SuggestionService().fromHistory(rows, berlin);
/// const SuggestionService().match('shop', habits).first.title; // Go shopping
/// ```
final class SuggestionService {
  const SuggestionService();

  /// Ranked most-used first, then most recent, at most [limit].
  List<HabitSuggestion> fromHistory(
    Iterable<Occurrence> history,
    tz.Location location, {
    int limit = 20,
  }) {
    final byTitle = <String, List<Occurrence>>{};
    for (final o in history) {
      if (o.deletedAt != null || o.source != OccurrenceSource.user) continue;
      final key = normaliseTitle(o.title);
      if (key.isEmpty) continue;
      (byTitle[key] ??= []).add(o);
    }
    final habits = [for (final rows in byTitle.values) _habit(rows, location)]
      ..sort(_rank);
    return habits.take(limit).toList();
  }

  /// [habits] whose title matches [query]: the whole title or a word
  /// starting with it first, then any other containing it, each group in
  /// rank order. An empty query returns the first [limit] habits.
  List<HabitSuggestion> match(
    String query,
    List<HabitSuggestion> habits, {
    int limit = 4,
  }) {
    final q = normaliseTitle(query);
    if (q.isEmpty) return habits.take(limit).toList();
    final starts = <HabitSuggestion>[];
    final contains = <HabitSuggestion>[];
    for (final h in habits) {
      final title = normaliseTitle(h.title);
      if (title.startsWith(q) || title.contains(' $q')) {
        starts.add(h);
      } else if (title.contains(q)) {
        contains.add(h);
      }
    }
    return [...starts, ...contains].take(limit).toList();
  }

  /// What Add step 1 lists under [title] (`A-ios-add-what`): while typing,
  /// the [match]es; once the title names a habit exactly, the top habits
  /// in rank order with that one among them (so the tick shows in
  /// context, not alone).
  List<HabitSuggestion> shownFor(
    String title,
    List<HabitSuggestion> habits, {
    int limit = 4,
  }) {
    final hit = exact(title, habits);
    if (hit == null) return match(title, habits, limit: limit);
    final top = habits.take(limit).toList();
    if (!top.contains(hit)) top[top.length - 1] = hit;
    return top;
  }

  /// The habit whose title is exactly [title] (case and spacing ignored).
  HabitSuggestion? exact(String title, List<HabitSuggestion> habits) {
    final key = normaliseTitle(title);
    if (key.isEmpty) return null;
    for (final h in habits) {
      if (normaliseTitle(h.title) == key) return h;
    }
    return null;
  }

  HabitSuggestion _habit(List<Occurrence> rows, tz.Location location) {
    DateTime used(Occurrence o) => o.startUtc ?? o.updatedAt;
    rows.sort((a, b) => used(b).compareTo(used(a)));
    final last = rows.first;
    final timed = rows.where((o) => o.startUtc != null).firstOrNull;
    final local = timed == null
        ? null
        : tz.TZDateTime.from(timed.startUtc!, location);
    return HabitSuggestion(
      title: last.title.trim(),
      minuteOfDay: local == null ? null : local.hour * 60 + local.minute,
      durationMin: last.durationMin,
      colorKey: last.colorKey,
      iconKey: last.iconKey,
      uses: rows.length,
      lastUsedUtc: used(last),
    );
  }

  static int _rank(HabitSuggestion a, HabitSuggestion b) {
    final byUses = b.uses.compareTo(a.uses);
    if (byUses != 0) return byUses;
    final byRecent = b.lastUsedUtc.compareTo(a.lastUsedUtc);
    return byRecent != 0 ? byRecent : a.title.compareTo(b.title);
  }
}

/// [title] lower-cased with runs of whitespace collapsed, for matching.
String normaliseTitle(String title) =>
    title.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
