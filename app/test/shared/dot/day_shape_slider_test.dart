import 'package:dottoday/shared/dot/day_shape_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

// A Wind Down after midnight (Q8, docs/05) set from its time field: the
// slider shows it and never pulls it back before midnight on its own.

String _time(int m) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(m ~/ 60 % 24)}:${two(m % 60)}';
}

Widget _slider(int bed, void Function(int, int) changed) => testApp(
  Scaffold(
    body: DayShapeSlider(
      wakeMinute: 7 * 60,
      bedMinute: bed,
      timeText: _time,
      awakeText: (m) => '$m min',
      wakeLabel: 'Wake Up',
      bedLabel: 'Wind Down',
      onChanged: changed,
    ),
  ),
);

void main() {
  testWidgets('a Wind Down at 00:30 stays, one step back is 00:15', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final writes = <(int, int)>[];
    await tester.pumpWidget(_slider(1470, (w, b) => writes.add((w, b))));
    expect(find.text('00:30'), findsOneWidget);
    expect(find.text('1050 min'), findsOneWidget);
    final bed = find.semantics.byPredicate((n) => n.label == 'Wind Down');
    tester.semantics.decrease(bed);
    await tester.pumpAndSettle();
    expect(writes.last, (420, 1455));
    tester.semantics.increase(bed);
    tester.semantics.increase(bed);
    await tester.pumpAndSettle();
    expect(writes.last.$2, 1470, reason: 'no later than where it was set');
    handle.dispose();
  });

  testWidgets('an evening Wind Down still stops a step before midnight', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final writes = <(int, int)>[];
    await tester.pumpWidget(_slider(1425, (w, b) => writes.add((w, b))));
    final bed = find.semantics.byPredicate((n) => n.label == 'Wind Down');
    tester.semantics.increase(bed);
    await tester.pumpAndSettle();
    expect(writes.last.$2, 1425);
    handle.dispose();
  });
}
