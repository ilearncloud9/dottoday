import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/wake_up/tier_gained.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/15 §11 "Device gains the alarm tier": only an OS update that
// brings the alarm tier counts.
void main() {
  const old = TierSeen(AlarmTier.timeSensitive, 'Version 18.6');
  const updated = TierSeen(AlarmTier.alarm, 'Version 26.1');

  test('an OS update that brings the alarm tier', () {
    expect(tierGainedByUpdate(old, updated), isTrue);
  });

  test('a first look, the same OS, or already there: no', () {
    expect(tierGainedByUpdate(null, updated), isFalse);
    expect(
      tierGainedByUpdate(
        const TierSeen(AlarmTier.headsUp, 'Version 26.1'),
        updated,
      ),
      isFalse,
      reason: 'a permission given, not an update',
    );
    expect(
      tierGainedByUpdate(const TierSeen(AlarmTier.alarm, '18.6'), updated),
      isFalse,
    );
    expect(
      tierGainedByUpdate(old, const TierSeen(AlarmTier.timeSensitive, '26.1')),
      isFalse,
    );
  });

  test('stored and read back; anything else is nothing', () {
    final back = TierSeen.parse(updated.stored)!;
    expect((back.tier, back.os), (AlarmTier.alarm, 'Version 26.1'));
    expect(TierSeen.parse(null), isNull);
    expect(TierSeen.parse('nope'), isNull);
    expect(TierSeen.parse('loud|26'), isNull);
  });
}
