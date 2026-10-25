import 'package:dottoday/data/notifications/notification_content.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/notifications/notification_gateway.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/repositories/subtask_repository.dart';
import 'package:dottoday/domain/scheduling/start_nudge.dart';

/// [NotificationGateway] over the OS scheduler (docs/04 §6, docs/09 M5.1).
///
/// The OS pending set is a cache of the plan: each payload round-trips its
/// [PlannedNotification], so the planner's diff sees exactly what is
/// scheduled. A pending notification that can't be read, or whose text no
/// longer matches its task (a rename), reads as stale and is replaced; so
/// every alert is posted once, with current text (R-10).
final class OsNotificationGateway implements NotificationGateway {
  OsNotificationGateway({
    required Future<NotificationPlatform> Function() platform,
    required OccurrenceRepository occurrences,
    required Future<Profile> Function() profile,
    SubtaskRepository? subtasks,
  }) : _platform = platform,
       _occurrences = occurrences,
       _profile = profile,
       _subtasks = subtasks;

  final Future<NotificationPlatform> Function() _platform;
  final OccurrenceRepository _occurrences;
  final Future<Profile> Function() _profile;

  /// For Smallest step's text, the task's first open step (M10.6).
  final SubtaskRepository? _subtasks;

  @override
  Future<Map<int, PlannedNotification>> pending() async {
    final profile = await _profile();
    final result = <int, PlannedNotification>{};
    for (final (id, payload) in await (await _platform()).pending()) {
      final planned = decodeNotificationPayload(id, payload);
      final current =
          planned != null && await _textIsCurrent(planned, payload, profile);
      result[id] = current ? planned : _stale(id);
    }
    return result;
  }

  @override
  Future<void> apply(NotificationDiff diff) async {
    final platform = await _platform();
    for (final id in diff.cancel) {
      await platform.cancel(id);
    }
    if (diff.schedule.isEmpty) return;
    final profile = await _profile();
    for (final planned in diff.schedule) {
      final os = composeNotification(
        planned,
        task: await _task(planned, profile),
        profile: profile,
        step: await _step(planned, profile),
      );
      // A task deleted since planning: the next resync drops it anyway.
      if (os != null) await platform.schedule(os);
    }
  }

  Future<bool> _textIsCurrent(
    PlannedNotification planned,
    String? payload,
    Profile profile,
  ) async {
    final os = composeNotification(
      planned,
      task: await _task(planned, profile),
      profile: profile,
      step: await _step(planned, profile),
    );
    return os != null &&
        notificationPayloadContentHash(os.payload) ==
            notificationPayloadContentHash(payload);
  }

  /// The task [p] is about, unless it is gone (Trash counts as gone).
  Future<Occurrence?> _task(PlannedNotification p, Profile profile) async {
    if (p.occurrenceId.isEmpty) return null;
    final task = await _occurrences.findById(profile.id, p.occurrenceId);
    return task?.deletedAt == null ? task : null;
  }

  /// The step a Smallest step reminder offers; null for any other.
  Future<Subtask?> _step(PlannedNotification p, Profile profile) async {
    final subtasks = _subtasks;
    if (subtasks == null || p.purpose != NotificationPurpose.smallestStep) {
      return null;
    }
    final steps = await subtasks.watchForOccurrences(profile.id, {
      p.occurrenceId,
    }).first;
    return smallestStep(steps);
  }

  /// Never equal to a planned notification, so the diff replaces it.
  static PlannedNotification _stale(int id) => PlannedNotification(
    id: id,
    occurrenceId: '',
    alertIndex: -1,
    fireAtUtc: DateTime.utc(1970),
    kind: AlertKind.atStart,
  );
}
