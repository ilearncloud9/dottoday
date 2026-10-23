import 'package:dottoday/core/router/deep_link_guard.dart';
import 'package:dottoday/domain/recurrence/instance_ids.dart';
import 'package:flutter_test/flutter_test.dart';

// Repeat instances get the same id on every device (docs/09 M6.2).
void main() {
  const series = '01929a3e-7c4b-7d2a-9f10-3b5c6d7e8f90';
  final at = DateTime.utc(2026, 10, 24, 7);

  test('the same series and start give the same id', () {
    expect(instanceId(series, at), instanceId(series, at));
  });

  test('another start or another series gives another id', () {
    final id = instanceId(series, at);
    expect(instanceId(series, at.add(const Duration(days: 1))), isNot(id));
    expect(instanceId('01929a3e-7c4b-7d2a-9f10-3b5c6d7e8f91', at), isNot(id));
  });

  test('a v7 UUID in form, its time the instance start; links open it', () {
    final id = instanceId(series, at);
    expect(
      id,
      matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab]')),
    );
    final ms = int.parse(id.replaceAll('-', '').substring(0, 12), radix: 16);
    expect(ms, at.millisecondsSinceEpoch);
    expect(allowListedLocation(Uri.parse('dottoday://task/$id')), '/task/$id');
  });

  test('template subtasks: stable per instance and index', () {
    final o = instanceId(series, at);
    expect(templateSubtaskId(o, 0, at), templateSubtaskId(o, 0, at));
    expect(templateSubtaskId(o, 1, at), isNot(templateSubtaskId(o, 0, at)));
  });
}
