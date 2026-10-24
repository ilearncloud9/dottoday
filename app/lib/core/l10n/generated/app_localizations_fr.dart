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
  String get iconCircle => 'Simple';

  @override
  String get iconCall => 'Appel';

  @override
  String get iconMail => 'E-mail';

  @override
  String get iconCode => 'Code';

  @override
  String get iconBook => 'Lecture';

  @override
  String get iconGym => 'Sport';

  @override
  String get iconRun => 'Course';

  @override
  String get iconMeal => 'Repas';

  @override
  String get iconHeart => 'Santé';

  @override
  String get iconHome => 'Maison';

  @override
  String get iconMusic => 'Musique';

  @override
  String get iconPet => 'Animal';

  @override
  String get iconStar => 'Étoile';

  @override
  String get iconList => 'Liste';

  @override
  String get iconLanguage => 'Langue';

  @override
  String get iconTravel => 'Voyage';

  @override
  String get iconCart => 'Chariot';

  @override
  String get iconTv => 'TV';

  @override
  String get iconBag => 'Sac de courses';

  @override
  String get iconMeds => 'Médicaments';

  @override
  String get iconWater => 'Eau';

  @override
  String get iconCar => 'Voiture';

  @override
  String get iconMoney => 'Argent';

  @override
  String get iconGift => 'Cadeau';

  @override
  String get iconCamera => 'Appareil photo';

  @override
  String get iconPeople => 'Personnes';

  @override
  String get iconDocument => 'Document';

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
  String resizeLabel(String title) {
    return 'Modifier la durée de $title';
  }

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
  String snackResized(String title, String time) {
    return '$title se termine maintenant à $time';
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
}
