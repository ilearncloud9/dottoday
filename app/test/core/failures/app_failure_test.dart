import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

List<AppFailure> _all() => [
  const StorageFailure(),
  for (final k in NetworkFailureKind.values) NetworkFailure(k),
  const AuthFailure(),
  for (final f in ValidationField.values)
    for (final r in ValidationRule.values) ValidationFailure(f, r),
  for (final e in EntityKind.values) ...[
    NotFoundFailure(e),
    ConflictFailure(e),
  ],
  for (final p in AppPermission.values) PermissionFailure(p),
  const UnexpectedFailure(),
];

void main() {
  test('codes are stable, unique and valid log events', () {
    final codes = _all().map((f) => f.code).toList();
    expect(codes.toSet(), hasLength(codes.length));
    expect(
      const NetworkFailure(NetworkFailureKind.offline).code,
      'network.offline',
    );
    expect(
      const ValidationFailure(
        ValidationField.title,
        ValidationRule.tooLong,
      ).code,
      'validation.title.tooLong',
    );
    for (final c in codes.where((c) => c.contains('.'))) {
      expect(isValidLogEvent(c.toLowerCase()), isTrue, reason: c);
    }
  });

  test(
    'every failure has a non-empty en message following copy rules',
    () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      for (final f in _all()) {
        final msg = failureMessage(l10n, f);
        expect(msg, isNotEmpty, reason: f.code);
        expect(msg, isNot(contains('!')), reason: '03 §5: ${f.code}');
      }
    },
  );
}
