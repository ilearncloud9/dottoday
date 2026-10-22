import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

/// [blocks] as plain text under [heading], in time order, one task per
/// line ("✓ 9:00 AM – 11:00 AM  Deep work"), skipped ones left out: Today's
/// ⋯ › Copy day as text (docs/09 M3f.6; the file export is M8.1). [time]
/// renders an instant in the user's zone and format.
///
/// ```dart
/// dayAsText(heading: 'Wednesday, 21 October', blocks: rows, time: fmt);
/// ```
String dayAsText({
  required String heading,
  required List<Occurrence> blocks,
  required String Function(DateTime utc) time,
}) {
  final timed = [
    for (final o in blocks)
      if (o.startUtc != null && o.status != OccurrenceStatus.skipped) o,
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  return [
    heading,
    for (final o in timed)
      _line(
        o.status == OccurrenceStatus.done ? _done : _open,
        time(o.startUtc!),
        time(o.endUtc!),
        o.title,
      ),
  ].join('\n'); // l10n-ignore: a line break
}

const _done = '✓'; // l10n-ignore: plain-text mark, same in every language
const _open = '○'; // l10n-ignore: plain-text mark, same in every language

String _line(String mark, String from, String to, String title) =>
    '$mark $from – $to  $title'; // l10n-ignore: plain-text row, as on the thread
