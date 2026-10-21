import 'package:dottoday/core/ids/id_generator.dart';

/// Sequential, readable IDs (`id-1`, `id-2`, …) for tests.
final class FakeIds implements IdGenerator {
  FakeIds([this.prefix = 'id']);

  final String prefix;
  var _next = 0;

  @override
  String newId() => '$prefix-${++_next}';
}
