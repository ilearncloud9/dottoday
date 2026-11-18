import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// Apple Pencil and Android styluses write into text fields (ED-258):
/// Scribble on iPad, system stylus handwriting on Android. Flutter's text
/// fields accept both by default, so no field may turn them off.
void main() {
  test('no text field turns stylus handwriting off', () {
    final sources = readLibSources('lib');
    expect(sources, isNotEmpty);
    final offences = [
      for (final MapEntry(key: path, value: source) in sources.entries)
        if (RegExp(
          r'(scribbleEnabled|stylusHandwritingEnabled)\s*:\s*false',
        ).hasMatch(source))
          path,
    ];
    expect(offences, isEmpty);
  });
}
