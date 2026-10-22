import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_order.dart';
import 'package:flutter_test/flutter_test.dart';

import 'scheduling_support.dart';

// The Inbox's own order (docs/09 M3f.9c).

void main() {
  final rows = [
    block('a', '09:00', 30).copyWith(startUtc: null),
    block('b', '09:00', 30).copyWith(startUtc: null),
    block('c', '09:00', 30).copyWith(startUtc: null),
  ];

  Map<String, double> orders(List<Occurrence> changed) => {
    for (final o in changed) o.id: o.sortOrder,
  };

  test('moves one and renumbers 1…n', () {
    expect(orders(reorderInbox(rows, 2, 0)), {'c': 1, 'a': 2, 'b': 3});
  });

  test('only what changed is written', () {
    final numbered = [
      for (final (i, o) in rows.indexed) o.copyWith(sortOrder: i + 1.0),
    ];
    expect(orders(reorderInbox(numbered, 0, 1)), {'b': 1, 'a': 2});
  });

  test('no move, nothing to write', () {
    expect(reorderInbox(rows, 1, 1), isEmpty);
    expect(reorderInbox(rows, 5, 0), isEmpty);
  });
}
