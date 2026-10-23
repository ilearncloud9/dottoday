import 'package:dottoday/data/sync/row_merge.dart';
import 'package:flutter_test/flutter_test.dart';

// One pulled row into the local one, field by field (docs/09 M6.2).

const _laptop = '1761033600000-0000-00000000000000bb';
const _laptopLater = '1761033610000-0000-00000000000000bb';
const _phoneEdit = '1761033620000-0000-00000000000000aa';

Map<String, Object?> _row(String title, {Object? link}) => {
  'id': 'o1',
  'user_id': 'u',
  'title': title,
  'calendar_link_id': link,
};

void main() {
  test('no pending edit: the server value is taken', () {
    final m = mergeRemote(
      entity: 'occurrences',
      local: _row('Run'),
      remote: _row('Gym'),
      pending: const {},
      versions: const {'title': _laptop},
    );
    expect(m.row['title'], 'Gym');
    expect(m.settled, isEmpty);
  });

  test('a device-only field keeps the local value', () {
    final m = mergeRemote(
      entity: 'occurrences',
      local: _row('Run', link: 'link-1'),
      remote: _row('Run'),
      pending: const {},
      versions: const {},
    );
    expect(m.row['calendar_link_id'], 'link-1');
  });

  test('an edit on top of the version last pulled just goes up', () {
    final m = mergeRemote(
      entity: 'occurrences',
      local: _row('Swim'),
      remote: _row('Run'),
      pending: const {'title': (seq: 1, value: 'Swim', hlc: _phoneEdit)},
      versions: const {'title': _laptop},
      seen: const {'title': _laptop},
    );
    expect(m.row['title'], 'Swim');
    expect(m.settled, isEmpty);
    expect(m.conflicts, isEmpty);
  });

  test('a server change not seen yet, within a minute: a conflict', () {
    final m = mergeRemote(
      entity: 'occurrences',
      local: _row('Swim'),
      remote: _row('Gym'),
      pending: const {'title': (seq: 1, value: 'Swim', hlc: _phoneEdit)},
      versions: const {'title': _laptopLater},
      seen: const {'title': _laptop},
    );
    expect(m.row['title'], 'Gym');
    expect(m.settled, {'title'});
    expect(m.conflicts.single.mine, 'Swim');
  });
}
