// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Dottoday';

  @override
  String get failureStorage =>
      'No se pudo guardar en este dispositivo. Inténtalo de nuevo.';

  @override
  String get failureNetworkOffline =>
      'Estás sin conexión. Los cambios se guardan en este dispositivo y se sincronizarán más tarde.';

  @override
  String get failureNetworkTimeout =>
      'El servidor tardó demasiado en responder. Inténtalo de nuevo.';

  @override
  String get failureNetworkServer =>
      'El servidor tuvo un problema. Tus datos están a salvo en este dispositivo.';

  @override
  String get failureAuth =>
      'Tu sesión ha terminado. Vuelve a iniciar sesión para seguir sincronizando.';

  @override
  String get failureValidationRequired => 'Este campo no puede estar vacío.';

  @override
  String get failureValidationTooLong =>
      'Es demasiado largo. Prueba con algo más corto.';

  @override
  String get failureValidationOutOfRange =>
      'Ese valor está fuera del rango permitido.';

  @override
  String get failureValidationInvalidFormat =>
      'Eso no parece correcto. Revisa el formato.';

  @override
  String get failureValidationTooLarge => 'Ese archivo es demasiado grande.';

  @override
  String get failureNotFound => 'Este elemento ya no existe.';

  @override
  String get failureConflict =>
      'Este elemento cambió en otro dispositivo. Elige qué versión conservar.';

  @override
  String get failurePermissionNotifications =>
      'Las notificaciones de Dottoday están desactivadas. Puedes activarlas en los ajustes del sistema.';

  @override
  String get failurePermissionCalendar =>
      'Dottoday no puede ver tus calendarios. Puedes permitir el acceso en los ajustes del sistema.';

  @override
  String get failureUndoExpired =>
      'Ya no se puede deshacer. Las tareas eliminadas permanecen en la papelera 30 días.';

  @override
  String get failureUnexpected => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get navToday => 'Hoy';

  @override
  String get navInbox => 'Bandeja de entrada';

  @override
  String get navWeek => 'Semana';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get quickAddTooltip => 'Añadir tarea';

  @override
  String get sheetClose => 'Cerrar';

  @override
  String get timeInputLabel => 'Hora';

  @override
  String get timeInputHint => 'p. ej., 9:30 o 14:00';

  @override
  String get timeInputInvalid => 'Escribe una hora como 9:30 o 14:00';

  @override
  String get timeInputWheel => 'Elegir hora con una rueda';

  @override
  String get timeInputDone => 'Hecho';

  @override
  String get durationLabel => 'Duración';

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
  String get durationCustom => 'Personalizada';

  @override
  String get durationCustomHint => 'p. ej., 40 min o 1h30';

  @override
  String get durationCustomInvalid => 'Usa de 5 min a 24 h, como 40 min o 1h30';

  @override
  String get colorCoral => 'Coral';

  @override
  String get colorAmber => 'Ámbar';

  @override
  String get colorMint => 'Menta';

  @override
  String get colorTeal => 'Verde azulado';

  @override
  String get colorSky => 'Cielo';

  @override
  String get colorIndigo => 'Índigo';

  @override
  String get colorViolet => 'Violeta';

  @override
  String get colorRose => 'Rosa';

  @override
  String get colorSlate => 'Pizarra';

  @override
  String get iconCircle => 'Simple';

  @override
  String get iconCall => 'Llamada';

  @override
  String get iconMail => 'Correo';

  @override
  String get iconCode => 'Código';

  @override
  String get iconBook => 'Lectura';

  @override
  String get iconGym => 'Gimnasio';

  @override
  String get iconRun => 'Correr';

  @override
  String get iconMeal => 'Comida';

  @override
  String get iconHeart => 'Salud';

  @override
  String get iconHome => 'Casa';

  @override
  String get iconMusic => 'Música';

  @override
  String get iconPet => 'Mascota';

  @override
  String get iconStar => 'Estrella';

  @override
  String get iconList => 'Lista';

  @override
  String get iconLanguage => 'Idioma';

  @override
  String get iconTravel => 'Viaje';

  @override
  String get iconCart => 'Carrito de compra';

  @override
  String get iconTv => 'TV';

  @override
  String get iconBag => 'Bolsa de compra';

  @override
  String get iconMeds => 'Medicación';

  @override
  String get iconWater => 'Agua';

  @override
  String get iconCar => 'Coche';

  @override
  String get iconMoney => 'Dinero';

  @override
  String get iconGift => 'Regalo';

  @override
  String get iconCamera => 'Cámara';

  @override
  String get iconPeople => 'Personas';

  @override
  String get iconDocument => 'Documento';

  @override
  String get undoAction => 'Deshacer';

  @override
  String get syncLocalOnly => 'En este dispositivo';

  @override
  String get syncSynced => 'Sincronizado';

  @override
  String get syncSyncing => 'Sincronizando';

  @override
  String get syncOffline => 'Sin conexión';

  @override
  String get syncError => 'Problema de sincronización';

  @override
  String timelineNow(String time) {
    return 'Ahora, $time';
  }

  @override
  String timelineBeforeHours(String time) {
    return 'Antes de las $time';
  }

  @override
  String timelineAfterHours(String time) {
    return 'Después de las $time';
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
      other: '$count bloques más',
      one: '1 bloque más',
    );
    return '$_temp0';
  }

  @override
  String get timelineAllDay => 'Todo el día';

  @override
  String blockTimeRange(String start, String end) {
    return '$start–$end';
  }

  @override
  String blockSemantics(String title, String start, String end) {
    return '$title, de $start a $end';
  }

  @override
  String get timelineMenu => 'Más opciones';

  @override
  String get debugLoadDemoDay => 'Cargar día de demostración (debug)';

  @override
  String get debugDemoDayLoaded => 'Día de demostración cargado';

  @override
  String get semanticsSeparator => ', ';

  @override
  String get blockDone => 'hecha';

  @override
  String get blockNotDoneYet => 'aún sin hacer';

  @override
  String blockSubtasks(int done, int total) {
    return '$done de $total subtareas hechas';
  }

  @override
  String blockSubtasksShort(int done, int total) {
    return '$done/$total';
  }

  @override
  String get blockRecurring => 'periódica';

  @override
  String get blockPinned => 'fijada';

  @override
  String get blockFromCalendar => 'de tu calendario';

  @override
  String blockAlerts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avisos',
      one: '1 aviso',
    );
    return '$_temp0';
  }

  @override
  String get blockStartsBefore => 'continúa del día anterior';

  @override
  String get blockEndsAfter => 'continúa al día siguiente';

  @override
  String blockMarkDone(String title) {
    return 'Marcar $title como hecha';
  }

  @override
  String blockMarkNotDone(String title) {
    return 'Marcar $title como sin hacer';
  }

  @override
  String get undoMarkedDone => 'Marcada como hecha';

  @override
  String get undoMarkedNotDone => 'Marcada como sin hacer';

  @override
  String dotUpcoming(String title) {
    return '$title, próxima';
  }

  @override
  String dotLive(String title) {
    return '$title, en curso';
  }

  @override
  String dotLiveLeft(String title, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'quedan $minutes minutos',
      one: 'queda 1 minuto',
    );
    return '$title, en curso, $_temp0';
  }

  @override
  String dotDone(String title) {
    return '$title, hecha';
  }

  @override
  String dotSkipped(String title) {
    return '$title, omitida';
  }

  @override
  String dotMissed(String title) {
    return '$title, sin hacer';
  }

  @override
  String get dotMarkDoneHint => 'Marcar como hecha';

  @override
  String get dotMarkNotDoneHint => 'Marcar como sin hacer';

  @override
  String rowLabel(String title, String range) {
    return '$title, $range';
  }

  @override
  String rowMissed(String label) {
    return '$label, sin hacer';
  }

  @override
  String rowPinned(String label) {
    return '$label, fijada';
  }

  @override
  String rowRepeats(String label) {
    return '$label, se repite';
  }

  @override
  String get rowMissedMeta => '· sin hacer';

  @override
  String threadWake(String time) {
    return 'Despertar · $time';
  }

  @override
  String threadBed(String time) {
    return 'Hora de dormir · $time';
  }

  @override
  String threadFree(String duration) {
    return '$duration libre';
  }

  @override
  String threadAddHere(String duration) {
    return '$duration libre · añadir aquí';
  }

  @override
  String threadAddHereLabel(String duration, String time) {
    return '$duration libre desde las $time. Añade una tarea aquí';
  }

  @override
  String liveSubtasks(int done, int total) {
    return '$done de $total';
  }

  @override
  String liveMinutesLeft(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'quedan $minutes min',
      one: 'queda 1 min',
    );
    return '$_temp0';
  }

  @override
  String get liveDone => 'Hecho';

  @override
  String get liveExtend => '+15 min';

  @override
  String get liveShiftRest => 'Desplazar el resto';

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
    return 'Día al $percent %';
  }

  @override
  String get weekStripShowMonth => 'Mostrar mes';

  @override
  String get weekStripHideMonth => 'Ocultar mes';

  @override
  String get dayCardTodaySuffix => ' · Hoy';

  @override
  String dayCardSummary(int done, int total, String planned) {
    return '$done de $total · $planned planificado';
  }

  @override
  String dayCardNothing(String free) {
    return 'Nada planificado · $free libre';
  }

  @override
  String dayPagerPosition(int position, int count) {
    return 'Día $position de $count';
  }

  @override
  String monthMore(int count) {
    return '+$count más';
  }

  @override
  String monthDoneOf(int done, int total) {
    return '$done de $total hechas';
  }

  @override
  String get monthLightDay => 'Día ligero';

  @override
  String monthMissedItem(String title) {
    return '$title · sin hacer';
  }

  @override
  String monthNowItem(String title) {
    return '$title · ahora';
  }

  @override
  String threadTimeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get debugConceptPreview => 'Vista previa del concepto A (debug)';

  @override
  String todayGreeting(String part) {
    String _temp0 = intl.Intl.selectLogic(part, {
      'morning': 'Buenos días',
      'afternoon': 'Buenas tardes',
      'other': 'Buenas noches',
    });
    return '$_temp0';
  }

  @override
  String todayGreetingName(String part, String name) {
    String _temp0 = intl.Intl.selectLogic(part, {
      'morning': 'Buenos días, $name',
      'afternoon': 'Buenas tardes, $name',
      'other': 'Buenas noches, $name',
    });
    return '$_temp0';
  }

  @override
  String get todayEmpty =>
      'Nada planificado · desliza la tira para planificar o toca +';

  @override
  String get todayAllDay => 'Todo el día';

  @override
  String stripDayLabel(String day, int done, int total) {
    return '$day, $done de $total hechas';
  }

  @override
  String monthFooterPlanned(String month, int count, int days) {
    return '$month · $count de $days días planificados';
  }

  @override
  String monthDaysPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días planificados',
      one: '1 día planificado',
    );
    return '$_temp0';
  }

  @override
  String get monthLegendPlanned => 'planificado';

  @override
  String get monthLegendRepeats => 'se repite';

  @override
  String monthNav(String previous, String current, String next) {
    return '$previous · $current · $next';
  }

  @override
  String get monthPrevious => 'Mes anterior';

  @override
  String get monthNext => 'Mes siguiente';

  @override
  String get todayPill => 'Hoy';

  @override
  String monthCellLabel(String day, int done, int total) {
    return '$day, $done de $total hechas';
  }

  @override
  String get emptyAddToDay => 'Añadir a este día';

  @override
  String emptyPullInbox(int count) {
    return 'Traer de la bandeja · $count';
  }

  @override
  String get emptyCopyDay => 'Copiar un día…';

  @override
  String get copyDayTitle => '¿Qué día copiar?';

  @override
  String copyDayDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas copiadas',
      one: '1 tarea copiada',
    );
    return '$_temp0';
  }

  @override
  String get copyDayNothing => 'Ese día no tiene nada que copiar';

  @override
  String snackDone(String title) {
    return '$title hecha';
  }

  @override
  String snackNotDone(String title) {
    return '$title sin hacer';
  }

  @override
  String snackExtended(String title, String time) {
    return '$title ahora termina a las $time';
  }

  @override
  String snackShifted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas movidas',
      one: '1 tarea movida',
    );
    return '$_temp0';
  }

  @override
  String snackShiftedPartial(int count, String pin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas movidas · detenido en $pin (fijada)',
      one: '1 tarea movida · detenido en $pin (fijada)',
      zero: 'Nada movido: $pin está fijada',
    );
    return '$_temp0';
  }

  @override
  String sheetMetaDay(String day, String range, String duration) {
    return '$day · $range · $duration';
  }

  @override
  String get sheetToday => 'Hoy';

  @override
  String get sheetTomorrow => 'Mañana';

  @override
  String get sheetInbox => 'Bandeja de entrada';

  @override
  String get sheetDone => 'Hecho';

  @override
  String get sheetUndone => 'Sin hacer';

  @override
  String get sheetExtend => '+15 min';

  @override
  String get sheetShift => 'Desplazar';

  @override
  String get sheetMove => 'Mover';

  @override
  String get sheetEdit => 'Editar';

  @override
  String sheetSubtasks(int done, int total) {
    return 'Subtareas · $done de $total';
  }

  @override
  String get sheetSubtasksNone => 'Subtareas';

  @override
  String get sheetAddSubtask => '+ Añadir';

  @override
  String get sheetNewSubtask => 'Nueva subtarea';

  @override
  String get sheetAlerts => 'Avisos';

  @override
  String get sheetRepeat => 'Repetir';

  @override
  String get sheetLook => 'Color e icono';

  @override
  String get sheetNever => 'Nunca';

  @override
  String get sheetNoAlerts => 'Ninguno';

  @override
  String get sheetNotFound => 'Esta tarea ya no está aquí';

  @override
  String get alertAtStart => 'al empezar';

  @override
  String get alertAtEnd => 'al terminar';

  @override
  String alertBefore(int minutes) {
    return '$minutes min antes';
  }

  @override
  String alertOverdue(int minutes) {
    return '$minutes min después del final';
  }

  @override
  String alertJoin(String first, String rest) {
    return '$first · $rest';
  }

  @override
  String get repeatDaily => 'Cada día';

  @override
  String get repeatWeekdays => 'Entre semana';

  @override
  String repeatWeekly(String days) {
    return 'Cada semana el $days';
  }

  @override
  String get repeatMonthly => 'Cada mes';

  @override
  String get repeatYearly => 'Cada año';

  @override
  String get repeatCustom => 'Personalizado';

  @override
  String listJoin(String first, String rest) {
    return '$first, $rest';
  }

  @override
  String sheetLeftSuffix(String left) {
    return ' · $left';
  }

  @override
  String get colourIconCaption => 'Color e icono';

  @override
  String get colourIconMore => 'Todos los iconos';

  @override
  String get editorCaption => 'Editar tarea';

  @override
  String get editorTitleHint => '¿Qué es?';

  @override
  String get editorWhen => 'Cuándo';

  @override
  String get editorStart => 'Inicio';

  @override
  String editorEndsAt(String time) {
    return '→ $time';
  }

  @override
  String get editorDuration => 'Duración';

  @override
  String get editorNotes => 'Notas';

  @override
  String get editorNotesHint => 'Añadir notas';

  @override
  String get editorSave => 'Guardar';

  @override
  String get editorMoveToInbox => 'Mover a la bandeja';

  @override
  String get editorDelete => 'Eliminar tarea';

  @override
  String editorDeleteConfirm(String title) {
    return '¿Eliminar “$title”?';
  }

  @override
  String get editorDeleteBody =>
      'Irá a la papelera durante 30 días. Puedes deshacerlo justo después.';

  @override
  String get editorCancel => 'Cancelar';

  @override
  String snackDeleted(String title) {
    return '$title eliminada';
  }

  @override
  String snackMovedToInbox(String title) {
    return '$title movida a la bandeja';
  }

  @override
  String get editorPickDay => 'Elige un día';

  @override
  String resizeLabel(String title) {
    return 'Cambiar cuánto dura $title';
  }

  @override
  String dragDropAt(String time) {
    return '→ $time';
  }

  @override
  String snackMoved(String title, String time) {
    return '$title movida a las $time';
  }

  @override
  String snackMovedDay(String title, String day) {
    return '$title movida a $day';
  }

  @override
  String snackResized(String title, String time) {
    return '$title ahora termina a las $time';
  }

  @override
  String get shiftChipLabel => 'Mover las siguientes';

  @override
  String get shiftChipCalendar => 'También eventos del calendario';

  @override
  String snackMovedShifted(String title, String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title movida a las $time · $count tareas posteriores también',
      one: '$title movida a las $time · 1 tarea posterior también',
      zero: '$title movida a las $time',
    );
    return '$_temp0';
  }

  @override
  String snackMovedShiftedPartial(String title, String time, String pin) {
    return '$title movida a las $time · detenido en $pin (fijada)';
  }

  @override
  String get selectAction => 'Seleccionar';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionadas',
      one: '1 seleccionada',
    );
    return '$_temp0';
  }

  @override
  String get selectionClose => 'Terminar selección';

  @override
  String get selectionMove => 'Mover';

  @override
  String get selectionMoveTitle => 'Mover a';

  @override
  String get selectionDuplicate => 'Duplicar';

  @override
  String get selectionColour => 'Color';

  @override
  String get selectionDelete => 'Eliminar';

  @override
  String selectionDeleteConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar $count tareas?',
      one: '¿Eliminar 1 tarea?',
    );
    return '$_temp0';
  }

  @override
  String snackManyMoved(int count, String day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas movidas a $day',
      one: '1 tarea movida a $day',
    );
    return '$_temp0';
  }

  @override
  String snackManyDuplicated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas duplicadas',
      one: '1 tarea duplicada',
    );
    return '$_temp0';
  }

  @override
  String snackManyRecoloured(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Color cambiado en $count tareas',
      one: 'Color cambiado en 1 tarea',
    );
    return '$_temp0';
  }

  @override
  String snackManyDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas movidas a la papelera',
      one: '1 tarea movida a la papelera',
    );
    return '$_temp0';
  }

  @override
  String get inboxSchedule => 'Programar';

  @override
  String get inboxTrash => 'Mover a la papelera';

  @override
  String inboxRowLabel(String title, String length) {
    return '$title, $length';
  }

  @override
  String inboxSummary(int count, String work) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sin programar',
      one: '1 sin programar',
    );
    return '$_temp0 · $work de trabajo';
  }

  @override
  String inboxRingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas en la bandeja',
      one: '1 tarea en la bandeja',
      zero: 'Bandeja vacía',
    );
    return '$_temp0';
  }

  @override
  String get inboxAddHint => 'Llamar a mamá mañana 15:00 20 min';

  @override
  String get inboxAddLabel => 'Añadir una tarea';

  @override
  String get inboxFilterAll => 'Todas';

  @override
  String get inboxFilterUnder30 => 'Menos de 30 min';

  @override
  String get inboxFilterFits => 'Cabe hoy';

  @override
  String inboxNextSlot(String range, String title) {
    return 'Próximo hueco libre hoy: $range · cabe $title';
  }

  @override
  String get inboxPlace => 'Colocar';

  @override
  String inboxCompleted(int count) {
    return 'Completadas · $count';
  }

  @override
  String get inboxEmpty => 'La bandeja está vacía';

  @override
  String get inboxNoMatch => 'Nada encaja con este filtro';

  @override
  String get inboxUntitled => 'Nueva tarea';

  @override
  String inboxScheduleTitle(String title) {
    return 'Programar $title';
  }

  @override
  String inboxScheduleToday(String range) {
    return 'Hoy, $range';
  }

  @override
  String inboxScheduleTomorrow(String range) {
    return 'Mañana, $range';
  }

  @override
  String get inboxScheduleNone =>
      'No hay huecos libres hoy ni mañana. Haz sitio en Hoy o arrástrala desde la semana.';

  @override
  String snackScheduled(String title, String when) {
    return '$title programada para $when';
  }

  @override
  String snackAddedInbox(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas añadidas',
      one: '$title añadida a la bandeja',
    );
    return '$_temp0';
  }

  @override
  String snackAddedTimed(String title, String when) {
    return '$title añadida para $when';
  }

  @override
  String snackTrashed(String title) {
    return '$title movida a la papelera';
  }

  @override
  String get addTitleLabel => 'Título';

  @override
  String get addTypeTimeHint =>
      'Escribe también una hora: ‘Ir de compras 17:00 1 h’';

  @override
  String addRemoveToken(String token) {
    return 'Quitar “$token”';
  }

  @override
  String get addSuggestions => 'Sugerencias';

  @override
  String get addFromHabits => 'según tus hábitos';

  @override
  String addHabitUsual(String range, String length) {
    return 'normalmente $range · $length';
  }

  @override
  String addHabitNoTime(String length) {
    return 'sin hora fija · $length';
  }

  @override
  String addHabitLabel(String title, String meta) {
    return '$title, $meta';
  }

  @override
  String get addContinue => 'Continuar';

  @override
  String get addToInbox => 'Añadir a la bandeja';

  @override
  String addStepOf(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get addBack => 'Atrás';

  @override
  String addWhenOnDay(String day, String time) {
    return '$day, $time';
  }

  @override
  String get pickerLabel => 'Hora de inicio';

  @override
  String addWhenSummary(String day, String range, String length) {
    return '$day · $range · $length';
  }

  @override
  String get addTimeCaption => 'Hora';

  @override
  String get addDurationCaption => 'Duración';

  @override
  String addFreeUntil(String time) {
    return 'Libre hasta las $time · sin solapes';
  }

  @override
  String addOverlaps(int count, String title, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se solapa con $title y $others más',
      one: 'Se solapa con $title',
    );
    return '$_temp0 · puedes añadirla igualmente';
  }

  @override
  String addLandsOn(String day, String range) {
    return 'Irá el $day a las $range';
  }

  @override
  String get addSlotFree => 'el hueco está libre';

  @override
  String addSlotBusy(String title) {
    return 'se solapa con $title';
  }

  @override
  String get addAdd => 'Añadir';

  @override
  String get addAnother => 'Añadir otra';

  @override
  String durationChipMinutes(int minutes) {
    return '$minutes';
  }

  @override
  String durationChipHours(String hours) {
    return '$hours h';
  }

  @override
  String get inboxPickTime => 'Elegir una hora…';

  @override
  String get durationSheetTitle => 'Duración';

  @override
  String get durationTypeLabel => 'O escribe una duración';

  @override
  String durationEnds(String time) {
    return 'termina a las $time';
  }

  @override
  String durationFitsBefore(String title, String time) {
    return 'Aún cabe antes de $title a las $time';
  }

  @override
  String durationFitsBedtime(String time) {
    return 'Cabe antes de la hora de dormir, a las $time';
  }

  @override
  String durationRunsInto(String title, String time) {
    return 'Se solapa con $title a las $time';
  }

  @override
  String durationPastBedtime(String time) {
    return 'Pasa de la hora de dormir, a las $time';
  }

  @override
  String get durationPresets => 'Predefinidas';

  @override
  String get durationReset => 'Restablecer';

  @override
  String get durationAddPreset => 'predefinida';

  @override
  String get durationAddPresetLabel => 'Guardar esta duración como predefinida';

  @override
  String durationRemovePreset(String length) {
    return 'Quitar la duración predefinida de $length';
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
  String get addMoreTime => 'Más opciones de hora';

  @override
  String get addMoreDuration => 'Más duraciones';

  @override
  String get timeMenuChangeDay => 'Cambiar día';

  @override
  String get timeMenuPickWeek => 'Elegir de la semana';

  @override
  String get timeMenuAllDay => 'Hacerla de todo el día';

  @override
  String get timeMenuTimed => 'Ponerle una hora';

  @override
  String get timeMenuInbox => 'Enviar a la bandeja';

  @override
  String get timeMenuZone => 'Zona horaria';

  @override
  String get timeMenuType => 'Escribir una hora';

  @override
  String get zoneSearch => 'Busca una ciudad o zona';

  @override
  String get weekPrevious => 'Semana anterior';

  @override
  String get weekNext => 'Semana siguiente';

  @override
  String get addAllDay => 'Todo el día';

  @override
  String get addLandsOnEdit => 'Editar';

  @override
  String addLandsOnAllDay(String day) {
    return 'Irá el $day · todo el día';
  }

  @override
  String pasteAsk(int count) {
    return '¿Añadir $count tareas?';
  }

  @override
  String pasteAdd(int count) {
    return 'Añadir $count';
  }

  @override
  String get pasteKeep => 'Dejar como una';

  @override
  String get searchSubtitle => 'Todo lo que has planificado';

  @override
  String get searchFieldLabel => 'Buscar en títulos, notas y subtareas';

  @override
  String get searchClear => 'Borrar búsqueda';

  @override
  String searchRingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
      zero: 'Sin resultados',
    );
    return '$_temp0';
  }

  @override
  String get searchFilterAll => 'Todo';

  @override
  String get searchFilterToday => 'Hoy';

  @override
  String get searchFilterWeek => 'Esta semana';

  @override
  String get searchFilterInbox => 'Bandeja';

  @override
  String get searchFilterDone => 'Hechas';

  @override
  String get searchFilterColour => 'Color';

  @override
  String get searchFilterIcon => 'Icono';

  @override
  String get searchPickColour => 'Mostrar un color';

  @override
  String get searchPickIcon => 'Mostrar un icono';

  @override
  String searchGroupToday(String weekday) {
    return '$weekday · Hoy';
  }

  @override
  String get searchGroupInbox => 'Bandeja de entrada';

  @override
  String searchMetaDay(String day, String range) {
    return '$day · $range';
  }

  @override
  String searchMetaDone(String when) {
    return '$when · Hecha';
  }

  @override
  String searchMetaMissed(String when) {
    return '$when · sin hacer';
  }

  @override
  String searchMetaInbox(String length) {
    return 'Bandeja · $length';
  }

  @override
  String searchRowLabel(String title, String meta) {
    return '$title, $meta';
  }

  @override
  String get searchRecent => 'Recientes';

  @override
  String searchRecentLabel(String query) {
    return 'Volver a buscar $query';
  }

  @override
  String get searchEmpty =>
      'Encuentra todo lo que has planificado: títulos, notas y subtareas, también las hechas.';

  @override
  String searchNoResults(String query) {
    return 'No hay resultados para “$query”';
  }

  @override
  String get searchNoResultsHint => 'Prueba con menos palabras u otro filtro.';

  @override
  String get searchShowAll => 'Mostrar todo';

  @override
  String searchDayLabel(String weekday, String date) {
    return '$weekday $date';
  }

  @override
  String settingsLocalOnly(String name) {
    return '$name · en este dispositivo';
  }

  @override
  String get settingsLocalOnlyNoName => 'En este dispositivo';

  @override
  String settingsAvatarLabel(String name) {
    return 'Cuenta: $name';
  }

  @override
  String get settingsDayShape => 'Forma del día';

  @override
  String settingsAwake(String length) {
    return '$length despierto';
  }

  @override
  String get settingsWakeUp => 'Despertar';

  @override
  String get settingsBedtime => 'Hora de dormir';

  @override
  String get settingsPerWeekday => 'Días distintos';

  @override
  String get settingsSameEveryDay => 'Igual todos los días';

  @override
  String settingsCustomDays(String days) {
    return '$days';
  }

  @override
  String get settingsUseEveryday => 'Igual que todos los días';

  @override
  String get settingsWeekStarts => 'La semana empieza';

  @override
  String get settingsTimeFormat => 'Formato de hora';

  @override
  String settingsTimeSystem(String example) {
    return 'Dispositivo ($example)';
  }

  @override
  String get settingsTime12 => '12 h';

  @override
  String get settingsTime24 => '24 h';

  @override
  String get settingsPlanning => 'Planificación';

  @override
  String get settingsDefaultDuration => 'Duración predeterminada';

  @override
  String get settingsSnap => 'Ajustar a';

  @override
  String settingsSnapValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsShiftLater => 'Mover las siguientes';

  @override
  String get settingsShiftAsk => 'Preguntar cada vez';

  @override
  String get settingsShiftAlways => 'Siempre';

  @override
  String get settingsShiftNever => 'Nunca';

  @override
  String get settingsShowFree => 'Mostrar tiempo libre';

  @override
  String get settingsShowFreeDetail => 'Huecos punteados en el hilo';

  @override
  String get settingsLateNudge => 'Aviso de retraso';

  @override
  String get settingsLateNudgeDetail => 'Ofrecer mover el resto del día';

  @override
  String get settingsRoll => 'Pasar lo pendiente a mañana';

  @override
  String get settingsRollDetail => 'Si no, vuelve a la bandeja';

  @override
  String get settingsReminders => 'Recordatorios';

  @override
  String get settingsTaskStarts => 'Al empezar una tarea';

  @override
  String get settingsAlertNone => 'Sin aviso';

  @override
  String get settingsAlertAtStart => 'Al empezar';

  @override
  String settingsAlertBefore(int minutes) {
    return '$minutes min antes';
  }

  @override
  String get settingsBedtimeReminder => 'Recordatorio para dormir';

  @override
  String settingsBedtimeReminderDetail(String time) {
    return 'A las $time, con la primera tarea de mañana';
  }

  @override
  String get settingsLook => 'Aspecto';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Como el dispositivo';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsAccent => 'Color de acento';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsData => 'Datos';

  @override
  String get settingsTrash => 'Papelera';

  @override
  String get settingsTrashDetail => 'Las tareas eliminadas se guardan 30 días';

  @override
  String get settingsTrashEmpty => 'La papelera está vacía';

  @override
  String get settingsRestore => 'Restaurar';

  @override
  String settingsRestored(String title) {
    return '$title restaurada';
  }

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsWhatsNew => 'Novedades';

  @override
  String changelogVersion(String version) {
    return 'Versión $version';
  }

  @override
  String changelogInstalled(String version) {
    return 'Versión $version · en este dispositivo';
  }

  @override
  String get changelogIntro => 'Qué cambió en cada versión de Dottoday.';

  @override
  String get releaseNotes010 =>
      'Planifica tu día en un solo hilo: arrastra una tarea para moverla, arrastra su borde para cambiar su duración y mueve todo lo que viene después de una vez.\nAñade una tarea con dos toques, escribe horas con palabras sencillas o pega una lista para añadir varias a la vez.\nTareas periódicas, recordatorios con antelación y tus calendarios en la línea de tiempo, todo gratis.\nSincroniza entre iPhone, Android, Mac y la web, con un estado visible y sin perder nada.\nExporta todo como JSON, CSV o archivo de calendario, y restaura una copia de seguridad.\nEnvía comentarios desde Ajustes y lee aquí las novedades tras cada actualización.';

  @override
  String whatsNewBanner(String version) {
    return 'Ya está aquí Dottoday $version';
  }

  @override
  String get whatsNewOpen => 'Ver novedades';

  @override
  String get settingsFeedback => 'Enviar comentarios';

  @override
  String get settingsFeedbackIntro =>
      'Abre un borrador en tu app de correo y lo envías desde allí. No se incluye nada de lo que dicen tus tareas.';

  @override
  String get settingsFeedbackDiagnostics => 'Añadir diagnóstico';

  @override
  String get settingsFeedbackDiagnosticsHint =>
      'Versión de la app, tipo de dispositivo, estado de sincronización y cuántas tareas tienes; nunca lo que dicen.';

  @override
  String get settingsFeedbackDiagnosticsFailed =>
      'No se pudo leer el diagnóstico, así que el correo se envía sin él.';

  @override
  String get settingsFeedbackPreview => 'Se añade al final de tu correo:';

  @override
  String get settingsFeedbackWrite => 'Escribir correo';

  @override
  String get settingsFeedbackSubject => 'Comentarios sobre Dottoday';

  @override
  String get settingsFeedbackNoMail =>
      'No hay ninguna app de correo configurada en este dispositivo.';

  @override
  String settingsAccentLabel(String name) {
    return 'Acento $name';
  }

  @override
  String get dayCardYesterdaySuffix => ' · Ayer';

  @override
  String get dayCardTomorrowSuffix => ' · Mañana';

  @override
  String spreadDoneOf(int done, int total) {
    return '$done de $total';
  }

  @override
  String spreadPlanned(int count) {
    return '$count planificadas';
  }

  @override
  String spreadSubtitle(String date, int done, int total) {
    return '$date · $done de $total hechas';
  }

  @override
  String get spreadPreviousDay => 'Día anterior';

  @override
  String get spreadNextDay => 'Día siguiente';

  @override
  String get spreadDropToPlan => 'suelta aquí para planificar';

  @override
  String spreadDropToPlanLabel(String day) {
    return 'Suelta una tarea aquí para planificarla el $day';
  }

  @override
  String threadDropInbox(String duration) {
    return '$duration libre · suelta aquí una tarea de la bandeja';
  }

  @override
  String get runningLate => 'Voy con retraso';

  @override
  String runningLateBy(int minutes) {
    return '+$minutes min';
  }

  @override
  String snackRunningLate(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas movidas $minutes min más tarde',
      one: '1 tarea movida $minutes min más tarde',
      zero: 'No queda nada que mover',
    );
    return '$_temp0';
  }

  @override
  String snackRunningLatePartial(int count, int minutes, String pinned) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas movidas $minutes min más tarde',
      one: '1 tarea movida $minutes min más tarde',
    );
    return '$_temp0 · $pinned se queda donde está';
  }

  @override
  String get spreadNothing => 'Nada planificado';

  @override
  String threadFreeFits(String duration, String title) {
    return '$duration libre · cabe $title';
  }

  @override
  String inboxFitsToday(String time) {
    return 'Cabe hoy $time';
  }

  @override
  String inboxFitsDay(String day, String time) {
    return 'Cabe $day $time';
  }

  @override
  String get inboxFitsNone => 'No hay sitio esta semana';

  @override
  String inboxAddedMeta(String duration, String when) {
    return '$duration · añadida $when';
  }

  @override
  String get inboxAddedToday => 'hoy';

  @override
  String get inboxAddedYesterday => 'ayer';

  @override
  String inboxSortLabel(String order) {
    return 'Ordenar: $order';
  }

  @override
  String get inboxSortAdded => 'añadidas';

  @override
  String get inboxSortDuration => 'duración';

  @override
  String get inboxSortFit => 'primer hueco';

  @override
  String get inboxAutoPlan => 'Planificar la semana';

  @override
  String snackAutoPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas planificadas esta semana',
      one: '1 tarea planificada esta semana',
      zero: 'Nada cabe esta semana',
    );
    return '$_temp0';
  }

  @override
  String snackAutoPlannedPartial(int count, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas planificadas',
      one: '1 tarea planificada',
    );
    return '$_temp0 · $left siguen en la bandeja';
  }

  @override
  String get inboxDropToday => 'Soltar en hoy';

  @override
  String inboxDropTodayFree(String duration) {
    return '$duration libre';
  }

  @override
  String inboxDropHint(String keys) {
    return 'Arrastra una tarea a un hueco punteado o pulsa $keys en una fila para colocarla en el primer hueco que encaje.';
  }

  @override
  String inboxUnscheduledCount(int count) {
    return '$count sin programar';
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
    return '$planned planificado de $awake despierto';
  }

  @override
  String weekBusiest(String day, String planned) {
    return 'Más ocupado · $day · $planned';
  }

  @override
  String weekLightest(String day, String planned) {
    return 'Más ligero · $day · $planned';
  }

  @override
  String weekFree(String free) {
    return 'Libre · $free sin planificar';
  }

  @override
  String weekDone(int done, int total) {
    return 'Hechas · $done de $total';
  }

  @override
  String get weekBusiestTag => 'Más ocupado';

  @override
  String get weekLightestTag => 'Más ligero';

  @override
  String get weekTitle => 'Esta semana';

  @override
  String weekSubtitle(String range, int done, int total, String planned) {
    return '$range · $done de $total hechas · $planned planificado';
  }

  @override
  String weekDayFree(String free) {
    return '$free libre';
  }

  @override
  String weekTodayDay(String day) {
    return '$day · hoy';
  }

  @override
  String get weekViewWeek => 'Semana';

  @override
  String get weekViewMonth => 'Mes';

  @override
  String get weekToday => 'Hoy';

  @override
  String weekDropHere(String free) {
    return 'Suelta una tarea aquí · $free';
  }

  @override
  String weekDropAt(String day, String range) {
    return '$day · $range';
  }

  @override
  String weekCardLeft(int minutes) {
    return 'Quedan $minutes min';
  }

  @override
  String weekCardSkipped(String range) {
    return '$range · omitida';
  }

  @override
  String weekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String monthStats(int done, int missed, int ahead) {
    return '$done hechas · $missed sin hacer · $ahead por delante';
  }

  @override
  String monthStatsBusiest(String stats, String day) {
    return '$stats · día más ocupado $day';
  }

  @override
  String get editorClose => 'Cerrar';

  @override
  String get editorEscKey => 'esc';

  @override
  String get shortcutsTitle => 'Atajos de teclado';

  @override
  String get shortcutsEverywhere => 'En todas partes';

  @override
  String get shortcutsTodaySection => 'Hoy';

  @override
  String get shortcutsWeekMonth => 'Semana y mes';

  @override
  String get shortcutsInbox => 'Bandeja de entrada';

  @override
  String get shortcutsEditor => 'Al editar una tarea';

  @override
  String get shortcutAdd => 'Añadir una tarea';

  @override
  String get shortcutGoToday => 'Ir a Hoy';

  @override
  String get shortcutGoInbox => 'Ir a la bandeja';

  @override
  String get shortcutGoWeek => 'Ir a Semana';

  @override
  String get shortcutGoMonth => 'Ir a Mes';

  @override
  String get shortcutShowKeys => 'Mostrar estos atajos';

  @override
  String get shortcutPrevDay => 'Día anterior';

  @override
  String get shortcutNextDay => 'Día siguiente';

  @override
  String get shortcutBackToday => 'Volver a hoy';

  @override
  String get shortcutDoneLive => 'Marcar la tarea actual como hecha';

  @override
  String get shortcutPrevPeriod => 'Semana o mes anterior';

  @override
  String get shortcutNextPeriod => 'Semana o mes siguiente';

  @override
  String get shortcutThisPeriod => 'Esta semana o mes';

  @override
  String get shortcutPlaceFirst =>
      'Colocar la tarea seleccionada en su primer hueco libre';

  @override
  String get shortcutAutoPlan => 'Planificar la semana';

  @override
  String get shortcutSave => 'Guardar y cerrar';

  @override
  String get shortcutDone => 'Marcar como hecha';

  @override
  String get shortcutClose => 'Cerrar';

  @override
  String get repeatTitle => 'Repetir';

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count días',
      one: 'Cada día',
    );
    return '$_temp0';
  }

  @override
  String get repeatEveryWeekday => 'Cada día laborable';

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count semanas',
      one: 'Cada semana',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeksOn(int count, String days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count semanas el $days',
      one: 'Cada semana el $days',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonthsOnDay(int count, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count meses el día $day',
      one: 'Cada mes el día $day',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonthsOnNth(int count, String nth, String weekday) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count meses el $nth $weekday',
      one: 'Cada mes el $nth $weekday',
    );
    return '$_temp0';
  }

  @override
  String repeatNth(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '1': 'primer',
      '2': 'segundo',
      '3': 'tercer',
      '4': 'cuarto',
      'other': 'último',
    });
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count años',
      one: 'Cada año',
    );
    return '$_temp0';
  }

  @override
  String repeatTimes(String summary, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces',
      one: 'una vez',
    );
    return '$summary · $_temp0';
  }

  @override
  String repeatUntil(String summary, String date) {
    return '$summary · hasta el $date';
  }

  @override
  String get repeatChoiceDaily => 'Cada día';

  @override
  String get repeatChoiceWeekly => 'Cada semana';

  @override
  String get repeatChoiceMonthly => 'Cada mes';

  @override
  String get repeatChoiceYearly => 'Cada año';

  @override
  String get repeatChoiceCustom => 'Personalizado';

  @override
  String repeatOnDay(int day) {
    return 'El día $day';
  }

  @override
  String repeatOnNth(String nth, String weekday) {
    return 'El $nth $weekday';
  }

  @override
  String get repeatEvery => 'Cada';

  @override
  String repeatUnitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'días',
      one: 'día',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'semanas',
      one: 'semana',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'meses',
      one: 'mes',
    );
    return '$_temp0';
  }

  @override
  String get repeatIntervalLess => 'Menos';

  @override
  String get repeatIntervalMore => 'Más';

  @override
  String get repeatEnds => 'Termina';

  @override
  String get repeatEndsNever => 'Nunca';

  @override
  String get repeatEndsAfter => 'Después de';

  @override
  String get repeatEndsOn => 'En una fecha';

  @override
  String repeatEndsAfterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces',
      one: '1 vez',
    );
    return '$_temp0';
  }

  @override
  String get repeatDone => 'Hecho';

  @override
  String get scopeTitleEdit => '¿Cuáles cambiar?';

  @override
  String get scopeTitleDelete => '¿Cuáles eliminar?';

  @override
  String get scopeThis => 'Solo esta';

  @override
  String get scopeFollowing => 'Esta y las siguientes';

  @override
  String get scopeAll => 'Todas';

  @override
  String get scopeAllDetail => 'Las anteriores se quedan como estaban';

  @override
  String snackSeriesChanged(String title) {
    return '$title cambiada';
  }

  @override
  String snackSeriesDeleted(String title) {
    return '$title eliminada';
  }

  @override
  String snackRepeatSet(String title, String summary) {
    return '$title se repite: $summary';
  }

  @override
  String snackRepeatStopped(String title) {
    return '$title ya no se repite';
  }

  @override
  String get alertsTitle => 'Avisos';

  @override
  String get alertsAdd => 'Añadir un aviso';

  @override
  String get alertsMax => 'Hasta 5 avisos';

  @override
  String alertsRemove(String alert) {
    return 'Quitar $alert';
  }

  @override
  String get alertsBedtime => 'Recordatorio para dormir';

  @override
  String get alertsBedtimeDetail =>
      'Cada noche, con la primera tarea de mañana';

  @override
  String get alertsDone => 'Hecho';

  @override
  String snackAlertsSaved(String title) {
    return 'Avisos de $title actualizados';
  }

  @override
  String subtaskRemove(String title) {
    return 'Quitar $title';
  }

  @override
  String subtaskReorder(String title) {
    return 'Reordenar $title';
  }

  @override
  String get subtaskMoveUp => 'Subir';

  @override
  String get subtaskMoveDown => 'Bajar';

  @override
  String subtaskRename(String title) {
    return 'Cambiar el nombre de $title';
  }

  @override
  String get subtaskNow => 'ahora';

  @override
  String get subtaskEveryTime => 'Usar esta lista siempre';

  @override
  String snackSubtaskRemoved(String title) {
    return '$title quitada';
  }

  @override
  String snackListEveryTime(String title) {
    return '$title tendrá esta lista siempre';
  }

  @override
  String get colourIconTitle => 'Color e icono';

  @override
  String get colourIconDone => 'Hecho';

  @override
  String get subtaskRenameTitle => 'Renombrar subtarea';

  @override
  String get subtaskRenameSave => 'Renombrar';

  @override
  String editorZone(String city) {
    return 'Zona horaria · $city';
  }

  @override
  String get todayMenuLate => 'Voy con retraso…';

  @override
  String get todayMenuReview => 'Repasar el día';

  @override
  String get lateAmount => 'Cuánto retraso';

  @override
  String get lateShiftRest => 'Mover el resto';

  @override
  String lateShiftPreview(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas se mueven $minutes min más tarde',
      one: '1 tarea se mueve $minutes min más tarde',
      zero: 'No queda nada que mover',
    );
    return '$_temp0';
  }

  @override
  String lateShiftPreviewPartial(int count, int minutes, String pinned) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas se mueven $minutes min más tarde',
      one: '1 tarea se mueve $minutes min más tarde',
    );
    return '$_temp0 · $pinned se queda donde está';
  }

  @override
  String lateSkip(String title) {
    return 'Omitir “$title”';
  }

  @override
  String get lateSkipDetail => 'Libera su tiempo; nada más se mueve';

  @override
  String lateShorten(String title) {
    return 'Acortar “$title”';
  }

  @override
  String lateShortenDetail(int minutes, String end) {
    return 'Empieza $minutes min más tarde y sigue terminando a las $end';
  }

  @override
  String lateShortenTooShort(int minutes) {
    return 'Demasiado corta para quitarle $minutes min';
  }

  @override
  String get lateNothingLeft => 'No queda nada hoy';

  @override
  String snackSkippedTask(String title) {
    return '“$title” omitida';
  }

  @override
  String snackShortened(String title, int minutes) {
    return '“$title” empieza $minutes min más tarde';
  }

  @override
  String get reviewTitle => 'Repaso del día';

  @override
  String reviewSummary(int done, int total) {
    return '$done de $total hechas';
  }

  @override
  String get reviewAskTomorrow => '¿Pasar el resto a mañana?';

  @override
  String get reviewAskInbox => '¿Enviar el resto a la bandeja?';

  @override
  String reviewMoveTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pasar $count a mañana',
      one: 'Pasar 1 a mañana',
    );
    return '$_temp0';
  }

  @override
  String reviewSendInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviar $count a la bandeja',
      one: 'Enviar 1 a la bandeja',
    );
    return '$_temp0';
  }

  @override
  String reviewStaying(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count más se quedan: se repiten o vienen de un calendario',
      one: '1 más se queda: se repite o viene de un calendario',
    );
    return '$_temp0';
  }

  @override
  String get reviewAllDone => 'No queda nada que mover';

  @override
  String snackRolled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas pasadas a mañana',
      one: '1 tarea pasada a mañana',
    );
    return '$_temp0';
  }

  @override
  String snackSentToInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas enviadas a la bandeja',
      one: '1 tarea enviada a la bandeja',
    );
    return '$_temp0';
  }

  @override
  String get promptNotNow => 'Ahora no';

  @override
  String get lateNudgeTitle => '¿Necesitas más tiempo?';

  @override
  String lateNudgeDetail(String title, int minutes) {
    return '“$title” terminó hace $minutes min';
  }

  @override
  String get lateNudgeAction => 'Ponerme al día';

  @override
  String get todayMenuDuplicate => 'Duplicar día…';

  @override
  String get todayMenuCopyText => 'Copiar día como texto';

  @override
  String get duplicateDayTitle => '¿A qué día copiar?';

  @override
  String get snackDayCopied => 'Día copiado como texto';

  @override
  String inboxDoneOn(String date) {
    return 'Hecha el $date';
  }

  @override
  String inboxNotDone(String title) {
    return 'Marcar “$title” como sin hacer';
  }

  @override
  String get inboxClearCompleted => 'Borrar completadas';

  @override
  String snackBackInInbox(String title) {
    return '“$title” vuelve a estar en la bandeja';
  }

  @override
  String snackClearedCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas completadas movidas a la papelera',
      one: '1 tarea completada movida a la papelera',
    );
    return '$_temp0';
  }

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsCalendars => 'Calendarios';

  @override
  String get settingsCalendarsDetail => 'Eventos en tu línea de tiempo';

  @override
  String get settingsExport => 'Exportar';

  @override
  String get settingsExportDetail => 'Tus datos, libres para llevártelos';

  @override
  String get settingsHelp => 'Ayuda';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsAboutApp => 'Acerca de Dottoday';

  @override
  String get settingsBack => 'Volver a Ajustes';

  @override
  String get accountProfile => 'Perfil';

  @override
  String get accountName => 'Nombre';

  @override
  String get accountNameNone => 'Sin definir';

  @override
  String get accountNameTitle => 'Tu nombre';

  @override
  String get accountNameSave => 'Guardar';

  @override
  String get accountSync => 'Sincronización';

  @override
  String get accountLocalBody =>
      'Todo está en este dispositivo. Inicia sesión para sincronizar entre tus dispositivos y guardar una copia segura.';

  @override
  String get accountApple => 'Continuar con Apple';

  @override
  String get accountGoogle => 'Continuar con Google';

  @override
  String get accountEmail => 'Continuar con correo';

  @override
  String get accountComingSoon =>
      'El inicio de sesión llegará con la sincronización en una próxima actualización. Hasta entonces, nada sale de este dispositivo.';

  @override
  String accountSignedInAs(String email) {
    return 'Sesión iniciada como $email';
  }

  @override
  String get accountSignOut => 'Cerrar sesión';

  @override
  String get accountSignOutEverywhere => 'Cerrar sesión en todas partes';

  @override
  String get accountDelete => 'Eliminar cuenta';

  @override
  String get accountDeleteTitle => '¿Eliminar tu cuenta?';

  @override
  String get accountDeleteExportFirst => 'Exportar mis datos antes';

  @override
  String accountDeleteBody(String word) {
    return 'Esto elimina tu cuenta y todo lo sincronizado con ella. Las tareas de este dispositivo se quedan. Escribe $word para confirmar.';
  }

  @override
  String get accountDeleteWord => 'ELIMINAR';

  @override
  String get calendarsIntro =>
      'Los eventos de tu calendario en la línea de tiempo, junto a tus tareas. Gratis, siempre.';

  @override
  String get calendarsConnected => 'Conectados';

  @override
  String get calendarsNone => 'Aún no hay calendarios conectados';

  @override
  String get calendarsConnect => 'Conectar un calendario';

  @override
  String get calendarsOnlineInSettings =>
      'Conecta Google o Microsoft en Ajustes › Calendarios.';

  @override
  String get calendarsOnline => 'Google y Microsoft';

  @override
  String get calendarsOnlineIntro =>
      'Se conectan una vez y aparecen en cada dispositivo donde inicies sesión. Si un calendario también está en este dispositivo, desactiva uno de los dos.';

  @override
  String get calendarsOnlineSignIn =>
      'Inicia sesión para conectar Google o Microsoft';

  @override
  String get calendarsConnectGoogle => 'Conectar Google Calendar';

  @override
  String get calendarsConnectMicrosoft => 'Conectar Microsoft Outlook';

  @override
  String get calendarsReconnect => 'Volver a conectar';

  @override
  String get calendarsReconnectDetail =>
      'Dottoday no puede acceder a esta cuenta hasta que la vuelvas a conectar';

  @override
  String get calendarsUnreachable =>
      'No se pudo acceder a esta cuenta ahora mismo';

  @override
  String get calendarsDisconnect => 'Desconectar';

  @override
  String calendarsDisconnectTitle(String account) {
    return '¿Desconectar $account?';
  }

  @override
  String get calendarsDisconnectBody =>
      'Sus eventos desaparecen de tu línea de tiempo en todos los dispositivos. Los eventos con tus subtareas o notas van a la papelera.';

  @override
  String get calendarsShifting => 'Cuando el día se mueve';

  @override
  String get calendarsMoveEvents => 'Mover también los eventos del calendario';

  @override
  String get calendarsMoveEventsDetail =>
      'Al mover el resto. Los eventos compartidos y periódicos se quedan donde están.';

  @override
  String get calendarsAsk =>
      'Dottoday pide una vez a tu dispositivo permiso para ver tus calendarios. Luego eliges cuáles se muestran.';

  @override
  String get calendarsOnDevice => 'En este dispositivo';

  @override
  String get calendarsNoneOnDevice => 'No hay calendarios en este dispositivo';

  @override
  String get calendarsReadOnly => 'Solo lectura';

  @override
  String get calendarsPickInSettings =>
      'Conectado · elige los calendarios en Ajustes';

  @override
  String get calendarDeniedTitle => 'El acceso al calendario está desactivado';

  @override
  String get calendarDeniedBody =>
      'Dottoday no puede mostrar tus eventos hasta que permitas el acceso al calendario en los ajustes del dispositivo.';

  @override
  String get calendarSettingsPath =>
      'Abre los Ajustes de tu dispositivo, busca Dottoday y permite el acceso a Calendarios.';

  @override
  String get exportIntro =>
      'Tus tareas son tuyas. Exportar es gratis, siempre, con o sin cuenta.';

  @override
  String get exportFormats => 'Formatos';

  @override
  String get exportJson => 'Todo (JSON)';

  @override
  String get exportJsonDetail => 'Una copia completa que puedes restaurar';

  @override
  String get exportCsv => 'Tareas (CSV)';

  @override
  String get exportCsvDetail => 'Se abre en cualquier hoja de cálculo';

  @override
  String get exportIcs => 'Calendario (.ics)';

  @override
  String get exportIcsDetail => 'Para otras apps de calendario';

  @override
  String get exportPlain =>
      'Los archivos exportados no están cifrados: cualquiera que tenga el archivo puede leer tus tareas. Los eventos de calendario importados se quedan en su calendario y no se incluyen.';

  @override
  String get exportDone => 'Exportado';

  @override
  String get exportHandOffFailed =>
      'No se pudo guardar ni compartir el archivo. No se ha cambiado nada.';

  @override
  String get exportRestore => 'Restaurar';

  @override
  String get exportImport => 'Importar una copia de seguridad…';

  @override
  String get exportImportDetail => 'Un archivo JSON exportado desde Dottoday';

  @override
  String get exportImportTitle =>
      '¿Reemplazar tus tareas con esta copia de seguridad?';

  @override
  String exportImportBody(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas',
      one: '1 tarea',
      zero: 'ninguna tarea',
    );
    return 'Este archivo del $date tiene $_temp0. Lo que haya aquí y no esté en él irá a la papelera. Antes se hace una copia de seguridad de lo que hay ahora.';
  }

  @override
  String get exportImportAction => 'Reemplazar';

  @override
  String get exportCancel => 'Cancelar';

  @override
  String get exportImported => 'Copia de seguridad importada';

  @override
  String get exportNotBackup =>
      'Esta no es una copia de seguridad de Dottoday, o viene de una versión más reciente de Dottoday. No se ha cambiado nada.';

  @override
  String get exportTooLarge =>
      'Este archivo supera los 25 MB y es demasiado grande para importarlo. No se ha cambiado nada.';

  @override
  String get exportBackups => 'En este dispositivo';

  @override
  String get exportBackupsNote =>
      'Dottoday guarda una copia de seguridad cada día (las últimas 7) y otra antes de cada importación o restauración, cifradas y solo en este dispositivo.';

  @override
  String get exportBackupsNone =>
      'Aún no hay copias de seguridad. La primera se hará la próxima vez que abras Dottoday.';

  @override
  String get exportBackupDaily => 'Copia diaria';

  @override
  String get exportBackupPreImport => 'Antes de una importación';

  @override
  String get exportBackupPreRestore => 'Antes de una restauración';

  @override
  String get exportRestoreTitle => '¿Volver a esta copia de seguridad?';

  @override
  String exportRestoreBody(String date) {
    return 'Tus tareas vuelven a como estaban el $date. Lo más reciente irá a la papelera. Antes se hace una copia de seguridad de lo que hay ahora.';
  }

  @override
  String get exportRestoreAction => 'Restaurar';

  @override
  String get exportRestored => 'Copia de seguridad restaurada';

  @override
  String get helpIntro =>
      'Respuestas rápidas. ¿Algo más? Envía tus comentarios abajo.';

  @override
  String get helpMoveQ => '¿Cómo muevo una tarea?';

  @override
  String get helpMoveA =>
      'Arrástrala a lo largo del hilo, o arrastra sus bordes para cambiar su duración. Mantén pulsado para elegir varias.';

  @override
  String get helpLateQ => 'Voy con retraso. ¿Se puede mover todo?';

  @override
  String get helpLateA =>
      'Sí: ⋯ › Voy con retraso mueve el resto del día 5, 15 o 30 minutos, hasta las tareas fijadas. También puedes omitir o acortar la tarea actual.';

  @override
  String get helpRepeatQ => '¿Cómo funcionan las tareas periódicas?';

  @override
  String get helpRepeatA =>
      'Abre una tarea › Repetir. Las marcas y subtareas pertenecen a cada día, así que la siguiente empieza de cero.';

  @override
  String get helpPasteQ => '¿Puedo añadir muchas tareas a la vez?';

  @override
  String get helpPasteA =>
      'Pega una lista en Añadir o en el campo de la bandeja: cada línea se convierte en una tarea.';

  @override
  String get helpKeysQ => '¿Hay atajos de teclado?';

  @override
  String get helpKeysA =>
      'En un Mac o en un navegador, pulsa ⌘/ (Ctrl+/ en otros) para verlos todos.';

  @override
  String get privacyLocalTitle => 'En tu dispositivo';

  @override
  String get privacyLocalBody =>
      'Las tareas se guardan cifradas en este dispositivo y la app funciona totalmente sin conexión.';

  @override
  String get privacyTrackTitle => 'Sin seguimiento';

  @override
  String get privacyTrackBody =>
      'Sin anuncios, sin analíticas, sin rastreadores de terceros.';

  @override
  String get privacySyncTitle => 'Cuando inicias sesión';

  @override
  String get privacySyncBody =>
      'La sincronización envía tus tareas por una conexión cifrada a tu propia cuenta, y a ningún otro sitio.';

  @override
  String get privacySearchTitle => 'Búsquedas';

  @override
  String get privacySearchBody =>
      'Las búsquedas recientes se quedan en este dispositivo y nunca se sincronizan ni se exportan.';

  @override
  String get privacyClearSearches => 'Borrar búsquedas recientes';

  @override
  String get privacyCrashTitle => 'Informes de fallos';

  @override
  String get privacyCrashBody =>
      'Si la app falla, envía el tipo de error y en qué parte de la app ocurrió. Nunca tus tareas, notas ni tu cuenta.';

  @override
  String get privacyPolicyOpen => 'Leer la política de privacidad';

  @override
  String get snackSearchesCleared => 'Búsquedas recientes borradas';

  @override
  String get aboutLicences => 'Licencias de código abierto';

  @override
  String get settingsSync => 'Sincronización';

  @override
  String get syncTitle => 'Sincronización';

  @override
  String get syncLocalOnlyBody =>
      'Tus tareas solo están en este dispositivo. Inicia sesión para sincronizarlas entre tus dispositivos.';

  @override
  String get syncSignIn => 'Iniciar sesión…';

  @override
  String get syncJustNow => 'Sincronizado hace un momento';

  @override
  String syncMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Sincronizado hace $minutes min',
      one: 'Sincronizado hace 1 min',
    );
    return '$_temp0';
  }

  @override
  String syncAt(String when) {
    return 'Última sincronización: $when';
  }

  @override
  String get syncNever => 'Aún sin sincronizar';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios pendientes de sincronizar',
      one: '1 cambio pendiente de sincronizar',
      zero: 'Nada pendiente de sincronizar',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get syncStateSynced => 'Al día';

  @override
  String get syncStateSyncing => 'Sincronizando…';

  @override
  String get syncStateOffline =>
      'Sin conexión. Los cambios se guardan aquí y se sincronizan cuando vuelvas.';

  @override
  String get syncStateError =>
      'No se pudo sincronizar. Tus cambios están a salvo aquí; se volverá a intentar.';

  @override
  String get syncConflicts => 'Cambiado en dos dispositivos';

  @override
  String get syncConflictHint =>
      'Se usa el cambio del otro dispositivo hasta que elijas.';

  @override
  String syncConflictField(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'El título',
      'start': 'La hora',
      'duration': 'La duración',
      'notes': 'Las notas',
      'colour': 'El color',
      'status': 'Hecha o no',
      'other': 'Un detalle',
    });
    return '$_temp0';
  }

  @override
  String syncMine(String value) {
    return 'Este dispositivo: $value';
  }

  @override
  String syncTheirs(String value) {
    return 'Otro dispositivo: $value';
  }

  @override
  String get syncKeepMine => 'Conservar el mío';

  @override
  String get syncKeepTheirs => 'Conservar el otro';

  @override
  String get bannerOffline => 'Sin conexión · todo sigue funcionando aquí';

  @override
  String bannerConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios te necesitan',
      one: '1 cambio te necesita',
    );
    return '$_temp0';
  }

  @override
  String get bannerReview => 'Revisar';

  @override
  String get notifDeniedTitle => 'Las notificaciones están desactivadas';

  @override
  String get notifDeniedBody =>
      'Dottoday no puede recordarte nada hasta que permitas las notificaciones en los ajustes del dispositivo.';

  @override
  String get notifOpenSettings => 'Abrir ajustes';

  @override
  String get notifSettingsPath =>
      'Abre Ajustes › Notificaciones › Dottoday en tu dispositivo y permite las notificaciones.';

  @override
  String syncSummary(String last, String pending) {
    return '$last · $pending';
  }

  @override
  String syncConflictHeading(String title, String field) {
    return '$title · $field';
  }

  @override
  String get recoveryLockedTitle => 'Dottoday no puede abrir tus tareas';

  @override
  String get recoveryLockedBody =>
      'Tus tareas en este dispositivo están bloqueadas con una clave que falta o ha cambiado. Puede pasar tras restaurar un dispositivo o borrar su llavero.';

  @override
  String get recoveryFreshBody =>
      'Empezar de cero aparta el archivo antiguo (nunca se elimina) y abre un planificador vacío. Tus tareas vuelven cuando inicias sesión para sincronizar, o al importar una exportación.';

  @override
  String get recoveryStartFresh => 'Empezar de cero';

  @override
  String get recoveryConfirm =>
      '¿Empezar con un planificador vacío? El archivo antiguo se queda en este dispositivo.';

  @override
  String get recoveryConfirmYes => 'Sí, empezar de cero';

  @override
  String recoveryKept(String where) {
    return 'Tu archivo antiguo se guarda en $where';
  }

  @override
  String get recoveryTabTitle => 'Dottoday está abierto en otra pestaña';

  @override
  String get recoveryTabBody =>
      'Para proteger tus tareas, solo una pestaña puede usarlas a la vez.';

  @override
  String get recoveryUseHere => 'Usarlo aquí';

  @override
  String get recoveryMovedTitle => 'Dottoday se ha pasado a otra pestaña';

  @override
  String get recoveryMovedBody =>
      'Elegiste usar Dottoday en otra pestaña. Tus tareas están guardadas.';

  @override
  String get recoveryNoAnswer =>
      'La otra pestaña no respondió. Ciérrala e inténtalo de nuevo.';

  @override
  String get recoveryContinue => 'Continuar';

  @override
  String get stateLoading => 'Cargando';

  @override
  String get stateErrorTitle => 'No se pudo cargar';

  @override
  String get stateErrorSafe => 'Tus tareas están a salvo en este dispositivo.';

  @override
  String get stateRetry => 'Reintentar';

  @override
  String get stateReadFailed =>
      'No se pudieron leer tus tareas en este dispositivo.';

  @override
  String get inboxSelect => 'Seleccionar';

  @override
  String get inboxPlanThese => 'Planificar estas';

  @override
  String inboxSelectedLabel(String title) {
    return '$title, seleccionada';
  }

  @override
  String get onboardingWelcomeTitle => 'Tu día, como un hilo.';

  @override
  String get onboardingWelcomeBody =>
      'Planifica tu día como puntos en una línea, mira a dónde va el tiempo y muévelo todo cuando el día cambie.';

  @override
  String get onboardingAgeNote =>
      'Dottoday es para personas a partir de 13 años.';

  @override
  String get onboardingGetStarted => 'Empezar';

  @override
  String get onboardingSignIn => 'Ya tengo una cuenta';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String onboardingStepOf(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get onboardingDotLabel => 'El punto del día, dibujándose';

  @override
  String get onboardingDayShapeTitle => '¿Cuándo empieza y termina tu día?';

  @override
  String get onboardingDayShapeBody =>
      'Tus tareas viven entre estas dos horas. Puedes cambiarlas, o dar a cada día de la semana las suyas, en Ajustes.';

  @override
  String get onboardingHabitsTitle => '¿Qué llena tus días?';

  @override
  String get onboardingHabitsBody =>
      'Elige hasta cinco. Irán al hilo de mañana en horas que encajen con tu día; cámbialas cuando quieras.';

  @override
  String onboardingHabitsAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Añadir $count a mañana',
      one: 'Añadir 1 a mañana',
    );
    return '$_temp0';
  }

  @override
  String get onboardingHabitsMax => 'Cinco es más que suficiente para empezar.';

  @override
  String get starterMorningRun => 'Correr por la mañana';

  @override
  String get starterDeepWork => 'Trabajo concentrado';

  @override
  String get starterLunch => 'Comida';

  @override
  String get starterWalk => 'Paseo';

  @override
  String get starterGym => 'Gimnasio';

  @override
  String get starterRead => 'Leer';

  @override
  String get starterPlanTomorrow => 'Planificar mañana';

  @override
  String onboardingHabitMeta(String time, String length) {
    return '$time · $length';
  }

  @override
  String get onboardingRemindersTitle => '¿Quieres un recordatorio?';

  @override
  String get onboardingRemindersBody =>
      'Dottoday te avisa cuando empieza una tarea y antes de dormir. Puedes cambiarlo cuando quieras en Ajustes.';

  @override
  String get onboardingTaskStarts => 'Antes de cada tarea';

  @override
  String get onboardingTaskStartsDetail =>
      'Cuánto antes lo decides tú, en Ajustes';

  @override
  String get onboardingBedtime => 'A la hora de dormir';

  @override
  String get onboardingBedtimeDetail =>
      'La primera tarea de mañana, para que la mañana no traiga sorpresas';

  @override
  String get onboardingAllow => 'Permitir notificaciones';

  @override
  String get onboardingNotNow => 'Ahora no';

  @override
  String get onboardingAccountTitle => '¿Sincronizar tus tareas?';

  @override
  String get onboardingAccountBody =>
      'Inicia sesión para usar Dottoday en todos tus dispositivos con una copia segura. O no: todo funciona en este dispositivo sin cuenta.';

  @override
  String get onboardingWithoutAccount => 'Continuar sin cuenta';

  @override
  String get onboardingDoneTitle => 'Tu primer hilo';

  @override
  String get onboardingDoneBody =>
      'Mañana, de Despertar a Hora de dormir. Añade cosas, muévelas o empieza por hoy.';

  @override
  String get onboardingDoneEmpty =>
      'Mañana, de Despertar a Hora de dormir, es todo tuyo. Añade la primera tarea cuando quieras.';

  @override
  String get onboardingOpenToday => 'Abrir hoy';

  @override
  String get onboardingTomorrow => 'Mañana';

  @override
  String get onboardingWelcomeBackTitle => 'Hola de nuevo';

  @override
  String get onboardingWelcomeBackBody =>
      'Inicia sesión para traer tus tareas a este dispositivo.';

  @override
  String get accountEmailLabel => 'Correo electrónico';

  @override
  String get accountSendLink => 'Enviarme un enlace';

  @override
  String get accountOtherWays => 'Otras formas de iniciar sesión';

  @override
  String get accountEmailInvalid => 'Eso no parece una dirección de correo.';

  @override
  String get accountCheckMailTitle => 'Revisa tu correo';

  @override
  String accountCheckMailBody(String email) {
    return 'Hemos enviado un enlace de inicio de sesión a $email. Ábrelo en este dispositivo para continuar.';
  }

  @override
  String get accountResend => 'Enviarlo de nuevo';

  @override
  String get accountOtherEmail => 'Usar otro correo';

  @override
  String get accountErrorTitle => 'No se pudo iniciar sesión';

  @override
  String get accountRestoring => 'Trayendo tus tareas a este dispositivo…';

  @override
  String accountRestoreCount(int done, int total) {
    return '$done de $total';
  }

  @override
  String notifStartsIn(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '1 minuto',
    );
    return 'Empieza en $_temp0';
  }

  @override
  String get notifStartsNow => 'Empieza ahora';

  @override
  String get notifEndsNow => 'Termina ahora';

  @override
  String notifOverdue(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '1 minuto',
    );
    return 'Terminó hace $_temp0. ¿Hecha?';
  }

  @override
  String get notifSnoozed => 'Recordatorio pospuesto';

  @override
  String get notifBedtimeTitle => 'Hora de dormir';

  @override
  String notifBedtimeFirst(String title, String time) {
    return 'Mañana empieza con $title a las $time.';
  }

  @override
  String get notifBedtimeFree => 'Aún no hay nada planificado para mañana.';

  @override
  String get notifActionDone => 'Hecho';

  @override
  String get notifActionSnooze => 'Posponer 10 min';

  @override
  String get notifActionOpen => 'Abrir';

  @override
  String get notifChannelAlerts => 'Avisos de tareas';

  @override
  String get notifChannelAlertsDetail =>
      'Recordatorios antes, al empezar y después de tus tareas';

  @override
  String get notifChannelAlarms => 'Inicio de tu día';

  @override
  String get notifChannelAlarmsDetail =>
      'Suena como una alarma para la primera tarea del día y cuando empieza una rutina';

  @override
  String get notifChannelSummary => 'Hora de dormir';

  @override
  String get notifChannelSummaryDetail => 'El vistazo nocturno a mañana';

  @override
  String inAppAlertText(String title, String detail) {
    return '$title · $detail';
  }

  @override
  String get inAppAlertLater => 'Más tarde';

  @override
  String get widgetNextUp => 'A continuación';

  @override
  String get widgetNow => 'Ahora';

  @override
  String widgetUntil(String time) {
    return 'hasta las $time';
  }

  @override
  String get widgetNothingNext => 'Nada más hoy';

  @override
  String get widgetToday => 'Hoy';

  @override
  String widgetInboxCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en la bandeja',
      one: '1 en la bandeja',
      zero: 'La bandeja está vacía',
    );
    return '$_temp0';
  }

  @override
  String get menuFile => 'Archivo';

  @override
  String get menuEdit => 'Edición';

  @override
  String get menuView => 'Visualización';

  @override
  String get menuGo => 'Ir';

  @override
  String get menuWindow => 'Ventana';

  @override
  String get menuSettings => 'Ajustes…';

  @override
  String get menuNewTask => 'Nueva tarea';

  @override
  String get menuExport => 'Exportar…';

  @override
  String get menuUndo => 'Deshacer';

  @override
  String get menuMonth => 'Mes';

  @override
  String get menuShortcuts => 'Atajos de teclado';

  @override
  String get menuPreviousDay => 'Día anterior';

  @override
  String get menuNextDay => 'Día siguiente';

  @override
  String get menuRedo => 'Rehacer';

  @override
  String get menuDelete => 'Eliminar';

  @override
  String get shortcutUndo => 'Deshacer el último cambio';

  @override
  String get shortcutRedo => 'Rehacer lo deshecho';

  @override
  String get exactTitle =>
      'Los recordatorios pueden llegar unos minutos después de su hora';

  @override
  String get exactBody =>
      'Para ahorrar batería, Android puede retener los recordatorios. Permite la hora exacta para que cada uno llegue cuando empiece tu tarea.';

  @override
  String get exactAllow => 'Permitir hora exacta';

  @override
  String get skipToContent => 'Saltar al contenido';

  @override
  String get installText =>
      'Instala Dottoday: se abre como una app y funciona sin conexión';

  @override
  String get installAction => 'Instalar';

  @override
  String get lockCaption => 'BLOQUEO DE LA APP';

  @override
  String get lockToggle => 'Bloquear Dottoday';

  @override
  String get lockToggleDetail => 'Pedir tu cara, huella o código';

  @override
  String get lockWebTitle => 'Usa el bloqueo de tu ordenador';

  @override
  String get lockWebDetail =>
      'En un navegador, Dottoday está tan bloqueado como tu ordenador. Bloquea la pantalla cuando te ausentes; las tareas siguen cifradas en este navegador.';

  @override
  String get lockAfter => 'Bloquear después de';

  @override
  String get lockAfterNow => 'Inmediatamente';

  @override
  String lockAfterMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get lockReason => 'Desbloquear Dottoday';

  @override
  String get lockTitle => 'Dottoday está bloqueado';

  @override
  String get lockUnlock => 'Desbloquear';

  @override
  String get lockUnavailable =>
      'Este dispositivo no tiene código, así que Dottoday no se puede bloquear.';

  @override
  String zoneBannerText(String city) {
    return 'Ahora estás en $city: ¿mantener las horas o moverlas?';
  }

  @override
  String get zoneKeep => 'Mantener horas';

  @override
  String get zoneShift => 'Mover';

  @override
  String zoneKeptSnack(String city) {
    return 'Tareas mantenidas a sus horas en $city';
  }

  @override
  String zoneShiftedSnack(String city) {
    return 'Tareas movidas a la hora de $city';
  }

  @override
  String get syncAgoJustNow => 'hace un momento';

  @override
  String syncAgoMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'hace $minutes min',
      one: 'hace 1 min',
    );
    return '$_temp0';
  }

  @override
  String syncAgoHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'hace $hours h',
      one: 'hace 1 h',
    );
    return '$_temp0';
  }

  @override
  String syncLineSynced(String ago) {
    return 'Sincronizado · $ago';
  }

  @override
  String get syncLineSyncing => 'Sincronizando…';

  @override
  String get syncLineOffline => 'Sin conexión · cambios guardados aquí';

  @override
  String clockFast(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Tu reloj va $minutes min adelantado',
      one: 'Tu reloj va 1 min adelantado',
    );
    return '$_temp0: los recordatorios pueden llegar antes';
  }

  @override
  String clockSlow(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Tu reloj va $minutes min por detrás',
      one: 'Tu reloj va 1 min por detrás',
    );
    return '$_temp0: los recordatorios pueden llegar después de su hora';
  }

  @override
  String get syncClockWaiting =>
      'Los cambios de este dispositivo esperan hasta que el reloj esté en hora; los de tus otros dispositivos siguen llegando.';

  @override
  String get healthTitle => 'Estado de las notificaciones';

  @override
  String get healthCaption => 'Este dispositivo';

  @override
  String get healthIntro =>
      'Lo que decide si tus recordatorios llegan en este dispositivo, leído ahora mismo de sus ajustes.';

  @override
  String get healthAllGood => 'Todo bien';

  @override
  String get healthPermissionOk => 'Las notificaciones están activadas';

  @override
  String get healthPermissionOff => 'Las notificaciones están desactivadas';

  @override
  String get healthPermissionOffDetail =>
      'Dottoday no puede recordarte nada hasta que las permitas.';

  @override
  String get healthExactOk => 'Los recordatorios llegan al minuto';

  @override
  String get healthExactOff =>
      'Los recordatorios pueden llegar unos minutos después de su hora';

  @override
  String get healthExactOffDetail =>
      'Permite “Alarmas y recordatorios” para Dottoday para que lleguen al minuto.';

  @override
  String get healthBatteryOk => 'El ahorro de batería no afecta a Dottoday';

  @override
  String get healthBatteryOff =>
      'El ahorro de batería puede retener los recordatorios';

  @override
  String get healthBatteryOffDetail =>
      'En la lista, elige Dottoday y “No optimizar”.';

  @override
  String get healthDndOff => 'No molestar está desactivado';

  @override
  String get healthDndOn => 'No molestar está activado';

  @override
  String get healthDndOnDetail =>
      'La primera tarea del día sigue sonando; los demás recordatorios llegan en silencio.';

  @override
  String get healthFocus => 'Concentración';

  @override
  String get healthFocusDetail =>
      'El inicio de las tareas es urgente, así que un modo Concentración que permita notificaciones urgentes las deja pasar.';

  @override
  String get healthPushOk => 'Los recordatorios llegan con la pestaña cerrada';

  @override
  String get healthPushOff =>
      'Los recordatorios llegan mientras Dottoday está abierto';

  @override
  String get healthPushOffDetail =>
      'Inicia sesión y permite las notificaciones para que también lleguen con la pestaña cerrada.';

  @override
  String get healthClockOk => 'Tu reloj está en hora';

  @override
  String get healthClockOffDetail =>
      'Activa “Ajuste automático” en los ajustes de fecha y hora.';

  @override
  String get healthFixAllow => 'Permitir';

  @override
  String get healthFixOpen => 'Abrir ajustes';

  @override
  String healthToFix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cosas por arreglar',
      one: '1 cosa por arreglar',
    );
    return '$_temp0';
  }

  @override
  String get testAlarmTitle => 'Alarma de prueba';

  @override
  String get testAlarmBody => 'Ha llegado. Tus recordatorios también llegarán.';

  @override
  String get testAlarmCaption => 'Comprueba que funciona';

  @override
  String get inAppAlertOk => 'OK';

  @override
  String get testAlarmRow => 'Enviarme una alarma de prueba';

  @override
  String get testAlarmRowDetail =>
      'Comprueba que un recordatorio te llega de verdad';

  @override
  String get testAlarmExplain =>
      'Dottoday enviará una alarma de prueba en 60 segundos para que compruebes que llega.';

  @override
  String get testAlarmSend => 'Enviar';

  @override
  String get testAlarmCancel => 'Cancelar';

  @override
  String get testAlarmAsk => '¿Ha sonado?';

  @override
  String get testAlarmYes => 'Sí';

  @override
  String get testAlarmNo => 'No';

  @override
  String get testAlarmGood => 'Ha llegado. Tus recordatorios también llegarán.';

  @override
  String get testAlarmLookHere =>
      'Las comprobaciones de arriba muestran qué lo impide.';

  @override
  String get testAlarmLookLater =>
      'Encontrarás qué lo impide en Ajustes › Recordatorios › Estado de las notificaciones.';

  @override
  String testAlarmCountdown(int seconds) {
    return 'Sonará en $seconds s…';
  }

  @override
  String get syncLinePaused =>
      'Sincronización en pausa · toca Sincronización para ver por qué';

  @override
  String settingsSynced(String name, String ago) {
    return '$name · sincronizado $ago';
  }

  @override
  String settingsSyncedNoName(String ago) {
    return 'Sincronizado $ago';
  }

  @override
  String settingsNameAndStatus(String name, String status) {
    return '$name · $status';
  }

  @override
  String get calendarEventUntitled => 'Evento sin título';

  @override
  String get taskLinks => 'Enlaces';

  @override
  String taskLinkOpen(String host) {
    return 'Abrir $host en el navegador';
  }

  @override
  String get taskLinkFailed => 'No se pudo abrir ese enlace';

  @override
  String get calendarsWriteBack => 'Enviar cambios al calendario';

  @override
  String get calendarsWriteBackDetail =>
      'Lo que muevas, redimensiones o renombres aquí va al calendario, también lo anterior. Los eventos periódicos y de todo el día solo cambian aquí.';

  @override
  String bannerWriteBackPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios aún no han llegado a tu calendario',
      one: '1 cambio aún no ha llegado a tu calendario',
    );
    return '$_temp0';
  }

  @override
  String bannerWriteBackClash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos también cambiaron en tu calendario',
      one: 'Este evento también cambió en tu calendario',
    );
    return '$_temp0';
  }

  @override
  String get bannerUseCalendars => 'Usar el del calendario';

  @override
  String taskCalendarSends(String calendar) {
    return 'Los cambios vuelven a $calendar';
  }

  @override
  String taskCalendarStays(String calendar) {
    return 'De $calendar · los cambios se quedan en Dottoday';
  }

  @override
  String get travelTitle => 'Tiempo de trayecto';

  @override
  String travelSuggestDetail(String place, String duration) {
    return 'En $place. ¿Reservar $duration antes para llegar?';
  }

  @override
  String travelSuggestAdd(String duration) {
    return 'Añadir $duration antes';
  }

  @override
  String travelAdded(String title) {
    return 'Tiempo de trayecto añadido antes de “$title”';
  }

  @override
  String get travelNone => 'Ninguno';

  @override
  String travelBefore(String duration) {
    return '$duration antes';
  }

  @override
  String rowTravelMeta(String duration) {
    return '· $duration de trayecto';
  }

  @override
  String rowTravel(String label, String duration) {
    return '$label, $duration de trayecto antes';
  }

  @override
  String get calendarsTravel => 'Tiempo de trayecto';

  @override
  String get calendarsTravelSuggest => 'Sugerir tiempo de trayecto';

  @override
  String get calendarsTravelSuggestDetail =>
      'Antes de eventos con lugar. Se calcula en este dispositivo; no se consulta ningún mapa';

  @override
  String rowFromCalendar(String label) {
    return '$label, de tu calendario';
  }

  @override
  String get pinTitle => 'Fijada';

  @override
  String get pinDetail => 'Se queda en su sitio cuando otras tareas se mueven';

  @override
  String threadOutsideBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas antes de despertar',
      one: '1 tarea antes de despertar',
    );
    return '$_temp0';
  }

  @override
  String threadOutsideAfter(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas después de la hora de dormir',
      one: '1 tarea después de la hora de dormir',
    );
    return '$_temp0';
  }

  @override
  String get shortcutPickTask => 'Seleccionar la tarea anterior o siguiente';

  @override
  String get shortcutNudgeTask =>
      'Mover las tareas seleccionadas 5 min antes o después';

  @override
  String get shortcutNudgeTaskMore =>
      'Mover las tareas seleccionadas 15 min antes o después';

  @override
  String get shortcutTrashTask =>
      'Mover las tareas seleccionadas a la papelera';

  @override
  String get shortcutOpenTask => 'Abrir la tarea seleccionada';

  @override
  String get shortcutDoneTask => 'Marcar la tarea seleccionada como hecha';

  @override
  String get shortcutKeyDelete => 'Supr';

  @override
  String get shortcutKeySpace => 'Espacio';

  @override
  String get editorEnergy => 'Energía';

  @override
  String get energyLow => 'Baja';

  @override
  String get energyMedium => 'Media';

  @override
  String get energyHigh => 'Alta';

  @override
  String get editorNotesFormat =>
      '**negrita**, *cursiva*, - listas y enlaces funcionan aquí';

  @override
  String navInboxBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bandeja de entrada, $count tareas',
      one: 'Bandeja de entrada, 1 tarea',
    );
    return '$_temp0';
  }

  @override
  String get inboxNudgeTitle => 'Planifica tu bandeja';

  @override
  String inboxNudgeDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tareas esperan en tu bandeja. ¿Un buen momento para darles una hora?',
      one:
          '1 tarea espera en tu bandeja. ¿Un buen momento para darle una hora?',
    );
    return '$_temp0';
  }

  @override
  String get inboxNudgeAction => 'Planificar';

  @override
  String get settingsInboxNudge => 'Aviso: planificar la bandeja';

  @override
  String get settingsInboxNudgeDetail =>
      'Una vez al día desde que te levantas, si la bandeja tiene tareas';

  @override
  String settingsAlertsMore(String first, int count) {
    return '$first +$count';
  }

  @override
  String get settingsSound => 'Sonido';

  @override
  String get settingsSoundSystem => 'Sonido del sistema';

  @override
  String get settingsSoundDetail =>
      'Para los recordatorios de tareas. Toca uno para oírlo. La primera tarea del día mantiene su alarma.';

  @override
  String get soundDot => 'Punto';

  @override
  String get soundChime => 'Campanilla';

  @override
  String get soundBell => 'Campana';

  @override
  String get soundRipple => 'Onda';

  @override
  String get settingsQuietHours => 'Horas de silencio';

  @override
  String get settingsQuietHoursOff =>
      'Los recordatorios llegan en silencio por la noche';

  @override
  String settingsQuietHoursOn(String from, String until) {
    return '$from–$until: los recordatorios llegan en silencio. La primera tarea del día sigue sonando.';
  }

  @override
  String get settingsQuietFrom => 'Desde';

  @override
  String get settingsQuietUntil => 'Hasta';

  @override
  String get settingsDaySummary => 'Resumen del día';

  @override
  String get settingsDaySummaryOff => 'Desactivado';

  @override
  String get settingsDaySummaryDetail =>
      'Al despertar los días que elijas: «Tu día: 6 bloques, el primero a las 08:00».';

  @override
  String get notifDaySummaryTitle => 'Tu día';

  @override
  String notifDaySummaryBody(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bloques, el primero a las $time',
      one: '1 bloque, a las $time',
    );
    return '$_temp0';
  }

  @override
  String notifChannelAlertsSound(String sound) {
    return 'Avisos de tareas · $sound';
  }

  @override
  String liveActivityLeft(String time) {
    return 'quedan $time';
  }

  @override
  String liveActivityStartsIn(String time) {
    return 'empieza en $time';
  }

  @override
  String liveActivityCount(int done, int total) {
    return '$done de $total';
  }

  @override
  String liveActivityCountLabel(int done, int total) {
    return '$done de $total hechas hoy';
  }

  @override
  String get privacyThinkingTitle => 'Ayuda para pensar';

  @override
  String get privacyThinkingBody =>
      '«Dividir en pasos» y las sugerencias se calculan en este dispositivo: Apple Intelligence en iPhone y Mac, Gemini Nano en Android, el modelo integrado de Chrome. Si no hay ninguno, Dottoday usa tu propio historial y reglas sencillas. Lo que escribes nunca se envía a un servidor; preguntas y respuestas se quedan en este dispositivo.';

  @override
  String get privacyThinkingOnDevice =>
      'En este dispositivo ahora: el modelo integrado.';

  @override
  String get privacyThinkingRules =>
      'En este dispositivo ahora: tu historial y reglas sencillas.';

  @override
  String get privacyClearThinking => 'Borrar historial de ideas';

  @override
  String get snackThinkingCleared => 'Historial de ideas borrado';

  @override
  String get proposalAccept => 'Aceptar';

  @override
  String get proposalDiscard => 'Descartar';

  @override
  String get proposalNothingSaved => 'No se guarda nada hasta que aceptes';

  @override
  String get proposalLegendNow => 'ahora';

  @override
  String get proposalLegendProposed => 'propuesto';

  @override
  String proposalShiftedLater(String duration) {
    return 'movido +$duration';
  }

  @override
  String proposalShiftedEarlier(String duration) {
    return 'movido −$duration';
  }

  @override
  String proposalShrunk(String duration) {
    return 'acortado a $duration';
  }

  @override
  String proposalGrown(String duration) {
    return 'alargado a $duration';
  }

  @override
  String proposalMovedTo(String when) {
    return 'movido a $when';
  }

  @override
  String get proposalMovedToInbox => 'movido a la bandeja de entrada';

  @override
  String get proposalAdded => 'nuevo';

  @override
  String get proposalUntouched => 'fijado · sin cambios';

  @override
  String proposalSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos',
      one: '1 paso',
    );
    return '$_temp0';
  }

  @override
  String get proposalNothing => 'Nada que cambiar';

  @override
  String proposalKeep(String title) {
    return 'Dejar $title como está';
  }

  @override
  String proposalDayTime(String day, String time) {
    return '$day a las $time';
  }

  @override
  String get stepLengthAdd => '+ tiempo';

  @override
  String stepLengthHint(String title) {
    return 'Cambiar cuánto dura $title';
  }

  @override
  String get stepLengthTitle => '¿Cuánto dura este paso?';

  @override
  String get stepLengthNone => 'Sin tiempo';

  @override
  String get editorStepsSum => 'Duración = suma de los pasos';

  @override
  String editorStepsSumTotal(String duration) {
    return 'Los pasos suman $duration';
  }

  @override
  String get editorStepsSumEmpty => 'Da tiempo a un paso para usarlo';

  @override
  String get breakdownAction => 'Dividir en pasos';

  @override
  String get breakdownOnDevice => 'en el dispositivo';

  @override
  String get breakdownUsual => 'lo habitual';

  @override
  String breakdownStepHint(int number) {
    return 'Paso $number';
  }

  @override
  String get breakdownAddStep => 'Añadir un paso';

  @override
  String breakdownDepth(int depth, int max) {
    return 'nivel $depth de $max';
  }

  @override
  String get breakdownSplit => 'Dividir este paso';

  @override
  String get breakdownRemove => 'Quitar el paso';

  @override
  String breakdownShow(String title) {
    return 'Más de $title';
  }

  @override
  String breakdownTotal(String duration) {
    return 'Total $duration · el punto se ajusta';
  }

  @override
  String get breakdownSmallest =>
      'Si no empieza, solo te preguntaremos por el primer paso (Paso más pequeño)';

  @override
  String breakdownWasNow(String before, String after) {
    return 'antes $before → ahora $after';
  }

  @override
  String breakdownJoin(String parent, String step) {
    return '$parent · $step';
  }

  @override
  String breakdownAccepted(String title) {
    return 'Pasos añadidos a $title';
  }

  @override
  String breakdownStepsOnDraft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos',
      one: '1 paso',
    );
    return '$_temp0 · se guardan con la tarea';
  }

  @override
  String get focusTitle => 'Foco';

  @override
  String get focusBack => 'Hoy';

  @override
  String focusRange(String range, String length) {
    return '$range · $length';
  }

  @override
  String focusStep(int number, int total) {
    return 'Paso $number de $total';
  }

  @override
  String get focusAllSteps => 'Todos los pasos hechos';

  @override
  String get focusChime => 'Aviso cada 15 min';

  @override
  String get focusDeepWork => 'Trabajo profundo · Foco activado';

  @override
  String get focusDeepWorkAccess => 'Permite que Dottoday active No molestar';

  @override
  String get focusShortcutsTitle =>
      'Activa un modo de concentración con Atajos';

  @override
  String get focusShortcutsBody =>
      'El iPhone y el Mac no dejan que las apps cambien el modo de concentración. En Atajos, crea un atajo con «Empezar a concentrarte» de Dottoday y «Activar modo de concentración», y ejecútalo desde el botón de acción, el centro de control o Siri.';

  @override
  String get focusShortcutsOpen => 'Abrir Atajos';

  @override
  String get focusDeepWorkWeb =>
      'Usa No molestar del ordenador; el navegador no puede cambiarlo';

  @override
  String get focusNextStep => 'Siguiente paso';

  @override
  String get focusBreakThrough =>
      'Los inicios de puntos siguen llegando (urgentes)';

  @override
  String get focusMore => 'Más';

  @override
  String get focusOpenTask => 'Detalles de la tarea';

  @override
  String focusDoneMessage(String title) {
    return '$title hecho';
  }

  @override
  String focusExtendedMessage(String title) {
    return '$title · 15 min más';
  }

  @override
  String get focusOpenHint => 'Abrir foco';

  @override
  String smallestStepTitle(String step, String length) {
    return '¿Solo $step · $length?';
  }

  @override
  String smallestStepTitleShort(String step) {
    return '¿Solo $step?';
  }

  @override
  String get smallestStepStart => 'Empezar';

  @override
  String get unstickPrompt => '¿Qué es lo primerísimo que harías, físicamente?';

  @override
  String get unstickHint => 'p. ej. Abrir la carpeta';

  @override
  String get unstickSave => 'Convertir en el paso 1';

  @override
  String unstickSaved(String title) {
    return 'Paso 1 añadido a $title';
  }

  @override
  String get rebalanceAccept => 'Aceptar plan';

  @override
  String get rebalanceFootnote =>
      'Nada se mueve hasta que aceptes · Deshacer durante 30 s después';

  @override
  String get rebalanceShiftFollowers => 'Desplazar lo siguiente';

  @override
  String get rebalanceAllowShrink => 'Permitir acortar lo opcional';

  @override
  String get rebalancePastBedtime => 'Pasar de la hora de dormir';

  @override
  String rebalanceRanOver(String title, String duration) {
    return '$title se pasó $duration · aquí hay un plan';
  }

  @override
  String rebalanceLate(String duration) {
    return 'El resto del día $duration más tarde · aquí hay un plan';
  }

  @override
  String rebalanceRunsOver(String title, String duration) {
    return '$title se alarga $duration · aquí hay un plan';
  }

  @override
  String get rebalanceAccepted => 'Plan aceptado';

  @override
  String get calendarMovedTitle => 'Calendario cambiado';

  @override
  String calendarMovedDetail(String title, String time) {
    return '$title pasó a las $time · ¿reajustar?';
  }

  @override
  String get calendarMovedAction => 'Reajustar';

  @override
  String rebalanceMoved(String title, String time) {
    return '$title pasó a las $time · aquí hay un plan';
  }

  @override
  String realityMetaJoin(String text) {
    return '· $text';
  }

  @override
  String realityPlanned(String time) {
    return 'previsto $time';
  }

  @override
  String get realityNotStarted => 'aún sin empezar';

  @override
  String realityTook(String duration) {
    return 'duró $duration';
  }

  @override
  String realityRunning(String duration) {
    return '$duration en curso';
  }

  @override
  String get realityNow => 'ahora';

  @override
  String get realityPlan => 'Plan';

  @override
  String get realityReality => 'Real';

  @override
  String learnUsually(String duration) {
    return 'normalmente $duration';
  }

  @override
  String learnStartsAfter(int minutes) {
    return 'sueles empezar ~$minutes min después de lo previsto';
  }

  @override
  String learnStartsBefore(int minutes) {
    return 'sueles empezar ~$minutes min antes de lo previsto';
  }

  @override
  String learnInsight(String title, String duration) {
    return '$title suele llevarte $duration · Añadir lo sugerirá';
  }

  @override
  String get learnInsightOk => 'OK';

  @override
  String learnCaption(int total, int done) {
    return 'Tu hilo de la realidad aparece tras unas $total tareas terminadas · $done hasta ahora';
  }

  @override
  String get learnCaptionHide => 'Ocultar hasta mañana';

  @override
  String get learnRealityReady =>
      'La vista de plan y realidad ya está en la cabecera del día';

  @override
  String get realityNothingStartedToday => 'hoy aún no has empezado nada';

  @override
  String lateUsually(String title, String duration) {
    return '$title suele llevar $duration';
  }

  @override
  String get routinesTitle => 'Rutinas';

  @override
  String get routinesSubtitle => 'Trozos de hilo reutilizables';

  @override
  String routineSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos',
      one: '1 paso',
    );
    return '$_temp0';
  }

  @override
  String routineSummary(String steps, String duration, String anchor) {
    return '$steps · $duration · $anchor';
  }

  @override
  String get routineStartsWake => 'empieza al despertar';

  @override
  String get routineEndsBed => 'termina a la hora de dormir';

  @override
  String routineStartsAt(String time) {
    return 'empieza a las $time';
  }

  @override
  String get routineDropToday => 'Poner en hoy';

  @override
  String get routineEdit => 'Editar';

  @override
  String get routineNew => 'Nueva rutina';

  @override
  String get routineNewHint => 'o guarda una selección de cualquier día';

  @override
  String get routineAlarmNote =>
      'El inicio de una rutina suena fuerte, como una alarma';

  @override
  String get routinesEmpty =>
      'Aún no hay rutinas. Elige unas tareas de un día y guárdalas como rutina, o empieza una nueva.';

  @override
  String get routineSaveSelection => 'Guardar como rutina';

  @override
  String get routineName => 'Nombre';

  @override
  String routineSaved(String title) {
    return '«$title» guardada como rutina';
  }

  @override
  String routineDeleted(String title) {
    return '«$title» eliminada';
  }

  @override
  String get routineDelete => 'Eliminar rutina';

  @override
  String get routineEditTitle => 'Editar rutina';

  @override
  String get routineAnchorLabel => 'Cuándo';

  @override
  String get routineAnchorWake => 'Al despertar';

  @override
  String get routineAnchorBed => 'Terminando a la hora de dormir';

  @override
  String get routineAnchorTime => 'A una hora';

  @override
  String get routineStepsLabel => 'Pasos';

  @override
  String get routineStepHint => 'Nombre del paso';

  @override
  String get routineAddStep => 'Añadir paso';

  @override
  String routineRemoveStep(String title) {
    return 'Quitar $title';
  }

  @override
  String routineMoveUp(String title) {
    return 'Subir $title';
  }

  @override
  String routineMoveDown(String title) {
    return 'Bajar $title';
  }

  @override
  String routineGap(String duration) {
    return '$duration libre';
  }

  @override
  String get routineSave => 'Guardar';

  @override
  String get routineDropTitle => 'Rutina';

  @override
  String routineDropSubtitle(String title, String day, String time) {
    return '$title el $day · desde las $time';
  }

  @override
  String get routineDropAccept => 'Añadir al día';

  @override
  String get routineDropAccepted => 'Rutina añadida';

  @override
  String routineChipLabel(String title) {
    return 'Poner la rutina $title';
  }

  @override
  String get routinesMenu => 'Rutinas…';

  @override
  String get routinesSuggestions => 'Rutinas';

  @override
  String get routineInvalid => 'Pon un nombre a la rutina y al menos un paso';

  @override
  String routinesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rutinas',
      one: '1 rutina',
      zero: 'Sin rutinas',
    );
    return '$_temp0';
  }

  @override
  String get routineDropHere => 'Poner una rutina…';

  @override
  String routineDropOnDay(String day) {
    return 'Poner en $day';
  }

  @override
  String get routineDropDay => 'Qué día';

  @override
  String get settingsEnergy => 'Sugerencias de energía';

  @override
  String get settingsEnergyDetail =>
      'Sugerir las horas en que sueles terminar las tareas exigentes';

  @override
  String settingsEnergyLocked(int total, int count) {
    return 'Tras $total tareas exigentes terminadas · $count hasta ahora';
  }

  @override
  String settingsEnergyReady(int count) {
    return 'listo: basado en $count tareas terminadas';
  }

  @override
  String get settingsLearning => 'Aprendizaje';

  @override
  String get settingsLearningReality => 'Hilo de la realidad';

  @override
  String settingsLearningRealityPending(int total) {
    return 'Dottoday está aprendiendo cómo van de verdad tus días. Tu hilo de la realidad aparece tras unas $total tareas terminadas.';
  }

  @override
  String get settingsLearningRealityReady =>
      'Listo · Plan / Realidad está en la cabecera de Hoy';

  @override
  String get settingsLearningDurations => 'Duración de las tareas';

  @override
  String settingsLearningDurationsPending(int min) {
    return 'Dottoday está aprendiendo cuánto duran de verdad tus tareas. Cada tarea muestra su duración habitual tras unas $min veces terminada.';
  }

  @override
  String settingsLearningTasksReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Listo para $count tareas',
      one: 'Listo para 1 tarea',
    );
    return '$_temp0';
  }

  @override
  String get settingsLearningSteps => 'Duración de los pasos';

  @override
  String settingsLearningStepsPending(int min) {
    return 'Dottoday está aprendiendo cuánto dura cada paso. El temporizador de un paso usa su duración habitual tras unas $min veces terminado.';
  }

  @override
  String settingsLearningStepsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Listo para $count pasos',
      one: 'Listo para 1 paso',
    );
    return '$_temp0';
  }

  @override
  String settingsLearningProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String settingsLearningProgressLabel(int done, int total) {
    return '$done de $total hasta ahora';
  }

  @override
  String get settingsLearningPrivacy =>
      'El aprendizaje ocurre en tu dispositivo. Tus horas reales de inicio y fin se sincronizan con tu cuenta como el resto de tu plan; los valores aprendidos nunca se suben.';

  @override
  String addEnergyBest(String range) {
    return 'terminas mejor las tareas exigentes $range';
  }

  @override
  String addEnergyTry(String time) {
    return 'Probar $time';
  }

  @override
  String get debugLoadM11Sample => 'Cargar ejemplo M11 (debug)';

  @override
  String get debugM11Loaded => 'Ejemplo M11 cargado';

  @override
  String get proposalOverlaps => 'ya está · se solapa';

  @override
  String get weekReviewTitle => 'Esta semana';

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
    return '$day: $done de $total hechas, $planned planificadas';
  }

  @override
  String weekReviewPlanned(String planned) {
    return '$planned planificadas';
  }

  @override
  String weekReviewPlannedBusiest(String planned) {
    return '$planned · el más ocupado';
  }

  @override
  String weekReviewBusiest(String day) {
    return 'Más ocupado · $day';
  }

  @override
  String weekReviewLightest(String day) {
    return 'Más ligero · $day';
  }

  @override
  String get weekPaceMornings =>
      'Las mañanas fueron casi siempre según el plan.';

  @override
  String get weekPaceAfternoons =>
      'Las tardes fueron casi siempre según el plan.';

  @override
  String get weekPaceAllDone => 'Todo lo que planificaste está hecho.';

  @override
  String get weekPaceQuiet =>
      'Una semana tranquila: no había nada planificado.';

  @override
  String weekLoadBoth(String busiest, String lightest) {
    return 'El $busiest cargó con más; el $lightest respiró.';
  }

  @override
  String weekLoadBusiest(String busiest) {
    return 'El $busiest cargó con más.';
  }

  @override
  String weekCarryAsk(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sin terminar · ¿pasarlas a la próxima semana?',
      one: '1 sin terminar · ¿pasarla a la próxima semana?',
    );
    return '$_temp0';
  }

  @override
  String get weekCarryPlace => 'Colocar';

  @override
  String get weekCarryInbox => 'Dejar en la bandeja';

  @override
  String get weekCarryTitle => 'Próxima semana';

  @override
  String weekCarrySubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tareas sin terminar, cada una en el primer hueco libre que encaje',
      one: '1 tarea sin terminar, en el primer hueco libre que encaje',
    );
    return '$_temp0';
  }

  @override
  String get weekCarryAccept => 'Colocarlas';

  @override
  String get weekCarryAccepted => 'Colocadas en la próxima semana';

  @override
  String get weekShareTitles => 'Mostrar títulos de tareas';

  @override
  String get weekShareImage => 'Compartir imagen';

  @override
  String weekShareDayTitles(String day, String titles) {
    return '$day · $titles';
  }

  @override
  String get weekReviewNoStreaks => 'Aquí no hay rachas: solo lo que pasó.';

  @override
  String get weekPromptDetail => 'Tu semana en siete puntos';

  @override
  String get weekPromptAction => 'Ver la semana';

  @override
  String get lowEnergyMode => 'Modo baja energía';

  @override
  String get lowEnergyTurnOff => 'Desactivar el modo baja energía';

  @override
  String get settingsLowEnergyDetail =>
      'Hoy solo muestra lo siguiente y los avisos se pausan hasta tu próximo despertar';

  @override
  String lowEnergyCaption(String date) {
    return '$date · Baja energía';
  }

  @override
  String get lowEnergyGreeting => 'Tómatelo con calma';

  @override
  String lowEnergyGreetingName(String name) {
    return 'Tómatelo con calma, $name';
  }

  @override
  String get lowEnergyOn => 'Baja energía · activado';

  @override
  String lowEnergyUntil(String time, String left) {
    return 'hasta las $time · quedan $left';
  }

  @override
  String lowEnergyAt(String time) {
    return 'a las $time';
  }

  @override
  String get lowEnergyNotToday => 'Hoy no';

  @override
  String lowEnergyMovedTomorrow(String title) {
    return '$title pasada a mañana';
  }

  @override
  String lowEnergySkipped(String title) {
    return '$title omitida por hoy';
  }

  @override
  String lowEnergyLater(int count) {
    return 'Más tarde · $count';
  }

  @override
  String get lowEnergyShowLater => 'Mostrar lo de más tarde';

  @override
  String get lowEnergyHideLater => 'Ocultar lo de más tarde';

  @override
  String get lowEnergyPropose => '¿Pasar todo lo opcional a mañana?';

  @override
  String get lowEnergyProposeAction => 'Proponer';

  @override
  String get lowEnergyNudgesOff =>
      'Los avisos están apagados hasta el despertar de mañana';

  @override
  String get lowEnergyNothing => 'Nada más por hoy. Descansa.';

  @override
  String get lowEnergyProposalTitle => 'Mañana';

  @override
  String lowEnergyProposalSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tareas opcionales, cada una en el primer hueco libre de mañana',
      one: '1 tarea opcional, en el primer hueco libre de mañana',
    );
    return '$_temp0';
  }

  @override
  String get lowEnergyProposalAccept => 'Moverlas';

  @override
  String get lowEnergyProposalAccepted => 'Pasadas a mañana';

  @override
  String get journalTitle => 'Días pasados';

  @override
  String get journalEntryDetail => 'Cada día que planificaste, tal como fue';

  @override
  String get journalSearchHint => '¿Cuándo fue la última vez que…?';

  @override
  String journalDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días en los últimos 12 meses',
      one: '1 día en los últimos 12 meses',
    );
    return '$_temp0';
  }

  @override
  String journalLast(String date, int ago, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      ago,
      locale: localeName,
      other: 'hace $ago días',
      one: 'ayer',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ago,
      locale: localeName,
      other: 'hace $ago días',
      one: 'ayer',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Última vez: $date · $_temp0 · $count días',
      one: 'Última vez: $date · $_temp1 · una vez',
    );
    return '$_temp2';
  }

  @override
  String journalNoMatch(String query) {
    return 'Nada en los últimos 12 meses coincide con «$query»';
  }

  @override
  String get journalEmpty =>
      'Aún no hay días pasados. Los días que planifiques aparecerán aquí al terminar.';

  @override
  String journalDayLabel(String date, String summary) {
    return '$date, $summary. Abrir el día';
  }

  @override
  String journalMatch(String title, String time) {
    return '$title · $time';
  }

  @override
  String get journalStripTitle => 'Franja del año';

  @override
  String journalStripLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tu año en puntos: $count días planificados',
      one: 'Tu año en puntos: 1 día planificado',
    );
    return '$_temp0';
  }

  @override
  String get dumpTitle => 'Vaciar la mente';

  @override
  String get dumpHint => 'Todo lo que tienes en mente, una cosa por línea';

  @override
  String get dumpPlan => 'Planificar';

  @override
  String get dumpNothing =>
      'Aún no hay nada que planificar. Escribe una cosa por línea.';

  @override
  String dumpSubtitle(int count, String day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas $day, en el primer hueco libre',
      one: '1 tarea $day, en el primer hueco libre',
    );
    return '$_temp0';
  }

  @override
  String get dumpAccepted => 'Añadido desde tu lista';

  @override
  String get dumpEarlier => 'Listas anteriores';

  @override
  String get dumpSearch => 'Buscar en listas anteriores';

  @override
  String get dumpUseAgain => 'Usar de nuevo';

  @override
  String get proposalToInbox => 'sin hueco · a la bandeja';

  @override
  String get releaseNotes100 =>
      'Ver el tiempo: tu próximo punto en la pantalla de bloqueo, widgets, la barra de menús del Mac y Siri, y alarmas que suenan de verdad.\nEmpezar: divide una tarea en pasos pequeños, céntrate en un punto y recibe ayuda suave cuando algo no arranca.\nMantener el control: Reequilibrar muestra un plan antes de mover nada; Plan / Realidad muestra cómo fue el día de verdad.\nRutinas, sugerencias de energía y duraciones aprendidas de tus propios días, en tu dispositivo.\nEsta semana en siete puntos, Días pasados para mirar atrás y el modo baja energía para los días difíciles. Sin nada que mantener.\nComparte una página o una nota a Dottoday desde cualquier app, o vacía la mente con Vaciar la mente.';
}
