import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:timezone/timezone.dart' as tz;

/// What one Quick Add line becomes: a series, or one occurrence.
typedef DraftRows = ({Series? series, Occurrence? occurrence});

/// Turns a confirmed [draft] into rows to write (docs/02 F2, R-06, R-07).
///
/// - A time and "every …" → a [Series] starting on the draft's date
///   (today by default); saving it materialises the occurrences.
/// - A time → a one-off on the timeline.
/// - No time, or `@inbox` → an inbox item. "every …" without a time can't
///   repeat (a series needs a time), so the line keeps its whole text as
///   the title rather than silently dropping the rule.
///
/// The length is the draft's, else [defaultDurationMin]; an empty title
/// becomes [untitled].
///
/// ```dart
/// rowsFromDraft(parse('Gym 7am every day'), ...).series!.rrule; // FREQ=DAILY
/// ```
DraftRows rowsFromDraft(
  QuickAddDraft draft, {
  required String userId,
  required String tzId,
  required DateTime nowUtc,
  required int defaultDurationMin,
  required String untitled,
  IdGenerator ids = const UuidV7Generator(),
}) {
  final duration = draft.durationMin ?? defaultDurationMin;
  final start = draft.startUtc;
  final rrule = draft.rrule;
  final title = draft.title.isEmpty ? untitled : draft.title;
  if (rrule != null && start != null) {
    final local = tz.TZDateTime.from(start, tz.getLocation(tzId));
    return (
      series: Series(
        id: ids.newId(),
        userId: userId,
        title: title,
        durationMin: duration,
        rrule: rrule,
        dtstartLocal: _isoLocal(local),
        tzId: tzId,
        createdAt: nowUtc,
        updatedAt: nowUtc,
      ),
      occurrence: null,
    );
  }
  final keepWhole = rrule != null && draft.text.isNotEmpty;
  return (
    series: null,
    occurrence: Occurrence(
      id: ids.newId(),
      userId: userId,
      title: keepWhole ? draft.text : title,
      startUtc: start,
      tzId: tzId,
      durationMin: duration,
      createdAt: nowUtc,
      updatedAt: nowUtc,
    ),
  );
}

/// `2026-10-21T15:00`: the floating local start a series stores.
String _isoLocal(DateTime t) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)}T${two(t.hour)}:${two(t.minute)}';
}
