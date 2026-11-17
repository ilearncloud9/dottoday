import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/calendar_series.dart';
import 'package:dottoday/domain/entities/calendar_series_template.dart';
import 'package:dottoday/domain/entities/enums.dart';

// CR-160 Stage A: calendar-series settings with every field set, so a
// round trip that drops or reorders one is caught.

final _at = DateTime.utc(2026, 11, 1, 9);

/// Every override set; steps deliberately not in id or title order.
CalendarSeries fullSeries({
  required String id,
  required String userId,
  String accountId = '',
  String seriesKey = 'EVT-standup',
  bool hidden = false,
}) => CalendarSeries(
  id: id,
  userId: userId,
  accountId: accountId,
  seriesKey: seriesKey,
  title: 'Standup',
  notes: 'Bring blockers\nand demos',
  colorKey: 'mint',
  iconKey: 'coffee',
  durationMin: 25,
  startMinute: 9 * 60 + 15,
  tzId: 'Europe/Berlin',
  pinned: true,
  travelBufferMin: 10,
  energy: Energy.high,
  alerts: const [
    Alert(kind: AlertKind.before, offsetMin: 10, sound: 'chime'),
    Alert(kind: AlertKind.atStart),
  ],
  soundId: 'system',
  subtaskTemplate: const [
    SubtaskTemplateItem(id: 'z', title: 'Third', sortOrder: 3),
    SubtaskTemplateItem(id: 'a', title: 'First', sortOrder: 1, durationMin: 5),
    SubtaskTemplateItem(id: 'm', title: 'Second', sortOrder: 2),
  ],
  hidden: hidden,
  createdAt: _at,
  updatedAt: _at.add(const Duration(hours: 1)),
);

/// [fullSeries] as a file template for [provider]'s calendar [calendarId].
CalendarSeriesTemplate fullTemplate({
  required String id,
  required String userId,
  CalendarProvider provider = CalendarProvider.appleDevice,
  String calendarId = 'work',
  String seriesKey = 'EVT-standup',
  String? deviceTag,
  bool hidden = false,
}) => CalendarSeriesTemplate(
  provider: provider,
  externalCalendarId: calendarId,
  deviceTag: deviceTag,
  settings: fullSeries(
    id: id,
    userId: userId,
    seriesKey: seriesKey,
    hidden: hidden,
  ),
);
