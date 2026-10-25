import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/calendar/calendar_importer.dart';
import 'package:dottoday/data/calendar/calendar_moves.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/calendar/edge_functions.dart';
import 'package:dottoday/data/calendar/function_cloud_calendars.dart';
import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/calendar/calendar_import.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/cloud_calendar.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cloud_calendar_providers.g.dart';

/// Where the browser comes back to after connecting (calendar-oauth checks
/// it against its allow-list): the Calendars page, already an allowed
/// deep link (06 §7) in the apps; on the web the page itself, same tab.
String cloudConnectReturn() => kIsWeb
    ? '${Uri.base.origin}${Uri.base.path}#/settings/calendars'
    : 'dottoday://settings/calendars';

/// Google and Microsoft calendars through the backend (docs/09 M7.4);
/// unavailable without a Supabase client (tests, local-only builds).
@Riverpod(keepAlive: true)
CloudCalendars cloudCalendars(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return FunctionCloudCalendars(
    client == null ? null : SupabaseEdgeFunctions(client),
    signedIn: () => client?.auth.currentSession != null,
    logger: ref.watch(loggerProvider),
  );
}

/// The signed-in account's connections; none when signed out. Throws the
/// failure when they can't be listed (the page's error state).
@riverpod
Future<List<CloudAccount>> cloudAccounts(Ref ref) async {
  // Every watch before the first await (see `deviceCalendars`).
  final cloud = ref.watch(cloudCalendarsProvider);
  final account = await ref.watch(accountProvider.future);
  if (account is! SignedIn) return const [];
  final result = await cloud.accounts();
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}

/// Each connected calendar with its switch and inherited colour, as for
/// device calendars (the switches are this device's).
@riverpod
Stream<List<CalendarChoice>> cloudCalendarChoiceList(Ref ref) async* {
  // Every watch before the first await (see `deviceCalendars`).
  final accountsFuture = ref.watch(cloudAccountsProvider.future);
  final profileFuture = ref.watch(currentProfileProvider.future)..ignore();
  final sources = ref.watch(calendarSourceRepositoryProvider);
  final accounts = await accountsFuture;
  final calendars = [for (final a in accounts) ...a.calendars];
  if (calendars.isEmpty) {
    yield const [];
    return;
  }
  final profile = await profileFuture;
  yield* sources
      .watchCloud(profile.id)
      .map((rows) => calendarChoices(calendars, rows, calendarPalette));
}

/// Connected-account events → occurrences, like device calendars' but
/// owning only the Google/Microsoft links (docs/09 M7.4).
@Riverpod(keepAlive: true)
CalendarImport cloudCalendarImporter(Ref ref) => CalendarImporter(
  db: ref.watch(appDatabaseProvider),
  gateway: ref.watch(cloudCalendarsProvider),
  sources: ref.watch(calendarSourceRepositoryProvider),
  effects: ref.watch(afterWriteEffectsProvider),
  clock: ref.watch(clockProvider),
  ids: const UuidV7Generator(),
  logger: ref.watch(loggerProvider),
  providers: cloudProviderWires,
  heldLinks: (userId) async => {
    for (final p in await ref.read(calendarWriteBackProvider).pending(userId))
      p.link.id,
  },
  onMoved: (moved) => ref.read(calendarMovesProvider.notifier).add(moved),
);

@Riverpod(keepAlive: true)
CloudCalendarActions cloudCalendarActions(Ref ref) => CloudCalendarActions(ref);

/// Connecting and disconnecting Google/Microsoft accounts (Settings ›
/// Calendars).
final class CloudCalendarActions {
  CloudCalendarActions(this._ref);

  final Ref _ref;

  /// Opens [provider]'s sign-in page; the browser comes back to the
  /// Calendars page, which re-reads the connections. On the web it opens
  /// in the same tab: the app runs in one tab at a time (M2.9).
  Future<Result<void, AppFailure>> connect(CalendarProvider provider) async {
    final url = await _ref
        .read(cloudCalendarsProvider)
        .connectUrl(provider, cloudConnectReturn());
    switch (url) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        final opened = await _ref
            .read(linkLauncherProvider)
            .open(value, sameWindow: kIsWeb);
        return opened ? const Ok(null) : const Err(UnexpectedFailure());
    }
  }

  /// Removes [account]; its events leave the timeline at the next import
  /// (run now), those with the person's subtasks or notes into Trash.
  Future<Result<void, AppFailure>> disconnect(CloudAccount account) async {
    final result = await _ref
        .read(cloudCalendarsProvider)
        .disconnect(account.id);
    if (result is Ok) {
      _ref.invalidate(cloudAccountsProvider);
      unawaited(_ref.read(calendarActionsProvider).importEvents());
    }
    return result;
  }
}
