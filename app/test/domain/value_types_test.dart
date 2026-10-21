import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:flutter_test/flutter_test.dart';

// Value equality and PII-free toString for small domain value types.
void main() {
  test('QuickAddToken equality', () {
    const a = QuickAddToken(QuickAddTokenKind.time, 1, 4);
    expect(a, const QuickAddToken(QuickAddTokenKind.time, 1, 4));
    expect(
      a.hashCode,
      const QuickAddToken(QuickAddTokenKind.time, 1, 4).hashCode,
    );
    expect(a, isNot(const QuickAddToken(QuickAddTokenKind.date, 1, 4)));
    expect(a.toString(), 'QuickAddToken(time, 1, 4)');
  });

  test('QuickAddDraft.toString never includes the title', () {
    const d = QuickAddDraft(title: 'secret dentist', minuteOfDay: 60);
    expect(d.toString(), isNot(contains('secret')));
    expect(d.inbox, isFalse);
  });

  test('Slot equality', () {
    final a = Slot(DateTime.utc(2026), DateTime.utc(2026, 1, 1, 1));
    expect(a, Slot(DateTime.utc(2026), DateTime.utc(2026, 1, 1, 1)));
    expect(
      a.hashCode,
      Slot(DateTime.utc(2026), DateTime.utc(2026, 1, 1, 1)).hashCode,
    );
    expect(a.toString(), contains('Slot('));
  });

  test('PlannedNotification equality and toString', () {
    PlannedNotification n({bool silent = false}) => PlannedNotification(
          id: 1,
          occurrenceId: 'o',
          alertIndex: 0,
          fireAtUtc: DateTime.utc(2026),
          kind: AlertKind.atStart,
          silent: silent,
        );
    expect(n(), n());
    expect(n().hashCode, n().hashCode);
    expect(n(), isNot(n(silent: true)));
    expect(n(silent: true).toString(), contains('silent'));
    expect(n(silent: true).timeSensitive, isFalse);
  });
}
