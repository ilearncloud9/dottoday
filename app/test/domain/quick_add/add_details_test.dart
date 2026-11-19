import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/quick_add/add_details.dart';
import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

// 10:00 Berlin, Wednesday 21 October 2026.
final _now = DateTime.utc(2026, 10, 21, 8);

AddDraft _draft() => AddDraft(
  today: DateTime(2026, 10, 21),
  tzId: 'Europe/Berlin',
  defaultDurationMin: 30,
).withStartMinute(16 * 60 + 30);

/// Create task's form (ED-140, M19.3): its Repeat, Alerts, Energy, Notes
/// and ⋯ choices are written with the task, in the same rows.
void main() {
  setUpAll(tzdata.initializeTimeZones);

  const tenBefore = Alert(kind: AlertKind.before, offsetMin: 10);
  const details = AddDetails(
    alerts: [tenBefore],
    energy: Energy.high,
    notes: '  Bring the slides  ',
    soundId: 'none',
    travelMin: 15,
    pinned: true,
  );

  test('a one-off carries every detail on its occurrence', () {
    final rows = _draft()
        .withDetails(details)
        .toRows(
          userId: 'u',
          nowUtc: _now,
          untitled: 'New',
          alerts: const [Alert(kind: AlertKind.atStart)],
        );
    final o = rows.occurrence!;
    expect(rows.series, isNull);
    expect(o.alerts, [tenBefore], reason: 'the pick, not the default');
    expect(o.energy, Energy.high);
    expect(o.notes, 'Bring the slides');
    expect((o.soundId, o.travelBufferMin, o.pinned), ('none', 15, true));
  });

  test('no alert picked keeps the default alerts; blank notes are none', () {
    const defaults = [Alert(kind: AlertKind.atStart)];
    final rows = _draft()
        .withDetails(const AddDetails(notes: '   '))
        .toRows(userId: 'u', nowUtc: _now, untitled: 'New', alerts: defaults);
    expect(rows.occurrence!.alerts, defaults);
    expect(rows.occurrence!.notes, isNull);
  });

  test('a picked repeat makes a series with the details', () {
    final d = _draft().withDetails(
      details.copyWith(
        repeat: () =>
            (rule: RepeatRule.parse('FREQ=DAILY', end: const EndsAfter(5))),
      ),
    );
    expect(d.rrule, 'FREQ=DAILY');
    final rows = d.toRows(userId: 'u', nowUtc: _now, untitled: 'New');
    final s = rows.series!;
    expect(s.rrule, contains('FREQ=DAILY'));
    expect(s.count, 5);
    expect(
      (s.energy, s.notes, s.pinned),
      (Energy.high, 'Bring the slides', true),
    );
  });

  test('Never overrides a typed "every …"', () {
    final d = _draft().withDetails(
      const AddDetails().copyWith(repeat: () => (rule: null)),
    );
    expect(d.rrule, isNull);
  });
}
