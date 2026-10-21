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
  String get colorPickerLabel => 'Colour';

  @override
  String get iconPickerLabel => 'Icon';

  @override
  String get colorCoral => 'Coral';

  @override
  String get colorTangerine => 'Tangerine';

  @override
  String get colorAmber => 'Amber';

  @override
  String get colorLime => 'Lime';

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
  String get colorMagenta => 'Magenta';

  @override
  String get colorRose => 'Rose';

  @override
  String get colorSlate => 'Slate';

  @override
  String get iconCircle => 'Plain';

  @override
  String get iconWork => 'Work';

  @override
  String get iconMeeting => 'Meeting';

  @override
  String get iconCall => 'Call';

  @override
  String get iconMail => 'Email';

  @override
  String get iconCode => 'Code';

  @override
  String get iconStudy => 'Study';

  @override
  String get iconBook => 'Reading';

  @override
  String get iconGym => 'Gym';

  @override
  String get iconRun => 'Run';

  @override
  String get iconWalk => 'Walk';

  @override
  String get iconBike => 'Bike';

  @override
  String get iconMeal => 'Meal';

  @override
  String get iconCoffee => 'Coffee';

  @override
  String get iconSleep => 'Sleep';

  @override
  String get iconMedication => 'Medication';

  @override
  String get iconHeart => 'Health';

  @override
  String get iconHome => 'Home';

  @override
  String get iconClean => 'Cleaning';

  @override
  String get iconShopping => 'Shopping';

  @override
  String get iconCommute => 'Commute';

  @override
  String get iconFlight => 'Travel';

  @override
  String get iconMusic => 'Music';

  @override
  String get iconPet => 'Pet';

  @override
  String get iconStar => 'Star';

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
}
