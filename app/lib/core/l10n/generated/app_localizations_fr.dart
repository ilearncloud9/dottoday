// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Dottoday';

  @override
  String get failureStorage =>
      'Impossible d\'enregistrer sur cet appareil. Réessayez.';

  @override
  String get failureNetworkOffline =>
      'Vous êtes hors ligne. Les modifications sont enregistrées sur cet appareil et seront synchronisées plus tard.';

  @override
  String get failureNetworkTimeout =>
      'Le serveur met trop de temps à répondre. Réessayez.';

  @override
  String get failureNetworkServer =>
      'Le serveur a rencontré un problème. Vos données sont en sécurité sur cet appareil.';

  @override
  String get failureAuth =>
      'Votre session a pris fin. Reconnectez-vous pour continuer la synchronisation.';

  @override
  String get failureValidationRequired => 'Ce champ ne peut pas être vide.';

  @override
  String get failureValidationTooLong =>
      'C\'est trop long. Essayez plus court.';

  @override
  String get failureValidationOutOfRange =>
      'Cette valeur est hors de la plage autorisée.';

  @override
  String get failureValidationInvalidFormat =>
      'Ce format ne semble pas correct. Vérifiez-le.';

  @override
  String get failureValidationTooLarge => 'Ce fichier est trop volumineux.';

  @override
  String get failureNotFound => 'Cet élément n\'existe plus.';

  @override
  String get failureConflict =>
      'Cet élément a été modifié sur un autre appareil. Choisissez la version à garder.';

  @override
  String get failurePermissionNotifications =>
      'Les notifications sont désactivées pour Dottoday. Vous pouvez les activer dans les réglages du système.';

  @override
  String get failurePermissionCalendar =>
      'Dottoday n\'a pas accès à vos calendriers. Vous pouvez l\'autoriser dans les réglages du système.';

  @override
  String get failureUndoExpired =>
      'Impossible d\'annuler maintenant. Les tâches supprimées restent 30 jours dans la corbeille.';

  @override
  String get failureUnexpected => 'Un problème est survenu. Réessayez.';

  @override
  String get navToday => 'Aujourd\'hui';

  @override
  String get navInbox => 'Boîte de réception';

  @override
  String get navWeek => 'Semaine';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navSettings => 'Réglages';

  @override
  String get quickAddTooltip => 'Ajouter une tâche';

  @override
  String get sheetClose => 'Fermer';

  @override
  String get timeInputLabel => 'Heure';

  @override
  String get timeInputHint => 'ex. 9h30 ou 14h';

  @override
  String get timeInputInvalid => 'Saisissez une heure comme 9h30 ou 14h';

  @override
  String get timeInputWheel => 'Choisir l\'heure avec une molette';

  @override
  String get timeInputDone => 'OK';

  @override
  String get durationLabel => 'Durée';

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
  String get durationCustom => 'Autre';

  @override
  String get durationCustomHint => 'ex. 40 min ou 1h30';

  @override
  String get durationCustomInvalid => 'De 5 min à 24 h, par ex. 40 min ou 1h30';

  @override
  String get colorCoral => 'Corail';

  @override
  String get colorAmber => 'Ambre';

  @override
  String get colorMint => 'Menthe';

  @override
  String get colorTeal => 'Sarcelle';

  @override
  String get colorSky => 'Ciel';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorViolet => 'Violet';

  @override
  String get colorRose => 'Rose';

  @override
  String get colorSlate => 'Ardoise';

  @override
  String get undoAction => 'Annuler';

  @override
  String get syncLocalOnly => 'Sur cet appareil';

  @override
  String get syncSynced => 'Synchronisé';

  @override
  String get syncSyncing => 'Synchronisation';

  @override
  String get syncOffline => 'Hors ligne';

  @override
  String get syncError => 'Problème de synchro';

  @override
  String timelineNow(String time) {
    return 'Maintenant, $time';
  }

  @override
  String timelineBeforeHours(String time) {
    return 'Avant $time';
  }

  @override
  String timelineAfterHours(String time) {
    return 'Après $time';
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
      other: '$count blocs de plus',
      one: '1 bloc de plus',
    );
    return '$_temp0';
  }

  @override
  String get timelineAllDay => 'Toute la journée';

  @override
  String blockTimeRange(String start, String end) {
    return '$start–$end';
  }

  @override
  String blockSemantics(String title, String start, String end) {
    return '$title, de $start à $end';
  }

  @override
  String get timelineMenu => 'Plus d\'options';

  @override
  String get debugLoadDemoDay => 'Charger une journée de démo (debug)';

  @override
  String get debugDemoDayLoaded => 'Journée de démo chargée';

  @override
  String get semanticsSeparator => ', ';

  @override
  String get blockDone => 'fait';

  @override
  String get blockNotDoneYet => 'pas encore fait';

  @override
  String blockSubtasks(int done, int total) {
    return '$done sous-tâches faites sur $total';
  }

  @override
  String blockSubtasksShort(int done, int total) {
    return '$done/$total';
  }

  @override
  String get blockRecurring => 'récurrente';

  @override
  String get blockPinned => 'épinglée';

  @override
  String get blockFromCalendar => 'de votre calendrier';

  @override
  String blockAlerts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alertes',
      one: '1 alerte',
    );
    return '$_temp0';
  }

  @override
  String get blockStartsBefore => 'commencé la veille';

  @override
  String get blockEndsAfter => 'se poursuit le lendemain';

  @override
  String blockMarkDone(String title) {
    return 'Marquer $title comme fait';
  }

  @override
  String blockMarkNotDone(String title) {
    return 'Marquer $title comme pas fait';
  }

  @override
  String get undoMarkedDone => 'Marqué comme fait';

  @override
  String get undoMarkedNotDone => 'Marqué comme pas fait';

  @override
  String dotUpcoming(String title) {
    return '$title, à venir';
  }

  @override
  String dotLive(String title) {
    return '$title, en cours';
  }

  @override
  String dotLiveLeft(String title, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes restantes',
      one: '1 minute restante',
    );
    return '$title, en cours, $_temp0';
  }

  @override
  String dotDone(String title) {
    return '$title, fait';
  }

  @override
  String dotSkipped(String title) {
    return '$title, passée';
  }

  @override
  String dotMissed(String title) {
    return '$title, pas fait';
  }

  @override
  String get dotMarkDoneHint => 'Marquer comme fait';

  @override
  String get dotMarkNotDoneHint => 'Marquer comme pas fait';

  @override
  String get dotOpenHint => 'Ouvrir';

  @override
  String threadOverlapping(String overlapping) {
    return 'Les tâches se $overlapping';
  }

  @override
  String get threadOverlappingWord => 'chevauchent';

  @override
  String rowLabel(String title, String range) {
    return '$title, $range';
  }

  @override
  String rowMissed(String label) {
    return '$label, pas fait';
  }

  @override
  String rowPinned(String label) {
    return '$label, épinglée';
  }

  @override
  String rowRepeats(String label) {
    return '$label, se répète';
  }

  @override
  String get rowMissedMeta => '· pas fait';

  @override
  String threadWake(String time) {
    return 'Réveil · $time';
  }

  @override
  String threadBed(String time) {
    return 'Coucher · $time';
  }

  @override
  String threadFree(String duration) {
    return '$duration libre';
  }

  @override
  String threadAddHere(String duration) {
    return '$duration libre · ajouter ici';
  }

  @override
  String threadAddHereLabel(String duration, String time) {
    return '$duration libre à partir de $time. Ajouter une tâche ici';
  }

  @override
  String liveSubtasks(int done, int total) {
    return '$done sur $total';
  }

  @override
  String liveMinutesLeft(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min restantes',
      one: '1 min restante',
    );
    return '$_temp0';
  }

  @override
  String get liveDone => 'Fait';

  @override
  String get liveExtend => '+15 min';

  @override
  String get liveShiftRest => 'Décaler la suite';

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
    return 'Journée écoulée à $percent %';
  }

  @override
  String get weekStripShowMonth => 'Afficher le mois';

  @override
  String get weekStripHideMonth => 'Masquer le mois';

  @override
  String get dayCardTodaySuffix => ' · Aujourd\'hui';

  @override
  String dayCardSummary(int done, int total, String planned) {
    return '$done sur $total · $planned prévu';
  }

  @override
  String dayCardNothing(String free) {
    return 'Rien de prévu · $free libre';
  }

  @override
  String dayPagerPosition(int position, int count) {
    return 'Jour $position sur $count';
  }

  @override
  String monthMore(int count) {
    return '+$count de plus';
  }

  @override
  String monthDoneOf(int done, int total) {
    return '$done sur $total faites';
  }

  @override
  String get monthLightDay => 'Journée légère';

  @override
  String monthMissedItem(String title) {
    return '$title · pas fait';
  }

  @override
  String monthNowItem(String title) {
    return '$title · maintenant';
  }

  @override
  String threadTimeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get debugConceptPreview => 'Aperçu Concept A (debug)';

  @override
  String todayGreeting(String part) {
    String _temp0 = intl.Intl.selectLogic(part, {
      'morning': 'Bonjour',
      'afternoon': 'Bon après-midi',
      'other': 'Bonsoir',
    });
    return '$_temp0';
  }

  @override
  String todayGreetingName(String part, String name) {
    String _temp0 = intl.Intl.selectLogic(part, {
      'morning': 'Bonjour, $name',
      'afternoon': 'Bon après-midi, $name',
      'other': 'Bonsoir, $name',
    });
    return '$_temp0';
  }

  @override
  String get todayEmpty =>
      'Rien de prévu · tirez le bandeau pour planifier ou touchez +';

  @override
  String get todayAllDay => 'Toute la journée';

  @override
  String stripDayLabel(String day, int done, int total) {
    return '$day, $done sur $total faites';
  }

  @override
  String monthFooterPlanned(String month, int count, int days) {
    return '$month · $count jours prévus sur $days';
  }

  @override
  String monthDaysPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours prévus',
      one: '1 jour prévu',
    );
    return '$_temp0';
  }

  @override
  String get monthLegendPlanned => 'prévu';

  @override
  String get monthLegendRepeats => 'se répète';

  @override
  String monthNav(String previous, String current, String next) {
    return '$previous · $current · $next';
  }

  @override
  String get monthPrevious => 'Mois précédent';

  @override
  String get monthNext => 'Mois suivant';

  @override
  String get todayPill => 'Aujourd\'hui';

  @override
  String monthCellLabel(String day, int done, int total) {
    return '$day, $done sur $total faites';
  }

  @override
  String get emptyAddToDay => 'Ajouter à ce jour';

  @override
  String emptyPullInbox(int count) {
    return 'Depuis la boîte de réception · $count';
  }

  @override
  String get emptyCopyDay => 'Copier un jour…';

  @override
  String get copyDayTitle => 'Copier quel jour ?';

  @override
  String copyDayDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches copiées',
      one: '1 tâche copiée',
    );
    return '$_temp0';
  }

  @override
  String get copyDayNothing => 'Rien à copier ce jour-là';

  @override
  String snackDone(String title) {
    return '$title : fait';
  }

  @override
  String snackNotDone(String title) {
    return '$title : pas fait';
  }

  @override
  String snackExtended(String title, String time) {
    return '$title se termine maintenant à $time';
  }

  @override
  String snackShifted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches déplacées',
      one: '1 tâche déplacée',
    );
    return '$_temp0';
  }

  @override
  String snackShiftedPartial(int count, String pin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches déplacées · arrêt à $pin (épinglée)',
      one: '1 tâche déplacée · arrêt à $pin (épinglée)',
      zero: 'Rien n\'a bougé : $pin est épinglée',
    );
    return '$_temp0';
  }

  @override
  String sheetMetaDay(String day, String range, String duration) {
    return '$day · $range · $duration';
  }

  @override
  String get sheetToday => 'Aujourd\'hui';

  @override
  String get sheetTomorrow => 'Demain';

  @override
  String get sheetInbox => 'Boîte de réception';

  @override
  String get sheetDone => 'Fait';

  @override
  String get sheetUndone => 'Pas fait';

  @override
  String get sheetExtend => '+15 min';

  @override
  String get sheetShift => 'Décaler';

  @override
  String get sheetMove => 'Déplacer';

  @override
  String get sheetEdit => 'Modifier';

  @override
  String sheetSubtasks(int done, int total) {
    return 'Sous-tâches · $done sur $total';
  }

  @override
  String get sheetSubtasksNone => 'Sous-tâches';

  @override
  String get sheetAddSubtask => '+ Ajouter';

  @override
  String get sheetNewSubtask => 'Nouvelle sous-tâche';

  @override
  String get sheetAlerts => 'Alertes';

  @override
  String get sheetRepeat => 'Répéter';

  @override
  String get sheetLook => 'Couleur et icône';

  @override
  String get sheetNever => 'Jamais';

  @override
  String get sheetNoAlerts => 'Aucune';

  @override
  String get sheetNotFound => 'Cette tâche n\'est plus là';

  @override
  String get alertAtStart => 'au début';

  @override
  String get alertAtEnd => 'à la fin';

  @override
  String alertBefore(int minutes) {
    return '$minutes min avant';
  }

  @override
  String alertOverdue(int minutes) {
    return '$minutes min après la fin';
  }

  @override
  String alertJoin(String first, String rest) {
    return '$first · $rest';
  }

  @override
  String get repeatDaily => 'Tous les jours';

  @override
  String get repeatWeekdays => 'En semaine';

  @override
  String repeatWeekly(String days) {
    return 'Chaque semaine le $days';
  }

  @override
  String get repeatMonthly => 'Tous les mois';

  @override
  String get repeatYearly => 'Tous les ans';

  @override
  String get repeatCustom => 'Personnalisé';

  @override
  String listJoin(String first, String rest) {
    return '$first, $rest';
  }

  @override
  String sheetLeftSuffix(String left) {
    return ' · $left';
  }

  @override
  String get colourIconCaption => 'Couleur et icône';

  @override
  String get colourIconMore => 'Toutes les icônes';

  @override
  String get editorCaption => 'Modifier la tâche';

  @override
  String get editorTitleHint => 'De quoi s\'agit-il ?';

  @override
  String get editorWhen => 'Quand';

  @override
  String get editorStart => 'Début';

  @override
  String editorEndsAt(String time) {
    return '→ $time';
  }

  @override
  String get editorDuration => 'Durée';

  @override
  String get editorNotes => 'Notes';

  @override
  String get editorNotesHint => 'Ajouter des notes';

  @override
  String get editorSave => 'Enregistrer';

  @override
  String get editorMoveToInbox => 'Mettre dans la boîte de réception';

  @override
  String get editorDelete => 'Supprimer la tâche';

  @override
  String editorDeleteConfirm(String title) {
    return 'Supprimer “$title” ?';
  }

  @override
  String get editorDeleteBody =>
      'Elle reste 30 jours dans la corbeille. Vous pouvez annuler juste après.';

  @override
  String get editorCancel => 'Annuler';

  @override
  String snackDeleted(String title) {
    return '$title supprimée';
  }

  @override
  String snackMovedToInbox(String title) {
    return '$title mise dans la boîte de réception';
  }

  @override
  String get editorPickDay => 'Choisir un jour';

  @override
  String dragDropAt(String time) {
    return '→ $time';
  }

  @override
  String snackMoved(String title, String time) {
    return '$title déplacée à $time';
  }

  @override
  String snackMovedDay(String title, String day) {
    return '$title déplacée à $day';
  }

  @override
  String get shiftChipLabel => 'Décaler les tâches suivantes';

  @override
  String get shiftChipCalendar => 'Événements du calendrier aussi';

  @override
  String snackMovedShifted(String title, String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title déplacée à $time · $count tâches suivantes décalées aussi',
      one: '$title déplacée à $time · 1 tâche suivante décalée aussi',
      zero: '$title déplacée à $time',
    );
    return '$_temp0';
  }

  @override
  String snackMovedShiftedPartial(String title, String time, String pin) {
    return '$title déplacée à $time · arrêt à $pin (épinglée)';
  }

  @override
  String get selectAction => 'Sélectionner';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnées',
      one: '1 sélectionnée',
    );
    return '$_temp0';
  }

  @override
  String get selectionClose => 'Terminer la sélection';

  @override
  String get selectionMove => 'Déplacer';

  @override
  String get selectionMoveTitle => 'Déplacer vers';

  @override
  String get selectionDuplicate => 'Dupliquer';

  @override
  String get selectionColour => 'Couleur';

  @override
  String get selectionDelete => 'Supprimer';

  @override
  String selectionDeleteConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer $count tâches ?',
      one: 'Supprimer 1 tâche ?',
    );
    return '$_temp0';
  }

  @override
  String snackManyMoved(int count, String day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches déplacées à $day',
      one: '1 tâche déplacée à $day',
    );
    return '$_temp0';
  }

  @override
  String snackManyDuplicated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches dupliquées',
      one: '1 tâche dupliquée',
    );
    return '$_temp0';
  }

  @override
  String snackManyRecoloured(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Couleur changée pour $count tâches',
      one: 'Couleur changée pour 1 tâche',
    );
    return '$_temp0';
  }

  @override
  String snackManyDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches mises à la corbeille',
      one: '1 tâche mise à la corbeille',
    );
    return '$_temp0';
  }

  @override
  String get inboxSchedule => 'Planifier';

  @override
  String get inboxTrash => 'Mettre à la corbeille';

  @override
  String inboxRowLabel(String title, String length) {
    return '$title, $length';
  }

  @override
  String inboxSummary(int count, String work) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count non planifiées',
      one: '1 non planifiée',
    );
    return '$_temp0 · $work de travail';
  }

  @override
  String inboxRingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches dans la boîte de réception',
      one: '1 tâche dans la boîte de réception',
      zero: 'Boîte de réception vide',
    );
    return '$_temp0';
  }

  @override
  String get inboxAddHint => 'Appeler maman demain 15h 20 min';

  @override
  String get inboxAddLabel => 'Ajouter une tâche';

  @override
  String get inboxFilterAll => 'Toutes';

  @override
  String get inboxFilterUnder30 => 'Moins de 30 min';

  @override
  String get inboxFilterFits => 'Tient aujourd\'hui';

  @override
  String inboxNextSlot(String range, String title) {
    return 'Prochain créneau libre aujourd\'hui : $range · idéal pour $title';
  }

  @override
  String get inboxPlace => 'Placer';

  @override
  String inboxCompleted(int count) {
    return 'Faites · $count';
  }

  @override
  String get inboxEmpty => 'Boîte de réception vide';

  @override
  String get inboxNoMatch => 'Rien ne correspond à ce filtre';

  @override
  String get inboxUntitled => 'Nouvelle tâche';

  @override
  String inboxScheduleTitle(String title) {
    return 'Planifier $title';
  }

  @override
  String inboxScheduleToday(String range) {
    return 'Aujourd\'hui, $range';
  }

  @override
  String inboxScheduleTomorrow(String range) {
    return 'Demain, $range';
  }

  @override
  String get inboxScheduleNone =>
      'Aucun créneau libre aujourd\'hui ni demain. Faites de la place aujourd\'hui ou faites-la glisser depuis la semaine.';

  @override
  String snackScheduled(String title, String when) {
    return '$title planifiée pour $when';
  }

  @override
  String snackAddedInbox(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches ajoutées',
      one: '$title ajoutée à la boîte de réception',
    );
    return '$_temp0';
  }

  @override
  String snackAddedTimed(String title, String when) {
    return '$title ajoutée pour $when';
  }

  @override
  String snackTrashed(String title) {
    return '$title mise à la corbeille';
  }

  @override
  String get addTitleLabel => 'Titre';

  @override
  String get addTypeTimeHint =>
      'Ajoutez aussi une heure : ‘Faire les courses 17h 1 heure’';

  @override
  String addRemoveToken(String token) {
    return 'Retirer “$token”';
  }

  @override
  String get addSuggestions => 'Suggestions';

  @override
  String get addFromHabits => 'selon vos habitudes';

  @override
  String addHabitUsual(String range, String length) {
    return 'en général $range · $length';
  }

  @override
  String addHabitNoTime(String length) {
    return 'sans heure fixe · $length';
  }

  @override
  String addHabitLabel(String title, String meta) {
    return '$title, $meta';
  }

  @override
  String get addContinue => 'Continuer';

  @override
  String get addToInbox => 'Plutôt dans la boîte de réception';

  @override
  String addStepOf(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get addBack => 'Retour';

  @override
  String addWhenOnDay(String day, String time) {
    return '$day, $time';
  }

  @override
  String get pickerLabel => 'Heure de début';

  @override
  String addWhenSummary(String day, String range, String length) {
    return '$day · $range · $length';
  }

  @override
  String get addTimeCaption => 'Heure';

  @override
  String get addDurationCaption => 'Durée';

  @override
  String addFreeUntil(String time) {
    return 'Libre jusqu\'à $time · aucun chevauchement';
  }

  @override
  String addOverlaps(int count, String title, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chevauche $title et $others autres',
      one: 'Chevauche $title',
    );
    return '$_temp0 · vous pouvez quand même l\'ajouter';
  }

  @override
  String addLandsOn(String day, String range) {
    return 'Placée le $day à $range';
  }

  @override
  String get addSlotFree => 'le créneau est libre';

  @override
  String addSlotBusy(String title) {
    return 'chevauche $title';
  }

  @override
  String get addAdd => 'Ajouter';

  @override
  String get addAnother => 'Ajouter une autre';

  @override
  String durationChipMinutes(int minutes) {
    return '$minutes';
  }

  @override
  String durationChipHours(String hours) {
    return '$hours h';
  }

  @override
  String get inboxPickTime => 'Choisir une heure…';

  @override
  String get durationSheetTitle => 'Durée';

  @override
  String get durationTypeLabel => 'Ou saisissez une durée';

  @override
  String durationEnds(String time) {
    return 'fin à $time';
  }

  @override
  String durationFitsBefore(String title, String time) {
    return 'Tient encore avant $title à $time';
  }

  @override
  String durationFitsBedtime(String time) {
    return 'Tient avant le coucher à $time';
  }

  @override
  String durationRunsInto(String title, String time) {
    return 'Empiète sur $title à $time';
  }

  @override
  String durationPastBedtime(String time) {
    return 'Finit après le coucher à $time';
  }

  @override
  String get durationPresets => 'Préréglages';

  @override
  String get durationReset => 'Réinitialiser';

  @override
  String get durationAddPreset => 'préréglage';

  @override
  String get durationAddPresetLabel => 'Garder cette durée en préréglage';

  @override
  String durationRemovePreset(String length) {
    return 'Retirer le préréglage $length';
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
    return '$hours h $minutes';
  }

  @override
  String get addMoreTime => 'Plus d\'options d\'heure';

  @override
  String get addMoreDuration => 'Plus de durées';

  @override
  String get timeMenuChangeDay => 'Changer de jour';

  @override
  String get timeMenuPickWeek => 'Choisir dans la semaine';

  @override
  String get timeMenuAllDay => 'Toute la journée';

  @override
  String get timeMenuTimed => 'Lui donner une heure';

  @override
  String get timeMenuInbox => 'Envoyer dans la boîte de réception';

  @override
  String get timeMenuZone => 'Fuseau horaire';

  @override
  String get timeMenuType => 'Saisir une heure';

  @override
  String get zoneSearch => 'Rechercher une ville ou un fuseau';

  @override
  String get weekPrevious => 'Semaine précédente';

  @override
  String get weekNext => 'Semaine suivante';

  @override
  String get addAllDay => 'Toute la journée';

  @override
  String get addLandsOnEdit => 'Modifier';

  @override
  String addLandsOnAllDay(String day) {
    return 'Placée le $day · toute la journée';
  }

  @override
  String pasteAsk(int count) {
    return 'Ajouter $count tâches ?';
  }

  @override
  String pasteAdd(int count) {
    return 'Ajouter $count';
  }

  @override
  String get pasteKeep => 'Garder en une seule';

  @override
  String get searchSubtitle => 'Tout ce que vous avez prévu';

  @override
  String get searchFieldLabel =>
      'Rechercher dans les titres, notes et sous-tâches';

  @override
  String get searchClear => 'Effacer la recherche';

  @override
  String searchRingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get searchFilterAll => 'Tout';

  @override
  String get searchFilterToday => 'Aujourd\'hui';

  @override
  String get searchFilterWeek => 'Cette semaine';

  @override
  String get searchFilterInbox => 'Boîte de réception';

  @override
  String get searchFilterDone => 'Fait';

  @override
  String get searchFilterColour => 'Couleur';

  @override
  String get searchFilterIcon => 'Icône';

  @override
  String get searchPickColour => 'Afficher une couleur';

  @override
  String get searchPickIcon => 'Afficher une icône';

  @override
  String searchGroupToday(String weekday) {
    return '$weekday · Aujourd\'hui';
  }

  @override
  String get searchGroupInbox => 'Boîte de réception';

  @override
  String searchMetaDay(String day, String range) {
    return '$day · $range';
  }

  @override
  String searchMetaDone(String when) {
    return '$when · Fait';
  }

  @override
  String searchMetaMissed(String when) {
    return '$when · pas fait';
  }

  @override
  String searchMetaInbox(String length) {
    return 'Boîte de réception · $length';
  }

  @override
  String searchRowLabel(String title, String meta) {
    return '$title, $meta';
  }

  @override
  String get searchRecent => 'Récentes';

  @override
  String searchRecentLabel(String query) {
    return 'Rechercher à nouveau $query';
  }

  @override
  String get searchEmpty =>
      'Retrouvez tout ce que vous avez prévu : titres, notes et sous-tâches, même celles qui sont faites.';

  @override
  String searchNoResults(String query) {
    return 'Aucun résultat pour “$query”';
  }

  @override
  String get searchNoResultsHint =>
      'Essayez avec moins de mots ou un autre filtre.';

  @override
  String get searchShowAll => 'Tout afficher';

  @override
  String searchDayLabel(String weekday, String date) {
    return '$weekday $date';
  }

  @override
  String settingsLocalOnly(String name) {
    return '$name · sur cet appareil';
  }

  @override
  String get settingsLocalOnlyNoName => 'Sur cet appareil';

  @override
  String settingsAvatarLabel(String name) {
    return 'Compte : $name';
  }

  @override
  String get settingsDayShape => 'Forme de la journée';

  @override
  String settingsAwake(String length) {
    return '$length éveillé';
  }

  @override
  String get settingsWakeUp => 'Réveil';

  @override
  String get settingsBedtime => 'Coucher';

  @override
  String get settingsPerWeekday => 'Jours différents';

  @override
  String get settingsSameEveryDay => 'Identique chaque jour';

  @override
  String settingsCustomDays(String days) {
    return '$days';
  }

  @override
  String get settingsUseEveryday => 'Comme les autres jours';

  @override
  String get settingsWeekStarts => 'Début de semaine';

  @override
  String get settingsTimeFormat => 'Format de l\'heure';

  @override
  String settingsTimeSystem(String example) {
    return 'Appareil ($example)';
  }

  @override
  String get settingsTime12 => '12 h';

  @override
  String get settingsTime24 => '24 h';

  @override
  String get settingsPlanning => 'Planification';

  @override
  String get settingsDefaultDuration => 'Durée par défaut';

  @override
  String get settingsSnap => 'Aimanter à';

  @override
  String settingsSnapValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsShiftLater => 'Décaler les tâches suivantes';

  @override
  String get settingsShiftAsk => 'Demander à chaque fois';

  @override
  String get settingsShiftAlways => 'Toujours';

  @override
  String get settingsShiftNever => 'Jamais';

  @override
  String get settingsShowFree => 'Afficher le temps libre';

  @override
  String get settingsShowFreeDetail => 'Espaces en pointillés sur le fil';

  @override
  String get settingsLateNudge => 'Rappel en cas de retard';

  @override
  String get settingsLateNudgeDetail =>
      'Proposer de décaler la suite de la journée';

  @override
  String get settingsRoll => 'Reporter le reste à demain';

  @override
  String get settingsRollDetail => 'Sinon, retour dans la boîte de réception';

  @override
  String get settingsReminders => 'Rappels';

  @override
  String get settingsTaskStarts => 'Début de tâche';

  @override
  String get settingsAlertNone => 'Pas d\'alerte';

  @override
  String get settingsAlertAtStart => 'Au début';

  @override
  String settingsAlertBefore(int minutes) {
    return '$minutes min avant';
  }

  @override
  String get settingsBedtimeReminder => 'Rappel du coucher';

  @override
  String settingsBedtimeReminderDetail(String time) {
    return 'À $time, avec la première tâche de demain';
  }

  @override
  String get settingsLook => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeSystem => 'Comme l\'appareil';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsAccent => 'Accent';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsData => 'Données';

  @override
  String get settingsTrash => 'Corbeille';

  @override
  String get settingsTrashDetail => 'Les tâches supprimées restent 30 jours';

  @override
  String get settingsTrashEmpty => 'La corbeille est vide';

  @override
  String get settingsRestore => 'Restaurer';

  @override
  String settingsRestored(String title) {
    return '$title restaurée';
  }

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsWhatsNew => 'Nouveautés';

  @override
  String changelogVersion(String version) {
    return 'Version $version';
  }

  @override
  String changelogInstalled(String version) {
    return 'Version $version · sur cet appareil';
  }

  @override
  String get changelogIntro =>
      'Ce qui a changé dans chaque version de Dottoday.';

  @override
  String get releaseNotes010 =>
      'Planifiez votre journée sur un seul fil : faites glisser une tâche pour la déplacer, tirez son bord pour changer sa durée et décalez toute la suite d\'un seul geste.\nAjoutez une tâche en deux touchers, saisissez les heures en langage courant ou collez une liste pour en ajouter plusieurs.\nTâches récurrentes, rappels à l\'avance et vos calendriers sur le fil — tout est gratuit.\nSynchronisation entre iPhone, Android, Mac et le web, avec un état visible et rien de perdu.\nExportez tout en JSON, CSV ou fichier de calendrier, et restaurez une sauvegarde.\nEnvoyez un avis depuis les réglages et découvrez les nouveautés ici après chaque mise à jour.';

  @override
  String whatsNewBanner(String version) {
    return 'Dottoday $version est arrivé';
  }

  @override
  String get whatsNewOpen => 'Voir les nouveautés';

  @override
  String get settingsFeedback => 'Envoyer un avis';

  @override
  String get settingsFeedbackIntro =>
      'Ouvre un brouillon dans votre app de messagerie ; vous l\'envoyez depuis là. Le contenu de vos tâches n\'est jamais inclus.';

  @override
  String get settingsFeedbackDiagnostics => 'Ajouter des diagnostics';

  @override
  String get settingsFeedbackDiagnosticsHint =>
      'Version de l\'app, type d\'appareil, état de la synchro et nombre de tâches — jamais leur contenu.';

  @override
  String get settingsFeedbackDiagnosticsFailed =>
      'Impossible de lire les diagnostics : l\'e-mail partira sans eux.';

  @override
  String get settingsFeedbackPreview => 'Ajouté à la fin de votre e-mail :';

  @override
  String get settingsFeedbackWrite => 'Écrire l\'e-mail';

  @override
  String get settingsFeedbackSubject => 'Avis sur Dottoday';

  @override
  String get settingsFeedbackNoMail =>
      'Aucune app de messagerie n\'est configurée sur cet appareil.';

  @override
  String settingsAccentLabel(String name) {
    return 'Accent $name';
  }

  @override
  String get dayCardYesterdaySuffix => ' · Hier';

  @override
  String get dayCardTomorrowSuffix => ' · Demain';

  @override
  String spreadDoneOf(int done, int total) {
    return '$done sur $total';
  }

  @override
  String spreadPlanned(int count) {
    return '$count prévues';
  }

  @override
  String spreadSubtitle(String date, int done, int total) {
    return '$date · $done sur $total faites';
  }

  @override
  String get spreadPreviousDay => 'Jour précédent';

  @override
  String get spreadNextDay => 'Jour suivant';

  @override
  String get spreadDropToPlan => 'déposer ici pour planifier';

  @override
  String spreadDropToPlanLabel(String day) {
    return 'Déposez une tâche ici pour la planifier le $day';
  }

  @override
  String threadDropInbox(String duration) {
    return '$duration libre · déposez une tâche de la boîte de réception';
  }

  @override
  String get runningLate => 'Je suis en retard';

  @override
  String runningLateBy(int minutes) {
    return '+$minutes min';
  }

  @override
  String snackRunningLate(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches décalées de $minutes min',
      one: '1 tâche décalée de $minutes min',
      zero: 'Plus rien à déplacer',
    );
    return '$_temp0';
  }

  @override
  String snackRunningLatePartial(int count, int minutes, String pinned) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches décalées de $minutes min',
      one: '1 tâche décalée de $minutes min',
    );
    return '$_temp0 · $pinned ne bouge pas';
  }

  @override
  String get spreadNothing => 'Rien de prévu';

  @override
  String threadFreeFits(String duration, String title) {
    return '$duration libre · $title y tient';
  }

  @override
  String inboxFitsToday(String time) {
    return 'Tient aujourd\'hui $time';
  }

  @override
  String inboxFitsDay(String day, String time) {
    return 'Tient $day $time';
  }

  @override
  String get inboxFitsNone => 'Pas de place cette semaine';

  @override
  String inboxAddedMeta(String duration, String when) {
    return '$duration · ajoutée $when';
  }

  @override
  String get inboxAddedToday => 'aujourd\'hui';

  @override
  String get inboxAddedYesterday => 'hier';

  @override
  String inboxSortLabel(String order) {
    return 'Tri : $order';
  }

  @override
  String get inboxSortAdded => 'ajout';

  @override
  String get inboxSortDuration => 'durée';

  @override
  String get inboxSortFit => 'premier créneau';

  @override
  String get inboxAutoPlan => 'Planifier la semaine';

  @override
  String snackAutoPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches planifiées cette semaine',
      one: '1 tâche planifiée cette semaine',
      zero: 'Rien ne tient cette semaine',
    );
    return '$_temp0';
  }

  @override
  String snackAutoPlannedPartial(int count, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches planifiées',
      one: '1 tâche planifiée',
    );
    return '$_temp0 · $left encore dans la boîte de réception';
  }

  @override
  String get inboxDropToday => 'Déposer sur aujourd\'hui';

  @override
  String inboxDropTodayFree(String duration) {
    return '$duration libre';
  }

  @override
  String inboxDropHint(String keys) {
    return 'Faites glisser une tâche sur un espace en pointillés, ou appuyez sur $keys sur une ligne pour la placer dans le premier créneau qui convient.';
  }

  @override
  String inboxUnscheduledCount(int count) {
    return '$count non planifiées';
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
    return '$planned prévu sur $awake éveillé';
  }

  @override
  String weekBusiest(String day, String planned) {
    return 'Plus chargé · $day · $planned';
  }

  @override
  String weekLightest(String day, String planned) {
    return 'Plus léger · $day · $planned';
  }

  @override
  String weekFree(String free) {
    return 'Libre · $free non planifié';
  }

  @override
  String weekDone(int done, int total) {
    return 'Fait · $done sur $total';
  }

  @override
  String get weekBusiestTag => 'Plus chargé';

  @override
  String get weekLightestTag => 'Plus léger';

  @override
  String get weekTitle => 'Cette semaine';

  @override
  String weekSubtitle(String range, int done, int total, String planned) {
    return '$range · $done sur $total faites · $planned prévu';
  }

  @override
  String weekDayFree(String free) {
    return '$free libre';
  }

  @override
  String weekTodayDay(String day) {
    return '$day · aujourd\'hui';
  }

  @override
  String get weekViewWeek => 'Semaine';

  @override
  String get weekViewMonth => 'Mois';

  @override
  String get weekToday => 'Aujourd\'hui';

  @override
  String weekDropHere(String free) {
    return 'Déposez une tâche ici · $free';
  }

  @override
  String weekDropAt(String day, String range) {
    return '$day · $range';
  }

  @override
  String weekCardLeft(int minutes) {
    return '$minutes min restantes';
  }

  @override
  String weekCardSkipped(String range) {
    return '$range · passée';
  }

  @override
  String weekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String monthStats(int done, int missed, int ahead) {
    return '$done faites · $missed pas faites · $ahead à venir';
  }

  @override
  String monthStatsBusiest(String stats, String day) {
    return '$stats · jour le plus chargé $day';
  }

  @override
  String get editorClose => 'Fermer';

  @override
  String get editorEscKey => 'esc';

  @override
  String get shortcutsTitle => 'Raccourcis clavier';

  @override
  String get shortcutsEverywhere => 'Partout';

  @override
  String get shortcutsTodaySection => 'Aujourd\'hui';

  @override
  String get shortcutsWeekMonth => 'Semaine et mois';

  @override
  String get shortcutsInbox => 'Boîte de réception';

  @override
  String get shortcutsEditor => 'Modifier une tâche';

  @override
  String get shortcutAdd => 'Ajouter une tâche';

  @override
  String get shortcutGoToday => 'Aller à Aujourd\'hui';

  @override
  String get shortcutGoInbox => 'Aller à la boîte de réception';

  @override
  String get shortcutGoWeek => 'Aller à Semaine';

  @override
  String get shortcutGoMonth => 'Aller à Mois';

  @override
  String get shortcutShowKeys => 'Afficher ces raccourcis';

  @override
  String get shortcutPrevDay => 'Jour précédent';

  @override
  String get shortcutNextDay => 'Jour suivant';

  @override
  String get shortcutBackToday => 'Revenir à aujourd\'hui';

  @override
  String get shortcutDoneLive => 'Marquer la tâche en cours comme faite';

  @override
  String get shortcutPrevPeriod => 'Semaine ou mois précédent';

  @override
  String get shortcutNextPeriod => 'Semaine ou mois suivant';

  @override
  String get shortcutThisPeriod => 'Cette semaine ou ce mois';

  @override
  String get shortcutPlaceFirst =>
      'Placer la tâche sélectionnée dans son premier créneau libre';

  @override
  String get shortcutAutoPlan => 'Planifier la semaine';

  @override
  String get shortcutSave => 'Enregistrer et fermer';

  @override
  String get shortcutDone => 'Marquer comme fait';

  @override
  String get shortcutClose => 'Fermer';

  @override
  String get repeatTitle => 'Répéter';

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count jours',
      one: 'Tous les jours',
    );
    return '$_temp0';
  }

  @override
  String get repeatEveryWeekday => 'Chaque jour de semaine';

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toutes les $count semaines',
      one: 'Chaque semaine',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeksOn(int count, String days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toutes les $count semaines le $days',
      one: 'Chaque semaine le $days',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonthsOnDay(int count, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count mois le $day',
      one: 'Chaque mois le $day',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonthsOnNth(int count, String nth, String weekday) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count mois le $nth $weekday',
      one: 'Chaque mois le $nth $weekday',
    );
    return '$_temp0';
  }

  @override
  String repeatNth(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '1': 'premier',
      '2': 'deuxième',
      '3': 'troisième',
      '4': 'quatrième',
      'other': 'dernier',
    });
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count ans',
      one: 'Chaque année',
    );
    return '$_temp0';
  }

  @override
  String repeatTimes(String summary, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois',
      one: 'une fois',
    );
    return '$summary · $_temp0';
  }

  @override
  String repeatUntil(String summary, String date) {
    return '$summary · jusqu\'au $date';
  }

  @override
  String get repeatChoiceDaily => 'Tous les jours';

  @override
  String get repeatChoiceWeekly => 'Chaque semaine';

  @override
  String get repeatChoiceMonthly => 'Chaque mois';

  @override
  String get repeatChoiceYearly => 'Chaque année';

  @override
  String get repeatChoiceCustom => 'Personnalisé';

  @override
  String repeatOnDay(int day) {
    return 'Le $day';
  }

  @override
  String repeatOnNth(String nth, String weekday) {
    return 'Le $nth $weekday';
  }

  @override
  String get repeatEvery => 'Tous les';

  @override
  String repeatUnitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'jours',
      one: 'jour',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'semaines',
      one: 'semaine',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mois',
      one: 'mois',
    );
    return '$_temp0';
  }

  @override
  String get repeatIntervalLess => 'Moins';

  @override
  String get repeatIntervalMore => 'Plus';

  @override
  String get repeatEnds => 'Fin';

  @override
  String get repeatEndsNever => 'Jamais';

  @override
  String get repeatEndsAfter => 'Après';

  @override
  String get repeatEndsOn => 'À une date';

  @override
  String repeatEndsAfterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois',
      one: '1 fois',
    );
    return '$_temp0';
  }

  @override
  String get repeatDone => 'OK';

  @override
  String get scopeTitleEdit => 'Modifier lesquelles ?';

  @override
  String get scopeTitleDelete => 'Supprimer lesquelles ?';

  @override
  String get scopeThis => 'Celle-ci';

  @override
  String get scopeFollowing => 'Celle-ci et les suivantes';

  @override
  String get scopeAll => 'Toutes';

  @override
  String get scopeAllDetail => 'Les précédentes restent inchangées';

  @override
  String snackSeriesChanged(String title) {
    return '$title modifiée';
  }

  @override
  String snackSeriesDeleted(String title) {
    return '$title supprimée';
  }

  @override
  String snackRepeatSet(String title, String summary) {
    return '$title se répète $summary';
  }

  @override
  String snackRepeatStopped(String title) {
    return '$title ne se répète plus';
  }

  @override
  String get alertsTitle => 'Alertes';

  @override
  String get alertsAdd => 'Ajouter une alerte';

  @override
  String get alertsMax => 'Jusqu\'à 5 alertes';

  @override
  String alertsRemove(String alert) {
    return 'Retirer $alert';
  }

  @override
  String get alertsBedtime => 'Rappel du coucher';

  @override
  String get alertsBedtimeDetail =>
      'Chaque soir, avec la première tâche de demain';

  @override
  String get alertsDone => 'OK';

  @override
  String snackAlertsSaved(String title) {
    return 'Alertes de $title mises à jour';
  }

  @override
  String subtaskRemove(String title) {
    return 'Retirer $title';
  }

  @override
  String subtaskReorder(String title) {
    return 'Réordonner $title';
  }

  @override
  String get subtaskMoveUp => 'Monter';

  @override
  String get subtaskMoveDown => 'Descendre';

  @override
  String subtaskRename(String title) {
    return 'Renommer $title';
  }

  @override
  String get subtaskNow => 'maintenant';

  @override
  String get subtaskEveryTime => 'Utiliser cette liste à chaque fois';

  @override
  String snackSubtaskRemoved(String title) {
    return '$title retirée';
  }

  @override
  String snackListEveryTime(String title) {
    return '$title aura cette liste à chaque fois';
  }

  @override
  String get colourIconTitle => 'Couleur et icône';

  @override
  String get colourIconDone => 'OK';

  @override
  String get iconSearchHint => 'Rechercher des icônes';

  @override
  String iconSearchEmpty(String query) {
    return 'Aucune icône pour « $query »';
  }

  @override
  String get subtaskRenameTitle => 'Renommer la sous-tâche';

  @override
  String get subtaskRenameSave => 'Renommer';

  @override
  String editorZone(String city) {
    return 'Fuseau horaire · $city';
  }

  @override
  String get todayMenuLate => 'Je suis en retard…';

  @override
  String get todayMenuReview => 'Faire le point sur la journée';

  @override
  String get lateAmount => 'De combien en retard';

  @override
  String get lateShiftRest => 'Décaler la suite';

  @override
  String lateShiftPreview(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches décalées de $minutes min',
      one: '1 tâche décalée de $minutes min',
      zero: 'Plus rien à déplacer',
    );
    return '$_temp0';
  }

  @override
  String lateShiftPreviewPartial(int count, int minutes, String pinned) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches décalées de $minutes min',
      one: '1 tâche décalée de $minutes min',
    );
    return '$_temp0 · $pinned ne bouge pas';
  }

  @override
  String lateSkip(String title) {
    return 'Passer “$title”';
  }

  @override
  String get lateSkipDetail => 'Libère son créneau ; rien d\'autre ne bouge';

  @override
  String lateShorten(String title) {
    return 'Raccourcir “$title”';
  }

  @override
  String lateShortenDetail(int minutes, String end) {
    return 'Commence $minutes min plus tard, finit toujours à $end';
  }

  @override
  String lateShortenTooShort(int minutes) {
    return 'Trop courte pour perdre $minutes min';
  }

  @override
  String get lateNothingLeft => 'Plus rien aujourd\'hui';

  @override
  String snackSkippedTask(String title) {
    return '“$title” passée';
  }

  @override
  String snackShortened(String title, int minutes) {
    return '“$title” commence $minutes min plus tard';
  }

  @override
  String get reviewTitle => 'Bilan de la journée';

  @override
  String reviewSummary(int done, int total) {
    return '$done sur $total faites';
  }

  @override
  String get reviewAskTomorrow => 'Déplacer le reste à demain ?';

  @override
  String get reviewAskInbox => 'Envoyer le reste dans la boîte de réception ?';

  @override
  String reviewMoveTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Déplacer $count tâches à demain',
      one: 'Déplacer 1 tâche à demain',
    );
    return '$_temp0';
  }

  @override
  String reviewSendInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Envoyer $count tâches dans la boîte',
      one: 'Envoyer 1 tâche dans la boîte',
    );
    return '$_temp0';
  }

  @override
  String reviewStaying(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count autres restent : elles se répètent ou viennent d\'un calendrier',
      one: '1 autre reste : elle se répète ou vient d\'un calendrier',
    );
    return '$_temp0';
  }

  @override
  String get reviewAllDone => 'Plus rien à déplacer';

  @override
  String snackRolled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches déplacées à demain',
      one: '1 tâche déplacée à demain',
    );
    return '$_temp0';
  }

  @override
  String snackSentToInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches envoyées dans la boîte de réception',
      one: '1 tâche envoyée dans la boîte de réception',
    );
    return '$_temp0';
  }

  @override
  String get promptNotNow => 'Pas maintenant';

  @override
  String get lateNudgeTitle => 'Besoin de plus de temps ?';

  @override
  String lateNudgeDetail(String title, int minutes) {
    return '“$title” s\'est terminée il y a $minutes min';
  }

  @override
  String get lateNudgeAction => 'Réajuster';

  @override
  String get todayMenuDuplicate => 'Dupliquer la journée…';

  @override
  String get todayMenuCopyText => 'Copier la journée en texte';

  @override
  String get duplicateDayTitle => 'Copier vers quel jour ?';

  @override
  String get snackDayCopied => 'Journée copiée en texte';

  @override
  String inboxDoneOn(String date) {
    return 'Faite le $date';
  }

  @override
  String inboxNotDone(String title) {
    return 'Marquer “$title” comme pas fait';
  }

  @override
  String get inboxClearCompleted => 'Effacer les faites';

  @override
  String snackBackInInbox(String title) {
    return '“$title” est de retour dans la boîte de réception';
  }

  @override
  String snackClearedCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches faites mises à la corbeille',
      one: '1 tâche faite mise à la corbeille',
    );
    return '$_temp0';
  }

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsCalendars => 'Calendriers';

  @override
  String get settingsCalendarsDetail => 'Événements sur votre fil';

  @override
  String get settingsExport => 'Exporter';

  @override
  String get settingsExportDetail => 'Vos données, librement';

  @override
  String get settingsHelp => 'Aide';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsAboutApp => 'À propos de Dottoday';

  @override
  String get settingsBack => 'Retour aux réglages';

  @override
  String get accountProfile => 'Profil';

  @override
  String get accountName => 'Nom';

  @override
  String get accountNameNone => 'Non défini';

  @override
  String get accountNameTitle => 'Votre nom';

  @override
  String get accountNameSave => 'Enregistrer';

  @override
  String get accountSync => 'Synchronisation';

  @override
  String get accountLocalBody =>
      'Tout est sur cet appareil. Connectez-vous pour synchroniser vos appareils et garder une copie en sécurité.';

  @override
  String get accountApple => 'Continuer avec Apple';

  @override
  String get accountGoogle => 'Continuer avec Google';

  @override
  String get accountEmail => 'Continuer avec un e-mail';

  @override
  String get accountComingSoon =>
      'La connexion arrivera avec la synchronisation dans une prochaine mise à jour. D\'ici là, rien ne quitte cet appareil.';

  @override
  String accountSignedInAs(String email) {
    return 'Connecté en tant que $email';
  }

  @override
  String get accountSignOut => 'Se déconnecter';

  @override
  String get accountSignOutEverywhere => 'Se déconnecter partout';

  @override
  String get accountDelete => 'Supprimer le compte';

  @override
  String get accountDeleteTitle => 'Supprimer votre compte ?';

  @override
  String get accountDeleteExportFirst => 'Exporter d\'abord mes données';

  @override
  String accountDeleteBody(String word) {
    return 'Cela supprime votre compte et tout ce qui y est synchronisé. Les tâches sur cet appareil restent. Saisissez $word pour confirmer.';
  }

  @override
  String get accountDeleteWord => 'SUPPRIMER';

  @override
  String get calendarsIntro =>
      'Vos événements de calendrier sur le fil, à côté de vos tâches. Gratuit, toujours.';

  @override
  String get calendarsConnected => 'Connectés';

  @override
  String get calendarsNone => 'Aucun calendrier connecté';

  @override
  String get calendarsConnect => 'Connecter un calendrier';

  @override
  String get calendarsOnlineInSettings =>
      'Connectez Google ou Microsoft dans Réglages › Calendriers.';

  @override
  String get calendarsOnline => 'Google et Microsoft';

  @override
  String get calendarsOnlineIntro =>
      'Connectés une fois, ils s\'affichent sur tous les appareils où vous êtes connecté. Si un calendrier est aussi sur cet appareil, désactivez l\'un des deux.';

  @override
  String get calendarsOnlineSignIn =>
      'Connectez-vous pour ajouter Google ou Microsoft';

  @override
  String get calendarsConnectGoogle => 'Connecter Google Agenda';

  @override
  String get calendarsConnectMicrosoft => 'Connecter Microsoft Outlook';

  @override
  String get calendarsReconnect => 'Reconnecter';

  @override
  String get calendarsReconnectDetail =>
      'Dottoday ne peut pas accéder à ce compte tant que vous ne l\'avez pas reconnecté';

  @override
  String get calendarsUnreachable =>
      'Impossible de joindre ce compte pour le moment';

  @override
  String get calendarsDisconnect => 'Déconnecter';

  @override
  String calendarsDisconnectTitle(String account) {
    return 'Déconnecter $account ?';
  }

  @override
  String get calendarsDisconnectBody =>
      'Ses événements quittent votre fil sur tous vos appareils. Les événements avec vos sous-tâches ou notes vont à la corbeille.';

  @override
  String get calendarsShifting => 'Quand la journée se décale';

  @override
  String get calendarsMoveEvents => 'Déplacer aussi les événements';

  @override
  String get calendarsMoveEventsDetail =>
      'Quand vous décalez la suite. Les événements partagés et récurrents ne bougent pas.';

  @override
  String get calendarsAsk =>
      'Dottoday demande une seule fois à votre appareil l\'accès à vos calendriers. Vous choisissez ensuite lesquels afficher.';

  @override
  String get calendarsOnDevice => 'Sur cet appareil';

  @override
  String get calendarsNoneOnDevice => 'Aucun calendrier sur cet appareil';

  @override
  String get calendarsReadOnly => 'Lecture seule';

  @override
  String get calendarsPickInSettings =>
      'Connecté · choisissez les calendriers dans les réglages';

  @override
  String get calendarDeniedTitle => 'L\'accès au calendrier est désactivé';

  @override
  String get calendarDeniedBody =>
      'Dottoday ne peut pas afficher vos événements tant que l\'accès au calendrier n\'est pas autorisé dans les réglages de l\'appareil.';

  @override
  String get calendarSettingsPath =>
      'Ouvrez les réglages de votre appareil, trouvez Dottoday et autorisez l\'accès aux calendriers.';

  @override
  String get exportIntro =>
      'Vos tâches vous appartiennent. L\'export est gratuit, toujours, avec ou sans compte.';

  @override
  String get exportFormats => 'Formats';

  @override
  String get exportJson => 'Tout (JSON)';

  @override
  String get exportJsonDetail => 'Une copie complète à restaurer';

  @override
  String get exportCsv => 'Tâches (CSV)';

  @override
  String get exportCsvDetail => 'S\'ouvre dans n\'importe quel tableur';

  @override
  String get exportIcs => 'Calendrier (.ics)';

  @override
  String get exportIcsDetail => 'Pour d\'autres apps de calendrier';

  @override
  String get exportPlain =>
      'Les fichiers exportés ne sont pas chiffrés : toute personne qui a le fichier peut lire vos tâches. Les événements de calendrier importés restent dans leur calendrier et ne sont pas inclus.';

  @override
  String get exportDone => 'Exporté';

  @override
  String get exportHandOffFailed =>
      'Impossible d\'enregistrer ou de partager le fichier. Rien n\'a été modifié.';

  @override
  String get exportRestore => 'Restaurer';

  @override
  String get exportImport => 'Importer une sauvegarde…';

  @override
  String get exportImportDetail => 'Un fichier JSON exporté de Dottoday';

  @override
  String get exportImportTitle => 'Remplacer vos tâches par cette sauvegarde ?';

  @override
  String exportImportBody(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches',
      one: '1 tâche',
      zero: 'aucune tâche',
    );
    return 'Ce fichier du $date contient $_temp0. Tout ce qui est ici et n\'y figure pas va à la corbeille. Une sauvegarde de l\'état actuel est faite avant.';
  }

  @override
  String get exportImportAction => 'Remplacer';

  @override
  String get exportCancel => 'Annuler';

  @override
  String get exportImported => 'Sauvegarde importée';

  @override
  String get exportNotBackup =>
      'Ce fichier n\'est pas une sauvegarde Dottoday, ou il vient d\'une version plus récente. Rien n\'a été modifié.';

  @override
  String get exportTooLarge =>
      'Ce fichier fait plus de 25 Mo, trop pour être importé. Rien n\'a été modifié.';

  @override
  String get exportBackups => 'Sur cet appareil';

  @override
  String get exportBackupsNote =>
      'Dottoday fait une sauvegarde chaque jour (les 7 dernières) et une avant chaque import ou restauration, chiffrées, sur cet appareil uniquement.';

  @override
  String get exportBackupsNone =>
      'Pas encore de sauvegarde. La première sera faite à la prochaine ouverture de Dottoday.';

  @override
  String get exportBackupDaily => 'Sauvegarde quotidienne';

  @override
  String get exportBackupPreImport => 'Avant un import';

  @override
  String get exportBackupPreRestore => 'Avant une restauration';

  @override
  String get exportRestoreTitle => 'Revenir à cette sauvegarde ?';

  @override
  String exportRestoreBody(String date) {
    return 'Vos tâches reviennent à leur état du $date. Tout ce qui est plus récent va à la corbeille. Une sauvegarde de l\'état actuel est faite avant.';
  }

  @override
  String get exportRestoreAction => 'Restaurer';

  @override
  String get exportRestored => 'Sauvegarde restaurée';

  @override
  String get helpIntro =>
      'Des réponses rapides. Autre chose ? Envoyez un avis ci-dessous.';

  @override
  String get helpMoveQ => 'Comment déplacer une tâche ?';

  @override
  String get helpMoveA =>
      'Faites-la glisser le long du fil, ou tirez ses bords pour changer sa durée. Appui long pour en choisir plusieurs.';

  @override
  String get helpLateQ => 'Je suis en retard. Tout peut-il bouger ?';

  @override
  String get helpLateA =>
      'Oui : ⋯ › Je suis en retard décale le reste de la journée de 5, 15 ou 30 minutes, jusqu\'aux tâches épinglées. Vous pouvez aussi passer ou raccourcir la tâche en cours.';

  @override
  String get helpRepeatQ => 'Comment fonctionnent les tâches récurrentes ?';

  @override
  String get helpRepeatA =>
      'Ouvrez une tâche › Répéter. Les coches et sous-tâches appartiennent à chaque jour : la suivante repart de zéro.';

  @override
  String get helpPasteQ => 'Puis-je ajouter plusieurs tâches à la fois ?';

  @override
  String get helpPasteA =>
      'Collez une liste dans Ajouter ou dans le champ de la boîte de réception : chaque ligne devient une tâche.';

  @override
  String get helpKeysQ => 'Y a-t-il des raccourcis clavier ?';

  @override
  String get helpKeysA =>
      'Sur Mac ou dans un navigateur, appuyez sur ⌘/ (Ctrl+/ ailleurs) pour tous les voir.';

  @override
  String get privacyLocalTitle => 'Sur votre appareil';

  @override
  String get privacyLocalBody =>
      'Les tâches sont stockées chiffrées sur cet appareil, et l\'app fonctionne entièrement hors ligne.';

  @override
  String get privacyTrackTitle => 'Aucun pistage';

  @override
  String get privacyTrackBody =>
      'Pas de publicité, pas d\'analytics, pas de traceurs tiers.';

  @override
  String get privacySyncTitle => 'Quand vous vous connectez';

  @override
  String get privacySyncBody =>
      'La synchronisation envoie vos tâches par une connexion chiffrée vers votre propre compte, et nulle part ailleurs.';

  @override
  String get privacySearchTitle => 'Recherches';

  @override
  String get privacySearchBody =>
      'Les recherches récentes restent sur cet appareil et ne sont jamais synchronisées ni exportées.';

  @override
  String get privacyClearSearches => 'Effacer les recherches récentes';

  @override
  String get privacyCrashTitle => 'Rapports de plantage';

  @override
  String get privacyCrashBody =>
      'Si l\'app plante, elle envoie le type d\'erreur et l\'endroit de l\'app où elle s\'est produite. Jamais vos tâches, vos notes ni votre compte.';

  @override
  String get privacyPolicyOpen => 'Lire la politique de confidentialité';

  @override
  String get snackSearchesCleared => 'Recherches récentes effacées';

  @override
  String get aboutLicences => 'Licences open source';

  @override
  String get settingsSync => 'Synchronisation';

  @override
  String get syncTitle => 'Synchronisation';

  @override
  String get syncLocalOnlyBody =>
      'Vos tâches sont uniquement sur cet appareil. Connectez-vous pour les synchroniser entre vos appareils.';

  @override
  String get syncSignIn => 'Se connecter…';

  @override
  String get syncJustNow => 'Synchronisé à l\'instant';

  @override
  String syncMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Synchronisé il y a $minutes min',
      one: 'Synchronisé il y a 1 min',
    );
    return '$_temp0';
  }

  @override
  String syncAt(String when) {
    return 'Synchronisé $when';
  }

  @override
  String get syncNever => 'Pas encore synchronisé';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifications en attente de synchronisation',
      one: '1 modification en attente de synchronisation',
      zero: 'Rien en attente de synchronisation',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Synchroniser';

  @override
  String get syncStateSynced => 'À jour';

  @override
  String get syncStateSyncing => 'Synchronisation…';

  @override
  String get syncStateOffline =>
      'Hors ligne. Les modifications sont enregistrées ici et se synchroniseront à votre retour.';

  @override
  String get syncStateError =>
      'Impossible de synchroniser. Vos modifications sont en sécurité ici ; nouvel essai bientôt.';

  @override
  String get syncConflicts => 'Modifié sur deux appareils';

  @override
  String get syncConflictHint =>
      'La modification de l\'autre appareil est utilisée tant que vous n\'avez pas choisi.';

  @override
  String syncConflictField(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'Le titre',
      'start': 'L\'heure',
      'duration': 'La durée',
      'notes': 'Les notes',
      'colour': 'La couleur',
      'status': 'Fait ou non',
      'other': 'Un détail',
    });
    return '$_temp0';
  }

  @override
  String syncMine(String value) {
    return 'Cet appareil : $value';
  }

  @override
  String syncTheirs(String value) {
    return 'Autre appareil : $value';
  }

  @override
  String get syncKeepMine => 'Garder la mienne';

  @override
  String get syncKeepTheirs => 'Garder l\'autre';

  @override
  String get bannerOffline => 'Hors ligne · tout fonctionne encore ici';

  @override
  String bannerConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifications attendent votre choix',
      one: '1 modification attend votre choix',
    );
    return '$_temp0';
  }

  @override
  String get bannerReview => 'Voir';

  @override
  String get notifDeniedTitle => 'Les notifications sont désactivées';

  @override
  String get notifDeniedBody =>
      'Dottoday ne peut pas vous rappeler quoi que ce soit tant que les notifications ne sont pas autorisées dans les réglages de l\'appareil.';

  @override
  String get notifOpenSettings => 'Ouvrir les réglages';

  @override
  String get notifSettingsPath =>
      'Ouvrez Réglages › Notifications › Dottoday sur votre appareil et autorisez les notifications.';

  @override
  String syncSummary(String last, String pending) {
    return '$last · $pending';
  }

  @override
  String syncConflictHeading(String title, String field) {
    return '$title · $field';
  }

  @override
  String get recoveryLockedTitle => 'Dottoday ne peut pas ouvrir vos tâches';

  @override
  String get recoveryLockedBody =>
      'Vos tâches sur cet appareil sont verrouillées par une clé absente ou modifiée. Cela peut arriver après la restauration d\'un appareil ou l\'effacement de son trousseau.';

  @override
  String get recoveryFreshBody =>
      'Repartir de zéro met l\'ancien fichier de côté (il n\'est jamais supprimé) et ouvre un planning vide. Vos tâches reviennent quand vous vous connectez pour synchroniser, ou en important un export.';

  @override
  String get recoveryStartFresh => 'Repartir de zéro';

  @override
  String get recoveryConfirm =>
      'Commencer avec un planning vide ? L\'ancien fichier reste sur cet appareil.';

  @override
  String get recoveryConfirmYes => 'Oui, repartir de zéro';

  @override
  String recoveryKept(String where) {
    return 'Votre ancien fichier est conservé ici : $where';
  }

  @override
  String get recoveryTabTitle => 'Dottoday est ouvert dans un autre onglet';

  @override
  String get recoveryTabBody =>
      'Pour protéger vos tâches, un seul onglet peut les utiliser à la fois.';

  @override
  String get recoveryUseHere => 'L\'utiliser ici';

  @override
  String get recoveryMovedTitle => 'Dottoday est passé dans un autre onglet';

  @override
  String get recoveryMovedBody =>
      'Vous avez choisi d\'utiliser Dottoday dans un autre onglet. Vos tâches sont enregistrées.';

  @override
  String get recoveryNoAnswer =>
      'L\'autre onglet n\'a pas répondu. Fermez-le et réessayez.';

  @override
  String get recoveryContinue => 'Continuer';

  @override
  String get stateLoading => 'Chargement';

  @override
  String get stateErrorTitle => 'Impossible de charger';

  @override
  String get stateErrorSafe => 'Vos tâches sont en sécurité sur cet appareil.';

  @override
  String get stateRetry => 'Réessayer';

  @override
  String get stateReadFailed =>
      'Impossible de lire vos tâches sur cet appareil.';

  @override
  String get inboxSelect => 'Sélectionner';

  @override
  String get inboxPlanThese => 'Planifier';

  @override
  String inboxSelectedLabel(String title) {
    return '$title, sélectionnée';
  }

  @override
  String get onboardingWelcomeTitle => 'Votre journée, comme un fil.';

  @override
  String get onboardingWelcomeBody =>
      'Planifiez votre journée en points sur une ligne, voyez où passe le temps, et déplacez tout quand la journée bouge.';

  @override
  String get onboardingAgeNote =>
      'Dottoday s\'adresse aux personnes de 13 ans et plus.';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingSignIn => 'J\'ai déjà un compte';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingBack => 'Retour';

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String onboardingStepOf(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get onboardingDotLabel => 'Le point du jour, qui se dessine';

  @override
  String get onboardingDayShapeTitle =>
      'Quand commence et finit votre journée ?';

  @override
  String get onboardingDayShapeBody =>
      'Vos tâches se placent entre ces deux heures. Vous pouvez les changer, ou en définir pour chaque jour, dans les réglages.';

  @override
  String get onboardingHabitsTitle => 'Qu\'est-ce qui remplit vos journées ?';

  @override
  String get onboardingHabitsBody =>
      'Choisissez-en jusqu\'à cinq. Elles iront sur le fil de demain, à des heures adaptées ; modifiables à tout moment.';

  @override
  String onboardingHabitsAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count à demain',
      one: 'Ajouter 1 à demain',
    );
    return '$_temp0';
  }

  @override
  String get onboardingHabitsMax => 'Cinq, c\'est bien assez pour commencer.';

  @override
  String get starterMorningRun => 'Course du matin';

  @override
  String get starterDeepWork => 'Travail concentré';

  @override
  String get starterLunch => 'Déjeuner';

  @override
  String get starterWalk => 'Marche';

  @override
  String get starterGym => 'Sport';

  @override
  String get starterRead => 'Lecture';

  @override
  String get starterPlanTomorrow => 'Planifier demain';

  @override
  String onboardingHabitMeta(String time, String length) {
    return '$time · $length';
  }

  @override
  String get onboardingRemindersTitle => 'Envie d\'un rappel ?';

  @override
  String get onboardingRemindersBody =>
      'Dottoday vous rappelle le début d\'une tâche et l\'heure du coucher. Vous pouvez changer cela à tout moment dans les réglages.';

  @override
  String get onboardingTaskStarts => 'Avant chaque tâche';

  @override
  String get onboardingTaskStartsDetail =>
      'Combien de temps avant, à vous de voir dans les réglages';

  @override
  String get onboardingBedtime => 'Au coucher';

  @override
  String get onboardingBedtimeDetail =>
      'La première tâche de demain, pour un matin sans surprise';

  @override
  String get onboardingAllow => 'Autoriser les notifications';

  @override
  String get onboardingNotNow => 'Pas maintenant';

  @override
  String get onboardingAccountTitle => 'Synchroniser vos tâches ?';

  @override
  String get onboardingAccountBody =>
      'Connectez-vous pour utiliser Dottoday sur tous vos appareils avec une copie en sécurité. Ou pas : tout fonctionne sur cet appareil sans compte.';

  @override
  String get onboardingWithoutAccount => 'Continuer sans compte';

  @override
  String get onboardingDoneTitle => 'Votre premier fil';

  @override
  String get onboardingDoneBody =>
      'Demain, du réveil au coucher. Ajoutez des tâches, déplacez-les, ou commencez par aujourd\'hui.';

  @override
  String get onboardingDoneEmpty =>
      'Demain, du réveil au coucher, est à vous. Ajoutez la première tâche quand vous voulez.';

  @override
  String get onboardingOpenToday => 'Ouvrir aujourd\'hui';

  @override
  String get onboardingTomorrow => 'Demain';

  @override
  String get onboardingWelcomeBackTitle => 'Bon retour';

  @override
  String get onboardingWelcomeBackBody =>
      'Connectez-vous pour retrouver vos tâches sur cet appareil.';

  @override
  String get accountEmailLabel => 'E-mail';

  @override
  String get accountSendLink => 'M\'envoyer un lien';

  @override
  String get accountOtherWays => 'Autres façons de se connecter';

  @override
  String get accountEmailInvalid =>
      'Cela ne ressemble pas à une adresse e-mail.';

  @override
  String get accountCheckMailTitle => 'Consultez vos e-mails';

  @override
  String accountCheckMailBody(String email) {
    return 'Nous avons envoyé un lien de connexion à $email. Ouvrez-le sur cet appareil pour continuer.';
  }

  @override
  String get accountResend => 'Renvoyer';

  @override
  String get accountOtherEmail => 'Utiliser une autre adresse';

  @override
  String get accountErrorTitle => 'Impossible de se connecter';

  @override
  String get accountRestoring => 'Récupération de vos tâches sur cet appareil…';

  @override
  String accountRestoreCount(int done, int total) {
    return '$done sur $total';
  }

  @override
  String notifStartsIn(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return 'Commence dans $_temp0';
  }

  @override
  String get notifStartsNow => 'Commence maintenant';

  @override
  String get notifEndsNow => 'Se termine maintenant';

  @override
  String notifOverdue(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return 'Terminée il y a $_temp0. C\'est fait ?';
  }

  @override
  String get notifSnoozed => 'Rappel reporté';

  @override
  String get notifBedtimeTitle => 'Coucher';

  @override
  String notifBedtimeFirst(String title, String time) {
    return 'Demain commence par $title à $time.';
  }

  @override
  String get notifBedtimeFree => 'Rien de prévu pour demain pour l\'instant.';

  @override
  String get notifActionDone => 'Fait';

  @override
  String get notifActionSnooze => 'Reporter de 10 min';

  @override
  String get notifActionOpen => 'Ouvrir';

  @override
  String get notifChannelAlerts => 'Alertes de tâches';

  @override
  String get notifChannelAlertsDetail =>
      'Rappels avant, pendant et après vos tâches';

  @override
  String get notifChannelAlarms => 'Début de journée';

  @override
  String get notifChannelAlarmsDetail =>
      'Sonne comme une alarme pour la première tâche de la journée et au début d\'une routine';

  @override
  String get notifChannelSummary => 'Coucher';

  @override
  String get notifChannelSummaryDetail => 'Le coup d\'œil du soir sur demain';

  @override
  String inAppAlertText(String title, String detail) {
    return '$title · $detail';
  }

  @override
  String get inAppAlertLater => 'Plus tard';

  @override
  String get widgetNextUp => 'Ensuite';

  @override
  String get widgetNow => 'Maintenant';

  @override
  String widgetUntil(String time) {
    return 'jusqu\'à $time';
  }

  @override
  String get widgetNothingNext => 'Plus rien aujourd\'hui';

  @override
  String get widgetToday => 'Aujourd\'hui';

  @override
  String widgetInboxCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dans la boîte',
      one: '1 dans la boîte',
      zero: 'Boîte de réception vide',
    );
    return '$_temp0';
  }

  @override
  String get menuFile => 'Fichier';

  @override
  String get menuEdit => 'Édition';

  @override
  String get menuView => 'Présentation';

  @override
  String get menuGo => 'Aller';

  @override
  String get menuWindow => 'Fenêtre';

  @override
  String get menuSettings => 'Réglages…';

  @override
  String get menuNewTask => 'Nouvelle tâche';

  @override
  String get menuExport => 'Exporter…';

  @override
  String get menuUndo => 'Annuler';

  @override
  String get menuMonth => 'Mois';

  @override
  String get menuShortcuts => 'Raccourcis clavier';

  @override
  String get menuPreviousDay => 'Jour précédent';

  @override
  String get menuNextDay => 'Jour suivant';

  @override
  String get menuRedo => 'Rétablir';

  @override
  String get menuDelete => 'Supprimer';

  @override
  String get shortcutUndo => 'Annuler la dernière modification';

  @override
  String get shortcutRedo => 'Rétablir ce qui a été annulé';

  @override
  String get exactTitle =>
      'Les rappels peuvent arriver quelques minutes après l\'heure';

  @override
  String get exactBody =>
      'Pour économiser la batterie, Android peut retenir les rappels. Autorisez l\'heure exacte pour que chacun arrive au début de votre tâche.';

  @override
  String get exactAllow => 'Autoriser l\'heure exacte';

  @override
  String get skipToContent => 'Aller au contenu';

  @override
  String get installText =>
      'Installer Dottoday : s\'ouvre comme une app et fonctionne hors ligne';

  @override
  String get installAction => 'Installer';

  @override
  String get lockCaption => 'VERROUILLAGE';

  @override
  String get lockToggle => 'Verrouiller Dottoday';

  @override
  String get lockToggleDetail => 'Demander votre visage, empreinte ou code';

  @override
  String get lockWebTitle => 'Utilise le verrouillage de votre ordinateur';

  @override
  String get lockWebDetail =>
      'Dans un navigateur, Dottoday est aussi verrouillé que votre ordinateur. Verrouillez l\'écran quand vous vous absentez ; les tâches restent chiffrées dans ce navigateur.';

  @override
  String get lockAfter => 'Verrouiller après';

  @override
  String get lockAfterNow => 'Immédiatement';

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
  String get lockReason => 'Déverrouiller Dottoday';

  @override
  String get lockTitle => 'Dottoday est verrouillé';

  @override
  String get lockUnlock => 'Déverrouiller';

  @override
  String get lockUnavailable =>
      'Cet appareil n\'a pas de code, Dottoday ne peut donc pas se verrouiller.';

  @override
  String zoneBannerText(String city) {
    return 'Vous êtes maintenant à $city — garder les heures ou décaler ?';
  }

  @override
  String get zoneKeep => 'Garder les heures';

  @override
  String get zoneShift => 'Décaler';

  @override
  String zoneKeptSnack(String city) {
    return 'Tâches gardées à leurs heures à $city';
  }

  @override
  String zoneShiftedSnack(String city) {
    return 'Tâches décalées à l\'heure de $city';
  }

  @override
  String get syncAgoJustNow => 'à l\'instant';

  @override
  String syncAgoMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'il y a $minutes min',
      one: 'il y a 1 min',
    );
    return '$_temp0';
  }

  @override
  String syncAgoHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'il y a $hours h',
      one: 'il y a 1 h',
    );
    return '$_temp0';
  }

  @override
  String syncLineSynced(String ago) {
    return 'Synchronisé · $ago';
  }

  @override
  String get syncLineSyncing => 'Synchronisation…';

  @override
  String get syncLineOffline => 'Hors ligne · modifications enregistrées ici';

  @override
  String clockFast(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Votre horloge avance de $minutes min',
      one: 'Votre horloge avance de 1 min',
    );
    return '$_temp0 — les rappels peuvent arriver en avance';
  }

  @override
  String clockSlow(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Votre horloge retarde de $minutes min',
      one: 'Votre horloge retarde de 1 min',
    );
    return '$_temp0 — les rappels peuvent arriver après l\'heure';
  }

  @override
  String get syncClockWaiting =>
      'Les modifications de cet appareil attendent que l\'horloge soit juste ; celles de vos autres appareils arrivent toujours.';

  @override
  String get healthTitle => 'État des notifications';

  @override
  String get healthCaption => 'Cet appareil';

  @override
  String get healthIntro =>
      'Ce qui détermine si vos rappels vous parviennent sur cet appareil, lu dans ses réglages à l\'instant.';

  @override
  String get healthAllGood => 'Tout va bien';

  @override
  String get healthPermissionOk => 'Les notifications sont activées';

  @override
  String get healthPermissionOff => 'Les notifications sont désactivées';

  @override
  String get healthPermissionOffDetail =>
      'Dottoday ne peut pas vous rappeler quoi que ce soit tant que vous ne les autorisez pas.';

  @override
  String get healthExactOk => 'Les rappels arrivent à la minute près';

  @override
  String get healthExactOff =>
      'Les rappels peuvent arriver quelques minutes après l\'heure';

  @override
  String get healthExactOffDetail =>
      'Autorisez “Alarmes et rappels” pour Dottoday pour les recevoir à la minute près.';

  @override
  String get healthBatteryOk =>
      'L\'économie de batterie laisse Dottoday tranquille';

  @override
  String get healthBatteryOff =>
      'L\'économie de batterie peut retenir les rappels';

  @override
  String get healthBatteryOffDetail =>
      'Dans la liste, choisissez Dottoday puis “Ne pas optimiser”.';

  @override
  String get healthDndOff => 'Ne pas déranger est désactivé';

  @override
  String get healthDndOn => 'Ne pas déranger est activé';

  @override
  String get healthDndOnDetail =>
      'La première tâche de la journée sonne quand même ; les autres rappels arrivent en silence.';

  @override
  String get healthFocus => 'Concentration';

  @override
  String get healthFocusDetail =>
      'Les débuts de tâche sont urgents : un mode Concentration qui autorise les notifications urgentes les laisse passer.';

  @override
  String get healthPushOk => 'Les rappels arrivent même onglet fermé';

  @override
  String get healthPushOff => 'Les rappels arrivent quand Dottoday est ouvert';

  @override
  String get healthPushOffDetail =>
      'Connectez-vous et autorisez les notifications pour les recevoir aussi onglet fermé.';

  @override
  String get healthClockOk => 'Votre horloge est à l\'heure';

  @override
  String get healthClockOffDetail =>
      'Activez “Régler automatiquement” dans les réglages de date et heure.';

  @override
  String get healthFixAllow => 'Autoriser';

  @override
  String get healthFixOpen => 'Ouvrir les réglages';

  @override
  String healthToFix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points à régler',
      one: '1 point à régler',
    );
    return '$_temp0';
  }

  @override
  String get testAlarmTitle => 'Alarme de test';

  @override
  String get testAlarmBody =>
      'Elle est bien arrivée. Vos rappels arriveront aussi.';

  @override
  String get testAlarmCaption => 'Vérifier que ça marche';

  @override
  String get inAppAlertOk => 'OK';

  @override
  String get testAlarmRow => 'M\'envoyer une alarme de test';

  @override
  String get testAlarmRowDetail =>
      'Vérifier qu\'un rappel vous parvient vraiment';

  @override
  String get testAlarmExplain =>
      'Dottoday enverra une alarme de test dans 60 secondes pour que vous vérifiiez qu\'elle arrive.';

  @override
  String get testAlarmSend => 'Envoyer';

  @override
  String get testAlarmCancel => 'Annuler';

  @override
  String get testAlarmAsk => 'Elle a sonné ?';

  @override
  String get testAlarmYes => 'Oui';

  @override
  String get testAlarmNo => 'Non';

  @override
  String get testAlarmGood =>
      'Elle est bien arrivée. Vos rappels arriveront aussi.';

  @override
  String get testAlarmLookHere =>
      'Les vérifications ci-dessus montrent ce qui bloque.';

  @override
  String get testAlarmLookLater =>
      'Vous trouverez ce qui bloque dans Réglages › Rappels › État des notifications.';

  @override
  String testAlarmCountdown(int seconds) {
    return 'Sonnerie dans $seconds s…';
  }

  @override
  String get syncLinePaused =>
      'Synchro en pause · touchez Synchronisation pour savoir pourquoi';

  @override
  String settingsSynced(String name, String ago) {
    return '$name · synchronisé $ago';
  }

  @override
  String settingsSyncedNoName(String ago) {
    return 'Synchronisé $ago';
  }

  @override
  String settingsNameAndStatus(String name, String status) {
    return '$name · $status';
  }

  @override
  String get calendarEventUntitled => 'Événement sans titre';

  @override
  String get taskLinks => 'Liens';

  @override
  String taskLinkOpen(String host) {
    return 'Ouvrir $host dans le navigateur';
  }

  @override
  String get taskLinkFailed => 'Impossible d\'ouvrir ce lien';

  @override
  String get calendarsWriteBack => 'Renvoyer les modifications';

  @override
  String get calendarsWriteBackDetail =>
      'Les déplacements, changements de durée et renommages faits ici vont au calendrier, y compris les précédents. Les événements récurrents et sur toute la journée ne changent qu\'ici.';

  @override
  String bannerWriteBackPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count modifications ne sont pas encore arrivées dans votre calendrier',
      one: '1 modification n\'est pas encore arrivée dans votre calendrier',
    );
    return '$_temp0';
  }

  @override
  String bannerWriteBackClash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count événements ont aussi changé dans votre calendrier',
      one: 'Cet événement a aussi changé dans votre calendrier',
    );
    return '$_temp0';
  }

  @override
  String get bannerUseCalendars => 'Version du calendrier';

  @override
  String taskCalendarSends(String calendar) {
    return 'Les modifications retournent à $calendar';
  }

  @override
  String taskCalendarStays(String calendar) {
    return 'De $calendar · les modifications restent dans Dottoday';
  }

  @override
  String get travelTitle => 'Temps de trajet';

  @override
  String travelSuggestDetail(String place, String duration) {
    return 'À $place. Prévoir $duration avant pour y aller ?';
  }

  @override
  String travelSuggestAdd(String duration) {
    return 'Ajouter $duration avant';
  }

  @override
  String travelAdded(String title) {
    return 'Temps de trajet ajouté avant “$title”';
  }

  @override
  String get travelNone => 'Aucun';

  @override
  String travelBefore(String duration) {
    return '$duration avant';
  }

  @override
  String rowTravelMeta(String duration) {
    return '· $duration de trajet';
  }

  @override
  String rowTravel(String label, String duration) {
    return '$label, $duration de trajet avant';
  }

  @override
  String get calendarsTravel => 'Temps de trajet';

  @override
  String get calendarsTravelSuggest => 'Suggérer un temps de trajet';

  @override
  String get calendarsTravelSuggestDetail =>
      'Avant les événements avec un lieu. Calculé sur cet appareil, sans service de cartes';

  @override
  String rowFromCalendar(String label) {
    return '$label, de votre calendrier';
  }

  @override
  String get pinTitle => 'Épinglée';

  @override
  String get pinDetail => 'Reste en place quand les autres tâches se décalent';

  @override
  String threadOutsideBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches avant le réveil',
      one: '1 tâche avant le réveil',
    );
    return '$_temp0';
  }

  @override
  String threadOutsideAfter(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches après le coucher',
      one: '1 tâche après le coucher',
    );
    return '$_temp0';
  }

  @override
  String get shortcutPickTask => 'Sélectionner la tâche précédente ou suivante';

  @override
  String get shortcutNudgeTask =>
      'Avancer ou retarder les tâches sélectionnées de 5 min';

  @override
  String get shortcutNudgeTaskMore =>
      'Avancer ou retarder les tâches sélectionnées de 15 min';

  @override
  String get shortcutTrashTask =>
      'Mettre les tâches sélectionnées à la corbeille';

  @override
  String get shortcutOpenTask => 'Ouvrir la tâche sélectionnée';

  @override
  String get shortcutDoneTask => 'Marquer la tâche sélectionnée comme faite';

  @override
  String get shortcutKeyDelete => 'Suppr';

  @override
  String get shortcutKeySpace => 'Espace';

  @override
  String get editorEnergy => 'Énergie';

  @override
  String get energyLow => 'Faible';

  @override
  String get energyMedium => 'Moyenne';

  @override
  String get energyHigh => 'Élevée';

  @override
  String get editorNotesFormat =>
      '**gras**, *italique*, - listes et liens fonctionnent ici';

  @override
  String navInboxBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Boîte de réception, $count tâches',
      one: 'Boîte de réception, 1 tâche',
    );
    return '$_temp0';
  }

  @override
  String get inboxNudgeTitle => 'Planifiez votre boîte';

  @override
  String inboxNudgeDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tâches attendent dans votre boîte. Un bon moment pour leur donner une heure ?',
      one:
          '1 tâche attend dans votre boîte. Un bon moment pour lui donner une heure ?',
    );
    return '$_temp0';
  }

  @override
  String get inboxNudgeAction => 'Planifier';

  @override
  String get settingsInboxNudge => 'Rappel : planifier la boîte';

  @override
  String get settingsInboxNudgeDetail =>
      'Une fois par jour dès le réveil, si la boîte contient des tâches';

  @override
  String settingsAlertsMore(String first, int count) {
    return '$first +$count';
  }

  @override
  String get settingsSound => 'Son';

  @override
  String get settingsSoundSystem => 'Son du système';

  @override
  String get settingsSoundDetail =>
      'Pour les rappels de tâches. Touchez-en un pour l\'écouter. La première tâche de la journée garde son alarme.';

  @override
  String get soundDot => 'Point';

  @override
  String get soundChime => 'Carillon';

  @override
  String get soundBell => 'Cloche';

  @override
  String get soundRipple => 'Ondée';

  @override
  String get soundDotAlarm => 'Réveil Point';

  @override
  String get soundQuietSlip => 'Glissé';

  @override
  String get soundQuietWhisper => 'Murmure';

  @override
  String get soundQuietSoft => 'Doux';

  @override
  String get soundQuietBubble => 'Bulle';

  @override
  String get soundQuietPull => 'Tirette';

  @override
  String get soundClearLift => 'Envol';

  @override
  String get soundClearBright => 'Éclat';

  @override
  String get soundClearSmile => 'Sourire';

  @override
  String get soundClearEase => 'Détente';

  @override
  String get soundClearTurn => 'À toi';

  @override
  String get soundClearSettled => 'Posé';

  @override
  String get soundClearQuick => 'Vif';

  @override
  String get soundClearOpening => 'Ouverture';

  @override
  String get soundClearSpark => 'Étincelle';

  @override
  String get soundClearEmerge => 'Éclosion';

  @override
  String get soundClearElegant => 'Élégant';

  @override
  String get soundClearDutiful => 'Dévoué';

  @override
  String get soundClearInvolved => 'Engagé';

  @override
  String get soundClearAppear => 'Apparition';

  @override
  String get soundClearTap => 'Tapotement';

  @override
  String get soundStartMorning => 'Matin';

  @override
  String get soundStartBells => 'Cloches douces';

  @override
  String get soundStartSunrise => 'Lever du soleil';

  @override
  String get soundStartSolemn => 'Solennel';

  @override
  String get soundStartStrike => 'Frappe';

  @override
  String get soundStartSwing => 'Balancement';

  @override
  String get soundStartLovingly => 'Tendrement';

  @override
  String get soundStartGentle => 'Délicat';

  @override
  String get soundStartInsistent => 'Insistant';

  @override
  String get soundPlayRooster => 'Coq';

  @override
  String get soundPlayHorse => 'Cheval';

  @override
  String get soundPlayKnock => 'Toc-toc';

  @override
  String get soundPlayChick => 'Poussin';

  @override
  String get soundPlayFrog => 'Grenouille';

  @override
  String get soundPlayDog => 'Chien';

  @override
  String get soundPlayGulls => 'Mouettes';

  @override
  String get soundPlayDrum => 'Tambour';

  @override
  String get soundDoneSwift => 'Leste';

  @override
  String get soundDoneChecked => 'Coché';

  @override
  String get soundDoneDone => 'Fini';

  @override
  String get soundDoneFinished => 'Terminé';

  @override
  String get soundDoneSucceeded => 'Réussi';

  @override
  String get soundDoneAchieved => 'Accompli';

  @override
  String notifChannelAlarmsSound(String sound) {
    return 'Début de journée · $sound';
  }

  @override
  String get notifChannelAlertsSilent => 'Alertes de tâches · Sans son';

  @override
  String get notifGroupDots => 'Rappels des points';

  @override
  String get notifGroupStart => 'Début du jour';

  @override
  String get healthSoundsOk => 'Les sons des rappels sont activés';

  @override
  String healthSoundsMuted(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Les sons $names sont coupés dans les réglages du système',
      one: 'Le son $names est coupé dans les réglages du système',
    );
    return '$_temp0';
  }

  @override
  String get healthSoundsMutedDetail =>
      'Ouvrez les réglages de notification de Dottoday et réactivez le son.';

  @override
  String get soundsTitle => 'Sons';

  @override
  String get soundsIntro =>
      'Les rappels de tâches jouent ce son, sauf si une tâche a le sien. Touchez-en un pour l\'écouter.';

  @override
  String get soundsTaskCaption => 'Rappels de tâches';

  @override
  String get soundNone => 'Aucun';

  @override
  String get soundNoneDetail => 'S\'affiche et vibre, sans son';

  @override
  String get soundSectionQuiet => 'Discrets';

  @override
  String get soundSectionClear => 'Clairs';

  @override
  String get soundSectionPlayful => 'Ludiques';

  @override
  String get soundsMoreCaption => 'Aussi';

  @override
  String get soundsStart => 'Son de départ';

  @override
  String get soundsStartDetail =>
      'Sonne pour la première tâche de la journée et au début d\'une routine';

  @override
  String get soundsDone => 'Son de fin';

  @override
  String get soundsDoneDetail => 'Quand vous cochez une tâche';

  @override
  String get soundsInApp => 'Sons dans l\'app';

  @override
  String get soundsInAppDetail => 'Le son de fin et le tic de Concentration';

  @override
  String get soundInsistentNote =>
      'Fort et répété. Utile si les sons plus doux ne vous atteignent pas.';

  @override
  String get soundsMuted =>
      'Votre appareil est en silencieux — la vibration reste possible';

  @override
  String soundsCredit(String source, String license) {
    return 'Sons de $source ($license).';
  }

  @override
  String soundDefault(String sound) {
    return 'Par défaut · $sound';
  }

  @override
  String get soundDefaultOption => 'Par défaut';

  @override
  String get sheetSound => 'Son';

  @override
  String get settingsQuietHours => 'Heures calmes';

  @override
  String get settingsQuietHoursOff => 'Les rappels arrivent en silence la nuit';

  @override
  String settingsQuietHoursOn(String from, String until) {
    return '$from–$until : les rappels arrivent en silence. La première tâche de la journée sonne quand même.';
  }

  @override
  String get settingsQuietFrom => 'De';

  @override
  String get settingsQuietUntil => 'À';

  @override
  String get settingsDaySummary => 'Résumé du matin';

  @override
  String get settingsDaySummaryOff => 'Désactivé';

  @override
  String get settingsDaySummaryDetail =>
      'Au réveil les jours choisis : « Votre journée : 6 blocs, le premier à 08:00 ».';

  @override
  String get notifDaySummaryTitle => 'Votre journée';

  @override
  String notifDaySummaryBody(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blocs, le premier à $time',
      one: '1 bloc, à $time',
    );
    return '$_temp0';
  }

  @override
  String notifChannelAlertsSound(String sound) {
    return 'Alertes de tâches · $sound';
  }

  @override
  String liveActivityLeft(String time) {
    return 'encore $time';
  }

  @override
  String liveActivityStartsIn(String time) {
    return 'commence dans $time';
  }

  @override
  String liveActivityCount(int done, int total) {
    return '$done sur $total';
  }

  @override
  String liveActivityCountLabel(int done, int total) {
    return '$done sur $total faites aujourd\'hui';
  }

  @override
  String get privacyThinkingTitle => 'Aide à la réflexion';

  @override
  String get privacyThinkingBody =>
      '« Découper » et les suggestions sont calculés sur cet appareil : Apple Intelligence sur iPhone et Mac, Gemini Nano sur Android, le modèle intégré de Chrome. Si aucun n\'est disponible, Dottoday utilise votre propre historique et des règles simples. Ce que vous tapez n\'est jamais envoyé à un serveur ; questions et réponses restent sur cet appareil.';

  @override
  String get privacyThinkingOnDevice =>
      'Sur cet appareil maintenant : le modèle intégré.';

  @override
  String get privacyThinkingRules =>
      'Sur cet appareil maintenant : votre historique et des règles simples.';

  @override
  String get privacyClearThinking => 'Effacer l\'historique de réflexion';

  @override
  String get snackThinkingCleared => 'Historique de réflexion effacé';

  @override
  String get proposalAccept => 'Accepter';

  @override
  String get proposalDiscard => 'Ignorer';

  @override
  String get proposalNothingSaved => 'Rien n\'est enregistré avant d\'accepter';

  @override
  String get proposalLegendNow => 'maintenant';

  @override
  String get proposalLegendProposed => 'proposé';

  @override
  String proposalShiftedLater(String duration) {
    return 'décalé de +$duration';
  }

  @override
  String proposalShiftedEarlier(String duration) {
    return 'décalé de −$duration';
  }

  @override
  String proposalShrunk(String duration) {
    return 'réduit à $duration';
  }

  @override
  String proposalGrown(String duration) {
    return 'allongé à $duration';
  }

  @override
  String proposalMovedTo(String when) {
    return 'déplacé à $when';
  }

  @override
  String get proposalMovedToInbox => 'déplacé dans la boîte de réception';

  @override
  String get proposalAdded => 'nouveau';

  @override
  String get proposalUntouched => 'épinglé · inchangé';

  @override
  String proposalSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '1 étape',
    );
    return '$_temp0';
  }

  @override
  String get proposalNothing => 'Rien à changer';

  @override
  String proposalKeep(String title) {
    return 'Garder $title tel quel';
  }

  @override
  String proposalDayTime(String day, String time) {
    return '$day à $time';
  }

  @override
  String get stepLengthAdd => '+ durée';

  @override
  String stepLengthHint(String title) {
    return 'Modifier la durée de $title';
  }

  @override
  String get stepLengthTitle => 'Combien de temps pour cette étape ?';

  @override
  String get stepLengthNone => 'Sans durée';

  @override
  String get editorStepsSum => 'Durée = somme des étapes';

  @override
  String editorStepsSumTotal(String duration) {
    return 'Les étapes font $duration';
  }

  @override
  String get editorStepsSumEmpty =>
      'Donnez une durée à une étape pour l\'utiliser';

  @override
  String get breakdownAction => 'Découper';

  @override
  String get breakdownOnDevice => 'sur l\'appareil';

  @override
  String get breakdownUsual => 'comme d\'habitude';

  @override
  String breakdownStepHint(int number) {
    return 'Étape $number';
  }

  @override
  String get breakdownAddStep => 'Ajouter une étape';

  @override
  String breakdownDepth(int depth, int max) {
    return 'niveau $depth sur $max';
  }

  @override
  String get breakdownSplit => 'Découper cette étape';

  @override
  String get breakdownRemove => 'Retirer l\'étape';

  @override
  String breakdownShow(String title) {
    return 'Plus pour $title';
  }

  @override
  String breakdownTotal(String duration) {
    return 'Total $duration · le point s\'adapte';
  }

  @override
  String get breakdownSmallest =>
      'Si rien ne démarre, on ne vous proposera que la première étape (Plus petit pas)';

  @override
  String breakdownWasNow(String before, String after) {
    return 'avant $before → maintenant $after';
  }

  @override
  String breakdownJoin(String parent, String step) {
    return '$parent · $step';
  }

  @override
  String breakdownAccepted(String title) {
    return 'Étapes ajoutées à $title';
  }

  @override
  String breakdownStepsOnDraft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '1 étape',
    );
    return '$_temp0 · enregistrées avec la tâche';
  }

  @override
  String get focusTitle => 'Concentration';

  @override
  String get focusBack => 'Aujourd\'hui';

  @override
  String focusRange(String range, String length) {
    return '$range · $length';
  }

  @override
  String focusStep(int number, int total) {
    return 'Étape $number sur $total';
  }

  @override
  String get focusAllSteps => 'Toutes les étapes faites';

  @override
  String get focusChime => 'Carillon toutes les 15 min';

  @override
  String get focusDeepWork => 'Travail profond · Concentration activée';

  @override
  String get focusDeepWorkAccess =>
      'Autoriser Dottoday à activer Ne pas déranger';

  @override
  String get focusShortcutsTitle => 'Activer une Concentration avec Raccourcis';

  @override
  String get focusShortcutsBody =>
      'L\'iPhone et le Mac ne laissent pas les apps changer de Concentration. Dans Raccourcis, créez un raccourci avec « Commencer le focus » de Dottoday et « Activer la Concentration », puis lancez-le depuis le bouton Action, le centre de contrôle ou Siri.';

  @override
  String get focusShortcutsOpen => 'Ouvrir Raccourcis';

  @override
  String get focusDeepWorkWeb =>
      'Utilisez Ne pas déranger de votre ordinateur ; le navigateur ne peut pas le changer';

  @override
  String get focusNextStep => 'Étape suivante';

  @override
  String get focusBreakThrough =>
      'Les débuts de points passent quand même la Concentration (urgents)';

  @override
  String get focusMore => 'Plus';

  @override
  String get focusOpenTask => 'Détails de la tâche';

  @override
  String focusDoneMessage(String title) {
    return '$title fait';
  }

  @override
  String focusExtendedMessage(String title) {
    return '$title · 15 min de plus';
  }

  @override
  String get focusOpenHint => 'Ouvrir la concentration';

  @override
  String smallestStepTitle(String step, String length) {
    return 'Juste $step · $length ?';
  }

  @override
  String smallestStepTitleShort(String step) {
    return 'Juste $step ?';
  }

  @override
  String get smallestStepStart => 'Commencer';

  @override
  String get unstickPrompt =>
      'Quelle est la toute première chose concrète que vous feriez ?';

  @override
  String get unstickHint => 'p. ex. Ouvrir le dossier';

  @override
  String get unstickSave => 'En faire l\'étape 1';

  @override
  String unstickSaved(String title) {
    return 'Étape 1 ajoutée à $title';
  }

  @override
  String get rebalanceAccept => 'Accepter le plan';

  @override
  String get rebalanceFootnote =>
      'Rien ne bouge avant votre accord · Annuler pendant 30 s ensuite';

  @override
  String get rebalanceShiftFollowers => 'Décaler la suite';

  @override
  String get rebalanceAllowShrink => 'Raccourcir l’optionnel';

  @override
  String get rebalancePastBedtime => 'Dépasser le coucher';

  @override
  String rebalanceRanOver(String title, String duration) {
    return '$title a débordé de $duration · voici un plan';
  }

  @override
  String rebalanceLate(String duration) {
    return 'La suite de la journée $duration plus tard · voici un plan';
  }

  @override
  String rebalanceRunsOver(String title, String duration) {
    return '$title dépasse de $duration · voici un plan';
  }

  @override
  String get rebalanceAccepted => 'Plan accepté';

  @override
  String get calendarMovedTitle => 'Agenda modifié';

  @override
  String calendarMovedDetail(String title, String time) {
    return '$title déplacé à $time · rééquilibrer ?';
  }

  @override
  String get calendarMovedAction => 'Rééquilibrer';

  @override
  String rebalanceMoved(String title, String time) {
    return '$title déplacé à $time · voici un plan';
  }

  @override
  String realityMetaJoin(String text) {
    return '· $text';
  }

  @override
  String realityPlanned(String time) {
    return 'prévu $time';
  }

  @override
  String get realityNotStarted => 'pas encore commencé';

  @override
  String realityTook(String duration) {
    return 'a pris $duration';
  }

  @override
  String realityRunning(String duration) {
    return 'depuis $duration';
  }

  @override
  String get realityNow => 'maintenant';

  @override
  String get realityPlan => 'Plan';

  @override
  String get realityReality => 'Réel';

  @override
  String learnUsually(String duration) {
    return 'en général $duration';
  }

  @override
  String learnStartsAfter(int minutes) {
    return 'commence d’habitude ~$minutes min après le plan';
  }

  @override
  String learnStartsBefore(int minutes) {
    return 'commence d’habitude ~$minutes min avant le plan';
  }

  @override
  String learnInsight(String title, String duration) {
    return '$title vous prend en général $duration · Ajouter le proposera';
  }

  @override
  String get learnInsightOk => 'OK';

  @override
  String learnCaption(int total, int done) {
    return 'Votre fil de la réalité apparaît après environ $total tâches terminées · $done pour l’instant';
  }

  @override
  String get learnCaptionHide => 'Masquer jusqu’à demain';

  @override
  String get learnRealityReady =>
      'La vue plan et réalité est maintenant en haut de la journée';

  @override
  String get realityNothingStartedToday =>
      'rien de commencé aujourd’hui pour l’instant';

  @override
  String learnBasedOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'd’après les $count dernières fois',
      one: 'd’après la dernière fois',
    );
    return '$_temp0 · médiane';
  }

  @override
  String learnEnergyBasedOn(int count) {
    return 'd’après vos $count dernières tâches exigeantes terminées · quand la plupart ont commencé';
  }

  @override
  String learnFromHistory(String value) {
    return '$value, appris de votre historique';
  }

  @override
  String get learnExplainHint => 'Montre comment c’est calculé';

  @override
  String get learnReset => 'Réinitialiser pour cette tâche sur cet appareil';

  @override
  String learnResetDone(String title) {
    return 'Apprentissage pour $title réinitialisé sur cet appareil';
  }

  @override
  String learnResetConfirm(String title) {
    return 'Oublier ce que $title a appris, sur cet appareil ?';
  }

  @override
  String get learnResetConfirmAction => 'Réinitialiser';

  @override
  String get learnResetKeep => 'Garder';

  @override
  String lateUsually(String title, String duration) {
    return '$title prend en général $duration';
  }

  @override
  String get routinesTitle => 'Routines';

  @override
  String get routinesSubtitle => 'Morceaux de fil réutilisables';

  @override
  String routineSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '1 étape',
    );
    return '$_temp0';
  }

  @override
  String routineSummary(String steps, String duration, String anchor) {
    return '$steps · $duration · $anchor';
  }

  @override
  String get routineStartsWake => 'commence au réveil';

  @override
  String get routineEndsBed => 'finit au coucher';

  @override
  String routineStartsAt(String time) {
    return 'commence à $time';
  }

  @override
  String get routineDropToday => 'Poser sur aujourd’hui';

  @override
  String get routineEdit => 'Modifier';

  @override
  String get routineNew => 'Nouvelle routine';

  @override
  String get routineNewHint => 'ou enregistrer une sélection d’un jour';

  @override
  String get routineAlarmNote =>
      'Le début d’une routine sonne fort, comme un réveil';

  @override
  String get routinesEmpty =>
      'Aucune routine. Choisis quelques tâches d’un jour et enregistre-les comme routine, ou commence-en une.';

  @override
  String get routineSaveSelection => 'Enregistrer comme routine';

  @override
  String get routineName => 'Nom';

  @override
  String routineSaved(String title) {
    return '« $title » enregistrée comme routine';
  }

  @override
  String routineDeleted(String title) {
    return '« $title » supprimée';
  }

  @override
  String get routineDelete => 'Supprimer la routine';

  @override
  String get routineEditTitle => 'Modifier la routine';

  @override
  String get routineAnchorLabel => 'Quand';

  @override
  String get routineAnchorWake => 'Au réveil';

  @override
  String get routineAnchorBed => 'Finit au coucher';

  @override
  String get routineAnchorTime => 'À une heure';

  @override
  String get routineStepsLabel => 'Étapes';

  @override
  String get routineStepHint => 'Nom de l’étape';

  @override
  String get routineAddStep => 'Ajouter une étape';

  @override
  String routineRemoveStep(String title) {
    return 'Retirer $title';
  }

  @override
  String routineMoveUp(String title) {
    return 'Monter $title';
  }

  @override
  String routineMoveDown(String title) {
    return 'Descendre $title';
  }

  @override
  String routineGap(String duration) {
    return '$duration libre';
  }

  @override
  String get routineSave => 'Enregistrer';

  @override
  String get routineDropTitle => 'Routine';

  @override
  String routineDropSubtitle(String title, String day, String time) {
    return '$title le $day · dès $time';
  }

  @override
  String get routineDropAccept => 'Ajouter au jour';

  @override
  String get routineDropAccepted => 'Routine ajoutée';

  @override
  String routineChipLabel(String title) {
    return 'Poser la routine $title';
  }

  @override
  String get routinesMenu => 'Mes routines…';

  @override
  String get routinesSuggestions => 'Mes routines';

  @override
  String get routineInvalid =>
      'Donne un nom à la routine et au moins une étape';

  @override
  String routinesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routines',
      one: '1 routine',
      zero: 'Aucune routine',
    );
    return '$_temp0';
  }

  @override
  String get routineDropHere => 'Poser une routine…';

  @override
  String routineDropOnDay(String day) {
    return 'Poser sur $day';
  }

  @override
  String get routineDropDay => 'Quel jour';

  @override
  String get settingsEnergy => 'Suggestions d’énergie';

  @override
  String get settingsEnergyDetail =>
      'Proposer les moments où vous terminez le mieux les tâches exigeantes';

  @override
  String settingsEnergyLocked(int total, int count) {
    return 'Après $total tâches exigeantes terminées · $count pour l’instant';
  }

  @override
  String settingsEnergyReady(int count) {
    return 'prêt – d’après $count tâches terminées';
  }

  @override
  String get settingsLearning => 'Apprentissage';

  @override
  String get settingsLearningReality => 'Fil de la réalité';

  @override
  String settingsLearningRealityPending(int total) {
    return 'Dottoday apprend comment se passent vraiment vos journées. Votre fil de la réalité apparaît après environ $total tâches terminées.';
  }

  @override
  String get settingsLearningRealityReady =>
      'Prêt · Plan / Réalité est en haut d’Aujourd’hui';

  @override
  String get settingsLearningDurations => 'Durée des tâches';

  @override
  String settingsLearningDurationsPending(int min) {
    return 'Dottoday apprend combien de temps vos tâches prennent vraiment. Chaque tâche affiche sa durée habituelle après environ $min fois terminée.';
  }

  @override
  String settingsLearningTasksReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Prêt pour $count tâches',
      one: 'Prêt pour 1 tâche',
    );
    return '$_temp0';
  }

  @override
  String get settingsLearningSteps => 'Durée des étapes';

  @override
  String settingsLearningStepsPending(int min) {
    return 'Dottoday apprend combien de temps prend chaque étape. Le minuteur d’une étape utilise sa durée habituelle après environ $min fois terminée.';
  }

  @override
  String settingsLearningStepsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Prêt pour $count étapes',
      one: 'Prêt pour 1 étape',
    );
    return '$_temp0';
  }

  @override
  String settingsLearningProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String settingsLearningProgressLabel(int done, int total) {
    return '$done sur $total pour l’instant';
  }

  @override
  String get settingsLearningPrivacy =>
      'L’apprentissage se fait sur votre appareil. Vos heures réelles de début et de fin se synchronisent avec votre compte comme le reste de votre plan ; les valeurs apprises ne sont jamais envoyées.';

  @override
  String addEnergyBest(String range) {
    return 'vous terminez le mieux les tâches exigeantes $range';
  }

  @override
  String addEnergyTry(String time) {
    return 'Essayer $time';
  }

  @override
  String get debugLoadM11Sample => 'Charger l’exemple M11 (debug)';

  @override
  String get debugM11Loaded => 'Exemple M11 chargé';

  @override
  String get proposalOverlaps => 'déjà là · chevauche';

  @override
  String get weekReviewTitle => 'Cette semaine';

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
    return '$day : $done sur $total faites, $planned prévues';
  }

  @override
  String weekReviewPlanned(String planned) {
    return '$planned prévues';
  }

  @override
  String weekReviewPlannedBusiest(String planned) {
    return '$planned · le plus chargé';
  }

  @override
  String weekReviewBusiest(String day) {
    return 'Plus chargé · $day';
  }

  @override
  String weekReviewLightest(String day) {
    return 'Plus léger · $day';
  }

  @override
  String get weekPaceMornings =>
      'Les matinées se sont surtout passées comme prévu.';

  @override
  String get weekPaceAfternoons =>
      'Les après-midi se sont surtout passés comme prévu.';

  @override
  String get weekPaceAllDone => 'Tout ce que vous aviez prévu est fait.';

  @override
  String get weekPaceQuiet => 'Une semaine calme : rien n\'était prévu.';

  @override
  String weekLoadBoth(String busiest, String lightest) {
    return '$busiest a porté le plus ; $lightest a respiré.';
  }

  @override
  String weekLoadBusiest(String busiest) {
    return '$busiest a porté le plus.';
  }

  @override
  String weekCarryAsk(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pas finies · les placer la semaine prochaine ?',
      one: '1 pas finie · la placer la semaine prochaine ?',
    );
    return '$_temp0';
  }

  @override
  String get weekCarryPlace => 'Placer';

  @override
  String get weekCarryInbox => 'Laisser dans la boîte de réception';

  @override
  String get weekCarryTitle => 'Semaine prochaine';

  @override
  String weekCarrySubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tâches pas finies, chacune dans le premier temps libre qui convient',
      one: '1 tâche pas finie, dans le premier temps libre qui convient',
    );
    return '$_temp0';
  }

  @override
  String get weekCarryAccept => 'Les placer';

  @override
  String get weekCarryAccepted => 'Placées la semaine prochaine';

  @override
  String get weekShareTitles => 'Afficher les titres des tâches';

  @override
  String get weekShareImage => 'Partager l\'image';

  @override
  String weekShareDayTitles(String day, String titles) {
    return '$day · $titles';
  }

  @override
  String get weekReviewNoStreaks =>
      'Pas de séries ici — juste ce qui s\'est passé.';

  @override
  String get weekPromptDetail => 'Votre semaine en sept points';

  @override
  String get weekPromptAction => 'Voir la semaine';

  @override
  String get lowEnergyMode => 'Mode basse énergie';

  @override
  String get lowEnergyTurnOff => 'Désactiver le mode basse énergie';

  @override
  String get settingsLowEnergyDetail =>
      'Aujourd\'hui n\'affiche que la suite et les rappels font une pause, jusqu\'à votre prochain réveil';

  @override
  String lowEnergyCaption(String date) {
    return '$date · Basse énergie';
  }

  @override
  String get lowEnergyGreeting => 'Allez-y doucement';

  @override
  String lowEnergyGreetingName(String name) {
    return 'Allez-y doucement, $name';
  }

  @override
  String get lowEnergyOn => 'Basse énergie · activé';

  @override
  String lowEnergyUntil(String time, String left) {
    return 'jusqu\'à $time · encore $left';
  }

  @override
  String lowEnergyAt(String time) {
    return 'à $time';
  }

  @override
  String get lowEnergyNotToday => 'Pas aujourd\'hui';

  @override
  String lowEnergyMovedTomorrow(String title) {
    return '$title déplacée à demain';
  }

  @override
  String lowEnergySkipped(String title) {
    return '$title passée pour aujourd\'hui';
  }

  @override
  String lowEnergyLater(int count) {
    return 'Plus tard · $count';
  }

  @override
  String get lowEnergyShowLater => 'Afficher la suite';

  @override
  String get lowEnergyHideLater => 'Masquer la suite';

  @override
  String get lowEnergyPropose => 'Tout l\'optionnel à demain ?';

  @override
  String get lowEnergyProposeAction => 'Proposer';

  @override
  String get lowEnergyNudgesOff =>
      'Les rappels sont coupés jusqu\'au réveil de demain';

  @override
  String get lowEnergyNothing => 'Plus rien aujourd\'hui. Reposez-vous bien.';

  @override
  String get lowEnergyProposalTitle => 'Demain';

  @override
  String lowEnergyProposalSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tâches optionnelles, chacune dans le premier temps libre de demain',
      one: '1 tâche optionnelle, dans le premier temps libre de demain',
    );
    return '$_temp0';
  }

  @override
  String get lowEnergyProposalAccept => 'Les déplacer';

  @override
  String get lowEnergyProposalAccepted => 'Déplacées à demain';

  @override
  String get journalTitle => 'Jours passés';

  @override
  String get journalEntryDetail => 'Chaque jour prévu, tel qu\'il s\'est passé';

  @override
  String get journalSearchHint => 'Dernière fois que…';

  @override
  String journalDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours ces 12 derniers mois',
      one: '1 jour ces 12 derniers mois',
    );
    return '$_temp0';
  }

  @override
  String journalLast(String date, int ago, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      ago,
      locale: localeName,
      other: 'il y a $ago jours',
      one: 'hier',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ago,
      locale: localeName,
      other: 'il y a $ago jours',
      one: 'hier',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dernière fois : $date · $_temp0 · $count jours',
      one: 'Dernière fois : $date · $_temp1 · une fois',
    );
    return '$_temp2';
  }

  @override
  String journalNoMatch(String query) {
    return 'Rien ces 12 derniers mois ne correspond à « $query »';
  }

  @override
  String get journalEmpty =>
      'Pas encore de jours passés. Les jours prévus apparaissent ici une fois terminés.';

  @override
  String journalDayLabel(String date, String summary) {
    return '$date, $summary. Ouvrir le jour';
  }

  @override
  String journalMatch(String title, String time) {
    return '$title · $time';
  }

  @override
  String get journalStripTitle => 'Bande de l\'année';

  @override
  String journalStripLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Votre année en points : $count jours prévus',
      one: 'Votre année en points : 1 jour prévu',
    );
    return '$_temp0';
  }

  @override
  String get dumpTitle => 'Vider sa tête';

  @override
  String get dumpHint =>
      'Tout ce qui vous passe par la tête, une chose par ligne';

  @override
  String get dumpPlan => 'Planifier';

  @override
  String get dumpNothing =>
      'Rien à planifier pour l\'instant. Écrivez une chose par ligne.';

  @override
  String dumpSubtitle(int count, String day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches $day, dans le premier temps libre',
      one: '1 tâche $day, dans le premier temps libre',
    );
    return '$_temp0';
  }

  @override
  String get dumpAccepted => 'Ajouté depuis votre liste';

  @override
  String get dumpEarlier => 'Listes précédentes';

  @override
  String get dumpSearch => 'Chercher dans les listes précédentes';

  @override
  String get dumpUseAgain => 'Réutiliser';

  @override
  String get proposalToInbox => 'pas de place · dans la boîte de réception';

  @override
  String get releaseNotes100 =>
      'Voir le temps : votre prochain point sur l\'écran verrouillé, les widgets, la barre des menus du Mac et Siri, et des alarmes qui sonnent vraiment.\nCommencer : découpez une tâche en petites étapes, concentrez-vous sur un point, et une aide douce quand une tâche ne démarre pas.\nGarder la main : Rééquilibrer montre un plan avant que rien ne bouge ; Plan / Réalité montre comment la journée s\'est vraiment passée.\nRoutines, suggestions d\'énergie et durées apprises de vos propres journées, sur votre appareil.\nCette semaine en sept points, Jours passés pour regarder en arrière, et le mode basse énergie pour les jours difficiles. Sans rien à tenir.\nPartagez une page ou une note vers Dottoday depuis n\'importe quelle app, ou videz votre tête avec Vider sa tête.';

  @override
  String get privacyAiAppleOffIos =>
      'Activez Apple Intelligence dans Réglages de l\'iPhone › Apple Intelligence et Siri. Dottoday l\'utilisera automatiquement.';

  @override
  String get privacyAiAppleOffMac =>
      'Activez Apple Intelligence dans Réglages Système › Apple Intelligence et Siri. Dottoday l\'utilisera automatiquement.';

  @override
  String get privacyAiAppleDownloading =>
      'Apple Intelligence se prépare sur cet appareil. Cela peut prendre un moment.';

  @override
  String get privacyAiGoogleDownloadable =>
      'Gemini Nano peut être téléchargé sur ce téléphone ; le téléchargement se fait en arrière-plan.';

  @override
  String get privacyAiGoogleDownloading =>
      'Gemini Nano est en cours de téléchargement sur ce téléphone. Dottoday l\'utilisera dès qu\'il sera prêt.';

  @override
  String get privacyAiChromeDownloadable =>
      'Ce navigateur peut télécharger son modèle d\'IA intégré. Dottoday l\'utilisera dès qu\'il sera là.';

  @override
  String get privacyAiChromeDownloading =>
      'Ce navigateur télécharge son modèle d\'IA intégré. Dottoday l\'utilisera dès qu\'il sera prêt.';

  @override
  String get privacyAiNotEligible =>
      'Cet appareil ne peut pas faire tourner le modèle intégré. Dottoday utilise votre historique et des règles simples.';

  @override
  String get privacyAiOpenSettings => 'Ouvrir les Réglages';

  @override
  String get privacyAiOpenSettingsIos =>
      'Ouvre la page de Dottoday dans Réglages. Apple ne permet pas aux apps d\'ouvrir Apple Intelligence directement : revenez à Réglages, puis Apple Intelligence et Siri.';

  @override
  String get thinkingOriginRules => 'règles simples';

  @override
  String get thinkingHintLead => 'Fait avec des règles simples';

  @override
  String get thinkingHintApple =>
      'Activez Apple Intelligence pour des plans plus fins';

  @override
  String get thinkingHintAppleReady =>
      'Apple Intelligence se prépare pour des plans plus fins';

  @override
  String get thinkingHintGoogle =>
      'Gemini Nano fera des plans plus fins une fois sur ce téléphone';

  @override
  String get thinkingHintChrome =>
      'L\'IA intégrée de votre navigateur fera des plans plus fins une fois prête';

  @override
  String get thinkingHintDismiss => 'Ne plus afficher';

  @override
  String get dumpPlansApple =>
      'Planifie avec Apple Intelligence sur cet appareil';

  @override
  String get dumpPlansGoogle => 'Planifie avec Gemini Nano sur ce téléphone';

  @override
  String get dumpPlansChrome =>
      'Planifie avec l\'IA intégrée de votre navigateur, sur cet appareil';

  @override
  String get dumpPlansRules => 'Planifie avec des règles simples';

  @override
  String get releaseNotes110 =>
      'Dites-le : touchez le micro dans « Vider sa tête » et dites ce qui vous occupe l\'esprit — faites une pause, ou dites « suivant », pour passer à une nouvelle tâche. Le micro est aussi dans les notes d\'une tâche. Vos mots deviennent du texte sur cet appareil et ne sont envoyés nulle part.\nDemandez à Siri : sur iPhone, Réglages › Siri et raccourcis montre les cinq choses que vous pouvez demander, comme « Et ensuite dans Dottoday ».\nSachez qui planifie : Réglages › Confidentialité indique si Apple Intelligence, Gemini Nano ou l\'IA intégrée de votre navigateur aide sur cet appareil, et comment l\'activer. Les plans faits avec des règles simples le disent désormais.';

  @override
  String statusHintJoin(String lead, String action) {
    return '$lead · $action';
  }

  @override
  String get settingsSiri => 'Siri et raccourcis';

  @override
  String get settingsSiriDetail => 'Demandez à Siri votre journée';

  @override
  String get siriIntro =>
      'Siri peut ajouter une tâche, vous dire ce qui suit et vous aider avec la tâche en cours — sans ouvrir Dottoday.';

  @override
  String get siriHowTo =>
      'Dites « Dis Siri » ou maintenez le bouton latéral, puis dites une phrase.';

  @override
  String get siriPhrasesCaption => 'Ce que vous pouvez dire';

  @override
  String get siriPhraseAdd => 'Ajouter une tâche dans Dottoday';

  @override
  String get siriPhraseAddDetail =>
      'Siri demande quoi ajouter. Avec une heure, c\'est placé dans votre journée ; sinon, dans la boîte de réception.';

  @override
  String get siriPhraseNext => 'Et ensuite dans Dottoday';

  @override
  String get siriPhraseNextDetail =>
      'Siri dit ce qui est en cours, ou ce qui vient ensuite.';

  @override
  String get siriPhraseDone => 'Marquer ma tâche comme faite dans Dottoday';

  @override
  String get siriPhraseDoneDetail => 'Coche la tâche en cours.';

  @override
  String get siriPhrasePlus15 =>
      'Donner 15 minutes de plus à ma tâche dans Dottoday';

  @override
  String get siriPhrasePlus15Detail =>
      'Donne 15 minutes de plus à la tâche en cours.';

  @override
  String get siriPhraseFocus => 'Commencer le focus dans Dottoday';

  @override
  String get siriPhraseFocusDetail => 'Ouvre le focus sur la tâche en cours.';

  @override
  String get siriShortcutsCaption => 'Raccourcis';

  @override
  String get siriShortcutsBody =>
      'Les cinq mêmes actions sont dans l\'app Raccourcis, prêtes pour le bouton Action, le centre de contrôle ou l\'écran d\'accueil.';

  @override
  String get siriOpenShortcuts => 'Ouvrir Raccourcis';

  @override
  String get siriTipTitle => 'Demandez à Siri « Et ensuite dans Dottoday »';

  @override
  String get siriTipShow => 'Me montrer';

  @override
  String get tipDismiss => 'Ne plus afficher';

  @override
  String get onboardingSiriLine =>
      'Vous pouvez aussi demander à Siri « Et ensuite dans Dottoday ».';

  @override
  String get dictationCommand => 'suivant';

  @override
  String get micDictate => 'Dicter';

  @override
  String get micStop => 'Arrêter la dictée';

  @override
  String get micDenied => 'Le micro est désactivé pour Dottoday';

  @override
  String get failureSpeech =>
      'La dictée s\'est arrêtée. Touchez le micro pour continuer.';

  @override
  String get micRationaleTitle => 'Utiliser le micro ?';

  @override
  String get micRationaleBody =>
      'Dottoday n\'écoute que lorsque le bouton micro est activé, pour transformer vos mots en texte sur cet appareil.';

  @override
  String get micRationaleContinue => 'Continuer';

  @override
  String get dumpListening =>
      'Faites une pause, ou dites « suivant », pour passer à une nouvelle tâche.';

  @override
  String get dumpHintMic => 'Tapez ou touchez le micro. Une chose par ligne.';

  @override
  String get dumpMicTipTitle => 'Dictez votre liste';

  @override
  String get dumpMicTipBody =>
      'Faites une pause, ou dites « suivant », entre deux choses. « Appeler le dentiste … suivant … acheter du lait » donne deux lignes.';

  @override
  String get layoutShowEverything => 'Tout afficher';

  @override
  String get layoutShowLess => 'Afficher moins';

  @override
  String get layoutRow => 'Affichage';

  @override
  String get layoutMinimal => 'Minimal';

  @override
  String get layoutFull => 'Complet';

  @override
  String laterRow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Plus tard · $count',
      zero: 'Plus tard',
    );
    return '$_temp0';
  }

  @override
  String laterRowLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Plus tard, $count tâches en attente',
      one: 'Plus tard, 1 tâche en attente',
      zero: 'Plus tard, rien en attente',
    );
    return '$_temp0';
  }

  @override
  String get moreOptions => 'Plus';

  @override
  String get sheetLater => 'Plus tard';

  @override
  String get sheetDelete => 'Supprimer';

  @override
  String get settingsEverythingElse => 'Tout le reste…';

  @override
  String get settingsRemindDotStarts => 'Me rappeler quand un point commence';

  @override
  String get settingsAccountAndSync => 'Compte et synchronisation';

  @override
  String addWhenChip(String time) {
    return 'À $time';
  }

  @override
  String get onboardingLayoutTitle => 'Que voulez-vous voir ?';

  @override
  String get onboardingLayoutBody =>
      'Vous pouvez changer cela à tout moment, en haut des Réglages.';

  @override
  String get onboardingLayoutMinimalTitle => 'Juste le prochain point';

  @override
  String get onboardingLayoutMinimalBody =>
      'Ce qui se passe maintenant et ensuite. Ajouter, faire, fait. Rien à régler.';

  @override
  String get onboardingLayoutFullTitle => 'Le planificateur complet';

  @override
  String get onboardingLayoutFullBody =>
      'Le fil entier, la semaine et le mois, les routines, les bilans, les widgets et tous les réglages.';

  @override
  String get onboardingFirstTaskTitle => 'Une chose pour aujourd\'hui ?';

  @override
  String get onboardingFirstTaskBody =>
      'Écrivez-le comme vous le diriez, par exemple « appeler Sam 18h ». Il va sur votre fil.';

  @override
  String get onboardingFirstTaskAdd => 'Mettre sur aujourd\'hui';

  @override
  String get hintRoutines => 'Enregistrer ceci comme votre matin ?';

  @override
  String get hintBreakDown => 'Le découper en étapes ?';

  @override
  String get hintWidget =>
      'Le prochain point aussi sur votre écran d\'accueil ?';

  @override
  String get hintWidgetHow =>
      'Ajoutez le widget Dottoday depuis la liste des widgets de votre écran d\'accueil.';

  @override
  String get hintWeek => 'Voir votre semaine en sept points ?';

  @override
  String get hintLearned =>
      'Dottoday peut préremplir les durées selon le temps que les choses prennent vraiment.';

  @override
  String get hintShowMe => 'Montrer';

  @override
  String get taskIconCategoryPlanning => 'Planification et rythme';

  @override
  String get taskIconCategoryHealth => 'Santé et corps';

  @override
  String get taskIconCategoryFitness => 'Forme et sport';

  @override
  String get taskIconCategoryFood => 'Nourriture et boissons';

  @override
  String get taskIconCategoryHome => 'Maison et ménage';

  @override
  String get taskIconCategoryWork => 'Travail et études';

  @override
  String get taskIconCategoryTech => 'Technologie et appareils';

  @override
  String get taskIconCategoryTravel => 'Voyages et transports';

  @override
  String get taskIconCategoryNature => 'Nature et météo';

  @override
  String get taskIconCategoryAnimals => 'Animaux';

  @override
  String get taskIconCategoryPeople => 'Personnes et vie sociale';

  @override
  String get taskIconCategoryLeisure => 'Loisirs et passe-temps';

  @override
  String get taskIconCategoryShopping => 'Achats et argent';

  @override
  String get taskIconCategoryStyle => 'Vêtements et beauté';

  @override
  String get taskIconCategoryFaith => 'Foi et fêtes';

  @override
  String get taskIconCategorySymbols => 'Symboles et signes';

  @override
  String get taskIconFocusBlock => 'Bloc de concentration';

  @override
  String get taskIconDeepWork => 'Travail en profondeur';

  @override
  String get taskIconPlanTheDay => 'Planifier la journée';

  @override
  String get taskIconTimeBlock => 'Créneau';

  @override
  String get taskIconBuffer => 'Marge';

  @override
  String get taskIconAnytime => 'À tout moment';

  @override
  String get taskIconTakeABreak => 'Pause';

  @override
  String get taskIconMorningRoutine => 'Routine du matin';

  @override
  String get taskIconEveningRoutine => 'Routine du soir';

  @override
  String get taskIconWindDown => 'Décompresser';

  @override
  String get taskIconPowerNap => 'Sieste éclair';

  @override
  String get taskIconWeekReview => 'Bilan de la semaine';

  @override
  String get taskIconInboxZero => 'Boîte vide';

  @override
  String get taskIconHabit => 'Habitude';

  @override
  String get taskIconErrands => 'Courses';

  @override
  String get taskIconLowEnergy => 'Peu d’énergie';

  @override
  String get taskIconHighEnergy => 'Plein d’énergie';

  @override
  String get taskIconScreenFree => 'Sans écran';

  @override
  String get taskIconStandUp => 'Point quotidien';

  @override
  String get taskIconSelfCare => 'Prendre soin de soi';

  @override
  String get taskIconMealPrep => 'Préparation des repas';

  @override
  String get taskIconPayBills => 'Payer les factures';

  @override
  String get taskIconAllergens => 'Allergènes';

  @override
  String get taskIconBandage => 'Pansement';

  @override
  String get taskIconBloodBag => 'Poche de sang';

  @override
  String get taskIconBrain => 'Cerveau';

  @override
  String get taskIconCrutch => 'Béquille';

  @override
  String get taskIconDoctor => 'Médecin';

  @override
  String get taskIconEar => 'Oreille';

  @override
  String get taskIconEcg => 'ECG';

  @override
  String get taskIconEyes => 'Yeux';

  @override
  String get taskIconFaceMask => 'Masque';

  @override
  String get taskIconFalling => 'Chute';

  @override
  String get taskIconHead => 'Tête';

  @override
  String get taskIconHearingDevice => 'Appareil auditif';

  @override
  String get taskIconHeart => 'Cœur';

  @override
  String get taskIconHospital => 'Hôpital';

  @override
  String get taskIconLungs => 'Poumons';

  @override
  String get taskIconMedicalThermometer => 'Thermomètre médical';

  @override
  String get taskIconMicrobe => 'Microbe';

  @override
  String get taskIconPharmacy => 'Pharmacie';

  @override
  String get taskIconMeds => 'Comprimé';

  @override
  String get taskIconPills => 'Comprimés';

  @override
  String get taskIconSleep => 'Sommeil';

  @override
  String get taskIconSleepyMoon => 'Lune endormie';

  @override
  String get taskIconStanding => 'Debout';

  @override
  String get taskIconStarOfLife => 'Étoile de vie';

  @override
  String get taskIconSyringe => 'Seringue';

  @override
  String get taskIconTherapy => 'Thérapie';

  @override
  String get taskIconTooth => 'Dent';

  @override
  String get taskIconToothbrush => 'Brosse à dents';

  @override
  String get taskIconVial => 'Fiole';

  @override
  String get taskIconWheelchair => 'Fauteuil roulant';

  @override
  String get taskIconAmericanFootball => 'Football américain';

  @override
  String get taskIconArchery => 'Tir à l\'arc';

  @override
  String get taskIconAustralianFootball => 'Football australien';

  @override
  String get taskIconBaseball => 'Baseball';

  @override
  String get taskIconBasketball => 'Basketball';

  @override
  String get taskIconBowling => 'Bowling';

  @override
  String get taskIconCoreTraining => 'Gainage';

  @override
  String get taskIconCricket => 'Cricket';

  @override
  String get taskIconCrossTraining => 'Cross-training';

  @override
  String get taskIconCurling => 'Curling';

  @override
  String get taskIconCycling => 'Cyclisme';

  @override
  String get taskIconDancing => 'Danse';

  @override
  String get taskIconGym => 'Haltère';

  @override
  String get taskIconFencing => 'Escrime';

  @override
  String get taskIconGolf => 'Golf';

  @override
  String get taskIconGymnastics => 'Gymnastique';

  @override
  String get taskIconHandball => 'Handball';

  @override
  String get taskIconHelmet => 'Casque';

  @override
  String get taskIconHiit => 'HIIT';

  @override
  String get taskIconHiking => 'Randonnée';

  @override
  String get taskIconHorseRiding => 'Équitation';

  @override
  String get taskIconIceSkates => 'Patins à glace';

  @override
  String get taskIconJogging => 'Jogging';

  @override
  String get taskIconMartialArts => 'Arts martiaux';

  @override
  String get taskIconMedal => 'Médaille';

  @override
  String get taskIconPoolSwimming => 'Natation en piscine';

  @override
  String get taskIconRopeJumping => 'Corde à sauter';

  @override
  String get taskIconRowing => 'Aviron';

  @override
  String get taskIconRugby => 'Rugby';

  @override
  String get taskIconRun => 'Course à pied';

  @override
  String get taskIconSailing => 'Voile';

  @override
  String get taskIconScubaDiving => 'Plongée sous-marine';

  @override
  String get taskIconSkateboard => 'Skateboard';

  @override
  String get taskIconSkating => 'Patinage';

  @override
  String get taskIconSkiing => 'Ski';

  @override
  String get taskIconSnowboard => 'Snowboard';

  @override
  String get taskIconSnowboarding => 'Surf des neiges';

  @override
  String get taskIconSoccer => 'Football';

  @override
  String get taskIconSoftball => 'Softball';

  @override
  String get taskIconSportcourt => 'Terrain de sport';

  @override
  String get taskIconStairStepper => 'Stepper';

  @override
  String get taskIconStepping => 'Step';

  @override
  String get taskIconStopwatch => 'Chronomètre';

  @override
  String get taskIconStretching => 'Étirements';

  @override
  String get taskIconSwimming => 'Natation';

  @override
  String get taskIconTableTennis => 'Tennis de table';

  @override
  String get taskIconTennis => 'Tennis';

  @override
  String get taskIconTrackAndField => 'Athlétisme';

  @override
  String get taskIconTrophy => 'Trophée';

  @override
  String get taskIconVolleyball => 'Volley-ball';

  @override
  String get taskIconWalking => 'Marche';

  @override
  String get taskIconWaterPolo => 'Water-polo';

  @override
  String get taskIconWeightLifting => 'Haltérophilie';

  @override
  String get taskIconYoga => 'Yoga';

  @override
  String get taskIconAlcohol => 'Alcool';

  @override
  String get taskIconApple => 'Pomme';

  @override
  String get taskIconBeer => 'Bière';

  @override
  String get taskIconBurger => 'Burger';

  @override
  String get taskIconCandy => 'Bonbon';

  @override
  String get taskIconCarrot => 'Carotte';

  @override
  String get taskIconCheese => 'Fromage';

  @override
  String get taskIconChopsticks => 'Baguettes';

  @override
  String get taskIconCoffee => 'Café';

  @override
  String get taskIconCooking => 'Cuisine';

  @override
  String get taskIconCookingStove => 'Réchaud';

  @override
  String get taskIconCup => 'Tasse';

  @override
  String get taskIconDumplings => 'Raviolis';

  @override
  String get taskIconFryingPan => 'Poêle';

  @override
  String get taskIconIceCream => 'Glace';

  @override
  String get taskIconMeal => 'Repas';

  @override
  String get taskIconMicrowave => 'Micro-ondes';

  @override
  String get taskIconMug => 'Mug';

  @override
  String get taskIconOven => 'Four';

  @override
  String get taskIconPizza => 'Pizza';

  @override
  String get taskIconPopcorn => 'Pop-corn';

  @override
  String get taskIconSoup => 'Soupe';

  @override
  String get taskIconTakeout => 'Plat à emporter';

  @override
  String get taskIconTray => 'Plateau';

  @override
  String get taskIconWaterBottle => 'Gourde';

  @override
  String get taskIconWater => 'Verre d\'eau';

  @override
  String get taskIconWineGlass => 'Verre de vin';

  @override
  String get taskIconWrap => 'Wrap';

  @override
  String get taskIconAirConditioner => 'Climatiseur';

  @override
  String get taskIconAirPurifier => 'Purificateur d\'air';

  @override
  String get taskIconAx => 'Hache';

  @override
  String get taskIconBathtub => 'Baignoire';

  @override
  String get taskIconBed => 'Lit';

  @override
  String get taskIconBlinds => 'Stores';

  @override
  String get taskIconBookshelf => 'Bibliothèque';

  @override
  String get taskIconBox => 'Boîte';

  @override
  String get taskIconBroom => 'Balai';

  @override
  String get taskIconCeilingFan => 'Ventilateur de plafond';

  @override
  String get taskIconCeilingLamp => 'Plafonnier';

  @override
  String get taskIconChair => 'Chaise';

  @override
  String get taskIconChairLounge => 'Chaise longue';

  @override
  String get taskIconCouch => 'Canapé';

  @override
  String get taskIconDehumidifier => 'Déshumidificateur';

  @override
  String get taskIconDishwasher => 'Lave-vaisselle';

  @override
  String get taskIconDoor => 'Porte';

  @override
  String get taskIconDryer => 'Sèche-linge';

  @override
  String get taskIconDuster => 'Plumeau';

  @override
  String get taskIconFan => 'Ventilateur';

  @override
  String get taskIconFireplace => 'Cheminée';

  @override
  String get taskIconFloorLamp => 'Lampadaire';

  @override
  String get taskIconFridge => 'Frigo';

  @override
  String get taskIconGarage => 'Garage';

  @override
  String get taskIconHammer => 'Marteau';

  @override
  String get taskIconHeater => 'Radiateur';

  @override
  String get taskIconHome => 'Maison';

  @override
  String get taskIconHouseWithFlag => 'Maison avec drapeau';

  @override
  String get taskIconHumidifier => 'Humidificateur';

  @override
  String get taskIconIron => 'Fer à repasser';

  @override
  String get taskIconKey => 'Clé';

  @override
  String get taskIconLaundryBasket => 'Panier à linge';

  @override
  String get taskIconLawnMower => 'Tondeuse';

  @override
  String get taskIconLevel => 'Niveau à bulle';

  @override
  String get taskIconLightBulb => 'Ampoule';

  @override
  String get taskIconMop => 'Serpillière';

  @override
  String get taskIconPottedPlant => 'Plante en pot';

  @override
  String get taskIconRake => 'Râteau';

  @override
  String get taskIconRecycling => 'Recyclage';

  @override
  String get taskIconRefrigerator => 'Réfrigérateur';

  @override
  String get taskIconShadeRoller => 'Store enrouleur';

  @override
  String get taskIconShades => 'Stores occultants';

  @override
  String get taskIconShovel => 'Pelle';

  @override
  String get taskIconShower => 'Douche';

  @override
  String get taskIconSink => 'Évier';

  @override
  String get taskIconSnowShovel => 'Pelle à neige';

  @override
  String get taskIconSoap => 'Savon';

  @override
  String get taskIconStairs => 'Escalier';

  @override
  String get taskIconTable => 'Table';

  @override
  String get taskIconTableLamp => 'Lampe de table';

  @override
  String get taskIconToilet => 'Toilettes';

  @override
  String get taskIconToiletPaper => 'Papier toilette';

  @override
  String get taskIconTrash => 'Poubelle';

  @override
  String get taskIconVacuum => 'Aspirateur';

  @override
  String get taskIconWashingMachine => 'Lave-linge';

  @override
  String get taskIconWateringCan => 'Arrosoir';

  @override
  String get taskIconWrench => 'Clé à molette';

  @override
  String get taskIconAllDayTask => 'Tâche sur la journée';

  @override
  String get taskIconBiology => 'Biologie';

  @override
  String get taskIconBlackboard => 'Tableau noir';

  @override
  String get taskIconBook => 'Livre';

  @override
  String get taskIconBookmark => 'Signet';

  @override
  String get taskIconBriefcase => 'Porte-documents';

  @override
  String get taskIconBuilding => 'Bâtiment';

  @override
  String get taskIconCalendar => 'Calendrier';

  @override
  String get taskIconList => 'Liste de contrôle';

  @override
  String get taskIconChemistry => 'Chimie';

  @override
  String get taskIconClipboard => 'Presse-papiers';

  @override
  String get taskIconCode => 'Code';

  @override
  String get taskIconDeskGlobe => 'Globe terrestre';

  @override
  String get taskIconDeskLamp => 'Lampe de bureau';

  @override
  String get taskIconDocument => 'Document';

  @override
  String get taskIconEmail => 'E-mail';

  @override
  String get taskIconFile => 'Fichier';

  @override
  String get taskIconFolder => 'Dossier';

  @override
  String get taskIconHighlighter => 'Surligneur';

  @override
  String get taskIconIdCard => 'Carte d\'identité';

  @override
  String get taskIconLanguage => 'Langue';

  @override
  String get taskIconLaw => 'Droit';

  @override
  String get taskIconLoupe => 'Loupe';

  @override
  String get taskIconMail => 'Courrier';

  @override
  String get taskIconMath => 'Maths';

  @override
  String get taskIconPaperclip => 'Trombone';

  @override
  String get taskIconPencil => 'Crayon';

  @override
  String get taskIconPencilAndRuler => 'Crayon et règle';

  @override
  String get taskIconPhysics => 'Physique';

  @override
  String get taskIconQuote => 'Citation';

  @override
  String get taskIconReminders => 'Rappels';

  @override
  String get taskIconRuler => 'Règle';

  @override
  String get taskIconSchool => 'École';

  @override
  String get taskIconScissors => 'Ciseaux';

  @override
  String get taskIconSignature => 'Signature';

  @override
  String get taskIconSpreadsheet => 'Tableur';

  @override
  String get taskIconStudentDesk => 'Pupitre';

  @override
  String get taskIconTask => 'Tâche';

  @override
  String get taskIconTestTube => 'Éprouvette';

  @override
  String get taskIconWriting => 'Écriture';

  @override
  String get taskIconZip => 'Archive ZIP';

  @override
  String get taskIconBattery => 'Batterie';

  @override
  String get taskIconCaptions => 'Sous-titres';

  @override
  String get taskIconComputerMouse => 'Souris d\'ordinateur';

  @override
  String get taskIconConnector => 'Connecteur';

  @override
  String get taskIconCpu => 'Processeur';

  @override
  String get taskIconCurlyBraces => 'Accolades';

  @override
  String get taskIconDesktop => 'Ordinateur de bureau';

  @override
  String get taskIconDial => 'Molette';

  @override
  String get taskIconDisk => 'Disquette';

  @override
  String get taskIconFax => 'Fax';

  @override
  String get taskIconFlashlight => 'Lampe torche';

  @override
  String get taskIconFlipphone => 'Téléphone à clapet';

  @override
  String get taskIconGears => 'Engrenages';

  @override
  String get taskIconGyroscope => 'Gyroscope';

  @override
  String get taskIconHardDrive => 'Disque dur';

  @override
  String get taskIconHeadphones => 'Casque audio';

  @override
  String get taskIconKeyboard => 'Clavier';

  @override
  String get taskIconLink => 'Lien';

  @override
  String get taskIconMerge => 'Fusion';

  @override
  String get taskIconMic => 'Micro';

  @override
  String get taskIconCall => 'Téléphone';

  @override
  String get taskIconPlug => 'Prise';

  @override
  String get taskIconPower => 'Marche/Arrêt';

  @override
  String get taskIconPrinter => 'Imprimante';

  @override
  String get taskIconScanner => 'Scanner';

  @override
  String get taskIconSdCard => 'Carte SD';

  @override
  String get taskIconSimcard => 'Carte SIM';

  @override
  String get taskIconSpeaker => 'Haut-parleur';

  @override
  String get taskIconTerminal => 'Terminal';

  @override
  String get taskIconUpload => 'Importer';

  @override
  String get taskIconVideoProjector => 'Vidéoprojecteur';

  @override
  String get taskIconWatch => 'Montre';

  @override
  String get taskIconWeb => 'Web';

  @override
  String get taskIconWifi => 'Wi-Fi';

  @override
  String get taskIconWifiRouter => 'Routeur Wi-Fi';

  @override
  String get taskIconWindows => 'Windows';

  @override
  String get taskIconTravel => 'Avion';

  @override
  String get taskIconArrival => 'Arrivée';

  @override
  String get taskIconArriving => 'Arrivée en cours';

  @override
  String get taskIconBackpack => 'Sac à dos';

  @override
  String get taskIconBeach => 'Plage';

  @override
  String get taskIconBike => 'Vélo';

  @override
  String get taskIconBoat => 'Bateau';

  @override
  String get taskIconBus => 'Bus';

  @override
  String get taskIconCablecar => 'Téléphérique';

  @override
  String get taskIconCar => 'Voiture';

  @override
  String get taskIconCase => 'Mallette';

  @override
  String get taskIconChineseCastle => 'Château chinois';

  @override
  String get taskIconColosseum => 'Colisée';

  @override
  String get taskIconCompass => 'Boussole';

  @override
  String get taskIconDeparture => 'Départ';

  @override
  String get taskIconDoubledeckerBus => 'Bus à impériale';

  @override
  String get taskIconElectricCar => 'Voiture électrique';

  @override
  String get taskIconEngine => 'Moteur';

  @override
  String get taskIconFerry => 'Ferry';

  @override
  String get taskIconGasStation => 'Station-service';

  @override
  String get taskIconGlobe => 'Globe';

  @override
  String get taskIconGlobeAmericas => 'Globe Amériques';

  @override
  String get taskIconGlobeAsia => 'Globe Asie';

  @override
  String get taskIconGlobeAsiaPacific => 'Globe Asie-Pacifique';

  @override
  String get taskIconGlobeEuropeAfrica => 'Globe Europe-Afrique';

  @override
  String get taskIconLeaving => 'Départ en cours';

  @override
  String get taskIconLifePreserver => 'Bouée de sauvetage';

  @override
  String get taskIconLightrail => 'Tramway';

  @override
  String get taskIconLocation => 'Position';

  @override
  String get taskIconLodge => 'Chalet';

  @override
  String get taskIconMap => 'Carte';

  @override
  String get taskIconMotorcycle => 'Moto';

  @override
  String get taskIconOilCan => 'Burette d\'huile';

  @override
  String get taskIconRoad => 'Route';

  @override
  String get taskIconRocket => 'Fusée';

  @override
  String get taskIconRollingSuitcase => 'Valise à roulettes';

  @override
  String get taskIconScooter => 'Trottinette';

  @override
  String get taskIconShip => 'Navire';

  @override
  String get taskIconSignpost => 'Panneau indicateur';

  @override
  String get taskIconSkiLift => 'Remontée mécanique';

  @override
  String get taskIconSteeringWheel => 'Volant';

  @override
  String get taskIconSubway => 'Métro';

  @override
  String get taskIconSuitcase => 'Valise';

  @override
  String get taskIconSuitcaseCart => 'Chariot à bagages';

  @override
  String get taskIconTent => 'Tente';

  @override
  String get taskIconTrain => 'Train';

  @override
  String get taskIconTruck => 'Camion';

  @override
  String get taskIconWindshield => 'Pare-brise';

  @override
  String get taskIconBarometer => 'Baromètre';

  @override
  String get taskIconCloud => 'Nuage';

  @override
  String get taskIconDrizzle => 'Bruine';

  @override
  String get taskIconFlame => 'Flamme';

  @override
  String get taskIconFlower => 'Fleur';

  @override
  String get taskIconFlowers => 'Fleurs';

  @override
  String get taskIconFog => 'Brouillard';

  @override
  String get taskIconFossil => 'Fossile';

  @override
  String get taskIconHail => 'Grêle';

  @override
  String get taskIconLeaf => 'Feuille';

  @override
  String get taskIconMoon => 'Lune';

  @override
  String get taskIconMoonHaze => 'Lune voilée';

  @override
  String get taskIconMountain => 'Montagne';

  @override
  String get taskIconMushroom => 'Champignon';

  @override
  String get taskIconPalmTree => 'Palmier';

  @override
  String get taskIconPartialSun => 'Éclaircies';

  @override
  String get taskIconPlant => 'Plante';

  @override
  String get taskIconRain => 'Pluie';

  @override
  String get taskIconRainbow => 'Arc-en-ciel';

  @override
  String get taskIconSeedling => 'Pousse';

  @override
  String get taskIconSleet => 'Neige fondue';

  @override
  String get taskIconSnow => 'Neige';

  @override
  String get taskIconSnowflake => 'Flocon de neige';

  @override
  String get taskIconSnowman => 'Bonhomme de neige';

  @override
  String get taskIconStorm => 'Tempête';

  @override
  String get taskIconSun => 'Soleil';

  @override
  String get taskIconSunHaze => 'Soleil voilé';

  @override
  String get taskIconSunrise => 'Lever du soleil';

  @override
  String get taskIconSunset => 'Coucher du soleil';

  @override
  String get taskIconTemperature => 'Température';

  @override
  String get taskIconThunderstorm => 'Orage';

  @override
  String get taskIconTree => 'Arbre';

  @override
  String get taskIconUmbrella => 'Parapluie';

  @override
  String get taskIconWaves => 'Vagues';

  @override
  String get taskIconWind => 'Vent';

  @override
  String get taskIconAnt => 'Fourmi';

  @override
  String get taskIconBird => 'Oiseau';

  @override
  String get taskIconBug => 'Insecte';

  @override
  String get taskIconCat => 'Chat';

  @override
  String get taskIconChicken => 'Poule';

  @override
  String get taskIconDog => 'Chien';

  @override
  String get taskIconFish => 'Poisson';

  @override
  String get taskIconHamster => 'Hamster';

  @override
  String get taskIconHorse => 'Cheval';

  @override
  String get taskIconMouse => 'Souris';

  @override
  String get taskIconPet => 'Patte';

  @override
  String get taskIconPetFoodBowl => 'Gamelle';

  @override
  String get taskIconPig => 'Cochon';

  @override
  String get taskIconRabbit => 'Lapin';

  @override
  String get taskIconTortoise => 'Tortue';

  @override
  String get taskIconWalkingCat => 'Chat qui marche';

  @override
  String get taskIconWalkingDog => 'Promenade du chien';

  @override
  String get taskIconBaby => 'Bébé';

  @override
  String get taskIconBabyBottle => 'Biberon';

  @override
  String get taskIconBallotBox => 'Urne';

  @override
  String get taskIconBrokenHeart => 'Cœur brisé';

  @override
  String get taskIconCouple => 'Couple';

  @override
  String get taskIconFamily => 'Famille';

  @override
  String get taskIconPeople => 'Groupe';

  @override
  String get taskIconHand => 'Main';

  @override
  String get taskIconHandshake => 'Poignée de main';

  @override
  String get taskIconMessage => 'Message';

  @override
  String get taskIconPerson => 'Personne';

  @override
  String get taskIconSignLanguage => 'Langue des signes';

  @override
  String get taskIconSmile => 'Sourire';

  @override
  String get taskIconStroller => 'Poussette';

  @override
  String get taskIconTwoPersons => 'Deux personnes';

  @override
  String get taskIconWaving => 'Salut de la main';

  @override
  String get taskIconAmplifier => 'Amplificateur';

  @override
  String get taskIconAperture => 'Ouverture';

  @override
  String get taskIconBinoculars => 'Jumelles';

  @override
  String get taskIconCamera => 'Appareil photo';

  @override
  String get taskIconCheckerboard => 'Damier';

  @override
  String get taskIconChess => 'Échiquier';

  @override
  String get taskIconClub => 'Trèfle';

  @override
  String get taskIconDice => 'Dés';

  @override
  String get taskIconDrums => 'Batterie (instrument)';

  @override
  String get taskIconEyedropper => 'Pipette';

  @override
  String get taskIconFilm => 'Film';

  @override
  String get taskIconFishing => 'Pêche';

  @override
  String get taskIconGaming => 'Jeux vidéo';

  @override
  String get taskIconGuitar => 'Guitare';

  @override
  String get taskIconHorn => 'Cor';

  @override
  String get taskIconHunting => 'Chasse';

  @override
  String get taskIconMagazine => 'Magazine';

  @override
  String get taskIconMagic => 'Magie';

  @override
  String get taskIconMetronome => 'Métronome';

  @override
  String get taskIconMovie => 'Cinéma';

  @override
  String get taskIconMovieClapper => 'Clap de cinéma';

  @override
  String get taskIconMusic => 'Musique';

  @override
  String get taskIconNewspaper => 'Journal';

  @override
  String get taskIconPaintPalette => 'Palette de peinture';

  @override
  String get taskIconPaintbrush => 'Pinceau';

  @override
  String get taskIconPhoto => 'Photo';

  @override
  String get taskIconPiano => 'Piano';

  @override
  String get taskIconPlayground => 'Aire de jeux';

  @override
  String get taskIconPuzzle => 'Puzzle';

  @override
  String get taskIconRadio => 'Radio';

  @override
  String get taskIconRecordingTape => 'Cassette';

  @override
  String get taskIconSewingMachine => 'Machine à coudre';

  @override
  String get taskIconSinging => 'Chant';

  @override
  String get taskIconSpade => 'Pique';

  @override
  String get taskIconSwatchPalette => 'Nuancier';

  @override
  String get taskIconTheater => 'Théâtre';

  @override
  String get taskIconTicket => 'Ticket';

  @override
  String get taskIconTuning => 'Accordeur';

  @override
  String get taskIconTv => 'Télé';

  @override
  String get taskIconBag => 'Sac';

  @override
  String get taskIconBanknote => 'Billet';

  @override
  String get taskIconBarcode => 'Code-barres';

  @override
  String get taskIconBasket => 'Panier';

  @override
  String get taskIconBitcoin => 'Bitcoin';

  @override
  String get taskIconCart => 'Chariot';

  @override
  String get taskIconCoin => 'Pièce';

  @override
  String get taskIconCreditcard => 'Carte bancaire';

  @override
  String get taskIconEuro => 'Euro';

  @override
  String get taskIconGift => 'Cadeau';

  @override
  String get taskIconGiftcard => 'Carte cadeau';

  @override
  String get taskIconMoney => 'Argent';

  @override
  String get taskIconParcel => 'Colis';

  @override
  String get taskIconStorefront => 'Boutique';

  @override
  String get taskIconTag => 'Étiquette';

  @override
  String get taskIconWalletPass => 'Carte Wallet';

  @override
  String get taskIconClothesHanger => 'Cintre';

  @override
  String get taskIconDiamond => 'Diamant';

  @override
  String get taskIconDress => 'Robe';

  @override
  String get taskIconGlasses => 'Lunettes';

  @override
  String get taskIconHairDresser => 'Coiffeur';

  @override
  String get taskIconHairdryer => 'Sèche-cheveux';

  @override
  String get taskIconHat => 'Chapeau';

  @override
  String get taskIconJacket => 'Veste';

  @override
  String get taskIconMustache => 'Moustache';

  @override
  String get taskIconPurse => 'Sac à main';

  @override
  String get taskIconRazor => 'Rasoir';

  @override
  String get taskIconRing => 'Bague';

  @override
  String get taskIconShoe => 'Chaussure';

  @override
  String get taskIconShoes => 'Chaussures';

  @override
  String get taskIconSkinCare => 'Soins de la peau';

  @override
  String get taskIconSunglasses => 'Lunettes de soleil';

  @override
  String get taskIconTShirt => 'T-shirt';

  @override
  String get taskIconTrousers => 'Pantalon';

  @override
  String get taskIconWinterJacket => 'Doudoune';

  @override
  String get taskIconBalloons => 'Ballons';

  @override
  String get taskIconBirthday => 'Anniversaire';

  @override
  String get taskIconBuddhism => 'Bouddhisme';

  @override
  String get taskIconCandle => 'Bougie';

  @override
  String get taskIconChristmasTree => 'Sapin de Noël';

  @override
  String get taskIconChurch => 'Église';

  @override
  String get taskIconCross => 'Croix';

  @override
  String get taskIconFireworks => 'Feu d\'artifice';

  @override
  String get taskIconGhost => 'Fantôme';

  @override
  String get taskIconGravestone => 'Pierre tombale';

  @override
  String get taskIconHalloween => 'Halloween';

  @override
  String get taskIconHinduism => 'Hindouisme';

  @override
  String get taskIconIslam => 'Islam';

  @override
  String get taskIconJudaism => 'Judaïsme';

  @override
  String get taskIconMosque => 'Mosquée';

  @override
  String get taskIconParty => 'Fête';

  @override
  String get taskIconPray => 'Prière';

  @override
  String get taskIconTaoism => 'Taoïsme';

  @override
  String get taskIconAlarm => 'Alarme';

  @override
  String get taskIconBarChart => 'Graphique à barres';

  @override
  String get taskIconBell => 'Cloche';

  @override
  String get taskIconBolt => 'Éclair';

  @override
  String get taskIconBubble => 'Bulle';

  @override
  String get taskIconBubbles => 'Bulles';

  @override
  String get taskIconClock => 'Horloge';

  @override
  String get taskIconCrown => 'Couronne';

  @override
  String get taskIconCube => 'Cube';

  @override
  String get taskIconDanger => 'Danger';

  @override
  String get taskIconError => 'Erreur';

  @override
  String get taskIconExplosion => 'Explosion';

  @override
  String get taskIconFemaleSymbol => 'Symbole féminin';

  @override
  String get taskIconFilters => 'Filtres';

  @override
  String get taskIconFlag => 'Drapeau';

  @override
  String get taskIconHashtag => 'Hashtag';

  @override
  String get taskIconHazardSign => 'Panneau de danger';

  @override
  String get taskIconHourglass => 'Sablier';

  @override
  String get taskIconLineChart => 'Graphique linéaire';

  @override
  String get taskIconLineChartDown => 'Graphique en baisse';

  @override
  String get taskIconLineChartUp => 'Graphique en hausse';

  @override
  String get taskIconLocked => 'Verrouillé';

  @override
  String get taskIconMaleSymbol => 'Symbole masculin';

  @override
  String get taskIconMegaphone => 'Mégaphone';

  @override
  String get taskIconMenu => 'Menu';

  @override
  String get taskIconMinus => 'Moins';

  @override
  String get taskIconNonBinarySymbol => 'Symbole non binaire';

  @override
  String get taskIconPeace => 'Paix';

  @override
  String get taskIconPieChart => 'Graphique circulaire';

  @override
  String get taskIconPin => 'Épingle';

  @override
  String get taskIconPlus => 'Plus';

  @override
  String get taskIconQrCode => 'Code QR';

  @override
  String get taskIconQuestion => 'Question';

  @override
  String get taskIconSearch => 'Recherche';

  @override
  String get taskIconShield => 'Bouclier';

  @override
  String get taskIconSkull => 'Crâne';

  @override
  String get taskIconSpeed => 'Vitesse';

  @override
  String get taskIconStar => 'Étoile';

  @override
  String get taskIconTarget => 'Cible';

  @override
  String get taskIconThumbsDown => 'Pouce vers le bas';

  @override
  String get taskIconThumbsUp => 'Pouce levé';

  @override
  String get taskIconTimer => 'Minuteur';

  @override
  String get taskIconTransgenderSymbol => 'Symbole transgenre';

  @override
  String get taskIconTransparentCube => 'Cube transparent';

  @override
  String get taskIconUnlock => 'Déverrouiller';

  @override
  String get taskIconWarning => 'Avertissement';

  @override
  String get taskIconWrongWaySign => 'Sens interdit';

  @override
  String get taskIconCircle => 'Simple';
}
