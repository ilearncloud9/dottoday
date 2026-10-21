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

  /// Heading of the block colour choices.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colorPickerLabel;

  /// Heading of the block icon choices.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconPickerLabel;

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
