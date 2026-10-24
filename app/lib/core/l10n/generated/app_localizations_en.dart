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
      'That can\'t be undone any more. Deleted tasks stay in Trash for 30 days.';

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
    return '$title, not done';
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
    return '$label, not done';
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
  String get rowMissedMeta => '· not done';

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
    return '$title · not done';
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
  String get shiftChipCalendar => 'Calendar events too';

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

  @override
  String get addTitleLabel => 'Title';

  @override
  String get addTypeTimeHint => 'Type a time too: ‘Go shopping 5pm 1h’';

  @override
  String addRemoveToken(String token) {
    return 'Remove “$token”';
  }

  @override
  String get addSuggestions => 'Suggestions';

  @override
  String get addFromHabits => 'from your habits';

  @override
  String addHabitUsual(String range, String length) {
    return 'usually $range · $length';
  }

  @override
  String addHabitNoTime(String length) {
    return 'no set time · $length';
  }

  @override
  String addHabitLabel(String title, String meta) {
    return '$title, $meta';
  }

  @override
  String get addContinue => 'Continue';

  @override
  String get addToInbox => 'Add to Inbox instead';

  @override
  String addStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get addBack => 'Back';

  @override
  String addWhenOnDay(String day, String time) {
    return '$day, $time';
  }

  @override
  String get pickerLabel => 'Start time';

  @override
  String addWhenSummary(String day, String range, String length) {
    return '$day · $range · $length';
  }

  @override
  String get addTimeCaption => 'Time';

  @override
  String get addDurationCaption => 'Duration';

  @override
  String addFreeUntil(String time) {
    return 'Free until $time · no overlap';
  }

  @override
  String addOverlaps(int count, String title, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Overlaps $title and $others more',
      one: 'Overlaps $title',
    );
    return '$_temp0 · you can still add it';
  }

  @override
  String addLandsOn(String day, String range) {
    return 'Lands on $day at $range';
  }

  @override
  String get addSlotFree => 'the slot is free';

  @override
  String addSlotBusy(String title) {
    return 'overlaps $title';
  }

  @override
  String get addAdd => 'Add';

  @override
  String get addAnother => 'Add another';

  @override
  String durationChipMinutes(int minutes) {
    return '$minutes';
  }

  @override
  String durationChipHours(String hours) {
    return '${hours}h';
  }

  @override
  String get inboxPickTime => 'Pick a time…';

  @override
  String get durationSheetTitle => 'Duration';

  @override
  String get durationTypeLabel => 'Or type a length';

  @override
  String durationEnds(String time) {
    return 'ends $time';
  }

  @override
  String durationFitsBefore(String title, String time) {
    return 'Still fits before $title at $time';
  }

  @override
  String durationFitsBedtime(String time) {
    return 'Fits before Bedtime at $time';
  }

  @override
  String durationRunsInto(String title, String time) {
    return 'Runs into $title at $time';
  }

  @override
  String durationPastBedtime(String time) {
    return 'Runs past Bedtime at $time';
  }

  @override
  String get durationPresets => 'Presets';

  @override
  String get durationReset => 'Reset';

  @override
  String get durationAddPreset => 'preset';

  @override
  String get durationAddPresetLabel => 'Keep this length as a preset';

  @override
  String durationRemovePreset(String length) {
    return 'Remove the $length preset';
  }

  @override
  String durationPresetMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String durationPresetHours(int hours) {
    return '${hours}h';
  }

  @override
  String durationPresetHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get addMoreTime => 'More time options';

  @override
  String get addMoreDuration => 'More lengths';

  @override
  String get timeMenuChangeDay => 'Change day';

  @override
  String get timeMenuPickWeek => 'Pick from the week';

  @override
  String get timeMenuAllDay => 'Make it all-day';

  @override
  String get timeMenuTimed => 'Give it a time';

  @override
  String get timeMenuInbox => 'Send to Inbox';

  @override
  String get timeMenuZone => 'Time zone';

  @override
  String get timeMenuType => 'Type a time';

  @override
  String get zoneSearch => 'Search a city or zone';

  @override
  String get weekPrevious => 'Previous week';

  @override
  String get weekNext => 'Next week';

  @override
  String get addAllDay => 'All day';

  @override
  String get addLandsOnEdit => 'Edit';

  @override
  String addLandsOnAllDay(String day) {
    return 'Lands on $day · all day';
  }

  @override
  String pasteAsk(int count) {
    return 'Add $count tasks?';
  }

  @override
  String pasteAdd(int count) {
    return 'Add $count';
  }

  @override
  String get pasteKeep => 'Keep as one';

  @override
  String get searchSubtitle => 'Everything you\'ve planned';

  @override
  String get searchFieldLabel => 'Search titles, notes and subtasks';

  @override
  String get searchClear => 'Clear search';

  @override
  String searchRingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get searchFilterAll => 'All';

  @override
  String get searchFilterToday => 'Today';

  @override
  String get searchFilterWeek => 'This week';

  @override
  String get searchFilterInbox => 'Inbox';

  @override
  String get searchFilterDone => 'Done';

  @override
  String get searchFilterColour => 'Colour';

  @override
  String get searchFilterIcon => 'Icon';

  @override
  String get searchPickColour => 'Show one colour';

  @override
  String get searchPickIcon => 'Show one icon';

  @override
  String searchGroupToday(String weekday) {
    return '$weekday · Today';
  }

  @override
  String get searchGroupInbox => 'Inbox';

  @override
  String searchMetaDay(String day, String range) {
    return '$day · $range';
  }

  @override
  String searchMetaDone(String when) {
    return '$when · Done';
  }

  @override
  String searchMetaMissed(String when) {
    return '$when · not done';
  }

  @override
  String searchMetaInbox(String length) {
    return 'Inbox · $length';
  }

  @override
  String searchRowLabel(String title, String meta) {
    return '$title, $meta';
  }

  @override
  String get searchRecent => 'Recent';

  @override
  String searchRecentLabel(String query) {
    return 'Search for $query again';
  }

  @override
  String get searchEmpty =>
      'Find anything you\'ve planned: titles, notes and subtasks, done ones too.';

  @override
  String searchNoResults(String query) {
    return 'No matches for “$query”';
  }

  @override
  String get searchNoResultsHint => 'Try fewer words, or another filter.';

  @override
  String get searchShowAll => 'Show all';

  @override
  String searchDayLabel(String weekday, String date) {
    return '$weekday $date';
  }

  @override
  String settingsLocalOnly(String name) {
    return '$name · on this device';
  }

  @override
  String get settingsLocalOnlyNoName => 'On this device';

  @override
  String settingsAvatarLabel(String name) {
    return 'Account: $name';
  }

  @override
  String get settingsDayShape => 'Day shape';

  @override
  String settingsAwake(String length) {
    return '$length awake';
  }

  @override
  String get settingsWakeUp => 'Wake Up';

  @override
  String get settingsBedtime => 'Bedtime';

  @override
  String get settingsPerWeekday => 'Different days';

  @override
  String get settingsSameEveryDay => 'Same every day';

  @override
  String settingsCustomDays(String days) {
    return '$days';
  }

  @override
  String get settingsUseEveryday => 'Same as every day';

  @override
  String get settingsWeekStarts => 'Week starts';

  @override
  String get settingsTimeFormat => 'Time format';

  @override
  String settingsTimeSystem(String example) {
    return 'Device ($example)';
  }

  @override
  String get settingsTime12 => '12 h';

  @override
  String get settingsTime24 => '24 h';

  @override
  String get settingsPlanning => 'Planning';

  @override
  String get settingsDefaultDuration => 'Default duration';

  @override
  String get settingsSnap => 'Snap to';

  @override
  String settingsSnapValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsShiftLater => 'Shift later tasks';

  @override
  String get settingsShiftAsk => 'Ask each time';

  @override
  String get settingsShiftAlways => 'Always';

  @override
  String get settingsShiftNever => 'Never';

  @override
  String get settingsShowFree => 'Show free time';

  @override
  String get settingsShowFreeDetail => 'Dotted gaps on the thread';

  @override
  String get settingsLateNudge => 'Running-late nudge';

  @override
  String get settingsLateNudgeDetail => 'Offer to shift the rest of the day';

  @override
  String get settingsRoll => 'Roll unfinished to tomorrow';

  @override
  String get settingsRollDetail => 'Otherwise they return to the Inbox';

  @override
  String get settingsReminders => 'Reminders';

  @override
  String get settingsTaskStarts => 'Task starts';

  @override
  String get settingsAlertNone => 'No alert';

  @override
  String get settingsAlertAtStart => 'When it starts';

  @override
  String settingsAlertBefore(int minutes) {
    return '$minutes min before';
  }

  @override
  String get settingsBedtimeReminder => 'Bedtime reminder';

  @override
  String settingsBedtimeReminderDetail(String time) {
    return 'At $time, with tomorrow\'s first task';
  }

  @override
  String get settingsLook => 'Look';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'Like this device';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsAccent => 'Accent';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsTrash => 'Trash';

  @override
  String get settingsTrashDetail => 'Deleted tasks stay 30 days';

  @override
  String get settingsTrashEmpty => 'Trash is empty';

  @override
  String get settingsRestore => 'Restore';

  @override
  String settingsRestored(String title) {
    return '$title restored';
  }

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsWhatsNew => 'What\'s new';

  @override
  String changelogVersion(String version) {
    return 'Version $version';
  }

  @override
  String changelogInstalled(String version) {
    return 'Version $version · on this device';
  }

  @override
  String get changelogIntro => 'What changed in each version of Dottoday.';

  @override
  String get releaseNotes010 =>
      'Plan your day on one thread: drag a task to move it, drag its edge to change how long it takes, and shift everything after it in one go.\nAdd a task in two taps, type times in plain words, or paste a list to add several at once.\nRepeating tasks, reminders with lead times, and your calendars on the timeline — all free.\nSync between iPhone, Android, Mac and the web, with a status you can see and nothing lost.\nExport everything as JSON, CSV or a calendar file, and bring a backup back.\nSend feedback from Settings, and read what\'s new here after each update.';

  @override
  String whatsNewBanner(String version) {
    return 'Dottoday $version is here';
  }

  @override
  String get whatsNewOpen => 'See what\'s new';

  @override
  String get settingsFeedback => 'Send feedback';

  @override
  String get settingsFeedbackIntro =>
      'Opens a draft in your mail app, and you send it from there. Nothing your tasks say is included.';

  @override
  String get settingsFeedbackDiagnostics => 'Add diagnostics';

  @override
  String get settingsFeedbackDiagnosticsHint =>
      'App version, device type, sync state and how many tasks you have — never what they say.';

  @override
  String get settingsFeedbackDiagnosticsFailed =>
      'Couldn\'t read the diagnostics, so the email goes without them.';

  @override
  String get settingsFeedbackPreview => 'Added to the end of your email:';

  @override
  String get settingsFeedbackWrite => 'Write email';

  @override
  String get settingsFeedbackSubject => 'Dottoday feedback';

  @override
  String get settingsFeedbackNoMail => 'No mail app is set up on this device.';

  @override
  String settingsAccentLabel(String name) {
    return '$name accent';
  }

  @override
  String get dayCardYesterdaySuffix => ' · Yesterday';

  @override
  String get dayCardTomorrowSuffix => ' · Tomorrow';

  @override
  String spreadDoneOf(int done, int total) {
    return '$done of $total';
  }

  @override
  String spreadPlanned(int count) {
    return '$count planned';
  }

  @override
  String spreadSubtitle(String date, int done, int total) {
    return '$date · $done of $total done';
  }

  @override
  String get spreadPreviousDay => 'Previous day';

  @override
  String get spreadNextDay => 'Next day';

  @override
  String get spreadDropToPlan => 'drop here to plan';

  @override
  String spreadDropToPlanLabel(String day) {
    return 'Drop a task here to plan it on $day';
  }

  @override
  String threadDropInbox(String duration) {
    return '$duration free · drop an inbox task here';
  }

  @override
  String get runningLate => 'Running late';

  @override
  String runningLateBy(int minutes) {
    return '+$minutes min';
  }

  @override
  String snackRunningLate(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks moved $minutes min later',
      one: '1 task moved $minutes min later',
      zero: 'Nothing left to move',
    );
    return '$_temp0';
  }

  @override
  String snackRunningLatePartial(int count, int minutes, String pinned) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks moved $minutes min later',
      one: '1 task moved $minutes min later',
    );
    return '$_temp0 · $pinned stays put';
  }

  @override
  String get spreadNothing => 'Nothing planned';

  @override
  String threadFreeFits(String duration, String title) {
    return '$duration free · $title fits';
  }

  @override
  String inboxFitsToday(String time) {
    return 'Fits today $time';
  }

  @override
  String inboxFitsDay(String day, String time) {
    return 'Fits $day $time';
  }

  @override
  String get inboxFitsNone => 'No room this week';

  @override
  String inboxAddedMeta(String duration, String when) {
    return '$duration · added $when';
  }

  @override
  String get inboxAddedToday => 'today';

  @override
  String get inboxAddedYesterday => 'yesterday';

  @override
  String inboxSortLabel(String order) {
    return 'Sort: $order';
  }

  @override
  String get inboxSortAdded => 'added';

  @override
  String get inboxSortDuration => 'duration';

  @override
  String get inboxSortFit => 'first fit';

  @override
  String get inboxAutoPlan => 'Auto-plan the week';

  @override
  String snackAutoPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks planned this week',
      one: '1 task planned this week',
      zero: 'Nothing fits this week',
    );
    return '$_temp0';
  }

  @override
  String snackAutoPlannedPartial(int count, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks planned',
      one: '1 task planned',
    );
    return '$_temp0 · $left still in the Inbox';
  }

  @override
  String get inboxDropToday => 'Drop onto today';

  @override
  String inboxDropTodayFree(String duration) {
    return '$duration free';
  }

  @override
  String inboxDropHint(String keys) {
    return 'Drag a task onto a dotted gap, or press $keys on a row to place it in the first fitting slot.';
  }

  @override
  String inboxUnscheduledCount(int count) {
    return '$count unscheduled';
  }

  @override
  String inboxRowFitLabel(String row, String fit) {
    return '$row, $fit';
  }

  @override
  String inboxScheduleDay(String day, String range) {
    return '$day, $range';
  }

  @override
  String capacityRingLabel(String planned, String awake) {
    return '$planned planned of $awake awake';
  }

  @override
  String weekBusiest(String day, String planned) {
    return 'Busiest · $day · $planned';
  }

  @override
  String weekLightest(String day, String planned) {
    return 'Lightest · $day · $planned';
  }

  @override
  String weekFree(String free) {
    return 'Free · $free unplanned';
  }

  @override
  String weekDone(int done, int total) {
    return 'Done · $done of $total';
  }

  @override
  String get weekBusiestTag => 'Busiest';

  @override
  String get weekLightestTag => 'Lightest';

  @override
  String get weekTitle => 'This week';

  @override
  String weekSubtitle(String range, int done, int total, String planned) {
    return '$range · $done of $total done · $planned planned';
  }

  @override
  String weekDayFree(String free) {
    return '$free free';
  }

  @override
  String weekTodayDay(String day) {
    return '$day · today';
  }

  @override
  String get weekViewWeek => 'Week';

  @override
  String get weekViewMonth => 'Month';

  @override
  String get weekToday => 'Today';

  @override
  String weekDropHere(String free) {
    return 'Drop a task here · $free';
  }

  @override
  String weekDropAt(String day, String range) {
    return '$day · $range';
  }

  @override
  String weekCardLeft(int minutes) {
    return '$minutes min left';
  }

  @override
  String weekCardSkipped(String range) {
    return '$range · skipped';
  }

  @override
  String weekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String monthStats(int done, int missed, int ahead) {
    return '$done done · $missed not done · $ahead ahead';
  }

  @override
  String monthStatsBusiest(String stats, String day) {
    return '$stats · busiest day $day';
  }

  @override
  String get editorClose => 'Close';

  @override
  String get editorEscKey => 'esc';

  @override
  String get shortcutsTitle => 'Keyboard shortcuts';

  @override
  String get shortcutsEverywhere => 'Everywhere';

  @override
  String get shortcutsTodaySection => 'Today';

  @override
  String get shortcutsWeekMonth => 'Week and Month';

  @override
  String get shortcutsInbox => 'Inbox';

  @override
  String get shortcutsEditor => 'Editing a task';

  @override
  String get shortcutAdd => 'Add a task';

  @override
  String get shortcutGoToday => 'Go to Today';

  @override
  String get shortcutGoInbox => 'Go to Inbox';

  @override
  String get shortcutGoWeek => 'Go to Week';

  @override
  String get shortcutGoMonth => 'Go to Month';

  @override
  String get shortcutShowKeys => 'Show these shortcuts';

  @override
  String get shortcutPrevDay => 'Previous day';

  @override
  String get shortcutNextDay => 'Next day';

  @override
  String get shortcutBackToday => 'Back to today';

  @override
  String get shortcutDoneLive => 'Mark the current task done';

  @override
  String get shortcutPrevPeriod => 'Previous week or month';

  @override
  String get shortcutNextPeriod => 'Next week or month';

  @override
  String get shortcutThisPeriod => 'This week or month';

  @override
  String get shortcutPlaceFirst =>
      'Place the selected task in its first free slot';

  @override
  String get shortcutAutoPlan => 'Auto-plan the week';

  @override
  String get shortcutSave => 'Save and close';

  @override
  String get shortcutDone => 'Mark done';

  @override
  String get shortcutClose => 'Close';

  @override
  String get repeatTitle => 'Repeat';

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String get repeatEveryWeekday => 'Every weekday';

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeksOn(int count, String days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks on $days',
      one: 'Every week on $days',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonthsOnDay(int count, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months on day $day',
      one: 'Every month on day $day',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonthsOnNth(int count, String nth, String weekday) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months on the $nth $weekday',
      one: 'Every month on the $nth $weekday',
    );
    return '$_temp0';
  }

  @override
  String repeatNth(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '1': 'first',
      '2': 'second',
      '3': 'third',
      '4': 'fourth',
      'other': 'last',
    });
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count years',
      one: 'Every year',
    );
    return '$_temp0';
  }

  @override
  String repeatTimes(String summary, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'once',
    );
    return '$summary · $_temp0';
  }

  @override
  String repeatUntil(String summary, String date) {
    return '$summary · until $date';
  }

  @override
  String get repeatChoiceDaily => 'Every day';

  @override
  String get repeatChoiceWeekly => 'Every week';

  @override
  String get repeatChoiceMonthly => 'Every month';

  @override
  String get repeatChoiceYearly => 'Every year';

  @override
  String get repeatChoiceCustom => 'Custom';

  @override
  String repeatOnDay(int day) {
    return 'On day $day';
  }

  @override
  String repeatOnNth(String nth, String weekday) {
    return 'On the $nth $weekday';
  }

  @override
  String get repeatEvery => 'Every';

  @override
  String repeatUnitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'weeks',
      one: 'week',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'months',
      one: 'month',
    );
    return '$_temp0';
  }

  @override
  String get repeatIntervalLess => 'Fewer';

  @override
  String get repeatIntervalMore => 'More';

  @override
  String get repeatEnds => 'Ends';

  @override
  String get repeatEndsNever => 'Never';

  @override
  String get repeatEndsAfter => 'After';

  @override
  String get repeatEndsOn => 'On a date';

  @override
  String repeatEndsAfterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return '$_temp0';
  }

  @override
  String get repeatDone => 'Done';

  @override
  String get scopeTitleEdit => 'Change which?';

  @override
  String get scopeTitleDelete => 'Delete which?';

  @override
  String get scopeThis => 'This one';

  @override
  String get scopeFollowing => 'This and following';

  @override
  String get scopeAll => 'All';

  @override
  String get scopeAllDetail => 'Past ones stay as they were';

  @override
  String snackSeriesChanged(String title) {
    return '$title changed';
  }

  @override
  String snackSeriesDeleted(String title) {
    return '$title deleted';
  }

  @override
  String snackRepeatSet(String title, String summary) {
    return '$title repeats $summary';
  }

  @override
  String snackRepeatStopped(String title) {
    return '$title no longer repeats';
  }

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get alertsAdd => 'Add an alert';

  @override
  String get alertsMax => 'Up to 5 alerts';

  @override
  String alertsRemove(String alert) {
    return 'Remove $alert';
  }

  @override
  String get alertsBedtime => 'Bedtime reminder';

  @override
  String get alertsBedtimeDetail =>
      'Every evening, with tomorrow\'s first task';

  @override
  String get alertsDone => 'Done';

  @override
  String snackAlertsSaved(String title) {
    return '$title alerts updated';
  }

  @override
  String subtaskRemove(String title) {
    return 'Remove $title';
  }

  @override
  String subtaskReorder(String title) {
    return 'Reorder $title';
  }

  @override
  String get subtaskMoveUp => 'Move up';

  @override
  String get subtaskMoveDown => 'Move down';

  @override
  String subtaskRename(String title) {
    return 'Rename $title';
  }

  @override
  String get subtaskNow => 'now';

  @override
  String get subtaskEveryTime => 'Use this list every time';

  @override
  String snackSubtaskRemoved(String title) {
    return '$title removed';
  }

  @override
  String snackListEveryTime(String title) {
    return '$title will have this list every time';
  }

  @override
  String get colourIconTitle => 'Colour and icon';

  @override
  String get colourIconDone => 'Done';

  @override
  String get subtaskRenameTitle => 'Rename subtask';

  @override
  String get subtaskRenameSave => 'Rename';

  @override
  String editorZone(String city) {
    return 'Time zone · $city';
  }

  @override
  String get todayMenuLate => 'Running late…';

  @override
  String get todayMenuReview => 'Review the day';

  @override
  String get lateAmount => 'How late';

  @override
  String get lateShiftRest => 'Shift the rest';

  @override
  String lateShiftPreview(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks move $minutes min later',
      one: '1 task moves $minutes min later',
      zero: 'Nothing left to move',
    );
    return '$_temp0';
  }

  @override
  String lateShiftPreviewPartial(int count, int minutes, String pinned) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks move $minutes min later',
      one: '1 task moves $minutes min later',
    );
    return '$_temp0 · $pinned stays put';
  }

  @override
  String lateSkip(String title) {
    return 'Skip “$title”';
  }

  @override
  String get lateSkipDetail => 'Frees its time; nothing else moves';

  @override
  String lateShorten(String title) {
    return 'Shorten “$title”';
  }

  @override
  String lateShortenDetail(int minutes, String end) {
    return 'Starts $minutes min later, still ends at $end';
  }

  @override
  String lateShortenTooShort(int minutes) {
    return 'Too short to lose $minutes min';
  }

  @override
  String get lateNothingLeft => 'Nothing left today';

  @override
  String snackSkippedTask(String title) {
    return '“$title” skipped';
  }

  @override
  String snackShortened(String title, int minutes) {
    return '“$title” starts $minutes min later';
  }

  @override
  String get reviewTitle => 'Day review';

  @override
  String reviewSummary(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get reviewAskTomorrow => 'Move the rest to tomorrow?';

  @override
  String get reviewAskInbox => 'Send the rest to the Inbox?';

  @override
  String reviewMoveTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move $count to tomorrow',
      one: 'Move 1 to tomorrow',
    );
    return '$_temp0';
  }

  @override
  String reviewSendInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Send $count to Inbox',
      one: 'Send 1 to Inbox',
    );
    return '$_temp0';
  }

  @override
  String reviewStaying(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more stay: they repeat or come from a calendar',
      one: '1 more stays: it repeats or comes from a calendar',
    );
    return '$_temp0';
  }

  @override
  String get reviewAllDone => 'Nothing left to move';

  @override
  String snackRolled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks moved to tomorrow',
      one: '1 task moved to tomorrow',
    );
    return '$_temp0';
  }

  @override
  String snackSentToInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks sent to the Inbox',
      one: '1 task sent to the Inbox',
    );
    return '$_temp0';
  }

  @override
  String get promptNotNow => 'Not now';

  @override
  String get lateNudgeTitle => 'Need more time?';

  @override
  String lateNudgeDetail(String title, int minutes) {
    return '“$title” ended $minutes min ago';
  }

  @override
  String get lateNudgeAction => 'Catch up';

  @override
  String get todayMenuDuplicate => 'Duplicate day…';

  @override
  String get todayMenuCopyText => 'Copy day as text';

  @override
  String get duplicateDayTitle => 'Copy to which day?';

  @override
  String get snackDayCopied => 'Day copied as text';

  @override
  String inboxDoneOn(String date) {
    return 'Done $date';
  }

  @override
  String inboxNotDone(String title) {
    return 'Mark “$title” not done';
  }

  @override
  String get inboxClearCompleted => 'Clear completed';

  @override
  String snackBackInInbox(String title) {
    return '“$title” is back in the Inbox';
  }

  @override
  String snackClearedCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed tasks moved to Trash',
      one: '1 completed task moved to Trash',
    );
    return '$_temp0';
  }

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsCalendars => 'Calendars';

  @override
  String get settingsCalendarsDetail => 'Events on your timeline';

  @override
  String get settingsExport => 'Export';

  @override
  String get settingsExportDetail => 'Your data, free to take';

  @override
  String get settingsHelp => 'Help';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsAboutApp => 'About Dottoday';

  @override
  String get settingsBack => 'Back to Settings';

  @override
  String get accountProfile => 'Profile';

  @override
  String get accountName => 'Name';

  @override
  String get accountNameNone => 'Not set';

  @override
  String get accountNameTitle => 'Your name';

  @override
  String get accountNameSave => 'Save';

  @override
  String get accountSync => 'Sync';

  @override
  String get accountLocalBody =>
      'Everything is on this device. Sign in to sync across your devices and keep a copy safe.';

  @override
  String get accountApple => 'Continue with Apple';

  @override
  String get accountGoogle => 'Continue with Google';

  @override
  String get accountEmail => 'Continue with email';

  @override
  String get accountComingSoon =>
      'Sign-in arrives with sync in a later update. Until then, nothing leaves this device.';

  @override
  String accountSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountSignOutEverywhere => 'Sign out everywhere';

  @override
  String get accountDelete => 'Delete account';

  @override
  String get accountDeleteTitle => 'Delete your account?';

  @override
  String get accountDeleteExportFirst => 'Export my data first';

  @override
  String accountDeleteBody(String word) {
    return 'This deletes your account and everything synced to it. Tasks on this device stay. Type $word to confirm.';
  }

  @override
  String get accountDeleteWord => 'DELETE';

  @override
  String get calendarsIntro =>
      'Your calendar events on the timeline, next to your tasks. Free, always.';

  @override
  String get calendarsConnected => 'Connected';

  @override
  String get calendarsNone => 'No calendars connected yet';

  @override
  String get calendarsConnect => 'Connect a calendar';

  @override
  String get calendarsOnlineInSettings =>
      'Connect Google or Microsoft in Settings › Calendars.';

  @override
  String get calendarsOnline => 'Google and Microsoft';

  @override
  String get calendarsOnlineIntro =>
      'Connected once, they show on every device you sign in on. If a calendar is also on this device, switch one of the two off.';

  @override
  String get calendarsOnlineSignIn => 'Sign in to connect Google or Microsoft';

  @override
  String get calendarsConnectGoogle => 'Connect Google Calendar';

  @override
  String get calendarsConnectMicrosoft => 'Connect Microsoft Outlook';

  @override
  String get calendarsReconnect => 'Reconnect';

  @override
  String get calendarsReconnectDetail =>
      'Dottoday can\'t reach this account until you reconnect it';

  @override
  String get calendarsUnreachable => 'Couldn\'t reach this account just now';

  @override
  String get calendarsDisconnect => 'Disconnect';

  @override
  String calendarsDisconnectTitle(String account) {
    return 'Disconnect $account?';
  }

  @override
  String get calendarsDisconnectBody =>
      'Its events leave your timeline on every device. Events with your subtasks or notes go to Trash.';

  @override
  String get calendarsShifting => 'When the day shifts';

  @override
  String get calendarsMoveEvents => 'Move calendar events too';

  @override
  String get calendarsMoveEventsDetail =>
      'When you shift the rest. Shared and repeating events stay put.';

  @override
  String get calendarsAsk =>
      'Dottoday asks your device once to see your calendars. Then you choose which ones come in.';

  @override
  String get calendarsOnDevice => 'On this device';

  @override
  String get calendarsNoneOnDevice => 'No calendars on this device';

  @override
  String get calendarsReadOnly => 'Read-only';

  @override
  String get calendarsPickInSettings =>
      'Connected · choose calendars in Settings';

  @override
  String get calendarDeniedTitle => 'Calendar access is off';

  @override
  String get calendarDeniedBody =>
      'Dottoday can\'t show your events until calendar access is allowed in your device settings.';

  @override
  String get calendarSettingsPath =>
      'Open your device\'s Settings, find Dottoday and allow access to Calendars.';

  @override
  String get exportIntro =>
      'Your tasks are yours. Export is free, always, with or without an account.';

  @override
  String get exportFormats => 'Formats';

  @override
  String get exportJson => 'Everything (JSON)';

  @override
  String get exportJsonDetail => 'A full copy you can restore';

  @override
  String get exportCsv => 'Tasks (CSV)';

  @override
  String get exportCsvDetail => 'Opens in any spreadsheet';

  @override
  String get exportIcs => 'Calendar (.ics)';

  @override
  String get exportIcsDetail => 'For other calendar apps';

  @override
  String get exportPlain =>
      'Export files aren\'t encrypted: anyone who has the file can read your tasks. Imported calendar events stay in their calendar and aren\'t included.';

  @override
  String get exportDone => 'Exported';

  @override
  String get exportHandOffFailed =>
      'Couldn\'t save or share the file. Nothing was changed.';

  @override
  String get exportRestore => 'Restore';

  @override
  String get exportImport => 'Import a backup…';

  @override
  String get exportImportDetail => 'A JSON file exported from Dottoday';

  @override
  String get exportImportTitle => 'Replace your tasks with this backup?';

  @override
  String exportImportBody(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
      zero: 'no tasks',
    );
    return 'This file from $date has $_temp0. Anything here that isn\'t in it moves to Trash. A backup of what\'s here now is taken first.';
  }

  @override
  String get exportImportAction => 'Replace';

  @override
  String get exportCancel => 'Cancel';

  @override
  String get exportImported => 'Backup imported';

  @override
  String get exportNotBackup =>
      'This isn\'t a Dottoday backup, or it comes from a newer version of Dottoday. Nothing was changed.';

  @override
  String get exportTooLarge =>
      'This file is over 25 MB, too large to import. Nothing was changed.';

  @override
  String get exportBackups => 'On this device';

  @override
  String get exportBackupsNote =>
      'Dottoday keeps a backup each day (the last 7) and one before every import or restore, encrypted, on this device only.';

  @override
  String get exportBackupsNone =>
      'No backups yet. The first is taken the next time Dottoday opens.';

  @override
  String get exportBackupDaily => 'Daily backup';

  @override
  String get exportBackupPreImport => 'Before an import';

  @override
  String get exportBackupPreRestore => 'Before a restore';

  @override
  String get exportRestoreTitle => 'Go back to this backup?';

  @override
  String exportRestoreBody(String date) {
    return 'Your tasks go back to how they were on $date. Anything newer moves to Trash. A backup of what\'s here now is taken first.';
  }

  @override
  String get exportRestoreAction => 'Restore';

  @override
  String get exportRestored => 'Backup restored';

  @override
  String get helpIntro => 'Quick answers. Anything else? Send feedback below.';

  @override
  String get helpMoveQ => 'How do I move a task?';

  @override
  String get helpMoveA =>
      'Drag it along the thread, or drag its edges to change how long it is. Long-press to pick several.';

  @override
  String get helpLateQ => 'I\'m running late. Can everything move?';

  @override
  String get helpLateA =>
      'Yes: ⋯ › Running late pushes the rest of today by 5, 15 or 30 minutes, stopping at pinned tasks. You can also skip or shorten the task at hand.';

  @override
  String get helpRepeatQ => 'How do repeating tasks work?';

  @override
  String get helpRepeatA =>
      'Open a task › Repeat. Ticks and subtasks belong to each day, so the next one starts fresh.';

  @override
  String get helpPasteQ => 'Can I add many tasks at once?';

  @override
  String get helpPasteA =>
      'Paste a list into Add or the Inbox field: each line becomes a task.';

  @override
  String get helpKeysQ => 'Are there keyboard shortcuts?';

  @override
  String get helpKeysA =>
      'On a Mac or in a browser, press ⌘/ (Ctrl+/ elsewhere) to see them all.';

  @override
  String get privacyLocalTitle => 'On your device';

  @override
  String get privacyLocalBody =>
      'Tasks are stored encrypted on this device, and the app works fully offline.';

  @override
  String get privacyTrackTitle => 'No tracking';

  @override
  String get privacyTrackBody =>
      'No ads, no analytics, no third-party trackers.';

  @override
  String get privacySyncTitle => 'When you sign in';

  @override
  String get privacySyncBody =>
      'Sync sends your tasks over an encrypted connection to your own account, and nowhere else.';

  @override
  String get privacySearchTitle => 'Searches';

  @override
  String get privacySearchBody =>
      'Recent searches stay on this device and are never synced or exported.';

  @override
  String get privacyClearSearches => 'Clear recent searches';

  @override
  String get snackSearchesCleared => 'Recent searches cleared';

  @override
  String get aboutLicences => 'Open-source licences';

  @override
  String get settingsSync => 'Sync';

  @override
  String get syncTitle => 'Sync';

  @override
  String get syncLocalOnlyBody =>
      'Your tasks are on this device only. Sign in to sync them across your devices.';

  @override
  String get syncSignIn => 'Sign in…';

  @override
  String get syncJustNow => 'Last synced just now';

  @override
  String syncMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Last synced $minutes min ago',
      one: 'Last synced 1 min ago',
    );
    return '$_temp0';
  }

  @override
  String syncAt(String when) {
    return 'Last synced $when';
  }

  @override
  String get syncNever => 'Not synced yet';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting to sync',
      one: '1 change waiting to sync',
      zero: 'Nothing waiting to sync',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncStateSynced => 'Up to date';

  @override
  String get syncStateSyncing => 'Syncing…';

  @override
  String get syncStateOffline =>
      'Offline. Changes are saved here and sync when you\'re back.';

  @override
  String get syncStateError =>
      'Couldn\'t sync. Your changes are safe here; it will try again.';

  @override
  String get syncConflicts => 'Changed on two devices';

  @override
  String get syncConflictHint =>
      'The other device\'s change is in use until you choose.';

  @override
  String syncConflictField(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'Title',
      'start': 'Time',
      'duration': 'Length',
      'notes': 'Notes',
      'colour': 'Colour',
      'status': 'Done or not',
      'other': 'A detail',
    });
    return '$_temp0';
  }

  @override
  String syncMine(String value) {
    return 'This device: $value';
  }

  @override
  String syncTheirs(String value) {
    return 'Other device: $value';
  }

  @override
  String get syncKeepMine => 'Keep mine';

  @override
  String get syncKeepTheirs => 'Keep theirs';

  @override
  String get bannerOffline => 'Offline · everything still works here';

  @override
  String bannerConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes need you',
      one: '1 change needs you',
    );
    return '$_temp0';
  }

  @override
  String get bannerReview => 'Review';

  @override
  String get notifDeniedTitle => 'Notifications are off';

  @override
  String get notifDeniedBody =>
      'Dottoday can\'t remind you until notifications are allowed in your device settings.';

  @override
  String get notifOpenSettings => 'Open settings';

  @override
  String get notifSettingsPath =>
      'Open your device\'s Settings › Notifications › Dottoday and allow notifications.';

  @override
  String syncSummary(String last, String pending) {
    return '$last · $pending';
  }

  @override
  String syncConflictHeading(String title, String field) {
    return '$title · $field';
  }

  @override
  String get recoveryLockedTitle => 'Dottoday can\'t open your tasks';

  @override
  String get recoveryLockedBody =>
      'Your tasks on this device are locked with a key that is missing or has changed. This can happen after restoring a device or clearing its keychain.';

  @override
  String get recoveryFreshBody =>
      'Start fresh keeps the old file aside (it is never deleted) and opens an empty planner. Your tasks come back when you sign in to sync, or by importing an export.';

  @override
  String get recoveryStartFresh => 'Start fresh';

  @override
  String get recoveryConfirm =>
      'Start with an empty planner? The old file stays on this device.';

  @override
  String get recoveryConfirmYes => 'Yes, start fresh';

  @override
  String recoveryKept(String where) {
    return 'Your old file is kept at $where';
  }

  @override
  String get recoveryTabTitle => 'Dottoday is open in another tab';

  @override
  String get recoveryTabBody =>
      'To keep your tasks safe, only one tab can use them at a time.';

  @override
  String get recoveryUseHere => 'Use it here';

  @override
  String get recoveryMovedTitle => 'Dottoday moved to another tab';

  @override
  String get recoveryMovedBody =>
      'You chose to use Dottoday in another tab. Your tasks are saved.';

  @override
  String get recoveryNoAnswer =>
      'The other tab didn\'t answer. Close it and try again.';

  @override
  String get recoveryContinue => 'Continue';

  @override
  String get stateLoading => 'Loading';

  @override
  String get stateErrorTitle => 'This didn\'t load';

  @override
  String get stateErrorSafe => 'Your tasks are safe on this device.';

  @override
  String get stateRetry => 'Try again';

  @override
  String get stateReadFailed => 'Couldn\'t read your tasks on this device.';

  @override
  String get inboxSelect => 'Select';

  @override
  String get inboxPlanThese => 'Plan these';

  @override
  String inboxSelectedLabel(String title) {
    return '$title, selected';
  }

  @override
  String get onboardingWelcomeTitle => 'Your day, as a thread.';

  @override
  String get onboardingWelcomeBody =>
      'Plan your day as dots on a line, see where the time goes, and move it all when the day moves.';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingSignIn => 'I already have an account';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String onboardingStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onboardingDotLabel => 'The day dot, drawing itself';

  @override
  String get onboardingDayShapeTitle => 'When does your day start and end?';

  @override
  String get onboardingDayShapeBody =>
      'Your tasks live between these two. You can change them, or give each weekday its own, in Settings.';

  @override
  String get onboardingHabitsTitle => 'What fills your days?';

  @override
  String get onboardingHabitsBody =>
      'Pick up to five. They go on tomorrow\'s thread at times that fit your day; change them any time.';

  @override
  String onboardingHabitsAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count to tomorrow',
      one: 'Add 1 to tomorrow',
    );
    return '$_temp0';
  }

  @override
  String get onboardingHabitsMax => 'Five is plenty to start with.';

  @override
  String get starterMorningRun => 'Morning run';

  @override
  String get starterDeepWork => 'Deep work';

  @override
  String get starterLunch => 'Lunch';

  @override
  String get starterWalk => 'Walk';

  @override
  String get starterGym => 'Gym';

  @override
  String get starterRead => 'Read';

  @override
  String get starterPlanTomorrow => 'Plan tomorrow';

  @override
  String onboardingHabitMeta(String time, String length) {
    return '$time · $length';
  }

  @override
  String get onboardingRemindersTitle => 'Want a nudge?';

  @override
  String get onboardingRemindersBody =>
      'Dottoday reminds you when a task starts and before bedtime. You can change this any time in Settings.';

  @override
  String get onboardingTaskStarts => 'Before each task';

  @override
  String get onboardingTaskStartsDetail =>
      'How early is up to you, in Settings';

  @override
  String get onboardingBedtime => 'At Bedtime';

  @override
  String get onboardingBedtimeDetail =>
      'Tomorrow\'s first task, so the morning has no surprises';

  @override
  String get onboardingAllow => 'Allow notifications';

  @override
  String get onboardingNotNow => 'Not now';

  @override
  String get onboardingAccountTitle => 'Keep your tasks in sync?';

  @override
  String get onboardingAccountBody =>
      'Sign in to use Dottoday on all your devices with a copy kept safe. Or don\'t: everything works on this device without an account.';

  @override
  String get onboardingWithoutAccount => 'Continue without an account';

  @override
  String get onboardingDoneTitle => 'Your first thread';

  @override
  String get onboardingDoneBody =>
      'Tomorrow, from Wake Up to Bedtime. Add to it, drag things around, or start with today.';

  @override
  String get onboardingDoneEmpty =>
      'Tomorrow, from Wake Up to Bedtime, is all yours. Add the first task whenever you like.';

  @override
  String get onboardingOpenToday => 'Open today';

  @override
  String get onboardingTomorrow => 'Tomorrow';

  @override
  String get onboardingWelcomeBackTitle => 'Welcome back';

  @override
  String get onboardingWelcomeBackBody =>
      'Sign in to bring your tasks to this device.';

  @override
  String get accountEmailLabel => 'Email';

  @override
  String get accountSendLink => 'Send me a link';

  @override
  String get accountOtherWays => 'Other ways to sign in';

  @override
  String get accountEmailInvalid => 'That doesn\'t look like an email address.';

  @override
  String get accountCheckMailTitle => 'Check your mail';

  @override
  String accountCheckMailBody(String email) {
    return 'We sent a sign-in link to $email. Open it on this device to carry on.';
  }

  @override
  String get accountResend => 'Send it again';

  @override
  String get accountOtherEmail => 'Use a different email';

  @override
  String get accountErrorTitle => 'Couldn\'t sign in';

  @override
  String get accountRestoring => 'Bringing your tasks to this device…';

  @override
  String accountRestoreCount(int done, int total) {
    return '$done of $total';
  }

  @override
  String notifStartsIn(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return 'Starts in $_temp0';
  }

  @override
  String get notifStartsNow => 'Starting now';

  @override
  String get notifEndsNow => 'Ending now';

  @override
  String notifOverdue(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return 'Ended $_temp0 ago. Done?';
  }

  @override
  String get notifSnoozed => 'Snoozed reminder';

  @override
  String get notifBedtimeTitle => 'Bedtime';

  @override
  String notifBedtimeFirst(String title, String time) {
    return 'Tomorrow starts with $title at $time.';
  }

  @override
  String get notifBedtimeFree => 'Nothing planned for tomorrow yet.';

  @override
  String get notifActionDone => 'Done';

  @override
  String get notifActionSnooze => 'Snooze 10 min';

  @override
  String get notifActionOpen => 'Open';

  @override
  String get notifChannelAlerts => 'Task alerts';

  @override
  String get notifChannelAlertsDetail =>
      'Reminders before, at and after your tasks';

  @override
  String get notifChannelAlarms => 'Start of your day';

  @override
  String get notifChannelAlarmsDetail =>
      'Rings like an alarm for the first task of your day and when a routine starts';

  @override
  String get notifChannelSummary => 'Bedtime';

  @override
  String get notifChannelSummaryDetail => 'The nightly look at tomorrow';

  @override
  String inAppAlertText(String title, String detail) {
    return '$title · $detail';
  }

  @override
  String get inAppAlertLater => 'Later';

  @override
  String get widgetNextUp => 'Next up';

  @override
  String get widgetNow => 'Now';

  @override
  String widgetUntil(String time) {
    return 'until $time';
  }

  @override
  String get widgetNothingNext => 'Nothing else today';

  @override
  String get widgetToday => 'Today';

  @override
  String widgetInboxCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in Inbox',
      one: '1 in Inbox',
      zero: 'Inbox is clear',
    );
    return '$_temp0';
  }

  @override
  String get menuFile => 'File';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuView => 'View';

  @override
  String get menuGo => 'Go';

  @override
  String get menuWindow => 'Window';

  @override
  String get menuSettings => 'Settings…';

  @override
  String get menuNewTask => 'New Task';

  @override
  String get menuExport => 'Export…';

  @override
  String get menuUndo => 'Undo';

  @override
  String get menuMonth => 'Month';

  @override
  String get menuShortcuts => 'Keyboard Shortcuts';

  @override
  String get menuPreviousDay => 'Previous Day';

  @override
  String get menuNextDay => 'Next Day';

  @override
  String get exactTitle => 'Reminders may come a few minutes after their time';

  @override
  String get exactBody =>
      'To save battery, Android can hold reminders back. Allow exact timing so each one arrives when your task starts.';

  @override
  String get exactAllow => 'Allow exact timing';

  @override
  String get skipToContent => 'Skip to content';

  @override
  String get installText =>
      'Install Dottoday: opens like an app and works offline';

  @override
  String get installAction => 'Install';

  @override
  String get lockCaption => 'APP LOCK';

  @override
  String get lockToggle => 'Lock Dottoday';

  @override
  String get lockToggleDetail => 'Ask for your face, fingerprint or passcode';

  @override
  String get lockWebTitle => 'Uses your computer\'s lock';

  @override
  String get lockWebDetail =>
      'In a browser, Dottoday is as locked as your computer. Lock your screen when you step away; tasks stay encrypted in this browser.';

  @override
  String get lockAfter => 'Lock after';

  @override
  String get lockAfterNow => 'Right away';

  @override
  String lockAfterMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get lockReason => 'Unlock Dottoday';

  @override
  String get lockTitle => 'Dottoday is locked';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockUnavailable =>
      'This device has no passcode, so Dottoday can\'t lock.';

  @override
  String zoneBannerText(String city) {
    return 'You\'re now in $city — keep times or shift?';
  }

  @override
  String get zoneKeep => 'Keep times';

  @override
  String get zoneShift => 'Shift';

  @override
  String zoneKeptSnack(String city) {
    return 'Tasks kept at their times in $city';
  }

  @override
  String zoneShiftedSnack(String city) {
    return 'Tasks shifted to $city time';
  }

  @override
  String get syncAgoJustNow => 'just now';

  @override
  String syncAgoMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String syncAgoHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours h ago',
      one: '1 h ago',
    );
    return '$_temp0';
  }

  @override
  String syncLineSynced(String ago) {
    return 'Synced · $ago';
  }

  @override
  String get syncLineSyncing => 'Syncing…';

  @override
  String get syncLineOffline => 'Offline · changes saved here';

  @override
  String clockFast(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Your clock is $minutes min fast',
      one: 'Your clock is 1 min fast',
    );
    return '$_temp0 — reminders may be early';
  }

  @override
  String clockSlow(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Your clock is $minutes min slow',
      one: 'Your clock is 1 min slow',
    );
    return '$_temp0 — reminders may arrive after their time';
  }

  @override
  String get syncClockWaiting =>
      'Changes from this device wait until the clock is right; changes from your other devices still arrive.';

  @override
  String get healthTitle => 'Notification health';

  @override
  String get healthCaption => 'This device';

  @override
  String get healthIntro =>
      'What decides whether your reminders get through on this device, read from its settings right now.';

  @override
  String get healthAllGood => 'All good';

  @override
  String get healthPermissionOk => 'Notifications are on';

  @override
  String get healthPermissionOff => 'Notifications are off';

  @override
  String get healthPermissionOffDetail =>
      'Dottoday can\'t remind you until you allow them.';

  @override
  String get healthExactOk => 'Reminders arrive on the minute';

  @override
  String get healthExactOff =>
      'Reminders may come a few minutes after their time';

  @override
  String get healthExactOffDetail =>
      'Allow “Alarms & reminders” for Dottoday to have them on the minute.';

  @override
  String get healthBatteryOk => 'Battery saving leaves Dottoday alone';

  @override
  String get healthBatteryOff => 'Battery saving can hold reminders back';

  @override
  String get healthBatteryOffDetail =>
      'In the list, choose Dottoday and “Don\'t optimise”.';

  @override
  String get healthDndOff => 'Do Not Disturb is off';

  @override
  String get healthDndOn => 'Do Not Disturb is on';

  @override
  String get healthDndOnDetail =>
      'The first task of your day still rings; other reminders arrive quietly.';

  @override
  String get healthFocus => 'Focus';

  @override
  String get healthFocusDetail =>
      'Task starts are time-sensitive, so a Focus that allows time-sensitive notifications lets them through.';

  @override
  String get healthPushOk => 'Reminders arrive with the tab closed';

  @override
  String get healthPushOff => 'Reminders arrive while Dottoday is open';

  @override
  String get healthPushOffDetail =>
      'Sign in and allow notifications so they also arrive with the tab closed.';

  @override
  String get healthClockOk => 'Your clock is right';

  @override
  String get healthClockOffDetail =>
      'Turn on “Set automatically” in your date and time settings.';

  @override
  String get healthFixAllow => 'Allow';

  @override
  String get healthFixOpen => 'Open settings';

  @override
  String healthToFix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things to fix',
      one: '1 thing to fix',
    );
    return '$_temp0';
  }

  @override
  String get testAlarmTitle => 'Test alarm';

  @override
  String get testAlarmBody => 'It got through. Your reminders will too.';

  @override
  String get testAlarmCaption => 'Check it works';

  @override
  String get inAppAlertOk => 'OK';

  @override
  String get testAlarmRow => 'Send me a test alarm';

  @override
  String get testAlarmRowDetail => 'Check that a reminder really reaches you';

  @override
  String get testAlarmExplain =>
      'Dottoday will send one test alarm in 60 seconds so you can check it gets through.';

  @override
  String get testAlarmSend => 'Send';

  @override
  String get testAlarmCancel => 'Cancel';

  @override
  String get testAlarmAsk => 'Did it ring?';

  @override
  String get testAlarmYes => 'Yes';

  @override
  String get testAlarmNo => 'No';

  @override
  String get testAlarmGood => 'It got through. Your reminders will too.';

  @override
  String get testAlarmLookHere => 'The checks above show what\'s in the way.';

  @override
  String get testAlarmLookLater =>
      'You\'ll find what\'s in the way in Settings › Reminders › Notification health.';

  @override
  String testAlarmCountdown(int seconds) {
    return 'Ringing in $seconds s…';
  }

  @override
  String get syncLinePaused => 'Sync paused · tap Sync for why';

  @override
  String settingsSynced(String name, String ago) {
    return '$name · synced $ago';
  }

  @override
  String settingsSyncedNoName(String ago) {
    return 'Synced $ago';
  }

  @override
  String settingsNameAndStatus(String name, String status) {
    return '$name · $status';
  }

  @override
  String get calendarEventUntitled => 'Untitled event';

  @override
  String get taskLinks => 'Links';

  @override
  String taskLinkOpen(String host) {
    return 'Open $host in the browser';
  }

  @override
  String get taskLinkFailed => 'Couldn\'t open that link';

  @override
  String get calendarsWriteBack => 'Send changes back';

  @override
  String get calendarsWriteBackDetail =>
      'Moves, resizes and renames you make here go to the calendar, earlier ones too. Repeating and all-day events change here only.';

  @override
  String bannerWriteBackPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes haven\'t reached your calendar yet',
      one: '1 change hasn\'t reached your calendar yet',
    );
    return '$_temp0';
  }

  @override
  String bannerWriteBackClash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events changed in your calendar too',
      one: 'This event changed in your calendar too',
    );
    return '$_temp0';
  }

  @override
  String get bannerUseCalendars => 'Use calendar\'s';

  @override
  String taskCalendarSends(String calendar) {
    return 'Changes go back to $calendar';
  }

  @override
  String taskCalendarStays(String calendar) {
    return 'From $calendar · changes stay in Dottoday';
  }

  @override
  String get travelTitle => 'Travel time';

  @override
  String travelSuggestDetail(String place, String duration) {
    return 'At $place. Keep $duration before it for getting there?';
  }

  @override
  String travelSuggestAdd(String duration) {
    return 'Add $duration before';
  }

  @override
  String travelAdded(String title) {
    return 'Travel time added before “$title”';
  }

  @override
  String get travelNone => 'None';

  @override
  String travelBefore(String duration) {
    return '$duration before';
  }

  @override
  String rowTravelMeta(String duration) {
    return '· $duration travel';
  }

  @override
  String rowTravel(String label, String duration) {
    return '$label, $duration travel time before';
  }

  @override
  String get calendarsTravel => 'Travel time';

  @override
  String get calendarsTravelSuggest => 'Suggest travel time';

  @override
  String get calendarsTravelSuggestDetail =>
      'Before events with a place. Worked out on this device; no maps are asked';

  @override
  String rowFromCalendar(String label) {
    return '$label, from your calendar';
  }

  @override
  String get pinTitle => 'Pinned';

  @override
  String get pinDetail => 'Stays put when other tasks shift';

  @override
  String threadOutsideBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks before Wake Up',
      one: '1 task before Wake Up',
    );
    return '$_temp0';
  }

  @override
  String threadOutsideAfter(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks after Bedtime',
      one: '1 task after Bedtime',
    );
    return '$_temp0';
  }
}
