import 'package:dottoday/domain/calendar/calendar_writer.dart';
import 'package:dottoday/domain/calendar/imported_event.dart';
import 'package:dottoday/domain/calendar/write_back_merge.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter_test/flutter_test.dart';

// Three-way merge of one imported event (docs/09 M7.3, R-02, R-08): what
// the calendar last had, the occurrence here, the event there now.

final _nine = DateTime.utc(2026, 10, 21, 7);
final _ten = _nine.add(const Duration(hours: 1));
const _untitled = 'Untitled event';

final _base = ImportFingerprint(
  startMs: _nine.millisecondsSinceEpoch,
  durationMin: 30,
  title: textHash('Standup'),
  notes: textHash('agenda'),
);

final _here = Occurrence(
  id: 'o1',
  userId: 'u1',
  title: 'Standup',
  notes: 'agenda',
  startUtc: _nine,
  tzId: 'Europe/Berlin',
  durationMin: 30,
  source: OccurrenceSource.calendar,
  calendarLinkId: 'l1',
  createdAt: _nine,
  updatedAt: _nine,
);

RemoteEvent _there({
  DateTime? start,
  Duration length = const Duration(minutes: 30),
  String title = 'Standup',
}) {
  final s = start ?? _nine;
  return RemoteEvent(
    startUtc: s,
    endUtc: s.add(length),
    title: title,
    version: 'v',
  );
}

WriteBackMerge _merge(
  Occurrence local,
  RemoteEvent remote, {
  WriteBackPrefer prefer = WriteBackPrefer.ask,
}) => mergeWriteBack(
  base: _base,
  local: local,
  remote: remote,
  untitled: _untitled,
  prefer: prefer,
);

void main() {
  test('nothing changed here: nothing to send', () {
    expect(hasLocalChange(_here, _base), isFalse);
    expect(
      hasLocalChange(_here.copyWith(notes: 'mine'), _base),
      isFalse,
      reason: 'notes never go back',
    );
  });

  test('a move here sends the new start and keeps the length', () {
    final moved = _here.copyWith(startUtc: _ten);
    expect(hasLocalChange(moved, _base), isTrue);
    final m = _merge(moved, _there()) as WriteBackMerged;
    expect(m.patch!.startUtc, _ten);
    expect(m.patch!.endUtc, _ten.add(const Duration(minutes: 30)));
    expect(m.patch!.title, isNull, reason: "the calendar's own title stays");
    expect(m.adopted, isNull);
    expect(m.fingerprint.startMs, _ten.millisecondsSinceEpoch);
    expect(m.fingerprint.notes, _base.notes);
  });

  test('a resize sends the new end; a rename the new title', () {
    final changed = _here.copyWith(durationMin: 45, title: 'Standup + demo');
    final m = _merge(changed, _there()) as WriteBackMerged;
    expect(m.patch!.endUtc, _nine.add(const Duration(minutes: 45)));
    expect(m.patch!.title, 'Standup + demo');
    expect(m.fingerprint.title, textHash('Standup + demo'));
  });

  test('a move keeps the real length of a longer-than-a-day event', () {
    final base = ImportFingerprint(
      startMs: _nine.millisecondsSinceEpoch,
      durationMin: 1440,
      title: textHash('Retreat'),
      notes: textHash(null),
    );
    final local = _here.copyWith(
      title: 'Retreat',
      durationMin: 1440,
      startUtc: _ten,
    );
    final m =
        mergeWriteBack(
              base: base,
              local: local,
              remote: _there(
                length: const Duration(hours: 50),
                title: 'Retreat',
              ),
              untitled: _untitled,
            )
            as WriteBackMerged;
    expect(m.patch!.endUtc, _ten.add(const Duration(hours: 50)));
  });

  test('different fields changed on each side merge both ways', () {
    final moved = _here.copyWith(startUtc: _ten);
    final m = _merge(moved, _there(title: 'Sync')) as WriteBackMerged;
    expect(m.patch!.startUtc, _ten);
    expect(m.patch!.title, isNull);
    expect(m.adopted!.title, 'Sync', reason: "the calendar's rename comes in");
    expect(m.adopted!.startUtc, _ten);
    expect(m.fingerprint.title, textHash('Sync'));
  });

  test('the same change on both sides leaves nothing to send', () {
    final m =
        _merge(_here.copyWith(startUtc: _ten), _there(start: _ten))
            as WriteBackMerged;
    expect(m.patch, isNull);
    expect(m.adopted, isNull);
    expect(m.fingerprint.startMs, _ten.millisecondsSinceEpoch);
  });

  test('one field changed both ways is a clash, never overwritten', () {
    final moved = _here.copyWith(startUtc: _ten);
    final there = _there(start: _nine.add(const Duration(hours: 3)));
    final clash = _merge(moved, there);
    expect(clash, isA<WriteBackClash>());
    expect((clash as WriteBackClash).fields, {WriteBackField.start});
  });

  test('Keep mine sends mine; Use calendar\'s takes theirs', () {
    final moved = _here.copyWith(startUtc: _ten);
    final noon = _nine.add(const Duration(hours: 3));
    final mine =
        _merge(moved, _there(start: noon), prefer: WriteBackPrefer.mine)
            as WriteBackMerged;
    expect(mine.patch!.startUtc, _ten);
    expect(mine.adopted, isNull);
    final theirs =
        _merge(moved, _there(start: noon), prefer: WriteBackPrefer.calendar)
            as WriteBackMerged;
    expect(theirs.patch, isNull);
    expect(theirs.adopted!.startUtc, noon);
  });

  test("a title emptied in the calendar compares as the import's name", () {
    final base = ImportFingerprint(
      startMs: _nine.millisecondsSinceEpoch,
      durationMin: 30,
      title: textHash(_untitled),
      notes: textHash(null),
    );
    final local = _here.copyWith(title: _untitled, startUtc: _ten);
    final m =
        mergeWriteBack(
              base: base,
              local: local,
              remote: _there(title: ''),
              untitled: _untitled,
            )
            as WriteBackMerged;
    expect(m.patch!.title, isNull, reason: 'never writes the placeholder');
  });
}
