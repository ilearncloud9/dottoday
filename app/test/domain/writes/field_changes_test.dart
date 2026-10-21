import 'package:dottoday/domain/writes/field_changes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('insert logs every field except identity and updated_at', () {
    expect(
      changedFields(null, {
        'id': 'x',
        'user_id': 'u',
        'title': 't',
        'notes': null,
        'updated_at': 1,
      }),
      ['title', 'notes'],
    );
  });

  test('update logs only changed fields, deep-comparing JSON', () {
    final before = {
      'title': 't',
      'alerts': [
        {'kind': 'before', 'offsetMin': 10},
      ],
      'updated_at': 1,
    };
    expect(
      changedFields(before, {
        ...before,
        'updated_at': 2,
        'alerts': [
          {'kind': 'before', 'offsetMin': 10},
        ],
      }),
      isEmpty,
    );
    expect(changedFields(before, {...before, 'title': 'u'}), ['title']);
    expect(changedFields(before, {...before, 'alerts': <Object?>[]}), [
      'alerts',
    ]);
  });

  test('a field missing before counts as changed', () {
    expect(changedFields({'title': 't'}, {'title': 't', 'energy': 2}), [
      'energy',
    ]);
  });
}
