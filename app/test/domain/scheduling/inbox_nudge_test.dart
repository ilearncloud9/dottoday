import 'package:dottoday/domain/scheduling/inbox_nudge.dart';
import 'package:flutter_test/flutter_test.dart';

// The once-a-day "Plan your inbox" card (docs/02 F3.3, docs/09 M8.4c).

final _today = DateTime(2026, 10, 21);
final _wake = DateTime.utc(2026, 10, 21, 5);
final _bed = DateTime.utc(2026, 10, 21, 20);

bool _shows({
  bool enabled = true,
  int open = 3,
  DateTime? putAwayOn,
  DateTime? now,
}) => showsInboxNudge(
  enabled: enabled,
  openCount: open,
  today: _today,
  putAwayOn: putAwayOn,
  nowUtc: now ?? DateTime.utc(2026, 10, 21, 7),
  wakeUtc: _wake,
  bedUtc: _bed,
);

void main() {
  test('shows from Wake Up with tasks waiting', () {
    expect(_shows(), isTrue);
    expect(_shows(now: _wake), isTrue);
  });

  test('off by setting or with an empty Inbox', () {
    expect(_shows(enabled: false), isFalse);
    expect(_shows(open: 0), isFalse);
  });

  test('not before Wake Up nor from Bedtime', () {
    expect(_shows(now: _wake.subtract(const Duration(minutes: 1))), isFalse);
    expect(_shows(now: _bed), isFalse);
  });

  test('once a day: put away today stays away, yesterday does not', () {
    expect(_shows(putAwayOn: DateTime(2026, 10, 21)), isFalse);
    expect(_shows(putAwayOn: DateTime(2026, 10, 20)), isTrue);
  });
}
