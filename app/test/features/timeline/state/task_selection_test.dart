import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Multi-select (docs/03 §3.2, R-05; E-R2-6, M20.5 part 4): the thread
/// keeps to one day, the hour grid may pick across its days.
void main() {
  final tue = DateTime(2026, 11, 3);
  final wed = DateTime(2026, 11, 4);

  ProviderContainer make() {
    final c = ProviderContainer(
      overrides: [
        layoutPolicyProvider.overrideWithValue(
          const LayoutPolicy(UiLayout.full),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test("the thread's pick on another day starts over there", () {
    final c = make();
    c.read(taskSelectionProvider.notifier)
      ..toggle(tue, 'a')
      ..toggle(wed, 'b');
    final p = c.read(taskSelectionProvider);
    expect(p.days, {'b': wed});
    expect(p.day, wed);
    expect(p.spansDays, isFalse);
  });

  test("the grid's picks span days; the last one out ends it", () {
    final c = make();
    final s = c.read(taskSelectionProvider.notifier)
      ..toggleAcross(tue, 'a')
      ..toggleAcross(wed, 'b')
      ..toggleAcross(wed, 'c');
    var p = c.read(taskSelectionProvider);
    expect(p.ids, {'a', 'b', 'c'});
    expect(p.day, isNull);
    expect(p.spansDays, isTrue);
    expect(p.on(wed), {'b', 'c'});
    s
      ..toggleAcross(tue, 'a')
      ..toggleAcross(wed, 'b')
      ..toggleAcross(wed, 'c');
    p = c.read(taskSelectionProvider);
    expect(p.isEmpty, isTrue);
    expect(p, Picked.none);
  });

  test('clear and only', () {
    final c = make();
    c.read(taskSelectionProvider.notifier)
      ..toggleAcross(tue, 'a')
      ..only(wed, 'b');
    expect(c.read(taskSelectionProvider).days, {'b': wed});
    c.read(taskSelectionProvider.notifier).clear();
    expect(c.read(taskSelectionProvider).isEmpty, isTrue);
  });
}
