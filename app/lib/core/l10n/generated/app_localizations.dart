import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

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
  /// **'It\'s too late to undo that. Deleted tasks stay in Trash for 30 days.'**
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

  /// Block icon name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Plain'**
  String get iconCircle;

  /// Block icon name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get iconCall;

  /// Block icon name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get iconMail;

  /// Block icon name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get iconCode;

  /// Block icon name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get iconBook;

  /// Block icon name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get iconGym;

  /// Block icon name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get iconRun;

  /// Block icon name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get iconMeal;

  /// Block icon name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get iconHeart;

  /// Block icon name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get iconHome;

  /// Block icon name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get iconMusic;

  /// Block icon name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get iconPet;

  /// Block icon name (screen readers, picker).
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get iconStar;

  /// Task icon name (list), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get iconList;

  /// Task icon name (language), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get iconLanguage;

  /// Task icon name (travel), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get iconTravel;

  /// Task icon name (shopping cart), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'Shopping cart'**
  String get iconCart;

  /// Task icon name (tv), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get iconTv;

  /// Task icon name (shopping bag), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'Shopping bag'**
  String get iconBag;

  /// Task icon name (medication), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get iconMeds;

  /// Task icon name (water), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get iconWater;

  /// Task icon name (car), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get iconCar;

  /// Task icon name (money), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get iconMoney;

  /// Task icon name (gift), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get iconGift;

  /// Task icon name (camera), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get iconCamera;

  /// Task icon name (people), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get iconPeople;

  /// Task icon name (document), read by screen readers and shown as the picker tooltip.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get iconDocument;

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
  /// **'{title}, missed'**
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

  /// Screen-reader label of a task row: title and time range.
  ///
  /// In en, this message translates to:
  /// **'{title}, {range}'**
  String rowLabel(String title, String range);

  /// Appended to a row label when the task was missed.
  ///
  /// In en, this message translates to:
  /// **'{label}, missed'**
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
  /// **'· missed'**
  String get rowMissedMeta;

  /// Sun cap at the top of the day's thread (Main).
  ///
  /// In en, this message translates to:
  /// **'Wake Up · {time}'**
  String threadWake(String time);

  /// Moon cap at the end of the day's thread (Main).
  ///
  /// In en, this message translates to:
  /// **'Bedtime · {time}'**
  String threadBed(String time);

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

  /// Screen-reader label of the day dot: share of Wake Up → Bedtime elapsed.
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
  /// **'{title} · missed'**
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

  /// Opens the grid of all 26 task icons.
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

  /// Screen-reader label of a task's resize grip; increase / decrease change the length.
  ///
  /// In en, this message translates to:
  /// **'Change how long {title} takes'**
  String resizeLabel(String title);

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

  /// Snackbar after resizing a task, with Undo.
  ///
  /// In en, this message translates to:
  /// **'{title} now ends at {time}'**
  String snackResized(String title, String time);

  /// Toggle chip shown while dragging a task: when on, the tasks after it move along (R-04). Desktop: hold Alt to invert.
  ///
  /// In en, this message translates to:
  /// **'Shift later tasks'**
  String get shiftChipLabel;

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

  /// Duration sheet preview: nothing follows until Bedtime.
  ///
  /// In en, this message translates to:
  /// **'Fits before Bedtime at {time}'**
  String durationFitsBedtime(String time);

  /// Duration sheet preview: the task overlaps the next one.
  ///
  /// In en, this message translates to:
  /// **'Runs into {title} at {time}'**
  String durationRunsInto(String title, String time);

  /// Duration sheet preview: the task ends after Bedtime.
  ///
  /// In en, this message translates to:
  /// **'Runs past Bedtime at {time}'**
  String durationPastBedtime(String time);

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
  /// **'{when} · missed'**
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
  /// **'Bedtime'**
  String get settingsBedtime;

  /// Settings row: per-weekday Wake Up / Bedtime.
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
  /// **'Bedtime reminder'**
  String get settingsBedtimeReminder;

  /// Subtitle of Bedtime reminder.
  ///
  /// In en, this message translates to:
  /// **'At {time}, with tomorrow\'s first task'**
  String settingsBedtimeReminderDetail(String time);

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

  /// Settings row; also the sheet's title.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get settingsWhatsNew;

  /// What's new sheet body for this version.
  ///
  /// In en, this message translates to:
  /// **'Add a task in two taps, with suggestions from your habits. Pick a time on your day\'s thread and see what it overlaps. Keep your own duration presets. Paste a list to add several tasks at once. Search everything you\'ve planned, done tasks too.'**
  String get settingsWhatsNewBody;

  /// Settings row; also the sheet's title.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get settingsFeedback;

  /// Feedback sheet intro.
  ///
  /// In en, this message translates to:
  /// **'Opens an email draft. Nothing about your tasks is included.'**
  String get settingsFeedbackIntro;

  /// Feedback switch: diagnostics opt-in.
  ///
  /// In en, this message translates to:
  /// **'Add app version and device type'**
  String get settingsFeedbackDiagnostics;

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
  /// **'{done} done · {missed} missed · {ahead} ahead'**
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
