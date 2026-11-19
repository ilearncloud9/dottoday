import 'package:dottoday/core/theme/task_palette.dart';
import 'package:dottoday/core/theme/tokens.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

// Concept E's colours as the approved boards draw them (foundation step 1,
// ED-360). Each pair was measured on the Design canvas, version
// 1794787239-a691: the light value is what the 53 active light boards draw
// for the role, the dark value what their dark companions draw in the same
// place (the ED-181 converter, matched across 50 board pairs). Renders of
// those boards are in docs/design-references/concept-e/.
//
// If a token stops matching the boards, this test fails. Change a value
// only with a decision that changes the boards too.

typedef _Pair = (Color light, Color dark);

const _roles = <String, _Pair>{
  'ground': (Color(0xFFFBF7F1), Color(0xFF171416)),
  'card': (Color(0xFFFFFDF9), Color(0xFF28232A)),
  'sunk': (Color(0xFFF6F1EA), Color(0xFF1F1B1E)),
  'chip': (Color(0xFFEDE7DF), Color(0xFF2F2A30)),
  'tile': (Color(0xFFF1ECE4), Color(0xFF2F2A30)),
  'control': (Color(0xFFECE5DC), Color(0xFF37313A)),
  'avatar': (Color(0xFFE7DFEF), Color(0xFF37313A)),
  'canvas': (Color(0xFFEFE7DB), Color(0xFF28232A)),
  'ink': (Color(0xFF241F2B), Color(0xFFF3ECE4)),
  'ink2': (Color(0xFF4E4757), Color(0xFFC7BEC4)),
  'secondary': (Color(0xFF6A6273), Color(0xFFC7BEC4)),
  'tertiary': (Color(0xFF7A7280), Color(0xFF8C838A)),
  'ring': (Color(0xFF8A8494), Color(0xFF8C838A)),
  'placeholder': (Color(0xFF6F6978), Color(0xFFA0999F)),
  'threadAhead': (Color(0xFFBEB6C7), Color(0xFF6B6369)),
  'threadOnRaised': (Color(0xFFBEB6C7), Color(0xFF7B7279)),
  'controlOutline': (Color(0xFFCFC6D6), Color(0xFF4A4348)),
  'hairline': (Color(0x14241F2B), Color(0x1AFFF5EB)),
  'hairlineStrong': (Color(0x1F241F2B), Color(0x29FFF5EB)),
  'calendarIcon': (Color(0xFF3B3543), Color(0xFFE6DEE2)),
  'tabOff': (Color(0xFF6E6E73), Color(0xFFC7BEC4)),
  'accentText': (Color(0xFF0B4642), Color(0xFFA3E2D9)),
  'tonal': (Color(0xFFE2EFEC), Color(0xFF1E3A37)),
  'tonalAndroid': (Color(0xFFCFE8E4), Color(0xFF1E3A37)),
  'onTonalAndroid': (Color(0xFF062F2C), Color(0xFFA3E2D9)),
  'selectedWeb': (Color(0xFFD9ECE9), Color(0xFF1E3A37)),
  'wakeCap': (Color(0xFFFBEBC8), Color(0xFF483924)),
  'wakeIcon': (Color(0xFF9A5A0E), Color(0xFFD9A23A)),
  'windCap': (Color(0xFFE6E3F7), Color(0xFF333148)),
  'windIcon': (Color(0xFF4B3FB0), Color(0xFFA9ACEB)),
  'orbTrack': (Color(0xFFE4E3F7), Color(0xFF302F48)),
  'orbInner': (Color(0xFFF1F0FB), Color(0xFF28232A)),
  'destructive': (Color(0xFFC8322F), Color(0xFFB5473C)),
  'swipeMove': (Color(0xFF6A6273), Color(0xFF636366)),
};

/// Set by decisions rather than measured on a frame: the focus ring
/// (ED-174, ED-211) and the iOS switch (ED-112, ED-174).
const _decided = <String, _Pair>{
  'focus': (Color(0xFF11615C), Color(0xFF7FD6CB)),
  'switchOn': (Color(0xFF11615C), Color(0xFF2A8C83)),
};

/// Task colours: light fill, light ahead ring (ED-155, ED-161) and the
/// dark fill that is also the dark ring (ED-175).
const _tasks = <String, (Color fill, Color ring, Color dark)>{
  'coral': (Color(0xFFE2725B), Color(0xFFDF6147), Color(0xFFE2725B)),
  'amber': (Color(0xFFD9A23A), Color(0xFFAF7E22), Color(0xFFD9A23A)),
  'mint': (Color(0xFF4CA36B), Color(0xFF469763), Color(0xFF4CA36B)),
  'teal': (Color(0xFF2A9D8F), Color(0xFF289588), Color(0xFF2A9D8F)),
  'sky': (Color(0xFF4A9BD6), Color(0xFF338ED1), Color(0xFF4A9BD6)),
  'indigo': (Color(0xFF5B5FD6), Color(0xFF5B5FD6), Color(0xFF7A7EDE)),
  'violet': (Color(0xFF8B5CF6), Color(0xFF8B5CF6), Color(0xFF9672E6)),
  'rose': (Color(0xFFD9668F), Color(0xFFD75E89), Color(0xFFD9668F)),
  'slate': (Color(0xFF6E6A75), Color(0xFF6E6A75), Color(0xFF898590)),
  // ED-161's new keys, their dark values the approved ones (ED-219).
  'brown': (Color(0xFF8C6A4F), Color(0xFF8C6A4F), Color(0xFFA67F60)),
  'plum': (Color(0xFF9E4F8F), Color(0xFF9E4F8F), Color(0xFFB76FA9)),
  'olive': (Color(0xFF7F8A3A), Color(0xFF7F8A3A), Color(0xFF828E3C)),
};

Color _role(DotPalette p, String role) => switch (role) {
  'ground' => p.ground,
  'card' => p.card,
  'sunk' => p.sunk,
  'chip' => p.chip,
  'tile' => p.tile,
  'control' => p.control,
  'avatar' => p.avatar,
  'canvas' => p.canvas,
  'ink' => p.ink,
  'ink2' => p.ink2,
  'secondary' => p.secondary,
  'tertiary' => p.tertiary,
  'ring' => p.ring,
  'placeholder' => p.placeholder,
  'threadAhead' => p.threadAhead,
  'threadOnRaised' => p.threadOnRaised,
  'controlOutline' => p.controlOutline,
  'hairline' => p.hairline,
  'hairlineStrong' => p.hairlineStrong,
  'calendarIcon' => p.calendarIcon,
  'tabOff' => p.tabOff,
  'accentText' => p.accentText,
  'tonal' => p.tonal,
  'tonalAndroid' => p.tonalAndroid,
  'onTonalAndroid' => p.onTonalAndroid,
  'selectedWeb' => p.selectedWeb,
  'wakeCap' => p.wakeCap,
  'wakeIcon' => p.wakeIcon,
  'windCap' => p.windCap,
  'windIcon' => p.windIcon,
  'orbTrack' => p.orbTrack,
  'orbInner' => p.orbInner,
  'destructive' => p.destructive,
  'swipeMove' => p.swipeMove,
  'focus' => p.focus,
  'switchOn' => p.switchOn,
  _ => throw ArgumentError(role),
};

void main() {
  group('colour roles match the approved boards', () {
    for (final MapEntry(key: role, value: (light, dark)) in {
      ..._roles,
      ..._decided,
    }.entries) {
      test(role, () {
        expect(_role(DotPalette.light, role), light, reason: 'light $role');
        expect(_role(DotPalette.dark, role), dark, reason: 'dark $role');
      });
    }
  });

  group('task colours match the approved boards', () {
    for (final MapEntry(key: key, value: (fill, ring, dark))
        in _tasks.entries) {
      test(key, () {
        final c = TaskColor.fromKey(key);
        expect(c.key, key);
        expect(c.color, fill, reason: 'light fill');
        expect(c.ring, ring, reason: 'light ahead ring');
        expect(c.dark, dark, reason: 'dark fill and ring');
      });
    }
    test('every stored key is covered', () {
      expect(TaskColor.values.map((c) => c.key).toSet(), _tasks.keys.toSet());
    });
  });

  test('the default accent is Concept E teal', () {
    expect(DotAccent.fallback, DotAccent.teal);
    expect(DotAccent.teal.light, const Color(0xFF11615C));
    expect(DotAccent.teal.dark, const Color(0xFF5BC4B8));
  });
}
