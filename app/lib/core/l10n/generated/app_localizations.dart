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
  /// **'Bedtime reminder'**
  String get alertsBedtime;

  /// Under the Bedtime reminder switch.
  ///
  /// In en, this message translates to:
  /// **'Every evening, with tomorrow\'s first task'**
  String get alertsBedtimeDetail;

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
  /// **'Dottoday reminds you when a task starts and before bedtime. You can change this any time in Settings.'**
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

  /// Onboarding O4: the Bedtime reminder switch.
  ///
  /// In en, this message translates to:
  /// **'At Bedtime'**
  String get onboardingBedtime;

  /// Onboarding O4: under the Bedtime switch.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow\'s first task, so the morning has no surprises'**
  String get onboardingBedtimeDetail;

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
  /// **'Tomorrow, from Wake Up to Bedtime. Add to it, drag things around, or start with today.'**
  String get onboardingDoneBody;

  /// Onboarding O6 when no habits were picked.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, from Wake Up to Bedtime, is all yours. Add the first task whenever you like.'**
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

  /// Title of the Bedtime reminder.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get notifBedtimeTitle;

  /// Bedtime reminder body.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow starts with {title} at {time}.'**
  String notifBedtimeFirst(String title, String time);

  /// Bedtime reminder body when tomorrow is empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for tomorrow yet.'**
  String get notifBedtimeFree;

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
  /// **'Bedtime'**
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

  /// Folded 'outside hours' row below the Bedtime cap (docs/02 F1.15): tasks that start at Bedtime or later. Tapping unfolds them.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task after Bedtime} other{{count} tasks after Bedtime}}'**
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
