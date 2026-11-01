import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// App name shown in the OS task switcher, window title and browser tab.
  ///
  /// In en, this message translates to:
  /// **'Dottoday'**
  String get appTitle;

  /// Local database read/write failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save on this device. Try again.'**
  String get failureStorage;

  /// No network connection.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Changes are saved on this device and will sync later.'**
  String get failureNetworkOffline;

  /// Network request timed out.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond. Try again.'**
  String get failureNetworkTimeout;

  /// Backend returned an error.
  ///
  /// In en, this message translates to:
  /// **'The server had a problem. Your data is safe on this device.'**
  String get failureNetworkServer;

  /// Auth session missing or expired.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Sign in again to keep syncing.'**
  String get failureAuth;

  /// A required input was empty.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be empty.'**
  String get failureValidationRequired;

  /// Input exceeded the maximum length.
  ///
  /// In en, this message translates to:
  /// **'That\'s too long. Try something shorter.'**
  String get failureValidationTooLong;

  /// Numeric/time input out of range.
  ///
  /// In en, this message translates to:
  /// **'That value is outside the allowed range.'**
  String get failureValidationOutOfRange;

  /// Input had an invalid format.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look right. Check the format.'**
  String get failureValidationInvalidFormat;

  /// Imported file exceeded the size limit.
  ///
  /// In en, this message translates to:
  /// **'That file is too large.'**
  String get failureValidationTooLarge;

  /// Entity missing or not visible to the user.
  ///
  /// In en, this message translates to:
  /// **'This item no longer exists.'**
  String get failureNotFound;

  /// Same-field sync conflict needing a decision.
  ///
  /// In en, this message translates to:
  /// **'This item changed on another device. Choose which version to keep.'**
  String get failureConflict;

  /// Notification permission denied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for Dottoday. You can turn them on in system settings.'**
  String get failurePermissionNotifications;

  /// Calendar permission denied.
  ///
  /// In en, this message translates to:
  /// **'Dottoday can\'t see your calendars. You can allow access in system settings.'**
  String get failurePermissionCalendar;

  /// Undo was tapped after its 30-second window.
  ///
  /// In en, this message translates to:
  /// **'That can\'t be undone any more. Deleted tasks stay in Trash for 30 days.'**
  String get failureUndoExpired;

  /// Fallback for unclassified failures.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get failureUnexpected;

  /// Bottom bar / rail tab: today's timeline.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// Tab: unscheduled tasks.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get navInbox;

  /// Tab: week view.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get navWeek;

  /// Tab: search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Tab: settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Tooltip and screen-reader label for the Quick Add button.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get quickAddTooltip;

  /// Button/label that closes a sheet or popover.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get sheetClose;

  /// Label of the typed time field.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeInputLabel;

  /// Hint inside the empty time field.
  ///
  /// In en, this message translates to:
  /// **'e.g. 9:30 or 2pm'**
  String get timeInputHint;

  /// Error under the time field when the text isn't a time; the previous time is kept.
  ///
  /// In en, this message translates to:
  /// **'Type a time like 9:30 or 2pm'**
  String get timeInputInvalid;

  /// Button next to the time field opening a wheel picker.
  ///
  /// In en, this message translates to:
  /// **'Pick time with a wheel'**
  String get timeInputWheel;

  /// Confirms the wheel time picker.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get timeInputDone;

  /// Label of the duration chips row.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// A duration under one hour.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// A whole number of hours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// Hours and minutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// Chip that lets the user type their own duration.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get durationCustom;

  /// Hint inside the custom duration field.
  ///
  /// In en, this message translates to:
  /// **'e.g. 40m or 1h30'**
  String get durationCustomHint;

  /// Error when the typed custom duration is invalid.
  ///
  /// In en, this message translates to:
  /// **'Use 5 min to 24 h, like 40m or 1h30'**
  String get durationCustomInvalid;

  /// Block colour name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Coral'**
  String get colorCoral;

  /// Block colour name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get colorAmber;

  /// Block colour name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get colorMint;

  /// Block colour name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// Block colour name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get colorSky;

  /// Block colour name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get colorIndigo;

  /// Block colour name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get colorViolet;

  /// Block colour name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorRose;

  /// Block colour name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get colorSlate;

  /// Snackbar action reverting the last change (30 s).
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// Sync pill: no account, data stays on this device.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get syncLocalOnly;

  /// Sync pill: everything is synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get syncSynced;

  /// Sync pill: sync in progress.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncSyncing;

  /// Sync pill: no connection; changes are kept locally.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get syncOffline;

  /// Sync pill: last sync failed; tap for details.
  ///
  /// In en, this message translates to:
  /// **'Sync problem'**
  String get syncError;

  /// Screen-reader label of the now-line.
  ///
  /// In en, this message translates to:
  /// **'Now, {time}'**
  String timelineNow(String time);

  /// Toggle on the collapsed zone before the user's day start.
  ///
  /// In en, this message translates to:
  /// **'Before {time}'**
  String timelineBeforeHours(String time);

  /// Toggle on the collapsed zone after the user's day end.
  ///
  /// In en, this message translates to:
  /// **'After {time}'**
  String timelineAfterHours(String time);

  /// Marker for overlapping blocks that don't fit in 3 columns.
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String timelineMoreBlocks(int count);

  /// Screen-reader label of the +n overlap marker.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more block} other{{count} more blocks}}'**
  String timelineMoreBlocksLabel(int count);

  /// Heading of the all-day strip above the timeline.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get timelineAllDay;

  /// Block start and end time.
  ///
  /// In en, this message translates to:
  /// **'{start}–{end}'**
  String blockTimeRange(String start, String end);

  /// Basic screen-reader label of a block (extended in M3.3).
  ///
  /// In en, this message translates to:
  /// **'{title}, {start} to {end}'**
  String blockSemantics(String title, String start, String end);

  /// Overflow menu in the timeline header.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get timelineMenu;

  /// Debug-build-only menu item that fills today with sample blocks.
  ///
  /// In en, this message translates to:
  /// **'Load demo day (debug)'**
  String get debugLoadDemoDay;

  /// Confirmation after the debug demo day was written.
  ///
  /// In en, this message translates to:
  /// **'Demo day loaded'**
  String get debugDemoDayLoaded;

  /// Separator between parts of a screen-reader label.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get semanticsSeparator;

  /// Screen-reader state of a completed block.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get blockDone;

  /// Screen-reader state of a past block that isn't done (never shaming, 03 §5).
  ///
  /// In en, this message translates to:
  /// **'not done yet'**
  String get blockNotDoneYet;

  /// Subtask progress in a block's screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} subtasks done'**
  String blockSubtasks(int done, int total);

  /// Visible subtask progress next to the ring.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String blockSubtasksShort(int done, int total);

  /// Badge meaning in screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'recurring'**
  String get blockRecurring;

  /// Badge meaning in screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'pinned'**
  String get blockPinned;

  /// Badge meaning: imported calendar event.
  ///
  /// In en, this message translates to:
  /// **'from your calendar'**
  String get blockFromCalendar;

  /// Alert count in a block's screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 alert} other{{count} alerts}}'**
  String blockAlerts(int count);

  /// Block began before this day.
  ///
  /// In en, this message translates to:
  /// **'continues from the previous day'**
  String get blockStartsBefore;

  /// Block runs past midnight.
  ///
  /// In en, this message translates to:
  /// **'continues into the next day'**
  String get blockEndsAfter;

  /// Button on a block's icon circle.
  ///
  /// In en, this message translates to:
  /// **'Mark {title} done'**
  String blockMarkDone(String title);

  /// Button on a done block's icon circle.
  ///
  /// In en, this message translates to:
  /// **'Mark {title} not done'**
  String blockMarkNotDone(String title);

  /// Undo snackbar after completing a block.
  ///
  /// In en, this message translates to:
  /// **'Marked done'**
  String get undoMarkedDone;

  /// Undo snackbar after un-completing a block.
  ///
  /// In en, this message translates to:
  /// **'Marked not done'**
  String get undoMarkedNotDone;

  /// Screen-reader label of an upcoming task's dot (docs/10 §5.4).
  ///
  /// In en, this message translates to:
  /// **'{title}, upcoming'**
  String dotUpcoming(String title);

  /// Screen-reader label of the live task's dot.
  ///
  /// In en, this message translates to:
  /// **'{title}, live'**
  String dotLive(String title);

  /// Screen-reader label of the live task's dot with the time left.
  ///
  /// In en, this message translates to:
  /// **'{title}, live, {minutes, plural, =1{1 minute left} other{{minutes} minutes left}}'**
  String dotLiveLeft(String title, int minutes);

  /// Screen-reader label of a done task's dot.
  ///
  /// In en, this message translates to:
  /// **'{title}, done'**
  String dotDone(String title);

  /// Screen-reader label of a skipped task's dot.
  ///
  /// In en, this message translates to:
  /// **'{title}, skipped'**
  String dotSkipped(String title);

  /// Screen-reader label of a missed task's dot.
  ///
  /// In en, this message translates to:
  /// **'{title}, not done'**
  String dotMissed(String title);

  /// Screen-reader hint: what tapping a task's dot does.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get dotMarkDoneHint;

  /// Screen-reader hint: tapping a done task's dot undoes it.
  ///
  /// In en, this message translates to:
  /// **'Mark not done'**
  String get dotMarkNotDoneHint;

  /// Screen-reader hint: tapping a task's dot opens the task (ADR-0015).
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get dotOpenHint;

  /// Beside the knot between two overlapping thread rows: 'Run and Sleep share 15 min'; {share} is threadOverlapShareTime, drawn in the later task's colour.
  ///
  /// In en, this message translates to:
  /// **'{first} and {second} {share}'**
  String threadOverlapShare(String first, String second, String share);

  /// The coloured part of threadOverlapShare: 'share 15 min'.
  ///
  /// In en, this message translates to:
  /// **'share {duration}'**
  String threadOverlapShareTime(String duration);

  /// Screen-reader label of a task row: title and time range.
  ///
  /// In en, this message translates to:
  /// **'{title}, {range}'**
  String rowLabel(String title, String range);

  /// Appended to a row label when the task was missed.
  ///
  /// In en, this message translates to:
  /// **'{label}, not done'**
  String rowMissed(String label);

  /// Appended to a row label when the task is pinned.
  ///
  /// In en, this message translates to:
  /// **'{label}, pinned'**
  String rowPinned(String label);

  /// Appended to a row label when the task repeats.
  ///
  /// In en, this message translates to:
  /// **'{label}, repeats'**
  String rowRepeats(String label);

  /// Shown after a missed task's time range (A-mac-month).
  ///
  /// In en, this message translates to:
  /// **'· not done'**
  String get rowMissedMeta;

  /// Sun cap at the top of the day's thread (Main).
  ///
  /// In en, this message translates to:
  /// **'Wake Up · {time}'**
  String threadWake(String time);

  /// Moon cap at the end of the day's thread (Main).
  ///
  /// In en, this message translates to:
  /// **'Wind Down · {time}'**
  String threadBed(String time);

  /// Screen-reader hint on the Wake Up / Wind Down caps of the thread: a tap edits the time.
  ///
  /// In en, this message translates to:
  /// **'Change time'**
  String get capEditHint;

  /// Cap time sheet: the new Wake Up / Wind Down applies to every day.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get capEveryDay;

  /// Cap time sheet: the new time applies only to this weekday, e.g. 'Every Saturday'.
  ///
  /// In en, this message translates to:
  /// **'Every {weekday}'**
  String capEveryWeekday(String weekday);

  /// A free gap on the thread, e.g. '1 h free' (Main).
  ///
  /// In en, this message translates to:
  /// **'{duration} free'**
  String threadFree(String duration);

  /// A future free gap the user can tap or drop onto (Main).
  ///
  /// In en, this message translates to:
  /// **'{duration} free · add here'**
  String threadAddHere(String duration);

  /// Screen-reader label of a future free gap.
  ///
  /// In en, this message translates to:
  /// **'{duration} free from {time}. Add a task here'**
  String threadAddHereLabel(String duration, String time);

  /// Subtask progress on the live row, e.g. '1 of 3'.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String liveSubtasks(int done, int total);

  /// Time left on the live task (Main).
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 min left} other{{minutes} min left}}'**
  String liveMinutesLeft(int minutes);

  /// Live row button: mark the current task done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get liveDone;

  /// Live row button: extend the current task by 15 minutes.
  ///
  /// In en, this message translates to:
  /// **'+15 min'**
  String get liveExtend;

  /// Live row button: move every later task by the overrun (R-04).
  ///
  /// In en, this message translates to:
  /// **'Shift the rest'**
  String get liveShiftRest;

  /// Compact duration as in the renders: '5 h 45'.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes}'**
  String durationHoursMinutesShort(int hours, int minutes);

  /// Live row meta: time range and length, e.g. '9:00 – 11:00 · 2 h'.
  ///
  /// In en, this message translates to:
  /// **'{range} · {duration}'**
  String liveMeta(String range, String duration);

  /// Appends subtask progress ('1 of 3') to a row's screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'{label}, {progress}'**
  String rowWithSubtasks(String label, String progress);

  /// Screen-reader label of the day dot: share of Wake Up → Wind Down elapsed.
  ///
  /// In en, this message translates to:
  /// **'Day {percent} % through'**
  String dayDotLabel(int percent);

  /// Screen-reader label of the handle under the week strip.
  ///
  /// In en, this message translates to:
  /// **'Show month'**
  String get weekStripShowMonth;

  /// Screen-reader label of the handle when the month is open.
  ///
  /// In en, this message translates to:
  /// **'Hide month'**
  String get weekStripHideMonth;

  /// Appended to the day card title on today (Main: 'Wednesday · Today').
  ///
  /// In en, this message translates to:
  /// **' · Today'**
  String get dayCardTodaySuffix;

  /// Day card numbers, e.g. '2 of 7 · 5 h 45 planned' (Main).
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} · {planned} planned'**
  String dayCardSummary(int done, int total, String planned);

  /// Day card numbers for an empty day (A-ios-future-month).
  ///
  /// In en, this message translates to:
  /// **'Nothing planned · {free} free'**
  String dayCardNothing(String free);

  /// Screen-reader label of the day pager's page dots.
  ///
  /// In en, this message translates to:
  /// **'Day {position} of {count}'**
  String dayPagerPosition(int position, int count);

  /// Expanded month cell: tasks not shown (A-mac-month).
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String monthMore(int count);

  /// Footer of a past month cell (A-mac-month).
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String monthDoneOf(int done, int total);

  /// Footer of a future month cell with few tasks (A-mac-month).
  ///
  /// In en, this message translates to:
  /// **'Light day'**
  String get monthLightDay;

  /// A missed task in a month cell.
  ///
  /// In en, this message translates to:
  /// **'{title} · not done'**
  String monthMissedItem(String title);

  /// The live task in today's month cell.
  ///
  /// In en, this message translates to:
  /// **'{title} · now'**
  String monthNowItem(String title);

  /// A task's time range on the thread, e.g. '7:30 – 8:00' (Main).
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String threadTimeRange(String start, String end);

  /// Debug-build-only menu item that opens the new components on today's data.
  ///
  /// In en, this message translates to:
  /// **'Concept A preview (debug)'**
  String get debugConceptPreview;

  /// Today's page title when the profile has no name (Main).
  ///
  /// In en, this message translates to:
  /// **'{part, select, morning{Good morning} afternoon{Good afternoon} other{Good evening}}'**
  String todayGreeting(String part);

  /// Today's page title with the user's name (Main: 'Good morning, Kody').
  ///
  /// In en, this message translates to:
  /// **'{part, select, morning{Good morning, {name}} afternoon{Good afternoon, {name}} other{Good evening, {name}}}'**
  String todayGreetingName(String part, String name);

  /// Empty Today (docs/10 §5.4).
  ///
  /// In en, this message translates to:
  /// **'Nothing planned · pull the strip to plan or tap +'**
  String get todayEmpty;

  /// Screen-reader label of the all-day chips row.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get todayAllDay;

  /// Screen-reader label of a week-strip day with tasks.
  ///
  /// In en, this message translates to:
  /// **'{day}, {done} of {total} done'**
  String stripDayLabel(String day, int done, int total);

  /// Footer under this month's grid (A-ios-today-month).
  ///
  /// In en, this message translates to:
  /// **'{month} · {count} of {days} days planned'**
  String monthFooterPlanned(String month, int count, int days);

  /// Footer of another month's grid (A-ios-future-month).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day planned} other{{count} days planned}}'**
  String monthDaysPlanned(int count);

  /// Legend next to a filled dot: a one-off task is planned that day.
  ///
  /// In en, this message translates to:
  /// **'planned'**
  String get monthLegendPlanned;

  /// Legend next to an outline dot: only repeating tasks that day.
  ///
  /// In en, this message translates to:
  /// **'repeats'**
  String get monthLegendRepeats;

  /// Month navigation row, e.g. 'Nov · Dec · Jan'.
  ///
  /// In en, this message translates to:
  /// **'{previous} · {current} · {next}'**
  String monthNav(String previous, String current, String next);

  /// Screen-reader label of the ‹ month button.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get monthPrevious;

  /// Screen-reader label of the › month button.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get monthNext;

  /// Pill that returns Today to the current date (A-ios-future-month).
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayPill;

  /// Screen-reader label of a month day with tasks.
  ///
  /// In en, this message translates to:
  /// **'{day}, {done} of {total} done'**
  String monthCellLabel(String day, int done, int total);

  /// Empty future day: start Quick Add on this date (A-ios-future-month).
  ///
  /// In en, this message translates to:
  /// **'Add to this day'**
  String get emptyAddToDay;

  /// Empty day: open the inbox to schedule from it.
  ///
  /// In en, this message translates to:
  /// **'Pull from inbox · {count}'**
  String emptyPullInbox(int count);

  /// Empty day: copy another day's tasks here (Duplicate day).
  ///
  /// In en, this message translates to:
  /// **'Copy a day…'**
  String get emptyCopyDay;

  /// Title of the sheet that picks the day to copy.
  ///
  /// In en, this message translates to:
  /// **'Copy which day?'**
  String get copyDayTitle;

  /// Snackbar after copying a day, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Copied 1 task} other{Copied {count} tasks}}'**
  String copyDayDone(int count);

  /// Snackbar when the picked day has no one-off tasks.
  ///
  /// In en, this message translates to:
  /// **'That day has nothing to copy'**
  String get copyDayNothing;

  /// Snackbar after marking a task done, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{title} done'**
  String snackDone(String title);

  /// Snackbar after un-marking a done task, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{title} not done'**
  String snackNotDone(String title);

  /// Snackbar after +15 min on the live task, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{title} now ends at {time}'**
  String snackExtended(String title, String time);

  /// Snackbar after Shift the rest, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Moved 1 task} other{Moved {count} tasks}}'**
  String snackShifted(int count);

  /// Snackbar when a pinned task stopped Shift the rest (R-17).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing moved: {pin} is pinned} =1{Moved 1 task · stopped at {pin} (pinned)} other{Moved {count} tasks · stopped at {pin} (pinned)}}'**
  String snackShiftedPartial(int count, String pin);

  /// Task sheet meta line, e.g. 'Today · 9:00 – 11:00 · 2 h' (A-ios-task-sheet).
  ///
  /// In en, this message translates to:
  /// **'{day} · {range} · {duration}'**
  String sheetMetaDay(String day, String range, String duration);

  /// Day name in the task sheet meta for today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get sheetToday;

  /// Day name in the task sheet meta for tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get sheetTomorrow;

  /// Task sheet meta for an unscheduled task.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get sheetInbox;

  /// Task sheet action: mark done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get sheetDone;

  /// Task sheet action on a done task: mark not done.
  ///
  /// In en, this message translates to:
  /// **'Not done'**
  String get sheetUndone;

  /// Task sheet action: 15 more minutes.
  ///
  /// In en, this message translates to:
  /// **'+15 min'**
  String get sheetExtend;

  /// Task sheet action: shift the later tasks by the overrun (R-04).
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get sheetShift;

  /// Task sheet action: pick the task up to move it.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get sheetMove;

  /// Task sheet action: open the editor.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get sheetEdit;

  /// Task sheet subtasks heading (A-ios-task-sheet).
  ///
  /// In en, this message translates to:
  /// **'Subtasks · {done} of {total}'**
  String sheetSubtasks(int done, int total);

  /// Task sheet subtasks heading with none yet.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get sheetSubtasksNone;

  /// Task sheet: add a subtask.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get sheetAddSubtask;

  /// Placeholder of the new-subtask field.
  ///
  /// In en, this message translates to:
  /// **'New subtask'**
  String get sheetNewSubtask;

  /// Task sheet details row: alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get sheetAlerts;

  /// Task sheet details row: repeat rule.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get sheetRepeat;

  /// Task sheet details row: colour and icon.
  ///
  /// In en, this message translates to:
  /// **'Colour and icon'**
  String get sheetLook;

  /// Repeat value when the task does not repeat.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get sheetNever;

  /// Alerts value when there are no alerts.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get sheetNoAlerts;

  /// Deep link or sheet for a missing, deleted or someone else's task.
  ///
  /// In en, this message translates to:
  /// **'This task isn\'t here any more'**
  String get sheetNotFound;

  /// Alert summary: at the start.
  ///
  /// In en, this message translates to:
  /// **'at start'**
  String get alertAtStart;

  /// Alert summary: at the end.
  ///
  /// In en, this message translates to:
  /// **'at end'**
  String get alertAtEnd;

  /// Alert summary: minutes before the start.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min before'**
  String alertBefore(int minutes);

  /// Alert summary: overdue reminder after the end.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min after end'**
  String alertOverdue(int minutes);

  /// Joins alert summaries: '10 min before · at start'.
  ///
  /// In en, this message translates to:
  /// **'{first} · {rest}'**
  String alertJoin(String first, String rest);

  /// Repeat summary.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// Repeat summary (A-ios-task-sheet).
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get repeatWeekdays;

  /// Repeat summary with the weekday names.
  ///
  /// In en, this message translates to:
  /// **'Weekly on {days}'**
  String repeatWeekly(String days);

  /// Repeat summary.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// Repeat summary.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get repeatYearly;

  /// Repeat summary for any other rule.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get repeatCustom;

  /// Joins list items, e.g. weekday names 'Mon, Wed'.
  ///
  /// In en, this message translates to:
  /// **'{first}, {rest}'**
  String listJoin(String first, String rest);

  /// Appended to the task sheet meta for the live task: ' · 38 min left'.
  ///
  /// In en, this message translates to:
  /// **' · {left}'**
  String sheetLeftSuffix(String left);

  /// Caption of the colour and icon block (shown uppercase).
  ///
  /// In en, this message translates to:
  /// **'Colour and icon'**
  String get colourIconCaption;

  /// Opens the full colour and icon picker (the task icon library, by category, with search).
  ///
  /// In en, this message translates to:
  /// **'All icons'**
  String get colourIconMore;

  /// Caption at the top of the task editor (A-mac-editor 'EDIT TASK').
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editorCaption;

  /// Placeholder of the editor's title field.
  ///
  /// In en, this message translates to:
  /// **'What is it?'**
  String get editorTitleHint;

  /// Editor field: the day.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get editorWhen;

  /// Editor field: the start time.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get editorStart;

  /// Editor: the end time next to the start, e.g. '→ 11:00'.
  ///
  /// In en, this message translates to:
  /// **'→ {time}'**
  String editorEndsAt(String time);

  /// Editor field: length.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get editorDuration;

  /// Editor field: notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get editorNotes;

  /// Placeholder of the notes field.
  ///
  /// In en, this message translates to:
  /// **'Add notes'**
  String get editorNotesHint;

  /// Editor: save and close (changes also save as you type).
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editorSave;

  /// Editor: unschedule the task.
  ///
  /// In en, this message translates to:
  /// **'Move to inbox'**
  String get editorMoveToInbox;

  /// Editor: delete (with a confirmation).
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get editorDelete;

  /// Confirmation title before deleting a task.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}”?'**
  String editorDeleteConfirm(String title);

  /// Confirmation body before deleting a task (R-11).
  ///
  /// In en, this message translates to:
  /// **'It goes to Trash for 30 days. You can undo right after.'**
  String get editorDeleteBody;

  /// Cancel button in the delete confirmation.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get editorCancel;

  /// Snackbar after deleting a task, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{title} deleted'**
  String snackDeleted(String title);

  /// Snackbar after moving a task to the inbox, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{title} moved to inbox'**
  String snackMovedToInbox(String title);

  /// Title of the day picker sheet in the editor.
  ///
  /// In en, this message translates to:
  /// **'Pick a day'**
  String get editorPickDay;

  /// Floating label while dragging a task over a free gap.
  ///
  /// In en, this message translates to:
  /// **'→ {time}'**
  String dragDropAt(String time);

  /// Snackbar after dropping a task on a free gap, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{title} moved to {time}'**
  String snackMoved(String title, String time);

  /// Snackbar after dropping a task on a week-strip day, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{title} moved to {day}'**
  String snackMovedDay(String title, String day);

  /// Toggle chip shown while dragging a task: when on, the tasks after it move along (R-04). Desktop: hold Alt to invert.
  ///
  /// In en, this message translates to:
  /// **'Shift later tasks'**
  String get shiftChipLabel;

  /// Second toggle chip beside 'Shift later tasks' while dragging, shown when the day has calendar events a shift could move: on, they move with the later tasks (docs/09 M7.6). Starts from Settings › Calendars › Move calendar events too.
  ///
  /// In en, this message translates to:
  /// **'Calendar events too'**
  String get shiftChipCalendar;

  /// Snackbar after a drop with Shift later tasks on, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{{title} moved to {time}} =1{{title} moved to {time} · 1 later task moved too} other{{title} moved to {time} · {count} later tasks moved too}}'**
  String snackMovedShifted(String title, String time, int count);

  /// Snackbar when a pinned task stopped the later tasks from following a drop (R-17).
  ///
  /// In en, this message translates to:
  /// **'{title} moved to {time} · stopped at {pin} (pinned)'**
  String snackMovedShiftedPartial(String title, String time, String pin);

  /// Screen-reader action on a task row that starts multi-select (R-12).
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectAction;

  /// Title of the multi-select bar; also announced when it changes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String selectionCount(int count);

  /// Closes multi-select.
  ///
  /// In en, this message translates to:
  /// **'Done selecting'**
  String get selectionClose;

  /// Multi-select: move the selected tasks to another day.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get selectionMove;

  /// Title of the day picker for moving selected tasks.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get selectionMoveTitle;

  /// Multi-select: copy the selected tasks.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get selectionDuplicate;

  /// Multi-select: change the colour of the selected tasks.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get selectionColour;

  /// Multi-select: move the selected tasks to Trash.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get selectionDelete;

  /// Confirmation before deleting selected tasks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 task?} other{Delete {count} tasks?}}'**
  String selectionDeleteConfirm(int count);

  /// Snackbar after moving selected tasks, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task moved to {day}} other{{count} tasks moved to {day}}}'**
  String snackManyMoved(int count, String day);

  /// Snackbar after duplicating selected tasks, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task duplicated} other{{count} tasks duplicated}}'**
  String snackManyDuplicated(int count);

  /// Snackbar after recolouring selected tasks, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task recoloured} other{{count} tasks recoloured}}'**
  String snackManyRecoloured(int count);

  /// Snackbar after deleting selected tasks, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task moved to Trash} other{{count} tasks moved to Trash}}'**
  String snackManyDeleted(int count);

  /// Inbox row: put the task on the timeline (round + button, swipe toward the start, screen-reader action).
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get inboxSchedule;

  /// Inbox row: move the task to Trash (swipe toward the end, screen-reader action).
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get inboxTrash;

  /// Screen-reader label of an inbox row.
  ///
  /// In en, this message translates to:
  /// **'{title}, {length}'**
  String inboxRowLabel(String title, String length);

  /// Inbox header line, e.g. '5 unscheduled · 5 h 15 of work'.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unscheduled} other{{count} unscheduled}} · {work} of work'**
  String inboxSummary(int count, String work);

  /// Screen-reader label of the dotted ring with the count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Inbox empty} =1{1 task in the Inbox} other{{count} tasks in the Inbox}}'**
  String inboxRingLabel(int count);

  /// Quick-add field hint in the Inbox: an example of what it understands (R-06).
  ///
  /// In en, this message translates to:
  /// **'Call Mum tomorrow 3pm 20m'**
  String get inboxAddHint;

  /// Screen-reader label of the Inbox quick-add field.
  ///
  /// In en, this message translates to:
  /// **'Add a task'**
  String get inboxAddLabel;

  /// Inbox filter chip.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get inboxFilterAll;

  /// Inbox filter chip: tasks shorter than 30 minutes.
  ///
  /// In en, this message translates to:
  /// **'Under 30 min'**
  String get inboxFilterUnder30;

  /// Inbox filter chip: tasks that fit a free slot left today.
  ///
  /// In en, this message translates to:
  /// **'Fits today'**
  String get inboxFilterFits;

  /// NextFreeSlot card in the Inbox.
  ///
  /// In en, this message translates to:
  /// **'Next free slot today: {range} · fits {title}'**
  String inboxNextSlot(String range, String title);

  /// Button on the NextFreeSlot card: schedule the task in that slot.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get inboxPlace;

  /// Header of the completed group in the Inbox.
  ///
  /// In en, this message translates to:
  /// **'Completed · {count}'**
  String inboxCompleted(int count);

  /// Empty Inbox (docs/10 §5.4).
  ///
  /// In en, this message translates to:
  /// **'Inbox is clear'**
  String get inboxEmpty;

  /// Inbox filter shows no tasks.
  ///
  /// In en, this message translates to:
  /// **'Nothing here fits this filter'**
  String get inboxNoMatch;

  /// Title of a Quick Add task typed with no words, only a time or length.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get inboxUntitled;

  /// Title of the schedule sheet for an inbox task.
  ///
  /// In en, this message translates to:
  /// **'Schedule {title}'**
  String inboxScheduleTitle(String title);

  /// Schedule suggestion: a free slot today.
  ///
  /// In en, this message translates to:
  /// **'Today, {range}'**
  String inboxScheduleToday(String range);

  /// Schedule suggestion: the first free slot tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, {range}'**
  String inboxScheduleTomorrow(String range);

  /// Schedule sheet when nothing fits.
  ///
  /// In en, this message translates to:
  /// **'No free slot today or tomorrow. Make room on Today, or drag it in from the week.'**
  String get inboxScheduleNone;

  /// Snackbar after scheduling an inbox task, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{title} scheduled for {when}'**
  String snackScheduled(String title, String when);

  /// Snackbar after Quick Add in the Inbox.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{title} added to the Inbox} other{{count} tasks added}}'**
  String snackAddedInbox(int count, String title);

  /// Snackbar after Quick Add made a timed task.
  ///
  /// In en, this message translates to:
  /// **'{title} added for {when}'**
  String snackAddedTimed(String title, String when);

  /// Snackbar after trashing an inbox task, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{title} moved to Trash'**
  String snackTrashed(String title);

  /// Screen-reader label of the Add title field (A-android-add-what).
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get addTitleLabel;

  /// Helper under the Add title field (A-ios-add-what); the example should parse in this language.
  ///
  /// In en, this message translates to:
  /// **'Type a time too: ‘Go shopping 5pm 1h’'**
  String get addTypeTimeHint;

  /// Tooltip of the × on a recognised Quick Add token chip.
  ///
  /// In en, this message translates to:
  /// **'Remove “{token}”'**
  String addRemoveToken(String token);

  /// Add step 1 section caption (shown uppercase).
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get addSuggestions;

  /// Muted note beside the Suggestions caption.
  ///
  /// In en, this message translates to:
  /// **'from your habits'**
  String get addFromHabits;

  /// Suggestion row meta: the habit's usual time range and length.
  ///
  /// In en, this message translates to:
  /// **'usually {range} · {length}'**
  String addHabitUsual(String range, String length);

  /// Suggestion row meta for a habit never put on a time.
  ///
  /// In en, this message translates to:
  /// **'no set time · {length}'**
  String addHabitNoTime(String length);

  /// Screen-reader label of a suggestion row.
  ///
  /// In en, this message translates to:
  /// **'{title}, {meta}'**
  String addHabitLabel(String title, String meta);

  /// Add step 1 primary button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get addContinue;

  /// Add step 1 secondary button: save without a time.
  ///
  /// In en, this message translates to:
  /// **'Add to Inbox instead'**
  String get addToInbox;

  /// Screen-reader label of the Add step dots.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String addStepOf(int step, int total);

  /// Add step 2: back to step 1.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get addBack;

  /// When a task added for another day lands, in the Added snackbar: day then time.
  ///
  /// In en, this message translates to:
  /// **'{day}, {time}'**
  String addWhenOnDay(String day, String time);

  /// Screen-reader label of the ThreadPicker slider; its value reads the time range.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get pickerLabel;

  /// Add step 2 subtitle under the title: 'Today · 5:00 – 6:00 PM · 1 h'.
  ///
  /// In en, this message translates to:
  /// **'{day} · {range} · {length}'**
  String addWhenSummary(String day, String range, String length);

  /// Add step 2 section caption (shown uppercase).
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get addTimeCaption;

  /// Add step 2 section caption (shown uppercase).
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get addDurationCaption;

  /// Under the ThreadPicker when the slot is free.
  ///
  /// In en, this message translates to:
  /// **'Free until {time} · no overlap'**
  String addFreeUntil(String time);

  /// Under the ThreadPicker when the slot collides with tasks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Overlaps {title}} other{Overlaps {title} and {others} more}} · you can still add it'**
  String addOverlaps(int count, String title, int others);

  /// Lands-on row: where the task goes. {day} is shown bold.
  ///
  /// In en, this message translates to:
  /// **'Lands on {day} at {range}'**
  String addLandsOn(String day, String range);

  /// Lands-on row suffix when nothing overlaps.
  ///
  /// In en, this message translates to:
  /// **'the slot is free'**
  String get addSlotFree;

  /// Lands-on row suffix when the slot is taken.
  ///
  /// In en, this message translates to:
  /// **'overlaps {title}'**
  String addSlotBusy(String title);

  /// Add step 2 primary button.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAdd;

  /// Add step 2: add this task and start the next one.
  ///
  /// In en, this message translates to:
  /// **'Add another'**
  String get addAnother;

  /// Duration chip under an hour: just the minutes ('15').
  ///
  /// In en, this message translates to:
  /// **'{minutes}'**
  String durationChipMinutes(int minutes);

  /// Duration chip of an hour or more: '1h', '1.5h' (hours formatted for the locale).
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationChipHours(String hours);

  /// Inbox schedule sheet: choose any time on the thread.
  ///
  /// In en, this message translates to:
  /// **'Pick a time…'**
  String get inboxPickTime;

  /// Title of the Duration sheet (A-ios-add-duration).
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationSheetTitle;

  /// Typed alternative to the duration wheel.
  ///
  /// In en, this message translates to:
  /// **'Or type a length'**
  String get durationTypeLabel;

  /// Duration sheet preview: when the task ends.
  ///
  /// In en, this message translates to:
  /// **'ends {time}'**
  String durationEnds(String time);

  /// Duration sheet preview: the task ends before the next one.
  ///
  /// In en, this message translates to:
  /// **'Still fits before {title} at {time}'**
  String durationFitsBefore(String title, String time);

  /// Duration sheet preview: nothing follows until Wind Down.
  ///
  /// In en, this message translates to:
  /// **'Fits before Wind Down at {time}'**
  String durationFitsWindDown(String time);

  /// Duration sheet preview: the task overlaps the next one.
  ///
  /// In en, this message translates to:
  /// **'Runs into {title} at {time}'**
  String durationRunsInto(String title, String time);

  /// Duration sheet preview: the task ends after Wind Down.
  ///
  /// In en, this message translates to:
  /// **'Runs past Wind Down at {time}'**
  String durationPastWindDown(String time);

  /// Duration sheet section caption (shown uppercase).
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get durationPresets;

  /// Duration sheet: restore the default presets.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get durationReset;

  /// The dashed '+ preset' chip (the + is an icon).
  ///
  /// In en, this message translates to:
  /// **'preset'**
  String get durationAddPreset;

  /// Screen-reader label of the '+ preset' chip.
  ///
  /// In en, this message translates to:
  /// **'Keep this length as a preset'**
  String get durationAddPresetLabel;

  /// Tooltip of a preset chip's ×.
  ///
  /// In en, this message translates to:
  /// **'Remove the {length} preset'**
  String durationRemovePreset(String length);

  /// A preset chip under an hour: '15m'.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationPresetMinutes(int minutes);

  /// A preset chip of whole hours: '2h'.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationPresetHours(int hours);

  /// A preset chip: '1h 30m'.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationPresetHoursMinutes(int hours, int minutes);

  /// Tooltip of the ⋯ beside TIME in Add.
  ///
  /// In en, this message translates to:
  /// **'More time options'**
  String get addMoreTime;

  /// Tooltip of the ⋯ beside DURATION in Add: opens the Duration sheet.
  ///
  /// In en, this message translates to:
  /// **'More lengths'**
  String get addMoreDuration;

  /// Time ⋯ menu item; also the month picker's title.
  ///
  /// In en, this message translates to:
  /// **'Change day'**
  String get timeMenuChangeDay;

  /// Time ⋯ menu item; also the week picker's title.
  ///
  /// In en, this message translates to:
  /// **'Pick from the week'**
  String get timeMenuPickWeek;

  /// Time ⋯ menu item.
  ///
  /// In en, this message translates to:
  /// **'Make it all-day'**
  String get timeMenuAllDay;

  /// Time ⋯ menu item when the task is all-day: back to a time.
  ///
  /// In en, this message translates to:
  /// **'Give it a time'**
  String get timeMenuTimed;

  /// Time ⋯ menu item: save without a time.
  ///
  /// In en, this message translates to:
  /// **'Send to Inbox'**
  String get timeMenuInbox;

  /// Time ⋯ menu item; also the zone picker's title.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get timeMenuZone;

  /// Time ⋯ menu item: the typed TimeInput.
  ///
  /// In en, this message translates to:
  /// **'Type a time'**
  String get timeMenuType;

  /// Label of the time-zone search field.
  ///
  /// In en, this message translates to:
  /// **'Search a city or zone'**
  String get zoneSearch;

  /// Week picker: go back a week.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get weekPrevious;

  /// Week picker: go forward a week.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get weekNext;

  /// Add step 2: an all-day task has no time.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get addAllDay;

  /// Lands-on row: change the day.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get addLandsOnEdit;

  /// Lands-on row for an all-day task. {day} is shown bold.
  ///
  /// In en, this message translates to:
  /// **'Lands on {day} · all day'**
  String addLandsOnAllDay(String day);

  /// Inline question after pasting a list into Add or the Inbox field (R-07).
  ///
  /// In en, this message translates to:
  /// **'Add {count} tasks?'**
  String pasteAsk(int count);

  /// Button: add every pasted line as its own task.
  ///
  /// In en, this message translates to:
  /// **'Add {count}'**
  String pasteAdd(int count);

  /// Button: join the pasted lines into one task.
  ///
  /// In en, this message translates to:
  /// **'Keep as one'**
  String get pasteKeep;

  /// Search header subtitle (A-ios-search).
  ///
  /// In en, this message translates to:
  /// **'Everything you\'ve planned'**
  String get searchSubtitle;

  /// Search field hint and screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'Search titles, notes and subtasks'**
  String get searchFieldLabel;

  /// Tooltip of the × in the search field.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClear;

  /// Screen-reader label of the count ring in the Search header.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String searchRingLabel(int count);

  /// Search filter chip.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchFilterAll;

  /// Search filter chip.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get searchFilterToday;

  /// Search filter chip.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get searchFilterWeek;

  /// Search filter chip.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get searchFilterInbox;

  /// Search filter chip.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get searchFilterDone;

  /// Search filter chip: pick one task colour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get searchFilterColour;

  /// Search filter chip: pick one icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get searchFilterIcon;

  /// Title of the colour filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Show one colour'**
  String get searchPickColour;

  /// Title of the icon filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Show one icon'**
  String get searchPickIcon;

  /// Results heading for today (shown uppercase; 'Today' in the accent).
  ///
  /// In en, this message translates to:
  /// **'{weekday} · Today'**
  String searchGroupToday(String weekday);

  /// Results heading for inbox tasks (shown uppercase).
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get searchGroupInbox;

  /// A result on another day: 'Fri 23 · 2:00 – 3:00'.
  ///
  /// In en, this message translates to:
  /// **'{day} · {range}'**
  String searchMetaDay(String day, String range);

  /// A done result: 'Mon 19 · 9:00 – 12:00 · Done'.
  ///
  /// In en, this message translates to:
  /// **'{when} · Done'**
  String searchMetaDone(String when);

  /// A past result not done.
  ///
  /// In en, this message translates to:
  /// **'{when} · not done'**
  String searchMetaMissed(String when);

  /// An inbox result: 'Inbox · 45 min'.
  ///
  /// In en, this message translates to:
  /// **'Inbox · {length}'**
  String searchMetaInbox(String length);

  /// Screen-reader label of a result row.
  ///
  /// In en, this message translates to:
  /// **'{title}, {meta}'**
  String searchRowLabel(String title, String meta);

  /// Recent searches caption (shown uppercase).
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get searchRecent;

  /// Screen-reader label of a recent-search chip.
  ///
  /// In en, this message translates to:
  /// **'Search for {query} again'**
  String searchRecentLabel(String query);

  /// Search with nothing typed and no recent searches.
  ///
  /// In en, this message translates to:
  /// **'Find anything you\'ve planned: titles, notes and subtasks, done ones too.'**
  String get searchEmpty;

  /// Search with no results.
  ///
  /// In en, this message translates to:
  /// **'No matches for “{query}”'**
  String searchNoResults(String query);

  /// Under the no-results line.
  ///
  /// In en, this message translates to:
  /// **'Try fewer words, or another filter.'**
  String get searchNoResultsHint;

  /// No results under a filter: go back to All.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get searchShowAll;

  /// A day without the month: 'Monday 19', 'Fri 23'.
  ///
  /// In en, this message translates to:
  /// **'{weekday} {date}'**
  String searchDayLabel(String weekday, String date);

  /// Settings header subtitle without an account (sync arrives in M6).
  ///
  /// In en, this message translates to:
  /// **'{name} · on this device'**
  String settingsLocalOnly(String name);

  /// Settings header subtitle without a name or account.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get settingsLocalOnlyNoName;

  /// Screen-reader label of the Settings avatar.
  ///
  /// In en, this message translates to:
  /// **'Account: {name}'**
  String settingsAvatarLabel(String name);

  /// Settings group caption (shown uppercase).
  ///
  /// In en, this message translates to:
  /// **'Day shape'**
  String get settingsDayShape;

  /// DAY SHAPE: length of the waking day, '15 h awake'.
  ///
  /// In en, this message translates to:
  /// **'{length} awake'**
  String settingsAwake(String length);

  /// Settings row; also the DAY SHAPE handle's name.
  ///
  /// In en, this message translates to:
  /// **'Wake Up'**
  String get settingsWakeUp;

  /// Settings row; also the DAY SHAPE handle's name.
  ///
  /// In en, this message translates to:
  /// **'Wind Down'**
  String get settingsWindDown;

  /// Settings row: per-weekday Wake Up / Wind Down.
  ///
  /// In en, this message translates to:
  /// **'Different days'**
  String get settingsPerWeekday;

  /// Per-weekday row value when no day differs.
  ///
  /// In en, this message translates to:
  /// **'Same every day'**
  String get settingsSameEveryDay;

  /// Per-weekday row value: the days that differ, 'Sat, Sun'.
  ///
  /// In en, this message translates to:
  /// **'{days}'**
  String settingsCustomDays(String days);

  /// Per-weekday sheet: reset this day to the everyday times.
  ///
  /// In en, this message translates to:
  /// **'Same as every day'**
  String get settingsUseEveryday;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Week starts'**
  String get settingsWeekStarts;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Time format'**
  String get settingsTimeFormat;

  /// Time format option: follow the OS.
  ///
  /// In en, this message translates to:
  /// **'Device ({example})'**
  String settingsTimeSystem(String example);

  /// Time format option.
  ///
  /// In en, this message translates to:
  /// **'12 h'**
  String get settingsTime12;

  /// Time format option.
  ///
  /// In en, this message translates to:
  /// **'24 h'**
  String get settingsTime24;

  /// Settings group caption.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get settingsPlanning;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Default duration'**
  String get settingsDefaultDuration;

  /// Settings row: drag/resize step.
  ///
  /// In en, this message translates to:
  /// **'Snap to'**
  String get settingsSnap;

  /// Snap value.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String settingsSnapValue(int minutes);

  /// Settings row: default of the drag chip (M3b.6).
  ///
  /// In en, this message translates to:
  /// **'Shift later tasks'**
  String get settingsShiftLater;

  /// Shift option: chip shown, off.
  ///
  /// In en, this message translates to:
  /// **'Ask each time'**
  String get settingsShiftAsk;

  /// Shift option: chip on.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get settingsShiftAlways;

  /// Shift option: no chip.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get settingsShiftNever;

  /// Settings switch.
  ///
  /// In en, this message translates to:
  /// **'Show free time'**
  String get settingsShowFree;

  /// Subtitle of Show free time.
  ///
  /// In en, this message translates to:
  /// **'Dotted gaps on the thread'**
  String get settingsShowFreeDetail;

  /// Settings switch.
  ///
  /// In en, this message translates to:
  /// **'Running-late nudge'**
  String get settingsLateNudge;

  /// Subtitle of Running-late nudge.
  ///
  /// In en, this message translates to:
  /// **'Offer to shift the rest of the day'**
  String get settingsLateNudgeDetail;

  /// Settings switch.
  ///
  /// In en, this message translates to:
  /// **'Roll unfinished to tomorrow'**
  String get settingsRoll;

  /// Subtitle of Roll unfinished.
  ///
  /// In en, this message translates to:
  /// **'Otherwise they return to the Inbox'**
  String get settingsRollDetail;

  /// Settings group caption.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsReminders;

  /// Settings row: the default alert.
  ///
  /// In en, this message translates to:
  /// **'Task starts'**
  String get settingsTaskStarts;

  /// Task starts option.
  ///
  /// In en, this message translates to:
  /// **'No alert'**
  String get settingsAlertNone;

  /// Task starts option.
  ///
  /// In en, this message translates to:
  /// **'When it starts'**
  String get settingsAlertAtStart;

  /// Task starts option.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min before'**
  String settingsAlertBefore(int minutes);

  /// Settings switch.
  ///
  /// In en, this message translates to:
  /// **'Wind Down reminder'**
  String get settingsWindDownReminder;

  /// Subtitle of Wind Down reminder.
  ///
  /// In en, this message translates to:
  /// **'At {time}, with tomorrow\'s first task'**
  String settingsWindDownReminderDetail(String time);

  /// Settings group caption.
  ///
  /// In en, this message translates to:
  /// **'Look'**
  String get settingsLook;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Like this device'**
  String get settingsThemeSystem;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Settings row: accent colour.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get settingsAccent;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Settings group caption.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// Settings row; also the Trash sheet's title.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get settingsTrash;

  /// Subtitle of Trash.
  ///
  /// In en, this message translates to:
  /// **'Deleted tasks stay 30 days'**
  String get settingsTrashDetail;

  /// Trash sheet with nothing in it.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get settingsTrashEmpty;

  /// Trash: put a task back.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get settingsRestore;

  /// Snackbar after restoring from Trash.
  ///
  /// In en, this message translates to:
  /// **'{title} restored'**
  String settingsRestored(String title);

  /// Settings group caption.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// About row; also the title of the changelog page (every release's notes).
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get settingsWhatsNew;

  /// Changelog page: caption over one release's notes.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String changelogVersion(String version);

  /// Changelog page: caption over the installed release's notes.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · on this device'**
  String changelogInstalled(String version);

  /// Changelog page intro.
  ///
  /// In en, this message translates to:
  /// **'What changed in each version of Dottoday.'**
  String get changelogIntro;

  /// Changelog notes for version 0.1.0; one item per line (each line becomes a bullet).
  ///
  /// In en, this message translates to:
  /// **'Plan your day on one thread: drag a task to move it, drag its edge to change how long it takes, and shift everything after it in one go.\nAdd a task in two taps, type times in plain words, or paste a list to add several at once.\nRepeating tasks, reminders with lead times, and your calendars on the timeline — all free.\nSync between iPhone, Android, Mac and the web, with a status you can see and nothing lost.\nExport everything as JSON, CSV or a calendar file, and bring a backup back.\nSend feedback from Settings, and read what\'s new here after each update.'**
  String get releaseNotes010;

  /// Banner after an update that brought release notes.
  ///
  /// In en, this message translates to:
  /// **'Dottoday {version} is here'**
  String whatsNewBanner(String version);

  /// Banner action: open the changelog page.
  ///
  /// In en, this message translates to:
  /// **'See what\'s new'**
  String get whatsNewOpen;

  /// Settings row; also the sheet's title.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get settingsFeedback;

  /// Feedback sheet intro.
  ///
  /// In en, this message translates to:
  /// **'Opens a draft in your mail app, and you send it from there. Nothing your tasks say is included.'**
  String get settingsFeedbackIntro;

  /// Feedback switch: diagnostics opt-in.
  ///
  /// In en, this message translates to:
  /// **'Add diagnostics'**
  String get settingsFeedbackDiagnostics;

  /// Feedback switch subtitle: what the diagnostics contain.
  ///
  /// In en, this message translates to:
  /// **'App version, device type, sync state and how many tasks you have — never what they say.'**
  String get settingsFeedbackDiagnosticsHint;

  /// Feedback sheet: the diagnostics couldn't be gathered.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the diagnostics, so the email goes without them.'**
  String get settingsFeedbackDiagnosticsFailed;

  /// Feedback sheet: caption over the diagnostics shown before sending.
  ///
  /// In en, this message translates to:
  /// **'Added to the end of your email:'**
  String get settingsFeedbackPreview;

  /// Feedback sheet primary button.
  ///
  /// In en, this message translates to:
  /// **'Write email'**
  String get settingsFeedbackWrite;

  /// Subject of the feedback email.
  ///
  /// In en, this message translates to:
  /// **'Dottoday feedback'**
  String get settingsFeedbackSubject;

  /// Snackbar when the mail draft can't open.
  ///
  /// In en, this message translates to:
  /// **'No mail app is set up on this device.'**
  String get settingsFeedbackNoMail;

  /// Screen-reader label of an accent swatch.
  ///
  /// In en, this message translates to:
  /// **'{name} accent'**
  String settingsAccentLabel(String name);

  /// After the weekday on the spread's previous-day column (Mac/web Today).
  ///
  /// In en, this message translates to:
  /// **' · Yesterday'**
  String get dayCardYesterdaySuffix;

  /// After the weekday on the spread's next-day column (Mac/web Today).
  ///
  /// In en, this message translates to:
  /// **' · Tomorrow'**
  String get dayCardTomorrowSuffix;

  /// Side-day summary of a past day on the Mac/web spread, e.g. '7 of 7'.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String spreadDoneOf(int done, int total);

  /// Side-day summary of a future day on the Mac/web spread, e.g. '4 planned'.
  ///
  /// In en, this message translates to:
  /// **'{count} planned'**
  String spreadPlanned(int count);

  /// Under the greeting on the Mac/web spread: 'Wednesday, 21 October · 2 of 7 done'.
  ///
  /// In en, this message translates to:
  /// **'{date} · {done} of {total} done'**
  String spreadSubtitle(String date, int done, int total);

  /// Tooltip of the ‹ button on the Mac/web spread.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get spreadPreviousDay;

  /// Tooltip of the › button on the Mac/web spread.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get spreadNextDay;

  /// Dashed drop target at the end of a future day on the Mac/web spread.
  ///
  /// In en, this message translates to:
  /// **'drop here to plan'**
  String get spreadDropToPlan;

  /// Screen-reader label of the spread's drop target.
  ///
  /// In en, this message translates to:
  /// **'Drop a task here to plan it on {day}'**
  String spreadDropToPlanLabel(String day);

  /// A future free gap on the wide Mac/web Today card.
  ///
  /// In en, this message translates to:
  /// **'{duration} free · drop an inbox task here'**
  String threadDropInbox(String duration);

  /// Button on the Mac/web Today header that pushes the rest of today later (R-04).
  ///
  /// In en, this message translates to:
  /// **'Running late'**
  String get runningLate;

  /// Running-late menu item: push the rest of today by this many minutes.
  ///
  /// In en, this message translates to:
  /// **'+{minutes} min'**
  String runningLateBy(int minutes);

  /// After Running late.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing left to move} =1{1 task moved {minutes} min later} other{{count} tasks moved {minutes} min later}}'**
  String snackRunningLate(int count, int minutes);

  /// After Running late when a pinned task stops the shift.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task moved {minutes} min later} other{{count} tasks moved {minutes} min later}} · {pinned} stays put'**
  String snackRunningLatePartial(int count, int minutes, String pinned);

  /// Side-day summary on the Mac/web spread when the day has no tasks.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned'**
  String get spreadNothing;

  /// A free gap on the Inbox's Drop onto today panel naming the inbox task that fits it.
  ///
  /// In en, this message translates to:
  /// **'{duration} free · {title} fits'**
  String threadFreeFits(String duration, String title);

  /// Inbox row on Mac/web: the first slot today.
  ///
  /// In en, this message translates to:
  /// **'Fits today {time}'**
  String inboxFitsToday(String time);

  /// Inbox row on Mac/web: the first slot later this week, e.g. 'Fits Thu 12:00'.
  ///
  /// In en, this message translates to:
  /// **'Fits {day} {time}'**
  String inboxFitsDay(String day, String time);

  /// Inbox row on Mac/web when nothing this week fits it.
  ///
  /// In en, this message translates to:
  /// **'No room this week'**
  String get inboxFitsNone;

  /// Inbox row meta on Mac/web, e.g. '60 min · added Monday'.
  ///
  /// In en, this message translates to:
  /// **'{duration} · added {when}'**
  String inboxAddedMeta(String duration, String when);

  /// 'added today' in the Inbox row meta.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get inboxAddedToday;

  /// 'added yesterday' in the Inbox row meta.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get inboxAddedYesterday;

  /// The Inbox sort button, e.g. 'Sort: duration'.
  ///
  /// In en, this message translates to:
  /// **'Sort: {order}'**
  String inboxSortLabel(String order);

  /// Inbox sort order: as added.
  ///
  /// In en, this message translates to:
  /// **'added'**
  String get inboxSortAdded;

  /// Inbox sort order: shortest first.
  ///
  /// In en, this message translates to:
  /// **'duration'**
  String get inboxSortDuration;

  /// Inbox sort order: soonest fitting slot first.
  ///
  /// In en, this message translates to:
  /// **'first fit'**
  String get inboxSortFit;

  /// Inbox button that places every task in the week's free time.
  ///
  /// In en, this message translates to:
  /// **'Auto-plan the week'**
  String get inboxAutoPlan;

  /// After Auto-plan the week.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing fits this week} =1{1 task planned this week} other{{count} tasks planned this week}}'**
  String snackAutoPlanned(int count);

  /// After Auto-plan the week when some did not fit.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task planned} other{{count} tasks planned}} · {left} still in the Inbox'**
  String snackAutoPlannedPartial(int count, int left);

  /// Title of the Inbox's today panel on Mac/web.
  ///
  /// In en, this message translates to:
  /// **'Drop onto today'**
  String get inboxDropToday;

  /// Free time left today in the Drop onto today panel.
  ///
  /// In en, this message translates to:
  /// **'{duration} free'**
  String inboxDropTodayFree(String duration);

  /// Footer of the Drop onto today panel.
  ///
  /// In en, this message translates to:
  /// **'Drag a task onto a dotted gap, or press {keys} on a row to place it in the first fitting slot.'**
  String inboxDropHint(String keys);

  /// Inbox sidebar header count.
  ///
  /// In en, this message translates to:
  /// **'{count} unscheduled'**
  String inboxUnscheduledCount(int count);

  /// Screen-reader label of an Inbox row with its fit: "Go for a run, 60 min, Fits today 11:30".
  ///
  /// In en, this message translates to:
  /// **'{row}, {fit}'**
  String inboxRowFitLabel(String row, String fit);

  /// Where a task was placed later this week, e.g. "Thu, 12:00 – 1:30 PM".
  ///
  /// In en, this message translates to:
  /// **'{day}, {range}'**
  String inboxScheduleDay(String day, String range);

  /// Screen-reader label of a Week day's capacity ring.
  ///
  /// In en, this message translates to:
  /// **'{planned} planned of {awake} awake'**
  String capacityRingLabel(String planned, String awake);

  /// Week summary chip, e.g. 'Busiest · Thu · 7 h 30'.
  ///
  /// In en, this message translates to:
  /// **'Busiest · {day} · {planned}'**
  String weekBusiest(String day, String planned);

  /// Week summary chip, e.g. 'Lightest · Sat · 2 h 30'.
  ///
  /// In en, this message translates to:
  /// **'Lightest · {day} · {planned}'**
  String weekLightest(String day, String planned);

  /// Week summary chip: free waking time this week.
  ///
  /// In en, this message translates to:
  /// **'Free · {free} unplanned'**
  String weekFree(String free);

  /// Week summary chip.
  ///
  /// In en, this message translates to:
  /// **'Done · {done} of {total}'**
  String weekDone(int done, int total);

  /// Tag under the busiest day's column on the Week board.
  ///
  /// In en, this message translates to:
  /// **'Busiest'**
  String get weekBusiestTag;

  /// Tag under the lightest day's column on the Week board.
  ///
  /// In en, this message translates to:
  /// **'Lightest'**
  String get weekLightestTag;

  /// Week board title for the current week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get weekTitle;

  /// Under the Week title: '18 – 24 October · 13 of 29 done · 36 h 15 planned'.
  ///
  /// In en, this message translates to:
  /// **'{range} · {done} of {total} done · {planned} planned'**
  String weekSubtitle(String range, int done, int total, String planned);

  /// Under a Week column's date: '10 h 30 free'.
  ///
  /// In en, this message translates to:
  /// **'{free} free'**
  String weekDayFree(String free);

  /// Today's Week column heading: 'Wed · today'.
  ///
  /// In en, this message translates to:
  /// **'{day} · today'**
  String weekTodayDay(String day);

  /// Week/Month switch on the Week board.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekViewWeek;

  /// Week/Month switch on the Week board.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get weekViewMonth;

  /// Button back to this week on the Week board.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get weekToday;

  /// Dashed target at the end of a future day on the Week board.
  ///
  /// In en, this message translates to:
  /// **'Drop a task here · {free}'**
  String weekDropHere(String free);

  /// Floating label while dragging over the Week board: 'Sat · 10:00 – 11:30'.
  ///
  /// In en, this message translates to:
  /// **'{day} · {range}'**
  String weekDropAt(String day, String range);

  /// Live card on the Week board.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left'**
  String weekCardLeft(int minutes);

  /// Skipped card on the Week board.
  ///
  /// In en, this message translates to:
  /// **'{range} · skipped'**
  String weekCardSkipped(String range);

  /// A week range: "October 18 – 24" or "Oct 28 – Nov 3".
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String weekRange(String start, String end);

  /// Mac/web Month header numbers.
  ///
  /// In en, this message translates to:
  /// **'{done} done · {missed} not done · {ahead} ahead'**
  String monthStats(int done, int missed, int ahead);

  /// Mac/web Month header with the busiest day: '… · busiest day Tue 13'.
  ///
  /// In en, this message translates to:
  /// **'{stats} · busiest day {day}'**
  String monthStatsBusiest(String stats, String day);

  /// Tooltip of × on the Mac/web editor panel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get editorClose;

  /// Key cap beside × on the Mac/web editor panel.
  ///
  /// In en, this message translates to:
  /// **'esc'**
  String get editorEscKey;

  /// Title of the ⌘/ shortcut sheet (Mac/web).
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get shortcutsTitle;

  /// Shortcut sheet section.
  ///
  /// In en, this message translates to:
  /// **'Everywhere'**
  String get shortcutsEverywhere;

  /// Shortcut sheet section.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get shortcutsTodaySection;

  /// Shortcut sheet section.
  ///
  /// In en, this message translates to:
  /// **'Week and Month'**
  String get shortcutsWeekMonth;

  /// Shortcut sheet section.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get shortcutsInbox;

  /// Shortcut sheet section.
  ///
  /// In en, this message translates to:
  /// **'Editing a task'**
  String get shortcutsEditor;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Add a task'**
  String get shortcutAdd;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Go to Today'**
  String get shortcutGoToday;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Go to Inbox'**
  String get shortcutGoInbox;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Go to Week'**
  String get shortcutGoWeek;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Go to Month'**
  String get shortcutGoMonth;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Show these shortcuts'**
  String get shortcutShowKeys;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get shortcutPrevDay;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get shortcutNextDay;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Back to today'**
  String get shortcutBackToday;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Mark the current task done'**
  String get shortcutDoneLive;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Previous week or month'**
  String get shortcutPrevPeriod;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Next week or month'**
  String get shortcutNextPeriod;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'This week or month'**
  String get shortcutThisPeriod;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Place the selected task in its first free slot'**
  String get shortcutPlaceFirst;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Auto-plan the week'**
  String get shortcutAutoPlan;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Save and close'**
  String get shortcutSave;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get shortcutDone;

  /// Shortcut sheet action.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get shortcutClose;

  /// Title of the Repeat editor sheet.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatTitle;

  /// Repeat summary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String repeatEveryDays(int count);

  /// Repeat summary and choice: Monday to Friday.
  ///
  /// In en, this message translates to:
  /// **'Every weekday'**
  String get repeatEveryWeekday;

  /// Repeat summary without days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every week} other{Every {count} weeks}}'**
  String repeatEveryWeeks(int count);

  /// Repeat summary: 'Every week on Mon, Fri'.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every week on {days}} other{Every {count} weeks on {days}}}'**
  String repeatEveryWeeksOn(int count, String days);

  /// Repeat summary by date.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every month on day {day}} other{Every {count} months on day {day}}}'**
  String repeatEveryMonthsOnDay(int count, int day);

  /// Repeat summary by weekday: 'Every month on the third Wednesday'.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every month on the {nth} {weekday}} other{Every {count} months on the {nth} {weekday}}}'**
  String repeatEveryMonthsOnNth(int count, String nth, String weekday);

  /// Which weekday of the month; 'other' is the last one.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 1{first} 2{second} 3{third} 4{fourth} other{last}}'**
  String repeatNth(String n);

  /// Repeat summary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every year} other{Every {count} years}}'**
  String repeatEveryYears(int count);

  /// Repeat summary with a count end.
  ///
  /// In en, this message translates to:
  /// **'{summary} · {count, plural, =1{once} other{{count} times}}'**
  String repeatTimes(String summary, int count);

  /// Repeat summary with an end date.
  ///
  /// In en, this message translates to:
  /// **'{summary} · until {date}'**
  String repeatUntil(String summary, String date);

  /// Repeat editor choice.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get repeatChoiceDaily;

  /// Repeat editor choice; weekday chips appear under it.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get repeatChoiceWeekly;

  /// Repeat editor choice.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get repeatChoiceMonthly;

  /// Repeat editor choice.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get repeatChoiceYearly;

  /// Repeat editor choice: every N days, weeks or months.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get repeatChoiceCustom;

  /// Monthly repeat by date.
  ///
  /// In en, this message translates to:
  /// **'On day {day}'**
  String repeatOnDay(int day);

  /// Monthly repeat by weekday.
  ///
  /// In en, this message translates to:
  /// **'On the {nth} {weekday}'**
  String repeatOnNth(String nth, String weekday);

  /// Before the custom interval number.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get repeatEvery;

  /// Custom repeat unit.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day} other{days}}'**
  String repeatUnitDays(int count);

  /// Custom repeat unit.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{week} other{weeks}}'**
  String repeatUnitWeeks(int count);

  /// Custom repeat unit.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{month} other{months}}'**
  String repeatUnitMonths(int count);

  /// Screen-reader label of − on the custom interval.
  ///
  /// In en, this message translates to:
  /// **'Fewer'**
  String get repeatIntervalLess;

  /// Screen-reader label of + on the custom interval.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get repeatIntervalMore;

  /// Caption of the end choice in the Repeat editor.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get repeatEnds;

  /// Repeat end choice.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get repeatEndsNever;

  /// Repeat end choice: after N times.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get repeatEndsAfter;

  /// Repeat end choice.
  ///
  /// In en, this message translates to:
  /// **'On a date'**
  String get repeatEndsOn;

  /// The count of an 'After' end.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time} other{{count} times}}'**
  String repeatEndsAfterCount(int count);

  /// Closes the Repeat editor and applies the rule.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get repeatDone;

  /// Title of the edit-scope sheet for a repeating task.
  ///
  /// In en, this message translates to:
  /// **'Change which?'**
  String get scopeTitleEdit;

  /// Title of the delete-scope sheet for a repeating task.
  ///
  /// In en, this message translates to:
  /// **'Delete which?'**
  String get scopeTitleDelete;

  /// Scope: only this occurrence.
  ///
  /// In en, this message translates to:
  /// **'This one'**
  String get scopeThis;

  /// Scope: this occurrence and every later one.
  ///
  /// In en, this message translates to:
  /// **'This and following'**
  String get scopeFollowing;

  /// Scope: the whole series from now on (history stays).
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get scopeAll;

  /// Under 'All' in the scope sheet.
  ///
  /// In en, this message translates to:
  /// **'Past ones stay as they were'**
  String get scopeAllDetail;

  /// After a scoped edit of a repeating task.
  ///
  /// In en, this message translates to:
  /// **'{title} changed'**
  String snackSeriesChanged(String title);

  /// After a scoped delete of a repeating task.
  ///
  /// In en, this message translates to:
  /// **'{title} deleted'**
  String snackSeriesDeleted(String title);

  /// After choosing a repeat rule.
  ///
  /// In en, this message translates to:
  /// **'{title} repeats {summary}'**
  String snackRepeatSet(String title, String summary);

  /// After choosing Never on a repeating task.
  ///
  /// In en, this message translates to:
  /// **'{title} no longer repeats'**
  String snackRepeatStopped(String title);

  /// Title of the Alerts editor sheet.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTitle;

  /// Caption over the alert choices.
  ///
  /// In en, this message translates to:
  /// **'Add an alert'**
  String get alertsAdd;

  /// Shown when a task has 5 alerts.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 alerts'**
  String get alertsMax;

  /// Tooltip of × on an alert row.
  ///
  /// In en, this message translates to:
  /// **'Remove {alert}'**
  String alertsRemove(String alert);

  /// Switch in the Alerts editor (applies to every day).
  ///
  /// In en, this message translates to:
  /// **'Wind Down reminder'**
  String get alertsWindDown;

  /// Under the Wind Down reminder switch.
  ///
  /// In en, this message translates to:
  /// **'Every evening, with tomorrow\'s first task'**
  String get alertsWindDownDetail;

  /// Closes the Alerts editor and applies the alerts.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get alertsDone;

  /// After a scoped alerts change.
  ///
  /// In en, this message translates to:
  /// **'{title} alerts updated'**
  String snackAlertsSaved(String title);

  /// Tooltip of × on a subtask row.
  ///
  /// In en, this message translates to:
  /// **'Remove {title}'**
  String subtaskRemove(String title);

  /// Screen-reader label of a subtask's drag handle.
  ///
  /// In en, this message translates to:
  /// **'Reorder {title}'**
  String subtaskReorder(String title);

  /// Screen-reader action on a subtask.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get subtaskMoveUp;

  /// Screen-reader action on a subtask.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get subtaskMoveDown;

  /// Screen-reader hint: tap a subtask's title to rename it.
  ///
  /// In en, this message translates to:
  /// **'Rename {title}'**
  String subtaskRename(String title);

  /// Beside the next subtask of the task running now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get subtaskNow;

  /// Makes this day's subtasks the list for every repeat.
  ///
  /// In en, this message translates to:
  /// **'Use this list every time'**
  String get subtaskEveryTime;

  /// After removing a subtask.
  ///
  /// In en, this message translates to:
  /// **'{title} removed'**
  String snackSubtaskRemoved(String title);

  /// After 'Use this list every time'.
  ///
  /// In en, this message translates to:
  /// **'{title} will have this list every time'**
  String snackListEveryTime(String title);

  /// Title of the full colour and icon picker.
  ///
  /// In en, this message translates to:
  /// **'Colour and icon'**
  String get colourIconTitle;

  /// Closes the colour and icon picker keeping the colour.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get colourIconDone;

  /// Search field in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Search icons'**
  String get iconSearchHint;

  /// Icon picker: nothing matches the search text.
  ///
  /// In en, this message translates to:
  /// **'No icons match “{query}”'**
  String iconSearchEmpty(String query);

  /// Title of the rename dialog.
  ///
  /// In en, this message translates to:
  /// **'Rename subtask'**
  String get subtaskRenameTitle;

  /// Confirms the new subtask name.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get subtaskRenameSave;

  /// Editor: the task's time zone under START; tap to pick another (keeps the wall clock).
  ///
  /// In en, this message translates to:
  /// **'Time zone · {city}'**
  String editorZone(String city);

  /// Today ⋯ menu: opens the Running late sheet.
  ///
  /// In en, this message translates to:
  /// **'Running late…'**
  String get todayMenuLate;

  /// Today ⋯ menu: opens the Day review.
  ///
  /// In en, this message translates to:
  /// **'Review the day'**
  String get todayMenuReview;

  /// Running late sheet: label of the +5/+15/+30 choice.
  ///
  /// In en, this message translates to:
  /// **'How late'**
  String get lateAmount;

  /// Running late sheet: push every remaining task later.
  ///
  /// In en, this message translates to:
  /// **'Shift the rest'**
  String get lateShiftRest;

  /// Running late sheet: what Shift the rest will do.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing left to move} =1{1 task moves {minutes} min later} other{{count} tasks move {minutes} min later}}'**
  String lateShiftPreview(int count, int minutes);

  /// Running late sheet: Shift the rest stops at a pinned task.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task moves {minutes} min later} other{{count} tasks move {minutes} min later}} · {pinned} stays put'**
  String lateShiftPreviewPartial(int count, int minutes, String pinned);

  /// Running late sheet: skip the current or next task.
  ///
  /// In en, this message translates to:
  /// **'Skip “{title}”'**
  String lateSkip(String title);

  /// Running late sheet: under Skip.
  ///
  /// In en, this message translates to:
  /// **'Frees its time; nothing else moves'**
  String get lateSkipDetail;

  /// Running late sheet: start the current or next task later, same end.
  ///
  /// In en, this message translates to:
  /// **'Shorten “{title}”'**
  String lateShorten(String title);

  /// Running late sheet: under Shorten.
  ///
  /// In en, this message translates to:
  /// **'Starts {minutes} min later, still ends at {end}'**
  String lateShortenDetail(int minutes, String end);

  /// Running late sheet: Shorten is off because the task is too short.
  ///
  /// In en, this message translates to:
  /// **'Too short to lose {minutes} min'**
  String lateShortenTooShort(int minutes);

  /// Running late sheet: no task left to skip or shorten.
  ///
  /// In en, this message translates to:
  /// **'Nothing left today'**
  String get lateNothingLeft;

  /// Snackbar after Skip, with Undo.
  ///
  /// In en, this message translates to:
  /// **'“{title}” skipped'**
  String snackSkippedTask(String title);

  /// Snackbar after Shorten, with Undo.
  ///
  /// In en, this message translates to:
  /// **'“{title}” starts {minutes} min later'**
  String snackShortened(String title, int minutes);

  /// Day review sheet title and prompt heading.
  ///
  /// In en, this message translates to:
  /// **'Day review'**
  String get reviewTitle;

  /// Day review: the day's count.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String reviewSummary(int done, int total);

  /// Day review question when Roll unfinished to tomorrow is on.
  ///
  /// In en, this message translates to:
  /// **'Move the rest to tomorrow?'**
  String get reviewAskTomorrow;

  /// Day review question when Roll unfinished to tomorrow is off.
  ///
  /// In en, this message translates to:
  /// **'Send the rest to the Inbox?'**
  String get reviewAskInbox;

  /// Day review button.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Move 1 to tomorrow} other{Move {count} to tomorrow}}'**
  String reviewMoveTomorrow(int count);

  /// Day review button.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Send 1 to Inbox} other{Send {count} to Inbox}}'**
  String reviewSendInbox(int count);

  /// Day review: unfinished tasks that are not moved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more stays: it repeats or comes from a calendar} other{{count} more stay: they repeat or come from a calendar}}'**
  String reviewStaying(int count);

  /// Day review when every one-off task is done.
  ///
  /// In en, this message translates to:
  /// **'Nothing left to move'**
  String get reviewAllDone;

  /// Snackbar after the Day review, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task moved to tomorrow} other{{count} tasks moved to tomorrow}}'**
  String snackRolled(int count);

  /// Snackbar after the Day review, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task sent to the Inbox} other{{count} tasks sent to the Inbox}}'**
  String snackSentToInbox(int count);

  /// Today prompt: put the prompt away for today.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get promptNotNow;

  /// Today prompt when a task ended unticked (running-late nudge).
  ///
  /// In en, this message translates to:
  /// **'Need more time?'**
  String get lateNudgeTitle;

  /// Running-late nudge detail.
  ///
  /// In en, this message translates to:
  /// **'“{title}” ended {minutes} min ago'**
  String lateNudgeDetail(String title, int minutes);

  /// Running-late nudge button: opens the Running late sheet.
  ///
  /// In en, this message translates to:
  /// **'Catch up'**
  String get lateNudgeAction;

  /// Day ⋯ menu: copy this day's one-off tasks to another day.
  ///
  /// In en, this message translates to:
  /// **'Duplicate day…'**
  String get todayMenuDuplicate;

  /// Day ⋯ menu: put this day's tasks on the clipboard as plain text.
  ///
  /// In en, this message translates to:
  /// **'Copy day as text'**
  String get todayMenuCopyText;

  /// Duplicate day: the month picker's title.
  ///
  /// In en, this message translates to:
  /// **'Copy to which day?'**
  String get duplicateDayTitle;

  /// Snackbar after Copy day as text.
  ///
  /// In en, this message translates to:
  /// **'Day copied as text'**
  String get snackDayCopied;

  /// Completed group: when an inbox task was done, e.g. 'Done Tue, Oct 20'.
  ///
  /// In en, this message translates to:
  /// **'Done {date}'**
  String inboxDoneOn(String date);

  /// Completed group: button tooltip that puts a done task back in the Inbox.
  ///
  /// In en, this message translates to:
  /// **'Mark “{title}” not done'**
  String inboxNotDone(String title);

  /// Completed group: move every completed inbox task to Trash.
  ///
  /// In en, this message translates to:
  /// **'Clear completed'**
  String get inboxClearCompleted;

  /// Snackbar after marking a completed inbox task not done, with Undo.
  ///
  /// In en, this message translates to:
  /// **'“{title}” is back in the Inbox'**
  String snackBackInInbox(String title);

  /// Snackbar after Clear completed, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 completed task moved to Trash} other{{count} completed tasks moved to Trash}}'**
  String snackClearedCompleted(int count);

  /// Settings header tap target and page title: the account page.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// Settings › DATA row and page title.
  ///
  /// In en, this message translates to:
  /// **'Calendars'**
  String get settingsCalendars;

  /// Settings › Calendars row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Events on your timeline'**
  String get settingsCalendarsDetail;

  /// Settings › DATA row and page title.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsExport;

  /// Settings › Export row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data, free to take'**
  String get settingsExportDetail;

  /// Settings › ABOUT row and page title.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsHelp;

  /// Settings › ABOUT row and page title.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// Settings › ABOUT row and page title.
  ///
  /// In en, this message translates to:
  /// **'About Dottoday'**
  String get settingsAboutApp;

  /// Settings sub-page back button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Back to Settings'**
  String get settingsBack;

  /// Account page group caption.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get accountProfile;

  /// Account page: the display name row.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get accountName;

  /// Account page: no display name yet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get accountNameNone;

  /// Rename dialog title on the Account page.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get accountNameTitle;

  /// Rename dialog button on the Account page.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get accountNameSave;

  /// Account page group caption.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get accountSync;

  /// Account page, signed out.
  ///
  /// In en, this message translates to:
  /// **'Everything is on this device. Sign in to sync across your devices and keep a copy safe.'**
  String get accountLocalBody;

  /// Account page sign-in button.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get accountApple;

  /// Account page sign-in button.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get accountGoogle;

  /// Account page sign-in button (magic link).
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get accountEmail;

  /// Account page caption while accounts are not available.
  ///
  /// In en, this message translates to:
  /// **'Sign-in arrives with sync in a later update. Until then, nothing leaves this device.'**
  String get accountComingSoon;

  /// Account page, signed in.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String accountSignedInAs(String email);

  /// Account page button.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// Account page: ends the account's sessions on every device (06 §2).
  ///
  /// In en, this message translates to:
  /// **'Sign out everywhere'**
  String get accountSignOutEverywhere;

  /// Account page destructive button and the confirm dialog's button.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDelete;

  /// Delete account confirm dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get accountDeleteTitle;

  /// Delete account dialog: opens Settings › Export before deleting (06 §6, M6.5).
  ///
  /// In en, this message translates to:
  /// **'Export my data first'**
  String get accountDeleteExportFirst;

  /// Delete account confirm dialog body.
  ///
  /// In en, this message translates to:
  /// **'This deletes your account and everything synced to it. Tasks on this device stay. Type {word} to confirm.'**
  String accountDeleteBody(String word);

  /// The word typed to confirm account deletion.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get accountDeleteWord;

  /// Calendars page intro.
  ///
  /// In en, this message translates to:
  /// **'Your calendar events on the timeline, next to your tasks. Free, always.'**
  String get calendarsIntro;

  /// Calendars page group caption.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get calendarsConnected;

  /// Calendars page: empty list.
  ///
  /// In en, this message translates to:
  /// **'No calendars connected yet'**
  String get calendarsNone;

  /// Calendars page button.
  ///
  /// In en, this message translates to:
  /// **'Connect a calendar'**
  String get calendarsConnect;

  /// Onboarding O4 where the device has no calendars of its own (web): where online calendars are connected (M7.4).
  ///
  /// In en, this message translates to:
  /// **'Connect Google or Microsoft in Settings › Calendars.'**
  String get calendarsOnlineInSettings;

  /// Calendars page group caption for connected online accounts (M7.4).
  ///
  /// In en, this message translates to:
  /// **'Google and Microsoft'**
  String get calendarsOnline;

  /// Calendars page: how online calendars behave across devices (M7.4).
  ///
  /// In en, this message translates to:
  /// **'Connected once, they show on every device you sign in on. If a calendar is also on this device, switch one of the two off.'**
  String get calendarsOnlineIntro;

  /// Calendars page row while signed out; opens Settings › Account (M7.4).
  ///
  /// In en, this message translates to:
  /// **'Sign in to connect Google or Microsoft'**
  String get calendarsOnlineSignIn;

  /// Calendars page row: opens Google's sign-in page (M7.4).
  ///
  /// In en, this message translates to:
  /// **'Connect Google Calendar'**
  String get calendarsConnectGoogle;

  /// Calendars page row: opens Microsoft's sign-in page (M7.4).
  ///
  /// In en, this message translates to:
  /// **'Connect Microsoft Outlook'**
  String get calendarsConnectMicrosoft;

  /// Calendars page row for an account whose access was revoked or expired (M7.4).
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get calendarsReconnect;

  /// Calendars page: subtitle of the Reconnect row (M7.4).
  ///
  /// In en, this message translates to:
  /// **'Dottoday can\'t reach this account until you reconnect it'**
  String get calendarsReconnectDetail;

  /// Calendars page: an account the provider didn't answer for; it is tried again later (M7.4).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach this account just now'**
  String get calendarsUnreachable;

  /// Calendars page row and confirm button: removes a connected account (M7.4).
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get calendarsDisconnect;

  /// Confirm dialog title before removing a connected calendar account (M7.4).
  ///
  /// In en, this message translates to:
  /// **'Disconnect {account}?'**
  String calendarsDisconnectTitle(String account);

  /// Confirm dialog body before removing a connected calendar account (M7.4).
  ///
  /// In en, this message translates to:
  /// **'Its events leave your timeline on every device. Events with your subtasks or notes go to Trash.'**
  String get calendarsDisconnectBody;

  /// Calendars page group caption.
  ///
  /// In en, this message translates to:
  /// **'When the day shifts'**
  String get calendarsShifting;

  /// Calendars page toggle (includeCalendarInShift).
  ///
  /// In en, this message translates to:
  /// **'Move calendar events too'**
  String get calendarsMoveEvents;

  /// Calendars page toggle subtitle.
  ///
  /// In en, this message translates to:
  /// **'When you shift the rest. Shared and repeating events stay put.'**
  String get calendarsMoveEventsDetail;

  /// Calendars page: explains the permission prompt before Connect.
  ///
  /// In en, this message translates to:
  /// **'Dottoday asks your device once to see your calendars. Then you choose which ones come in.'**
  String get calendarsAsk;

  /// Calendars page group caption for calendars without an account name.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get calendarsOnDevice;

  /// Calendars page: permission granted but the device has no calendars.
  ///
  /// In en, this message translates to:
  /// **'No calendars on this device'**
  String get calendarsNoneOnDevice;

  /// Calendars page: subtitle part for a calendar Dottoday can't write to.
  ///
  /// In en, this message translates to:
  /// **'Read-only'**
  String get calendarsReadOnly;

  /// Onboarding O4: the Connect a calendar row once access is allowed.
  ///
  /// In en, this message translates to:
  /// **'Connected · choose calendars in Settings'**
  String get calendarsPickInSettings;

  /// Permission-denied notice title for calendars.
  ///
  /// In en, this message translates to:
  /// **'Calendar access is off'**
  String get calendarDeniedTitle;

  /// Permission-denied notice body for calendars.
  ///
  /// In en, this message translates to:
  /// **'Dottoday can\'t show your events until calendar access is allowed in your device settings.'**
  String get calendarDeniedBody;

  /// Shown when the app can't open the system settings itself.
  ///
  /// In en, this message translates to:
  /// **'Open your device\'s Settings, find Dottoday and allow access to Calendars.'**
  String get calendarSettingsPath;

  /// Export page intro.
  ///
  /// In en, this message translates to:
  /// **'Your tasks are yours. Export is free, always, with or without an account.'**
  String get exportIntro;

  /// Export page group caption.
  ///
  /// In en, this message translates to:
  /// **'Formats'**
  String get exportFormats;

  /// Export format row.
  ///
  /// In en, this message translates to:
  /// **'Everything (JSON)'**
  String get exportJson;

  /// Export format row subtitle.
  ///
  /// In en, this message translates to:
  /// **'A full copy you can restore'**
  String get exportJsonDetail;

  /// Export format row.
  ///
  /// In en, this message translates to:
  /// **'Tasks (CSV)'**
  String get exportCsv;

  /// Export format row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Opens in any spreadsheet'**
  String get exportCsvDetail;

  /// Export format row.
  ///
  /// In en, this message translates to:
  /// **'Calendar (.ics)'**
  String get exportIcs;

  /// Export format row subtitle.
  ///
  /// In en, this message translates to:
  /// **'For other calendar apps'**
  String get exportIcsDetail;

  /// Export page warning shown before any export (06 §2: plaintext by user action only).
  ///
  /// In en, this message translates to:
  /// **'Export files aren\'t encrypted: anyone who has the file can read your tasks. Imported calendar events stay in their calendar and aren\'t included.'**
  String get exportPlain;

  /// Snackbar after an export file was shared, saved or downloaded.
  ///
  /// In en, this message translates to:
  /// **'Exported'**
  String get exportDone;

  /// Snackbar when the share sheet or save dialog failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save or share the file. Nothing was changed.'**
  String get exportHandOffFailed;

  /// Export page group caption for importing a backup.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get exportRestore;

  /// Row that opens the file picker for a JSON backup.
  ///
  /// In en, this message translates to:
  /// **'Import a backup…'**
  String get exportImport;

  /// Subtitle of the import row.
  ///
  /// In en, this message translates to:
  /// **'A JSON file exported from Dottoday'**
  String get exportImportDetail;

  /// Import confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Replace your tasks with this backup?'**
  String get exportImportTitle;

  /// Import confirmation body; names the replace policy.
  ///
  /// In en, this message translates to:
  /// **'This file from {date} has {count, plural, =0{no tasks} =1{1 task} other{{count} tasks}}. Anything here that isn\'t in it moves to Trash. A backup of what\'s here now is taken first.'**
  String exportImportBody(String date, int count);

  /// Import confirmation action.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get exportImportAction;

  /// Cancels an import or restore.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get exportCancel;

  /// Snackbar after an import; offers Undo.
  ///
  /// In en, this message translates to:
  /// **'Backup imported'**
  String get exportImported;

  /// Import refused: wrong or newer file.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a Dottoday backup, or it comes from a newer version of Dottoday. Nothing was changed.'**
  String get exportNotBackup;

  /// Import refused: file too large.
  ///
  /// In en, this message translates to:
  /// **'This file is over 25 MB, too large to import. Nothing was changed.'**
  String get exportTooLarge;

  /// Export page group caption for local backups.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get exportBackups;

  /// Explains local backups.
  ///
  /// In en, this message translates to:
  /// **'Dottoday keeps a backup each day (the last 7) and one before every import or restore, encrypted, on this device only.'**
  String get exportBackupsNote;

  /// Shown when there are no local backups.
  ///
  /// In en, this message translates to:
  /// **'No backups yet. The first is taken the next time Dottoday opens.'**
  String get exportBackupsNone;

  /// Local backup row: the daily one.
  ///
  /// In en, this message translates to:
  /// **'Daily backup'**
  String get exportBackupDaily;

  /// Local backup row: taken before an import.
  ///
  /// In en, this message translates to:
  /// **'Before an import'**
  String get exportBackupPreImport;

  /// Local backup row: taken before a restore.
  ///
  /// In en, this message translates to:
  /// **'Before a restore'**
  String get exportBackupPreRestore;

  /// Restore confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Go back to this backup?'**
  String get exportRestoreTitle;

  /// Restore confirmation body; names the replace policy.
  ///
  /// In en, this message translates to:
  /// **'Your tasks go back to how they were on {date}. Anything newer moves to Trash. A backup of what\'s here now is taken first.'**
  String exportRestoreBody(String date);

  /// Restore confirmation action.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get exportRestoreAction;

  /// Snackbar after restoring a local backup; offers Undo.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get exportRestored;

  /// Help page intro.
  ///
  /// In en, this message translates to:
  /// **'Quick answers. Anything else? Send feedback below.'**
  String get helpIntro;

  /// Help question.
  ///
  /// In en, this message translates to:
  /// **'How do I move a task?'**
  String get helpMoveQ;

  /// Help answer.
  ///
  /// In en, this message translates to:
  /// **'Drag it along the thread, or drag its edges to change how long it is. Long-press to pick several.'**
  String get helpMoveA;

  /// Help question.
  ///
  /// In en, this message translates to:
  /// **'I\'m running late. Can everything move?'**
  String get helpLateQ;

  /// Help answer.
  ///
  /// In en, this message translates to:
  /// **'Yes: ⋯ › Running late pushes the rest of today by 5, 15 or 30 minutes, stopping at pinned tasks. You can also skip or shorten the task at hand.'**
  String get helpLateA;

  /// Help question.
  ///
  /// In en, this message translates to:
  /// **'How do repeating tasks work?'**
  String get helpRepeatQ;

  /// Help answer.
  ///
  /// In en, this message translates to:
  /// **'Open a task › Repeat. Ticks and subtasks belong to each day, so the next one starts fresh.'**
  String get helpRepeatA;

  /// Help question.
  ///
  /// In en, this message translates to:
  /// **'Can I add many tasks at once?'**
  String get helpPasteQ;

  /// Help answer.
  ///
  /// In en, this message translates to:
  /// **'Paste a list into Add or the Inbox field: each line becomes a task.'**
  String get helpPasteA;

  /// Help question.
  ///
  /// In en, this message translates to:
  /// **'Are there keyboard shortcuts?'**
  String get helpKeysQ;

  /// Help answer.
  ///
  /// In en, this message translates to:
  /// **'On a Mac or in a browser, press ⌘/ (Ctrl+/ elsewhere) to see them all.'**
  String get helpKeysA;

  /// Privacy page heading.
  ///
  /// In en, this message translates to:
  /// **'On your device'**
  String get privacyLocalTitle;

  /// Privacy page text.
  ///
  /// In en, this message translates to:
  /// **'Tasks are stored encrypted on this device, and the app works fully offline.'**
  String get privacyLocalBody;

  /// Privacy page heading.
  ///
  /// In en, this message translates to:
  /// **'No tracking'**
  String get privacyTrackTitle;

  /// Privacy page text.
  ///
  /// In en, this message translates to:
  /// **'No ads, no analytics, no third-party trackers.'**
  String get privacyTrackBody;

  /// Privacy page heading.
  ///
  /// In en, this message translates to:
  /// **'When you sign in'**
  String get privacySyncTitle;

  /// Privacy page text.
  ///
  /// In en, this message translates to:
  /// **'Sync sends your tasks over an encrypted connection to your own account, and nowhere else.'**
  String get privacySyncBody;

  /// Privacy page heading.
  ///
  /// In en, this message translates to:
  /// **'Searches'**
  String get privacySearchTitle;

  /// Privacy page text.
  ///
  /// In en, this message translates to:
  /// **'Recent searches stay on this device and are never synced or exported.'**
  String get privacySearchBody;

  /// Privacy page button.
  ///
  /// In en, this message translates to:
  /// **'Clear recent searches'**
  String get privacyClearSearches;

  /// Privacy page heading, shown only when crash reporting is configured.
  ///
  /// In en, this message translates to:
  /// **'Crash reports'**
  String get privacyCrashTitle;

  /// Privacy page paragraph under 'Crash reports' (docs/06 §6).
  ///
  /// In en, this message translates to:
  /// **'If the app crashes, it sends the kind of error and where in the app it happened. Never your tasks, notes or account.'**
  String get privacyCrashBody;

  /// Privacy page button: opens the full privacy policy in the browser.
  ///
  /// In en, this message translates to:
  /// **'Read the privacy policy'**
  String get privacyPolicyOpen;

  /// Snackbar after Clear recent searches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches cleared'**
  String get snackSearchesCleared;

  /// About page row: the licence page.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get aboutLicences;

  /// Settings › DATA row: opens the Sync sheet.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get settingsSync;

  /// Sync sheet title.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncTitle;

  /// Sync sheet, no account.
  ///
  /// In en, this message translates to:
  /// **'Your tasks are on this device only. Sign in to sync them across your devices.'**
  String get syncLocalOnlyBody;

  /// Sync sheet, no account: opens Settings › Account.
  ///
  /// In en, this message translates to:
  /// **'Sign in…'**
  String get syncSignIn;

  /// Sync sheet: synced under a minute ago.
  ///
  /// In en, this message translates to:
  /// **'Last synced just now'**
  String get syncJustNow;

  /// Sync sheet: synced minutes ago.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{Last synced 1 min ago} other{Last synced {minutes} min ago}}'**
  String syncMinutesAgo(int minutes);

  /// Sync sheet: synced earlier, e.g. 'Tue, Oct 20, 9:41 PM'.
  ///
  /// In en, this message translates to:
  /// **'Last synced {when}'**
  String syncAt(String when);

  /// Sync sheet: never synced.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get syncNever;

  /// Sync sheet: local changes not yet pushed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing waiting to sync} =1{1 change waiting to sync} other{{count} changes waiting to sync}}'**
  String syncPending(int count);

  /// Sync sheet button.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// Sync sheet state line.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get syncStateSynced;

  /// Sync sheet state line.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncStateSyncing;

  /// Sync sheet state line.
  ///
  /// In en, this message translates to:
  /// **'Offline. Changes are saved here and sync when you\'re back.'**
  String get syncStateOffline;

  /// Sync sheet state line.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sync. Your changes are safe here; it will try again.'**
  String get syncStateError;

  /// Sync sheet: the conflicts section caption.
  ///
  /// In en, this message translates to:
  /// **'Changed on two devices'**
  String get syncConflicts;

  /// Sync sheet: under the conflicts caption.
  ///
  /// In en, this message translates to:
  /// **'The other device\'s change is in use until you choose.'**
  String get syncConflictHint;

  /// Sync sheet: which field of the task differs.
  ///
  /// In en, this message translates to:
  /// **'{field, select, title{Title} start{Time} duration{Length} notes{Notes} colour{Colour} status{Done or not} other{A detail}}'**
  String syncConflictField(String field);

  /// Sync sheet: this device's value.
  ///
  /// In en, this message translates to:
  /// **'This device: {value}'**
  String syncMine(String value);

  /// Sync sheet: the other device's value.
  ///
  /// In en, this message translates to:
  /// **'Other device: {value}'**
  String syncTheirs(String value);

  /// Sync sheet conflict button.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get syncKeepMine;

  /// Sync sheet conflict button.
  ///
  /// In en, this message translates to:
  /// **'Keep theirs'**
  String get syncKeepTheirs;

  /// Banner above every screen while offline (signed in).
  ///
  /// In en, this message translates to:
  /// **'Offline · everything still works here'**
  String get bannerOffline;

  /// Banner above every screen when sync has conflicts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change needs you} other{{count} changes need you}}'**
  String bannerConflicts(int count);

  /// Banner button: opens the Sync sheet.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get bannerReview;

  /// Notification permission denied notice title.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get notifDeniedTitle;

  /// Notification permission denied notice text.
  ///
  /// In en, this message translates to:
  /// **'Dottoday can\'t remind you until notifications are allowed in your device settings.'**
  String get notifDeniedBody;

  /// Notification permission denied notice button.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get notifOpenSettings;

  /// Snackbar when the app can't open system settings itself.
  ///
  /// In en, this message translates to:
  /// **'Open your device\'s Settings › Notifications › Dottoday and allow notifications.'**
  String get notifSettingsPath;

  /// Sync sheet: 'Last synced 4 min ago · 2 changes waiting to sync'.
  ///
  /// In en, this message translates to:
  /// **'{last} · {pending}'**
  String syncSummary(String last, String pending);

  /// Sync sheet conflict card heading: the task and the detail that differs.
  ///
  /// In en, this message translates to:
  /// **'{title} · {field}'**
  String syncConflictHeading(String title, String field);

  /// Recovery screen title: the database key is missing or wrong.
  ///
  /// In en, this message translates to:
  /// **'Dottoday can\'t open your tasks'**
  String get recoveryLockedTitle;

  /// Recovery screen: why.
  ///
  /// In en, this message translates to:
  /// **'Your tasks on this device are locked with a key that is missing or has changed. This can happen after restoring a device or clearing its keychain.'**
  String get recoveryLockedBody;

  /// Recovery screen: what Start fresh does.
  ///
  /// In en, this message translates to:
  /// **'Start fresh keeps the old file aside (it is never deleted) and opens an empty planner. Your tasks come back when you sign in to sync, or by importing an export.'**
  String get recoveryFreshBody;

  /// Recovery screen button.
  ///
  /// In en, this message translates to:
  /// **'Start fresh'**
  String get recoveryStartFresh;

  /// Recovery screen: inline confirmation after the first tap.
  ///
  /// In en, this message translates to:
  /// **'Start with an empty planner? The old file stays on this device.'**
  String get recoveryConfirm;

  /// Recovery screen: confirm button.
  ///
  /// In en, this message translates to:
  /// **'Yes, start fresh'**
  String get recoveryConfirmYes;

  /// Snackbar after Start fresh.
  ///
  /// In en, this message translates to:
  /// **'Your old file is kept at {where}'**
  String recoveryKept(String where);

  /// Web: the database is in use in another tab.
  ///
  /// In en, this message translates to:
  /// **'Dottoday is open in another tab'**
  String get recoveryTabTitle;

  /// Web: why only one tab.
  ///
  /// In en, this message translates to:
  /// **'To keep your tasks safe, only one tab can use them at a time.'**
  String get recoveryTabBody;

  /// Web: ask the other tab to let go and open here.
  ///
  /// In en, this message translates to:
  /// **'Use it here'**
  String get recoveryUseHere;

  /// Web: this tab handed the database to another tab.
  ///
  /// In en, this message translates to:
  /// **'Dottoday moved to another tab'**
  String get recoveryMovedTitle;

  /// Web: after handing over.
  ///
  /// In en, this message translates to:
  /// **'You chose to use Dottoday in another tab. Your tasks are saved.'**
  String get recoveryMovedBody;

  /// Web: Use it here timed out.
  ///
  /// In en, this message translates to:
  /// **'The other tab didn\'t answer. Close it and try again.'**
  String get recoveryNoAnswer;

  /// Recovery screen: after Start fresh, open the new empty planner.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get recoveryContinue;

  /// Screen reader label of the skeleton shown while a screen loads.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get stateLoading;

  /// Inline error on a screen whose data failed to load.
  ///
  /// In en, this message translates to:
  /// **'This didn\'t load'**
  String get stateErrorTitle;

  /// Inline error: reassurance under the reason.
  ///
  /// In en, this message translates to:
  /// **'Your tasks are safe on this device.'**
  String get stateErrorSafe;

  /// Inline error button.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get stateRetry;

  /// Inline error when a screen could not load from the local database.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read your tasks on this device.'**
  String get stateReadFailed;

  /// Inbox row menu and screen-reader action: start picking several tasks.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get inboxSelect;

  /// Inbox selection bar: place the picked tasks where they first fit this week.
  ///
  /// In en, this message translates to:
  /// **'Plan these'**
  String get inboxPlanThese;

  /// Screen reader: an inbox row that is picked.
  ///
  /// In en, this message translates to:
  /// **'{title}, selected'**
  String inboxSelectedLabel(String title);

  /// Onboarding O1 headline.
  ///
  /// In en, this message translates to:
  /// **'Your day, as a thread.'**
  String get onboardingWelcomeTitle;

  /// Onboarding O1: the one-line value proposition.
  ///
  /// In en, this message translates to:
  /// **'Plan your day as dots on a line, see where the time goes, and move it all when the day moves.'**
  String get onboardingWelcomeBody;

  /// Welcome step, under the buttons: the age gate (docs/06 §6). Wording under owner/legal review (docs/store/age-rating.md).
  ///
  /// In en, this message translates to:
  /// **'Dottoday is for people aged 13 and over.'**
  String get onboardingAgeNote;

  /// Onboarding O1 primary button.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// Onboarding O1: go to sign-in (O5).
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboardingSignIn;

  /// Onboarding: skip this step.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Onboarding: the previous step (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// Onboarding: next step.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// Onboarding progress, read by screen readers.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardingStepOf(int step, int total);

  /// Onboarding O1: label of the animated day dot.
  ///
  /// In en, this message translates to:
  /// **'The day dot, drawing itself'**
  String get onboardingDotLabel;

  /// Onboarding O2 question.
  ///
  /// In en, this message translates to:
  /// **'When does your day start and end?'**
  String get onboardingDayShapeTitle;

  /// Onboarding O2 explanation.
  ///
  /// In en, this message translates to:
  /// **'Your tasks live between these two. You can change them, or give each weekday its own, in Settings.'**
  String get onboardingDayShapeBody;

  /// Onboarding O3 question.
  ///
  /// In en, this message translates to:
  /// **'What fills your days?'**
  String get onboardingHabitsTitle;

  /// Onboarding O3 explanation.
  ///
  /// In en, this message translates to:
  /// **'Pick up to five. They go on tomorrow\'s thread at times that fit your day; change them any time.'**
  String get onboardingHabitsBody;

  /// Onboarding O3 primary button with habits picked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 to tomorrow} other{Add {count} to tomorrow}}'**
  String onboardingHabitsAdd(int count);

  /// Onboarding O3: shown when five are picked.
  ///
  /// In en, this message translates to:
  /// **'Five is plenty to start with.'**
  String get onboardingHabitsMax;

  /// Onboarding starter habit.
  ///
  /// In en, this message translates to:
  /// **'Morning run'**
  String get starterMorningRun;

  /// Onboarding starter habit.
  ///
  /// In en, this message translates to:
  /// **'Deep work'**
  String get starterDeepWork;

  /// Onboarding starter habit.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get starterLunch;

  /// Onboarding starter habit.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get starterWalk;

  /// Onboarding starter habit.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get starterGym;

  /// Onboarding starter habit.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get starterRead;

  /// Onboarding starter habit.
  ///
  /// In en, this message translates to:
  /// **'Plan tomorrow'**
  String get starterPlanTomorrow;

  /// Onboarding O3 row: '7:30 AM · 30 min'.
  ///
  /// In en, this message translates to:
  /// **'{time} · {length}'**
  String onboardingHabitMeta(String time, String length);

  /// Onboarding O4 question.
  ///
  /// In en, this message translates to:
  /// **'Want a nudge?'**
  String get onboardingRemindersTitle;

  /// Onboarding O4 explanation.
  ///
  /// In en, this message translates to:
  /// **'Dottoday reminds you when a task starts and before Wind Down. You can change this any time in Settings.'**
  String get onboardingRemindersBody;

  /// Onboarding O4: the task-start reminder.
  ///
  /// In en, this message translates to:
  /// **'Before each task'**
  String get onboardingTaskStarts;

  /// Onboarding O4: under the task-start reminder.
  ///
  /// In en, this message translates to:
  /// **'How early is up to you, in Settings'**
  String get onboardingTaskStartsDetail;

  /// Onboarding O4: the Wind Down reminder switch.
  ///
  /// In en, this message translates to:
  /// **'At Wind Down'**
  String get onboardingWindDown;

  /// Onboarding O4: under the Wind Down switch.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow\'s first task, so the morning has no surprises'**
  String get onboardingWindDownDetail;

  /// Onboarding O4: asks the system for permission.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get onboardingAllow;

  /// Onboarding O4: go on without asking.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get onboardingNotNow;

  /// Onboarding O5 question.
  ///
  /// In en, this message translates to:
  /// **'Keep your tasks in sync?'**
  String get onboardingAccountTitle;

  /// Onboarding O5 explanation.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use Dottoday on all your devices with a copy kept safe. Or don\'t: everything works on this device without an account.'**
  String get onboardingAccountBody;

  /// Onboarding O5 primary button: local only.
  ///
  /// In en, this message translates to:
  /// **'Continue without an account'**
  String get onboardingWithoutAccount;

  /// Onboarding O6 heading.
  ///
  /// In en, this message translates to:
  /// **'Your first thread'**
  String get onboardingDoneTitle;

  /// Onboarding O6 explanation.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, from Wake Up to Wind Down. Add to it, drag things around, or start with today.'**
  String get onboardingDoneBody;

  /// Onboarding O6 when no habits were picked.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, from Wake Up to Wind Down, is all yours. Add the first task whenever you like.'**
  String get onboardingDoneEmpty;

  /// Onboarding O6 primary button: finishes onboarding.
  ///
  /// In en, this message translates to:
  /// **'Open today'**
  String get onboardingOpenToday;

  /// Onboarding O6: the day card's title.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get onboardingTomorrow;

  /// Onboarding O5 for a returning user.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get onboardingWelcomeBackTitle;

  /// Onboarding O5 for a returning user.
  ///
  /// In en, this message translates to:
  /// **'Sign in to bring your tasks to this device.'**
  String get onboardingWelcomeBackBody;

  /// Sign-in email field label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmailLabel;

  /// Sign in by email: send the magic link.
  ///
  /// In en, this message translates to:
  /// **'Send me a link'**
  String get accountSendLink;

  /// Sign in by email: back to Apple / Google / email.
  ///
  /// In en, this message translates to:
  /// **'Other ways to sign in'**
  String get accountOtherWays;

  /// Sign-in email field error.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like an email address.'**
  String get accountEmailInvalid;

  /// Magic link sent.
  ///
  /// In en, this message translates to:
  /// **'Check your mail'**
  String get accountCheckMailTitle;

  /// Magic link sent: where.
  ///
  /// In en, this message translates to:
  /// **'We sent a sign-in link to {email}. Open it on this device to carry on.'**
  String accountCheckMailBody(String email);

  /// Magic link sent: resend.
  ///
  /// In en, this message translates to:
  /// **'Send it again'**
  String get accountResend;

  /// Magic link sent: back to the email field.
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get accountOtherEmail;

  /// Sign-in error heading.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in'**
  String get accountErrorTitle;

  /// Restore from sync after sign-in.
  ///
  /// In en, this message translates to:
  /// **'Bringing your tasks to this device…'**
  String get accountRestoring;

  /// Restore progress count.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String accountRestoreCount(int done, int total);

  /// Body of an alert some minutes before a task.
  ///
  /// In en, this message translates to:
  /// **'Starts in {minutes, plural, =1{1 minute} other{{minutes} minutes}}'**
  String notifStartsIn(int minutes);

  /// Body of an alert at a task's start.
  ///
  /// In en, this message translates to:
  /// **'Starting now'**
  String get notifStartsNow;

  /// Body of an alert at a task's end.
  ///
  /// In en, this message translates to:
  /// **'Ending now'**
  String get notifEndsNow;

  /// Body of an overdue alert.
  ///
  /// In en, this message translates to:
  /// **'Ended {minutes, plural, =1{1 minute} other{{minutes} minutes}} ago. Done?'**
  String notifOverdue(int minutes);

  /// Body of the reminder a Snooze sets.
  ///
  /// In en, this message translates to:
  /// **'Snoozed reminder'**
  String get notifSnoozed;

  /// Title of the Wind Down reminder.
  ///
  /// In en, this message translates to:
  /// **'Wind Down'**
  String get notifWindDownTitle;

  /// Wind Down reminder body.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow starts with {title} at {time}.'**
  String notifWindDownFirst(String title, String time);

  /// Wind Down reminder body when tomorrow is empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for tomorrow yet.'**
  String get notifWindDownFree;

  /// Notification action: mark the task done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notifActionDone;

  /// Notification action: remind again in 10 minutes.
  ///
  /// In en, this message translates to:
  /// **'Snooze 10 min'**
  String get notifActionSnooze;

  /// Notification action: open the task.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get notifActionOpen;

  /// Android notification channel name.
  ///
  /// In en, this message translates to:
  /// **'Task alerts'**
  String get notifChannelAlerts;

  /// Android channel description.
  ///
  /// In en, this message translates to:
  /// **'Reminders before, at and after your tasks'**
  String get notifChannelAlertsDetail;

  /// Android notification channel name for alarm-loud dot-starts: the day's first task and routine starts (docs/09 M6.5.5).
  ///
  /// In en, this message translates to:
  /// **'Start of your day'**
  String get notifChannelAlarms;

  /// Android channel description for the alarm channel.
  ///
  /// In en, this message translates to:
  /// **'Rings like an alarm for the first task of your day and when a routine starts'**
  String get notifChannelAlarmsDetail;

  /// Android notification channel name.
  ///
  /// In en, this message translates to:
  /// **'Wind Down'**
  String get notifChannelSummary;

  /// Android channel description.
  ///
  /// In en, this message translates to:
  /// **'The nightly look at tomorrow'**
  String get notifChannelSummaryDetail;

  /// In-app reminder banner: the task title and when.
  ///
  /// In en, this message translates to:
  /// **'{title} · {detail}'**
  String inAppAlertText(String title, String detail);

  /// Dismisses the in-app reminder banner.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get inAppAlertLater;

  /// Home-screen widget caption above the next task.
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get widgetNextUp;

  /// Home-screen widget: the task under way.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get widgetNow;

  /// Home-screen widget: when the task under way ends.
  ///
  /// In en, this message translates to:
  /// **'until {time}'**
  String widgetUntil(String time);

  /// Home-screen widget when no task is left.
  ///
  /// In en, this message translates to:
  /// **'Nothing else today'**
  String get widgetNothingNext;

  /// Home-screen widget title for the day's thread.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get widgetToday;

  /// Home-screen widget: how many tasks wait in the Inbox.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Inbox is clear} =1{1 in Inbox} other{{count} in Inbox}}'**
  String widgetInboxCount(int count);

  /// Mac menu bar: File menu.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get menuFile;

  /// Mac menu bar: Edit menu.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuEdit;

  /// Mac menu bar: View menu.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get menuView;

  /// Mac menu bar: Go menu.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get menuGo;

  /// Mac menu bar: Window menu.
  ///
  /// In en, this message translates to:
  /// **'Window'**
  String get menuWindow;

  /// Mac app menu: opens Settings.
  ///
  /// In en, this message translates to:
  /// **'Settings…'**
  String get menuSettings;

  /// Mac File menu: opens Add.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get menuNewTask;

  /// Mac File menu: opens Settings › Export.
  ///
  /// In en, this message translates to:
  /// **'Export…'**
  String get menuExport;

  /// Mac Edit menu: undoes the last change.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get menuUndo;

  /// Mac View menu: the month view.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get menuMonth;

  /// Mac View menu: lists every shortcut.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get menuShortcuts;

  /// Mac Go menu: the day before on Today.
  ///
  /// In en, this message translates to:
  /// **'Previous Day'**
  String get menuPreviousDay;

  /// Mac Go menu: the day after on Today.
  ///
  /// In en, this message translates to:
  /// **'Next Day'**
  String get menuNextDay;

  /// Mac Edit menu: makes the change the last Undo reverted again.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get menuRedo;

  /// Mac Edit menu: moves the picked tasks on Today to Trash (with Undo); in a text field, deletes the selected text.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get menuDelete;

  /// Keyboard shortcut sheet, everywhere: ⌘Z / Ctrl+Z outside a text field (docs/09 M8.6b).
  ///
  /// In en, this message translates to:
  /// **'Undo the last change'**
  String get shortcutUndo;

  /// Keyboard shortcut sheet, everywhere: ⇧⌘Z / Ctrl+Shift+Z outside a text field (docs/09 M8.6b).
  ///
  /// In en, this message translates to:
  /// **'Redo what was undone'**
  String get shortcutRedo;

  /// Settings › Reminders notice when Android doesn't allow exact alarms.
  ///
  /// In en, this message translates to:
  /// **'Reminders may come a few minutes after their time'**
  String get exactTitle;

  /// Rationale for the exact-alarm permission (docs/07 Android).
  ///
  /// In en, this message translates to:
  /// **'To save battery, Android can hold reminders back. Allow exact timing so each one arrives when your task starts.'**
  String get exactBody;

  /// Opens Android's Alarms & reminders screen.
  ///
  /// In en, this message translates to:
  /// **'Allow exact timing'**
  String get exactAllow;

  /// Keyboard link that skips the navigation (web/Mac).
  ///
  /// In en, this message translates to:
  /// **'Skip to content'**
  String get skipToContent;

  /// Web banner offering to install the app (after the 2nd visit).
  ///
  /// In en, this message translates to:
  /// **'Install Dottoday: opens like an app and works offline'**
  String get installText;

  /// Web banner button that installs the app.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get installAction;

  /// Settings › Privacy group caption.
  ///
  /// In en, this message translates to:
  /// **'APP LOCK'**
  String get lockCaption;

  /// Settings switch for the app lock.
  ///
  /// In en, this message translates to:
  /// **'Lock Dottoday'**
  String get lockToggle;

  /// Under the app-lock switch.
  ///
  /// In en, this message translates to:
  /// **'Ask for your face, fingerprint or passcode'**
  String get lockToggleDetail;

  /// Web fallback for app lock (07 Web): a browser can't ask for a face or fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Uses your computer\'s lock'**
  String get lockWebTitle;

  /// Under the web app-lock row.
  ///
  /// In en, this message translates to:
  /// **'In a browser, Dottoday is as locked as your computer. Lock your screen when you step away; tasks stay encrypted in this browser.'**
  String get lockWebDetail;

  /// Settings row: how long before it locks again.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get lockAfter;

  /// Lock-after choice: as soon as the app is left.
  ///
  /// In en, this message translates to:
  /// **'Right away'**
  String get lockAfterNow;

  /// Lock-after choice.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 minute} other{{minutes} minutes}}'**
  String lockAfterMinutes(int minutes);

  /// Shown by the OS in the face/fingerprint/passcode prompt.
  ///
  /// In en, this message translates to:
  /// **'Unlock Dottoday'**
  String get lockReason;

  /// The lock screen.
  ///
  /// In en, this message translates to:
  /// **'Dottoday is locked'**
  String get lockTitle;

  /// Lock screen button.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockUnlock;

  /// Snackbar when turning the lock on fails.
  ///
  /// In en, this message translates to:
  /// **'This device has no passcode, so Dottoday can\'t lock.'**
  String get lockUnavailable;

  /// Travel banner (07, M5.9) when the device's zone differs from the planning zone.
  ///
  /// In en, this message translates to:
  /// **'You\'re now in {city} — keep times or shift?'**
  String zoneBannerText(String city);

  /// Travel banner: 9:00 stays 9:00 in the new zone (the default).
  ///
  /// In en, this message translates to:
  /// **'Keep times'**
  String get zoneKeep;

  /// Travel banner: tasks keep their moment, so clock times move.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get zoneShift;

  /// After Keep times.
  ///
  /// In en, this message translates to:
  /// **'Tasks kept at their times in {city}'**
  String zoneKeptSnack(String city);

  /// After Shift.
  ///
  /// In en, this message translates to:
  /// **'Tasks shifted to {city} time'**
  String zoneShiftedSnack(String city);

  /// How long since the last sync: under a minute (M6.3).
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get syncAgoJustNow;

  /// How long since the last sync, in minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 min ago} other{{minutes} min ago}}'**
  String syncAgoMinutes(int minutes);

  /// How long since the last sync, in hours.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{1 h ago} other{{hours} h ago}}'**
  String syncAgoHours(int hours);

  /// Status line under the Inbox sidebar (A-mac-week-alt3-board).
  ///
  /// In en, this message translates to:
  /// **'Synced · {ago}'**
  String syncLineSynced(String ago);

  /// Status line while syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncLineSyncing;

  /// Status line when the device is offline; nothing is lost.
  ///
  /// In en, this message translates to:
  /// **'Offline · changes saved here'**
  String get syncLineOffline;

  /// Sync sheet and notification health: the device clock is more than 5 min ahead of the server (docs/09 M6.5.7).
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{Your clock is 1 min fast} other{Your clock is {minutes} min fast}} — reminders may be early'**
  String clockFast(int minutes);

  /// Sync sheet and notification health: the device clock is more than 5 min behind the server. No-shame copy: never 'late'.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{Your clock is 1 min slow} other{Your clock is {minutes} min slow}} — reminders may arrive after their time'**
  String clockSlow(int minutes);

  /// Sync sheet, under clockFast: pushes are deferred while the clock is fast (M6.5.7).
  ///
  /// In en, this message translates to:
  /// **'Changes from this device wait until the clock is right; changes from your other devices still arrive.'**
  String get syncClockWaiting;

  /// Settings › Reminders page and row: what decides whether reminders get through (docs/09 M6.5.8).
  ///
  /// In en, this message translates to:
  /// **'Notification health'**
  String get healthTitle;

  /// Caption over the notification health rows.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get healthCaption;

  /// Notification health intro.
  ///
  /// In en, this message translates to:
  /// **'What decides whether your reminders get through on this device, read from its settings right now.'**
  String get healthIntro;

  /// Settings row value: no problem found.
  ///
  /// In en, this message translates to:
  /// **'All good'**
  String get healthAllGood;

  /// Health row: permission granted.
  ///
  /// In en, this message translates to:
  /// **'Notifications are on'**
  String get healthPermissionOk;

  /// Health row: permission not granted.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get healthPermissionOff;

  /// Health row detail.
  ///
  /// In en, this message translates to:
  /// **'Dottoday can\'t remind you until you allow them.'**
  String get healthPermissionOffDetail;

  /// Android: exact alarms allowed.
  ///
  /// In en, this message translates to:
  /// **'Reminders arrive on the minute'**
  String get healthExactOk;

  /// Android: exact alarms not allowed. No-shame: never 'late'.
  ///
  /// In en, this message translates to:
  /// **'Reminders may come a few minutes after their time'**
  String get healthExactOff;

  /// Health row detail.
  ///
  /// In en, this message translates to:
  /// **'Allow “Alarms & reminders” for Dottoday to have them on the minute.'**
  String get healthExactOffDetail;

  /// Android: battery optimisation off for the app.
  ///
  /// In en, this message translates to:
  /// **'Battery saving leaves Dottoday alone'**
  String get healthBatteryOk;

  /// Android: battery optimisation applies.
  ///
  /// In en, this message translates to:
  /// **'Battery saving can hold reminders back'**
  String get healthBatteryOff;

  /// Health row detail; the button opens the system list.
  ///
  /// In en, this message translates to:
  /// **'In the list, choose Dottoday and “Don\'t optimise”.'**
  String get healthBatteryOffDetail;

  /// Android: DND off.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb is off'**
  String get healthDndOff;

  /// Android: DND on (information, not a problem).
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb is on'**
  String get healthDndOn;

  /// Health row detail.
  ///
  /// In en, this message translates to:
  /// **'The first task of your day still rings; other reminders arrive quietly.'**
  String get healthDndOnDetail;

  /// iPhone/Mac: Focus row title.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get healthFocus;

  /// iPhone/Mac: what Focus does to task starts (Focus state can't be read).
  ///
  /// In en, this message translates to:
  /// **'Task starts are time-sensitive, so a Focus that allows time-sensitive notifications lets them through.'**
  String get healthFocusDetail;

  /// Web: push is set up.
  ///
  /// In en, this message translates to:
  /// **'Reminders arrive with the tab closed'**
  String get healthPushOk;

  /// Web: no push yet (information).
  ///
  /// In en, this message translates to:
  /// **'Reminders arrive while Dottoday is open'**
  String get healthPushOff;

  /// Web health row detail.
  ///
  /// In en, this message translates to:
  /// **'Sign in and allow notifications so they also arrive with the tab closed.'**
  String get healthPushOffDetail;

  /// Health row: device clock within 5 minutes of the server.
  ///
  /// In en, this message translates to:
  /// **'Your clock is right'**
  String get healthClockOk;

  /// Health row detail under clockFast/clockSlow.
  ///
  /// In en, this message translates to:
  /// **'Turn on “Set automatically” in your date and time settings.'**
  String get healthClockOffDetail;

  /// Health row button: ask for the permission.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get healthFixAllow;

  /// Health row button: open the system settings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get healthFixOpen;

  /// Settings row value: how many health rows need fixing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thing to fix} other{{count} things to fix}}'**
  String healthToFix(int count);

  /// The test alarm's notification title (docs/09 M6.5.9).
  ///
  /// In en, this message translates to:
  /// **'Test alarm'**
  String get testAlarmTitle;

  /// The test alarm's notification body.
  ///
  /// In en, this message translates to:
  /// **'It got through. Your reminders will too.'**
  String get testAlarmBody;

  /// Caption over the test alarm row (O4, Notification health).
  ///
  /// In en, this message translates to:
  /// **'Check it works'**
  String get testAlarmCaption;

  /// In-app strip: the only action on the test alarm (dismisses it, M6.5.9).
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get inAppAlertOk;

  /// O4 and Notification health: the test alarm row.
  ///
  /// In en, this message translates to:
  /// **'Send me a test alarm'**
  String get testAlarmRow;

  /// Under the test alarm row.
  ///
  /// In en, this message translates to:
  /// **'Check that a reminder really reaches you'**
  String get testAlarmRowDetail;

  /// Owner's copy, shown before the test alarm is scheduled (2026-10-23).
  ///
  /// In en, this message translates to:
  /// **'Dottoday will send one test alarm in 60 seconds so you can check it gets through.'**
  String get testAlarmExplain;

  /// Schedules the test alarm.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get testAlarmSend;

  /// Cancels the test alarm before it rings.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get testAlarmCancel;

  /// After the countdown.
  ///
  /// In en, this message translates to:
  /// **'Did it ring?'**
  String get testAlarmAsk;

  /// It rang.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get testAlarmYes;

  /// It didn't ring.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get testAlarmNo;

  /// After Yes.
  ///
  /// In en, this message translates to:
  /// **'It got through. Your reminders will too.'**
  String get testAlarmGood;

  /// After No, on the Notification health page.
  ///
  /// In en, this message translates to:
  /// **'The checks above show what\'s in the way.'**
  String get testAlarmLookHere;

  /// After No, during onboarding.
  ///
  /// In en, this message translates to:
  /// **'You\'ll find what\'s in the way in Settings › Reminders › Notification health.'**
  String get testAlarmLookLater;

  /// Countdown while waiting for the test alarm.
  ///
  /// In en, this message translates to:
  /// **'Ringing in {seconds} s…'**
  String testAlarmCountdown(int seconds);

  /// Status line after a server error (details in the Sync sheet).
  ///
  /// In en, this message translates to:
  /// **'Sync paused · tap Sync for why'**
  String get syncLinePaused;

  /// Settings header when signed in and synced (A-ios-settings: Kody · synced just now).
  ///
  /// In en, this message translates to:
  /// **'{name} · synced {ago}'**
  String settingsSynced(String name, String ago);

  /// Settings header, signed in, no name.
  ///
  /// In en, this message translates to:
  /// **'Synced {ago}'**
  String settingsSyncedNoName(String ago);

  /// Settings header, signed in, a sync state other than synced.
  ///
  /// In en, this message translates to:
  /// **'{name} · {status}'**
  String settingsNameAndStatus(String name, String status);

  /// Title of an imported calendar event that has none (M7.2).
  ///
  /// In en, this message translates to:
  /// **'Untitled event'**
  String get calendarEventUntitled;

  /// Task sheet and editor: caption over the web links found in the notes (R-02).
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get taskLinks;

  /// Screen-reader hint of a link row in the task sheet.
  ///
  /// In en, this message translates to:
  /// **'Open {host} in the browser'**
  String taskLinkOpen(String host);

  /// Snackbar when the browser couldn't be opened for a link.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that link'**
  String get taskLinkFailed;

  /// Calendars page: caption of the per-calendar write-back switches (M7.3).
  ///
  /// In en, this message translates to:
  /// **'Send changes back'**
  String get calendarsWriteBack;

  /// Calendars page: what turning write-back on does (M7.3).
  ///
  /// In en, this message translates to:
  /// **'Moves, resizes and renames you make here go to the calendar, earlier ones too. Repeating and all-day events change here only.'**
  String get calendarsWriteBackDetail;

  /// Banner when edits of imported events couldn't be written to their calendar (M7.3); action: Try again.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change hasn\'t reached your calendar yet} other{{count} changes haven\'t reached your calendar yet}}'**
  String bannerWriteBackPending(int count);

  /// Banner when an imported event was changed both here and in its calendar (M7.3); actions: Keep mine / Use calendar's.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This event changed in your calendar too} other{{count} events changed in your calendar too}}'**
  String bannerWriteBackClash(int count);

  /// Write-back clash banner: take the calendar's version (M7.3).
  ///
  /// In en, this message translates to:
  /// **'Use calendar\'s'**
  String get bannerUseCalendars;

  /// Editor, imported event: write-back is on for its calendar (M7.3).
  ///
  /// In en, this message translates to:
  /// **'Changes go back to {calendar}'**
  String taskCalendarSends(String calendar);

  /// Editor, imported event: changes are not written to its calendar (write-back off, read-only, repeating or all-day; M7.3).
  ///
  /// In en, this message translates to:
  /// **'From {calendar} · changes stay in Dottoday'**
  String taskCalendarStays(String calendar);

  /// Travel time before a task (M7.5, R-17): the task sheet card caption, the sheet and editor row, the Settings row and its picker title.
  ///
  /// In en, this message translates to:
  /// **'Travel time'**
  String get travelTitle;

  /// Task sheet, an imported event with a place: the travel time suggestion (M7.5). Nothing is written until Add.
  ///
  /// In en, this message translates to:
  /// **'At {place}. Keep {duration} before it for getting there?'**
  String travelSuggestDetail(String place, String duration);

  /// Task sheet travel suggestion: accept, writes the travel time.
  ///
  /// In en, this message translates to:
  /// **'Add {duration} before'**
  String travelSuggestAdd(String duration);

  /// Snackbar after accepting a travel time suggestion (with Undo).
  ///
  /// In en, this message translates to:
  /// **'Travel time added before “{title}”'**
  String travelAdded(String title);

  /// Travel time picker and row: no travel time.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get travelNone;

  /// Travel time row value, e.g. '15 min before'.
  ///
  /// In en, this message translates to:
  /// **'{duration} before'**
  String travelBefore(String duration);

  /// Timeline row meta after the time range when the task has travel time before it, e.g. '15 min travel'.
  ///
  /// In en, this message translates to:
  /// **'· {duration} travel'**
  String rowTravelMeta(String duration);

  /// Screen-reader row label with travel time.
  ///
  /// In en, this message translates to:
  /// **'{label}, {duration} travel time before'**
  String rowTravel(String label, String duration);

  /// Calendars page group caption (M7.5).
  ///
  /// In en, this message translates to:
  /// **'Travel time'**
  String get calendarsTravel;

  /// Calendars page toggle: suggest a travel buffer before events that have a place.
  ///
  /// In en, this message translates to:
  /// **'Suggest travel time'**
  String get calendarsTravelSuggest;

  /// Calendars page toggle subtitle: the suggestion is a fixed length, no route lookup, the place stays on the device.
  ///
  /// In en, this message translates to:
  /// **'Before events with a place. Worked out on this device; no maps are asked'**
  String get calendarsTravelSuggestDetail;

  /// Appended to a row label when the row is an imported calendar event (docs/02 F1.10): the screen-reader side of the calendar badge.
  ///
  /// In en, this message translates to:
  /// **'{label}, from your calendar'**
  String rowFromCalendar(String label);

  /// Task sheet and editor toggle (docs/02 F1.5, F2.9): a pinned task is never moved by shifts, Running late or drags of other tasks.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinTitle;

  /// Subtitle of the Pinned toggle in the task sheet and editor.
  ///
  /// In en, this message translates to:
  /// **'Stays put when other tasks shift'**
  String get pinDetail;

  /// Folded 'outside hours' row above the Wake Up cap (docs/02 F1.15): tasks that end by Wake Up. Tapping unfolds them.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task before Wake Up} other{{count} tasks before Wake Up}}'**
  String threadOutsideBefore(int count);

  /// Folded 'outside hours' row below the Wind Down cap (docs/02 F1.15): tasks that start at Wind Down or later. Tapping unfolds them.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task after Wind Down} other{{count} tasks after Wind Down}}'**
  String threadOutsideAfter(int count);

  /// Keyboard shortcut sheet, Today: ↑ / ↓ pick a task along the day (docs/02 F1.17).
  ///
  /// In en, this message translates to:
  /// **'Pick the previous or next task'**
  String get shortcutPickTask;

  /// Keyboard shortcut sheet, Today: ⌘/Ctrl+↑ / ↓ (docs/02 F1.17).
  ///
  /// In en, this message translates to:
  /// **'Move the picked tasks 5 min earlier or later'**
  String get shortcutNudgeTask;

  /// Keyboard shortcut sheet, Today: Shift+⌘/Ctrl+↑ / ↓ (docs/02 F1.17).
  ///
  /// In en, this message translates to:
  /// **'Move the picked tasks 15 min earlier or later'**
  String get shortcutNudgeTaskMore;

  /// Keyboard shortcut sheet, Today: Delete / Backspace, with Undo (docs/02 F1.17).
  ///
  /// In en, this message translates to:
  /// **'Move the picked tasks to Trash'**
  String get shortcutTrashTask;

  /// Keyboard shortcut sheet, Today: Return opens the one picked task (docs/02 F1.17).
  ///
  /// In en, this message translates to:
  /// **'Open the picked task'**
  String get shortcutOpenTask;

  /// Keyboard shortcut sheet, Today: Space completes the one picked task (docs/02 F1.17).
  ///
  /// In en, this message translates to:
  /// **'Mark the picked task done'**
  String get shortcutDoneTask;

  /// Name of the Delete key as printed on keyboards, in the shortcut sheet (Backspace works too).
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get shortcutKeyDelete;

  /// Name of the Space bar in the shortcut sheet.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get shortcutKeySpace;

  /// Editor field: the optional energy level a task needs (low/medium/high).
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get editorEnergy;

  /// Energy level chip: low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get energyLow;

  /// Energy level chip: medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get energyMedium;

  /// Energy level chip: high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get energyHigh;

  /// Helper under the notes field: the markdown-lite syntax it understands. Keep the ** * - markers as typed.
  ///
  /// In en, this message translates to:
  /// **'**bold**, *italic*, - lists and links work here'**
  String get editorNotesFormat;

  /// Screen-reader name of the Inbox tab when it shows a count badge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Inbox, 1 task} other{Inbox, {count} tasks}}'**
  String navInboxBadge(int count);

  /// Caption of the once-a-day card on Today inviting the person to give Inbox tasks a time. Friendly, never judging.
  ///
  /// In en, this message translates to:
  /// **'Plan your inbox'**
  String get inboxNudgeTitle;

  /// Body of the plan-your-inbox card. Friendly, never judging.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task is waiting in your Inbox. A good moment to give it a time?} other{{count} tasks are waiting in your Inbox. A good moment to give them a time?}}'**
  String inboxNudgeDetail(int count);

  /// Plan-your-inbox card: opens the Inbox.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get inboxNudgeAction;

  /// Settings › Planning switch: the once-a-day card on Today.
  ///
  /// In en, this message translates to:
  /// **'Plan-your-inbox nudge'**
  String get settingsInboxNudge;

  /// Detail under the plan-your-inbox switch.
  ///
  /// In en, this message translates to:
  /// **'Once a day from Wake Up, when the Inbox holds tasks'**
  String get settingsInboxNudgeDetail;

  /// Task starts value when the default set has more than one alert: the first alert, then how many more.
  ///
  /// In en, this message translates to:
  /// **'{first} +{count}'**
  String settingsAlertsMore(String first, int count);

  /// Settings › Reminders row and sheet title: the sound of task reminders.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSound;

  /// Sound choice: the device's own notification sound.
  ///
  /// In en, this message translates to:
  /// **'System sound'**
  String get settingsSoundSystem;

  /// Line at the top of the Sound sheet.
  ///
  /// In en, this message translates to:
  /// **'For task reminders. Tap one to hear it. The first task of the day keeps its alarm.'**
  String get settingsSoundDetail;

  /// Name of a bundled reminder sound: one soft ping.
  ///
  /// In en, this message translates to:
  /// **'Dot'**
  String get soundDot;

  /// Name of a bundled reminder sound: two rising notes.
  ///
  /// In en, this message translates to:
  /// **'Chime'**
  String get soundChime;

  /// Name of a bundled reminder sound: a small bell.
  ///
  /// In en, this message translates to:
  /// **'Bell'**
  String get soundBell;

  /// Name of a bundled reminder sound: three quick notes.
  ///
  /// In en, this message translates to:
  /// **'Ripple'**
  String get soundRipple;

  /// Name of a bundled sound (docs/12): the Dottoday alarm chime.
  ///
  /// In en, this message translates to:
  /// **'Dot alarm'**
  String get soundDotAlarm;

  /// Name of a bundled sound (docs/12): a quick soft click.
  ///
  /// In en, this message translates to:
  /// **'Slip'**
  String get soundQuietSlip;

  /// Name of a bundled sound (docs/12): a very soft tone.
  ///
  /// In en, this message translates to:
  /// **'Whisper'**
  String get soundQuietWhisper;

  /// Name of a bundled sound (docs/12): a short gentle tone.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get soundQuietSoft;

  /// Name of a bundled sound (docs/12): a bubble rising.
  ///
  /// In en, this message translates to:
  /// **'Bubble'**
  String get soundQuietBubble;

  /// Name of a bundled sound (docs/12): a short pull sound.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get soundQuietPull;

  /// Name of a bundled sound (docs/12): a light, rising melody.
  ///
  /// In en, this message translates to:
  /// **'Lift'**
  String get soundClearLift;

  /// Name of a bundled sound (docs/12): a joyful chime.
  ///
  /// In en, this message translates to:
  /// **'Bright'**
  String get soundClearBright;

  /// Name of a bundled sound (docs/12): a cheerful short tune.
  ///
  /// In en, this message translates to:
  /// **'Smile'**
  String get soundClearSmile;

  /// Name of a bundled sound (docs/12): a relaxed melody.
  ///
  /// In en, this message translates to:
  /// **'Ease'**
  String get soundClearEase;

  /// Name of a bundled sound (docs/12): a short 'your turn' tone.
  ///
  /// In en, this message translates to:
  /// **'Turn'**
  String get soundClearTurn;

  /// Name of a bundled sound (docs/12): a calm, sure melody.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get soundClearSettled;

  /// Name of a bundled sound (docs/12): a quick bright tone.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get soundClearQuick;

  /// Name of a bundled sound (docs/12): an opening phrase.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get soundClearOpening;

  /// Name of a bundled sound (docs/12): a magical sparkle.
  ///
  /// In en, this message translates to:
  /// **'Spark'**
  String get soundClearSpark;

  /// Name of a bundled sound (docs/12): a melody that grows.
  ///
  /// In en, this message translates to:
  /// **'Emerge'**
  String get soundClearEmerge;

  /// Name of a bundled sound (docs/12): an elegant chime.
  ///
  /// In en, this message translates to:
  /// **'Elegant'**
  String get soundClearElegant;

  /// Name of a bundled sound (docs/12): a steady, willing tone.
  ///
  /// In en, this message translates to:
  /// **'Dutiful'**
  String get soundClearDutiful;

  /// Name of a bundled sound (docs/12): a short lively tone.
  ///
  /// In en, this message translates to:
  /// **'Involved'**
  String get soundClearInvolved;

  /// Name of a bundled sound (docs/12): a tone out of nowhere.
  ///
  /// In en, this message translates to:
  /// **'Appear'**
  String get soundClearAppear;

  /// Name of a bundled sound (docs/12): a confident tap.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get soundClearTap;

  /// Name of a bundled sound (docs/12): a good-morning alarm.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get soundStartMorning;

  /// Name of a bundled sound (docs/12): soft bells, for waking.
  ///
  /// In en, this message translates to:
  /// **'Soft bells'**
  String get soundStartBells;

  /// Name of a bundled sound (docs/12): a slow sunrise alarm.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get soundStartSunrise;

  /// Name of a bundled sound (docs/12): a solemn alarm.
  ///
  /// In en, this message translates to:
  /// **'Solemn'**
  String get soundStartSolemn;

  /// Name of a bundled sound (docs/12): a firm striking alarm.
  ///
  /// In en, this message translates to:
  /// **'Strike'**
  String get soundStartStrike;

  /// Name of a bundled sound (docs/12): a swinging alarm.
  ///
  /// In en, this message translates to:
  /// **'Swing'**
  String get soundStartSwing;

  /// Name of a bundled sound (docs/12): a tender alarm.
  ///
  /// In en, this message translates to:
  /// **'Lovingly'**
  String get soundStartLovingly;

  /// Name of a bundled sound (docs/12): a gentle alarm.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get soundStartGentle;

  /// Name of a bundled sound (docs/12): a loud repeating alarm.
  ///
  /// In en, this message translates to:
  /// **'Insistent'**
  String get soundStartInsistent;

  /// Name of a bundled sound (docs/12): a single soft bell, repeating slowly.
  ///
  /// In en, this message translates to:
  /// **'Slow bell'**
  String get soundStartSlowBell;

  /// Name of a bundled sound (docs/12): a slow, gentle music box.
  ///
  /// In en, this message translates to:
  /// **'Music box'**
  String get soundStartMusicBox;

  /// Name of a bundled sound (docs/12): birdsong at first light, a recording.
  ///
  /// In en, this message translates to:
  /// **'Dawn chorus'**
  String get soundStartDawnChorus;

  /// Name of a bundled sound (docs/12): light rain on leaves.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get soundStartRain;

  /// Name of a bundled sound (docs/12): a small brook, close up.
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get soundStartStream;

  /// Name of a bundled sound (docs/12): a calm shoreline.
  ///
  /// In en, this message translates to:
  /// **'Waves'**
  String get soundStartWaves;

  /// Name of a bundled sound (docs/12): soft chimes in a light breeze.
  ///
  /// In en, this message translates to:
  /// **'Wind chimes'**
  String get soundStartWindChimes;

  /// Name of a bundled sound (docs/12): a forest morning with distant birds.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get soundStartForest;

  /// Name of a bundled sound (docs/12): a mechanical alarm-clock bell.
  ///
  /// In en, this message translates to:
  /// **'Clock bell'**
  String get soundStartClockBell;

  /// Name of a bundled sound (docs/12): a digital beep that gets louder.
  ///
  /// In en, this message translates to:
  /// **'Beep rise'**
  String get soundStartBeepRise;

  /// Name of a bundled sound (docs/12): a rooster crowing.
  ///
  /// In en, this message translates to:
  /// **'Rooster'**
  String get soundPlayRooster;

  /// Name of a bundled sound (docs/12): a horse whinnying.
  ///
  /// In en, this message translates to:
  /// **'Horse'**
  String get soundPlayHorse;

  /// Name of a bundled sound (docs/12): a knock at the door.
  ///
  /// In en, this message translates to:
  /// **'Knock'**
  String get soundPlayKnock;

  /// Name of a bundled sound (docs/12): a little chick.
  ///
  /// In en, this message translates to:
  /// **'Chick'**
  String get soundPlayChick;

  /// Name of a bundled sound (docs/12): a bullfrog.
  ///
  /// In en, this message translates to:
  /// **'Frog'**
  String get soundPlayFrog;

  /// Name of a bundled sound (docs/12): a dog barking.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get soundPlayDog;

  /// Name of a bundled sound (docs/12): seagulls.
  ///
  /// In en, this message translates to:
  /// **'Gulls'**
  String get soundPlayGulls;

  /// Name of a bundled sound (docs/12): a short drum roll.
  ///
  /// In en, this message translates to:
  /// **'Drum'**
  String get soundPlayDrum;

  /// Name of a bundled sound (docs/12): a swift gesture sound.
  ///
  /// In en, this message translates to:
  /// **'Swift'**
  String get soundDoneSwift;

  /// Name of a bundled sound (docs/12): a tick-off sound.
  ///
  /// In en, this message translates to:
  /// **'Checked'**
  String get soundDoneChecked;

  /// Name of a bundled sound (docs/12): a job-done sound.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get soundDoneDone;

  /// Name of a bundled sound (docs/12): a work-is-done sound.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get soundDoneFinished;

  /// Name of a bundled sound (docs/12): a success sound.
  ///
  /// In en, this message translates to:
  /// **'Succeeded'**
  String get soundDoneSucceeded;

  /// Name of a bundled sound (docs/12): an achievement sound.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get soundDoneAchieved;

  /// Android notification channel name for the alarm-loud first task with one Start sound.
  ///
  /// In en, this message translates to:
  /// **'Start of your day · {sound}'**
  String notifChannelAlarmsSound(String sound);

  /// Android notification channel name for task alerts set to None: they vibrate and show, without a sound.
  ///
  /// In en, this message translates to:
  /// **'Task alerts · No sound'**
  String get notifChannelAlertsSilent;

  /// Android notification channel group: every task-reminder channel, one per sound.
  ///
  /// In en, this message translates to:
  /// **'Dot reminders'**
  String get notifGroupDots;

  /// Android notification channel group: the alarm-loud first-task channels, one per Start sound.
  ///
  /// In en, this message translates to:
  /// **'Start of day'**
  String get notifGroupStart;

  /// Notification health row when no reminder sound in use is muted in Android's settings.
  ///
  /// In en, this message translates to:
  /// **'Reminder sounds are on'**
  String get healthSoundsOk;

  /// Notification health row: reminder sounds in use whose Android channel the user muted; {names} is a list like 'Lift, Rooster'.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The sound for {names} is muted in system settings} other{The sounds for {names} are muted in system settings}}'**
  String healthSoundsMuted(int count, String names);

  /// Notification health: how to fix a muted reminder sound.
  ///
  /// In en, this message translates to:
  /// **'Open Dottoday\'s notification settings and turn the sound back on.'**
  String get healthSoundsMutedDetail;

  /// Settings › Reminders › Sounds page title (docs/12 §6).
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get soundsTitle;

  /// Sounds page: line at the top.
  ///
  /// In en, this message translates to:
  /// **'Task reminders play this, unless a task has its own. Tap one to hear it.'**
  String get soundsIntro;

  /// Sounds page: caption of the default-sound list.
  ///
  /// In en, this message translates to:
  /// **'Task reminders'**
  String get soundsTaskCaption;

  /// Sound picker row: no sound (the reminder still shows and vibrates).
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get soundNone;

  /// Sound picker: subtitle of None.
  ///
  /// In en, this message translates to:
  /// **'Shows and vibrates, without a sound'**
  String get soundNoneDetail;

  /// Sound picker section: short, soft sounds.
  ///
  /// In en, this message translates to:
  /// **'Quiet'**
  String get soundSectionQuiet;

  /// Sound picker section: short melodies.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get soundSectionClear;

  /// Sound picker section: animals and objects.
  ///
  /// In en, this message translates to:
  /// **'Playful'**
  String get soundSectionPlayful;

  /// Sounds page: caption over the Start sound and Done sound rows.
  ///
  /// In en, this message translates to:
  /// **'Also'**
  String get soundsMoreCaption;

  /// Sounds page row and sheet title: the alarm-loud first task's sound.
  ///
  /// In en, this message translates to:
  /// **'Start sound'**
  String get soundsStart;

  /// Sounds page: what the Start sound is for.
  ///
  /// In en, this message translates to:
  /// **'Rings for the first task of your day and when a routine starts'**
  String get soundsStartDetail;

  /// Sounds page row and sheet title: the sound when a task is ticked done.
  ///
  /// In en, this message translates to:
  /// **'Done sound'**
  String get soundsDone;

  /// Sounds page: what the Done sound is for.
  ///
  /// In en, this message translates to:
  /// **'When you tick a task done'**
  String get soundsDoneDetail;

  /// Sounds page switch: the app's own sounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds in app'**
  String get soundsInApp;

  /// Sounds in app switch subtitle: what it covers (previews always play).
  ///
  /// In en, this message translates to:
  /// **'The Done sound and the Focus tick'**
  String get soundsInAppDetail;

  /// Sounds page: caption over the Sounds in app and Haptics in app switches.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundsEffectsCaption;

  /// Sounds page switch: the app's own haptic taps (docs/12 §2.6).
  ///
  /// In en, this message translates to:
  /// **'Haptics in app'**
  String get soundsHapticsInApp;

  /// Haptics in app switch subtitle: what it covers.
  ///
  /// In en, this message translates to:
  /// **'Taps you feel as you drag, drop and tick a task done'**
  String get soundsHapticsInAppDetail;

  /// Sounds page: note under the Sound effects switches (the OS can still mute or turn off haptics).
  ///
  /// In en, this message translates to:
  /// **'Sounds and haptics may not play, depending on your device\'s settings.'**
  String get soundsEffectsFooter;

  /// Start sound list: caption under Insistent (never 'annoying', docs/12 §2.3).
  ///
  /// In en, this message translates to:
  /// **'Loud and repeating. Use it if quieter sounds don\'t reach you.'**
  String get soundInsistentNote;

  /// Sounds page banner while the device's ringer is silent (docs/12 §6; no exclamation mark).
  ///
  /// In en, this message translates to:
  /// **'Your device is muted — you may still get vibration'**
  String get soundsMuted;

  /// Sounds page footer: the one credit line per source (docs/12 §1); {source} is a link.
  ///
  /// In en, this message translates to:
  /// **'Sounds from {source} ({license}).'**
  String soundsCredit(String source, String license);

  /// Task Sound row value when the task uses the default, e.g. 'Default · Dot'.
  ///
  /// In en, this message translates to:
  /// **'Default · {sound}'**
  String soundDefault(String sound);

  /// Task sound picker row: use the default sound.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get soundDefaultOption;

  /// Task sheet and editor row: the task's reminder sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sheetSound;

  /// Settings › Reminders switch: quiet hours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get settingsQuietHours;

  /// Quiet hours subtitle while off.
  ///
  /// In en, this message translates to:
  /// **'Reminders arrive silently at night'**
  String get settingsQuietHoursOff;

  /// Quiet hours subtitle while on, with the window.
  ///
  /// In en, this message translates to:
  /// **'{from}–{until}: reminders arrive silently. The first task of the day still rings.'**
  String settingsQuietHoursOn(String from, String until);

  /// Quiet hours start row.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get settingsQuietFrom;

  /// Quiet hours end row.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get settingsQuietUntil;

  /// Settings › Reminders row and sheet title: the day-start summary notification.
  ///
  /// In en, this message translates to:
  /// **'Day-start summary'**
  String get settingsDaySummary;

  /// Day-start summary value when no weekday has it.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsDaySummaryOff;

  /// Line at the top of the Day-start summary sheet: what it says and when.
  ///
  /// In en, this message translates to:
  /// **'At Wake Up on the days you choose: “Your day: 6 blocks, first at 08:00”.'**
  String get settingsDaySummaryDetail;

  /// Title of the day-start summary notification.
  ///
  /// In en, this message translates to:
  /// **'Your day'**
  String get notifDaySummaryTitle;

  /// Body of the day-start summary notification: how many blocks today and when the first starts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 block, at {time}} other{{count} blocks, first at {time}}}'**
  String notifDaySummaryBody(int count, String time);

  /// Android notification channel name for task alerts with one bundled sound.
  ///
  /// In en, this message translates to:
  /// **'Task alerts · {sound}'**
  String notifChannelAlertsSound(String sound);

  /// Live Activity / ongoing notification: time left of the task under way; {time} is a live countdown the system draws (e.g. 37:59).
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String liveActivityLeft(String time);

  /// Live Activity / ongoing notification: the next task, starting within the hour; {time} is a live countdown.
  ///
  /// In en, this message translates to:
  /// **'starts in {time}'**
  String liveActivityStartsIn(String time);

  /// Live Activity: today's tasks done so far, next to a small pie, e.g. '1 of 3'.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String liveActivityCount(int done, int total);

  /// Screen-reader label for liveActivityCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done today'**
  String liveActivityCountLabel(int done, int total);

  /// Privacy page heading: where Break it down and other suggestions are worked out (docs/09 M10.1, ADR-0009).
  ///
  /// In en, this message translates to:
  /// **'Help with thinking'**
  String get privacyThinkingTitle;

  /// Privacy page text: the on-device model paths and the rules fallback; no server.
  ///
  /// In en, this message translates to:
  /// **'Break it down and suggestions are worked out on this device: Apple Intelligence on iPhone and Mac, Gemini Nano on Android, the browser\'s built-in model in Chrome. Where none is available, Dottoday uses your own history and simple rules. What you type is never sent to a server; what was asked and answered stays on this device.'**
  String get privacyThinkingBody;

  /// Privacy page line: an on-device model is ready on this device now.
  ///
  /// In en, this message translates to:
  /// **'On this device now: the built-in model.'**
  String get privacyThinkingOnDevice;

  /// Privacy page line: no on-device model here, so history and rules answer.
  ///
  /// In en, this message translates to:
  /// **'On this device now: your history and simple rules.'**
  String get privacyThinkingRules;

  /// Privacy page button: forgets saved breakdowns and the local log of what was asked and answered.
  ///
  /// In en, this message translates to:
  /// **'Clear thinking history'**
  String get privacyClearThinking;

  /// Snackbar after Clear thinking history.
  ///
  /// In en, this message translates to:
  /// **'Thinking history cleared'**
  String get snackThinkingCleared;

  /// Proposal sheet primary button (11 B3, B-ios-break-it-down).
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get proposalAccept;

  /// Proposal sheet secondary button: closes without writing anything.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get proposalDiscard;

  /// Proposal sheet footer under Discard (11 B3).
  ///
  /// In en, this message translates to:
  /// **'Nothing is saved until you accept'**
  String get proposalNothingSaved;

  /// Proposal change list legend: the faded dots are the day as it is (B-ios-rebalance).
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get proposalLegendNow;

  /// Proposal change list legend: the outlined dots are the proposed day.
  ///
  /// In en, this message translates to:
  /// **'proposed'**
  String get proposalLegendProposed;

  /// Change chip: the task starts later by {duration} (e.g. '25 min').
  ///
  /// In en, this message translates to:
  /// **'shifted +{duration}'**
  String proposalShiftedLater(String duration);

  /// Change chip: the task starts earlier by {duration}.
  ///
  /// In en, this message translates to:
  /// **'shifted −{duration}'**
  String proposalShiftedEarlier(String duration);

  /// Change chip: the task is shorter, now {duration}.
  ///
  /// In en, this message translates to:
  /// **'shrunk to {duration}'**
  String proposalShrunk(String duration);

  /// Change chip: the task is longer, now {duration}.
  ///
  /// In en, this message translates to:
  /// **'grown to {duration}'**
  String proposalGrown(String duration);

  /// Change chip: the task moves to another day, e.g. 'tomorrow 9:00'.
  ///
  /// In en, this message translates to:
  /// **'moved to {when}'**
  String proposalMovedTo(String when);

  /// Change chip: the task goes back to the Inbox.
  ///
  /// In en, this message translates to:
  /// **'moved to Inbox'**
  String get proposalMovedToInbox;

  /// Change chip: a new task the proposal adds.
  ///
  /// In en, this message translates to:
  /// **'new'**
  String get proposalAdded;

  /// Change chip: a pinned task that stays where it is.
  ///
  /// In en, this message translates to:
  /// **'pinned · untouched'**
  String get proposalUntouched;

  /// Change chip: the task gains {count} steps (Break it down).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String proposalSteps(int count);

  /// Proposal change list when every line was removed or nothing needs to change.
  ///
  /// In en, this message translates to:
  /// **'Nothing to change'**
  String get proposalNothing;

  /// Screen-reader label of the × on a change line: drops that change, the task stays as it is.
  ///
  /// In en, this message translates to:
  /// **'Keep {title} as it is'**
  String proposalKeep(String title);

  /// A day and a time in a change chip, e.g. 'tomorrow 9:00' in 'moved to tomorrow 9:00'.
  ///
  /// In en, this message translates to:
  /// **'{day} {time}'**
  String proposalDayTime(String day, String time);

  /// Step row chip when the step has no length yet (11 B2, M10.3).
  ///
  /// In en, this message translates to:
  /// **'+ time'**
  String get stepLengthAdd;

  /// Screen-reader hint of a step's length chip.
  ///
  /// In en, this message translates to:
  /// **'Change how long {title} takes'**
  String stepLengthHint(String title);

  /// Title of the sheet that picks a step's length.
  ///
  /// In en, this message translates to:
  /// **'How long is this step?'**
  String get stepLengthTitle;

  /// Option in the step length sheet: the step has no length.
  ///
  /// In en, this message translates to:
  /// **'No time'**
  String get stepLengthNone;

  /// Editor switch under DURATION: the task's length follows the sum of its steps (11 B2).
  ///
  /// In en, this message translates to:
  /// **'Length = sum of steps'**
  String get editorStepsSum;

  /// Under the switch: what the steps add up to.
  ///
  /// In en, this message translates to:
  /// **'Steps add up to {duration}'**
  String editorStepsSumTotal(String duration);

  /// Under the switch when no step has a length yet.
  ///
  /// In en, this message translates to:
  /// **'Give a step a time to use this'**
  String get editorStepsSumEmpty;

  /// Button in Add step 1 and the task sheet that opens Break it down (11 B1, M10.4).
  ///
  /// In en, this message translates to:
  /// **'Break it down'**
  String get breakdownAction;

  /// Origin chip: the steps came from the on-device model (B-ios-break-it-down).
  ///
  /// In en, this message translates to:
  /// **'on-device'**
  String get breakdownOnDevice;

  /// Origin chip: the steps are the user's usual breakdown for this title.
  ///
  /// In en, this message translates to:
  /// **'your usual'**
  String get breakdownUsual;

  /// Hint in an empty step's title field.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String breakdownStepHint(int number);

  /// Dashed button under the steps: adds an empty step.
  ///
  /// In en, this message translates to:
  /// **'Add a step'**
  String get breakdownAddStep;

  /// Caption under sub-steps: how deep they are, of at most 3.
  ///
  /// In en, this message translates to:
  /// **'depth {depth} of {max}'**
  String breakdownDepth(int depth, int max);

  /// Under an expanded step: split it into sub-steps.
  ///
  /// In en, this message translates to:
  /// **'Break this down'**
  String get breakdownSplit;

  /// Under an expanded step: removes it from the proposal.
  ///
  /// In en, this message translates to:
  /// **'Remove step'**
  String get breakdownRemove;

  /// Screen-reader label of a step's chevron: shows its sub-steps and actions.
  ///
  /// In en, this message translates to:
  /// **'More for {title}'**
  String breakdownShow(String title);

  /// Under the steps: their total and that the task grows to fit.
  ///
  /// In en, this message translates to:
  /// **'Total {duration} · the dot grows to fit'**
  String breakdownTotal(String duration);

  /// Note under the total: Smallest step will ask only for the first step if the task stays unstarted (11 B2).
  ///
  /// In en, this message translates to:
  /// **'You\'ll be asked for the first step only if this stays unstarted (Smallest step)'**
  String get breakdownSmallest;

  /// Task row in Break it down: its length before and after the steps.
  ///
  /// In en, this message translates to:
  /// **'was {before} → now {after}'**
  String breakdownWasNow(String before, String after);

  /// A sub-step's title as it is saved: its parent step, then itself (steps are a flat list).
  ///
  /// In en, this message translates to:
  /// **'{parent} · {step}'**
  String breakdownJoin(String parent, String step);

  /// Undo snackbar after accepting a breakdown.
  ///
  /// In en, this message translates to:
  /// **'Steps added to {title}'**
  String breakdownAccepted(String title);

  /// Add step 1 line once steps were accepted (they are saved with the task).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}} · saved with the task'**
  String breakdownStepsOnDraft(int count);

  /// Focus screen's top bar title, shown in capitals (B-ios-focus, 11 A3).
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusTitle;

  /// Focus screen's back link to Today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get focusBack;

  /// Under the ring: the dot's planned time and length, e.g. '9:00 – 11:00 · 2 h'.
  ///
  /// In en, this message translates to:
  /// **'{range} · {length}'**
  String focusRange(String range, String length);

  /// Step card label, shown in capitals: which step of how many.
  ///
  /// In en, this message translates to:
  /// **'Step {number} of {total}'**
  String focusStep(int number, int total);

  /// Step card when every step is ticked.
  ///
  /// In en, this message translates to:
  /// **'Every step done'**
  String get focusAllSteps;

  /// Focus toggle: a soft sound every 15 minutes while Focus is open (off by default).
  ///
  /// In en, this message translates to:
  /// **'Chime every 15 min'**
  String get focusChime;

  /// Focus toggle: quiet the device while this dot runs (B-ios-focus 'Deep work · Focus on').
  ///
  /// In en, this message translates to:
  /// **'Deep work · Focus on'**
  String get focusDeepWork;

  /// Under the Deep work toggle on Android when Dottoday may not change Do Not Disturb yet.
  ///
  /// In en, this message translates to:
  /// **'Allow Dottoday to turn on Do Not Disturb'**
  String get focusDeepWorkAccess;

  /// Sheet title when Deep work is tapped on iPhone or Mac.
  ///
  /// In en, this message translates to:
  /// **'Turn on Focus with Shortcuts'**
  String get focusShortcutsTitle;

  /// Sheet text: apps can't switch Focus on Apple devices; how to do it with a shortcut.
  ///
  /// In en, this message translates to:
  /// **'iPhone and Mac don\'t let apps switch Focus. In Shortcuts, make a shortcut with Dottoday\'s Start focus and Set Focus, and run it from the Action button, Control Center or Siri.'**
  String get focusShortcutsBody;

  /// Button in the Shortcuts sheet.
  ///
  /// In en, this message translates to:
  /// **'Open Shortcuts'**
  String get focusShortcutsOpen;

  /// Under the Deep work row on the web: the browser can't change it.
  ///
  /// In en, this message translates to:
  /// **'Use your computer\'s Do Not Disturb; the browser can\'t change it'**
  String get focusDeepWorkWeb;

  /// Focus button: ticks the current step and moves to the next.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get focusNextStep;

  /// Focus footer: the next dot's start still comes through.
  ///
  /// In en, this message translates to:
  /// **'Dot starts still break through Focus (time-sensitive)'**
  String get focusBreakThrough;

  /// Focus top bar ⋯ menu tooltip.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get focusMore;

  /// Focus ⋯ menu item: opens the task's details.
  ///
  /// In en, this message translates to:
  /// **'Task details'**
  String get focusOpenTask;

  /// Undo snackbar after Done in Focus.
  ///
  /// In en, this message translates to:
  /// **'{title} done'**
  String focusDoneMessage(String title);

  /// Undo snackbar after +15 min in Focus.
  ///
  /// In en, this message translates to:
  /// **'{title} · 15 min more'**
  String focusExtendedMessage(String title);

  /// Screen-reader hint on the live dot: one tap opens Focus.
  ///
  /// In en, this message translates to:
  /// **'Open Focus'**
  String get focusOpenHint;

  /// Smallest step reminder and row (11 B2, M10.6): only the first step, with its length.
  ///
  /// In en, this message translates to:
  /// **'Just {step} · {length}?'**
  String smallestStepTitle(String step, String length);

  /// Smallest step reminder and row when the first step has no length.
  ///
  /// In en, this message translates to:
  /// **'Just {step}?'**
  String smallestStepTitleShort(String step);

  /// Smallest step's one button (reminder and row): starts the task in Focus.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get smallestStepStart;

  /// Unstick row under a task moved 3 times with no steps (11 B3, M10.7). Never a modal.
  ///
  /// In en, this message translates to:
  /// **'What\'s the very first thing you\'d physically do?'**
  String get unstickPrompt;

  /// Hint in the Unstick row's one-line field.
  ///
  /// In en, this message translates to:
  /// **'e.g. Open the folder'**
  String get unstickHint;

  /// Screen-reader label of the Unstick row's send button: the answer becomes step 1.
  ///
  /// In en, this message translates to:
  /// **'Make it step 1'**
  String get unstickSave;

  /// Undo snackbar after the Unstick answer became step 1.
  ///
  /// In en, this message translates to:
  /// **'Step 1 added to {title}'**
  String unstickSaved(String title);

  /// Rebalance proposal's Accept (B-ios-rebalance).
  ///
  /// In en, this message translates to:
  /// **'Accept plan'**
  String get rebalanceAccept;

  /// Under Rebalance's buttons.
  ///
  /// In en, this message translates to:
  /// **'Nothing moves until you accept · Undo for 30 s after'**
  String get rebalanceFootnote;

  /// Rebalance rule chip: later tasks keep their gaps and move by the delay.
  ///
  /// In en, this message translates to:
  /// **'Shift followers'**
  String get rebalanceShiftFollowers;

  /// Rebalance rule chip: optional tasks may get shorter.
  ///
  /// In en, this message translates to:
  /// **'Allow shrinking optional'**
  String get rebalanceAllowShrink;

  /// Rebalance rule chip: let the day run past Wind Down instead of moving tasks to tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Push past Wind Down'**
  String get rebalancePastWindDown;

  /// Rebalance subtitle after a task overran its end.
  ///
  /// In en, this message translates to:
  /// **'{title} ran over by {duration} · here\'s a plan'**
  String rebalanceRanOver(String title, String duration);

  /// Rebalance subtitle from Running late.
  ///
  /// In en, this message translates to:
  /// **'The rest of today, {duration} later · here\'s a plan'**
  String rebalanceLate(String duration);

  /// Rebalance subtitle from Shift the rest on a task under way.
  ///
  /// In en, this message translates to:
  /// **'{title} runs {duration} over · here\'s a plan'**
  String rebalanceRunsOver(String title, String duration);

  /// Snackbar with Undo after Rebalance's Accept.
  ///
  /// In en, this message translates to:
  /// **'Plan accepted'**
  String get rebalanceAccepted;

  /// Today prompt caption when an imported event moved later and now collides with the plan.
  ///
  /// In en, this message translates to:
  /// **'Calendar changed'**
  String get calendarMovedTitle;

  /// Today prompt after the calendar moved an event later today.
  ///
  /// In en, this message translates to:
  /// **'{title} moved to {time} · Rebalance?'**
  String calendarMovedDetail(String title, String time);

  /// Button: open the Rebalance proposal for a calendar move.
  ///
  /// In en, this message translates to:
  /// **'Rebalance'**
  String get calendarMovedAction;

  /// Rebalance subtitle after the calendar moved an event.
  ///
  /// In en, this message translates to:
  /// **'{title} moved to {time} · here\'s a plan'**
  String rebalanceMoved(String title, String time);

  /// Reality thread: what follows a row's real times, e.g. '· planned 7:30'.
  ///
  /// In en, this message translates to:
  /// **'· {text}'**
  String realityMetaJoin(String text);

  /// Reality thread: when the plan had a task, after its real times. Never judgemental (no 'late').
  ///
  /// In en, this message translates to:
  /// **'planned {time}'**
  String realityPlanned(String time);

  /// Reality thread: a task with no real start yet.
  ///
  /// In en, this message translates to:
  /// **'not started yet'**
  String get realityNotStarted;

  /// Reality thread: how long a finished task really took.
  ///
  /// In en, this message translates to:
  /// **'took {duration}'**
  String realityTook(String duration);

  /// Reality thread: how long the task under way has run.
  ///
  /// In en, this message translates to:
  /// **'{duration} in'**
  String realityRunning(String duration);

  /// Reality thread: the open end of the task under way, e.g. '9:10 – now'.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get realityNow;

  /// Day card toggle: the planned thread.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get realityPlan;

  /// Day card toggle: what really happened (actual start and end times).
  ///
  /// In en, this message translates to:
  /// **'Reality'**
  String get realityReality;

  /// Add: a task's usual real length from the user's history (11 C3). Plain, never judgemental.
  ///
  /// In en, this message translates to:
  /// **'usually {duration}'**
  String learnUsually(String duration);

  /// Add: the user usually starts this task this much after its planned time. Never 'late'.
  ///
  /// In en, this message translates to:
  /// **'usually starts ~{minutes} min after plan'**
  String learnStartsAfter(int minutes);

  /// Add: the user usually starts this task this much before its planned time.
  ///
  /// In en, this message translates to:
  /// **'usually starts ~{minutes} min before plan'**
  String learnStartsBefore(int minutes);

  /// Reality thread insight strip: what the history says about the task under way.
  ///
  /// In en, this message translates to:
  /// **'{title} usually takes you {duration} · Add will suggest it'**
  String learnInsight(String title, String duration);

  /// Puts the insight strip away.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get learnInsightOk;

  /// Today's card, under the header, before the reality thread is ready (docs/13 §4.2). A promise; never 'late'.
  ///
  /// In en, this message translates to:
  /// **'Your reality thread appears after about {total} finished tasks · {done} so far'**
  String learnCaption(int total, int done);

  /// Screen-reader label of the × beside the learning caption.
  ///
  /// In en, this message translates to:
  /// **'Hide until tomorrow'**
  String get learnCaptionHide;

  /// Announced once to screen readers when the Plan / Reality toggle first appears (docs/13 §4.3).
  ///
  /// In en, this message translates to:
  /// **'Plan and reality view is now in the day header'**
  String get learnRealityReady;

  /// Under Today's header in the Reality view on a day with no real start yet: the plan is shown as it is. Plain, never 'late'.
  ///
  /// In en, this message translates to:
  /// **'nothing started yet today'**
  String get realityNothingStartedToday;

  /// How a learned value was worked out, shown on tap (docs/13 §6).
  ///
  /// In en, this message translates to:
  /// **'based on your last {count, plural, one{time} other{{count} times}} · median'**
  String learnBasedOn(int count);

  /// How the energy window was worked out, shown on tap.
  ///
  /// In en, this message translates to:
  /// **'based on your last {count} finished high-energy tasks · where most started'**
  String learnEnergyBasedOn(int count);

  /// Screen-reader label of a learned value (docs/13 §6).
  ///
  /// In en, this message translates to:
  /// **'{value}, learned from your history'**
  String learnFromHistory(String value);

  /// Screen-reader hint on a learned value.
  ///
  /// In en, this message translates to:
  /// **'Shows how this was worked out'**
  String get learnExplainHint;

  /// Clears what was learned for this task title, on this device only (docs/13 §6).
  ///
  /// In en, this message translates to:
  /// **'Reset for this task on this device'**
  String get learnReset;

  /// Snackbar after a reset, with Undo.
  ///
  /// In en, this message translates to:
  /// **'Learning for {title} reset on this device'**
  String learnResetDone(String title);

  /// Inside a sheet or popover, where Undo can't be reached, the reset asks once inline (docs/13 §6).
  ///
  /// In en, this message translates to:
  /// **'Forget what {title} taught, on this device?'**
  String learnResetConfirm(String title);

  /// Confirms the inline reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get learnResetConfirmAction;

  /// Cancels the inline reset; nothing changes.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get learnResetKeep;

  /// Running late sheet: the task at hand's usual real length, which picked the amount.
  ///
  /// In en, this message translates to:
  /// **'{title} usually takes {duration}'**
  String lateUsually(String title, String duration);

  /// Routines page title (11 C2).
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get routinesTitle;

  /// Routines page subtitle.
  ///
  /// In en, this message translates to:
  /// **'Reusable slices of thread'**
  String get routinesSubtitle;

  /// Routine card: number of steps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String routineSteps(int count);

  /// Routine card summary, e.g. '4 steps · 1 h 15 · starts at Wake Up'.
  ///
  /// In en, this message translates to:
  /// **'{steps} · {duration} · {anchor}'**
  String routineSummary(String steps, String duration, String anchor);

  /// Routine anchor: first step at Wake Up.
  ///
  /// In en, this message translates to:
  /// **'starts at Wake Up'**
  String get routineStartsWake;

  /// Routine anchor: last step ends at Wind Down.
  ///
  /// In en, this message translates to:
  /// **'ends at Wind Down'**
  String get routineEndsBed;

  /// Routine anchor: a fixed local time.
  ///
  /// In en, this message translates to:
  /// **'starts at {time}'**
  String routineStartsAt(String time);

  /// Button: propose the routine's tasks on today.
  ///
  /// In en, this message translates to:
  /// **'Drop on today'**
  String get routineDropToday;

  /// Button: edit a routine.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get routineEdit;

  /// Button and editor title: create a routine from scratch.
  ///
  /// In en, this message translates to:
  /// **'New routine'**
  String get routineNew;

  /// After 'New routine': the other way to make one.
  ///
  /// In en, this message translates to:
  /// **'or save a selection from any day'**
  String get routineNewHint;

  /// Footnote on the Routines page (A0).
  ///
  /// In en, this message translates to:
  /// **'Routine-start dots ring loud, like an alarm'**
  String get routineAlarmNote;

  /// Routines page with none saved.
  ///
  /// In en, this message translates to:
  /// **'No routines yet. Pick a few tasks on any day and save them as a routine, or start a new one.'**
  String get routinesEmpty;

  /// Selection bar action and sheet title: save the picked tasks as a routine.
  ///
  /// In en, this message translates to:
  /// **'Save as routine'**
  String get routineSaveSelection;

  /// Routine name field label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get routineName;

  /// Snackbar after saving a routine.
  ///
  /// In en, this message translates to:
  /// **'Saved “{title}” as a routine'**
  String routineSaved(String title);

  /// Snackbar with Undo after deleting a routine.
  ///
  /// In en, this message translates to:
  /// **'Deleted “{title}”'**
  String routineDeleted(String title);

  /// Editor action.
  ///
  /// In en, this message translates to:
  /// **'Delete routine'**
  String get routineDelete;

  /// Editor title for an existing routine.
  ///
  /// In en, this message translates to:
  /// **'Edit routine'**
  String get routineEditTitle;

  /// Editor caption above the anchor choice.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get routineAnchorLabel;

  /// Anchor choice.
  ///
  /// In en, this message translates to:
  /// **'At Wake Up'**
  String get routineAnchorWake;

  /// Anchor choice.
  ///
  /// In en, this message translates to:
  /// **'Ending at Wind Down'**
  String get routineAnchorBed;

  /// Anchor choice.
  ///
  /// In en, this message translates to:
  /// **'At a time'**
  String get routineAnchorTime;

  /// Editor caption above the steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get routineStepsLabel;

  /// Hint in a step's name field.
  ///
  /// In en, this message translates to:
  /// **'Step name'**
  String get routineStepHint;

  /// Editor button.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get routineAddStep;

  /// Tooltip: remove a step from the routine.
  ///
  /// In en, this message translates to:
  /// **'Remove {title}'**
  String routineRemoveStep(String title);

  /// Tooltip: move a step earlier.
  ///
  /// In en, this message translates to:
  /// **'Move {title} up'**
  String routineMoveUp(String title);

  /// Tooltip: move a step later.
  ///
  /// In en, this message translates to:
  /// **'Move {title} down'**
  String routineMoveDown(String title);

  /// Editor: free time kept between two steps.
  ///
  /// In en, this message translates to:
  /// **'{duration} free'**
  String routineGap(String duration);

  /// Editor button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get routineSave;

  /// Proposal sheet title when dropping a routine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routineDropTitle;

  /// Proposal subtitle when dropping a routine.
  ///
  /// In en, this message translates to:
  /// **'{title} on {day} · from {time}'**
  String routineDropSubtitle(String title, String day, String time);

  /// Proposal accept button when dropping a routine.
  ///
  /// In en, this message translates to:
  /// **'Add to day'**
  String get routineDropAccept;

  /// Snackbar with Undo after a routine drop was accepted.
  ///
  /// In en, this message translates to:
  /// **'Routine added'**
  String get routineDropAccepted;

  /// Screen-reader label of a routine chip.
  ///
  /// In en, this message translates to:
  /// **'Drop routine {title}'**
  String routineChipLabel(String title);

  /// Today ⋯ menu and Settings › Planning: open the Routines page.
  ///
  /// In en, this message translates to:
  /// **'Routines…'**
  String get routinesMenu;

  /// Add step 1: caption above routine chips.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get routinesSuggestions;

  /// Editor: why Save is off.
  ///
  /// In en, this message translates to:
  /// **'Give the routine a name and at least one step'**
  String get routineInvalid;

  /// Routines page ring, read out.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No routines} =1{1 routine} other{{count} routines}}'**
  String routinesCount(int count);

  /// Week strip day menu and Inbox: pick a routine to propose on that day.
  ///
  /// In en, this message translates to:
  /// **'Drop a routine…'**
  String get routineDropHere;

  /// Routine card button for a day other than today.
  ///
  /// In en, this message translates to:
  /// **'Drop on {day}'**
  String routineDropOnDay(String day);

  /// Routines page: caption above the week strip picking where routines drop.
  ///
  /// In en, this message translates to:
  /// **'Which day'**
  String get routineDropDay;

  /// Settings › Planning switch (11 C4): suggest when to place high-energy tasks.
  ///
  /// In en, this message translates to:
  /// **'Energy suggestions'**
  String get settingsEnergy;

  /// Under the Energy suggestions switch.
  ///
  /// In en, this message translates to:
  /// **'Suggest times when you usually finish high-energy tasks'**
  String get settingsEnergyDetail;

  /// Under the Energy suggestions switch while it can't be on yet (docs/13 §3).
  ///
  /// In en, this message translates to:
  /// **'After {total} finished high-energy tasks · {count} so far'**
  String settingsEnergyLocked(int total, int count);

  /// Under the Energy suggestions switch once it can be turned on, while it is off (docs/13 §3).
  ///
  /// In en, this message translates to:
  /// **'ready — based on {count} completed tasks'**
  String settingsEnergyReady(int count);

  /// Settings group caption: what Dottoday learns from the user's own history (docs/13 §4.1).
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get settingsLearning;

  /// Settings › Learning row title.
  ///
  /// In en, this message translates to:
  /// **'Reality thread'**
  String get settingsLearningReality;

  /// Settings › Learning, before the reality thread is ready. A promise, never a judgement.
  ///
  /// In en, this message translates to:
  /// **'Dottoday is learning how your days really go. Your reality thread appears after about {total} finished tasks.'**
  String settingsLearningRealityPending(int total);

  /// Settings › Learning, once the reality thread is ready.
  ///
  /// In en, this message translates to:
  /// **'Ready · Plan / Reality is in Today\'s header'**
  String get settingsLearningRealityReady;

  /// Settings › Learning row title.
  ///
  /// In en, this message translates to:
  /// **'Task lengths'**
  String get settingsLearningDurations;

  /// Settings › Learning: per task, so it reveals one task at a time.
  ///
  /// In en, this message translates to:
  /// **'Dottoday is learning how long your tasks really take. Each task shows its usual length after about {min} finished times.'**
  String settingsLearningDurationsPending(int min);

  /// Settings › Learning value: tasks whose usual length now shows. Hidden at 0.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Ready for 1 task} other{Ready for {count} tasks}}'**
  String settingsLearningTasksReady(int count);

  /// Settings › Learning row title.
  ///
  /// In en, this message translates to:
  /// **'Step lengths'**
  String get settingsLearningSteps;

  /// Settings › Learning: step lengths in Focus.
  ///
  /// In en, this message translates to:
  /// **'Dottoday is learning how long each step takes. A step\'s timer uses its usual length after about {min} finished times.'**
  String settingsLearningStepsPending(int min);

  /// Settings › Learning value: steps whose usual length now shows. Hidden at 0.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Ready for 1 step} other{Ready for {count} steps}}'**
  String settingsLearningStepsReady(int count);

  /// Settings › Learning value beside the progress ring, e.g. 7/10.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String settingsLearningProgress(int done, int total);

  /// Screen-reader reading of the progress ring and its value.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} so far'**
  String settingsLearningProgressLabel(int done, int total);

  /// Settings › Learning footer: the privacy line (docs/13 §4.1). Must stay accurate to the sync design.
  ///
  /// In en, this message translates to:
  /// **'Learning happens on your device. Your actual start and end times sync with your account like the rest of your plan; the learned numbers themselves are never uploaded.'**
  String get settingsLearningPrivacy;

  /// Add step 2: the user's best window for high-energy work, from their own history.
  ///
  /// In en, this message translates to:
  /// **'you finish high-energy tasks best {range}'**
  String addEnergyBest(String range);

  /// Add step 2: move the new task to the start of the best window.
  ///
  /// In en, this message translates to:
  /// **'Try {time}'**
  String addEnergyTry(String time);

  /// Debug-build-only menu item: real times on two of today's tasks and three sample routines.
  ///
  /// In en, this message translates to:
  /// **'Load M11 sample (debug)'**
  String get debugLoadM11Sample;

  /// Confirmation after the debug M11 sample was written.
  ///
  /// In en, this message translates to:
  /// **'M11 sample loaded'**
  String get debugM11Loaded;

  /// Proposal chip on an existing task a new one would overlap; it stays as it is (routine drop, M11.4).
  ///
  /// In en, this message translates to:
  /// **'already here · overlaps'**
  String get proposalOverlaps;

  /// Weekly review (11 D1): sheet title, Today ⋯ menu item and Wind Down prompt caption.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get weekReviewTitle;

  /// Weekly review: the week's first and last day.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String weekReviewDates(String from, String to);

  /// Weekly review: done and planned tasks inside a day's dot.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String weekReviewDotCount(int done, int total);

  /// Weekly review: a day's dot read out by screen readers.
  ///
  /// In en, this message translates to:
  /// **'{day}: {done} of {total} done, {planned} planned'**
  String weekReviewDayLabel(String day, int done, int total, String planned);

  /// Weekly review: a tapped day's planned time, under its tasks.
  ///
  /// In en, this message translates to:
  /// **'{planned} planned'**
  String weekReviewPlanned(String planned);

  /// Weekly review: the busiest day's planned time, under its tasks.
  ///
  /// In en, this message translates to:
  /// **'{planned} · busiest'**
  String weekReviewPlannedBusiest(String planned);

  /// Weekly review chip: the day with the most planned time.
  ///
  /// In en, this message translates to:
  /// **'Busiest · {day}'**
  String weekReviewBusiest(String day);

  /// Weekly review chip: the day with the least planned time.
  ///
  /// In en, this message translates to:
  /// **'Lightest · {day}'**
  String weekReviewLightest(String day);

  /// Weekly review sentence, first half: most morning tasks really started within 15 min of plan.
  ///
  /// In en, this message translates to:
  /// **'Mornings mostly went to plan.'**
  String get weekPaceMornings;

  /// Weekly review sentence, first half: most afternoon tasks really started within 15 min of plan.
  ///
  /// In en, this message translates to:
  /// **'Afternoons mostly went to plan.'**
  String get weekPaceAfternoons;

  /// Weekly review sentence, first half: every planned task is done.
  ///
  /// In en, this message translates to:
  /// **'Everything you planned got done.'**
  String get weekPaceAllDone;

  /// Weekly review sentence when the week had no tasks.
  ///
  /// In en, this message translates to:
  /// **'A quiet week: nothing was planned.'**
  String get weekPaceQuiet;

  /// Weekly review sentence, second half: the busiest and the lightest day by planned time.
  ///
  /// In en, this message translates to:
  /// **'{busiest} carried the most; {lightest} breathed.'**
  String weekLoadBoth(String busiest, String lightest);

  /// Weekly review sentence, second half, when only one day had anything planned.
  ///
  /// In en, this message translates to:
  /// **'{busiest} carried the most.'**
  String weekLoadBusiest(String busiest);

  /// Weekly review: one-off tasks left unfinished this week.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unfinished · move it to next week?} other{{count} unfinished · move them to next week?}}'**
  String weekCarryAsk(int count);

  /// Weekly review: propose the unfinished tasks into next week's free time.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get weekCarryPlace;

  /// Weekly review: send the unfinished tasks to the Inbox (with Undo).
  ///
  /// In en, this message translates to:
  /// **'Leave in Inbox'**
  String get weekCarryInbox;

  /// Proposal title: unfinished tasks placed into next week.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get weekCarryTitle;

  /// Proposal subtitle for placing unfinished tasks into next week.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unfinished task, each in the first free time that fits} other{{count} unfinished tasks, each in the first free time that fits}}'**
  String weekCarrySubtitle(int count);

  /// Proposal accept button: place the unfinished tasks into next week.
  ///
  /// In en, this message translates to:
  /// **'Place them'**
  String get weekCarryAccept;

  /// Undo snackbar after the unfinished tasks were placed into next week.
  ///
  /// In en, this message translates to:
  /// **'Placed in next week'**
  String get weekCarryAccepted;

  /// Weekly review: include task titles in the share image (off by default).
  ///
  /// In en, this message translates to:
  /// **'Show task titles'**
  String get weekShareTitles;

  /// Weekly review: share the week as an image through the system share sheet.
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get weekShareImage;

  /// Share image with titles on: a day and its task titles.
  ///
  /// In en, this message translates to:
  /// **'{day} · {titles}'**
  String weekShareDayTitles(String day, String titles);

  /// Weekly review footer: states the no-streak principle (11 D). The one string allowed to name streaks, to say there are none.
  ///
  /// In en, this message translates to:
  /// **'No streaks here — just what happened.'**
  String get weekReviewNoStreaks;

  /// Wind Down prompt on the week's last day: what the weekly review shows.
  ///
  /// In en, this message translates to:
  /// **'Your week in seven dots'**
  String get weekPromptDetail;

  /// Wind Down prompt on the week's last day: open the weekly review.
  ///
  /// In en, this message translates to:
  /// **'See the week'**
  String get weekPromptAction;

  /// Low-energy mode (11 D2): Today ⋯ item and Settings › Planning switch title.
  ///
  /// In en, this message translates to:
  /// **'Low-energy mode'**
  String get lowEnergyMode;

  /// Today ⋯ item while low-energy mode is on.
  ///
  /// In en, this message translates to:
  /// **'Turn off low-energy mode'**
  String get lowEnergyTurnOff;

  /// Under the Low-energy mode switch in Settings › Planning.
  ///
  /// In en, this message translates to:
  /// **'Today shows only what\'s next and nudges pause, until your next Wake Up'**
  String get settingsLowEnergyDetail;

  /// Today header caption in low-energy mode (shown upper-case on phones).
  ///
  /// In en, this message translates to:
  /// **'{date} · Low-energy'**
  String lowEnergyCaption(String date);

  /// Today title in low-energy mode, no name set.
  ///
  /// In en, this message translates to:
  /// **'Take it easy'**
  String get lowEnergyGreeting;

  /// Today title in low-energy mode.
  ///
  /// In en, this message translates to:
  /// **'Take it easy, {name}'**
  String lowEnergyGreetingName(String name);

  /// Today header switch while low-energy mode is on; turning it off ends the mode.
  ///
  /// In en, this message translates to:
  /// **'Low-energy · on'**
  String get lowEnergyOn;

  /// Low-energy next dot, while it runs.
  ///
  /// In en, this message translates to:
  /// **'until {time} · {left} left'**
  String lowEnergyUntil(String time, String left);

  /// Low-energy next dot, before it starts.
  ///
  /// In en, this message translates to:
  /// **'at {time}'**
  String lowEnergyAt(String time);

  /// Low-energy next dot: a one-off moves to tomorrow, a repeat or event is skipped today (with Undo).
  ///
  /// In en, this message translates to:
  /// **'Not today'**
  String get lowEnergyNotToday;

  /// Undo snackbar after Not today moved a task.
  ///
  /// In en, this message translates to:
  /// **'{title} moved to tomorrow'**
  String lowEnergyMovedTomorrow(String title);

  /// Undo snackbar after Not today skipped a repeat or event.
  ///
  /// In en, this message translates to:
  /// **'{title} skipped for today'**
  String lowEnergySkipped(String title);

  /// Low-energy: caption of the pile of today's later tasks.
  ///
  /// In en, this message translates to:
  /// **'Later · {count}'**
  String lowEnergyLater(int count);

  /// Tooltip: open the Later pile.
  ///
  /// In en, this message translates to:
  /// **'Show what\'s later'**
  String get lowEnergyShowLater;

  /// Tooltip: close the Later pile.
  ///
  /// In en, this message translates to:
  /// **'Hide what\'s later'**
  String get lowEnergyHideLater;

  /// Low-energy: offered once a day; opens a proposal.
  ///
  /// In en, this message translates to:
  /// **'Move everything optional to tomorrow?'**
  String get lowEnergyPropose;

  /// Low-energy: open the proposal moving optional tasks to tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Propose'**
  String get lowEnergyProposeAction;

  /// Low-energy footer. Alarm-loud first dots still ring.
  ///
  /// In en, this message translates to:
  /// **'Nudges are off until tomorrow\'s Wake Up'**
  String get lowEnergyNudgesOff;

  /// Low-energy: nothing left planned today.
  ///
  /// In en, this message translates to:
  /// **'Nothing else today. Rest well.'**
  String get lowEnergyNothing;

  /// Proposal title: optional tasks moved to tomorrow (low-energy).
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get lowEnergyProposalTitle;

  /// Proposal subtitle (low-energy).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 optional task, in tomorrow\'s first free time} other{{count} optional tasks, each in tomorrow\'s first free time}}'**
  String lowEnergyProposalSubtitle(int count);

  /// Proposal accept button (low-energy).
  ///
  /// In en, this message translates to:
  /// **'Move them'**
  String get lowEnergyProposalAccept;

  /// Undo snackbar after the low-energy proposal was accepted.
  ///
  /// In en, this message translates to:
  /// **'Moved to tomorrow'**
  String get lowEnergyProposalAccepted;

  /// Thread journal (11 D3): Search entry and page title.
  ///
  /// In en, this message translates to:
  /// **'Past days'**
  String get journalTitle;

  /// Under the Past days entry in Search.
  ///
  /// In en, this message translates to:
  /// **'Every day you planned, as it went'**
  String get journalEntryDetail;

  /// Past days search field hint.
  ///
  /// In en, this message translates to:
  /// **'When did I last…'**
  String get journalSearchHint;

  /// Past days: how many days with something planned.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day in the last 12 months} other{{count} days in the last 12 months}}'**
  String journalDays(int count);

  /// Past days search: the newest matching day, how long ago, and on how many days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Last: {date} · {ago, plural, =1{yesterday} other{{ago} days ago}} · once} other{Last: {date} · {ago, plural, =1{yesterday} other{{ago} days ago}} · {count} days}}'**
  String journalLast(String date, int ago, int count);

  /// Past days search with no match.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the last 12 months matches “{query}”'**
  String journalNoMatch(String query);

  /// Past days with nothing yet.
  ///
  /// In en, this message translates to:
  /// **'No past days yet. Days you plan show up here once they\'re over.'**
  String get journalEmpty;

  /// Screen reader: a past day's row.
  ///
  /// In en, this message translates to:
  /// **'{date}, {summary}. Open the day'**
  String journalDayLabel(String date, String summary);

  /// Past days search: a matching task on that day and its time.
  ///
  /// In en, this message translates to:
  /// **'{title} · {time}'**
  String journalMatch(String title, String time);

  /// Past days: open the twelve-month strip to share as an image.
  ///
  /// In en, this message translates to:
  /// **'Year strip'**
  String get journalStripTitle;

  /// Screen reader: the year strip image.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your year as dots: 1 day planned} other{Your year as dots: {count} days planned}}'**
  String journalStripLabel(int count);

  /// Brain dump (11 B4): Today ⋯ item, sheet and proposal title.
  ///
  /// In en, this message translates to:
  /// **'Brain dump'**
  String get dumpTitle;

  /// Brain dump field hint; typing or dictation.
  ///
  /// In en, this message translates to:
  /// **'Everything on your mind, one thing per line'**
  String get dumpHint;

  /// Brain dump: turn the lines into a proposal on the chosen day.
  ///
  /// In en, this message translates to:
  /// **'Plan it'**
  String get dumpPlan;

  /// Brain dump: the text gave no tasks.
  ///
  /// In en, this message translates to:
  /// **'Nothing to plan yet. Write one thing per line.'**
  String get dumpNothing;

  /// Brain dump proposal subtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task on {day}, in the first free time} other{{count} tasks on {day}, in the first free time}}'**
  String dumpSubtitle(int count, String day);

  /// Undo snackbar after a brain dump was accepted.
  ///
  /// In en, this message translates to:
  /// **'Added from your brain dump'**
  String get dumpAccepted;

  /// Brain dump sheet: caption above the local history.
  ///
  /// In en, this message translates to:
  /// **'Earlier dumps'**
  String get dumpEarlier;

  /// Brain dump history search hint.
  ///
  /// In en, this message translates to:
  /// **'Search earlier dumps'**
  String get dumpSearch;

  /// Brain dump history: put an earlier dump back in the field.
  ///
  /// In en, this message translates to:
  /// **'Use again'**
  String get dumpUseAgain;

  /// Proposal chip: a new task with no free time left on the day goes to the Inbox (brain dump).
  ///
  /// In en, this message translates to:
  /// **'no room · to the Inbox'**
  String get proposalToInbox;

  /// What's new in 1.0.0 (M9–M12), one item per line (PRD F11).
  ///
  /// In en, this message translates to:
  /// **'See time: your next dot on the lock screen, widgets, the Mac menu bar and Siri, and alarms that really ring.\nStart: Break it down into small steps, Focus on one dot, and gentle help when a task won\'t start.\nStay in control: Rebalance shows a plan before anything moves; Plan / Reality shows how the day really went.\nRoutines, energy suggestions and lengths learned from your own days, on your device.\nThis week as seven dots, Past days to look back, and low-energy mode for hard days. Nothing to keep up.\nShare a page or a note to Dottoday from any app, or empty your head with Brain dump.'**
  String get releaseNotes100;

  /// Privacy › Help with thinking (M14.2): Apple Intelligence is off on this iPhone; where to turn it on.
  ///
  /// In en, this message translates to:
  /// **'Turn on Apple Intelligence in iPhone Settings › Apple Intelligence & Siri. Dottoday will use it automatically.'**
  String get privacyAiAppleOffIos;

  /// Privacy › Help with thinking (M14.2): Apple Intelligence is off on this Mac; where to turn it on.
  ///
  /// In en, this message translates to:
  /// **'Turn on Apple Intelligence in System Settings › Apple Intelligence & Siri. Dottoday will use it automatically.'**
  String get privacyAiAppleOffMac;

  /// Privacy › Help with thinking (M14.2): Apple Intelligence is preparing its model.
  ///
  /// In en, this message translates to:
  /// **'Apple Intelligence is getting ready on this device. It can take a while.'**
  String get privacyAiAppleDownloading;

  /// Privacy › Help with thinking (M14.2): Gemini Nano can be downloaded by Android.
  ///
  /// In en, this message translates to:
  /// **'Gemini Nano can be downloaded on this phone; it downloads in the background.'**
  String get privacyAiGoogleDownloadable;

  /// Privacy › Help with thinking (M14.2): Gemini Nano is downloading.
  ///
  /// In en, this message translates to:
  /// **'Gemini Nano is downloading on this phone. Dottoday will use it once it\'s ready.'**
  String get privacyAiGoogleDownloading;

  /// Privacy › Help with thinking (M14.2): the browser's built-in model can be downloaded.
  ///
  /// In en, this message translates to:
  /// **'This browser can download its built-in AI model. Dottoday will use it once it\'s there.'**
  String get privacyAiChromeDownloadable;

  /// Privacy › Help with thinking (M14.2): the browser is downloading its built-in model.
  ///
  /// In en, this message translates to:
  /// **'This browser is downloading its built-in AI model. Dottoday will use it once it\'s ready.'**
  String get privacyAiChromeDownloading;

  /// Privacy › Help with thinking (M14.2): this device, OS or browser can't run an on-device model.
  ///
  /// In en, this message translates to:
  /// **'This device can\'t run the built-in model. Dottoday uses your history and simple rules.'**
  String get privacyAiNotEligible;

  /// Privacy › Help with thinking (M14.2): button that opens the OS settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get privacyAiOpenSettings;

  /// Privacy › Help with thinking (M14.2): under Open Settings on iPhone; iOS only allows opening the app's own page.
  ///
  /// In en, this message translates to:
  /// **'Opens Dottoday\'s page in Settings. Apple doesn\'t let apps open Apple Intelligence directly: go back to Settings, then Apple Intelligence & Siri.'**
  String get privacyAiOpenSettingsIos;

  /// Proposal origin chip (M14.2): the plan was made by Dottoday's rules, not a model. Lower case like 'on-device'.
  ///
  /// In en, this message translates to:
  /// **'simple rules'**
  String get thinkingOriginRules;

  /// Proposal hint (M14.2, StatusHint): first, muted part.
  ///
  /// In en, this message translates to:
  /// **'Made with simple rules'**
  String get thinkingHintLead;

  /// Proposal hint (M14.2): accent part when Apple Intelligence is off; taps to Privacy.
  ///
  /// In en, this message translates to:
  /// **'Turn on Apple Intelligence for smarter plans'**
  String get thinkingHintApple;

  /// Proposal hint (M14.2): accent part while Apple Intelligence prepares its model.
  ///
  /// In en, this message translates to:
  /// **'Apple Intelligence is getting ready for smarter plans'**
  String get thinkingHintAppleReady;

  /// Proposal hint (M14.2): accent part while Gemini Nano is downloadable or downloading.
  ///
  /// In en, this message translates to:
  /// **'Gemini Nano makes smarter plans once it\'s on this phone'**
  String get thinkingHintGoogle;

  /// Proposal hint (M14.2): accent part while the browser's model is downloadable or downloading.
  ///
  /// In en, this message translates to:
  /// **'Your browser\'s built-in AI makes smarter plans once it\'s ready'**
  String get thinkingHintChrome;

  /// Proposal hint (M14.2): the ×; the hint never shows again on this device.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get thinkingHintDismiss;

  /// Brain dump: caption under Plan it when Apple Intelligence will answer (M14.2).
  ///
  /// In en, this message translates to:
  /// **'Plans with Apple Intelligence on this device'**
  String get dumpPlansApple;

  /// Brain dump: caption under Plan it when Gemini Nano will answer (M14.2).
  ///
  /// In en, this message translates to:
  /// **'Plans with Gemini Nano on this phone'**
  String get dumpPlansGoogle;

  /// Brain dump: caption under Plan it when the browser's built-in model will answer (M14.2).
  ///
  /// In en, this message translates to:
  /// **'Plans with your browser\'s built-in AI, on this device'**
  String get dumpPlansChrome;

  /// Brain dump: caption under Plan it when Dottoday's rules will answer (M14.2).
  ///
  /// In en, this message translates to:
  /// **'Plans with simple rules'**
  String get dumpPlansRules;

  /// What's new in 1.1.0 (M14: voice + AI clarity), one item per line (PRD F11).
  ///
  /// In en, this message translates to:
  /// **'Speak it: tap the mic in Brain dump and say what\'s on your mind — pause, or say \"next\", to start a new task. The mic is in a task\'s notes too. Your words are turned into text on this device and never sent anywhere.\nAsk Siri: on iPhone, Settings › Siri & Shortcuts shows the five things you can ask, like \"What\'s next in Dottoday\".\nKnow who plans: Settings › Privacy says whether Apple Intelligence, Gemini Nano or your browser\'s built-in AI is helping on this device, and how to turn it on. Plans made with simple rules now say so.'**
  String get releaseNotes110;

  /// StatusHint (M14.2): a muted lead and an accent action on one line, e.g. 'Made with simple rules · Turn on Apple Intelligence for smarter plans'.
  ///
  /// In en, this message translates to:
  /// **'{lead} · {action}'**
  String statusHintJoin(String lead, String action);

  /// Settings row and page title (M14.3, iPhone only): Siri and the Shortcuts app.
  ///
  /// In en, this message translates to:
  /// **'Siri & Shortcuts'**
  String get settingsSiri;

  /// Settings › Siri & Shortcuts row subtitle (M14.3).
  ///
  /// In en, this message translates to:
  /// **'Ask Siri about your day'**
  String get settingsSiriDetail;

  /// Siri page (M14.3): what Siri can do with Dottoday.
  ///
  /// In en, this message translates to:
  /// **'Siri can add a task, tell you what\'s next, and help with the task you\'re on — without opening Dottoday.'**
  String get siriIntro;

  /// Siri page (M14.3): how to invoke Siri.
  ///
  /// In en, this message translates to:
  /// **'Say \"Hey Siri\" or hold the side button, then say a phrase.'**
  String get siriHowTo;

  /// Siri page (M14.3): caption above the five phrases.
  ///
  /// In en, this message translates to:
  /// **'What you can say'**
  String get siriPhrasesCaption;

  /// Siri phrase; must match ios/Runner/<lang>.lproj/AppShortcuts.strings with the app name (siri_phrases_test).
  ///
  /// In en, this message translates to:
  /// **'Add a task in Dottoday'**
  String get siriPhraseAdd;

  /// Siri page: what the Add a task phrase does.
  ///
  /// In en, this message translates to:
  /// **'Siri asks what to add. Say a time and it goes on your day; otherwise it goes to the Inbox.'**
  String get siriPhraseAddDetail;

  /// Siri phrase; must match AppShortcuts.strings (siri_phrases_test).
  ///
  /// In en, this message translates to:
  /// **'What\'s next in Dottoday'**
  String get siriPhraseNext;

  /// Siri page: what the What's next phrase does.
  ///
  /// In en, this message translates to:
  /// **'Siri says what\'s on now, or what comes next.'**
  String get siriPhraseNextDetail;

  /// Siri phrase; must match AppShortcuts.strings (siri_phrases_test).
  ///
  /// In en, this message translates to:
  /// **'Mark my task done in Dottoday'**
  String get siriPhraseDone;

  /// Siri page: what the Mark done phrase does.
  ///
  /// In en, this message translates to:
  /// **'Ticks off the task you\'re on.'**
  String get siriPhraseDoneDetail;

  /// Siri phrase; must match AppShortcuts.strings (siri_phrases_test).
  ///
  /// In en, this message translates to:
  /// **'Give my task 15 more minutes in Dottoday'**
  String get siriPhrasePlus15;

  /// Siri page: what the +15 phrase does.
  ///
  /// In en, this message translates to:
  /// **'Gives the task you\'re on 15 more minutes.'**
  String get siriPhrasePlus15Detail;

  /// Siri phrase; must match AppShortcuts.strings (siri_phrases_test).
  ///
  /// In en, this message translates to:
  /// **'Start focus in Dottoday'**
  String get siriPhraseFocus;

  /// Siri page: what the Start focus phrase does.
  ///
  /// In en, this message translates to:
  /// **'Opens Focus on the task you\'re on.'**
  String get siriPhraseFocusDetail;

  /// Siri page (M14.3): caption above the Shortcuts part.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get siriShortcutsCaption;

  /// Siri page (M14.3): the same actions are in the Shortcuts app.
  ///
  /// In en, this message translates to:
  /// **'The same five actions are in the Shortcuts app, ready for the Action button, Control Center or your Home Screen.'**
  String get siriShortcutsBody;

  /// Siri page (M14.3): button that opens the Shortcuts app.
  ///
  /// In en, this message translates to:
  /// **'Open Shortcuts'**
  String get siriOpenShortcuts;

  /// Today tip card (M14.3, iPhone, once): suggests a Siri phrase.
  ///
  /// In en, this message translates to:
  /// **'Ask Siri \"What\'s next in Dottoday\"'**
  String get siriTipTitle;

  /// Today tip card (M14.3): opens Settings › Siri & Shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Show me'**
  String get siriTipShow;

  /// A one-time tip card's × (M14): it never shows again on this device.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get tipDismiss;

  /// Onboarding Done step (M14.3, iPhone only): one quiet line about Siri.
  ///
  /// In en, this message translates to:
  /// **'You can also ask Siri \"What\'s next in Dottoday\".'**
  String get onboardingSiriLine;

  /// Brain dump dictation (D6): the ONE spoken word that starts a new line. A single common word, lower case; owner-decided per language.
  ///
  /// In en, this message translates to:
  /// **'next'**
  String get dictationCommand;

  /// Mic button (M14.5): screen reader label and tooltip when idle.
  ///
  /// In en, this message translates to:
  /// **'Dictate'**
  String get micDictate;

  /// Mic button (M14.5): screen reader label and tooltip while listening.
  ///
  /// In en, this message translates to:
  /// **'Stop dictation'**
  String get micStop;

  /// Quiet line when the microphone permission is off (M14.5); never red.
  ///
  /// In en, this message translates to:
  /// **'Microphone is off for Dottoday'**
  String get micDenied;

  /// Dictation stopped for a reason other than the user (interruption, recognizer).
  ///
  /// In en, this message translates to:
  /// **'Dictation stopped. Tap the mic to go on.'**
  String get failureSpeech;

  /// In-app rationale before Android's microphone dialog (D5).
  ///
  /// In en, this message translates to:
  /// **'Use the microphone?'**
  String get micRationaleTitle;

  /// In-app rationale before the system microphone dialog (D5, same meaning as the iOS usage text).
  ///
  /// In en, this message translates to:
  /// **'Dottoday listens only while the mic button is on, to turn your words into text on this device.'**
  String get micRationaleBody;

  /// In-app microphone rationale: go on to the system dialog.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get micRationaleContinue;

  /// Brain dump caption while listening (M14.5); the quoted word is dictationCommand.
  ///
  /// In en, this message translates to:
  /// **'Pause, or say \"next\", to start a new task.'**
  String get dumpListening;

  /// Brain dump field hint where the mic is available (M14.5).
  ///
  /// In en, this message translates to:
  /// **'Type or tap the mic. One thing per line.'**
  String get dumpHintMic;

  /// Brain dump first-use dictation tip card title (M14.5, once).
  ///
  /// In en, this message translates to:
  /// **'Speak your list'**
  String get dumpMicTipTitle;

  /// Brain dump first-use dictation tip (M14.5): the two ways to start a new line, with an example.
  ///
  /// In en, this message translates to:
  /// **'Pause, or say \"next\", between things. \"Call the dentist … next … buy milk\" becomes two lines.'**
  String get dumpMicTipBody;

  /// Today ⋯ item in minimal mode: switches to the full layout at once (docs/14 §5).
  ///
  /// In en, this message translates to:
  /// **'Show everything'**
  String get layoutShowEverything;

  /// Today ⋯ item in full mode: switches to the minimal layout at once (docs/14 §5).
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get layoutShowLess;

  /// Settings row 1 in both layouts (docs/14 §4): the minimal / full switch.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get layoutRow;

  /// Settings › Layout: the minimal choice.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get layoutMinimal;

  /// Settings › Layout: the full choice.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get layoutFull;

  /// Minimal Today: the quiet row at the end of the thread that opens the Inbox (docs/14 §3).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Later} other{Later · {count}}}'**
  String laterRow(int count);

  /// Screen-reader label of the Later row.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Later, nothing waiting} =1{Later, 1 task waiting} other{Later, {count} tasks waiting}}'**
  String laterRowLabel(int count);

  /// Minimal Add and task sheet: opens every other option (docs/14 §4).
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreOptions;

  /// Minimal task sheet: sends the task to the Inbox (the Later row).
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get sheetLater;

  /// Minimal task sheet: moves the task to Trash, with Undo.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get sheetDelete;

  /// Minimal Settings row 8: opens the full Settings tree (docs/14 §4).
  ///
  /// In en, this message translates to:
  /// **'Everything else…'**
  String get settingsEverythingElse;

  /// Minimal Settings row 4: on = the default alert at the start, off = no default alert.
  ///
  /// In en, this message translates to:
  /// **'Remind me when a dot starts'**
  String get settingsRemindDotStarts;

  /// Minimal Settings row 7.
  ///
  /// In en, this message translates to:
  /// **'Account and sync'**
  String get settingsAccountAndSync;

  /// Minimal Add: the when chip, pre-set to the next free slot (docs/14 §4).
  ///
  /// In en, this message translates to:
  /// **'At {time}'**
  String addWhenChip(String time);

  /// Onboarding step 0 (docs/14 §4).
  ///
  /// In en, this message translates to:
  /// **'How much do you want to see?'**
  String get onboardingLayoutTitle;

  /// Onboarding step 0, under the title.
  ///
  /// In en, this message translates to:
  /// **'You can change this any time, from the top of Settings.'**
  String get onboardingLayoutBody;

  /// Onboarding step 0: the minimal card's title (owner's copy, docs/14 §4).
  ///
  /// In en, this message translates to:
  /// **'Just the next dot'**
  String get onboardingLayoutMinimalTitle;

  /// Onboarding step 0: the minimal card's text (owner's copy).
  ///
  /// In en, this message translates to:
  /// **'What\'s now and what\'s next. Add, do, done. Nothing to set up.'**
  String get onboardingLayoutMinimalBody;

  /// Onboarding step 0: the full card's title (owner's copy).
  ///
  /// In en, this message translates to:
  /// **'The full planner'**
  String get onboardingLayoutFullTitle;

  /// Onboarding step 0: the full card's text (owner's copy).
  ///
  /// In en, this message translates to:
  /// **'The whole thread, week and month, routines, reviews, widgets and every setting.'**
  String get onboardingLayoutFullBody;

  /// Minimal onboarding, last step: the first task.
  ///
  /// In en, this message translates to:
  /// **'What\'s one thing for today?'**
  String get onboardingFirstTaskTitle;

  /// Minimal onboarding, last step: the text under the title.
  ///
  /// In en, this message translates to:
  /// **'Type it the way you\'d say it, like \"call Sam 6pm\". It goes on your thread.'**
  String get onboardingFirstTaskBody;

  /// Minimal onboarding, last step: adds the task and opens Today.
  ///
  /// In en, this message translates to:
  /// **'Put it on today'**
  String get onboardingFirstTaskAdd;

  /// Minimal-mode reveal hint (docs/14 §5): three mornings started the same way.
  ///
  /// In en, this message translates to:
  /// **'Save this as your morning?'**
  String get hintRoutines;

  /// Minimal-mode reveal hint: a task over 60 min without steps.
  ///
  /// In en, this message translates to:
  /// **'Break it into steps?'**
  String get hintBreakDown;

  /// Minimal-mode reveal hint: after the first Live Activity was dismissed.
  ///
  /// In en, this message translates to:
  /// **'Want the next dot on your home screen too?'**
  String get hintWidget;

  /// After Show me on the widget hint.
  ///
  /// In en, this message translates to:
  /// **'Add the Dottoday widget from your home screen\'s widget list.'**
  String get hintWidgetHow;

  /// Minimal-mode reveal hint: after 14 days of use.
  ///
  /// In en, this message translates to:
  /// **'See your week as seven dots?'**
  String get hintWeek;

  /// Minimal-mode reveal hint: three tasks took more than 20 min longer than planned this week.
  ///
  /// In en, this message translates to:
  /// **'Dottoday can start pre-filling times from how long things really take.'**
  String get hintLearned;

  /// A reveal hint's action.
  ///
  /// In en, this message translates to:
  /// **'Show me'**
  String get hintShowMe;

  /// Settings › Day shape and onboarding: the Wake Up alarm switch (docs/15 W1).
  ///
  /// In en, this message translates to:
  /// **'Wake Up alarm'**
  String get settingsWakeUpAlarm;

  /// Under the Wake Up alarm switch while it is off.
  ///
  /// In en, this message translates to:
  /// **'Rings like an alarm at Wake Up on days you\'ve planned'**
  String get settingsWakeUpAlarmDetail;

  /// The Wake Up alarm takes over the screen like an alarm (docs/15 §2).
  ///
  /// In en, this message translates to:
  /// **'Alarm-grade wake-up is on.'**
  String get wakeUpTierAlarm;

  /// iPhone: the Wake Up alarm is a time-sensitive notification (docs/15 §2).
  ///
  /// In en, this message translates to:
  /// **'Wake Up rings as a time-sensitive notification.'**
  String get wakeUpTierTimeSensitive;

  /// Under wakeUpTierTimeSensitive: what breaks through and what doesn't.
  ///
  /// In en, this message translates to:
  /// **'It breaks through Focus. The Silent switch still mutes it.'**
  String get wakeUpTierTimeSensitiveDetail;

  /// Android 14+: the full-screen intent is not allowed (docs/15 §2, §12 tier.fsiRevoked).
  ///
  /// In en, this message translates to:
  /// **'Wake Up can take over the screen like an alarm. Android needs you to allow it.'**
  String get wakeUpTierFsiRevoked;

  /// The Wake Up alarm can't ring because notifications are off.
  ///
  /// In en, this message translates to:
  /// **'Wake Up can\'t ring while notifications are off.'**
  String get wakeUpTierNoPermission;

  /// Mac and web: the Wake Up alarm rings on the phone (docs/15 §2).
  ///
  /// In en, this message translates to:
  /// **'Wake-up alarms ring on your phone.'**
  String get wakeUpTierNotAPhone;

  /// Title of the Wake Up alarm notification (docs/15 §12 alarm.label).
  ///
  /// In en, this message translates to:
  /// **'Wake Up'**
  String get notifWakeUpTitle;

  /// Wake Up alarm body: the day's first task and its time.
  ///
  /// In en, this message translates to:
  /// **'First: {title} at {time}'**
  String notifWakeUpFirst(String title, String time);

  /// Wake Up alarm body when the day's first task is gone.
  ///
  /// In en, this message translates to:
  /// **'Good morning.'**
  String get notifWakeUpBody;

  /// Day shape row under Wake Up alarm: opens its sound and snooze page.
  ///
  /// In en, this message translates to:
  /// **'Wake Up options'**
  String get settingsWakeUpOptions;

  /// Wake Up alarm page: caption over the switch.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get wakeUpAlarmCaption;

  /// Wake Up row button on an iPhone below iOS 26: how to update iOS.
  ///
  /// In en, this message translates to:
  /// **'How to update'**
  String get wakeUpFixUpdate;

  /// Wake Up alarm page in minimal mode: shows the remaining rows.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get wakeUpMoreOptions;

  /// Wake Up alarm row (Android): how long the alarm takes to reach full volume.
  ///
  /// In en, this message translates to:
  /// **'Volume ramp'**
  String get wakeUpRamp;

  /// Under Volume ramp.
  ///
  /// In en, this message translates to:
  /// **'Starts quieter and rises to your alarm volume.'**
  String get wakeUpRampDetail;

  /// Volume ramp value: starts at full volume.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get wakeUpRampOff;

  /// Button on the ringing Wake Up alarm.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get wakeUpSnooze;

  /// Wake Up alarm page: caption over the snooze rows.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get wakeUpSnoozeCaption;

  /// Under the Snooze switch.
  ///
  /// In en, this message translates to:
  /// **'Rings again a few minutes later.'**
  String get wakeUpSnoozeDetail;

  /// Wake Up alarm row: minutes until a snoozed alarm rings again.
  ///
  /// In en, this message translates to:
  /// **'Snooze length'**
  String get wakeUpSnoozeLength;

  /// Wake Up alarm row: how many snoozes before only I'm up is left.
  ///
  /// In en, this message translates to:
  /// **'Snooze limit'**
  String get wakeUpSnoozeLimit;

  /// Snooze limit value.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get wakeUpSnoozeNoLimit;

  /// Wake Up alarm switch: whether the alarm offers snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get wakeUpSnoozeRow;

  /// Wake Up alarm page: caption over the sound rows.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get wakeUpSoundCaption;

  /// Wake Up alarm row: which Start sound it rings with.
  ///
  /// In en, this message translates to:
  /// **'Alarm sound'**
  String get wakeUpSoundRow;

  /// Button that stops the ringing Wake Up alarm.
  ///
  /// In en, this message translates to:
  /// **'I\'m up'**
  String get wakeUpStop;

  /// After No on the Wake Up alarm page's test.
  ///
  /// In en, this message translates to:
  /// **'If it didn\'t ring, the line at the top says what\'s in the way.'**
  String get wakeUpTestLookHere;

  /// iOS 26+ with Dottoday's alarms not allowed.
  ///
  /// In en, this message translates to:
  /// **'Wake Up can ring like an alarm, but alarms are off for Dottoday in Settings.'**
  String get wakeUpTierAlarmsOff;

  /// An iPhone below iOS 26 that can update to it.
  ///
  /// In en, this message translates to:
  /// **'Your iPhone can\'t ring Wake Up like an alarm yet. That needs iOS 26.'**
  String get wakeUpTierNeedsUpdate;

  /// Wake Up alarm switch: a different Start sound each day.
  ///
  /// In en, this message translates to:
  /// **'Vary the sound'**
  String get wakeUpVary;

  /// Under Vary the sound.
  ///
  /// In en, this message translates to:
  /// **'A different alarm sound each day, so it stays easy to hear.'**
  String get wakeUpVaryDetail;

  /// Volume ramp value in seconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String wakeUpRampSeconds(int seconds);

  /// Snooze limit value.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Once} other{{count} times}}'**
  String wakeUpSnoozeTimes(int count);

  /// Wake Up card: caption over the first dot.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get wakeUpCardFirst;

  /// Wake Up card: caption over the next dots.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get wakeUpCardNext;

  /// Wake Up card: opens Rebalance when up after plan.
  ///
  /// In en, this message translates to:
  /// **'Shift the rest?'**
  String get wakeUpCardShift;

  /// Wake Up card's main button.
  ///
  /// In en, this message translates to:
  /// **'Start the day'**
  String get wakeUpCardStart;

  /// Wake Up card: closes it.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get wakeUpCardLater;

  /// Wake Up card on a day with no dots.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned yet'**
  String get wakeUpCardEmpty;

  /// Wake Up card on an empty day: opens Add.
  ///
  /// In en, this message translates to:
  /// **'Plan today'**
  String get wakeUpCardPlan;

  /// Minimal Wake Up card: shows the day dot, next dots and chips.
  ///
  /// In en, this message translates to:
  /// **'Show my day'**
  String get wakeUpCardShowDay;

  /// Wake Up options page: caption over the card rows.
  ///
  /// In en, this message translates to:
  /// **'Morning card'**
  String get wakeUpCardCaption;

  /// Switch: the Wake Up card.
  ///
  /// In en, this message translates to:
  /// **'Morning card'**
  String get wakeUpCardRow;

  /// Under the Morning card switch.
  ///
  /// In en, this message translates to:
  /// **'Your day on one screen when you\'re up'**
  String get wakeUpCardRowDetail;

  /// Switch: open the card on the first launch after Wake Up.
  ///
  /// In en, this message translates to:
  /// **'Show it when I first open the app'**
  String get wakeUpCardOnOpenRow;

  /// Switch: today's events on the card.
  ///
  /// In en, this message translates to:
  /// **'Calendar on the card'**
  String get wakeUpCardCalendarRow;

  /// Switch: the Inbox count on the card.
  ///
  /// In en, this message translates to:
  /// **'Inbox count on the card'**
  String get wakeUpCardInboxRow;

  /// Switch: the card's Shift the rest? offer.
  ///
  /// In en, this message translates to:
  /// **'Offer to shift the day when I\'m up after plan'**
  String get wakeUpLateOfferRow;

  /// Row: minutes after Wake Up before the shift offer shows.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get wakeUpLateAfterRow;

  /// Wake Up card's first line; date is the weekday and date.
  ///
  /// In en, this message translates to:
  /// **'Good morning. {date}.'**
  String wakeUpCardGreeting(String date);

  /// Inside the Wake Up card's day dot.
  ///
  /// In en, this message translates to:
  /// **'{count} planned · ends {time}'**
  String wakeUpCardPlanned(int count, String time);

  /// Wake Up card: the first dot's first step and its length.
  ///
  /// In en, this message translates to:
  /// **'first: {step} · {length}'**
  String wakeUpCardFirstStep(String step, String length);

  /// Wake Up card: the first dot's first step, no length.
  ///
  /// In en, this message translates to:
  /// **'first: {step}'**
  String wakeUpCardFirstStepShort(String step);

  /// Wake Up card chip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event today} other{{count} events today}}'**
  String wakeUpCardCalendar(int count);

  /// Wake Up card chip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 in Inbox} other{{count} in Inbox}}'**
  String wakeUpCardInbox(int count);

  /// Wake Up card: up this long after Wake Up (no-shame: never 'late').
  ///
  /// In en, this message translates to:
  /// **'You\'re up {min} min after plan.'**
  String wakeUpCardLate(int min);

  /// Notification health, under the Wake Up row.
  ///
  /// In en, this message translates to:
  /// **'Last wake-up: rang {rang}, up {up}'**
  String healthLastWakeUp(String rang, String up);

  /// Notification health when the ring time isn't known (iPhone).
  ///
  /// In en, this message translates to:
  /// **'Last wake-up: up {up}'**
  String healthLastWakeUpUp(String up);

  /// Notification health when it rang and stopped by itself.
  ///
  /// In en, this message translates to:
  /// **'Last wake-up: rang {rang}'**
  String healthLastWakeUpRang(String rang);

  /// Wake Up Check body when the first dot has no steps.
  ///
  /// In en, this message translates to:
  /// **'Tap to start.'**
  String get wakeUpCheckBody;

  /// Wake Up options: caption over the check rows.
  ///
  /// In en, this message translates to:
  /// **'Check I\'ve started'**
  String get wakeUpCheckCaption;

  /// Switch: the Wake Up Check.
  ///
  /// In en, this message translates to:
  /// **'Check I\'ve started'**
  String get wakeUpCheckRow;

  /// Under the Wake Up Check switch.
  ///
  /// In en, this message translates to:
  /// **'One nudge if nothing has started a few minutes after I\'m up'**
  String get wakeUpCheckRowDetail;

  /// Row: how the Wake Up Check comes (gentle ping or alarm).
  ///
  /// In en, this message translates to:
  /// **'As'**
  String get wakeUpCheckAsRow;

  /// Wake Up Check tier: a normal notification.
  ///
  /// In en, this message translates to:
  /// **'Gentle ping'**
  String get wakeUpCheckGentle;

  /// Wake Up Check tier: rings like the alarm, once.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get wakeUpCheckAlarm;

  /// Wake Up Check title when the first dot has no steps.
  ///
  /// In en, this message translates to:
  /// **'Start {title}?'**
  String wakeUpCheckStart(String title);

  /// Day shape row: how much sleep Wind Down plans for (docs/15 W4).
  ///
  /// In en, this message translates to:
  /// **'Sleep target'**
  String get settingsSleepTarget;

  /// Sleep target value: Wind Down stays as set.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsSleepTargetOff;

  /// Under the Sleep target row.
  ///
  /// In en, this message translates to:
  /// **'Wind Down moves earlier before an early morning'**
  String get settingsSleepTargetDetail;

  /// Switch: the night arc on the day dot (docs/15 W6).
  ///
  /// In en, this message translates to:
  /// **'Show the night on the day dot'**
  String get settingsShowNight;

  /// One-time offer in the Wind Down review for existing users (docs/15 §11).
  ///
  /// In en, this message translates to:
  /// **'New: tell Dottoday how much sleep you want, and Wind Down will move earlier before an early Wake Up.'**
  String get reviewSleepOffer;

  /// Sleep offer: save the sleep target.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get reviewSleepOfferSet;

  /// Sleep offer: declined for good (unlike the review's Not now, which is for today).
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get reviewSleepOfferLater;

  /// Onboarding day shape: the sleep slider's label (docs/15 W6).
  ///
  /// In en, this message translates to:
  /// **'How much sleep do you want?'**
  String get onboardingSleepTarget;

  /// The night on the day dot, read out and on a long-press.
  ///
  /// In en, this message translates to:
  /// **'Night · {length}'**
  String nightLabel(String length);

  /// Wind Down review's first line at or after Wind Down.
  ///
  /// In en, this message translates to:
  /// **'{length} until Wake Up at {time}'**
  String reviewNightUntil(String length, String time);

  /// Wind Down review's first line when opened before Wind Down.
  ///
  /// In en, this message translates to:
  /// **'{length} if you wind down now'**
  String reviewNightIfNow(String length);

  /// Wind Down reminder with a sleep target: what the night protects.
  ///
  /// In en, this message translates to:
  /// **'Wind down now for {length} before {title} at {time}.'**
  String notifWindDownNudge(String length, String title, String time);

  /// Wind Down reminder with a sleep target and no task tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Wind down now for {length} before {time}.'**
  String notifWindDownNudgeNoDot(String length, String time);

  /// Wind Down row value when a sleep target moved it.
  ///
  /// In en, this message translates to:
  /// **'{time} · from tomorrow\'s {wake}'**
  String settingsWindDownFrom(String time, String wake);

  /// Today's day card footer when tomorrow's early start moved Wind Down.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow starts {start} → wind down {windDown}'**
  String todayWindDownFooter(String start, String windDown);

  /// Onboarding day shape: Wind Down from the slider, live.
  ///
  /// In en, this message translates to:
  /// **'Wind Down {time} · {length} of sleep'**
  String onboardingWindDownLive(String time, String length);

  /// What's new in 1.2.0 (M15 sounds, M16 minimal layout, the Structured-style day, M17 Wake Up alarm), one item per line (PRD F11).
  ///
  /// In en, this message translates to:
  /// **'Wake Up alarm: turn it on in Settings › Day shape and your Wake Up time rings on days you\'ve planned — like an alarm on Android and on iPhones with iOS 26, as a time-sensitive notification on older iPhones. Pick its sound and snooze under Sound and snooze, and send yourself a test. Nothing rings until you turn it on.\nSounds: 48 reminder sounds made to sit well together. Pick one for every task or give a task its own; your first task of the day rings with your Start sound.\nJust the next dot: a minimal layout you can choose any time, with nothing lost. Today shows your thread, the date and one menu.\nDrag a task anywhere on the day, even onto another one: overlapping tasks tie a small knot in the thread.\nBedtime is now Wind Down. The two ends of your day are dots, a sun and a moon; tap one to change its time.\nIcons fill themselves in: type \"Gym\" and the task gets a dumbbell, from 524 icons.\nThe night: tell Dottoday how much sleep you want and Wind Down moves earlier before an early morning. The day dot shows the night, and the Wind Down review opens with it.'**
  String get releaseNotes120;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Planning & rhythm'**
  String get taskIconCategoryPlanning;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Health & body'**
  String get taskIconCategoryHealth;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Fitness & sport'**
  String get taskIconCategoryFitness;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Food & drink'**
  String get taskIconCategoryFood;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Home & chores'**
  String get taskIconCategoryHome;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Work & study'**
  String get taskIconCategoryWork;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Tech & devices'**
  String get taskIconCategoryTech;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Travel & transport'**
  String get taskIconCategoryTravel;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Nature & weather'**
  String get taskIconCategoryNature;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get taskIconCategoryAnimals;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'People & social'**
  String get taskIconCategoryPeople;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Leisure & hobbies'**
  String get taskIconCategoryLeisure;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Shopping & money'**
  String get taskIconCategoryShopping;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Clothing & beauty'**
  String get taskIconCategoryStyle;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Faith & celebrations'**
  String get taskIconCategoryFaith;

  /// Section title in the task icon picker.
  ///
  /// In en, this message translates to:
  /// **'Symbols & signs'**
  String get taskIconCategorySymbols;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Focus Block'**
  String get taskIconFocusBlock;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Deep Work'**
  String get taskIconDeepWork;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Plan the Day'**
  String get taskIconPlanTheDay;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Time Block'**
  String get taskIconTimeBlock;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Buffer'**
  String get taskIconBuffer;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get taskIconAnytime;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get taskIconTakeABreak;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Morning Routine'**
  String get taskIconMorningRoutine;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Evening Routine'**
  String get taskIconEveningRoutine;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Wind Down'**
  String get taskIconWindDown;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Power Nap'**
  String get taskIconPowerNap;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Week Review'**
  String get taskIconWeekReview;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Inbox Zero'**
  String get taskIconInboxZero;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get taskIconHabit;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Errands'**
  String get taskIconErrands;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Low Energy'**
  String get taskIconLowEnergy;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'High Energy'**
  String get taskIconHighEnergy;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Screen-free'**
  String get taskIconScreenFree;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Stand-up'**
  String get taskIconStandUp;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Self-care'**
  String get taskIconSelfCare;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Meal Prep'**
  String get taskIconMealPrep;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pay Bills'**
  String get taskIconPayBills;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get taskIconAllergens;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bandage'**
  String get taskIconBandage;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Blood Bag'**
  String get taskIconBloodBag;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Brain'**
  String get taskIconBrain;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Crutch'**
  String get taskIconCrutch;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get taskIconDoctor;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ear'**
  String get taskIconEar;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'ECG'**
  String get taskIconEcg;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Eyes'**
  String get taskIconEyes;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Face Mask'**
  String get taskIconFaceMask;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Falling'**
  String get taskIconFalling;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get taskIconHead;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hearing Device'**
  String get taskIconHearingDevice;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get taskIconHeart;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get taskIconHospital;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Lungs'**
  String get taskIconLungs;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Medical Thermometer'**
  String get taskIconMedicalThermometer;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Microbe'**
  String get taskIconMicrobe;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get taskIconPharmacy;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pill'**
  String get taskIconMeds;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pills'**
  String get taskIconPills;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get taskIconSleep;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Sleepy Moon'**
  String get taskIconSleepyMoon;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Standing'**
  String get taskIconStanding;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Star of Life'**
  String get taskIconStarOfLife;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Syringe'**
  String get taskIconSyringe;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Therapy'**
  String get taskIconTherapy;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Tooth'**
  String get taskIconTooth;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Toothbrush'**
  String get taskIconToothbrush;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Vial'**
  String get taskIconVial;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Wheelchair'**
  String get taskIconWheelchair;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'American Football'**
  String get taskIconAmericanFootball;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Archery'**
  String get taskIconArchery;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Australian Football'**
  String get taskIconAustralianFootball;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Baseball'**
  String get taskIconBaseball;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get taskIconBasketball;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bowling'**
  String get taskIconBowling;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Core Training'**
  String get taskIconCoreTraining;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Cricket'**
  String get taskIconCricket;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Cross Training'**
  String get taskIconCrossTraining;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Curling'**
  String get taskIconCurling;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get taskIconCycling;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Dancing'**
  String get taskIconDancing;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get taskIconGym;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Fencing'**
  String get taskIconFencing;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Golf'**
  String get taskIconGolf;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Gymnastics'**
  String get taskIconGymnastics;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Handball'**
  String get taskIconHandball;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Helmet'**
  String get taskIconHelmet;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'HIIT'**
  String get taskIconHiit;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get taskIconHiking;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Horse Riding'**
  String get taskIconHorseRiding;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ice Skates'**
  String get taskIconIceSkates;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Jogging'**
  String get taskIconJogging;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Martial Arts'**
  String get taskIconMartialArts;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Medal'**
  String get taskIconMedal;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pool Swimming'**
  String get taskIconPoolSwimming;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Rope Jumping'**
  String get taskIconRopeJumping;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Rowing'**
  String get taskIconRowing;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Rugby'**
  String get taskIconRugby;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get taskIconRun;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Sailing'**
  String get taskIconSailing;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Scuba Diving'**
  String get taskIconScubaDiving;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Skateboard'**
  String get taskIconSkateboard;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Skating'**
  String get taskIconSkating;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Skiing'**
  String get taskIconSkiing;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Snowboard'**
  String get taskIconSnowboard;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Snowboarding'**
  String get taskIconSnowboarding;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Soccer'**
  String get taskIconSoccer;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Softball'**
  String get taskIconSoftball;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Sportcourt'**
  String get taskIconSportcourt;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Stair Stepper'**
  String get taskIconStairStepper;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Stepping'**
  String get taskIconStepping;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get taskIconStopwatch;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get taskIconStretching;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get taskIconSwimming;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Table Tennis'**
  String get taskIconTableTennis;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get taskIconTennis;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Track and Field'**
  String get taskIconTrackAndField;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Trophy'**
  String get taskIconTrophy;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Volleyball'**
  String get taskIconVolleyball;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get taskIconWalking;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Water Polo'**
  String get taskIconWaterPolo;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Weight Lifting'**
  String get taskIconWeightLifting;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get taskIconYoga;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get taskIconAlcohol;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get taskIconApple;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Beer'**
  String get taskIconBeer;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Burger'**
  String get taskIconBurger;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Candy'**
  String get taskIconCandy;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Carrot'**
  String get taskIconCarrot;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Cheese'**
  String get taskIconCheese;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Chopsticks'**
  String get taskIconChopsticks;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get taskIconCoffee;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get taskIconCooking;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Cooking Stove'**
  String get taskIconCookingStove;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Cup'**
  String get taskIconCup;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Dumplings'**
  String get taskIconDumplings;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Frying Pan'**
  String get taskIconFryingPan;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ice Cream'**
  String get taskIconIceCream;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get taskIconMeal;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Microwave'**
  String get taskIconMicrowave;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Mug'**
  String get taskIconMug;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Oven'**
  String get taskIconOven;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pizza'**
  String get taskIconPizza;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Popcorn'**
  String get taskIconPopcorn;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Soup'**
  String get taskIconSoup;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Takeout'**
  String get taskIconTakeout;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Tray'**
  String get taskIconTray;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Water Bottle'**
  String get taskIconWaterBottle;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Water Glass'**
  String get taskIconWater;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Wine Glass'**
  String get taskIconWineGlass;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Wrap'**
  String get taskIconWrap;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Air Conditioner'**
  String get taskIconAirConditioner;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Air Purifier'**
  String get taskIconAirPurifier;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ax'**
  String get taskIconAx;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bathtub'**
  String get taskIconBathtub;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get taskIconBed;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Blinds'**
  String get taskIconBlinds;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bookshelf'**
  String get taskIconBookshelf;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get taskIconBox;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Broom'**
  String get taskIconBroom;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ceiling Fan'**
  String get taskIconCeilingFan;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ceiling Lamp'**
  String get taskIconCeilingLamp;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Chair'**
  String get taskIconChair;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Chair Lounge'**
  String get taskIconChairLounge;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Couch'**
  String get taskIconCouch;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Dehumidifier'**
  String get taskIconDehumidifier;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Dishwasher'**
  String get taskIconDishwasher;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Door'**
  String get taskIconDoor;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Dryer'**
  String get taskIconDryer;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Duster'**
  String get taskIconDuster;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Fan'**
  String get taskIconFan;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Fireplace'**
  String get taskIconFireplace;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Floor Lamp'**
  String get taskIconFloorLamp;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get taskIconFridge;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get taskIconGarage;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hammer'**
  String get taskIconHammer;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Heater'**
  String get taskIconHeater;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get taskIconHome;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'House with Flag'**
  String get taskIconHouseWithFlag;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Humidifier'**
  String get taskIconHumidifier;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Iron'**
  String get taskIconIron;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get taskIconKey;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Laundry Basket'**
  String get taskIconLaundryBasket;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Lawn Mower'**
  String get taskIconLawnMower;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get taskIconLevel;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Light Bulb'**
  String get taskIconLightBulb;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Mop'**
  String get taskIconMop;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Potted Plant'**
  String get taskIconPottedPlant;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Rake'**
  String get taskIconRake;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Recycling'**
  String get taskIconRecycling;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Refrigerator'**
  String get taskIconRefrigerator;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Shade Roller'**
  String get taskIconShadeRoller;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Shades'**
  String get taskIconShades;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Shovel'**
  String get taskIconShovel;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Shower'**
  String get taskIconShower;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Sink'**
  String get taskIconSink;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Snow Shovel'**
  String get taskIconSnowShovel;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Soap'**
  String get taskIconSoap;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Stairs'**
  String get taskIconStairs;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get taskIconTable;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Table Lamp'**
  String get taskIconTableLamp;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Toilet'**
  String get taskIconToilet;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Toilet Paper'**
  String get taskIconToiletPaper;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get taskIconTrash;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Vacuum'**
  String get taskIconVacuum;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Washing Machine'**
  String get taskIconWashingMachine;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Watering Can'**
  String get taskIconWateringCan;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Wrench'**
  String get taskIconWrench;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'All Day Task'**
  String get taskIconAllDayTask;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Biology'**
  String get taskIconBiology;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Blackboard'**
  String get taskIconBlackboard;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get taskIconBook;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get taskIconBookmark;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Briefcase'**
  String get taskIconBriefcase;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get taskIconBuilding;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get taskIconCalendar;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get taskIconList;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Chemistry'**
  String get taskIconChemistry;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Clipboard'**
  String get taskIconClipboard;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get taskIconCode;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Desk Globe'**
  String get taskIconDeskGlobe;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Desk Lamp'**
  String get taskIconDeskLamp;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get taskIconDocument;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get taskIconEmail;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get taskIconFile;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get taskIconFolder;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Highlighter'**
  String get taskIconHighlighter;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get taskIconIdCard;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get taskIconLanguage;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Law'**
  String get taskIconLaw;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Loupe'**
  String get taskIconLoupe;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Mail'**
  String get taskIconMail;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get taskIconMath;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Paperclip'**
  String get taskIconPaperclip;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pencil'**
  String get taskIconPencil;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pencil and Ruler'**
  String get taskIconPencilAndRuler;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get taskIconPhysics;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get taskIconQuote;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get taskIconReminders;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ruler'**
  String get taskIconRuler;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get taskIconSchool;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Scissors'**
  String get taskIconScissors;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get taskIconSignature;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet'**
  String get taskIconSpreadsheet;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Student Desk'**
  String get taskIconStudentDesk;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskIconTask;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Test Tube'**
  String get taskIconTestTube;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get taskIconWriting;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Zip'**
  String get taskIconZip;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get taskIconBattery;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Captions'**
  String get taskIconCaptions;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Computer Mouse'**
  String get taskIconComputerMouse;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Connector'**
  String get taskIconConnector;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'CPU'**
  String get taskIconCpu;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Curly Braces'**
  String get taskIconCurlyBraces;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get taskIconDesktop;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Dial'**
  String get taskIconDial;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Disk'**
  String get taskIconDisk;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Fax'**
  String get taskIconFax;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Flashlight'**
  String get taskIconFlashlight;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Flipphone'**
  String get taskIconFlipphone;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Gears'**
  String get taskIconGears;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Gyroscope'**
  String get taskIconGyroscope;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hard Drive'**
  String get taskIconHardDrive;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Headphones'**
  String get taskIconHeadphones;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get taskIconKeyboard;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get taskIconLink;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get taskIconMerge;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Mic'**
  String get taskIconMic;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get taskIconCall;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Plug'**
  String get taskIconPlug;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get taskIconPower;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Printer'**
  String get taskIconPrinter;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get taskIconScanner;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'SD Card'**
  String get taskIconSdCard;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Simcard'**
  String get taskIconSimcard;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get taskIconSpeaker;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get taskIconTerminal;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get taskIconUpload;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Video Projector'**
  String get taskIconVideoProjector;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get taskIconWatch;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get taskIconWeb;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Wifi'**
  String get taskIconWifi;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Wifi Router'**
  String get taskIconWifiRouter;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Windows'**
  String get taskIconWindows;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Airplane'**
  String get taskIconTravel;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get taskIconArrival;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Arriving'**
  String get taskIconArriving;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Backpack'**
  String get taskIconBackpack;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get taskIconBeach;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get taskIconBike;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Boat'**
  String get taskIconBoat;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get taskIconBus;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Cablecar'**
  String get taskIconCablecar;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get taskIconCar;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get taskIconCase;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Chinese Castle'**
  String get taskIconChineseCastle;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Colosseum'**
  String get taskIconColosseum;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get taskIconCompass;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get taskIconDeparture;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Doubledecker Bus'**
  String get taskIconDoubledeckerBus;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Electric Car'**
  String get taskIconElectricCar;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get taskIconEngine;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ferry'**
  String get taskIconFerry;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Gas Station'**
  String get taskIconGasStation;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Globe'**
  String get taskIconGlobe;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Globe Americas'**
  String get taskIconGlobeAmericas;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Globe Asia'**
  String get taskIconGlobeAsia;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Globe Asia-Pacific'**
  String get taskIconGlobeAsiaPacific;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Globe Europe Africa'**
  String get taskIconGlobeEuropeAfrica;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Leaving'**
  String get taskIconLeaving;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Life Preserver'**
  String get taskIconLifePreserver;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Lightrail'**
  String get taskIconLightrail;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get taskIconLocation;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Lodge'**
  String get taskIconLodge;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get taskIconMap;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get taskIconMotorcycle;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Oil Can'**
  String get taskIconOilCan;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Road'**
  String get taskIconRoad;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Rocket'**
  String get taskIconRocket;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Rolling Suitcase'**
  String get taskIconRollingSuitcase;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Scooter'**
  String get taskIconScooter;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ship'**
  String get taskIconShip;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Signpost'**
  String get taskIconSignpost;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ski Lift'**
  String get taskIconSkiLift;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Steering Wheel'**
  String get taskIconSteeringWheel;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Subway'**
  String get taskIconSubway;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Suitcase'**
  String get taskIconSuitcase;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Suitcase Cart'**
  String get taskIconSuitcaseCart;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Tent'**
  String get taskIconTent;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get taskIconTrain;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get taskIconTruck;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Windshield'**
  String get taskIconWindshield;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Barometer'**
  String get taskIconBarometer;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get taskIconCloud;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get taskIconDrizzle;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Flame'**
  String get taskIconFlame;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Flower'**
  String get taskIconFlower;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Flowers'**
  String get taskIconFlowers;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get taskIconFog;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Fossil'**
  String get taskIconFossil;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hail'**
  String get taskIconHail;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Leaf'**
  String get taskIconLeaf;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get taskIconMoon;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Moon Haze'**
  String get taskIconMoonHaze;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get taskIconMountain;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Mushroom'**
  String get taskIconMushroom;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Palm Tree'**
  String get taskIconPalmTree;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Partial Sun'**
  String get taskIconPartialSun;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get taskIconPlant;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get taskIconRain;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Rainbow'**
  String get taskIconRainbow;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Seedling'**
  String get taskIconSeedling;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Sleet'**
  String get taskIconSleet;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get taskIconSnow;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Snowflake'**
  String get taskIconSnowflake;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Snowman'**
  String get taskIconSnowman;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Storm'**
  String get taskIconStorm;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get taskIconSun;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Sun Haze'**
  String get taskIconSunHaze;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get taskIconSunrise;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get taskIconSunset;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get taskIconTemperature;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get taskIconThunderstorm;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Tree'**
  String get taskIconTree;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Umbrella'**
  String get taskIconUmbrella;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Waves'**
  String get taskIconWaves;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get taskIconWind;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ant'**
  String get taskIconAnt;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bird'**
  String get taskIconBird;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get taskIconBug;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get taskIconCat;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Chicken'**
  String get taskIconChicken;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get taskIconDog;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get taskIconFish;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hamster'**
  String get taskIconHamster;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Horse'**
  String get taskIconHorse;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Mouse'**
  String get taskIconMouse;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Paw'**
  String get taskIconPet;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pet Food Bowl'**
  String get taskIconPetFoodBowl;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pig'**
  String get taskIconPig;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get taskIconRabbit;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Tortoise'**
  String get taskIconTortoise;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Walking Cat'**
  String get taskIconWalkingCat;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Walking Dog'**
  String get taskIconWalkingDog;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get taskIconBaby;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Baby Bottle'**
  String get taskIconBabyBottle;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ballot Box'**
  String get taskIconBallotBox;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Broken Heart'**
  String get taskIconBrokenHeart;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Couple'**
  String get taskIconCouple;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get taskIconFamily;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get taskIconPeople;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hand'**
  String get taskIconHand;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Handshake'**
  String get taskIconHandshake;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get taskIconMessage;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get taskIconPerson;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Sign Language'**
  String get taskIconSignLanguage;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Smile'**
  String get taskIconSmile;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Stroller'**
  String get taskIconStroller;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Two Persons'**
  String get taskIconTwoPersons;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Waving'**
  String get taskIconWaving;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Amplifier'**
  String get taskIconAmplifier;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Aperture'**
  String get taskIconAperture;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Binoculars'**
  String get taskIconBinoculars;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get taskIconCamera;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Checkerboard'**
  String get taskIconCheckerboard;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Chess'**
  String get taskIconChess;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get taskIconClub;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get taskIconDice;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Drums'**
  String get taskIconDrums;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Eyedropper'**
  String get taskIconEyedropper;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Film'**
  String get taskIconFilm;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Fishing'**
  String get taskIconFishing;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get taskIconGaming;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Guitar'**
  String get taskIconGuitar;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Horn'**
  String get taskIconHorn;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hunting'**
  String get taskIconHunting;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Magazine'**
  String get taskIconMagazine;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Magic'**
  String get taskIconMagic;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Metronome'**
  String get taskIconMetronome;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get taskIconMovie;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Movie Clapper'**
  String get taskIconMovieClapper;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get taskIconMusic;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Newspaper'**
  String get taskIconNewspaper;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Paint Palette'**
  String get taskIconPaintPalette;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Paintbrush'**
  String get taskIconPaintbrush;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get taskIconPhoto;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Piano'**
  String get taskIconPiano;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Playground'**
  String get taskIconPlayground;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Puzzle'**
  String get taskIconPuzzle;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get taskIconRadio;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Recording Tape'**
  String get taskIconRecordingTape;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Sewing Machine'**
  String get taskIconSewingMachine;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Singing'**
  String get taskIconSinging;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Spade'**
  String get taskIconSpade;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Swatch Palette'**
  String get taskIconSwatchPalette;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Theater'**
  String get taskIconTheater;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get taskIconTicket;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Tuning'**
  String get taskIconTuning;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get taskIconTv;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bag'**
  String get taskIconBag;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Banknote'**
  String get taskIconBanknote;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get taskIconBarcode;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Basket'**
  String get taskIconBasket;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bitcoin'**
  String get taskIconBitcoin;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get taskIconCart;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get taskIconCoin;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Creditcard'**
  String get taskIconCreditcard;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get taskIconEuro;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get taskIconGift;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Giftcard'**
  String get taskIconGiftcard;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get taskIconMoney;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Parcel'**
  String get taskIconParcel;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Storefront'**
  String get taskIconStorefront;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get taskIconTag;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Wallet Pass'**
  String get taskIconWalletPass;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Clothes Hanger'**
  String get taskIconClothesHanger;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get taskIconDiamond;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Dress'**
  String get taskIconDress;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get taskIconGlasses;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hair Dresser'**
  String get taskIconHairDresser;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hairdryer'**
  String get taskIconHairdryer;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hat'**
  String get taskIconHat;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Jacket'**
  String get taskIconJacket;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Mustache'**
  String get taskIconMustache;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Purse'**
  String get taskIconPurse;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Razor'**
  String get taskIconRazor;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ring'**
  String get taskIconRing;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Shoe'**
  String get taskIconShoe;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get taskIconShoes;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Skin Care'**
  String get taskIconSkinCare;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Sunglasses'**
  String get taskIconSunglasses;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'T-Shirt'**
  String get taskIconTShirt;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Trousers'**
  String get taskIconTrousers;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Winter Jacket'**
  String get taskIconWinterJacket;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Balloons'**
  String get taskIconBalloons;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get taskIconBirthday;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Buddhism'**
  String get taskIconBuddhism;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Candle'**
  String get taskIconCandle;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Christmas Tree'**
  String get taskIconChristmasTree;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Church'**
  String get taskIconChurch;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Cross'**
  String get taskIconCross;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Fireworks'**
  String get taskIconFireworks;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Ghost'**
  String get taskIconGhost;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Gravestone'**
  String get taskIconGravestone;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Halloween'**
  String get taskIconHalloween;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hinduism'**
  String get taskIconHinduism;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Islam'**
  String get taskIconIslam;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Judaism'**
  String get taskIconJudaism;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Mosque'**
  String get taskIconMosque;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get taskIconParty;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pray'**
  String get taskIconPray;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Taoism'**
  String get taskIconTaoism;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get taskIconAlarm;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bar Chart'**
  String get taskIconBarChart;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bell'**
  String get taskIconBell;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bolt'**
  String get taskIconBolt;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bubble'**
  String get taskIconBubble;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Bubbles'**
  String get taskIconBubbles;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get taskIconClock;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Crown'**
  String get taskIconCrown;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Cube'**
  String get taskIconCube;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get taskIconDanger;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get taskIconError;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Explosion'**
  String get taskIconExplosion;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Female Symbol'**
  String get taskIconFemaleSymbol;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get taskIconFilters;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get taskIconFlag;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hashtag'**
  String get taskIconHashtag;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hazard Sign'**
  String get taskIconHazardSign;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Hourglass'**
  String get taskIconHourglass;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Line Chart'**
  String get taskIconLineChart;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Line Chart Down'**
  String get taskIconLineChartDown;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Line Chart Up'**
  String get taskIconLineChartUp;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get taskIconLocked;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Male Symbol'**
  String get taskIconMaleSymbol;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Megaphone'**
  String get taskIconMegaphone;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get taskIconMenu;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Minus'**
  String get taskIconMinus;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Non-Binary Symbol'**
  String get taskIconNonBinarySymbol;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Peace'**
  String get taskIconPeace;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pie Chart'**
  String get taskIconPieChart;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get taskIconPin;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Plus'**
  String get taskIconPlus;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get taskIconQrCode;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get taskIconQuestion;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get taskIconSearch;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Shield'**
  String get taskIconShield;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Skull'**
  String get taskIconSkull;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get taskIconSpeed;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get taskIconStar;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get taskIconTarget;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Thumbs Down'**
  String get taskIconThumbsDown;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Thumbs Up'**
  String get taskIconThumbsUp;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get taskIconTimer;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Transgender Symbol'**
  String get taskIconTransgenderSymbol;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Transparent Cube'**
  String get taskIconTransparentCube;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get taskIconUnlock;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get taskIconWarning;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Wrong Way Sign'**
  String get taskIconWrongWaySign;

  /// Task icon name (icon picker, icon search, screen readers).
  ///
  /// In en, this message translates to:
  /// **'Plain'**
  String get taskIconCircle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
