// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dottoday';

  @override
  String get failureStorage => 'Couldn\'t save on this device. Try again.';

  @override
  String get failureNetworkOffline =>
      'You\'re offline. Changes are saved on this device and will sync later.';

  @override
  String get failureNetworkTimeout =>
      'The server took too long to respond. Try again.';

  @override
  String get failureNetworkServer =>
      'The server had a problem. Your data is safe on this device.';

  @override
  String get failureAuth =>
      'Your session has ended. Sign in again to keep syncing.';

  @override
  String get failureValidationRequired => 'This can\'t be empty.';

  @override
  String get failureValidationTooLong =>
      'That\'s too long. Try something shorter.';

  @override
  String get failureValidationOutOfRange =>
      'That value is outside the allowed range.';

  @override
  String get failureValidationInvalidFormat =>
      'That doesn\'t look right. Check the format.';

  @override
  String get failureValidationTooLarge => 'That file is too large.';

  @override
  String get failureNotFound => 'This item no longer exists.';

  @override
  String get failureConflict =>
      'This item changed on another device. Choose which version to keep.';

  @override
  String get failurePermissionNotifications =>
      'Notifications are off for Dottoday. You can turn them on in system settings.';

  @override
  String get failurePermissionCalendar =>
      'Dottoday can\'t see your calendars. You can allow access in system settings.';

  @override
  String get failureUndoExpired =>
      'It\'s too late to undo that. Deleted tasks stay in Trash for 30 days.';

  @override
  String get failureUnexpected => 'Something went wrong. Try again.';

  @override
  String get navToday => 'Today';

  @override
  String get navInbox => 'Inbox';

  @override
  String get navWeek => 'Week';

  @override
  String get navSearch => 'Search';

  @override
  String get navSettings => 'Settings';

  @override
  String get quickAddTooltip => 'Add task';

  @override
  String get sheetClose => 'Close';

  @override
  String get timeInputLabel => 'Time';

  @override
  String get timeInputHint => 'e.g. 9:30 or 2pm';

  @override
  String get timeInputInvalid => 'Type a time like 9:30 or 2pm';

  @override
  String get timeInputWheel => 'Pick time with a wheel';

  @override
  String get timeInputDone => 'Done';

  @override
  String get durationLabel => 'Duration';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get durationCustom => 'Custom';

  @override
  String get durationCustomHint => 'e.g. 40m or 1h30';

  @override
  String get durationCustomInvalid => 'Use 5 min to 24 h, like 40m or 1h30';

  @override
  String get colorCoral => 'Coral';

  @override
  String get colorAmber => 'Amber';

  @override
  String get colorMint => 'Mint';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorSky => 'Sky';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorViolet => 'Violet';

  @override
  String get colorRose => 'Rose';

  @override
  String get colorSlate => 'Slate';

  @override
  String get iconCircle => 'Plain';

  @override
  String get iconCall => 'Call';

  @override
  String get iconMail => 'Email';

  @override
  String get iconCode => 'Code';

  @override
  String get iconBook => 'Reading';

  @override
  String get iconGym => 'Gym';

  @override
  String get iconRun => 'Run';

  @override
  String get iconMeal => 'Meal';

  @override
  String get iconHeart => 'Health';

  @override
  String get iconHome => 'Home';

  @override
  String get iconMusic => 'Music';

  @override
  String get iconPet => 'Pet';

  @override
  String get iconStar => 'Star';

  @override
  String get iconList => 'List';

  @override
  String get iconLanguage => 'Language';

  @override
  String get iconTravel => 'Travel';

  @override
  String get iconCart => 'Shopping cart';

  @override
  String get iconTv => 'TV';

  @override
  String get iconBag => 'Shopping bag';

  @override
  String get iconMeds => 'Medication';

  @override
  String get iconWater => 'Water';

  @override
  String get iconCar => 'Car';

  @override
  String get iconMoney => 'Money';

  @override
  String get iconGift => 'Gift';

  @override
  String get iconCamera => 'Camera';

  @override
  String get iconPeople => 'People';

  @override
  String get iconDocument => 'Document';

  @override
  String get undoAction => 'Undo';

  @override
  String get syncLocalOnly => 'On this device';

  @override
  String get syncSynced => 'Synced';

  @override
  String get syncSyncing => 'Syncing';

  @override
  String get syncOffline => 'Offline';

  @override
  String get syncError => 'Sync problem';

  @override
  String timelineNow(String time) {
    return 'Now, $time';
  }

  @override
  String timelineBeforeHours(String time) {
    return 'Before $time';
  }

  @override
  String timelineAfterHours(String time) {
    return 'After $time';
  }

  @override
  String timelineMoreBlocks(int count) {
    return '+$count';
  }

  @override
  String timelineMoreBlocksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more blocks',
      one: '1 more block',
    );
    return '$_temp0';
  }

  @override
  String get timelineAllDay => 'All day';

  @override
  String blockTimeRange(String start, String end) {
    return '$start–$end';
  }

  @override
  String blockSemantics(String title, String start, String end) {
    return '$title, $start to $end';
  }

  @override
  String get timelineMenu => 'More options';

  @override
  String get debugLoadDemoDay => 'Load demo day (debug)';

  @override
  String get debugDemoDayLoaded => 'Demo day loaded';

  @override
  String get semanticsSeparator => ', ';

  @override
  String get blockDone => 'done';

  @override
  String get blockNotDoneYet => 'not done yet';

  @override
  String blockSubtasks(int done, int total) {
    return '$done of $total subtasks done';
  }

  @override
  String blockSubtasksShort(int done, int total) {
    return '$done/$total';
  }

  @override
  String get blockRecurring => 'recurring';

  @override
  String get blockPinned => 'pinned';

  @override
  String get blockFromCalendar => 'from your calendar';

  @override
  String blockAlerts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alerts',
      one: '1 alert',
    );
    return '$_temp0';
  }

  @override
  String get blockStartsBefore => 'continues from the previous day';

  @override
  String get blockEndsAfter => 'continues into the next day';

  @override
  String blockMarkDone(String title) {
    return 'Mark $title done';
  }

  @override
  String blockMarkNotDone(String title) {
    return 'Mark $title not done';
  }

  @override
  String get undoMarkedDone => 'Marked done';

  @override
  String get undoMarkedNotDone => 'Marked not done';

  @override
  String dotUpcoming(String title) {
    return '$title, upcoming';
  }

  @override
  String dotLive(String title) {
    return '$title, live';
  }

  @override
  String dotLiveLeft(String title, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes left',
      one: '1 minute left',
    );
    return '$title, live, $_temp0';
  }

  @override
  String dotDone(String title) {
    return '$title, done';
  }

  @override
  String dotSkipped(String title) {
    return '$title, skipped';
  }

  @override
  String dotMissed(String title) {
    return '$title, missed';
  }

  @override
  String get dotMarkDoneHint => 'Mark done';

  @override
  String get dotMarkNotDoneHint => 'Mark not done';

  @override
  String rowLabel(String title, String range) {
    return '$title, $range';
  }

  @override
  String rowMissed(String label) {
    return '$label, missed';
  }

  @override
  String rowPinned(String label) {
    return '$label, pinned';
  }

  @override
  String rowRepeats(String label) {
    return '$label, repeats';
  }

  @override
  String get rowMissedMeta => '· missed';

  @override
  String threadWake(String time) {
    return 'Wake Up · $time';
  }

  @override
  String threadBed(String time) {
    return 'Bedtime · $time';
  }

  @override
  String threadFree(String duration) {
    return '$duration free';
  }

  @override
  String threadAddHere(String duration) {
    return '$duration free · add here';
  }

  @override
  String threadAddHereLabel(String duration, String time) {
    return '$duration free from $time. Add a task here';
  }

  @override
  String liveSubtasks(int done, int total) {
    return '$done of $total';
  }

  @override
  String liveMinutesLeft(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min left',
      one: '1 min left',
    );
    return '$_temp0';
  }

  @override
  String get liveDone => 'Done';

  @override
  String get liveExtend => '+15 min';

  @override
  String get liveShiftRest => 'Shift the rest';

  @override
  String durationHoursMinutesShort(int hours, int minutes) {
    return '$hours h $minutes';
  }

  @override
  String liveMeta(String range, String duration) {
    return '$range · $duration';
  }

  @override
  String rowWithSubtasks(String label, String progress) {
    return '$label, $progress';
  }

  @override
  String dayDotLabel(int percent) {
    return 'Day $percent % through';
  }

  @override
  String get weekStripShowMonth => 'Show month';

  @override
  String get weekStripHideMonth => 'Hide month';

  @override
  String get dayCardTodaySuffix => ' · Today';

  @override
  String dayCardSummary(int done, int total, String planned) {
    return '$done of $total · $planned planned';
  }

  @override
  String dayCardNothing(String free) {
    return 'Nothing planned · $free free';
  }

  @override
  String dayPagerPosition(int position, int count) {
    return 'Day $position of $count';
  }

  @override
  String monthMore(int count) {
    return '+$count more';
  }

  @override
  String monthDoneOf(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get monthLightDay => 'Light day';

  @override
  String monthMissedItem(String title) {
    return '$title · missed';
  }

  @override
  String monthNowItem(String title) {
    return '$title · now';
  }

  @override
  String threadTimeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get debugConceptPreview => 'Concept A preview (debug)';

  @override
  String todayGreeting(String part) {
    String _temp0 = intl.Intl.selectLogic(part, {
      'morning': 'Good morning',
      'afternoon': 'Good afternoon',
      'other': 'Good evening',
    });
    return '$_temp0';
  }

  @override
  String todayGreetingName(String part, String name) {
    String _temp0 = intl.Intl.selectLogic(part, {
      'morning': 'Good morning, $name',
      'afternoon': 'Good afternoon, $name',
      'other': 'Good evening, $name',
    });
    return '$_temp0';
  }

  @override
  String get todayEmpty => 'Nothing planned · pull the strip to plan or tap +';

  @override
  String get todayAllDay => 'All day';

  @override
  String stripDayLabel(String day, int done, int total) {
    return '$day, $done of $total done';
  }

  @override
  String monthFooterPlanned(String month, int count, int days) {
    return '$month · $count of $days days planned';
  }

  @override
  String monthDaysPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days planned',
      one: '1 day planned',
    );
    return '$_temp0';
  }

  @override
  String get monthLegendPlanned => 'planned';

  @override
  String get monthLegendRepeats => 'repeats';

  @override
  String monthNav(String previous, String current, String next) {
    return '$previous · $current · $next';
  }

  @override
  String get monthPrevious => 'Previous month';

  @override
  String get monthNext => 'Next month';

  @override
  String get todayPill => 'Today';

  @override
  String monthCellLabel(String day, int done, int total) {
    return '$day, $done of $total done';
  }

  @override
  String get emptyAddToDay => 'Add to this day';

  @override
  String emptyPullInbox(int count) {
    return 'Pull from inbox · $count';
  }

  @override
  String get emptyCopyDay => 'Copy a day…';

  @override
  String get copyDayTitle => 'Copy which day?';

  @override
  String copyDayDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copied $count tasks',
      one: 'Copied 1 task',
    );
    return '$_temp0';
  }

  @override
  String get copyDayNothing => 'That day has nothing to copy';

  @override
  String snackDone(String title) {
    return '$title done';
  }

  @override
  String snackNotDone(String title) {
    return '$title not done';
  }

  @override
  String snackExtended(String title, String time) {
    return '$title now ends at $time';
  }

  @override
  String snackShifted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved $count tasks',
      one: 'Moved 1 task',
    );
    return '$_temp0';
  }

  @override
  String snackShiftedPartial(int count, String pin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved $count tasks · stopped at $pin (pinned)',
      one: 'Moved 1 task · stopped at $pin (pinned)',
      zero: 'Nothing moved: $pin is pinned',
    );
    return '$_temp0';
  }

  @override
  String sheetMetaDay(String day, String range, String duration) {
    return '$day · $range · $duration';
  }

  @override
  String get sheetToday => 'Today';

  @override
  String get sheetTomorrow => 'Tomorrow';

  @override
  String get sheetInbox => 'Inbox';

  @override
  String get sheetDone => 'Done';

  @override
  String get sheetUndone => 'Not done';

  @override
  String get sheetExtend => '+15 min';

  @override
  String get sheetShift => 'Shift';

  @override
  String get sheetMove => 'Move';

  @override
  String get sheetEdit => 'Edit';

  @override
  String sheetSubtasks(int done, int total) {
    return 'Subtasks · $done of $total';
  }

  @override
  String get sheetSubtasksNone => 'Subtasks';

  @override
  String get sheetAddSubtask => '+ Add';

  @override
  String get sheetNewSubtask => 'New subtask';

  @override
  String get sheetAlerts => 'Alerts';

  @override
  String get sheetRepeat => 'Repeat';

  @override
  String get sheetLook => 'Colour and icon';

  @override
  String get sheetNever => 'Never';

  @override
  String get sheetNoAlerts => 'None';

  @override
  String get sheetNotFound => 'This task isn\'t here any more';

  @override
  String get alertAtStart => 'at start';

  @override
  String get alertAtEnd => 'at end';

  @override
  String alertBefore(int minutes) {
    return '$minutes min before';
  }

  @override
  String alertOverdue(int minutes) {
    return '$minutes min after end';
  }

  @override
  String alertJoin(String first, String rest) {
    return '$first · $rest';
  }

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekdays => 'Weekdays';

  @override
  String repeatWeekly(String days) {
    return 'Weekly on $days';
  }

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String get repeatYearly => 'Yearly';

  @override
  String get repeatCustom => 'Custom';

  @override
  String listJoin(String first, String rest) {
    return '$first, $rest';
  }

  @override
  String sheetLeftSuffix(String left) {
    return ' · $left';
  }

  @override
  String get colourIconCaption => 'Colour and icon';

  @override
  String get colourIconMore => 'All icons';

  @override
  String get editorCaption => 'Edit task';

  @override
  String get editorTitleHint => 'What is it?';

  @override
  String get editorWhen => 'When';

  @override
  String get editorStart => 'Start';

  @override
  String editorEndsAt(String time) {
    return '→ $time';
  }

  @override
  String get editorDuration => 'Duration';

  @override
  String get editorNotes => 'Notes';

  @override
  String get editorNotesHint => 'Add notes';

  @override
  String get editorSave => 'Save';

  @override
  String get editorMoveToInbox => 'Move to inbox';

  @override
  String get editorDelete => 'Delete task';

  @override
  String editorDeleteConfirm(String title) {
    return 'Delete “$title”?';
  }

  @override
  String get editorDeleteBody =>
      'It goes to Trash for 30 days. You can undo right after.';

  @override
  String get editorCancel => 'Cancel';

  @override
  String snackDeleted(String title) {
    return '$title deleted';
  }

  @override
  String snackMovedToInbox(String title) {
    return '$title moved to inbox';
  }

  @override
  String get editorPickDay => 'Pick a day';

  @override
  String resizeLabel(String title) {
    return 'Change how long $title takes';
  }

  @override
  String dragDropAt(String time) {
    return '→ $time';
  }

  @override
  String snackMoved(String title, String time) {
    return '$title moved to $time';
  }

  @override
  String snackMovedDay(String title, String day) {
    return '$title moved to $day';
  }

  @override
  String snackResized(String title, String time) {
    return '$title now ends at $time';
  }

  @override
  String get shiftChipLabel => 'Shift later tasks';

  @override
  String snackMovedShifted(String title, String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title moved to $time · $count later tasks moved too',
      one: '$title moved to $time · 1 later task moved too',
      zero: '$title moved to $time',
    );
    return '$_temp0';
  }

  @override
  String snackMovedShiftedPartial(String title, String time, String pin) {
    return '$title moved to $time · stopped at $pin (pinned)';
  }

  @override
  String get selectAction => 'Select';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get selectionClose => 'Done selecting';

  @override
  String get selectionMove => 'Move';

  @override
  String get selectionMoveTitle => 'Move to';

  @override
  String get selectionDuplicate => 'Duplicate';

  @override
  String get selectionColour => 'Colour';

  @override
  String get selectionDelete => 'Delete';

  @override
  String selectionDeleteConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count tasks?',
      one: 'Delete 1 task?',
    );
    return '$_temp0';
  }

  @override
  String snackManyMoved(int count, String day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks moved to $day',
      one: '1 task moved to $day',
    );
    return '$_temp0';
  }

  @override
  String snackManyDuplicated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks duplicated',
      one: '1 task duplicated',
    );
    return '$_temp0';
  }

  @override
  String snackManyRecoloured(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks recoloured',
      one: '1 task recoloured',
    );
    return '$_temp0';
  }

  @override
  String snackManyDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks moved to Trash',
      one: '1 task moved to Trash',
    );
    return '$_temp0';
  }

  @override
  String get inboxSchedule => 'Schedule';

  @override
  String get inboxTrash => 'Move to Trash';

  @override
  String inboxRowLabel(String title, String length) {
    return '$title, $length';
  }

  @override
  String inboxSummary(int count, String work) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unscheduled',
      one: '1 unscheduled',
    );
    return '$_temp0 · $work of work';
  }

  @override
  String inboxRingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks in the Inbox',
      one: '1 task in the Inbox',
      zero: 'Inbox empty',
    );
    return '$_temp0';
  }

  @override
  String get inboxAddHint => 'Call Mum tomorrow 3pm 20m';

  @override
  String get inboxAddLabel => 'Add a task';

  @override
  String get inboxFilterAll => 'All';

  @override
  String get inboxFilterUnder30 => 'Under 30 min';

  @override
  String get inboxFilterFits => 'Fits today';

  @override
  String inboxNextSlot(String range, String title) {
    return 'Next free slot today: $range · fits $title';
  }

  @override
  String get inboxPlace => 'Place';

  @override
  String inboxCompleted(int count) {
    return 'Completed · $count';
  }

  @override
  String get inboxEmpty => 'Inbox is clear';

  @override
  String get inboxNoMatch => 'Nothing here fits this filter';

  @override
  String get inboxUntitled => 'New task';

  @override
  String inboxScheduleTitle(String title) {
    return 'Schedule $title';
  }

  @override
  String inboxScheduleToday(String range) {
    return 'Today, $range';
  }

  @override
  String inboxScheduleTomorrow(String range) {
    return 'Tomorrow, $range';
  }

  @override
  String get inboxScheduleNone =>
      'No free slot today or tomorrow. Make room on Today, or drag it in from the week.';

  @override
  String snackScheduled(String title, String when) {
    return '$title scheduled for $when';
  }

  @override
  String snackAddedInbox(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks added',
      one: '$title added to the Inbox',
    );
    return '$_temp0';
  }

  @override
  String snackAddedTimed(String title, String when) {
    return '$title added for $when';
  }

  @override
  String snackTrashed(String title) {
    return '$title moved to Trash';
  }
}
