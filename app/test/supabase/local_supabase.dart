import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Q9 (ED-352): these tests run only against a local stack. The isolated test
// stack (`tool/test_stack.sh`, `dottoday-test`) serves 55321; the original
// app's stack serves 54321 and is allowed only on CI's throw-away runner.
const _testStackPort = 55321;
const _ciPort = 54321;
const _localHosts = {'127.0.0.1', 'localhost'};

String _env(String name) {
  final value = Platform.environment[name];
  if (value == null || value.isEmpty) {
    throw StateError(
      '$name is not set. Run the client tests with `tool/test_stack.sh test` '
      'or `eval "\$(tool/test_stack.sh env)"` first.',
    );
  }
  return value;
}

/// Why [url] is refused, or null when it is a local test stack. Exposed for
/// the guard's own unit test.
String? refuseUrl(String url, {required bool ci}) {
  final uri = Uri.tryParse(url);
  if (uri == null || !_localHosts.contains(uri.host)) {
    return 'host must be 127.0.0.1 or localhost';
  }
  if (uri.port == _testStackPort) return null;
  if (uri.port == _ciPort && ci) return null;
  return 'port must be $_testStackPort (tool/test_stack.sh)'
      '${ci ? '' : ', or $_ciPort only when CI=true'}';
}

String _guarded(String name) {
  final url = _env(name);
  final reason = refuseUrl(url, ci: Platform.environment['CI'] == 'true');
  if (reason != null) {
    throw StateError('Refusing $name=$url: $reason.');
  }
  return url;
}

/// The local stack's API, from the environment only (no `supabase status`
/// from the current folder, which may be the original app's stack).
final localUrl = _guarded('SUPABASE_URL');
final localAnonKey = _env('SUPABASE_ANON_KEY');

/// The local stack's service-role key, for checks a user can't make (that
/// rows are gone) and for cleanup. Test-only: the app never holds it (06 §1).
final localServiceKey = _env('SUPABASE_SERVICE_ROLE_KEY');

/// Mailpit of the same local stack; the sign-in mails land there.
final _mailpit = _localHost('MAILPIT_URL');

String _localHost(String name) {
  final url = _env(name);
  if (!_localHosts.contains(Uri.tryParse(url)?.host)) {
    throw StateError(
      'Refusing $name=$url: host must be 127.0.0.1 or localhost.',
    );
  }
  return url;
}

final _created = <String>{};

/// Call first in each file's `main`: checks the stack before any test runs and
/// deletes the users the file created ([testEmail]) once its tests are done.
void useLocalSupabase() {
  setUpAll(() {
    localUrl;
    localAnonKey;
    localServiceKey;
    _mailpit;
  });
  tearDownAll(_deleteCreatedUsers);
}

/// A fresh address for [prefix] on the reserved `.test` domain, removed in
/// `tearDownAll` by [useLocalSupabase].
String testEmail(String prefix) {
  final email = '$prefix-${DateTime.now().microsecondsSinceEpoch}@example.test';
  _created.add(email);
  return email;
}

Future<void> _deleteCreatedUsers() async {
  if (_created.isEmpty) return;
  final admin = SupabaseClient(localUrl, localServiceKey);
  try {
    for (var page = 1; _created.isNotEmpty; page++) {
      final users = await admin.auth.admin.listUsers(page: page, perPage: 200);
      if (users.isEmpty) break;
      for (final user in users) {
        if (_created.remove(user.email)) {
          await admin.auth.admin.deleteUser(user.id);
        }
      }
    }
    _created.clear();
  } finally {
    await admin.dispose();
  }
}

/// Rows of [table] owned by [userId], as the server holds them.
Future<List<Object?>> adminRows(String table, String userId) async {
  final http = HttpClient();
  try {
    final idColumn = table == 'profiles' ? 'id' : 'user_id';
    final request = await http.getUrl(
      Uri.parse('$localUrl/rest/v1/$table?$idColumn=eq.$userId&select=id'),
    );
    request.headers
      ..set('apikey', localServiceKey)
      ..set('Authorization', 'Bearer $localServiceKey');
    final response = await request.close();
    return jsonDecode(await response.transform(utf8.decoder).join())
        as List<Object?>;
  } finally {
    http.close();
  }
}

/// A client like the app's: PKCE, the verifier in memory.
SupabaseClient localClient() => SupabaseClient(
  localUrl,
  localAnonKey,
  authOptions: AuthClientOptions(pkceAsyncStorage: MemoryPkceStorage()),
);

final class MemoryPkceStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _items[key];

  @override
  Future<void> setItem({required String key, required String value}) async =>
      _items[key] = value;

  @override
  Future<void> removeItem({required String key}) async => _items.remove(key);
}

/// The sign-in link mailed to [email], followed one hop: where the server
/// redirects the browser (the app's callback with the code).
Future<Uri> magicLinkCallback(String email) async {
  final http = HttpClient();
  try {
    final link = await _waitForLink(http, email);
    final request = await http.getUrl(link)
      ..followRedirects = false;
    final response = await request.close();
    await response.drain<void>();
    return Uri.parse(response.headers.value(HttpHeaders.locationHeader)!);
  } finally {
    http.close();
  }
}

Future<Uri> _waitForLink(HttpClient http, String email) async {
  for (var i = 0; i < 50; i++) {
    final search = await _json(
      http,
      Uri.parse(
        '$_mailpit/api/v1/search?query=${Uri.encodeQueryComponent('to:"$email"')}',
      ),
    );
    final messages = search['messages'] as List<dynamic>;
    if (messages.isNotEmpty) {
      final id = (messages.first as Map<String, dynamic>)['ID'] as String;
      final message = await _json(
        http,
        Uri.parse('$_mailpit/api/v1/message/$id'),
      );
      final text = '${message['Text']} ${message['HTML']}';
      final match = RegExp(
        r'https?://[^\s"<>]+/auth/v1/verify\?[^\s"<>]+',
      ).firstMatch(text);
      return Uri.parse(match!.group(0)!.replaceAll('&amp;', '&'));
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  throw StateError('no sign-in mail for $email');
}

Future<Map<String, dynamic>> _json(HttpClient http, Uri uri) async {
  final response = await (await http.getUrl(uri)).close();
  return jsonDecode(await response.transform(utf8.decoder).join())
      as Map<String, dynamic>;
}
