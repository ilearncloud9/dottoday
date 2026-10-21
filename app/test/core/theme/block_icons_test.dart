import 'package:dottoday/core/theme/block_icons.dart';
import 'package:dottoday/domain/entities/icon_keys.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every key is a valid persisted icon_key', () {
    for (final i in BlockIcon.values) {
      expect(iconKeyPattern.hasMatch(i.key), isTrue, reason: i.key);
    }
  });

  test('the column default maps to the fallback', () {
    expect(BlockIcon.fromKey(defaultIconKey), BlockIcon.fallback);
  });

  test('unknown keys fall back instead of failing', () {
    expect(BlockIcon.fromKey('from_a_newer_app'), BlockIcon.fallback);
    expect(BlockIcon.fromKey(null), BlockIcon.fallback);
    expect(BlockIcon.fromKey('gym'), BlockIcon.gym);
  });
}
