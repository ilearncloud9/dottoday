// The browser side of reminders (docs/09 M5.3): the Notification API and
// the service worker (web/sw.js). Hand-written `dart:js_interop` bindings,
// like the DB key vault, so the app takes no `package:web` dependency.
import 'dart:async';
import 'dart:js_interop';

import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';

@JS('Notification')
extension type _Notification._(JSObject _) implements JSObject {
  external static String get permission;
  external static JSPromise<JSString> requestPermission();
}

@JS('navigator.serviceWorker')
external _ServiceWorkerContainer? get _serviceWorker;

extension type _ServiceWorkerContainer._(JSObject _) implements JSObject {
  external JSPromise<_Registration> get ready;
  external _ServiceWorker? get controller;
  external void addEventListener(String type, JSFunction listener);
}

extension type _ServiceWorker._(JSObject _) implements JSObject {
  external void postMessage(JSAny message);
}

extension type _Registration._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> showNotification(String title, JSObject options);
}

extension type _Message._(JSObject _) implements JSObject {
  external JSAny? get data;
}

extension type _ClickMessage._(JSObject _) implements JSObject {
  external String? get type;
  external String? get action;
  external int? get id;
  external String? get payload;
}

/// Whether the page may post notifications.
bool get browserNotificationsSupported => _serviceWorker != null;

/// The browser's notification permission.
PermissionState browserPermission() {
  if (!browserNotificationsSupported) return PermissionState.denied;
  return switch (_Notification.permission) {
    'granted' => PermissionState.granted,
    'denied' => PermissionState.denied,
    _ => PermissionState.notAsked,
  };
}

/// Shows the browser's prompt (once; afterwards only site settings).
Future<PermissionState> requestBrowserPermission() async {
  if (!browserNotificationsSupported) return PermissionState.denied;
  await _Notification.requestPermission().toDart;
  return browserPermission();
}

/// Posts [n] through the service worker now, with Done and +15 (Chrome
/// shows at most two actions; a tap opens the task, M9.7); false without permission or a worker.
Future<bool> showBrowserNotification(
  OsNotification n, {
  required String doneLabel,
  required String plusLabel,
}) async {
  final worker = _serviceWorker;
  if (worker == null || browserPermission() != PermissionState.granted) {
    return false;
  }
  final registration = await worker.ready.toDart;
  final options =
      {
            'body': n.body,
            'tag': '${n.id}',
            'silent': n.silent,
            'icon': 'icons/Icon-192.png',
            'data': {'id': n.id, 'payload': n.payload},
            'actions': [
              if (n.withActions) ...[
                {'action': NotificationAction.done.name, 'title': doneLabel},
                {'action': NotificationAction.plus15.name, 'title': plusLabel},
              ],
            ],
          }.jsify()!
          as JSObject;
  await registration.showNotification(n.title, options).toDart;
  return true;
}

/// One per page: the service worker's messages arrive on it.
final _taps = StreamController<NotificationTap>.broadcast();
var _listening = false;

/// Taps and actions the service worker reports, including ones that
/// opened this page (it queues them until we say we listen).
Stream<NotificationTap> browserNotificationTaps() {
  final worker = _serviceWorker;
  if (worker == null) return const Stream.empty();
  if (_listening) return _taps.stream;
  _listening = true;
  worker.addEventListener(
    'message',
    ((_Message event) {
      final data = event.data;
      if (data == null || !data.isA<JSObject>()) return;
      final m = data as _ClickMessage;
      if (m.type != 'dottoday-notification') return;
      _taps.add(
        NotificationTap(id: m.id, actionId: m.action, payload: m.payload),
      );
    }).toJS,
  );
  unawaited(_sayReady(worker));
  return _taps.stream;
}

Future<void> _sayReady(_ServiceWorkerContainer worker) async {
  await worker.ready.toDart;
  worker.controller?.postMessage({'type': 'dottoday-ready'}.jsify()!);
}
