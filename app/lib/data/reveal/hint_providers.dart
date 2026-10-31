import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/reveal/hint_scheduler.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'hint_providers.g.dart';

/// The user's hint records by hint (docs/14 §6 `reveal_hints`).
@riverpod
Stream<Map<HintId, RevealHint>> revealHints(Ref ref) {
  final profile = ref.watch(currentProfileProvider.future);
  final repo = ref.watch(revealHintRepositoryProvider);
  return Stream.fromFuture(profile)
      .asyncExpand((p) => repo.watchAll(p.id))
      .map((rows) => {for (final r in rows) r.hintId: r});
}

/// One row per user and hint, on every device: a name-based UUID (v5)
/// of both, so two devices showing the same hint update one row.
String revealHintRowId(String userId, HintId hint) =>
    const Uuid().v5(Namespace.url.value, 'dottoday:hint:$userId:${hint.name}');

/// Records that [hint] showed (first time today): count + 1 (never past
/// [hintMaxShows]), when.
Future<Result<void, AppFailure>> recordHintShown(
  ProviderContainer ref,
  HintId hint,
) => _change(
  ref,
  hint,
  (h, now) => h.copyWith(
    shownCount: (h.shownCount + 1).clamp(0, hintMaxShows),
    lastShownUtc: now,
  ),
);

/// *Not now*: [hint] never shows again (docs/14 §5).
Future<Result<void, AppFailure>> dismissHint(
  ProviderContainer ref,
  HintId hint,
) => _change(ref, hint, (h, now) => h.copyWith(dismissedAtUtc: now));

Future<Result<void, AppFailure>> _change(
  ProviderContainer ref,
  HintId hint,
  RevealHint Function(RevealHint h, DateTime now) change,
) async {
  final profile = await readProfile(ref);
  final now = ref.read(clockProvider).nowUtc();
  final id = revealHintRowId(profile.id, hint);
  final stored = await ref
      .read(revealHintRepositoryProvider)
      .findById(profile.id, id);
  final base =
      stored ??
      RevealHint(
        id: id,
        userId: profile.id,
        hintId: hint,
        createdAt: now,
        updatedAt: now,
      );
  return ref
      .read(writeUseCaseProvider)
      .apply(WriteBatch(userId: profile.id, revealHints: [change(base, now)]));
}
