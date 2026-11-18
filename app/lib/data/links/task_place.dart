import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Where a task link opens (rule T, ED-097): the task over its own date,
/// read when the link opens, so a moved task follows. No date: the Inbox;
/// today: Today; any other date, past or upcoming: that day. A task that
/// is gone, in the Trash or not the signed-in user's opens Today and says
/// nothing about the id (D2): the repository looks it up under the
/// current user only.
///
/// ```dart
/// await taskLinkPlace(container, id); // '/day/2026-11-20?task=<id>'
/// ```
Future<String> taskLinkPlace(ProviderContainer container, String id) async {
  final profile = await _profile(container);
  final task = await container
      .read(occurrenceRepositoryProvider)
      .findById(profile.id, id);
  if (task == null || task.deletedAt != null) return AppRoutes.today;
  final start = task.startUtc;
  if (start == null) return AppRoutes.withTask(AppRoutes.inbox, id);
  // The profile's zone, as Today reads its own date.
  final zone = tz.getLocation(profile.tzId);
  DateTime dateOf(DateTime utc) {
    final local = tz.TZDateTime.from(utc, zone);
    return DateTime(local.year, local.month, local.day);
  }

  final day = dateOf(start);
  final today = dateOf(container.read(clockProvider).nowUtc());
  final place = day == today ? AppRoutes.today : AppRoutes.day(day);
  return AppRoutes.withTask(place, id);
}

/// Whether task [id] may open from a `?task=` address: the signed-in
/// user's and not in the Trash (D2). Anything else opens nothing.
Future<bool> taskLinkVisible(ProviderContainer container, String id) async {
  final profile = await _profile(container);
  final task = await container
      .read(occurrenceRepositoryProvider)
      .findById(profile.id, id);
  return task != null && task.deletedAt == null;
}

/// The signed-in profile, listened to while it is read: Riverpod pauses a
/// provider nobody listens to, and a link can arrive before any screen
/// watches the profile.
Future<Profile> _profile(ProviderContainer container) async {
  final sub = container.listen(currentProfileProvider.future, (_, _) {});
  try {
    return await sub.read();
  } finally {
    sub.close();
  }
}
