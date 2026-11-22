import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// Each platform's own controls (owner, native pass, 2026-11-20): what the
/// redesign made native stays native.
void main() {
  final sources = {
    ...readLibSources('lib/features'),
    ...readLibSources('lib/shared'),
  };

  bool code(String line) {
    final s = line.trimLeft();
    return !s.startsWith('//');
  }

  List<String> offences(RegExp pattern, {Set<String> allowed = const {}}) => [
    for (final MapEntry(key: path, value: source) in sources.entries)
      if (!allowed.contains(path))
        for (final line in source.split('\n'))
          if (code(line) && pattern.hasMatch(line)) '$path: ${line.trim()}',
  ];

  test("every text field shows the platform's edit menu", () {
    final fields = <String>[];
    for (final MapEntry(key: path, value: source) in sources.entries) {
      final starts = RegExp(r'(?<![\w.])(TextField|TextFormField)\(');
      for (final m in starts.allMatches(source)) {
        final line = source.substring(source.lastIndexOf('\n', m.start) + 1);
        if (!code(line)) continue;
        final head = source.substring(
          m.end,
          (m.end + 120).clamp(0, source.length),
        );
        if (!head.contains('contextMenuBuilder:')) fields.add(path);
      }
    }
    expect(fields, isEmpty);
  });

  test('menus open through the shared menu (the system one on Apple)', () {
    expect(
      offences(
        RegExp(r'PopupMenuButton<|showMenu<|DropdownButton<'),
        // The shared menu: the system's own, then Flutter's (M20.3).
        allowed: {
          'shared/menus/context_menu.dart',
          'shared/menus/flutter_menu.dart',
        },
      ),
      isEmpty,
    );
  });

  test("segmented choices use the platform's segmented control", () {
    expect(
      offences(
        RegExp(r'SegmentedButton<'),
        allowed: {
          'shared/controls/dot_segmented.dart',
          // Android's own tabs in Add; Apple gets iOS's control there.
          'features/task_editor/add/create/add_mode_tabs.dart',
        },
      ),
      isEmpty,
    );
  });

  test('alerts go through the system alert', () {
    expect(
      offences(
        RegExp(r'(?<![\w.])AlertDialog\(|CupertinoAlertDialog\('),
        allowed: {'shared/sheets/dot_alert.dart'},
      ),
      isEmpty,
    );
  });

  test('pushed screens use the platform top bar', () {
    expect(
      offences(
        RegExp(r'(?<![\w.])AppBar\('),
        allowed: {'shared/navigation/dot_page_bar.dart'},
      ),
      isEmpty,
    );
  });
}
