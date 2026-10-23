import 'dart:async';

import 'package:dottoday/core/router/deep_link_guard.dart';

/// `dottoday://auth-callback?code=…` (docs/09 M6.1): where the sign-in page
/// hands back the one-time PKCE code. It is never a route (the 06 §7
/// allow-list doesn't change); the router passes it to the account
/// service and shows Settings › Account.
const authCallbackHost = 'auth-callback';

/// The redirect URL registered with Supabase Auth for the apps.
const authCallbackLink = '$deepLinkScheme://$authCallbackHost';

/// Whether [uri] is a sign-in callback.
bool isAuthCallback(Uri uri) =>
    uri.scheme == deepLinkScheme && uri.host == authCallbackHost;

/// Holds callbacks until the account service listens: on a cold start the
/// link arrives before any provider exists.
final class AuthCallbackInbox {
  final _pending = <Uri>[];
  final _links = StreamController<Uri>.broadcast();

  /// From the router: a callback came in.
  void deliver(Uri uri) {
    if (_links.hasListener) {
      _links.add(uri);
    } else {
      _pending.add(uri);
    }
  }

  /// Every callback, the waiting ones first. Listens at once, so no link
  /// falls between handing over the waiting ones and listening.
  Stream<Uri> take() => Stream.multi((out) {
    final sub = _links.stream.listen(out.add);
    _pending.forEach(out.add);
    _pending.clear();
    out.onCancel = sub.cancel;
  });
}
