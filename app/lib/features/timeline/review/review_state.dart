import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_state.g.dart';

/// Which half of the one review is showing (ED-099): the Day review, or
/// Week in review pushed over it.
enum ReviewPage { day, week }

/// The review a pane or column is showing: the [day] it reviews (the week
/// is the one holding it) and its [page].
@immutable
final class ReviewOpen {
  const ReviewOpen(this.day, this.page);

  final DateTime day;
  final ReviewPage page;

  @override
  bool operator ==(Object other) =>
      other is ReviewOpen && other.day == day && other.page == page;

  @override
  int get hashCode => Object.hash(day, page);
}

/// The review shown beside the day (ED-099, ED-297): the pane on an iPad
/// or Android tablet's Workspace, or Minimal's Day column on the Mac and
/// the web. Null = none. Cleared at every change of owner (CR-160 I5).
@Riverpod(keepAlive: true)
class ReviewBeside extends _$ReviewBeside {
  @override
  ReviewOpen? build() {
    ref.watch(ownerEpochProvider);
    return null;
  }

  void show(ReviewOpen open) => state = open;

  void close() => state = null;
}

/// The day the Review place shows (ED-099): set by the entry that opened
/// it, then stepped with ‹ ›. Null = the review's own day.
@Riverpod(keepAlive: true)
class ReviewPlaceDay extends _$ReviewPlaceDay {
  @override
  DateTime? build() {
    ref.watch(ownerEpochProvider);
    return null;
  }

  // ignore: use_setters_to_change_properties, a notifier's command.
  void show(DateTime day) => state = day;
}
