import 'package:dottoday/core/router/auth_callback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only dottoday://auth-callback is a sign-in callback', () {
    expect(isAuthCallback(Uri.parse('$authCallbackLink?code=x')), isTrue);
    expect(isAuthCallback(Uri.parse('dottoday://inbox?code=x')), isFalse);
    expect(isAuthCallback(Uri.parse('https://auth-callback/?code=x')), isFalse);
  });

  // A cold start: the link comes before the account service listens.
  test('the inbox keeps a link until someone listens, then streams', () async {
    final inbox = AuthCallbackInbox();
    final first = Uri.parse('$authCallbackLink?code=1');
    final second = Uri.parse('$authCallbackLink?code=2');
    inbox.deliver(first);
    final got = <Uri>[];
    final sub = inbox.take().listen(got.add);
    await pumpEventQueue();
    inbox.deliver(second);
    await pumpEventQueue();
    await sub.cancel();
    expect(got, [first, second]);
  });

  test('a link right after listening is not lost', () async {
    final inbox = AuthCallbackInbox();
    final link = Uri.parse('$authCallbackLink?code=3');
    final got = <Uri>[];
    final sub = inbox.take().listen(got.add);
    inbox.deliver(link);
    await pumpEventQueue();
    await sub.cancel();
    expect(got, [link]);
  });
}
