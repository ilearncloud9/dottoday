import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'one_thing.freezed.dart';
part 'one_thing.g.dart';

/// Today's one thing (docs/15 §8, M17.7b): the dot that matters most, for
/// one civil day. One field holds it, so there is at most one a day and a
/// new pick quietly replaces the old (owner, 2026-11-01). It is synced in
/// `profiles.settings`, so every device and widget shows the same ring.
@freezed
abstract class OneThing with _$OneThing {
  const factory OneThing({
    /// `yyyy-MM-dd` in the profile's zone: the day it was picked for.
    required String date,

    /// The picked occurrence: one of the day's dots or an Inbox item.
    required String occurrenceId,
  }) = _OneThing;

  factory OneThing.fromJson(Map<String, Object?> json) =>
      _$OneThingFromJson(json);
}

/// The occurrence id of [pick] on [dateKey], or null: a pick from another
/// day has cleared, so the ring ends with the day by itself (15 §8). No
/// reminder follows it; an unfinished one thing is never brought up
/// again (no-shame rule).
///
/// ```dart
/// oneThingOn(const OneThing(date: '2026-11-02', occurrenceId: 'a'),
///     '2026-11-02'); // 'a'
/// ```
String? oneThingOn(OneThing? pick, String dateKey) =>
    pick != null && pick.date == dateKey ? pick.occurrenceId : null;

/// What the pick screen offers (15 §8): the day's dots still to do in
/// start order, then the Inbox (owner, 2026-11-01: "today's tasks or the
/// Inbox"). The mission caps the dots at [oneThingMaxDots] each, as the
/// spec's "first 3–5"; picked from Today, every dot of the day is offered.
/// Done and skipped dots are left out: there is nothing left to choose.
///
/// ```dart
/// oneThingChoices(dots: day, inbox: inbox, nowUtc: now, mission: true);
/// ```
({List<Occurrence> dots, List<Occurrence> inbox}) oneThingChoices({
  required Iterable<Occurrence> dots,
  required Iterable<Occurrence> inbox,
  required DateTime nowUtc,
  bool mission = false,
}) {
  final open = [
    for (final o in dots)
      if (o.startUtc != null &&
          o.status == OccurrenceStatus.planned &&
          o.endUtc!.isAfter(nowUtc))
        o,
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  final waiting = [
    for (final o in inbox)
      if (o.isInbox && o.status == OccurrenceStatus.planned) o,
  ];
  if (!mission) return (dots: open, inbox: waiting);
  return (
    dots: open.take(oneThingMaxDots).toList(),
    inbox: waiting.take(oneThingMaxDots).toList(),
  );
}

/// How many dots Pick today's one thing offers at most in the mission
/// (15 §8: 3–5), and the same for the Inbox below them.
const oneThingMaxDots = 5;

/// Pick today's one thing needs a real choice (15 §8): with one dot the
/// app would be deciding for the user. Inbox items don't count, so the
/// mission's skip rule reads the day as planned.
const oneThingMinDots = 2;
