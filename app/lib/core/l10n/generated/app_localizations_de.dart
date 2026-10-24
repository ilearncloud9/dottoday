// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Dottoday';

  @override
  String get failureStorage =>
      'Konnte auf diesem Gerät nicht speichern. Versuch es noch mal.';

  @override
  String get failureNetworkOffline =>
      'Du bist offline. Änderungen werden auf diesem Gerät gespeichert und später synchronisiert.';

  @override
  String get failureNetworkTimeout =>
      'Der Server hat zu lange gebraucht. Versuch es noch mal.';

  @override
  String get failureNetworkServer =>
      'Der Server hatte ein Problem. Deine Daten sind auf diesem Gerät sicher.';

  @override
  String get failureAuth =>
      'Deine Sitzung ist abgelaufen. Melde dich erneut an, um weiter zu synchronisieren.';

  @override
  String get failureValidationRequired => 'Das darf nicht leer sein.';

  @override
  String get failureValidationTooLong => 'Das ist zu lang. Versuch es kürzer.';

  @override
  String get failureValidationOutOfRange =>
      'Dieser Wert liegt außerhalb des erlaubten Bereichs.';

  @override
  String get failureValidationInvalidFormat =>
      'Das sieht nicht richtig aus. Prüf das Format.';

  @override
  String get failureValidationTooLarge => 'Diese Datei ist zu groß.';

  @override
  String get failureNotFound => 'Dieses Element gibt es nicht mehr.';

  @override
  String get failureConflict =>
      'Dieses Element wurde auf einem anderen Gerät geändert. Wähle, welche Version du behalten möchtest.';

  @override
  String get failurePermissionNotifications =>
      'Mitteilungen für Dottoday sind aus. Du kannst sie in den Systemeinstellungen einschalten.';

  @override
  String get failurePermissionCalendar =>
      'Dottoday kann deine Kalender nicht sehen. Du kannst den Zugriff in den Systemeinstellungen erlauben.';

  @override
  String get failureUndoExpired =>
      'Das lässt sich nicht mehr rückgängig machen. Gelöschte Aufgaben bleiben 30 Tage im Papierkorb.';

  @override
  String get failureUnexpected =>
      'Etwas ist schiefgelaufen. Versuch es noch mal.';

  @override
  String get navToday => 'Heute';

  @override
  String get navInbox => 'Eingang';

  @override
  String get navWeek => 'Woche';

  @override
  String get navSearch => 'Suche';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get quickAddTooltip => 'Aufgabe hinzufügen';

  @override
  String get sheetClose => 'Schließen';

  @override
  String get timeInputLabel => 'Uhrzeit';

  @override
  String get timeInputHint => 'z. B. 9:30 oder 14 Uhr';

  @override
  String get timeInputInvalid => 'Gib eine Uhrzeit wie 9:30 oder 14 Uhr ein';

  @override
  String get timeInputWheel => 'Uhrzeit mit Rad wählen';

  @override
  String get timeInputDone => 'Fertig';

  @override
  String get durationLabel => 'Dauer';

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
  String get durationCustom => 'Eigene';

  @override
  String get durationCustomHint => 'z. B. 40 min oder 1h30';

  @override
  String get durationCustomInvalid => '5 min bis 24 h, z. B. 40 min oder 1h30';

  @override
  String get colorCoral => 'Koralle';

  @override
  String get colorAmber => 'Bernstein';

  @override
  String get colorMint => 'Mint';

  @override
  String get colorTeal => 'Petrol';

  @override
  String get colorSky => 'Himmelblau';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorViolet => 'Violett';

  @override
  String get colorRose => 'Rosé';

  @override
  String get colorSlate => 'Schiefer';

  @override
  String get iconCircle => 'Schlicht';

  @override
  String get iconCall => 'Anruf';

  @override
  String get iconMail => 'E-Mail';

  @override
  String get iconCode => 'Code';

  @override
  String get iconBook => 'Lesen';

  @override
  String get iconGym => 'Fitness';

  @override
  String get iconRun => 'Laufen';

  @override
  String get iconMeal => 'Essen';

  @override
  String get iconHeart => 'Gesundheit';

  @override
  String get iconHome => 'Zuhause';

  @override
  String get iconMusic => 'Musik';

  @override
  String get iconPet => 'Haustier';

  @override
  String get iconStar => 'Stern';

  @override
  String get iconList => 'Liste';

  @override
  String get iconLanguage => 'Sprache';

  @override
  String get iconTravel => 'Reisen';

  @override
  String get iconCart => 'Einkaufswagen';

  @override
  String get iconTv => 'TV';

  @override
  String get iconBag => 'Einkaufstasche';

  @override
  String get iconMeds => 'Medikamente';

  @override
  String get iconWater => 'Wasser';

  @override
  String get iconCar => 'Auto';

  @override
  String get iconMoney => 'Geld';

  @override
  String get iconGift => 'Geschenk';

  @override
  String get iconCamera => 'Kamera';

  @override
  String get iconPeople => 'Personen';

  @override
  String get iconDocument => 'Dokument';

  @override
  String get undoAction => 'Rückgängig';

  @override
  String get syncLocalOnly => 'Auf diesem Gerät';

  @override
  String get syncSynced => 'Synchronisiert';

  @override
  String get syncSyncing => 'Synchronisiert …';

  @override
  String get syncOffline => 'Offline';

  @override
  String get syncError => 'Sync-Problem';

  @override
  String timelineNow(String time) {
    return 'Jetzt, $time';
  }

  @override
  String timelineBeforeHours(String time) {
    return 'Vor $time';
  }

  @override
  String timelineAfterHours(String time) {
    return 'Nach $time';
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
      other: '$count weitere Blöcke',
      one: '1 weiterer Block',
    );
    return '$_temp0';
  }

  @override
  String get timelineAllDay => 'Ganztägig';

  @override
  String blockTimeRange(String start, String end) {
    return '$start–$end';
  }

  @override
  String blockSemantics(String title, String start, String end) {
    return '$title, $start bis $end';
  }

  @override
  String get timelineMenu => 'Weitere Optionen';

  @override
  String get debugLoadDemoDay => 'Demo-Tag laden (Debug)';

  @override
  String get debugDemoDayLoaded => 'Demo-Tag geladen';

  @override
  String get semanticsSeparator => ', ';

  @override
  String get blockDone => 'erledigt';

  @override
  String get blockNotDoneYet => 'noch nicht erledigt';

  @override
  String blockSubtasks(int done, int total) {
    return '$done von $total Unteraufgaben erledigt';
  }

  @override
  String blockSubtasksShort(int done, int total) {
    return '$done/$total';
  }

  @override
  String get blockRecurring => 'wiederkehrend';

  @override
  String get blockPinned => 'angeheftet';

  @override
  String get blockFromCalendar => 'aus deinem Kalender';

  @override
  String blockAlerts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Hinweise',
      one: '1 Hinweis',
    );
    return '$_temp0';
  }

  @override
  String get blockStartsBefore => 'geht vom Vortag weiter';

  @override
  String get blockEndsAfter => 'geht in den nächsten Tag weiter';

  @override
  String blockMarkDone(String title) {
    return '$title als erledigt markieren';
  }

  @override
  String blockMarkNotDone(String title) {
    return '$title als nicht erledigt markieren';
  }

  @override
  String get undoMarkedDone => 'Als erledigt markiert';

  @override
  String get undoMarkedNotDone => 'Als nicht erledigt markiert';

  @override
  String dotUpcoming(String title) {
    return '$title, anstehend';
  }

  @override
  String dotLive(String title) {
    return '$title, läuft';
  }

  @override
  String dotLiveLeft(String title, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'noch $minutes Minuten',
      one: 'noch 1 Minute',
    );
    return '$title, läuft, $_temp0';
  }

  @override
  String dotDone(String title) {
    return '$title, erledigt';
  }

  @override
  String dotSkipped(String title) {
    return '$title, übersprungen';
  }

  @override
  String dotMissed(String title) {
    return '$title, nicht erledigt';
  }

  @override
  String get dotMarkDoneHint => 'Als erledigt markieren';

  @override
  String get dotMarkNotDoneHint => 'Als nicht erledigt markieren';

  @override
  String rowLabel(String title, String range) {
    return '$title, $range';
  }

  @override
  String rowMissed(String label) {
    return '$label, nicht erledigt';
  }

  @override
  String rowPinned(String label) {
    return '$label, angeheftet';
  }

  @override
  String rowRepeats(String label) {
    return '$label, wiederholt sich';
  }

  @override
  String get rowMissedMeta => '· nicht erledigt';

  @override
  String threadWake(String time) {
    return 'Aufstehen · $time';
  }

  @override
  String threadBed(String time) {
    return 'Schlafenszeit · $time';
  }

  @override
  String threadFree(String duration) {
    return '$duration frei';
  }

  @override
  String threadAddHere(String duration) {
    return '$duration frei · hier hinzufügen';
  }

  @override
  String threadAddHereLabel(String duration, String time) {
    return '$duration frei ab $time. Hier eine Aufgabe hinzufügen';
  }

  @override
  String liveSubtasks(int done, int total) {
    return '$done von $total';
  }

  @override
  String liveMinutesLeft(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'noch $minutes min',
      one: 'noch 1 min',
    );
    return '$_temp0';
  }

  @override
  String get liveDone => 'Erledigt';

  @override
  String get liveExtend => '+15 min';

  @override
  String get liveShiftRest => 'Rest verschieben';

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
    return 'Tag zu $percent % vorbei';
  }

  @override
  String get weekStripShowMonth => 'Monat anzeigen';

  @override
  String get weekStripHideMonth => 'Monat ausblenden';

  @override
  String get dayCardTodaySuffix => ' · Heute';

  @override
  String dayCardSummary(int done, int total, String planned) {
    return '$done von $total · $planned geplant';
  }

  @override
  String dayCardNothing(String free) {
    return 'Nichts geplant · $free frei';
  }

  @override
  String dayPagerPosition(int position, int count) {
    return 'Tag $position von $count';
  }

  @override
  String monthMore(int count) {
    return '+$count weitere';
  }

  @override
  String monthDoneOf(int done, int total) {
    return '$done von $total erledigt';
  }

  @override
  String get monthLightDay => 'Ruhiger Tag';

  @override
  String monthMissedItem(String title) {
    return '$title · nicht erledigt';
  }

  @override
  String monthNowItem(String title) {
    return '$title · jetzt';
  }

  @override
  String threadTimeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get debugConceptPreview => 'Konzept-A-Vorschau (Debug)';

  @override
  String todayGreeting(String part) {
    String _temp0 = intl.Intl.selectLogic(part, {
      'morning': 'Guten Morgen',
      'afternoon': 'Guten Tag',
      'other': 'Guten Abend',
    });
    return '$_temp0';
  }

  @override
  String todayGreetingName(String part, String name) {
    String _temp0 = intl.Intl.selectLogic(part, {
      'morning': 'Guten Morgen, $name',
      'afternoon': 'Guten Tag, $name',
      'other': 'Guten Abend, $name',
    });
    return '$_temp0';
  }

  @override
  String get todayEmpty =>
      'Nichts geplant · zieh die Leiste zum Planen oder tippe auf +';

  @override
  String get todayAllDay => 'Ganztägig';

  @override
  String stripDayLabel(String day, int done, int total) {
    return '$day, $done von $total erledigt';
  }

  @override
  String monthFooterPlanned(String month, int count, int days) {
    return '$month · $count von $days Tagen geplant';
  }

  @override
  String monthDaysPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage geplant',
      one: '1 Tag geplant',
    );
    return '$_temp0';
  }

  @override
  String get monthLegendPlanned => 'geplant';

  @override
  String get monthLegendRepeats => 'wiederholt sich';

  @override
  String monthNav(String previous, String current, String next) {
    return '$previous · $current · $next';
  }

  @override
  String get monthPrevious => 'Vorheriger Monat';

  @override
  String get monthNext => 'Nächster Monat';

  @override
  String get todayPill => 'Heute';

  @override
  String monthCellLabel(String day, int done, int total) {
    return '$day, $done von $total erledigt';
  }

  @override
  String get emptyAddToDay => 'Zu diesem Tag hinzufügen';

  @override
  String emptyPullInbox(int count) {
    return 'Aus dem Eingang holen · $count';
  }

  @override
  String get emptyCopyDay => 'Tag kopieren …';

  @override
  String get copyDayTitle => 'Welchen Tag kopieren?';

  @override
  String copyDayDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben kopiert',
      one: '1 Aufgabe kopiert',
    );
    return '$_temp0';
  }

  @override
  String get copyDayNothing => 'An diesem Tag gibt es nichts zu kopieren';

  @override
  String snackDone(String title) {
    return '$title erledigt';
  }

  @override
  String snackNotDone(String title) {
    return '$title nicht erledigt';
  }

  @override
  String snackExtended(String title, String time) {
    return '$title endet jetzt um $time';
  }

  @override
  String snackShifted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben verschoben',
      one: '1 Aufgabe verschoben',
    );
    return '$_temp0';
  }

  @override
  String snackShiftedPartial(int count, String pin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben verschoben · gestoppt bei $pin (angeheftet)',
      one: '1 Aufgabe verschoben · gestoppt bei $pin (angeheftet)',
      zero: 'Nichts verschoben: $pin ist angeheftet',
    );
    return '$_temp0';
  }

  @override
  String sheetMetaDay(String day, String range, String duration) {
    return '$day · $range · $duration';
  }

  @override
  String get sheetToday => 'Heute';

  @override
  String get sheetTomorrow => 'Morgen';

  @override
  String get sheetInbox => 'Eingang';

  @override
  String get sheetDone => 'Erledigt';

  @override
  String get sheetUndone => 'Nicht erledigt';

  @override
  String get sheetExtend => '+15 min';

  @override
  String get sheetShift => 'Verschieben';

  @override
  String get sheetMove => 'Verlegen';

  @override
  String get sheetEdit => 'Bearbeiten';

  @override
  String sheetSubtasks(int done, int total) {
    return 'Unteraufgaben · $done von $total';
  }

  @override
  String get sheetSubtasksNone => 'Unteraufgaben';

  @override
  String get sheetAddSubtask => '+ Neu';

  @override
  String get sheetNewSubtask => 'Neue Unteraufgabe';

  @override
  String get sheetAlerts => 'Hinweise';

  @override
  String get sheetRepeat => 'Wiederholen';

  @override
  String get sheetLook => 'Farbe und Symbol';

  @override
  String get sheetNever => 'Nie';

  @override
  String get sheetNoAlerts => 'Keine';

  @override
  String get sheetNotFound => 'Diese Aufgabe ist nicht mehr da';

  @override
  String get alertAtStart => 'zu Beginn';

  @override
  String get alertAtEnd => 'am Ende';

  @override
  String alertBefore(int minutes) {
    return '$minutes min vorher';
  }

  @override
  String alertOverdue(int minutes) {
    return '$minutes min nach Ende';
  }

  @override
  String alertJoin(String first, String rest) {
    return '$first · $rest';
  }

  @override
  String get repeatDaily => 'Täglich';

  @override
  String get repeatWeekdays => 'Werktags';

  @override
  String repeatWeekly(String days) {
    return 'Wöchentlich am $days';
  }

  @override
  String get repeatMonthly => 'Monatlich';

  @override
  String get repeatYearly => 'Jährlich';

  @override
  String get repeatCustom => 'Eigene';

  @override
  String listJoin(String first, String rest) {
    return '$first, $rest';
  }

  @override
  String sheetLeftSuffix(String left) {
    return ' · $left';
  }

  @override
  String get colourIconCaption => 'Farbe und Symbol';

  @override
  String get colourIconMore => 'Alle Symbole';

  @override
  String get editorCaption => 'Aufgabe bearbeiten';

  @override
  String get editorTitleHint => 'Was steht an?';

  @override
  String get editorWhen => 'Wann';

  @override
  String get editorStart => 'Beginn';

  @override
  String editorEndsAt(String time) {
    return '→ $time';
  }

  @override
  String get editorDuration => 'Dauer';

  @override
  String get editorNotes => 'Notizen';

  @override
  String get editorNotesHint => 'Notizen hinzufügen';

  @override
  String get editorSave => 'Speichern';

  @override
  String get editorMoveToInbox => 'In den Eingang';

  @override
  String get editorDelete => 'Aufgabe löschen';

  @override
  String editorDeleteConfirm(String title) {
    return '“$title” löschen?';
  }

  @override
  String get editorDeleteBody =>
      'Sie kommt für 30 Tage in den Papierkorb. Du kannst es direkt danach rückgängig machen.';

  @override
  String get editorCancel => 'Abbrechen';

  @override
  String snackDeleted(String title) {
    return '$title gelöscht';
  }

  @override
  String snackMovedToInbox(String title) {
    return '$title in den Eingang verschoben';
  }

  @override
  String get editorPickDay => 'Tag wählen';

  @override
  String resizeLabel(String title) {
    return 'Dauer von $title ändern';
  }

  @override
  String dragDropAt(String time) {
    return '→ $time';
  }

  @override
  String snackMoved(String title, String time) {
    return '$title auf $time verschoben';
  }

  @override
  String snackMovedDay(String title, String day) {
    return '$title auf $day verschoben';
  }

  @override
  String snackResized(String title, String time) {
    return '$title endet jetzt um $time';
  }

  @override
  String get shiftChipLabel => 'Spätere mitverschieben';

  @override
  String get shiftChipCalendar => 'Auch Kalendertermine';

  @override
  String snackMovedShifted(String title, String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$title auf $time verschoben · $count spätere Aufgaben mitverschoben',
      one: '$title auf $time verschoben · 1 spätere Aufgabe mitverschoben',
      zero: '$title auf $time verschoben',
    );
    return '$_temp0';
  }

  @override
  String snackMovedShiftedPartial(String title, String time, String pin) {
    return '$title auf $time verschoben · gestoppt bei $pin (angeheftet)';
  }

  @override
  String get selectAction => 'Auswählen';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählt',
      one: '1 ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get selectionClose => 'Auswahl beenden';

  @override
  String get selectionMove => 'Verschieben';

  @override
  String get selectionMoveTitle => 'Verschieben nach';

  @override
  String get selectionDuplicate => 'Duplizieren';

  @override
  String get selectionColour => 'Farbe';

  @override
  String get selectionDelete => 'Löschen';

  @override
  String selectionDeleteConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben löschen?',
      one: '1 Aufgabe löschen?',
    );
    return '$_temp0';
  }

  @override
  String snackManyMoved(int count, String day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben auf $day verschoben',
      one: '1 Aufgabe auf $day verschoben',
    );
    return '$_temp0';
  }

  @override
  String snackManyDuplicated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben dupliziert',
      one: '1 Aufgabe dupliziert',
    );
    return '$_temp0';
  }

  @override
  String snackManyRecoloured(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Farbe von $count Aufgaben geändert',
      one: 'Farbe von 1 Aufgabe geändert',
    );
    return '$_temp0';
  }

  @override
  String snackManyDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben in den Papierkorb verschoben',
      one: '1 Aufgabe in den Papierkorb verschoben',
    );
    return '$_temp0';
  }

  @override
  String get inboxSchedule => 'Einplanen';

  @override
  String get inboxTrash => 'In den Papierkorb';

  @override
  String inboxRowLabel(String title, String length) {
    return '$title, $length';
  }

  @override
  String inboxSummary(int count, String work) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nicht eingeplant',
      one: '1 nicht eingeplant',
    );
    return '$_temp0 · $work Arbeit';
  }

  @override
  String inboxRingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben im Eingang',
      one: '1 Aufgabe im Eingang',
      zero: 'Eingang leer',
    );
    return '$_temp0';
  }

  @override
  String get inboxAddHint => 'Mama morgen 15 Uhr anrufen 20 min';

  @override
  String get inboxAddLabel => 'Aufgabe hinzufügen';

  @override
  String get inboxFilterAll => 'Alle';

  @override
  String get inboxFilterUnder30 => 'Unter 30 min';

  @override
  String get inboxFilterFits => 'Passt heute';

  @override
  String inboxNextSlot(String range, String title) {
    return 'Nächste freie Zeit heute: $range · passt für $title';
  }

  @override
  String get inboxPlace => 'Einsetzen';

  @override
  String inboxCompleted(int count) {
    return 'Erledigt · $count';
  }

  @override
  String get inboxEmpty => 'Eingang ist leer';

  @override
  String get inboxNoMatch => 'Nichts passt zu diesem Filter';

  @override
  String get inboxUntitled => 'Neue Aufgabe';

  @override
  String inboxScheduleTitle(String title) {
    return '$title einplanen';
  }

  @override
  String inboxScheduleToday(String range) {
    return 'Heute, $range';
  }

  @override
  String inboxScheduleTomorrow(String range) {
    return 'Morgen, $range';
  }

  @override
  String get inboxScheduleNone =>
      'Heute und morgen ist keine Zeit frei. Schaff Platz unter Heute oder zieh die Aufgabe aus der Woche hinein.';

  @override
  String snackScheduled(String title, String when) {
    return '$title eingeplant für $when';
  }

  @override
  String snackAddedInbox(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben hinzugefügt',
      one: '$title zum Eingang hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String snackAddedTimed(String title, String when) {
    return '$title hinzugefügt für $when';
  }

  @override
  String snackTrashed(String title) {
    return '$title in den Papierkorb verschoben';
  }

  @override
  String get addTitleLabel => 'Titel';

  @override
  String get addTypeTimeHint =>
      'Gib auch eine Zeit ein: ‘Einkaufen 17 Uhr 1 h’';

  @override
  String addRemoveToken(String token) {
    return '“$token” entfernen';
  }

  @override
  String get addSuggestions => 'Vorschläge';

  @override
  String get addFromHabits => 'aus deinen Gewohnheiten';

  @override
  String addHabitUsual(String range, String length) {
    return 'meist $range · $length';
  }

  @override
  String addHabitNoTime(String length) {
    return 'keine feste Zeit · $length';
  }

  @override
  String addHabitLabel(String title, String meta) {
    return '$title, $meta';
  }

  @override
  String get addContinue => 'Weiter';

  @override
  String get addToInbox => 'Lieber in den Eingang';

  @override
  String addStepOf(int step, int total) {
    return 'Schritt $step von $total';
  }

  @override
  String get addBack => 'Zurück';

  @override
  String addWhenOnDay(String day, String time) {
    return '$day, $time';
  }

  @override
  String get pickerLabel => 'Beginn';

  @override
  String addWhenSummary(String day, String range, String length) {
    return '$day · $range · $length';
  }

  @override
  String get addTimeCaption => 'Uhrzeit';

  @override
  String get addDurationCaption => 'Dauer';

  @override
  String addFreeUntil(String time) {
    return 'Frei bis $time · keine Überschneidung';
  }

  @override
  String addOverlaps(int count, String title, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Überschneidet sich mit $title und $others weiteren',
      one: 'Überschneidet sich mit $title',
    );
    return '$_temp0 · du kannst sie trotzdem hinzufügen';
  }

  @override
  String addLandsOn(String day, String range) {
    return 'Landet am $day um $range';
  }

  @override
  String get addSlotFree => 'die Zeit ist frei';

  @override
  String addSlotBusy(String title) {
    return 'überschneidet sich mit $title';
  }

  @override
  String get addAdd => 'Hinzufügen';

  @override
  String get addAnother => 'Noch eine';

  @override
  String durationChipMinutes(int minutes) {
    return '$minutes';
  }

  @override
  String durationChipHours(String hours) {
    return '$hours h';
  }

  @override
  String get inboxPickTime => 'Zeit wählen …';

  @override
  String get durationSheetTitle => 'Dauer';

  @override
  String get durationTypeLabel => 'Oder Dauer eingeben';

  @override
  String durationEnds(String time) {
    return 'endet $time';
  }

  @override
  String durationFitsBefore(String title, String time) {
    return 'Passt noch vor $title um $time';
  }

  @override
  String durationFitsBedtime(String time) {
    return 'Passt vor die Schlafenszeit um $time';
  }

  @override
  String durationRunsInto(String title, String time) {
    return 'Reicht in $title um $time';
  }

  @override
  String durationPastBedtime(String time) {
    return 'Reicht über die Schlafenszeit um $time';
  }

  @override
  String get durationPresets => 'Vorlagen';

  @override
  String get durationReset => 'Zurücksetzen';

  @override
  String get durationAddPreset => 'Vorlage';

  @override
  String get durationAddPresetLabel => 'Diese Dauer als Vorlage behalten';

  @override
  String durationRemovePreset(String length) {
    return 'Vorlage $length entfernen';
  }

  @override
  String durationPresetMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationPresetHours(int hours) {
    return '$hours h';
  }

  @override
  String durationPresetHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get addMoreTime => 'Weitere Zeitoptionen';

  @override
  String get addMoreDuration => 'Weitere Dauern';

  @override
  String get timeMenuChangeDay => 'Tag ändern';

  @override
  String get timeMenuPickWeek => 'Aus der Woche wählen';

  @override
  String get timeMenuAllDay => 'Ganztägig machen';

  @override
  String get timeMenuTimed => 'Uhrzeit festlegen';

  @override
  String get timeMenuInbox => 'In den Eingang';

  @override
  String get timeMenuZone => 'Zeitzone';

  @override
  String get timeMenuType => 'Uhrzeit eingeben';

  @override
  String get zoneSearch => 'Stadt oder Zone suchen';

  @override
  String get weekPrevious => 'Vorherige Woche';

  @override
  String get weekNext => 'Nächste Woche';

  @override
  String get addAllDay => 'Ganztägig';

  @override
  String get addLandsOnEdit => 'Ändern';

  @override
  String addLandsOnAllDay(String day) {
    return 'Landet am $day · ganztägig';
  }

  @override
  String pasteAsk(int count) {
    return '$count Aufgaben hinzufügen?';
  }

  @override
  String pasteAdd(int count) {
    return '$count hinzufügen';
  }

  @override
  String get pasteKeep => 'Als eine behalten';

  @override
  String get searchSubtitle => 'Alles, was du geplant hast';

  @override
  String get searchFieldLabel => 'Titel, Notizen und Unteraufgaben durchsuchen';

  @override
  String get searchClear => 'Suche löschen';

  @override
  String searchRingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ergebnisse',
      one: '1 Ergebnis',
      zero: 'Keine Ergebnisse',
    );
    return '$_temp0';
  }

  @override
  String get searchFilterAll => 'Alle';

  @override
  String get searchFilterToday => 'Heute';

  @override
  String get searchFilterWeek => 'Diese Woche';

  @override
  String get searchFilterInbox => 'Eingang';

  @override
  String get searchFilterDone => 'Erledigt';

  @override
  String get searchFilterColour => 'Farbe';

  @override
  String get searchFilterIcon => 'Symbol';

  @override
  String get searchPickColour => 'Eine Farbe zeigen';

  @override
  String get searchPickIcon => 'Ein Symbol zeigen';

  @override
  String searchGroupToday(String weekday) {
    return '$weekday · Heute';
  }

  @override
  String get searchGroupInbox => 'Eingang';

  @override
  String searchMetaDay(String day, String range) {
    return '$day · $range';
  }

  @override
  String searchMetaDone(String when) {
    return '$when · Erledigt';
  }

  @override
  String searchMetaMissed(String when) {
    return '$when · nicht erledigt';
  }

  @override
  String searchMetaInbox(String length) {
    return 'Eingang · $length';
  }

  @override
  String searchRowLabel(String title, String meta) {
    return '$title, $meta';
  }

  @override
  String get searchRecent => 'Zuletzt';

  @override
  String searchRecentLabel(String query) {
    return 'Erneut nach $query suchen';
  }

  @override
  String get searchEmpty =>
      'Finde alles, was du geplant hast: Titel, Notizen und Unteraufgaben, auch erledigte.';

  @override
  String searchNoResults(String query) {
    return 'Keine Treffer für “$query”';
  }

  @override
  String get searchNoResultsHint =>
      'Versuch weniger Wörter oder einen anderen Filter.';

  @override
  String get searchShowAll => 'Alle zeigen';

  @override
  String searchDayLabel(String weekday, String date) {
    return '$weekday $date';
  }

  @override
  String settingsLocalOnly(String name) {
    return '$name · auf diesem Gerät';
  }

  @override
  String get settingsLocalOnlyNoName => 'Auf diesem Gerät';

  @override
  String settingsAvatarLabel(String name) {
    return 'Konto: $name';
  }

  @override
  String get settingsDayShape => 'Tagesform';

  @override
  String settingsAwake(String length) {
    return '$length wach';
  }

  @override
  String get settingsWakeUp => 'Aufstehen';

  @override
  String get settingsBedtime => 'Schlafenszeit';

  @override
  String get settingsPerWeekday => 'Abweichende Tage';

  @override
  String get settingsSameEveryDay => 'Jeden Tag gleich';

  @override
  String settingsCustomDays(String days) {
    return '$days';
  }

  @override
  String get settingsUseEveryday => 'Wie an jedem Tag';

  @override
  String get settingsWeekStarts => 'Woche beginnt am';

  @override
  String get settingsTimeFormat => 'Zeitformat';

  @override
  String settingsTimeSystem(String example) {
    return 'Gerät ($example)';
  }

  @override
  String get settingsTime12 => '12 h';

  @override
  String get settingsTime24 => '24 h';

  @override
  String get settingsPlanning => 'Planung';

  @override
  String get settingsDefaultDuration => 'Standarddauer';

  @override
  String get settingsSnap => 'Raster';

  @override
  String settingsSnapValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsShiftLater => 'Spätere mitverschieben';

  @override
  String get settingsShiftAsk => 'Jedes Mal fragen';

  @override
  String get settingsShiftAlways => 'Immer';

  @override
  String get settingsShiftNever => 'Nie';

  @override
  String get settingsShowFree => 'Freie Zeit zeigen';

  @override
  String get settingsShowFreeDetail => 'Gepunktete Lücken auf dem Faden';

  @override
  String get settingsLateNudge => 'Hinweis bei Verspätung';

  @override
  String get settingsLateNudgeDetail =>
      'Bietet an, den Rest des Tages zu verschieben';

  @override
  String get settingsRoll => 'Offenes auf morgen schieben';

  @override
  String get settingsRollDetail => 'Sonst geht es zurück in den Eingang';

  @override
  String get settingsReminders => 'Erinnerungen';

  @override
  String get settingsTaskStarts => 'Aufgabenbeginn';

  @override
  String get settingsAlertNone => 'Kein Hinweis';

  @override
  String get settingsAlertAtStart => 'Zu Beginn';

  @override
  String settingsAlertBefore(int minutes) {
    return '$minutes min vorher';
  }

  @override
  String get settingsBedtimeReminder => 'Erinnerung zur Schlafenszeit';

  @override
  String settingsBedtimeReminderDetail(String time) {
    return 'Um $time, mit der ersten Aufgabe von morgen';
  }

  @override
  String get settingsLook => 'Aussehen';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsThemeSystem => 'Wie dieses Gerät';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsAccent => 'Akzent';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsData => 'Daten';

  @override
  String get settingsTrash => 'Papierkorb';

  @override
  String get settingsTrashDetail => 'Gelöschte Aufgaben bleiben 30 Tage';

  @override
  String get settingsTrashEmpty => 'Papierkorb ist leer';

  @override
  String get settingsRestore => 'Wiederherstellen';

  @override
  String settingsRestored(String title) {
    return '$title wiederhergestellt';
  }

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsWhatsNew => 'Neuigkeiten';

  @override
  String changelogVersion(String version) {
    return 'Version $version';
  }

  @override
  String changelogInstalled(String version) {
    return 'Version $version · auf diesem Gerät';
  }

  @override
  String get changelogIntro =>
      'Was sich in jeder Version von Dottoday geändert hat.';

  @override
  String get releaseNotes010 =>
      'Plane deinen Tag an einem Faden: Zieh eine Aufgabe, um sie zu verschieben, zieh ihren Rand, um ihre Dauer zu ändern, und verschieb alles danach in einem Zug.\nFüge eine Aufgabe mit zwei Tipps hinzu, gib Zeiten in normalen Worten ein oder füge eine Liste ein, um mehrere auf einmal anzulegen.\nWiederkehrende Aufgaben, Erinnerungen mit Vorlauf und deine Kalender auf der Zeitleiste – alles kostenlos.\nSync zwischen iPhone, Android, Mac und Web, mit sichtbarem Status und ohne Datenverlust.\nExportiere alles als JSON, CSV oder Kalenderdatei und spiel ein Backup wieder ein.\nSende Feedback aus den Einstellungen und lies nach jedem Update hier die Neuigkeiten.';

  @override
  String whatsNewBanner(String version) {
    return 'Dottoday $version ist da';
  }

  @override
  String get whatsNewOpen => 'Neuigkeiten ansehen';

  @override
  String get settingsFeedback => 'Feedback senden';

  @override
  String get settingsFeedbackIntro =>
      'Öffnet einen Entwurf in deiner Mail-App, den du von dort sendest. Inhalte deiner Aufgaben sind nicht enthalten.';

  @override
  String get settingsFeedbackDiagnostics => 'Diagnosedaten anhängen';

  @override
  String get settingsFeedbackDiagnosticsHint =>
      'App-Version, Gerätetyp, Sync-Status und wie viele Aufgaben du hast – nie, was darin steht.';

  @override
  String get settingsFeedbackDiagnosticsFailed =>
      'Diagnosedaten konnten nicht gelesen werden, die E-Mail geht ohne sie raus.';

  @override
  String get settingsFeedbackPreview => 'Wird am Ende deiner E-Mail angefügt:';

  @override
  String get settingsFeedbackWrite => 'E-Mail schreiben';

  @override
  String get settingsFeedbackSubject => 'Feedback zu Dottoday';

  @override
  String get settingsFeedbackNoMail =>
      'Auf diesem Gerät ist keine Mail-App eingerichtet.';

  @override
  String settingsAccentLabel(String name) {
    return 'Akzent $name';
  }

  @override
  String get dayCardYesterdaySuffix => ' · Gestern';

  @override
  String get dayCardTomorrowSuffix => ' · Morgen';

  @override
  String spreadDoneOf(int done, int total) {
    return '$done von $total';
  }

  @override
  String spreadPlanned(int count) {
    return '$count geplant';
  }

  @override
  String spreadSubtitle(String date, int done, int total) {
    return '$date · $done von $total erledigt';
  }

  @override
  String get spreadPreviousDay => 'Vorheriger Tag';

  @override
  String get spreadNextDay => 'Nächster Tag';

  @override
  String get spreadDropToPlan => 'zum Planen hier ablegen';

  @override
  String spreadDropToPlanLabel(String day) {
    return 'Leg eine Aufgabe hier ab, um sie für $day zu planen';
  }

  @override
  String threadDropInbox(String duration) {
    return '$duration frei · Aufgabe aus dem Eingang hier ablegen';
  }

  @override
  String get runningLate => 'Ich bin spät dran';

  @override
  String runningLateBy(int minutes) {
    return '+$minutes min';
  }

  @override
  String snackRunningLate(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben um $minutes min nach hinten verschoben',
      one: '1 Aufgabe um $minutes min nach hinten verschoben',
      zero: 'Nichts mehr zu verschieben',
    );
    return '$_temp0';
  }

  @override
  String snackRunningLatePartial(int count, int minutes, String pinned) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben um $minutes min nach hinten verschoben',
      one: '1 Aufgabe um $minutes min nach hinten verschoben',
    );
    return '$_temp0 · $pinned bleibt, wo es ist';
  }

  @override
  String get spreadNothing => 'Nichts geplant';

  @override
  String threadFreeFits(String duration, String title) {
    return '$duration frei · $title passt';
  }

  @override
  String inboxFitsToday(String time) {
    return 'Passt heute $time';
  }

  @override
  String inboxFitsDay(String day, String time) {
    return 'Passt $day $time';
  }

  @override
  String get inboxFitsNone => 'Diese Woche kein Platz';

  @override
  String inboxAddedMeta(String duration, String when) {
    return '$duration · hinzugefügt $when';
  }

  @override
  String get inboxAddedToday => 'heute';

  @override
  String get inboxAddedYesterday => 'gestern';

  @override
  String inboxSortLabel(String order) {
    return 'Sortieren: $order';
  }

  @override
  String get inboxSortAdded => 'hinzugefügt';

  @override
  String get inboxSortDuration => 'Dauer';

  @override
  String get inboxSortFit => 'erste freie Zeit';

  @override
  String get inboxAutoPlan => 'Woche automatisch planen';

  @override
  String snackAutoPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben diese Woche eingeplant',
      one: '1 Aufgabe diese Woche eingeplant',
      zero: 'Diese Woche passt nichts',
    );
    return '$_temp0';
  }

  @override
  String snackAutoPlannedPartial(int count, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben eingeplant',
      one: '1 Aufgabe eingeplant',
    );
    return '$_temp0 · $left noch im Eingang';
  }

  @override
  String get inboxDropToday => 'Auf heute ziehen';

  @override
  String inboxDropTodayFree(String duration) {
    return '$duration frei';
  }

  @override
  String inboxDropHint(String keys) {
    return 'Zieh eine Aufgabe auf eine gepunktete Lücke oder drück $keys in einer Zeile, um sie in die erste passende Lücke zu setzen.';
  }

  @override
  String inboxUnscheduledCount(int count) {
    return '$count nicht eingeplant';
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
    return '$planned geplant von $awake wach';
  }

  @override
  String weekBusiest(String day, String planned) {
    return 'Am vollsten · $day · $planned';
  }

  @override
  String weekLightest(String day, String planned) {
    return 'Am ruhigsten · $day · $planned';
  }

  @override
  String weekFree(String free) {
    return 'Frei · $free ungeplant';
  }

  @override
  String weekDone(int done, int total) {
    return 'Erledigt · $done von $total';
  }

  @override
  String get weekBusiestTag => 'Am vollsten';

  @override
  String get weekLightestTag => 'Am ruhigsten';

  @override
  String get weekTitle => 'Diese Woche';

  @override
  String weekSubtitle(String range, int done, int total, String planned) {
    return '$range · $done von $total erledigt · $planned geplant';
  }

  @override
  String weekDayFree(String free) {
    return '$free frei';
  }

  @override
  String weekTodayDay(String day) {
    return '$day · heute';
  }

  @override
  String get weekViewWeek => 'Woche';

  @override
  String get weekViewMonth => 'Monat';

  @override
  String get weekToday => 'Heute';

  @override
  String weekDropHere(String free) {
    return 'Aufgabe hier ablegen · $free';
  }

  @override
  String weekDropAt(String day, String range) {
    return '$day · $range';
  }

  @override
  String weekCardLeft(int minutes) {
    return 'noch $minutes min';
  }

  @override
  String weekCardSkipped(String range) {
    return '$range · übersprungen';
  }

  @override
  String weekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String monthStats(int done, int missed, int ahead) {
    return '$done erledigt · $missed nicht erledigt · $ahead anstehend';
  }

  @override
  String monthStatsBusiest(String stats, String day) {
    return '$stats · vollster Tag $day';
  }

  @override
  String get editorClose => 'Schließen';

  @override
  String get editorEscKey => 'esc';

  @override
  String get shortcutsTitle => 'Tastaturkurzbefehle';

  @override
  String get shortcutsEverywhere => 'Überall';

  @override
  String get shortcutsTodaySection => 'Heute';

  @override
  String get shortcutsWeekMonth => 'Woche und Monat';

  @override
  String get shortcutsInbox => 'Eingang';

  @override
  String get shortcutsEditor => 'Aufgabe bearbeiten';

  @override
  String get shortcutAdd => 'Aufgabe hinzufügen';

  @override
  String get shortcutGoToday => 'Zu Heute';

  @override
  String get shortcutGoInbox => 'Zum Eingang';

  @override
  String get shortcutGoWeek => 'Zur Woche';

  @override
  String get shortcutGoMonth => 'Zum Monat';

  @override
  String get shortcutShowKeys => 'Diese Kurzbefehle zeigen';

  @override
  String get shortcutPrevDay => 'Vorheriger Tag';

  @override
  String get shortcutNextDay => 'Nächster Tag';

  @override
  String get shortcutBackToday => 'Zurück zu heute';

  @override
  String get shortcutDoneLive => 'Aktuelle Aufgabe als erledigt markieren';

  @override
  String get shortcutPrevPeriod => 'Vorherige Woche bzw. vorheriger Monat';

  @override
  String get shortcutNextPeriod => 'Nächste Woche bzw. nächster Monat';

  @override
  String get shortcutThisPeriod => 'Diese Woche bzw. dieser Monat';

  @override
  String get shortcutPlaceFirst =>
      'Ausgewählte Aufgabe in die erste freie Lücke setzen';

  @override
  String get shortcutAutoPlan => 'Woche automatisch planen';

  @override
  String get shortcutSave => 'Sichern und schließen';

  @override
  String get shortcutDone => 'Als erledigt markieren';

  @override
  String get shortcutClose => 'Schließen';

  @override
  String get repeatTitle => 'Wiederholen';

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Tage',
      one: 'Jeden Tag',
    );
    return '$_temp0';
  }

  @override
  String get repeatEveryWeekday => 'Jeden Werktag';

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Wochen',
      one: 'Jede Woche',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeksOn(int count, String days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Wochen am $days',
      one: 'Jede Woche am $days',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonthsOnDay(int count, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Monate am $day.',
      one: 'Jeden Monat am $day.',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonthsOnNth(int count, String nth, String weekday) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Monate am $nth $weekday',
      one: 'Jeden Monat am $nth $weekday',
    );
    return '$_temp0';
  }

  @override
  String repeatNth(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '1': 'ersten',
      '2': 'zweiten',
      '3': 'dritten',
      '4': 'vierten',
      'other': 'letzten',
    });
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Jahre',
      one: 'Jedes Jahr',
    );
    return '$_temp0';
  }

  @override
  String repeatTimes(String summary, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-mal',
      one: 'einmal',
    );
    return '$summary · $_temp0';
  }

  @override
  String repeatUntil(String summary, String date) {
    return '$summary · bis $date';
  }

  @override
  String get repeatChoiceDaily => 'Jeden Tag';

  @override
  String get repeatChoiceWeekly => 'Jede Woche';

  @override
  String get repeatChoiceMonthly => 'Jeden Monat';

  @override
  String get repeatChoiceYearly => 'Jedes Jahr';

  @override
  String get repeatChoiceCustom => 'Eigene';

  @override
  String repeatOnDay(int day) {
    return 'Am $day.';
  }

  @override
  String repeatOnNth(String nth, String weekday) {
    return 'Am $nth $weekday';
  }

  @override
  String get repeatEvery => 'Alle';

  @override
  String repeatUnitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tage',
      one: 'Tag',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wochen',
      one: 'Woche',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Monate',
      one: 'Monat',
    );
    return '$_temp0';
  }

  @override
  String get repeatIntervalLess => 'Weniger';

  @override
  String get repeatIntervalMore => 'Mehr';

  @override
  String get repeatEnds => 'Endet';

  @override
  String get repeatEndsNever => 'Nie';

  @override
  String get repeatEndsAfter => 'Nach';

  @override
  String get repeatEndsOn => 'An einem Datum';

  @override
  String repeatEndsAfterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-mal',
      one: '1-mal',
    );
    return '$_temp0';
  }

  @override
  String get repeatDone => 'Fertig';

  @override
  String get scopeTitleEdit => 'Was ändern?';

  @override
  String get scopeTitleDelete => 'Was löschen?';

  @override
  String get scopeThis => 'Nur diese';

  @override
  String get scopeFollowing => 'Diese und folgende';

  @override
  String get scopeAll => 'Alle';

  @override
  String get scopeAllDetail => 'Vergangene bleiben, wie sie waren';

  @override
  String snackSeriesChanged(String title) {
    return '$title geändert';
  }

  @override
  String snackSeriesDeleted(String title) {
    return '$title gelöscht';
  }

  @override
  String snackRepeatSet(String title, String summary) {
    return '$title wiederholt sich: $summary';
  }

  @override
  String snackRepeatStopped(String title) {
    return '$title wiederholt sich nicht mehr';
  }

  @override
  String get alertsTitle => 'Hinweise';

  @override
  String get alertsAdd => 'Hinweis hinzufügen';

  @override
  String get alertsMax => 'Bis zu 5 Hinweise';

  @override
  String alertsRemove(String alert) {
    return '$alert entfernen';
  }

  @override
  String get alertsBedtime => 'Erinnerung zur Schlafenszeit';

  @override
  String get alertsBedtimeDetail =>
      'Jeden Abend, mit der ersten Aufgabe von morgen';

  @override
  String get alertsDone => 'Fertig';

  @override
  String snackAlertsSaved(String title) {
    return 'Hinweise für $title aktualisiert';
  }

  @override
  String subtaskRemove(String title) {
    return '$title entfernen';
  }

  @override
  String subtaskReorder(String title) {
    return '$title umsortieren';
  }

  @override
  String get subtaskMoveUp => 'Nach oben';

  @override
  String get subtaskMoveDown => 'Nach unten';

  @override
  String subtaskRename(String title) {
    return '$title umbenennen';
  }

  @override
  String get subtaskNow => 'jetzt';

  @override
  String get subtaskEveryTime => 'Diese Liste jedes Mal verwenden';

  @override
  String snackSubtaskRemoved(String title) {
    return '$title entfernt';
  }

  @override
  String snackListEveryTime(String title) {
    return '$title bekommt jedes Mal diese Liste';
  }

  @override
  String get colourIconTitle => 'Farbe und Symbol';

  @override
  String get colourIconDone => 'Fertig';

  @override
  String get subtaskRenameTitle => 'Unteraufgabe umbenennen';

  @override
  String get subtaskRenameSave => 'Umbenennen';

  @override
  String editorZone(String city) {
    return 'Zeitzone · $city';
  }

  @override
  String get todayMenuLate => 'Ich bin spät dran …';

  @override
  String get todayMenuReview => 'Tag durchsehen';

  @override
  String get lateAmount => 'Wie viel später';

  @override
  String get lateShiftRest => 'Rest verschieben';

  @override
  String lateShiftPreview(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben rücken $minutes min nach hinten',
      one: '1 Aufgabe rückt $minutes min nach hinten',
      zero: 'Nichts mehr zu verschieben',
    );
    return '$_temp0';
  }

  @override
  String lateShiftPreviewPartial(int count, int minutes, String pinned) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben rücken $minutes min nach hinten',
      one: '1 Aufgabe rückt $minutes min nach hinten',
    );
    return '$_temp0 · $pinned bleibt, wo es ist';
  }

  @override
  String lateSkip(String title) {
    return '“$title” überspringen';
  }

  @override
  String get lateSkipDetail =>
      'Gibt die Zeit frei, sonst verschiebt sich nichts';

  @override
  String lateShorten(String title) {
    return '“$title” kürzen';
  }

  @override
  String lateShortenDetail(int minutes, String end) {
    return 'Beginnt $minutes min später, endet weiter um $end';
  }

  @override
  String lateShortenTooShort(int minutes) {
    return 'Zu kurz, um $minutes min abzugeben';
  }

  @override
  String get lateNothingLeft => 'Heute steht nichts mehr an';

  @override
  String snackSkippedTask(String title) {
    return '“$title” übersprungen';
  }

  @override
  String snackShortened(String title, int minutes) {
    return '“$title” beginnt $minutes min später';
  }

  @override
  String get reviewTitle => 'Tagesrückblick';

  @override
  String reviewSummary(int done, int total) {
    return '$done von $total erledigt';
  }

  @override
  String get reviewAskTomorrow => 'Den Rest auf morgen verschieben?';

  @override
  String get reviewAskInbox => 'Den Rest in den Eingang legen?';

  @override
  String reviewMoveTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count auf morgen verschieben',
      one: '1 auf morgen verschieben',
    );
    return '$_temp0';
  }

  @override
  String reviewSendInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in den Eingang',
      one: '1 in den Eingang',
    );
    return '$_temp0';
  }

  @override
  String reviewStaying(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count weitere bleiben: Sie wiederholen sich oder stammen aus einem Kalender',
      one:
          '1 weitere bleibt: Sie wiederholt sich oder stammt aus einem Kalender',
    );
    return '$_temp0';
  }

  @override
  String get reviewAllDone => 'Nichts mehr zu verschieben';

  @override
  String snackRolled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben auf morgen verschoben',
      one: '1 Aufgabe auf morgen verschoben',
    );
    return '$_temp0';
  }

  @override
  String snackSentToInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben in den Eingang gelegt',
      one: '1 Aufgabe in den Eingang gelegt',
    );
    return '$_temp0';
  }

  @override
  String get promptNotNow => 'Nicht jetzt';

  @override
  String get lateNudgeTitle => 'Mehr Zeit nötig?';

  @override
  String lateNudgeDetail(String title, int minutes) {
    return '“$title” endete vor $minutes min';
  }

  @override
  String get lateNudgeAction => 'Aufholen';

  @override
  String get todayMenuDuplicate => 'Tag duplizieren …';

  @override
  String get todayMenuCopyText => 'Tag als Text kopieren';

  @override
  String get duplicateDayTitle => 'Auf welchen Tag kopieren?';

  @override
  String get snackDayCopied => 'Tag als Text kopiert';

  @override
  String inboxDoneOn(String date) {
    return 'Erledigt $date';
  }

  @override
  String inboxNotDone(String title) {
    return '“$title” als nicht erledigt markieren';
  }

  @override
  String get inboxClearCompleted => 'Erledigte entfernen';

  @override
  String snackBackInInbox(String title) {
    return '“$title” ist wieder im Eingang';
  }

  @override
  String snackClearedCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count erledigte Aufgaben in den Papierkorb verschoben',
      one: '1 erledigte Aufgabe in den Papierkorb verschoben',
    );
    return '$_temp0';
  }

  @override
  String get settingsAccount => 'Konto';

  @override
  String get settingsCalendars => 'Kalender';

  @override
  String get settingsCalendarsDetail => 'Termine auf deiner Zeitleiste';

  @override
  String get settingsExport => 'Exportieren';

  @override
  String get settingsExportDetail => 'Deine Daten, frei mitzunehmen';

  @override
  String get settingsHelp => 'Hilfe';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsAboutApp => 'Über Dottoday';

  @override
  String get settingsBack => 'Zurück zu den Einstellungen';

  @override
  String get accountProfile => 'Profil';

  @override
  String get accountName => 'Name';

  @override
  String get accountNameNone => 'Nicht festgelegt';

  @override
  String get accountNameTitle => 'Dein Name';

  @override
  String get accountNameSave => 'Sichern';

  @override
  String get accountSync => 'Sync';

  @override
  String get accountLocalBody =>
      'Alles liegt auf diesem Gerät. Melde dich an, um zwischen deinen Geräten zu synchronisieren und eine sichere Kopie zu behalten.';

  @override
  String get accountApple => 'Mit Apple fortfahren';

  @override
  String get accountGoogle => 'Mit Google fortfahren';

  @override
  String get accountEmail => 'Mit E-Mail fortfahren';

  @override
  String get accountComingSoon =>
      'Die Anmeldung kommt mit Sync in einem späteren Update. Bis dahin verlässt nichts dieses Gerät.';

  @override
  String accountSignedInAs(String email) {
    return 'Angemeldet als $email';
  }

  @override
  String get accountSignOut => 'Abmelden';

  @override
  String get accountSignOutEverywhere => 'Überall abmelden';

  @override
  String get accountDelete => 'Konto löschen';

  @override
  String get accountDeleteTitle => 'Dein Konto löschen?';

  @override
  String get accountDeleteExportFirst => 'Erst meine Daten exportieren';

  @override
  String accountDeleteBody(String word) {
    return 'Dadurch werden dein Konto und alles damit Synchronisierte gelöscht. Aufgaben auf diesem Gerät bleiben. Gib $word ein, um zu bestätigen.';
  }

  @override
  String get accountDeleteWord => 'LÖSCHEN';

  @override
  String get calendarsIntro =>
      'Deine Kalendertermine auf der Zeitleiste, neben deinen Aufgaben. Kostenlos, immer.';

  @override
  String get calendarsConnected => 'Verbunden';

  @override
  String get calendarsNone => 'Noch keine Kalender verbunden';

  @override
  String get calendarsConnect => 'Kalender verbinden';

  @override
  String get calendarsOnlineInSettings =>
      'Verbinde Google oder Microsoft unter Einstellungen › Kalender.';

  @override
  String get calendarsOnline => 'Google und Microsoft';

  @override
  String get calendarsOnlineIntro =>
      'Einmal verbunden, erscheinen sie auf jedem Gerät, auf dem du angemeldet bist. Ist ein Kalender auch auf diesem Gerät, schalte einen der beiden aus.';

  @override
  String get calendarsOnlineSignIn =>
      'Melde dich an, um Google oder Microsoft zu verbinden';

  @override
  String get calendarsConnectGoogle => 'Google Kalender verbinden';

  @override
  String get calendarsConnectMicrosoft => 'Microsoft Outlook verbinden';

  @override
  String get calendarsReconnect => 'Neu verbinden';

  @override
  String get calendarsReconnectDetail =>
      'Dottoday erreicht dieses Konto erst wieder, wenn du es neu verbindest';

  @override
  String get calendarsUnreachable => 'Dieses Konto war gerade nicht erreichbar';

  @override
  String get calendarsDisconnect => 'Trennen';

  @override
  String calendarsDisconnectTitle(String account) {
    return '$account trennen?';
  }

  @override
  String get calendarsDisconnectBody =>
      'Die Termine verschwinden auf jedem Gerät von deiner Zeitleiste. Termine mit deinen Unteraufgaben oder Notizen kommen in den Papierkorb.';

  @override
  String get calendarsShifting => 'Wenn sich der Tag verschiebt';

  @override
  String get calendarsMoveEvents => 'Auch Kalendertermine verschieben';

  @override
  String get calendarsMoveEventsDetail =>
      'Wenn du den Rest verschiebst. Geteilte und wiederkehrende Termine bleiben, wo sie sind.';

  @override
  String get calendarsAsk =>
      'Dottoday fragt dein Gerät einmal, ob es deine Kalender sehen darf. Danach wählst du, welche angezeigt werden.';

  @override
  String get calendarsOnDevice => 'Auf diesem Gerät';

  @override
  String get calendarsNoneOnDevice => 'Keine Kalender auf diesem Gerät';

  @override
  String get calendarsReadOnly => 'Nur lesen';

  @override
  String get calendarsPickInSettings =>
      'Verbunden · Kalender in den Einstellungen wählen';

  @override
  String get calendarDeniedTitle => 'Kalenderzugriff ist aus';

  @override
  String get calendarDeniedBody =>
      'Dottoday kann deine Termine erst zeigen, wenn der Kalenderzugriff in den Geräteeinstellungen erlaubt ist.';

  @override
  String get calendarSettingsPath =>
      'Öffne die Einstellungen deines Geräts, such Dottoday und erlaube den Zugriff auf Kalender.';

  @override
  String get exportIntro =>
      'Deine Aufgaben gehören dir. Exportieren ist kostenlos, immer, mit oder ohne Konto.';

  @override
  String get exportFormats => 'Formate';

  @override
  String get exportJson => 'Alles (JSON)';

  @override
  String get exportJsonDetail => 'Eine vollständige Kopie zum Wiederherstellen';

  @override
  String get exportCsv => 'Aufgaben (CSV)';

  @override
  String get exportCsvDetail => 'Öffnet sich in jeder Tabellenkalkulation';

  @override
  String get exportIcs => 'Kalender (.ics)';

  @override
  String get exportIcsDetail => 'Für andere Kalender-Apps';

  @override
  String get exportPlain =>
      'Exportdateien sind nicht verschlüsselt: Wer die Datei hat, kann deine Aufgaben lesen. Importierte Kalendertermine bleiben in ihrem Kalender und sind nicht enthalten.';

  @override
  String get exportDone => 'Exportiert';

  @override
  String get exportHandOffFailed =>
      'Konnte die Datei nicht sichern oder teilen. Es wurde nichts geändert.';

  @override
  String get exportRestore => 'Wiederherstellen';

  @override
  String get exportImport => 'Backup importieren …';

  @override
  String get exportImportDetail => 'Eine aus Dottoday exportierte JSON-Datei';

  @override
  String get exportImportTitle =>
      'Deine Aufgaben durch dieses Backup ersetzen?';

  @override
  String exportImportBody(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben',
      one: '1 Aufgabe',
      zero: 'keine Aufgaben',
    );
    return 'Diese Datei vom $date enthält $_temp0. Alles, was hier ist, aber nicht darin, kommt in den Papierkorb. Vorher wird ein Backup des aktuellen Stands angelegt.';
  }

  @override
  String get exportImportAction => 'Ersetzen';

  @override
  String get exportCancel => 'Abbrechen';

  @override
  String get exportImported => 'Backup importiert';

  @override
  String get exportNotBackup =>
      'Das ist kein Dottoday-Backup oder es stammt aus einer neueren Version von Dottoday. Es wurde nichts geändert.';

  @override
  String get exportTooLarge =>
      'Diese Datei ist größer als 25 MB und zu groß zum Importieren. Es wurde nichts geändert.';

  @override
  String get exportBackups => 'Auf diesem Gerät';

  @override
  String get exportBackupsNote =>
      'Dottoday legt jeden Tag ein Backup an (die letzten 7) und eines vor jedem Import oder jeder Wiederherstellung – verschlüsselt und nur auf diesem Gerät.';

  @override
  String get exportBackupsNone =>
      'Noch keine Backups. Das erste wird beim nächsten Öffnen von Dottoday angelegt.';

  @override
  String get exportBackupDaily => 'Tägliches Backup';

  @override
  String get exportBackupPreImport => 'Vor einem Import';

  @override
  String get exportBackupPreRestore => 'Vor einer Wiederherstellung';

  @override
  String get exportRestoreTitle => 'Zu diesem Backup zurückkehren?';

  @override
  String exportRestoreBody(String date) {
    return 'Deine Aufgaben werden auf den Stand vom $date zurückgesetzt. Alles Neuere kommt in den Papierkorb. Vorher wird ein Backup des aktuellen Stands angelegt.';
  }

  @override
  String get exportRestoreAction => 'Wiederherstellen';

  @override
  String get exportRestored => 'Backup wiederhergestellt';

  @override
  String get helpIntro =>
      'Schnelle Antworten. Noch etwas? Sende unten Feedback.';

  @override
  String get helpMoveQ => 'Wie verschiebe ich eine Aufgabe?';

  @override
  String get helpMoveA =>
      'Zieh sie am Faden entlang oder zieh an ihren Rändern, um die Dauer zu ändern. Lange drücken, um mehrere auszuwählen.';

  @override
  String get helpLateQ => 'Ich bin spät dran. Kann sich alles verschieben?';

  @override
  String get helpLateA =>
      'Ja: ⋯ › Ich bin spät dran verschiebt den Rest des Tages um 5, 15 oder 30 Minuten und stoppt an angehefteten Aufgaben. Du kannst die aktuelle Aufgabe auch überspringen oder kürzen.';

  @override
  String get helpRepeatQ => 'Wie funktionieren wiederkehrende Aufgaben?';

  @override
  String get helpRepeatA =>
      'Öffne eine Aufgabe › Wiederholen. Häkchen und Unteraufgaben gehören zum jeweiligen Tag, die nächste beginnt also frisch.';

  @override
  String get helpPasteQ => 'Kann ich viele Aufgaben auf einmal hinzufügen?';

  @override
  String get helpPasteA =>
      'Füge eine Liste in Hinzufügen oder das Eingangsfeld ein: Jede Zeile wird eine Aufgabe.';

  @override
  String get helpKeysQ => 'Gibt es Tastaturkurzbefehle?';

  @override
  String get helpKeysA =>
      'Drück auf dem Mac oder im Browser ⌘/ (sonst Strg+/), um alle zu sehen.';

  @override
  String get privacyLocalTitle => 'Auf deinem Gerät';

  @override
  String get privacyLocalBody =>
      'Aufgaben werden verschlüsselt auf diesem Gerät gespeichert, und die App funktioniert komplett offline.';

  @override
  String get privacyTrackTitle => 'Kein Tracking';

  @override
  String get privacyTrackBody =>
      'Keine Werbung, keine Analysen, keine Tracker von Dritten.';

  @override
  String get privacySyncTitle => 'Wenn du dich anmeldest';

  @override
  String get privacySyncBody =>
      'Sync sendet deine Aufgaben über eine verschlüsselte Verbindung an dein eigenes Konto und sonst nirgendwohin.';

  @override
  String get privacySearchTitle => 'Suchen';

  @override
  String get privacySearchBody =>
      'Letzte Suchen bleiben auf diesem Gerät und werden nie synchronisiert oder exportiert.';

  @override
  String get privacyClearSearches => 'Letzte Suchen löschen';

  @override
  String get snackSearchesCleared => 'Letzte Suchen gelöscht';

  @override
  String get aboutLicences => 'Open-Source-Lizenzen';

  @override
  String get settingsSync => 'Sync';

  @override
  String get syncTitle => 'Sync';

  @override
  String get syncLocalOnlyBody =>
      'Deine Aufgaben sind nur auf diesem Gerät. Melde dich an, um sie zwischen deinen Geräten zu synchronisieren.';

  @override
  String get syncSignIn => 'Anmelden …';

  @override
  String get syncJustNow => 'Gerade eben synchronisiert';

  @override
  String syncMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Vor $minutes min synchronisiert',
      one: 'Vor 1 min synchronisiert',
    );
    return '$_temp0';
  }

  @override
  String syncAt(String when) {
    return 'Zuletzt synchronisiert $when';
  }

  @override
  String get syncNever => 'Noch nicht synchronisiert';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Änderungen warten auf Sync',
      one: '1 Änderung wartet auf Sync',
      zero: 'Nichts wartet auf Sync',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Jetzt synchronisieren';

  @override
  String get syncStateSynced => 'Auf dem neuesten Stand';

  @override
  String get syncStateSyncing => 'Synchronisiert …';

  @override
  String get syncStateOffline =>
      'Offline. Änderungen werden hier gespeichert und synchronisiert, sobald du wieder online bist.';

  @override
  String get syncStateError =>
      'Konnte nicht synchronisieren. Deine Änderungen sind hier sicher; es wird erneut versucht.';

  @override
  String get syncConflicts => 'Auf zwei Geräten geändert';

  @override
  String get syncConflictHint =>
      'Die Änderung des anderen Geräts gilt, bis du wählst.';

  @override
  String syncConflictField(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'Titel',
      'start': 'Uhrzeit',
      'duration': 'Dauer',
      'notes': 'Notizen',
      'colour': 'Farbe',
      'status': 'Erledigt oder nicht',
      'other': 'Ein Detail',
    });
    return '$_temp0';
  }

  @override
  String syncMine(String value) {
    return 'Dieses Gerät: $value';
  }

  @override
  String syncTheirs(String value) {
    return 'Anderes Gerät: $value';
  }

  @override
  String get syncKeepMine => 'Meine behalten';

  @override
  String get syncKeepTheirs => 'Andere behalten';

  @override
  String get bannerOffline => 'Offline · hier funktioniert weiter alles';

  @override
  String bannerConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Änderungen brauchen dich',
      one: '1 Änderung braucht dich',
    );
    return '$_temp0';
  }

  @override
  String get bannerReview => 'Ansehen';

  @override
  String get notifDeniedTitle => 'Mitteilungen sind aus';

  @override
  String get notifDeniedBody =>
      'Dottoday kann dich erst erinnern, wenn Mitteilungen in den Geräteeinstellungen erlaubt sind.';

  @override
  String get notifOpenSettings => 'Einstellungen öffnen';

  @override
  String get notifSettingsPath =>
      'Öffne die Einstellungen deines Geräts › Mitteilungen › Dottoday und erlaube Mitteilungen.';

  @override
  String syncSummary(String last, String pending) {
    return '$last · $pending';
  }

  @override
  String syncConflictHeading(String title, String field) {
    return '$title · $field';
  }

  @override
  String get recoveryLockedTitle => 'Dottoday kann deine Aufgaben nicht öffnen';

  @override
  String get recoveryLockedBody =>
      'Deine Aufgaben auf diesem Gerät sind mit einem Schlüssel gesperrt, der fehlt oder sich geändert hat. Das kann nach dem Wiederherstellen eines Geräts oder dem Leeren des Schlüsselbunds passieren.';

  @override
  String get recoveryFreshBody =>
      'Neu beginnen legt die alte Datei beiseite (sie wird nie gelöscht) und öffnet einen leeren Planer. Deine Aufgaben kommen zurück, wenn du dich zum Synchronisieren anmeldest oder einen Export importierst.';

  @override
  String get recoveryStartFresh => 'Neu beginnen';

  @override
  String get recoveryConfirm =>
      'Mit einem leeren Planer beginnen? Die alte Datei bleibt auf diesem Gerät.';

  @override
  String get recoveryConfirmYes => 'Ja, neu beginnen';

  @override
  String recoveryKept(String where) {
    return 'Deine alte Datei liegt unter $where';
  }

  @override
  String get recoveryTabTitle => 'Dottoday ist in einem anderen Tab geöffnet';

  @override
  String get recoveryTabBody =>
      'Damit deine Aufgaben sicher bleiben, kann immer nur ein Tab sie nutzen.';

  @override
  String get recoveryUseHere => 'Hier verwenden';

  @override
  String get recoveryMovedTitle =>
      'Dottoday ist in einen anderen Tab gewechselt';

  @override
  String get recoveryMovedBody =>
      'Du nutzt Dottoday jetzt in einem anderen Tab. Deine Aufgaben sind gespeichert.';

  @override
  String get recoveryNoAnswer =>
      'Der andere Tab hat nicht geantwortet. Schließ ihn und versuch es noch mal.';

  @override
  String get recoveryContinue => 'Weiter';

  @override
  String get stateLoading => 'Wird geladen';

  @override
  String get stateErrorTitle => 'Das konnte nicht geladen werden';

  @override
  String get stateErrorSafe => 'Deine Aufgaben sind auf diesem Gerät sicher.';

  @override
  String get stateRetry => 'Noch mal versuchen';

  @override
  String get stateReadFailed =>
      'Konnte deine Aufgaben auf diesem Gerät nicht lesen.';

  @override
  String get inboxSelect => 'Auswählen';

  @override
  String get inboxPlanThese => 'Diese einplanen';

  @override
  String inboxSelectedLabel(String title) {
    return '$title, ausgewählt';
  }

  @override
  String get onboardingWelcomeTitle => 'Dein Tag als Faden.';

  @override
  String get onboardingWelcomeBody =>
      'Plane deinen Tag als Punkte auf einer Linie, sieh, wohin die Zeit geht, und verschieb alles, wenn sich der Tag verschiebt.';

  @override
  String get onboardingGetStarted => 'Los geht’s';

  @override
  String get onboardingSignIn => 'Ich habe schon ein Konto';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingBack => 'Zurück';

  @override
  String get onboardingContinue => 'Weiter';

  @override
  String onboardingStepOf(int step, int total) {
    return 'Schritt $step von $total';
  }

  @override
  String get onboardingDotLabel => 'Der Tagespunkt zeichnet sich';

  @override
  String get onboardingDayShapeTitle => 'Wann beginnt und endet dein Tag?';

  @override
  String get onboardingDayShapeBody =>
      'Deine Aufgaben liegen zwischen diesen beiden Zeiten. Du kannst sie in den Einstellungen ändern oder jedem Wochentag eigene geben.';

  @override
  String get onboardingHabitsTitle => 'Was füllt deine Tage?';

  @override
  String get onboardingHabitsBody =>
      'Wähl bis zu fünf. Sie kommen zu passenden Zeiten auf den Faden von morgen; du kannst sie jederzeit ändern.';

  @override
  String onboardingHabitsAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zu morgen hinzufügen',
      one: '1 zu morgen hinzufügen',
    );
    return '$_temp0';
  }

  @override
  String get onboardingHabitsMax => 'Fünf sind für den Anfang genug.';

  @override
  String get starterMorningRun => 'Morgenlauf';

  @override
  String get starterDeepWork => 'Konzentriertes Arbeiten';

  @override
  String get starterLunch => 'Mittagessen';

  @override
  String get starterWalk => 'Spaziergang';

  @override
  String get starterGym => 'Fitnessstudio';

  @override
  String get starterRead => 'Lesen';

  @override
  String get starterPlanTomorrow => 'Morgen planen';

  @override
  String onboardingHabitMeta(String time, String length) {
    return '$time · $length';
  }

  @override
  String get onboardingRemindersTitle => 'Lust auf einen Anstoß?';

  @override
  String get onboardingRemindersBody =>
      'Dottoday erinnert dich, wenn eine Aufgabe beginnt, und vor der Schlafenszeit. Du kannst das jederzeit in den Einstellungen ändern.';

  @override
  String get onboardingTaskStarts => 'Vor jeder Aufgabe';

  @override
  String get onboardingTaskStartsDetail =>
      'Wie früh, entscheidest du in den Einstellungen';

  @override
  String get onboardingBedtime => 'Zur Schlafenszeit';

  @override
  String get onboardingBedtimeDetail =>
      'Die erste Aufgabe von morgen, damit der Morgen keine Überraschungen bringt';

  @override
  String get onboardingAllow => 'Mitteilungen erlauben';

  @override
  String get onboardingNotNow => 'Nicht jetzt';

  @override
  String get onboardingAccountTitle => 'Aufgaben synchron halten?';

  @override
  String get onboardingAccountBody =>
      'Melde dich an, um Dottoday auf all deinen Geräten mit einer sicheren Kopie zu nutzen. Oder nicht: Auf diesem Gerät funktioniert alles auch ohne Konto.';

  @override
  String get onboardingWithoutAccount => 'Ohne Konto weiter';

  @override
  String get onboardingDoneTitle => 'Dein erster Faden';

  @override
  String get onboardingDoneBody =>
      'Morgen, vom Aufstehen bis zur Schlafenszeit. Füg etwas hinzu, verschieb Dinge oder fang mit heute an.';

  @override
  String get onboardingDoneEmpty =>
      'Morgen, vom Aufstehen bis zur Schlafenszeit, gehört ganz dir. Füg die erste Aufgabe hinzu, wann du willst.';

  @override
  String get onboardingOpenToday => 'Heute öffnen';

  @override
  String get onboardingTomorrow => 'Morgen';

  @override
  String get onboardingWelcomeBackTitle => 'Willkommen zurück';

  @override
  String get onboardingWelcomeBackBody =>
      'Melde dich an, um deine Aufgaben auf dieses Gerät zu holen.';

  @override
  String get accountEmailLabel => 'E-Mail';

  @override
  String get accountSendLink => 'Link senden';

  @override
  String get accountOtherWays => 'Andere Anmeldemöglichkeiten';

  @override
  String get accountEmailInvalid =>
      'Das sieht nicht nach einer E-Mail-Adresse aus.';

  @override
  String get accountCheckMailTitle => 'Schau in deine E-Mails';

  @override
  String accountCheckMailBody(String email) {
    return 'Wir haben einen Anmeldelink an $email gesendet. Öffne ihn auf diesem Gerät, um weiterzumachen.';
  }

  @override
  String get accountResend => 'Erneut senden';

  @override
  String get accountOtherEmail => 'Andere E-Mail verwenden';

  @override
  String get accountErrorTitle => 'Konnte dich nicht anmelden';

  @override
  String get accountRestoring => 'Deine Aufgaben kommen auf dieses Gerät …';

  @override
  String accountRestoreCount(int done, int total) {
    return '$done von $total';
  }

  @override
  String notifStartsIn(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes Minuten',
      one: '1 Minute',
    );
    return 'Beginnt in $_temp0';
  }

  @override
  String get notifStartsNow => 'Beginnt jetzt';

  @override
  String get notifEndsNow => 'Endet jetzt';

  @override
  String notifOverdue(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes Minuten',
      one: '1 Minute',
    );
    return 'Vor $_temp0 geendet. Erledigt?';
  }

  @override
  String get notifSnoozed => 'Geschlummerte Erinnerung';

  @override
  String get notifBedtimeTitle => 'Schlafenszeit';

  @override
  String notifBedtimeFirst(String title, String time) {
    return 'Morgen beginnt mit $title um $time.';
  }

  @override
  String get notifBedtimeFree => 'Für morgen ist noch nichts geplant.';

  @override
  String get notifActionDone => 'Erledigt';

  @override
  String get notifActionSnooze => '10 min schlummern';

  @override
  String get notifActionOpen => 'Öffnen';

  @override
  String get notifChannelAlerts => 'Aufgabenhinweise';

  @override
  String get notifChannelAlertsDetail =>
      'Erinnerungen vor, zu Beginn und nach deinen Aufgaben';

  @override
  String get notifChannelAlarms => 'Start in den Tag';

  @override
  String get notifChannelAlarmsDetail =>
      'Klingelt wie ein Wecker bei der ersten Aufgabe des Tages und wenn eine Routine beginnt';

  @override
  String get notifChannelSummary => 'Schlafenszeit';

  @override
  String get notifChannelSummaryDetail => 'Der abendliche Blick auf morgen';

  @override
  String inAppAlertText(String title, String detail) {
    return '$title · $detail';
  }

  @override
  String get inAppAlertLater => 'Später';

  @override
  String get widgetNextUp => 'Als Nächstes';

  @override
  String get widgetNow => 'Jetzt';

  @override
  String widgetUntil(String time) {
    return 'bis $time';
  }

  @override
  String get widgetNothingNext => 'Heute steht nichts mehr an';

  @override
  String get widgetToday => 'Heute';

  @override
  String widgetInboxCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count im Eingang',
      one: '1 im Eingang',
      zero: 'Eingang ist leer',
    );
    return '$_temp0';
  }

  @override
  String get menuFile => 'Ablage';

  @override
  String get menuEdit => 'Bearbeiten';

  @override
  String get menuView => 'Darstellung';

  @override
  String get menuGo => 'Gehe zu';

  @override
  String get menuWindow => 'Fenster';

  @override
  String get menuSettings => 'Einstellungen …';

  @override
  String get menuNewTask => 'Neue Aufgabe';

  @override
  String get menuExport => 'Exportieren …';

  @override
  String get menuUndo => 'Rückgängig';

  @override
  String get menuMonth => 'Monat';

  @override
  String get menuShortcuts => 'Tastaturkurzbefehle';

  @override
  String get menuPreviousDay => 'Vorheriger Tag';

  @override
  String get menuNextDay => 'Nächster Tag';

  @override
  String get exactTitle =>
      'Erinnerungen kommen eventuell ein paar Minuten nach ihrer Zeit';

  @override
  String get exactBody =>
      'Um Akku zu sparen, kann Android Erinnerungen zurückhalten. Erlaube genaue Zeitplanung, damit jede kommt, wenn deine Aufgabe beginnt.';

  @override
  String get exactAllow => 'Genaue Zeitplanung erlauben';

  @override
  String get skipToContent => 'Zum Inhalt springen';

  @override
  String get installText =>
      'Dottoday installieren: öffnet sich wie eine App und funktioniert offline';

  @override
  String get installAction => 'Installieren';

  @override
  String get lockCaption => 'APP-SPERRE';

  @override
  String get lockToggle => 'Dottoday sperren';

  @override
  String get lockToggleDetail => 'Gesicht, Fingerabdruck oder Code abfragen';

  @override
  String get lockWebTitle => 'Nutzt die Sperre deines Computers';

  @override
  String get lockWebDetail =>
      'Im Browser ist Dottoday so gesperrt wie dein Computer. Sperr deinen Bildschirm, wenn du weggehst; Aufgaben bleiben in diesem Browser verschlüsselt.';

  @override
  String get lockAfter => 'Sperren nach';

  @override
  String get lockAfterNow => 'Sofort';

  @override
  String lockAfterMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes Minuten',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String get lockReason => 'Dottoday entsperren';

  @override
  String get lockTitle => 'Dottoday ist gesperrt';

  @override
  String get lockUnlock => 'Entsperren';

  @override
  String get lockUnavailable =>
      'Dieses Gerät hat keinen Code, daher kann Dottoday nicht gesperrt werden.';

  @override
  String zoneBannerText(String city) {
    return 'Du bist jetzt in $city – Zeiten behalten oder verschieben?';
  }

  @override
  String get zoneKeep => 'Zeiten behalten';

  @override
  String get zoneShift => 'Verschieben';

  @override
  String zoneKeptSnack(String city) {
    return 'Aufgaben behalten ihre Zeiten in $city';
  }

  @override
  String zoneShiftedSnack(String city) {
    return 'Aufgaben auf die Zeit in $city verschoben';
  }

  @override
  String get syncAgoJustNow => 'gerade eben';

  @override
  String syncAgoMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'vor $minutes min',
      one: 'vor 1 min',
    );
    return '$_temp0';
  }

  @override
  String syncAgoHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'vor $hours h',
      one: 'vor 1 h',
    );
    return '$_temp0';
  }

  @override
  String syncLineSynced(String ago) {
    return 'Synchronisiert · $ago';
  }

  @override
  String get syncLineSyncing => 'Synchronisiert …';

  @override
  String get syncLineOffline => 'Offline · Änderungen hier gespeichert';

  @override
  String clockFast(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Deine Uhr geht $minutes min vor',
      one: 'Deine Uhr geht 1 min vor',
    );
    return '$_temp0 – Erinnerungen kommen eventuell zu früh';
  }

  @override
  String clockSlow(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Deine Uhr geht $minutes min nach',
      one: 'Deine Uhr geht 1 min nach',
    );
    return '$_temp0 – Erinnerungen kommen eventuell nach ihrer Zeit';
  }

  @override
  String get syncClockWaiting =>
      'Änderungen von diesem Gerät warten, bis die Uhr stimmt; Änderungen von deinen anderen Geräten kommen weiter an.';

  @override
  String get healthTitle => 'Mitteilungs-Check';

  @override
  String get healthCaption => 'Dieses Gerät';

  @override
  String get healthIntro =>
      'Was darüber entscheidet, ob deine Erinnerungen auf diesem Gerät ankommen – gerade aus den Einstellungen gelesen.';

  @override
  String get healthAllGood => 'Alles gut';

  @override
  String get healthPermissionOk => 'Mitteilungen sind an';

  @override
  String get healthPermissionOff => 'Mitteilungen sind aus';

  @override
  String get healthPermissionOffDetail =>
      'Dottoday kann dich erst erinnern, wenn du sie erlaubst.';

  @override
  String get healthExactOk => 'Erinnerungen kommen auf die Minute';

  @override
  String get healthExactOff =>
      'Erinnerungen kommen eventuell ein paar Minuten nach ihrer Zeit';

  @override
  String get healthExactOffDetail =>
      'Erlaube “Wecker & Erinnerungen” für Dottoday, damit sie auf die Minute kommen.';

  @override
  String get healthBatteryOk => 'Energiesparen lässt Dottoday in Ruhe';

  @override
  String get healthBatteryOff => 'Energiesparen kann Erinnerungen zurückhalten';

  @override
  String get healthBatteryOffDetail =>
      'Wähle in der Liste Dottoday und “Nicht optimieren”.';

  @override
  String get healthDndOff => 'Nicht stören ist aus';

  @override
  String get healthDndOn => 'Nicht stören ist an';

  @override
  String get healthDndOnDetail =>
      'Die erste Aufgabe des Tages klingelt trotzdem; andere Erinnerungen kommen leise.';

  @override
  String get healthFocus => 'Fokus';

  @override
  String get healthFocusDetail =>
      'Aufgabenbeginne sind zeitkritisch – ein Fokus, der zeitkritische Mitteilungen erlaubt, lässt sie durch.';

  @override
  String get healthPushOk => 'Erinnerungen kommen auch bei geschlossenem Tab';

  @override
  String get healthPushOff =>
      'Erinnerungen kommen, solange Dottoday geöffnet ist';

  @override
  String get healthPushOffDetail =>
      'Melde dich an und erlaube Mitteilungen, damit sie auch bei geschlossenem Tab kommen.';

  @override
  String get healthClockOk => 'Deine Uhr stimmt';

  @override
  String get healthClockOffDetail =>
      'Schalte “Automatisch einstellen” in deinen Datums- und Uhrzeiteinstellungen ein.';

  @override
  String get healthFixAllow => 'Erlauben';

  @override
  String get healthFixOpen => 'Einstellungen öffnen';

  @override
  String healthToFix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Punkte zu beheben',
      one: '1 Punkt zu beheben',
    );
    return '$_temp0';
  }

  @override
  String get testAlarmTitle => 'Testalarm';

  @override
  String get testAlarmBody =>
      'Er ist angekommen. Deine Erinnerungen werden es auch.';

  @override
  String get testAlarmCaption => 'Prüfen, ob es klappt';

  @override
  String get inAppAlertOk => 'OK';

  @override
  String get testAlarmRow => 'Testalarm senden';

  @override
  String get testAlarmRowDetail =>
      'Prüfen, ob eine Erinnerung dich wirklich erreicht';

  @override
  String get testAlarmExplain =>
      'Dottoday sendet in 60 Sekunden einen Testalarm, damit du prüfen kannst, ob er ankommt.';

  @override
  String get testAlarmSend => 'Senden';

  @override
  String get testAlarmCancel => 'Abbrechen';

  @override
  String get testAlarmAsk => 'Hat es geklingelt?';

  @override
  String get testAlarmYes => 'Ja';

  @override
  String get testAlarmNo => 'Nein';

  @override
  String get testAlarmGood =>
      'Er ist angekommen. Deine Erinnerungen werden es auch.';

  @override
  String get testAlarmLookHere => 'Die Prüfungen oben zeigen, was im Weg ist.';

  @override
  String get testAlarmLookLater =>
      'Was im Weg ist, findest du unter Einstellungen › Erinnerungen › Mitteilungs-Check.';

  @override
  String testAlarmCountdown(int seconds) {
    return 'Klingelt in $seconds s …';
  }

  @override
  String get syncLinePaused => 'Sync pausiert · tippe auf Sync für den Grund';

  @override
  String settingsSynced(String name, String ago) {
    return '$name · synchronisiert $ago';
  }

  @override
  String settingsSyncedNoName(String ago) {
    return 'Synchronisiert $ago';
  }

  @override
  String settingsNameAndStatus(String name, String status) {
    return '$name · $status';
  }

  @override
  String get calendarEventUntitled => 'Termin ohne Titel';

  @override
  String get taskLinks => 'Links';

  @override
  String taskLinkOpen(String host) {
    return '$host im Browser öffnen';
  }

  @override
  String get taskLinkFailed => 'Konnte den Link nicht öffnen';

  @override
  String get calendarsWriteBack => 'Änderungen zurückschreiben';

  @override
  String get calendarsWriteBackDetail =>
      'Was du hier verschiebst, in der Dauer änderst oder umbenennst, geht an den Kalender, auch frühere Änderungen. Wiederkehrende und ganztägige Termine ändern sich nur hier.';

  @override
  String bannerWriteBackPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Änderungen sind noch nicht in deinem Kalender angekommen',
      one: '1 Änderung ist noch nicht in deinem Kalender angekommen',
    );
    return '$_temp0';
  }

  @override
  String bannerWriteBackClash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Termine wurden auch in deinem Kalender geändert',
      one: 'Dieser Termin wurde auch in deinem Kalender geändert',
    );
    return '$_temp0';
  }

  @override
  String get bannerUseCalendars => 'Kalenderversion nehmen';

  @override
  String taskCalendarSends(String calendar) {
    return 'Änderungen gehen zurück an $calendar';
  }

  @override
  String taskCalendarStays(String calendar) {
    return 'Aus $calendar · Änderungen bleiben in Dottoday';
  }

  @override
  String get travelTitle => 'Wegzeit';

  @override
  String travelSuggestDetail(String place, String duration) {
    return 'In $place. $duration davor für den Weg einplanen?';
  }

  @override
  String travelSuggestAdd(String duration) {
    return '$duration davor hinzufügen';
  }

  @override
  String travelAdded(String title) {
    return 'Wegzeit vor “$title” hinzugefügt';
  }

  @override
  String get travelNone => 'Keine';

  @override
  String travelBefore(String duration) {
    return '$duration davor';
  }

  @override
  String rowTravelMeta(String duration) {
    return '· $duration Weg';
  }

  @override
  String rowTravel(String label, String duration) {
    return '$label, $duration Wegzeit davor';
  }

  @override
  String get calendarsTravel => 'Wegzeit';

  @override
  String get calendarsTravelSuggest => 'Wegzeit vorschlagen';

  @override
  String get calendarsTravelSuggestDetail =>
      'Vor Terminen mit Ort. Auf diesem Gerät berechnet, ohne Kartenabfrage';

  @override
  String rowFromCalendar(String label) {
    return '$label, aus deinem Kalender';
  }

  @override
  String get pinTitle => 'Angeheftet';

  @override
  String get pinDetail =>
      'Bleibt stehen, wenn sich andere Aufgaben verschieben';

  @override
  String threadOutsideBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben vor dem Aufstehen',
      one: '1 Aufgabe vor dem Aufstehen',
    );
    return '$_temp0';
  }

  @override
  String threadOutsideAfter(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben nach der Schlafenszeit',
      one: '1 Aufgabe nach der Schlafenszeit',
    );
    return '$_temp0';
  }
}
