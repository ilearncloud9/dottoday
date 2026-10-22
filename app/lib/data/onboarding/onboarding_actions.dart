import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/onboarding/starter_habits.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// O3 (docs/09 M4.3): [picked] onto tomorrow's thread, within tomorrow's
/// Wake Up and Bedtime, as one write (one Undo). Null when nothing was
/// picked.
Future<Result<UndoToken, AppFailure>?> plantStarters(
  ProviderContainer ref,
  Set<StarterHabit> picked,
  String Function(StarterHabit h) titleOf,
) async {
  if (picked.isEmpty) return null;
  final profile = await readProfile(ref);
  final zone = tz.getLocation(profile.tzId);
  final now = ref.read(clockProvider).nowUtc();
  final local = tz.TZDateTime.from(now, zone);
  final tomorrow = DateTime(local.year, local.month, local.day + 1);
  final shape = DayShape.on(
    zone,
    tomorrow,
    profile.settings.boundaryFor(Weekday.values[tomorrow.weekday - 1]),
  );
  final rows = starterTasks(
    picked: StarterHabit.values.where(picked.contains),
    titleOf: titleOf,
    shape: shape,
    zone: zone,
    userId: profile.id,
    nowUtc: now,
    ids: const UuidV7Generator(),
  );
  return ref
      .read(undoServiceProvider)
      .applyUndoable(WriteBatch(userId: profile.id, occurrences: rows));
}
