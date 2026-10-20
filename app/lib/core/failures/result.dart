import 'package:dottoday/core/failures/app_failure.dart';

/// Outcome of an operation that can fail recoverably: [Ok] or [Err].
///
/// Return this instead of throwing for expected failures; reserve throws for
/// bugs (CLAUDE.md §4). Consume with an exhaustive `switch` or [when].
///
/// ```dart
/// Result<int, ValidationFailure> parse(String s) => ...;
/// final label = parse(s).when(ok: (n) => '$n', err: (f) => f.code);
/// ```
sealed class Result<T, F extends AppFailure> {
  const Result();

  /// Calls [ok] or [err] depending on the outcome.
  R when<R>({
    required R Function(T value) ok,
    required R Function(F failure) err,
  }) {
    return switch (this) {
      Ok<T, F>(:final value) => ok(value),
      Err<T, F>(:final failure) => err(failure),
    };
  }

  /// Transforms the success value; failures pass through unchanged.
  Result<U, F> map<U>(U Function(T value) transform) {
    return switch (this) {
      Ok<T, F>(:final value) => Ok(transform(value)),
      Err<T, F>(:final failure) => Err(failure),
    };
  }
}

final class Ok<T, F extends AppFailure> extends Result<T, F> {
  const Ok(this.value);

  final T value;

  @override
  bool operator ==(Object other) => other is Ok<T, F> && other.value == value;

  @override
  int get hashCode => Object.hash(Ok, value);

  @override
  String toString() => 'Ok($value)';
}

final class Err<T, F extends AppFailure> extends Result<T, F> {
  const Err(this.failure);

  final F failure;

  @override
  bool operator ==(Object other) =>
      other is Err<T, F> && other.failure == failure;

  @override
  int get hashCode => Object.hash(Err, failure);

  // Code only: failures carry no content, but keep output uniform with logs.
  @override
  String toString() => 'Err(${failure.code})';
}
