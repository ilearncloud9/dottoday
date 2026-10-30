import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

// docs/14 §6, ADR-0016: minimal mode is a View-layer flag. Only the
// entity, the schema-9 migration and features/layout name it; Views ask
// LayoutPolicy, and no repository, DAO, sync or notification code
// branches on it.
const _allowed = {
  'domain/entities/enums.dart',
  'domain/entities/settings.dart',
  'data/db/app_database.dart',
};

void main() {
  test('only features/layout reads the layout flag', () {
    final flag = RegExp(r'\b(uiLayout|UiLayout)\b');
    final offenders = [
      for (final MapEntry(:key, :value) in readLibSources('lib').entries)
        if (flag.hasMatch(value) &&
            !_allowed.contains(key) &&
            !key.startsWith('features/layout/'))
          key,
    ];
    expect(offenders, isEmpty, reason: 'ask LayoutPolicy instead');
  });
}
