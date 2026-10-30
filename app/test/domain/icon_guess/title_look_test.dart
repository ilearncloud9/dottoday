import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/icon_guess/title_look.dart';
import 'package:flutter_test/flutter_test.dart';

final _at = DateTime.utc(2026, 10, 21, 8);

Occurrence _task({String icon = 'circle', String color = 'indigo'}) =>
    Occurrence(
      id: 'o',
      userId: 'u',
      title: '',
      tzId: 'Europe/Berlin',
      durationMin: 30,
      iconKey: icon,
      colorKey: color,
      createdAt: _at,
      updatedAt: _at,
    );

(String, String) _look(Occurrence o) => (o.iconKey, o.colorKey);

void main() {
  test('a plain task follows its title, and back to plain', () {
    final opened = _task();
    final look = TitleLook(opened);
    final gym = look.retitle(opened, 'Gym', language: 'en');
    expect((gym.title, _look(gym)), ('Gym', ('gym', 'coral')));
    final other = look.retitle(gym, 'Xyzzy', language: 'en');
    expect(_look(other), ('circle', 'indigo'));
  });

  test("a task's own icon is never replaced", () {
    final opened = _task(icon: 'heart', color: 'sky');
    final o = TitleLook(opened).retitle(opened, 'Gym', language: 'en');
    expect(_look(o), ('heart', 'sky'));
  });

  test('a plain icon with its own colour keeps the colour', () {
    final opened = _task(color: 'mint');
    final o = TitleLook(opened).retitle(opened, 'Gym', language: 'en');
    expect(_look(o), ('gym', 'mint'));
  });

  // As in Add: each pick stops only what was picked.
  test('picking an icon or colour stops that one following', () {
    final opened = _task();
    final look = TitleLook(opened);
    final picked = look.pickIcon(opened, 'heart');
    final o = look.retitle(picked, 'Gym', language: 'en');
    expect(_look(o), ('heart', 'coral'));

    final look2 = TitleLook(opened);
    final coloured = look2.pickColor(opened, 'sky');
    final o2 = look2.retitle(coloured, 'Gym', language: 'en');
    expect(_look(o2), ('gym', 'sky'));
  });
}
