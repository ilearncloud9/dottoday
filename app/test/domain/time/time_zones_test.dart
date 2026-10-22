import 'package:dottoday/domain/time/time_zones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('zoneCity', () {
    expect(zoneCity('Europe/Berlin'), 'Berlin');
    expect(zoneCity('America/New_York'), 'New York');
    expect(zoneCity('America/Argentina/Buenos_Aires'), 'Buenos Aires');
    expect(zoneCity('UTC'), 'UTC');
  });

  test('pickableZones drops aliases and sorts', () {
    expect(
      pickableZones(['Europe/Paris', 'EST5EDT', 'Etc/GMT+5', 'Asia/Tokyo']),
      ['Asia/Tokyo', 'Europe/Paris'],
    );
  });

  test('searchZones: case, spaces as underscores, limit', () {
    final zones = ['America/New_York', 'Europe/London', 'Europe/Lisbon'];
    expect(searchZones(zones, 'new york'), ['America/New_York']);
    expect(searchZones(zones, 'LON'), ['Europe/London']);
    expect(searchZones(zones, 'europe', limit: 1), ['Europe/London']);
    expect(searchZones(zones, '  '), isEmpty);
  });
}
