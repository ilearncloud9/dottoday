import 'package:dottoday/core/logging/error_handlers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

final _boom = Provider<int>((ref) => throw StateError('contains Buy milk'));
final _outer = Provider<int>((ref) => ref.watch(_boom));

Object _caught(ProviderContainer c, ProviderListenable<int> p) {
  try {
    c.read<int>(p);
  } on Object catch (e) {
    return e;
  }
  fail('expected the provider to throw');
}

void main() {
  test('unwraps (nested) ProviderException to the original error', () {
    final container = ProviderContainer.test();
    final error = _caught(container, _outer);
    expect(error, isA<ProviderException>());

    final (e, s) = unwrapProviderException(error, StackTrace.empty);
    expect(e, isA<StateError>());
    expect(s, isNot(StackTrace.empty));
  });

  test('passes other errors through unchanged', () {
    final err = ArgumentError('x');
    final (e, s) = unwrapProviderException(err, StackTrace.empty);
    expect(e, same(err));
    expect(s, StackTrace.empty);
  });
}
