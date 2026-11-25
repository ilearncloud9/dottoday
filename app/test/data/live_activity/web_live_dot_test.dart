import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/live_activity/web_live_dot.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The browser tab's live dot (docs/09 M9.7): "● 38 min left · <title>"
// and a favicon ring while a dot is live; the Inbox count for the badge.

final _start = DateTime.utc(2026, 10, 21, 7);
final _en = lookupAppLocalizations(const Locale('en'));

DaySnapshot _snapshot({int inbox = 3}) => DaySnapshot(
  generatedAtUtc: _start,
  wakeUtc: _start.subtract(const Duration(hours: 2)),
  bedUtc: _start.add(const Duration(hours: 13)),
  inboxCount: inbox,
  dots: [
    SnapshotDot(
      id: 'deep',
      title: 'Deep work: roadmap',
      startUtc: _start,
      durationMin: 120,
      colorKey: 'indigo',
      iconKey: 'code',
      done: false,
    ),
  ],
);

// Teal, the App colour's default (appColourTones).
const _teal = {
  'light': {'dot': '#11615C'},
  'dark': {'dot': '#5BC4B8'},
};

String _decoded(String dataUrl) =>
    Uri.decodeComponent(dataUrl.substring('data:image/svg+xml,'.length));

void main() {
  test('live: title, favicon ring in the App colour, badge', () {
    final tab = webLiveDot(
      _snapshot(),
      _start.add(const Duration(minutes: 82)),
      _en,
      accent: _teal,
    );
    expect(tab.title, '● 38 min left · Deep work: roadmap');
    final svg = _decoded(tab.favicon!);
    // Light tone, and the bright tone on a dark browser (ED-474).
    expect(svg, contains('.c{stroke:#11615C}'));
    expect(
      svg,
      contains('@media (prefers-color-scheme:dark){.c{stroke:#5BC4B8}'),
    );
    // 82 of 120 min: 68 % of a 2πr = 75.40 ring.
    expect(svg, contains("stroke-dasharray='51.52 75.40'"));
    expect(tab.badge, 3);
  });

  test('German words its own way round', () {
    final de = lookupAppLocalizations(const Locale('de'));
    final tab = webLiveDot(
      _snapshot(),
      _start.add(const Duration(minutes: 82)),
      de,
      accent: _teal,
    );
    expect(tab.title, startsWith('● noch 38'));
  });

  test('overrunning: the dot and its name, no "0 min left"', () {
    final tab = webLiveDot(
      _snapshot(),
      _start.add(const Duration(minutes: 130)),
      _en,
      accent: _teal,
    );
    expect(tab.title, '● Deep work: roadmap');
    expect(_decoded(tab.favicon!), contains("stroke-dasharray='75.40 75.40'"));
  });

  test('nothing live: the app\'s own title and icon; the badge stays', () {
    final soon = webLiveDot(
      _snapshot(inbox: 0),
      _start.subtract(const Duration(minutes: 10)),
      _en,
      accent: _teal,
    );
    expect(soon, const WebLiveDot());
    expect(webLiveDot(null, _start, _en, accent: _teal), WebLiveDot.none);
    expect(
      webLiveDot(
        _snapshot(),
        _start.add(const Duration(hours: 5)),
        _en,
        accent: _teal,
      ).badge,
      3,
    );
  });
}
