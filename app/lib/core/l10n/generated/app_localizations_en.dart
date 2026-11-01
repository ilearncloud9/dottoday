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
  String get dotOpenHint => 'Open';

  @override
  String threadOverlapShare(String first, String second, String share) {
    return '$first and $second $share';
  }

  @override
  String threadOverlapShareTime(String duration) {
    return 'share $duration';
  }

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
    return 'Wind Down · $time';
  }

  @override
  String get capEditHint => 'Change time';

  @override
  String get capEveryDay => 'Every day';

  @override
  String capEveryWeekday(String weekday) {
    return 'Every $weekday';
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
  String durationFitsWindDown(String time) {
    return 'Fits before Wind Down at $time';
  }

  @override
  String durationRunsInto(String title, String time) {
    return 'Runs into $title at $time';
  }

  @override
  String durationPastWindDown(String time) {
    return 'Runs past Wind Down at $time';
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
  String get settingsWindDown => 'Wind Down';

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
  String get settingsWindDownReminder => 'Wind Down reminder';

  @override
  String settingsWindDownReminderDetail(String time) {
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
  String snackSeriesNotSent(String calendar) {
    return 'Changed in Dottoday only. $calendar couldn\'t be reached.';
  }

  @override
  String seriesDeleteCalendarTitle(String calendar) {
    return 'Also delete it from $calendar?';
  }

  @override
  String get seriesDeleteOnlyHere => 'Only in Dottoday';

  @override
  String seriesDeleteFromCalendar(String calendar) {
    return 'Delete from $calendar too';
  }

  @override
  String get seriesDeleteFromCalendarDetail =>
      'Every repeat goes, on all your devices. Undo here can\'t bring it back.';

  @override
  String snackSeriesDeletedThere(String title, String calendar) {
    return '$title deleted here and from $calendar';
  }

  @override
  String snackSeriesNotDeletedThere(String calendar) {
    return 'Deleted in Dottoday. $calendar couldn\'t be reached.';
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
  String get alertsWindDown => 'Wind Down reminder';

  @override
  String get alertsWindDownDetail =>
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
  String get iconSearchHint => 'Search icons';

  @override
  String iconSearchEmpty(String query) {
    return 'No icons match “$query”';
  }

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
  String get privacyCrashTitle => 'Crash reports';

  @override
  String get privacyCrashBody =>
      'If the app crashes, it sends the kind of error and where in the app it happened. Never your tasks, notes or account.';

  @override
  String get privacyPolicyOpen => 'Read the privacy policy';

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
  String get onboardingAgeNote => 'Dottoday is for people aged 13 and over.';

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
      'Dottoday reminds you when a task starts and before Wind Down. You can change this any time in Settings.';

  @override
  String get onboardingTaskStarts => 'Before each task';

  @override
  String get onboardingTaskStartsDetail =>
      'How early is up to you, in Settings';

  @override
  String get onboardingWindDown => 'At Wind Down';

  @override
  String get onboardingWindDownDetail =>
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
      'Tomorrow, from Wake Up to Wind Down. Add to it, drag things around, or start with today.';

  @override
  String get onboardingDoneEmpty =>
      'Tomorrow, from Wake Up to Wind Down, is all yours. Add the first task whenever you like.';

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
  String get notifWindDownTitle => 'Wind Down';

  @override
  String notifWindDownFirst(String title, String time) {
    return 'Tomorrow starts with $title at $time.';
  }

  @override
  String get notifWindDownFree => 'Nothing planned for tomorrow yet.';

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
  String get notifChannelSummary => 'Wind Down';

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
  String get menuRedo => 'Redo';

  @override
  String get menuDelete => 'Delete';

  @override
  String get shortcutUndo => 'Undo the last change';

  @override
  String get shortcutRedo => 'Redo what was undone';

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
      other: '$count tasks after Wind Down',
      one: '1 task after Wind Down',
    );
    return '$_temp0';
  }

  @override
  String get shortcutPickTask => 'Pick the previous or next task';

  @override
  String get shortcutNudgeTask =>
      'Move the picked tasks 5 min earlier or later';

  @override
  String get shortcutNudgeTaskMore =>
      'Move the picked tasks 15 min earlier or later';

  @override
  String get shortcutTrashTask => 'Move the picked tasks to Trash';

  @override
  String get shortcutOpenTask => 'Open the picked task';

  @override
  String get shortcutDoneTask => 'Mark the picked task done';

  @override
  String get shortcutKeyDelete => 'Delete';

  @override
  String get shortcutKeySpace => 'Space';

  @override
  String get editorEnergy => 'Energy';

  @override
  String get energyLow => 'Low';

  @override
  String get energyMedium => 'Medium';

  @override
  String get energyHigh => 'High';

  @override
  String get editorNotesFormat =>
      '**bold**, *italic*, - lists and links work here';

  @override
  String navInboxBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inbox, $count tasks',
      one: 'Inbox, 1 task',
    );
    return '$_temp0';
  }

  @override
  String get inboxNudgeTitle => 'Plan your inbox';

  @override
  String inboxNudgeDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tasks are waiting in your Inbox. A good moment to give them a time?',
      one: '1 task is waiting in your Inbox. A good moment to give it a time?',
    );
    return '$_temp0';
  }

  @override
  String get inboxNudgeAction => 'Plan';

  @override
  String get settingsInboxNudge => 'Plan-your-inbox nudge';

  @override
  String get settingsInboxNudgeDetail =>
      'Once a day from Wake Up, when the Inbox holds tasks';

  @override
  String settingsAlertsMore(String first, int count) {
    return '$first +$count';
  }

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsSoundSystem => 'System sound';

  @override
  String get settingsSoundDetail =>
      'For task reminders. Tap one to hear it. The first task of the day keeps its alarm.';

  @override
  String get soundDot => 'Dot';

  @override
  String get soundChime => 'Chime';

  @override
  String get soundBell => 'Bell';

  @override
  String get soundRipple => 'Ripple';

  @override
  String get soundDotAlarm => 'Dot alarm';

  @override
  String get soundQuietSlip => 'Slip';

  @override
  String get soundQuietWhisper => 'Whisper';

  @override
  String get soundQuietSoft => 'Soft';

  @override
  String get soundQuietBubble => 'Bubble';

  @override
  String get soundQuietPull => 'Pull';

  @override
  String get soundClearLift => 'Lift';

  @override
  String get soundClearBright => 'Bright';

  @override
  String get soundClearSmile => 'Smile';

  @override
  String get soundClearEase => 'Ease';

  @override
  String get soundClearTurn => 'Turn';

  @override
  String get soundClearSettled => 'Settled';

  @override
  String get soundClearQuick => 'Quick';

  @override
  String get soundClearOpening => 'Opening';

  @override
  String get soundClearSpark => 'Spark';

  @override
  String get soundClearEmerge => 'Emerge';

  @override
  String get soundClearElegant => 'Elegant';

  @override
  String get soundClearDutiful => 'Dutiful';

  @override
  String get soundClearInvolved => 'Involved';

  @override
  String get soundClearAppear => 'Appear';

  @override
  String get soundClearTap => 'Tap';

  @override
  String get soundStartMorning => 'Morning';

  @override
  String get soundStartBells => 'Soft bells';

  @override
  String get soundStartSunrise => 'Sunrise';

  @override
  String get soundStartSolemn => 'Solemn';

  @override
  String get soundStartStrike => 'Strike';

  @override
  String get soundStartSwing => 'Swing';

  @override
  String get soundStartLovingly => 'Lovingly';

  @override
  String get soundStartGentle => 'Gentle';

  @override
  String get soundStartInsistent => 'Insistent';

  @override
  String get soundStartSlowBell => 'Slow bell';

  @override
  String get soundStartMusicBox => 'Music box';

  @override
  String get soundStartDawnChorus => 'Dawn chorus';

  @override
  String get soundStartRain => 'Rain';

  @override
  String get soundStartStream => 'Stream';

  @override
  String get soundStartWaves => 'Waves';

  @override
  String get soundStartWindChimes => 'Wind chimes';

  @override
  String get soundStartForest => 'Forest';

  @override
  String get soundStartClockBell => 'Clock bell';

  @override
  String get soundStartBeepRise => 'Beep rise';

  @override
  String get soundPlayRooster => 'Rooster';

  @override
  String get soundPlayHorse => 'Horse';

  @override
  String get soundPlayKnock => 'Knock';

  @override
  String get soundPlayChick => 'Chick';

  @override
  String get soundPlayFrog => 'Frog';

  @override
  String get soundPlayDog => 'Dog';

  @override
  String get soundPlayGulls => 'Gulls';

  @override
  String get soundPlayDrum => 'Drum';

  @override
  String get soundDoneSwift => 'Swift';

  @override
  String get soundDoneChecked => 'Checked';

  @override
  String get soundDoneDone => 'Done';

  @override
  String get soundDoneFinished => 'Finished';

  @override
  String get soundDoneSucceeded => 'Succeeded';

  @override
  String get soundDoneAchieved => 'Achieved';

  @override
  String notifChannelAlarmsSound(String sound) {
    return 'Start of your day · $sound';
  }

  @override
  String get notifChannelAlertsSilent => 'Task alerts · No sound';

  @override
  String get notifGroupDots => 'Dot reminders';

  @override
  String get notifGroupStart => 'Start of day';

  @override
  String get healthSoundsOk => 'Reminder sounds are on';

  @override
  String healthSoundsMuted(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The sounds for $names are muted in system settings',
      one: 'The sound for $names is muted in system settings',
    );
    return '$_temp0';
  }

  @override
  String get healthSoundsMutedDetail =>
      'Open Dottoday\'s notification settings and turn the sound back on.';

  @override
  String get soundsTitle => 'Sounds';

  @override
  String get soundsIntro =>
      'Task reminders play this, unless a task has its own. Tap one to hear it.';

  @override
  String get soundsTaskCaption => 'Task reminders';

  @override
  String get soundNone => 'None';

  @override
  String get soundNoneDetail => 'Shows and vibrates, without a sound';

  @override
  String get soundSectionQuiet => 'Quiet';

  @override
  String get soundSectionClear => 'Clear';

  @override
  String get soundSectionPlayful => 'Playful';

  @override
  String get soundsMoreCaption => 'Also';

  @override
  String get soundsStart => 'Start sound';

  @override
  String get soundsStartDetail =>
      'Rings for the first task of your day and when a routine starts';

  @override
  String get soundsDone => 'Done sound';

  @override
  String get soundsDoneDetail => 'When you tick a task done';

  @override
  String get soundsInApp => 'Sounds in app';

  @override
  String get soundsInAppDetail => 'The Done sound and the Focus tick';

  @override
  String get soundsEffectsCaption => 'Sound effects';

  @override
  String get soundsHapticsInApp => 'Haptics in app';

  @override
  String get soundsHapticsInAppDetail =>
      'Taps you feel as you drag, drop and tick a task done';

  @override
  String get soundsEffectsFooter =>
      'Sounds and haptics may not play, depending on your device\'s settings.';

  @override
  String get soundInsistentNote =>
      'Loud and repeating. Use it if quieter sounds don\'t reach you.';

  @override
  String get soundsMuted =>
      'Your device is muted — you may still get vibration';

  @override
  String soundsCredit(String source, String license) {
    return 'Sounds from $source ($license).';
  }

  @override
  String soundDefault(String sound) {
    return 'Default · $sound';
  }

  @override
  String get soundDefaultOption => 'Default';

  @override
  String get sheetSound => 'Sound';

  @override
  String get settingsQuietHours => 'Quiet hours';

  @override
  String get settingsQuietHoursOff => 'Reminders arrive silently at night';

  @override
  String settingsQuietHoursOn(String from, String until) {
    return '$from–$until: reminders arrive silently. The first task of the day still rings.';
  }

  @override
  String get settingsQuietFrom => 'From';

  @override
  String get settingsQuietUntil => 'Until';

  @override
  String get settingsDaySummary => 'Day-start summary';

  @override
  String get settingsDaySummaryOff => 'Off';

  @override
  String get settingsDaySummaryDetail =>
      'At Wake Up on the days you choose: “Your day: 6 blocks, first at 08:00”.';

  @override
  String get notifDaySummaryTitle => 'Your day';

  @override
  String notifDaySummaryBody(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blocks, first at $time',
      one: '1 block, at $time',
    );
    return '$_temp0';
  }

  @override
  String notifChannelAlertsSound(String sound) {
    return 'Task alerts · $sound';
  }

  @override
  String liveActivityLeft(String time) {
    return '$time left';
  }

  @override
  String liveActivityStartsIn(String time) {
    return 'starts in $time';
  }

  @override
  String liveActivityCount(int done, int total) {
    return '$done of $total';
  }

  @override
  String liveActivityCountLabel(int done, int total) {
    return '$done of $total done today';
  }

  @override
  String get privacyThinkingTitle => 'Help with thinking';

  @override
  String get privacyThinkingBody =>
      'Break it down and suggestions are worked out on this device: Apple Intelligence on iPhone and Mac, Gemini Nano on Android, the browser\'s built-in model in Chrome. Where none is available, Dottoday uses your own history and simple rules. What you type is never sent to a server; what was asked and answered stays on this device.';

  @override
  String get privacyThinkingOnDevice =>
      'On this device now: the built-in model.';

  @override
  String get privacyThinkingRules =>
      'On this device now: your history and simple rules.';

  @override
  String get privacyClearThinking => 'Clear thinking history';

  @override
  String get snackThinkingCleared => 'Thinking history cleared';

  @override
  String get proposalAccept => 'Accept';

  @override
  String get proposalDiscard => 'Discard';

  @override
  String get proposalNothingSaved => 'Nothing is saved until you accept';

  @override
  String get proposalLegendNow => 'now';

  @override
  String get proposalLegendProposed => 'proposed';

  @override
  String proposalShiftedLater(String duration) {
    return 'shifted +$duration';
  }

  @override
  String proposalShiftedEarlier(String duration) {
    return 'shifted −$duration';
  }

  @override
  String proposalShrunk(String duration) {
    return 'shrunk to $duration';
  }

  @override
  String proposalGrown(String duration) {
    return 'grown to $duration';
  }

  @override
  String proposalMovedTo(String when) {
    return 'moved to $when';
  }

  @override
  String get proposalMovedToInbox => 'moved to Inbox';

  @override
  String get proposalAdded => 'new';

  @override
  String get proposalUntouched => 'pinned · untouched';

  @override
  String proposalSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get proposalNothing => 'Nothing to change';

  @override
  String proposalKeep(String title) {
    return 'Keep $title as it is';
  }

  @override
  String proposalDayTime(String day, String time) {
    return '$day $time';
  }

  @override
  String get stepLengthAdd => '+ time';

  @override
  String stepLengthHint(String title) {
    return 'Change how long $title takes';
  }

  @override
  String get stepLengthTitle => 'How long is this step?';

  @override
  String get stepLengthNone => 'No time';

  @override
  String get editorStepsSum => 'Length = sum of steps';

  @override
  String editorStepsSumTotal(String duration) {
    return 'Steps add up to $duration';
  }

  @override
  String get editorStepsSumEmpty => 'Give a step a time to use this';

  @override
  String get breakdownAction => 'Break it down';

  @override
  String get breakdownOnDevice => 'on-device';

  @override
  String get breakdownUsual => 'your usual';

  @override
  String breakdownStepHint(int number) {
    return 'Step $number';
  }

  @override
  String get breakdownAddStep => 'Add a step';

  @override
  String breakdownDepth(int depth, int max) {
    return 'depth $depth of $max';
  }

  @override
  String get breakdownSplit => 'Break this down';

  @override
  String get breakdownRemove => 'Remove step';

  @override
  String breakdownShow(String title) {
    return 'More for $title';
  }

  @override
  String breakdownTotal(String duration) {
    return 'Total $duration · the dot grows to fit';
  }

  @override
  String get breakdownSmallest =>
      'You\'ll be asked for the first step only if this stays unstarted (Smallest step)';

  @override
  String breakdownWasNow(String before, String after) {
    return 'was $before → now $after';
  }

  @override
  String breakdownJoin(String parent, String step) {
    return '$parent · $step';
  }

  @override
  String breakdownAccepted(String title) {
    return 'Steps added to $title';
  }

  @override
  String breakdownStepsOnDraft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0 · saved with the task';
  }

  @override
  String get focusTitle => 'Focus';

  @override
  String get focusBack => 'Today';

  @override
  String focusRange(String range, String length) {
    return '$range · $length';
  }

  @override
  String focusStep(int number, int total) {
    return 'Step $number of $total';
  }

  @override
  String get focusAllSteps => 'Every step done';

  @override
  String get focusChime => 'Chime every 15 min';

  @override
  String get focusDeepWork => 'Deep work · Focus on';

  @override
  String get focusDeepWorkAccess => 'Allow Dottoday to turn on Do Not Disturb';

  @override
  String get focusShortcutsTitle => 'Turn on Focus with Shortcuts';

  @override
  String get focusShortcutsBody =>
      'iPhone and Mac don\'t let apps switch Focus. In Shortcuts, make a shortcut with Dottoday\'s Start focus and Set Focus, and run it from the Action button, Control Center or Siri.';

  @override
  String get focusShortcutsOpen => 'Open Shortcuts';

  @override
  String get focusDeepWorkWeb =>
      'Use your computer\'s Do Not Disturb; the browser can\'t change it';

  @override
  String get focusNextStep => 'Next step';

  @override
  String get focusBreakThrough =>
      'Dot starts still break through Focus (time-sensitive)';

  @override
  String get focusMore => 'More';

  @override
  String get focusOpenTask => 'Task details';

  @override
  String focusDoneMessage(String title) {
    return '$title done';
  }

  @override
  String focusExtendedMessage(String title) {
    return '$title · 15 min more';
  }

  @override
  String get focusOpenHint => 'Open Focus';

  @override
  String smallestStepTitle(String step, String length) {
    return 'Just $step · $length?';
  }

  @override
  String smallestStepTitleShort(String step) {
    return 'Just $step?';
  }

  @override
  String get smallestStepStart => 'Start';

  @override
  String get unstickPrompt =>
      'What\'s the very first thing you\'d physically do?';

  @override
  String get unstickHint => 'e.g. Open the folder';

  @override
  String get unstickSave => 'Make it step 1';

  @override
  String unstickSaved(String title) {
    return 'Step 1 added to $title';
  }

  @override
  String get rebalanceAccept => 'Accept plan';

  @override
  String get rebalanceFootnote =>
      'Nothing moves until you accept · Undo for 30 s after';

  @override
  String get rebalanceShiftFollowers => 'Shift followers';

  @override
  String get rebalanceAllowShrink => 'Allow shrinking optional';

  @override
  String get rebalancePastWindDown => 'Push past Wind Down';

  @override
  String rebalanceRanOver(String title, String duration) {
    return '$title ran over by $duration · here\'s a plan';
  }

  @override
  String rebalanceLate(String duration) {
    return 'The rest of today, $duration later · here\'s a plan';
  }

  @override
  String rebalanceRunsOver(String title, String duration) {
    return '$title runs $duration over · here\'s a plan';
  }

  @override
  String get rebalanceAccepted => 'Plan accepted';

  @override
  String get calendarMovedTitle => 'Calendar changed';

  @override
  String calendarMovedDetail(String title, String time) {
    return '$title moved to $time · Rebalance?';
  }

  @override
  String get calendarMovedAction => 'Rebalance';

  @override
  String rebalanceMoved(String title, String time) {
    return '$title moved to $time · here\'s a plan';
  }

  @override
  String realityMetaJoin(String text) {
    return '· $text';
  }

  @override
  String realityPlanned(String time) {
    return 'planned $time';
  }

  @override
  String get realityNotStarted => 'not started yet';

  @override
  String realityTook(String duration) {
    return 'took $duration';
  }

  @override
  String realityRunning(String duration) {
    return '$duration in';
  }

  @override
  String get realityNow => 'now';

  @override
  String get realityPlan => 'Plan';

  @override
  String get realityReality => 'Reality';

  @override
  String learnUsually(String duration) {
    return 'usually $duration';
  }

  @override
  String learnStartsAfter(int minutes) {
    return 'usually starts ~$minutes min after plan';
  }

  @override
  String learnStartsBefore(int minutes) {
    return 'usually starts ~$minutes min before plan';
  }

  @override
  String learnInsight(String title, String duration) {
    return '$title usually takes you $duration · Add will suggest it';
  }

  @override
  String get learnInsightOk => 'OK';

  @override
  String learnCaption(int total, int done) {
    return 'Your reality thread appears after about $total finished tasks · $done so far';
  }

  @override
  String get learnCaptionHide => 'Hide until tomorrow';

  @override
  String get learnRealityReady =>
      'Plan and reality view is now in the day header';

  @override
  String get realityNothingStartedToday => 'nothing started yet today';

  @override
  String learnBasedOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'time',
    );
    return 'based on your last $_temp0 · median';
  }

  @override
  String learnEnergyBasedOn(int count) {
    return 'based on your last $count finished high-energy tasks · where most started';
  }

  @override
  String learnFromHistory(String value) {
    return '$value, learned from your history';
  }

  @override
  String get learnExplainHint => 'Shows how this was worked out';

  @override
  String get learnReset => 'Reset for this task on this device';

  @override
  String learnResetDone(String title) {
    return 'Learning for $title reset on this device';
  }

  @override
  String learnResetConfirm(String title) {
    return 'Forget what $title taught, on this device?';
  }

  @override
  String get learnResetConfirmAction => 'Reset';

  @override
  String get learnResetKeep => 'Keep';

  @override
  String lateUsually(String title, String duration) {
    return '$title usually takes $duration';
  }

  @override
  String get routinesTitle => 'Routines';

  @override
  String get routinesSubtitle => 'Reusable slices of thread';

  @override
  String routineSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String routineSummary(String steps, String duration, String anchor) {
    return '$steps · $duration · $anchor';
  }

  @override
  String get routineStartsWake => 'starts at Wake Up';

  @override
  String get routineEndsBed => 'ends at Wind Down';

  @override
  String routineStartsAt(String time) {
    return 'starts at $time';
  }

  @override
  String get routineDropToday => 'Drop on today';

  @override
  String get routineEdit => 'Edit';

  @override
  String get routineNew => 'New routine';

  @override
  String get routineNewHint => 'or save a selection from any day';

  @override
  String get routineAlarmNote => 'Routine-start dots ring loud, like an alarm';

  @override
  String get routinesEmpty =>
      'No routines yet. Pick a few tasks on any day and save them as a routine, or start a new one.';

  @override
  String get routineSaveSelection => 'Save as routine';

  @override
  String get routineName => 'Name';

  @override
  String routineSaved(String title) {
    return 'Saved “$title” as a routine';
  }

  @override
  String routineDeleted(String title) {
    return 'Deleted “$title”';
  }

  @override
  String get routineDelete => 'Delete routine';

  @override
  String get routineEditTitle => 'Edit routine';

  @override
  String get routineAnchorLabel => 'When';

  @override
  String get routineAnchorWake => 'At Wake Up';

  @override
  String get routineAnchorBed => 'Ending at Wind Down';

  @override
  String get routineAnchorTime => 'At a time';

  @override
  String get routineStepsLabel => 'Steps';

  @override
  String get routineStepHint => 'Step name';

  @override
  String get routineAddStep => 'Add step';

  @override
  String routineRemoveStep(String title) {
    return 'Remove $title';
  }

  @override
  String routineMoveUp(String title) {
    return 'Move $title up';
  }

  @override
  String routineMoveDown(String title) {
    return 'Move $title down';
  }

  @override
  String routineGap(String duration) {
    return '$duration free';
  }

  @override
  String get routineSave => 'Save';

  @override
  String get routineDropTitle => 'Routine';

  @override
  String routineDropSubtitle(String title, String day, String time) {
    return '$title on $day · from $time';
  }

  @override
  String get routineDropAccept => 'Add to day';

  @override
  String get routineDropAccepted => 'Routine added';

  @override
  String routineChipLabel(String title) {
    return 'Drop routine $title';
  }

  @override
  String get routinesMenu => 'Routines…';

  @override
  String get routinesSuggestions => 'Routines';

  @override
  String get routineInvalid => 'Give the routine a name and at least one step';

  @override
  String routinesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routines',
      one: '1 routine',
      zero: 'No routines',
    );
    return '$_temp0';
  }

  @override
  String get routineDropHere => 'Drop a routine…';

  @override
  String routineDropOnDay(String day) {
    return 'Drop on $day';
  }

  @override
  String get routineDropDay => 'Which day';

  @override
  String get settingsEnergy => 'Energy suggestions';

  @override
  String get settingsEnergyDetail =>
      'Suggest times when you usually finish high-energy tasks';

  @override
  String settingsEnergyLocked(int total, int count) {
    return 'After $total finished high-energy tasks · $count so far';
  }

  @override
  String settingsEnergyReady(int count) {
    return 'ready — based on $count completed tasks';
  }

  @override
  String get settingsLearning => 'Learning';

  @override
  String get settingsLearningReality => 'Reality thread';

  @override
  String settingsLearningRealityPending(int total) {
    return 'Dottoday is learning how your days really go. Your reality thread appears after about $total finished tasks.';
  }

  @override
  String get settingsLearningRealityReady =>
      'Ready · Plan / Reality is in Today\'s header';

  @override
  String get settingsLearningDurations => 'Task lengths';

  @override
  String settingsLearningDurationsPending(int min) {
    return 'Dottoday is learning how long your tasks really take. Each task shows its usual length after about $min finished times.';
  }

  @override
  String settingsLearningTasksReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ready for $count tasks',
      one: 'Ready for 1 task',
    );
    return '$_temp0';
  }

  @override
  String get settingsLearningSteps => 'Step lengths';

  @override
  String settingsLearningStepsPending(int min) {
    return 'Dottoday is learning how long each step takes. A step\'s timer uses its usual length after about $min finished times.';
  }

  @override
  String settingsLearningStepsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ready for $count steps',
      one: 'Ready for 1 step',
    );
    return '$_temp0';
  }

  @override
  String settingsLearningProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String settingsLearningProgressLabel(int done, int total) {
    return '$done of $total so far';
  }

  @override
  String get settingsLearningPrivacy =>
      'Learning happens on your device. Your actual start and end times sync with your account like the rest of your plan; the learned numbers themselves are never uploaded.';

  @override
  String addEnergyBest(String range) {
    return 'you finish high-energy tasks best $range';
  }

  @override
  String addEnergyTry(String time) {
    return 'Try $time';
  }

  @override
  String get debugLoadM11Sample => 'Load M11 sample (debug)';

  @override
  String get debugM11Loaded => 'M11 sample loaded';

  @override
  String get proposalOverlaps => 'already here · overlaps';

  @override
  String get weekReviewTitle => 'This week';

  @override
  String weekReviewDates(String from, String to) {
    return '$from – $to';
  }

  @override
  String weekReviewDotCount(int done, int total) {
    return '$done/$total';
  }

  @override
  String weekReviewDayLabel(String day, int done, int total, String planned) {
    return '$day: $done of $total done, $planned planned';
  }

  @override
  String weekReviewPlanned(String planned) {
    return '$planned planned';
  }

  @override
  String weekReviewPlannedBusiest(String planned) {
    return '$planned · busiest';
  }

  @override
  String weekReviewBusiest(String day) {
    return 'Busiest · $day';
  }

  @override
  String weekReviewLightest(String day) {
    return 'Lightest · $day';
  }

  @override
  String get weekPaceMornings => 'Mornings mostly went to plan.';

  @override
  String get weekPaceAfternoons => 'Afternoons mostly went to plan.';

  @override
  String get weekPaceAllDone => 'Everything you planned got done.';

  @override
  String get weekPaceQuiet => 'A quiet week: nothing was planned.';

  @override
  String weekLoadBoth(String busiest, String lightest) {
    return '$busiest carried the most; $lightest breathed.';
  }

  @override
  String weekLoadBusiest(String busiest) {
    return '$busiest carried the most.';
  }

  @override
  String weekCarryAsk(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unfinished · move them to next week?',
      one: '1 unfinished · move it to next week?',
    );
    return '$_temp0';
  }

  @override
  String get weekCarryPlace => 'Place';

  @override
  String get weekCarryInbox => 'Leave in Inbox';

  @override
  String get weekCarryTitle => 'Next week';

  @override
  String weekCarrySubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unfinished tasks, each in the first free time that fits',
      one: '1 unfinished task, each in the first free time that fits',
    );
    return '$_temp0';
  }

  @override
  String get weekCarryAccept => 'Place them';

  @override
  String get weekCarryAccepted => 'Placed in next week';

  @override
  String get weekShareTitles => 'Show task titles';

  @override
  String get weekShareImage => 'Share image';

  @override
  String weekShareDayTitles(String day, String titles) {
    return '$day · $titles';
  }

  @override
  String get weekReviewNoStreaks => 'No streaks here — just what happened.';

  @override
  String get weekPromptDetail => 'Your week in seven dots';

  @override
  String get weekPromptAction => 'See the week';

  @override
  String get lowEnergyMode => 'Low-energy mode';

  @override
  String get lowEnergyTurnOff => 'Turn off low-energy mode';

  @override
  String get settingsLowEnergyDetail =>
      'Today shows only what\'s next and nudges pause, until your next Wake Up';

  @override
  String lowEnergyCaption(String date) {
    return '$date · Low-energy';
  }

  @override
  String get lowEnergyGreeting => 'Take it easy';

  @override
  String lowEnergyGreetingName(String name) {
    return 'Take it easy, $name';
  }

  @override
  String get lowEnergyOn => 'Low-energy · on';

  @override
  String lowEnergyUntil(String time, String left) {
    return 'until $time · $left left';
  }

  @override
  String lowEnergyAt(String time) {
    return 'at $time';
  }

  @override
  String get lowEnergyNotToday => 'Not today';

  @override
  String lowEnergyMovedTomorrow(String title) {
    return '$title moved to tomorrow';
  }

  @override
  String lowEnergySkipped(String title) {
    return '$title skipped for today';
  }

  @override
  String lowEnergyLater(int count) {
    return 'Later · $count';
  }

  @override
  String get lowEnergyShowLater => 'Show what\'s later';

  @override
  String get lowEnergyHideLater => 'Hide what\'s later';

  @override
  String get lowEnergyPropose => 'Move everything optional to tomorrow?';

  @override
  String get lowEnergyProposeAction => 'Propose';

  @override
  String get lowEnergyNudgesOff => 'Nudges are off until tomorrow\'s Wake Up';

  @override
  String get lowEnergyNothing => 'Nothing else today. Rest well.';

  @override
  String get lowEnergyProposalTitle => 'Tomorrow';

  @override
  String lowEnergyProposalSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count optional tasks, each in tomorrow\'s first free time',
      one: '1 optional task, in tomorrow\'s first free time',
    );
    return '$_temp0';
  }

  @override
  String get lowEnergyProposalAccept => 'Move them';

  @override
  String get lowEnergyProposalAccepted => 'Moved to tomorrow';

  @override
  String get journalTitle => 'Past days';

  @override
  String get journalEntryDetail => 'Every day you planned, as it went';

  @override
  String get journalSearchHint => 'When did I last…';

  @override
  String journalDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days in the last 12 months',
      one: '1 day in the last 12 months',
    );
    return '$_temp0';
  }

  @override
  String journalLast(String date, int ago, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      ago,
      locale: localeName,
      other: '$ago days ago',
      one: 'yesterday',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ago,
      locale: localeName,
      other: '$ago days ago',
      one: 'yesterday',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Last: $date · $_temp0 · $count days',
      one: 'Last: $date · $_temp1 · once',
    );
    return '$_temp2';
  }

  @override
  String journalNoMatch(String query) {
    return 'Nothing in the last 12 months matches “$query”';
  }

  @override
  String get journalEmpty =>
      'No past days yet. Days you plan show up here once they\'re over.';

  @override
  String journalDayLabel(String date, String summary) {
    return '$date, $summary. Open the day';
  }

  @override
  String journalMatch(String title, String time) {
    return '$title · $time';
  }

  @override
  String get journalStripTitle => 'Year strip';

  @override
  String journalStripLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your year as dots: $count days planned',
      one: 'Your year as dots: 1 day planned',
    );
    return '$_temp0';
  }

  @override
  String get dumpTitle => 'Brain dump';

  @override
  String get dumpHint => 'Everything on your mind, one thing per line';

  @override
  String get dumpPlan => 'Plan it';

  @override
  String get dumpNothing => 'Nothing to plan yet. Write one thing per line.';

  @override
  String dumpSubtitle(int count, String day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks on $day, in the first free time',
      one: '1 task on $day, in the first free time',
    );
    return '$_temp0';
  }

  @override
  String get dumpAccepted => 'Added from your brain dump';

  @override
  String get dumpEarlier => 'Earlier dumps';

  @override
  String get dumpSearch => 'Search earlier dumps';

  @override
  String get dumpUseAgain => 'Use again';

  @override
  String get proposalToInbox => 'no room · to the Inbox';

  @override
  String get releaseNotes100 =>
      'See time: your next dot on the lock screen, widgets, the Mac menu bar and Siri, and alarms that really ring.\nStart: Break it down into small steps, Focus on one dot, and gentle help when a task won\'t start.\nStay in control: Rebalance shows a plan before anything moves; Plan / Reality shows how the day really went.\nRoutines, energy suggestions and lengths learned from your own days, on your device.\nThis week as seven dots, Past days to look back, and low-energy mode for hard days. Nothing to keep up.\nShare a page or a note to Dottoday from any app, or empty your head with Brain dump.';

  @override
  String get privacyAiAppleOffIos =>
      'Turn on Apple Intelligence in iPhone Settings › Apple Intelligence & Siri. Dottoday will use it automatically.';

  @override
  String get privacyAiAppleOffMac =>
      'Turn on Apple Intelligence in System Settings › Apple Intelligence & Siri. Dottoday will use it automatically.';

  @override
  String get privacyAiAppleDownloading =>
      'Apple Intelligence is getting ready on this device. It can take a while.';

  @override
  String get privacyAiGoogleDownloadable =>
      'Gemini Nano can be downloaded on this phone; it downloads in the background.';

  @override
  String get privacyAiGoogleDownloading =>
      'Gemini Nano is downloading on this phone. Dottoday will use it once it\'s ready.';

  @override
  String get privacyAiChromeDownloadable =>
      'This browser can download its built-in AI model. Dottoday will use it once it\'s there.';

  @override
  String get privacyAiChromeDownloading =>
      'This browser is downloading its built-in AI model. Dottoday will use it once it\'s ready.';

  @override
  String get privacyAiNotEligible =>
      'This device can\'t run the built-in model. Dottoday uses your history and simple rules.';

  @override
  String get privacyAiOpenSettings => 'Open Settings';

  @override
  String get privacyAiOpenSettingsIos =>
      'Opens Dottoday\'s page in Settings. Apple doesn\'t let apps open Apple Intelligence directly: go back to Settings, then Apple Intelligence & Siri.';

  @override
  String get thinkingOriginRules => 'simple rules';

  @override
  String get thinkingHintLead => 'Made with simple rules';

  @override
  String get thinkingHintApple =>
      'Turn on Apple Intelligence for smarter plans';

  @override
  String get thinkingHintAppleReady =>
      'Apple Intelligence is getting ready for smarter plans';

  @override
  String get thinkingHintGoogle =>
      'Gemini Nano makes smarter plans once it\'s on this phone';

  @override
  String get thinkingHintChrome =>
      'Your browser\'s built-in AI makes smarter plans once it\'s ready';

  @override
  String get thinkingHintDismiss => 'Don\'t show again';

  @override
  String get dumpPlansApple => 'Plans with Apple Intelligence on this device';

  @override
  String get dumpPlansGoogle => 'Plans with Gemini Nano on this phone';

  @override
  String get dumpPlansChrome =>
      'Plans with your browser\'s built-in AI, on this device';

  @override
  String get dumpPlansRules => 'Plans with simple rules';

  @override
  String get releaseNotes110 =>
      'Speak it: tap the mic in Brain dump and say what\'s on your mind — pause, or say \"next\", to start a new task. The mic is in a task\'s notes too. Your words are turned into text on this device and never sent anywhere.\nAsk Siri: on iPhone, Settings › Siri & Shortcuts shows the five things you can ask, like \"What\'s next in Dottoday\".\nKnow who plans: Settings › Privacy says whether Apple Intelligence, Gemini Nano or your browser\'s built-in AI is helping on this device, and how to turn it on. Plans made with simple rules now say so.';

  @override
  String statusHintJoin(String lead, String action) {
    return '$lead · $action';
  }

  @override
  String get settingsSiri => 'Siri & Shortcuts';

  @override
  String get settingsSiriDetail => 'Ask Siri about your day';

  @override
  String get siriIntro =>
      'Siri can add a task, tell you what\'s next, and help with the task you\'re on — without opening Dottoday.';

  @override
  String get siriHowTo =>
      'Say \"Hey Siri\" or hold the side button, then say a phrase.';

  @override
  String get siriPhrasesCaption => 'What you can say';

  @override
  String get siriPhraseAdd => 'Add a task in Dottoday';

  @override
  String get siriPhraseAddDetail =>
      'Siri asks what to add. Say a time and it goes on your day; otherwise it goes to the Inbox.';

  @override
  String get siriPhraseNext => 'What\'s next in Dottoday';

  @override
  String get siriPhraseNextDetail =>
      'Siri says what\'s on now, or what comes next.';

  @override
  String get siriPhraseDone => 'Mark my task done in Dottoday';

  @override
  String get siriPhraseDoneDetail => 'Ticks off the task you\'re on.';

  @override
  String get siriPhrasePlus15 => 'Give my task 15 more minutes in Dottoday';

  @override
  String get siriPhrasePlus15Detail =>
      'Gives the task you\'re on 15 more minutes.';

  @override
  String get siriPhraseFocus => 'Start focus in Dottoday';

  @override
  String get siriPhraseFocusDetail => 'Opens Focus on the task you\'re on.';

  @override
  String get siriShortcutsCaption => 'Shortcuts';

  @override
  String get siriShortcutsBody =>
      'The same five actions are in the Shortcuts app, ready for the Action button, Control Center or your Home Screen.';

  @override
  String get siriOpenShortcuts => 'Open Shortcuts';

  @override
  String get siriTipTitle => 'Ask Siri \"What\'s next in Dottoday\"';

  @override
  String get siriTipShow => 'Show me';

  @override
  String get tipDismiss => 'Don\'t show again';

  @override
  String get onboardingSiriLine =>
      'You can also ask Siri \"What\'s next in Dottoday\".';

  @override
  String get dictationCommand => 'next';

  @override
  String get micDictate => 'Dictate';

  @override
  String get micStop => 'Stop dictation';

  @override
  String get micDenied => 'Microphone is off for Dottoday';

  @override
  String get failureSpeech => 'Dictation stopped. Tap the mic to go on.';

  @override
  String get micRationaleTitle => 'Use the microphone?';

  @override
  String get micRationaleBody =>
      'Dottoday listens only while the mic button is on, to turn your words into text on this device.';

  @override
  String get micRationaleContinue => 'Continue';

  @override
  String get dumpListening => 'Pause, or say \"next\", to start a new task.';

  @override
  String get dumpHintMic => 'Type or tap the mic. One thing per line.';

  @override
  String get dumpMicTipTitle => 'Speak your list';

  @override
  String get dumpMicTipBody =>
      'Pause, or say \"next\", between things. \"Call the dentist … next … buy milk\" becomes two lines.';

  @override
  String get layoutShowEverything => 'Show everything';

  @override
  String get layoutShowLess => 'Show less';

  @override
  String get layoutRow => 'Layout';

  @override
  String get layoutMinimal => 'Minimal';

  @override
  String get layoutFull => 'Full';

  @override
  String laterRow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Later · $count',
      zero: 'Later',
    );
    return '$_temp0';
  }

  @override
  String laterRowLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Later, $count tasks waiting',
      one: 'Later, 1 task waiting',
      zero: 'Later, nothing waiting',
    );
    return '$_temp0';
  }

  @override
  String get moreOptions => 'More';

  @override
  String get sheetLater => 'Later';

  @override
  String get sheetDelete => 'Delete';

  @override
  String get settingsEverythingElse => 'Everything else…';

  @override
  String get settingsRemindDotStarts => 'Remind me when a dot starts';

  @override
  String get settingsAccountAndSync => 'Account and sync';

  @override
  String addWhenChip(String time) {
    return 'At $time';
  }

  @override
  String get onboardingLayoutTitle => 'How much do you want to see?';

  @override
  String get onboardingLayoutBody =>
      'You can change this any time, from the top of Settings.';

  @override
  String get onboardingLayoutMinimalTitle => 'Just the next dot';

  @override
  String get onboardingLayoutMinimalBody =>
      'What\'s now and what\'s next. Add, do, done. Nothing to set up.';

  @override
  String get onboardingLayoutFullTitle => 'The full planner';

  @override
  String get onboardingLayoutFullBody =>
      'The whole thread, week and month, routines, reviews, widgets and every setting.';

  @override
  String get onboardingFirstTaskTitle => 'What\'s one thing for today?';

  @override
  String get onboardingFirstTaskBody =>
      'Type it the way you\'d say it, like \"call Sam 6pm\". It goes on your thread.';

  @override
  String get onboardingFirstTaskAdd => 'Put it on today';

  @override
  String get hintRoutines => 'Save this as your morning?';

  @override
  String get hintBreakDown => 'Break it into steps?';

  @override
  String get hintWidget => 'Want the next dot on your home screen too?';

  @override
  String get hintWidgetHow =>
      'Add the Dottoday widget from your home screen\'s widget list.';

  @override
  String get hintWeek => 'See your week as seven dots?';

  @override
  String get hintLearned =>
      'Dottoday can start pre-filling times from how long things really take.';

  @override
  String get hintShowMe => 'Show me';

  @override
  String get settingsWakeUpAlarm => 'Wake Up alarm';

  @override
  String get settingsWakeUpAlarmDetail =>
      'Rings like an alarm at Wake Up on days you\'ve planned';

  @override
  String get wakeUpTierAlarm => 'Alarm-grade wake-up is on.';

  @override
  String get wakeUpTierTimeSensitive =>
      'Wake Up rings as a time-sensitive notification.';

  @override
  String get wakeUpTierTimeSensitiveDetail =>
      'It breaks through Focus. The Silent switch still mutes it.';

  @override
  String get wakeUpTierFsiRevoked =>
      'Wake Up can take over the screen like an alarm. Android needs you to allow it.';

  @override
  String get wakeUpTierNoPermission =>
      'Wake Up can\'t ring while notifications are off.';

  @override
  String get wakeUpTierNotAPhone => 'Wake-up alarms ring on your phone.';

  @override
  String get notifWakeUpTitle => 'Wake Up';

  @override
  String notifWakeUpFirst(String title, String time) {
    return 'First: $title at $time';
  }

  @override
  String get notifWakeUpBody => 'Good morning.';

  @override
  String get settingsWakeUpOptions => 'Wake Up options';

  @override
  String get wakeUpAlarmCaption => 'Alarm';

  @override
  String get wakeUpFixUpdate => 'How to update';

  @override
  String get wakeUpMoreOptions => 'More options';

  @override
  String get wakeUpRamp => 'Volume ramp';

  @override
  String get wakeUpRampDetail =>
      'Starts quieter and rises to your alarm volume.';

  @override
  String get wakeUpRampOff => 'Off';

  @override
  String get wakeUpSnooze => 'Snooze';

  @override
  String get wakeUpSnoozeCaption => 'Snooze';

  @override
  String get wakeUpSnoozeDetail => 'Rings again a few minutes later.';

  @override
  String get wakeUpSnoozeLength => 'Snooze length';

  @override
  String get wakeUpSnoozeLimit => 'Snooze limit';

  @override
  String get wakeUpSnoozeNoLimit => 'No limit';

  @override
  String get wakeUpSnoozeRow => 'Snooze';

  @override
  String get wakeUpSoundCaption => 'Sound';

  @override
  String get wakeUpSoundRow => 'Alarm sound';

  @override
  String get wakeUpStop => 'I\'m up';

  @override
  String get wakeUpTestLookHere =>
      'If it didn\'t ring, the line at the top says what\'s in the way.';

  @override
  String get wakeUpTierAlarmsOff =>
      'Wake Up can ring like an alarm, but alarms are off for Dottoday in Settings.';

  @override
  String get wakeUpTierNeedsUpdate =>
      'Your iPhone can\'t ring Wake Up like an alarm yet. That needs iOS 26.';

  @override
  String get wakeUpVary => 'Vary the sound';

  @override
  String get wakeUpVaryDetail =>
      'A different alarm sound each day, so it stays easy to hear.';

  @override
  String wakeUpRampSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String wakeUpSnoozeTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'Once',
    );
    return '$_temp0';
  }

  @override
  String get wakeUpCardFirst => 'First';

  @override
  String get wakeUpCardNext => 'Next';

  @override
  String get wakeUpCardShift => 'Shift the rest?';

  @override
  String get wakeUpCardStart => 'Start the day';

  @override
  String get wakeUpCardLater => 'Later';

  @override
  String get wakeUpCardEmpty => 'Nothing planned yet';

  @override
  String get wakeUpCardPlan => 'Plan today';

  @override
  String get wakeUpCardShowDay => 'Show my day';

  @override
  String get wakeUpCardCaption => 'Morning card';

  @override
  String get wakeUpCardRow => 'Morning card';

  @override
  String get wakeUpCardRowDetail => 'Your day on one screen when you\'re up';

  @override
  String get wakeUpCardOnOpenRow => 'Show it when I first open the app';

  @override
  String get wakeUpCardCalendarRow => 'Calendar on the card';

  @override
  String get wakeUpCardInboxRow => 'Inbox count on the card';

  @override
  String get wakeUpLateOfferRow =>
      'Offer to shift the day when I\'m up after plan';

  @override
  String get wakeUpLateAfterRow => 'After';

  @override
  String wakeUpCardGreeting(String date) {
    return 'Good morning. $date.';
  }

  @override
  String wakeUpCardPlanned(int count, String time) {
    return '$count planned · ends $time';
  }

  @override
  String wakeUpCardFirstStep(String step, String length) {
    return 'first: $step · $length';
  }

  @override
  String wakeUpCardFirstStepShort(String step) {
    return 'first: $step';
  }

  @override
  String wakeUpCardCalendar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events today',
      one: '1 event today',
    );
    return '$_temp0';
  }

  @override
  String wakeUpCardInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in Inbox',
      one: '1 in Inbox',
    );
    return '$_temp0';
  }

  @override
  String wakeUpCardLate(int min) {
    return 'You\'re up $min min after plan.';
  }

  @override
  String healthLastWakeUp(String rang, String up) {
    return 'Last wake-up: rang $rang, up $up';
  }

  @override
  String healthLastWakeUpUp(String up) {
    return 'Last wake-up: up $up';
  }

  @override
  String healthLastWakeUpRang(String rang) {
    return 'Last wake-up: rang $rang';
  }

  @override
  String get wakeUpCheckBody => 'Tap to start.';

  @override
  String get wakeUpCheckCaption => 'Check I\'ve started';

  @override
  String get wakeUpCheckRow => 'Check I\'ve started';

  @override
  String get wakeUpCheckRowDetail =>
      'One nudge if nothing has started a few minutes after I\'m up';

  @override
  String get wakeUpCheckAsRow => 'As';

  @override
  String get wakeUpCheckGentle => 'Gentle ping';

  @override
  String get wakeUpCheckAlarm => 'Alarm';

  @override
  String wakeUpCheckStart(String title) {
    return 'Start $title?';
  }

  @override
  String get settingsSleepTarget => 'Sleep target';

  @override
  String get settingsSleepTargetOff => 'Off';

  @override
  String get settingsSleepTargetDetail =>
      'Wind Down moves earlier before an early morning';

  @override
  String get settingsShowNight => 'Show the night on the day dot';

  @override
  String get reviewSleepOffer =>
      'New: tell Dottoday how much sleep you want, and Wind Down will move earlier before an early Wake Up.';

  @override
  String get reviewSleepOfferSet => 'Set';

  @override
  String get reviewSleepOfferLater => 'No thanks';

  @override
  String get onboardingSleepTarget => 'How much sleep do you want?';

  @override
  String nightLabel(String length) {
    return 'Night · $length';
  }

  @override
  String reviewNightUntil(String length, String time) {
    return '$length until Wake Up at $time';
  }

  @override
  String reviewNightIfNow(String length) {
    return '$length if you wind down now';
  }

  @override
  String notifWindDownNudge(String length, String title, String time) {
    return 'Wind down now for $length before $title at $time.';
  }

  @override
  String notifWindDownNudgeNoDot(String length, String time) {
    return 'Wind down now for $length before $time.';
  }

  @override
  String settingsWindDownFrom(String time, String wake) {
    return '$time · from tomorrow\'s $wake';
  }

  @override
  String todayWindDownFooter(String start, String windDown) {
    return 'Tomorrow starts $start → wind down $windDown';
  }

  @override
  String onboardingWindDownLive(String time, String length) {
    return 'Wind Down $time · $length of sleep';
  }

  @override
  String get sleepLess => 'Less sleep';

  @override
  String get sleepMore => 'More sleep';

  @override
  String get releaseNotes120 =>
      'Wake Up alarm: turn it on in Settings › Day shape and your Wake Up time rings on days you\'ve planned — like an alarm on Android and on iPhones with iOS 26, as a time-sensitive notification on older iPhones. Pick its sound and snooze under Sound and snooze, and send yourself a test. Nothing rings until you turn it on.\nSounds: 48 reminder sounds made to sit well together. Pick one for every task or give a task its own; your first task of the day rings with your Start sound.\nJust the next dot: a minimal layout you can choose any time, with nothing lost. Today shows your thread, the date and one menu.\nDrag a task anywhere on the day, even onto another one: overlapping tasks tie a small knot in the thread.\nBedtime is now Wind Down. The two ends of your day are dots, a sun and a moon; tap one to change its time.\nIcons fill themselves in: type \"Gym\" and the task gets a dumbbell, from 524 icons.\nThe night: tell Dottoday how much sleep you want and Wind Down moves earlier before an early morning. The day dot shows the night, and the Wind Down review opens with it.';

  @override
  String get settingsMissions => 'Missions';

  @override
  String get missionModeOff => 'Off';

  @override
  String get missionModeWhenAsked => 'Only when I ask';

  @override
  String get missionModeAfterSnooze => 'Only after a snooze';

  @override
  String get missionModeChosenDays => 'Only on chosen days';

  @override
  String get missionModeAlways => 'Every time';

  @override
  String get settingsMissionDays => 'Days';

  @override
  String get settingsMission => 'Mission';

  @override
  String get missionStandUp => 'Stand up';

  @override
  String get missionWalk => 'Walk';

  @override
  String get missionLight => 'Light';

  @override
  String get missionBreathe => 'Breathe';

  @override
  String get missionCatchDot => 'Catch the dot';

  @override
  String get missionOneThing => 'Pick today\'s one thing';

  @override
  String get missionOnScreenNote => 'Wakes you up, doesn\'t get you up';

  @override
  String get settingsMissionSteps => 'Steps';

  @override
  String get settingsMissionBackup => 'Backup mission';

  @override
  String get missionBackupNone => 'None';

  @override
  String get settingsMissionSkipOffer =>
      'Offer to turn missions off after repeated skips';

  @override
  String get missionNeedsAlarm => 'Needs alarm-grade wake-up';

  @override
  String get missionSensorMissing => 'This phone has no sensor for it';

  @override
  String get missionSensorDenied =>
      'Allow access in the phone\'s settings to use it';

  @override
  String get missionOneThingNeeds => 'Needs at least two dots that day.';

  @override
  String get missionLineStandUp => 'Stand up and move';

  @override
  String missionLineWalk(int count) {
    return 'Walk $count steps';
  }

  @override
  String get missionLineLight => 'Turn on a light';

  @override
  String get missionLineBreathe => 'Breathe with the ring';

  @override
  String missionLineCatchDot(int count) {
    return 'Catch the dot $count times';
  }

  @override
  String missionStepsProgress(int done, int target) {
    return '$done of $target steps';
  }

  @override
  String missionHoldProgress(int done, int target) {
    return '$done of $target s';
  }

  @override
  String get missionLightDark => 'Still too dark';

  @override
  String get missionLightBright => 'Bright enough, keep it on';

  @override
  String get missionUprightHint => 'Hold the phone upright and move';

  @override
  String get missionBreatheHold => 'Hold';

  @override
  String get missionBreatheLetGo => 'Let go';

  @override
  String missionBreathCount(int done, int total) {
    return 'Breath $done of $total';
  }

  @override
  String get missionCatchTap => 'Tap the dot';

  @override
  String missionCatchCount(int done, int total) {
    return '$done of $total';
  }

  @override
  String get missionCantNow => 'Can\'t right now';

  @override
  String get missionCantNowHint => 'Hold for 5 seconds';

  @override
  String get missionOffOffer =>
      'Missions seem to get in the way lately. Turn them off?';

  @override
  String get missionOffOfferTurnOff => 'Turn off';

  @override
  String get missionOffOfferKeep => 'Keep them';

  @override
  String rowOneThing(String label) {
    return '$label, your one thing';
  }

  @override
  String get oneThingMeta => 'Your one thing';

  @override
  String oneThingMetaJoin(String meta) {
    return '$meta · Your one thing';
  }

  @override
  String get oneThingAsk => 'What matters most today?';

  @override
  String get oneThingEveryAnswer => 'Tap one. Every answer is right.';

  @override
  String get oneThingToday => 'TODAY';

  @override
  String get oneThingInbox => 'INBOX';

  @override
  String get oneThingMenu => 'Pick today\'s one thing…';

  @override
  String get oneThingNothing =>
      'Nothing to pick from yet. Plan a dot or two first.';

  @override
  String get oneThingInInbox => 'in your Inbox';

  @override
  String startNudgeTitle(String title) {
    return 'Start $title?';
  }

  @override
  String get startNudgeBody => 'Tap Start when you\'re ready.';

  @override
  String get settingsStartNudge => 'Ask when a dot hasn\'t started';

  @override
  String get settingsStartNudgeDetail =>
      '10 minutes after its start, one gentle ping: \"Start Run?\"';

  @override
  String get taskIconCategoryPlanning => 'Planning & rhythm';

  @override
  String get taskIconCategoryHealth => 'Health & body';

  @override
  String get taskIconCategoryFitness => 'Fitness & sport';

  @override
  String get taskIconCategoryFood => 'Food & drink';

  @override
  String get taskIconCategoryHome => 'Home & chores';

  @override
  String get taskIconCategoryWork => 'Work & study';

  @override
  String get taskIconCategoryTech => 'Tech & devices';

  @override
  String get taskIconCategoryTravel => 'Travel & transport';

  @override
  String get taskIconCategoryNature => 'Nature & weather';

  @override
  String get taskIconCategoryAnimals => 'Animals';

  @override
  String get taskIconCategoryPeople => 'People & social';

  @override
  String get taskIconCategoryLeisure => 'Leisure & hobbies';

  @override
  String get taskIconCategoryShopping => 'Shopping & money';

  @override
  String get taskIconCategoryStyle => 'Clothing & beauty';

  @override
  String get taskIconCategoryFaith => 'Faith & celebrations';

  @override
  String get taskIconCategorySymbols => 'Symbols & signs';

  @override
  String get taskIconFocusBlock => 'Focus Block';

  @override
  String get taskIconDeepWork => 'Deep Work';

  @override
  String get taskIconPlanTheDay => 'Plan the Day';

  @override
  String get taskIconTimeBlock => 'Time Block';

  @override
  String get taskIconBuffer => 'Buffer';

  @override
  String get taskIconAnytime => 'Anytime';

  @override
  String get taskIconTakeABreak => 'Break';

  @override
  String get taskIconMorningRoutine => 'Morning Routine';

  @override
  String get taskIconEveningRoutine => 'Evening Routine';

  @override
  String get taskIconWindDown => 'Wind Down';

  @override
  String get taskIconPowerNap => 'Power Nap';

  @override
  String get taskIconWeekReview => 'Week Review';

  @override
  String get taskIconInboxZero => 'Inbox Zero';

  @override
  String get taskIconHabit => 'Habit';

  @override
  String get taskIconErrands => 'Errands';

  @override
  String get taskIconLowEnergy => 'Low Energy';

  @override
  String get taskIconHighEnergy => 'High Energy';

  @override
  String get taskIconScreenFree => 'Screen-free';

  @override
  String get taskIconStandUp => 'Stand-up';

  @override
  String get taskIconSelfCare => 'Self-care';

  @override
  String get taskIconMealPrep => 'Meal Prep';

  @override
  String get taskIconPayBills => 'Pay Bills';

  @override
  String get taskIconAllergens => 'Allergens';

  @override
  String get taskIconBandage => 'Bandage';

  @override
  String get taskIconBloodBag => 'Blood Bag';

  @override
  String get taskIconBrain => 'Brain';

  @override
  String get taskIconCrutch => 'Crutch';

  @override
  String get taskIconDoctor => 'Doctor';

  @override
  String get taskIconEar => 'Ear';

  @override
  String get taskIconEcg => 'ECG';

  @override
  String get taskIconEyes => 'Eyes';

  @override
  String get taskIconFaceMask => 'Face Mask';

  @override
  String get taskIconFalling => 'Falling';

  @override
  String get taskIconHead => 'Head';

  @override
  String get taskIconHearingDevice => 'Hearing Device';

  @override
  String get taskIconHeart => 'Heart';

  @override
  String get taskIconHospital => 'Hospital';

  @override
  String get taskIconLungs => 'Lungs';

  @override
  String get taskIconMedicalThermometer => 'Medical Thermometer';

  @override
  String get taskIconMicrobe => 'Microbe';

  @override
  String get taskIconPharmacy => 'Pharmacy';

  @override
  String get taskIconMeds => 'Pill';

  @override
  String get taskIconPills => 'Pills';

  @override
  String get taskIconSleep => 'Sleep';

  @override
  String get taskIconSleepyMoon => 'Sleepy Moon';

  @override
  String get taskIconStanding => 'Standing';

  @override
  String get taskIconStarOfLife => 'Star of Life';

  @override
  String get taskIconSyringe => 'Syringe';

  @override
  String get taskIconTherapy => 'Therapy';

  @override
  String get taskIconTooth => 'Tooth';

  @override
  String get taskIconToothbrush => 'Toothbrush';

  @override
  String get taskIconVial => 'Vial';

  @override
  String get taskIconWheelchair => 'Wheelchair';

  @override
  String get taskIconAmericanFootball => 'American Football';

  @override
  String get taskIconArchery => 'Archery';

  @override
  String get taskIconAustralianFootball => 'Australian Football';

  @override
  String get taskIconBaseball => 'Baseball';

  @override
  String get taskIconBasketball => 'Basketball';

  @override
  String get taskIconBowling => 'Bowling';

  @override
  String get taskIconCoreTraining => 'Core Training';

  @override
  String get taskIconCricket => 'Cricket';

  @override
  String get taskIconCrossTraining => 'Cross Training';

  @override
  String get taskIconCurling => 'Curling';

  @override
  String get taskIconCycling => 'Cycling';

  @override
  String get taskIconDancing => 'Dancing';

  @override
  String get taskIconGym => 'Dumbbell';

  @override
  String get taskIconFencing => 'Fencing';

  @override
  String get taskIconGolf => 'Golf';

  @override
  String get taskIconGymnastics => 'Gymnastics';

  @override
  String get taskIconHandball => 'Handball';

  @override
  String get taskIconHelmet => 'Helmet';

  @override
  String get taskIconHiit => 'HIIT';

  @override
  String get taskIconHiking => 'Hiking';

  @override
  String get taskIconHorseRiding => 'Horse Riding';

  @override
  String get taskIconIceSkates => 'Ice Skates';

  @override
  String get taskIconJogging => 'Jogging';

  @override
  String get taskIconMartialArts => 'Martial Arts';

  @override
  String get taskIconMedal => 'Medal';

  @override
  String get taskIconPoolSwimming => 'Pool Swimming';

  @override
  String get taskIconRopeJumping => 'Rope Jumping';

  @override
  String get taskIconRowing => 'Rowing';

  @override
  String get taskIconRugby => 'Rugby';

  @override
  String get taskIconRun => 'Running';

  @override
  String get taskIconSailing => 'Sailing';

  @override
  String get taskIconScubaDiving => 'Scuba Diving';

  @override
  String get taskIconSkateboard => 'Skateboard';

  @override
  String get taskIconSkating => 'Skating';

  @override
  String get taskIconSkiing => 'Skiing';

  @override
  String get taskIconSnowboard => 'Snowboard';

  @override
  String get taskIconSnowboarding => 'Snowboarding';

  @override
  String get taskIconSoccer => 'Soccer';

  @override
  String get taskIconSoftball => 'Softball';

  @override
  String get taskIconSportcourt => 'Sportcourt';

  @override
  String get taskIconStairStepper => 'Stair Stepper';

  @override
  String get taskIconStepping => 'Stepping';

  @override
  String get taskIconStopwatch => 'Stopwatch';

  @override
  String get taskIconStretching => 'Stretching';

  @override
  String get taskIconSwimming => 'Swimming';

  @override
  String get taskIconTableTennis => 'Table Tennis';

  @override
  String get taskIconTennis => 'Tennis';

  @override
  String get taskIconTrackAndField => 'Track and Field';

  @override
  String get taskIconTrophy => 'Trophy';

  @override
  String get taskIconVolleyball => 'Volleyball';

  @override
  String get taskIconWalking => 'Walking';

  @override
  String get taskIconWaterPolo => 'Water Polo';

  @override
  String get taskIconWeightLifting => 'Weight Lifting';

  @override
  String get taskIconYoga => 'Yoga';

  @override
  String get taskIconAlcohol => 'Alcohol';

  @override
  String get taskIconApple => 'Apple';

  @override
  String get taskIconBeer => 'Beer';

  @override
  String get taskIconBurger => 'Burger';

  @override
  String get taskIconCandy => 'Candy';

  @override
  String get taskIconCarrot => 'Carrot';

  @override
  String get taskIconCheese => 'Cheese';

  @override
  String get taskIconChopsticks => 'Chopsticks';

  @override
  String get taskIconCoffee => 'Coffee';

  @override
  String get taskIconCooking => 'Cooking';

  @override
  String get taskIconCookingStove => 'Cooking Stove';

  @override
  String get taskIconCup => 'Cup';

  @override
  String get taskIconDumplings => 'Dumplings';

  @override
  String get taskIconFryingPan => 'Frying Pan';

  @override
  String get taskIconIceCream => 'Ice Cream';

  @override
  String get taskIconMeal => 'Meal';

  @override
  String get taskIconMicrowave => 'Microwave';

  @override
  String get taskIconMug => 'Mug';

  @override
  String get taskIconOven => 'Oven';

  @override
  String get taskIconPizza => 'Pizza';

  @override
  String get taskIconPopcorn => 'Popcorn';

  @override
  String get taskIconSoup => 'Soup';

  @override
  String get taskIconTakeout => 'Takeout';

  @override
  String get taskIconTray => 'Tray';

  @override
  String get taskIconWaterBottle => 'Water Bottle';

  @override
  String get taskIconWater => 'Water Glass';

  @override
  String get taskIconWineGlass => 'Wine Glass';

  @override
  String get taskIconWrap => 'Wrap';

  @override
  String get taskIconAirConditioner => 'Air Conditioner';

  @override
  String get taskIconAirPurifier => 'Air Purifier';

  @override
  String get taskIconAx => 'Ax';

  @override
  String get taskIconBathtub => 'Bathtub';

  @override
  String get taskIconBed => 'Bed';

  @override
  String get taskIconBlinds => 'Blinds';

  @override
  String get taskIconBookshelf => 'Bookshelf';

  @override
  String get taskIconBox => 'Box';

  @override
  String get taskIconBroom => 'Broom';

  @override
  String get taskIconCeilingFan => 'Ceiling Fan';

  @override
  String get taskIconCeilingLamp => 'Ceiling Lamp';

  @override
  String get taskIconChair => 'Chair';

  @override
  String get taskIconChairLounge => 'Chair Lounge';

  @override
  String get taskIconCouch => 'Couch';

  @override
  String get taskIconDehumidifier => 'Dehumidifier';

  @override
  String get taskIconDishwasher => 'Dishwasher';

  @override
  String get taskIconDoor => 'Door';

  @override
  String get taskIconDryer => 'Dryer';

  @override
  String get taskIconDuster => 'Duster';

  @override
  String get taskIconFan => 'Fan';

  @override
  String get taskIconFireplace => 'Fireplace';

  @override
  String get taskIconFloorLamp => 'Floor Lamp';

  @override
  String get taskIconFridge => 'Fridge';

  @override
  String get taskIconGarage => 'Garage';

  @override
  String get taskIconHammer => 'Hammer';

  @override
  String get taskIconHeater => 'Heater';

  @override
  String get taskIconHome => 'House';

  @override
  String get taskIconHouseWithFlag => 'House with Flag';

  @override
  String get taskIconHumidifier => 'Humidifier';

  @override
  String get taskIconIron => 'Iron';

  @override
  String get taskIconKey => 'Key';

  @override
  String get taskIconLaundryBasket => 'Laundry Basket';

  @override
  String get taskIconLawnMower => 'Lawn Mower';

  @override
  String get taskIconLevel => 'Level';

  @override
  String get taskIconLightBulb => 'Light Bulb';

  @override
  String get taskIconMop => 'Mop';

  @override
  String get taskIconPottedPlant => 'Potted Plant';

  @override
  String get taskIconRake => 'Rake';

  @override
  String get taskIconRecycling => 'Recycling';

  @override
  String get taskIconRefrigerator => 'Refrigerator';

  @override
  String get taskIconShadeRoller => 'Shade Roller';

  @override
  String get taskIconShades => 'Shades';

  @override
  String get taskIconShovel => 'Shovel';

  @override
  String get taskIconShower => 'Shower';

  @override
  String get taskIconSink => 'Sink';

  @override
  String get taskIconSnowShovel => 'Snow Shovel';

  @override
  String get taskIconSoap => 'Soap';

  @override
  String get taskIconStairs => 'Stairs';

  @override
  String get taskIconTable => 'Table';

  @override
  String get taskIconTableLamp => 'Table Lamp';

  @override
  String get taskIconToilet => 'Toilet';

  @override
  String get taskIconToiletPaper => 'Toilet Paper';

  @override
  String get taskIconTrash => 'Trash';

  @override
  String get taskIconVacuum => 'Vacuum';

  @override
  String get taskIconWashingMachine => 'Washing Machine';

  @override
  String get taskIconWateringCan => 'Watering Can';

  @override
  String get taskIconWrench => 'Wrench';

  @override
  String get taskIconAllDayTask => 'All Day Task';

  @override
  String get taskIconBiology => 'Biology';

  @override
  String get taskIconBlackboard => 'Blackboard';

  @override
  String get taskIconBook => 'Book';

  @override
  String get taskIconBookmark => 'Bookmark';

  @override
  String get taskIconBriefcase => 'Briefcase';

  @override
  String get taskIconBuilding => 'Building';

  @override
  String get taskIconCalendar => 'Calendar';

  @override
  String get taskIconList => 'Checklist';

  @override
  String get taskIconChemistry => 'Chemistry';

  @override
  String get taskIconClipboard => 'Clipboard';

  @override
  String get taskIconCode => 'Code';

  @override
  String get taskIconDeskGlobe => 'Desk Globe';

  @override
  String get taskIconDeskLamp => 'Desk Lamp';

  @override
  String get taskIconDocument => 'Document';

  @override
  String get taskIconEmail => 'Email';

  @override
  String get taskIconFile => 'File';

  @override
  String get taskIconFolder => 'Folder';

  @override
  String get taskIconHighlighter => 'Highlighter';

  @override
  String get taskIconIdCard => 'ID Card';

  @override
  String get taskIconLanguage => 'Language';

  @override
  String get taskIconLaw => 'Law';

  @override
  String get taskIconLoupe => 'Loupe';

  @override
  String get taskIconMail => 'Mail';

  @override
  String get taskIconMath => 'Math';

  @override
  String get taskIconPaperclip => 'Paperclip';

  @override
  String get taskIconPencil => 'Pencil';

  @override
  String get taskIconPencilAndRuler => 'Pencil and Ruler';

  @override
  String get taskIconPhysics => 'Physics';

  @override
  String get taskIconQuote => 'Quote';

  @override
  String get taskIconReminders => 'Reminders';

  @override
  String get taskIconRuler => 'Ruler';

  @override
  String get taskIconSchool => 'School';

  @override
  String get taskIconScissors => 'Scissors';

  @override
  String get taskIconSignature => 'Signature';

  @override
  String get taskIconSpreadsheet => 'Spreadsheet';

  @override
  String get taskIconStudentDesk => 'Student Desk';

  @override
  String get taskIconTask => 'Task';

  @override
  String get taskIconTestTube => 'Test Tube';

  @override
  String get taskIconWriting => 'Writing';

  @override
  String get taskIconZip => 'Zip';

  @override
  String get taskIconBattery => 'Battery';

  @override
  String get taskIconCaptions => 'Captions';

  @override
  String get taskIconComputerMouse => 'Computer Mouse';

  @override
  String get taskIconConnector => 'Connector';

  @override
  String get taskIconCpu => 'CPU';

  @override
  String get taskIconCurlyBraces => 'Curly Braces';

  @override
  String get taskIconDesktop => 'Desktop';

  @override
  String get taskIconDial => 'Dial';

  @override
  String get taskIconDisk => 'Disk';

  @override
  String get taskIconFax => 'Fax';

  @override
  String get taskIconFlashlight => 'Flashlight';

  @override
  String get taskIconFlipphone => 'Flipphone';

  @override
  String get taskIconGears => 'Gears';

  @override
  String get taskIconGyroscope => 'Gyroscope';

  @override
  String get taskIconHardDrive => 'Hard Drive';

  @override
  String get taskIconHeadphones => 'Headphones';

  @override
  String get taskIconKeyboard => 'Keyboard';

  @override
  String get taskIconLink => 'Link';

  @override
  String get taskIconMerge => 'Merge';

  @override
  String get taskIconMic => 'Mic';

  @override
  String get taskIconCall => 'Phone';

  @override
  String get taskIconPlug => 'Plug';

  @override
  String get taskIconPower => 'Power';

  @override
  String get taskIconPrinter => 'Printer';

  @override
  String get taskIconScanner => 'Scanner';

  @override
  String get taskIconSdCard => 'SD Card';

  @override
  String get taskIconSimcard => 'Simcard';

  @override
  String get taskIconSpeaker => 'Speaker';

  @override
  String get taskIconTerminal => 'Terminal';

  @override
  String get taskIconUpload => 'Upload';

  @override
  String get taskIconVideoProjector => 'Video Projector';

  @override
  String get taskIconWatch => 'Watch';

  @override
  String get taskIconWeb => 'Web';

  @override
  String get taskIconWifi => 'Wifi';

  @override
  String get taskIconWifiRouter => 'Wifi Router';

  @override
  String get taskIconWindows => 'Windows';

  @override
  String get taskIconTravel => 'Airplane';

  @override
  String get taskIconArrival => 'Arrival';

  @override
  String get taskIconArriving => 'Arriving';

  @override
  String get taskIconBackpack => 'Backpack';

  @override
  String get taskIconBeach => 'Beach';

  @override
  String get taskIconBike => 'Bike';

  @override
  String get taskIconBoat => 'Boat';

  @override
  String get taskIconBus => 'Bus';

  @override
  String get taskIconCablecar => 'Cablecar';

  @override
  String get taskIconCar => 'Car';

  @override
  String get taskIconCase => 'Case';

  @override
  String get taskIconChineseCastle => 'Chinese Castle';

  @override
  String get taskIconColosseum => 'Colosseum';

  @override
  String get taskIconCompass => 'Compass';

  @override
  String get taskIconDeparture => 'Departure';

  @override
  String get taskIconDoubledeckerBus => 'Doubledecker Bus';

  @override
  String get taskIconElectricCar => 'Electric Car';

  @override
  String get taskIconEngine => 'Engine';

  @override
  String get taskIconFerry => 'Ferry';

  @override
  String get taskIconGasStation => 'Gas Station';

  @override
  String get taskIconGlobe => 'Globe';

  @override
  String get taskIconGlobeAmericas => 'Globe Americas';

  @override
  String get taskIconGlobeAsia => 'Globe Asia';

  @override
  String get taskIconGlobeAsiaPacific => 'Globe Asia-Pacific';

  @override
  String get taskIconGlobeEuropeAfrica => 'Globe Europe Africa';

  @override
  String get taskIconLeaving => 'Leaving';

  @override
  String get taskIconLifePreserver => 'Life Preserver';

  @override
  String get taskIconLightrail => 'Lightrail';

  @override
  String get taskIconLocation => 'Location';

  @override
  String get taskIconLodge => 'Lodge';

  @override
  String get taskIconMap => 'Map';

  @override
  String get taskIconMotorcycle => 'Motorcycle';

  @override
  String get taskIconOilCan => 'Oil Can';

  @override
  String get taskIconRoad => 'Road';

  @override
  String get taskIconRocket => 'Rocket';

  @override
  String get taskIconRollingSuitcase => 'Rolling Suitcase';

  @override
  String get taskIconScooter => 'Scooter';

  @override
  String get taskIconShip => 'Ship';

  @override
  String get taskIconSignpost => 'Signpost';

  @override
  String get taskIconSkiLift => 'Ski Lift';

  @override
  String get taskIconSteeringWheel => 'Steering Wheel';

  @override
  String get taskIconSubway => 'Subway';

  @override
  String get taskIconSuitcase => 'Suitcase';

  @override
  String get taskIconSuitcaseCart => 'Suitcase Cart';

  @override
  String get taskIconTent => 'Tent';

  @override
  String get taskIconTrain => 'Train';

  @override
  String get taskIconTruck => 'Truck';

  @override
  String get taskIconWindshield => 'Windshield';

  @override
  String get taskIconBarometer => 'Barometer';

  @override
  String get taskIconCloud => 'Cloud';

  @override
  String get taskIconDrizzle => 'Drizzle';

  @override
  String get taskIconFlame => 'Flame';

  @override
  String get taskIconFlower => 'Flower';

  @override
  String get taskIconFlowers => 'Flowers';

  @override
  String get taskIconFog => 'Fog';

  @override
  String get taskIconFossil => 'Fossil';

  @override
  String get taskIconHail => 'Hail';

  @override
  String get taskIconLeaf => 'Leaf';

  @override
  String get taskIconMoon => 'Moon';

  @override
  String get taskIconMoonHaze => 'Moon Haze';

  @override
  String get taskIconMountain => 'Mountain';

  @override
  String get taskIconMushroom => 'Mushroom';

  @override
  String get taskIconPalmTree => 'Palm Tree';

  @override
  String get taskIconPartialSun => 'Partial Sun';

  @override
  String get taskIconPlant => 'Plant';

  @override
  String get taskIconRain => 'Rain';

  @override
  String get taskIconRainbow => 'Rainbow';

  @override
  String get taskIconSeedling => 'Seedling';

  @override
  String get taskIconSleet => 'Sleet';

  @override
  String get taskIconSnow => 'Snow';

  @override
  String get taskIconSnowflake => 'Snowflake';

  @override
  String get taskIconSnowman => 'Snowman';

  @override
  String get taskIconStorm => 'Storm';

  @override
  String get taskIconSun => 'Sun';

  @override
  String get taskIconSunHaze => 'Sun Haze';

  @override
  String get taskIconSunrise => 'Sunrise';

  @override
  String get taskIconSunset => 'Sunset';

  @override
  String get taskIconTemperature => 'Temperature';

  @override
  String get taskIconThunderstorm => 'Thunderstorm';

  @override
  String get taskIconTree => 'Tree';

  @override
  String get taskIconUmbrella => 'Umbrella';

  @override
  String get taskIconWaves => 'Waves';

  @override
  String get taskIconWind => 'Wind';

  @override
  String get taskIconAnt => 'Ant';

  @override
  String get taskIconBird => 'Bird';

  @override
  String get taskIconBug => 'Bug';

  @override
  String get taskIconCat => 'Cat';

  @override
  String get taskIconChicken => 'Chicken';

  @override
  String get taskIconDog => 'Dog';

  @override
  String get taskIconFish => 'Fish';

  @override
  String get taskIconHamster => 'Hamster';

  @override
  String get taskIconHorse => 'Horse';

  @override
  String get taskIconMouse => 'Mouse';

  @override
  String get taskIconPet => 'Paw';

  @override
  String get taskIconPetFoodBowl => 'Pet Food Bowl';

  @override
  String get taskIconPig => 'Pig';

  @override
  String get taskIconRabbit => 'Rabbit';

  @override
  String get taskIconTortoise => 'Tortoise';

  @override
  String get taskIconWalkingCat => 'Walking Cat';

  @override
  String get taskIconWalkingDog => 'Walking Dog';

  @override
  String get taskIconBaby => 'Baby';

  @override
  String get taskIconBabyBottle => 'Baby Bottle';

  @override
  String get taskIconBallotBox => 'Ballot Box';

  @override
  String get taskIconBrokenHeart => 'Broken Heart';

  @override
  String get taskIconCouple => 'Couple';

  @override
  String get taskIconFamily => 'Family';

  @override
  String get taskIconPeople => 'Group';

  @override
  String get taskIconHand => 'Hand';

  @override
  String get taskIconHandshake => 'Handshake';

  @override
  String get taskIconMessage => 'Message';

  @override
  String get taskIconPerson => 'Person';

  @override
  String get taskIconSignLanguage => 'Sign Language';

  @override
  String get taskIconSmile => 'Smile';

  @override
  String get taskIconStroller => 'Stroller';

  @override
  String get taskIconTwoPersons => 'Two Persons';

  @override
  String get taskIconWaving => 'Waving';

  @override
  String get taskIconAmplifier => 'Amplifier';

  @override
  String get taskIconAperture => 'Aperture';

  @override
  String get taskIconBinoculars => 'Binoculars';

  @override
  String get taskIconCamera => 'Camera';

  @override
  String get taskIconCheckerboard => 'Checkerboard';

  @override
  String get taskIconChess => 'Chess';

  @override
  String get taskIconClub => 'Club';

  @override
  String get taskIconDice => 'Dice';

  @override
  String get taskIconDrums => 'Drums';

  @override
  String get taskIconEyedropper => 'Eyedropper';

  @override
  String get taskIconFilm => 'Film';

  @override
  String get taskIconFishing => 'Fishing';

  @override
  String get taskIconGaming => 'Gaming';

  @override
  String get taskIconGuitar => 'Guitar';

  @override
  String get taskIconHorn => 'Horn';

  @override
  String get taskIconHunting => 'Hunting';

  @override
  String get taskIconMagazine => 'Magazine';

  @override
  String get taskIconMagic => 'Magic';

  @override
  String get taskIconMetronome => 'Metronome';

  @override
  String get taskIconMovie => 'Movie';

  @override
  String get taskIconMovieClapper => 'Movie Clapper';

  @override
  String get taskIconMusic => 'Music';

  @override
  String get taskIconNewspaper => 'Newspaper';

  @override
  String get taskIconPaintPalette => 'Paint Palette';

  @override
  String get taskIconPaintbrush => 'Paintbrush';

  @override
  String get taskIconPhoto => 'Photo';

  @override
  String get taskIconPiano => 'Piano';

  @override
  String get taskIconPlayground => 'Playground';

  @override
  String get taskIconPuzzle => 'Puzzle';

  @override
  String get taskIconRadio => 'Radio';

  @override
  String get taskIconRecordingTape => 'Recording Tape';

  @override
  String get taskIconSewingMachine => 'Sewing Machine';

  @override
  String get taskIconSinging => 'Singing';

  @override
  String get taskIconSpade => 'Spade';

  @override
  String get taskIconSwatchPalette => 'Swatch Palette';

  @override
  String get taskIconTheater => 'Theater';

  @override
  String get taskIconTicket => 'Ticket';

  @override
  String get taskIconTuning => 'Tuning';

  @override
  String get taskIconTv => 'TV';

  @override
  String get taskIconBag => 'Bag';

  @override
  String get taskIconBanknote => 'Banknote';

  @override
  String get taskIconBarcode => 'Barcode';

  @override
  String get taskIconBasket => 'Basket';

  @override
  String get taskIconBitcoin => 'Bitcoin';

  @override
  String get taskIconCart => 'Cart';

  @override
  String get taskIconCoin => 'Coin';

  @override
  String get taskIconCreditcard => 'Creditcard';

  @override
  String get taskIconEuro => 'Euro';

  @override
  String get taskIconGift => 'Gift';

  @override
  String get taskIconGiftcard => 'Giftcard';

  @override
  String get taskIconMoney => 'Money';

  @override
  String get taskIconParcel => 'Parcel';

  @override
  String get taskIconStorefront => 'Storefront';

  @override
  String get taskIconTag => 'Tag';

  @override
  String get taskIconWalletPass => 'Wallet Pass';

  @override
  String get taskIconClothesHanger => 'Clothes Hanger';

  @override
  String get taskIconDiamond => 'Diamond';

  @override
  String get taskIconDress => 'Dress';

  @override
  String get taskIconGlasses => 'Glasses';

  @override
  String get taskIconHairDresser => 'Hair Dresser';

  @override
  String get taskIconHairdryer => 'Hairdryer';

  @override
  String get taskIconHat => 'Hat';

  @override
  String get taskIconJacket => 'Jacket';

  @override
  String get taskIconMustache => 'Mustache';

  @override
  String get taskIconPurse => 'Purse';

  @override
  String get taskIconRazor => 'Razor';

  @override
  String get taskIconRing => 'Ring';

  @override
  String get taskIconShoe => 'Shoe';

  @override
  String get taskIconShoes => 'Shoes';

  @override
  String get taskIconSkinCare => 'Skin Care';

  @override
  String get taskIconSunglasses => 'Sunglasses';

  @override
  String get taskIconTShirt => 'T-Shirt';

  @override
  String get taskIconTrousers => 'Trousers';

  @override
  String get taskIconWinterJacket => 'Winter Jacket';

  @override
  String get taskIconBalloons => 'Balloons';

  @override
  String get taskIconBirthday => 'Birthday';

  @override
  String get taskIconBuddhism => 'Buddhism';

  @override
  String get taskIconCandle => 'Candle';

  @override
  String get taskIconChristmasTree => 'Christmas Tree';

  @override
  String get taskIconChurch => 'Church';

  @override
  String get taskIconCross => 'Cross';

  @override
  String get taskIconFireworks => 'Fireworks';

  @override
  String get taskIconGhost => 'Ghost';

  @override
  String get taskIconGravestone => 'Gravestone';

  @override
  String get taskIconHalloween => 'Halloween';

  @override
  String get taskIconHinduism => 'Hinduism';

  @override
  String get taskIconIslam => 'Islam';

  @override
  String get taskIconJudaism => 'Judaism';

  @override
  String get taskIconMosque => 'Mosque';

  @override
  String get taskIconParty => 'Party';

  @override
  String get taskIconPray => 'Pray';

  @override
  String get taskIconTaoism => 'Taoism';

  @override
  String get taskIconAlarm => 'Alarm';

  @override
  String get taskIconBarChart => 'Bar Chart';

  @override
  String get taskIconBell => 'Bell';

  @override
  String get taskIconBolt => 'Bolt';

  @override
  String get taskIconBubble => 'Bubble';

  @override
  String get taskIconBubbles => 'Bubbles';

  @override
  String get taskIconClock => 'Clock';

  @override
  String get taskIconCrown => 'Crown';

  @override
  String get taskIconCube => 'Cube';

  @override
  String get taskIconDanger => 'Danger';

  @override
  String get taskIconError => 'Error';

  @override
  String get taskIconExplosion => 'Explosion';

  @override
  String get taskIconFemaleSymbol => 'Female Symbol';

  @override
  String get taskIconFilters => 'Filters';

  @override
  String get taskIconFlag => 'Flag';

  @override
  String get taskIconHashtag => 'Hashtag';

  @override
  String get taskIconHazardSign => 'Hazard Sign';

  @override
  String get taskIconHourglass => 'Hourglass';

  @override
  String get taskIconLineChart => 'Line Chart';

  @override
  String get taskIconLineChartDown => 'Line Chart Down';

  @override
  String get taskIconLineChartUp => 'Line Chart Up';

  @override
  String get taskIconLocked => 'Locked';

  @override
  String get taskIconMaleSymbol => 'Male Symbol';

  @override
  String get taskIconMegaphone => 'Megaphone';

  @override
  String get taskIconMenu => 'Menu';

  @override
  String get taskIconMinus => 'Minus';

  @override
  String get taskIconNonBinarySymbol => 'Non-Binary Symbol';

  @override
  String get taskIconPeace => 'Peace';

  @override
  String get taskIconPieChart => 'Pie Chart';

  @override
  String get taskIconPin => 'Pin';

  @override
  String get taskIconPlus => 'Plus';

  @override
  String get taskIconQrCode => 'QR Code';

  @override
  String get taskIconQuestion => 'Question';

  @override
  String get taskIconSearch => 'Search';

  @override
  String get taskIconShield => 'Shield';

  @override
  String get taskIconSkull => 'Skull';

  @override
  String get taskIconSpeed => 'Speed';

  @override
  String get taskIconStar => 'Star';

  @override
  String get taskIconTarget => 'Target';

  @override
  String get taskIconThumbsDown => 'Thumbs Down';

  @override
  String get taskIconThumbsUp => 'Thumbs Up';

  @override
  String get taskIconTimer => 'Timer';

  @override
  String get taskIconTransgenderSymbol => 'Transgender Symbol';

  @override
  String get taskIconTransparentCube => 'Transparent Cube';

  @override
  String get taskIconUnlock => 'Unlock';

  @override
  String get taskIconWarning => 'Warning';

  @override
  String get taskIconWrongWaySign => 'Wrong Way Sign';

  @override
  String get taskIconCircle => 'Plain';
}
